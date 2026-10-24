// ui/notebook.ts — 引月札：周目信息 / 收藏计数 / 记忆条目（Tab 开关）；封闭矩形纸底面板
import { Color, DrawNode, Label, Node, Sprite, Texture2D, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { LoopState } from "core/types";
import { MEMORIES_LIST, PHASE_NAMES } from "data/story";
import * as Tower from "data/tower";

const FONT = "sarasa-mono-sc-regular";

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
  private tokenLb: Label.Type | undefined;
  private causeLbs: Label.Type[];
  private memoryLbs: Label.Type[];
  private openFlag: boolean;
  // 收藏图标：用户素材 Sprite（与世界里对应物件同一贴图）；缺失时 update 回退程序化画法
  private iconMoon: Sprite.Type | undefined;
  private iconToken: Sprite.Type | undefined;

  constructor(parent: Node.Type) {
    this.memoryLbs = [];
    this.causeLbs = [];
    this.openFlag = false;
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
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
    this.tokenLb = makeLabel(this.root, 19, -96, 56, 0, 0.5, Palette.inkSoft);
    // 整改三：因果记录（引月札栏目）；石子行已按需求移除，因果上移补位
    const h4 = makeLabel(this.root, 20, -392, -16, 0, 0.5, Palette.gold);
    setText(h4, "因果");
    for (let i = 0; i < 4; i++) {
      const lb = makeLabel(this.root, 16, -392, -48 - i * 28, 0, 0.5, Palette.inkSoft);
      if (lb !== undefined) {
        this.causeLbs.push(lb);
      }
    }
    for (let i = 0; i < MEMORIES_LIST.length; i++) {
      const lb = makeLabel(this.root, 19, 118, 92 - i * 36, 0, 0.5, Palette.inkSoft);
      if (lb !== undefined) {
        this.memoryLbs.push(lb);
      }
    }
    const footer = makeLabel(this.root, 16, 0, -224, 0.5, 0.5, Palette.paleInk);
    setText(footer, "Tab 关闭");
    // 收藏图标素材化：月石=moon_stone（与世界月石收集品同贴图）、旧物=e7_shard（月华碎片）；机关件行已按需求移除（2026-10-26），旧物上移补位
    this.iconMoon = this.makeIcon("assets/tiles/moon_stone.png", -116, 92, 26);
    this.iconToken = this.makeIcon("assets/props/e7_shard.png", -116, 56, 26);
  }

  // 面板收藏图标：按逻辑高度等比缩放的素材 Sprite；加载失败返回 undefined（update 回退程序化画法）
  private makeIcon(path: string, x: number, y: number, h: number): Sprite.Type | undefined {
    const tex = Texture2D(path);
    if (tex === undefined) {
      return undefined;
    }
    const sp = Sprite(tex);
    if (sp === undefined) {
      return undefined;
    }
    sp.scaleX = h / tex.height;
    sp.scaleY = h / tex.height;
    sp.position = Vec2(x, y);
    sp.addTo(this.root);
    return sp;
  }

  // 探针用：已成功素材化的图标数（0~2）
  debugIconCount(): number {
    let n = 0;
    if (this.iconMoon !== undefined) {
      n += 1;
    }
    if (this.iconToken !== undefined) {
      n += 1;
    }
    return n;
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
    // 纸底面板 880x500：封闭矩形（填充 + 墨框），内描金线
    this.draw.drawPolygon(
      [Vec2(-440, -250), Vec2(440, -250), Vec2(440, 250), Vec2(-440, 250)],
      col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), 2, col(Palette.inkDark)
    );
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
    // 检查点显示中文名（data/tower.checkpoints 的 label），无匹配时回退「未记录」
    let checkpointName = "未记录";
    for (let i = 0; i < Tower.checkpoints.length; i++) {
      if (Tower.checkpoints[i].id === state.currentCheckpointId) {
        checkpointName = Tower.checkpoints[i].label;
        break;
      }
    }
    setText(this.checkLb, "检查点：" + checkpointName);
    // 收藏计数
    setText(this.stoneLb, "月石　x " + state.moonstones);
    setText(this.tokenLb, "旧物　x " + state.tokens);
    // 因果记录：只显示最近 4 条（旧→新）
    const total = state.causalityLog.length;
    const start = Math.max(0, total - this.causeLbs.length);
    for (let i = 0; i < this.causeLbs.length; i++) {
      const idx = start + i;
      if (idx < total) {
        setText(this.causeLbs[i], (idx + 1) + ". " + state.causalityLog[idx]);
        this.causeLbs[i].color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, Palette.inkSoft.a);
      } else {
        setText(this.causeLbs[i], "");
      }
    }
    // 收藏小图标：素材 Sprite 常驻 root（随面板显隐）；此处只在素材缺失时回退程序化画法
    if (this.iconMoon === undefined) {
      this.draw.drawDot(Vec2(-116, 92), 7, col(Palette.moonCyan));
      this.draw.drawDot(Vec2(-116, 92), 10, col(Palette.moonCyanFaint));
    }
    if (this.iconToken === undefined) {
      this.draw.drawPolygon([Vec2(-116, 62), Vec2(-108, 56), Vec2(-116, 50), Vec2(-124, 56)], col(Palette.vermilion));
    }
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
