// ui/notebook.ts — 引月札：周目信息 / 收藏计数 / 记忆条目（Tab 开关）
import { Color, DrawNode, Label, Node, Sprite, Texture2D, TextureFilter, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { LoopState } from "core/types";
import { MEMORIES_LIST, PHASE_NAMES } from "data/story";
import * as Tower from "data/tower";

const FONT = "sarasa-mono-sc-regular";

// 检查点内部 id → 层名（显示用）
function checkpointLabel(id: string): string {
  for (let i = 0; i < Tower.checkpoints.length; i++) {
    if (Tower.checkpoints[i].id === id) {
      return Tower.FLOORS[Tower.checkpoints[i].floor] + "·" + Tower.checkpoints[i].label;
    }
  }
  return id;
}
// 像素素材：panel.png 平铺面板底（Point 采样）
const PANEL_TEX = "assets/ui/panel.png";
const PANEL_W = 880;
const PANEL_H = 500;
const PANEL_COLS = 7;
const PANEL_ROWS = 4;

function loadTex(path: string): Texture2D.Type | undefined {
  return Texture2D(path);
}

function pxSprite(tex: Texture2D.Type): Sprite.Type {
  const sp = Sprite(tex);
  sp.filter = TextureFilter.Point;
  return sp;
}

function col(c: InkColor): Color.Type { return Color(c.r, c.g, c.b, c.a); }

function makeLabel(parent: Node.Type, size: number, x: number, y: number, ax: number, ay: number, color: InkColor): Label.Type | undefined {
  const lb = Label(FONT, size);
  if (lb === undefined) {
    return undefined;
  }
  lb.anchor = Vec2(ax, ay);
  lb.position = Vec2(x, y);
  lb.color = Color(color.r, color.g, color.b, color.a);
  lb.addTo(parent);
  return lb;
}

function setText(lb: Label.Type | undefined, text: string): void {
  if (lb !== undefined && lb.text !== text) {
    lb.text = text;
  }
}

export class NotebookUI {
  private root: Node.Type;
  private draw: DrawNode.Type;
  private loopLb: Label.Type | undefined;
  private phaseLb: Label.Type | undefined;
  private checkLb: Label.Type | undefined;
  private stoneLb: Label.Type | undefined;
  private mechLb: Label.Type | undefined;
  private tokenLb: Label.Type | undefined;
  private memoryLbs: Label.Type[];
  private openFlag: boolean;
  private panelTex: Texture2D.Type | undefined;
  private tilesNode: Node.Type | undefined;
  private pxPanel: boolean;

  constructor(parent: Node.Type) {
    this.memoryLbs = [];
    this.openFlag = false;
    this.pxPanel = false;
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
    // 像素面板底：panel.png 7x4 平铺（点采样），先于 draw 加入保证墨框/图标在其上；纹理缺失保留程序化纸底
    this.panelTex = loadTex(PANEL_TEX);
    if (this.panelTex !== undefined) {
      this.tilesNode = Node();
      this.tilesNode.addTo(this.root);
      const tileW = PANEL_W / PANEL_COLS;
      const tileH = PANEL_H / PANEL_ROWS;
      for (let r = 0; r < PANEL_ROWS; r++) {
        for (let c = 0; c < PANEL_COLS; c++) {
          const sp = pxSprite(this.panelTex);
          sp.anchor = Vec2(0, 0);
          sp.scaleX = tileW / 32;
          sp.scaleY = tileH / 32;
          sp.position = Vec2(-PANEL_W / 2 + c * tileW, -PANEL_H / 2 + r * tileH);
          sp.addTo(this.tilesNode);
        }
      }
      this.pxPanel = true;
    }
    this.draw = DrawNode();
    this.draw.addTo(this.root);
    // 标题与栏头
    const title = makeLabel(this.root, 34, 0, 186, 0.5, 0.5, Palette.inkDark);
    setText(title, "引月札");
    const h1 = makeLabel(this.root, 20, -392, 138, 0, 0.5, Palette.gold);
    setText(h1, "周目");
    const h2 = makeLabel(this.root, 20, -132, 138, 0, 0.5, Palette.gold);
    setText(h2, "收藏");
    const h3 = makeLabel(this.root, 20, 88, 138, 0, 0.5, Palette.gold);
    setText(h3, "记忆");
    // 三栏内容（每帧 update 时按状态刷新文字）
    this.loopLb = makeLabel(this.root, 19, -392, 92, 0, 0.5, Palette.inkSoft);
    this.phaseLb = makeLabel(this.root, 19, -392, 56, 0, 0.5, Palette.inkSoft);
    this.checkLb = makeLabel(this.root, 19, -392, 20, 0, 0.5, Palette.inkSoft);
    this.stoneLb = makeLabel(this.root, 19, -96, 92, 0, 0.5, Palette.inkSoft);
    this.mechLb = makeLabel(this.root, 19, -96, 56, 0, 0.5, Palette.inkSoft);
    this.tokenLb = makeLabel(this.root, 19, -96, 20, 0, 0.5, Palette.inkSoft);
    for (let i = 0; i < MEMORIES_LIST.length; i++) {
      const lb = makeLabel(this.root, 19, 118, 92 - i * 36, 0, 0.5, Palette.inkSoft);
      if (lb !== undefined) {
        this.memoryLbs.push(lb);
      }
    }
    const footer = makeLabel(this.root, 16, 0, -224, 0.5, 0.5, Palette.paleInk);
    setText(footer, "Tab 关闭");
  }

  toggle(): void {
    this.openFlag = !this.openFlag;
    this.root.visible = this.openFlag;
  }

  isOpen(): boolean {
    return this.openFlag;
  }

  update(_dt: number, state: LoopState): void {
    if (!this.openFlag) {
      return;
    }
    const w = View.size.width;
    const h = View.size.height;
    this.draw.clear();
    // 纸底面板 880x500：像素平铺底→仅描墨框/金线；程序化回退→填充 + 墨框 + 金线
    if (this.pxPanel) {
      this.draw.drawPolygon(
        [Vec2(-440, -250), Vec2(440, -250), Vec2(440, 250), Vec2(-440, 250)],
        col(ink(0, 0, 0, 0)), 2, col(Palette.inkDark)
      );
    } else {
      this.draw.drawPolygon(
        [Vec2(-440, -250), Vec2(440, -250), Vec2(440, 250), Vec2(-440, 250)],
        col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), 2, col(Palette.inkDark)
      );
    }
    this.draw.drawPolygon(
      [Vec2(-428, -238), Vec2(428, -238), Vec2(428, 238), Vec2(-428, 238)],
      col(ink(0, 0, 0, 0)), 1, col(Palette.goldSoft)
    );
    this.draw.drawSegment(Vec2(-172, -210), Vec2(-172, 190), 1, col(Palette.inkFaint));
    this.draw.drawSegment(Vec2(48, -210), Vec2(48, 190), 1, col(Palette.inkFaint));
    // 周目信息
    const phaseName = state.phaseIndex >= 0 && state.phaseIndex < PHASE_NAMES.length ? PHASE_NAMES[state.phaseIndex] : "";
    setText(this.loopLb, "第" + (state.loopIndex + 1) + "周目");
    setText(this.phaseLb, "当前月相：" + phaseName);
    setText(this.checkLb, "检查点：" + checkpointLabel(state.currentCheckpointId));
    // 收藏计数
    setText(this.stoneLb, "月石　x " + state.moonstones);
    setText(this.mechLb, "机关件　x " + state.mechanismParts);
    setText(this.tokenLb, "旧物　x " + state.tokens);
    // 收藏小图标
    this.draw.drawDot(Vec2(-116, 92), 7, col(Palette.moonCyan));
    this.draw.drawDot(Vec2(-116, 92), 10, col(Palette.moonCyanFaint));
    this.draw.drawPolygon([Vec2(-116, 62), Vec2(-107, 56), Vec2(-116, 50), Vec2(-125, 56)], col(Palette.gold), 1, col(Palette.inkDark));
    this.draw.drawPolygon([Vec2(-116, 26), Vec2(-108, 20), Vec2(-116, 14), Vec2(-124, 20)], col(Palette.vermilion));
    // 记忆条目：已知实心墨点 + 正文；未知「？」虚位
    for (let i = 0; i < this.memoryLbs.length; i++) {
      const known = i < MEMORIES_LIST.length && state.memories.indexOf(MEMORIES_LIST[i]) >= 0;
      const y = 92 - i * 36;
      if (known) {
        this.draw.drawDot(Vec2(102, y), 5, col(Palette.inkDark));
        setText(this.memoryLbs[i], MEMORIES_LIST[i]);
        this.memoryLbs[i].color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, Palette.inkSoft.a);
      } else {
        this.draw.drawPolygon([Vec2(102, y + 6), Vec2(108, y), Vec2(102, y - 6), Vec2(96, y)], col(ink(0, 0, 0, 0)), 1, col(Palette.inkFaint));
        setText(this.memoryLbs[i], "？");
        this.memoryLbs[i].color = Color(Palette.paleInkFar.r, Palette.paleInkFar.g, Palette.paleInkFar.b, Palette.paleInkFar.a);
      }
    }
  }
}
