// ui/dialog.ts — 剧情对话框：纸底面板 + 打字机 + 选项列表（青色菱形选中）
import { Color, DrawNode, Label, Node, Sprite, Texture2D, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { DialogChoice, DialogLine, StoryNode } from "core/types";

const FONT = "sarasa-mono-sc-regular";
const CHARS_PER_SEC = 28;
const CHOICE_POOL = 4;
// 像素素材：对话框底板 / 名牌 / 面板（Point 采样，非均匀拉伸允许）
const BOX_TEX = "assets/ui/dialogue_box.png";
const PLATE_TEX = "assets/ui/nameplate.png";
const PANEL_TEX = "assets/ui/panel.png";
const BOX_SCALE_X = 15;
const BOX_SCALE_Y = 4;
const PLATE_SCALE = 2;
const CHOICE_W = 580;

function loadTex(path: string): Texture2D.Type | undefined {
  return Texture2D(path);
}

function pxSprite(tex: Texture2D.Type): Sprite.Type {
  const sp = Sprite(tex);
  sp.filter = "Point" as unknown as number;
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

function setLabelColor(lb: Label.Type | undefined, color: InkColor): void {
  if (lb !== undefined) {
    lb.color = Color(color.r, color.g, color.b, color.a);
  }
}

export class DialogUI {
  private root: Node.Type;
  private panel: DrawNode.Type;
  private choicesDraw: DrawNode.Type;
  private speakerLb: Label.Type | undefined;
  private textLb: Label.Type | undefined;
  private choiceLbs: Label.Type[];
  private lines: DialogLine[];
  private node: StoryNode | undefined;
  private fallbackSpeaker: string;
  private lineIndex: number;
  private charShown: number;
  private shownCount: number;
  private choiceMode: boolean;
  private selected: number;
  private openFlag: boolean;
  public onChoice: (index: number) => void;
  private boxTex: Texture2D.Type | undefined;
  private plateTex: Texture2D.Type | undefined;
  private panelTex: Texture2D.Type | undefined;
  private boxSp: Sprite.Type | undefined;
  private plateSp: Sprite.Type | undefined;
  private choicePanelSp: Sprite.Type | undefined;

  constructor(parent: Node.Type) {
    this.lines = [];
    this.choiceLbs = [];
    this.node = undefined;
    this.fallbackSpeaker = "";
    this.lineIndex = 0;
    this.charShown = 0;
    this.shownCount = -1;
    this.choiceMode = false;
    this.selected = 0;
    this.openFlag = false;
    this.onChoice = function (_index: number): void {};
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
    this.panel = DrawNode();
    this.panel.addTo(this.root);
    const h = View.size.height;
    const top = -h / 2 + 196;
    const bot = -h / 2 + 26;
    this.panel.drawPolygon(
      [Vec2(-490, bot), Vec2(490, bot), Vec2(490, top), Vec2(-490, top)],
      col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 235)), 2, col(Palette.inkDark)
    );
    this.panel.drawSegment(Vec2(-490, top - 52), Vec2(490, top - 52), 1, col(Palette.goldSoft));
    // 像素素材层：对话框底板 + 名牌 + 选项面板底（纹理缺失时保留程序化纸底）
    this.boxTex = loadTex(BOX_TEX);
    this.plateTex = loadTex(PLATE_TEX);
    this.panelTex = loadTex(PANEL_TEX);
    if (this.boxTex !== undefined) {
      this.panel.visible = false;
      const box = pxSprite(this.boxTex);
      box.scaleX = BOX_SCALE_X;
      box.scaleY = BOX_SCALE_Y;
      box.position = Vec2(0, (bot + top) / 2);
      box.addTo(this.root);
      this.boxSp = box;
    }
    if (this.plateTex !== undefined) {
      const plate = pxSprite(this.plateTex);
      plate.scaleX = PLATE_SCALE;
      plate.scaleY = PLATE_SCALE;
      plate.anchor = Vec2(0, 0.5);
      plate.position = Vec2(-474, top - 28);
      plate.addTo(this.root);
      this.plateSp = plate;
    }
    if (this.panelTex !== undefined) {
      const cp = pxSprite(this.panelTex);
      cp.visible = false;
      cp.addTo(this.root);
      this.choicePanelSp = cp;
    }
    this.speakerLb = makeLabel(this.root, 24, -462, top - 28, 0, 0.5, Palette.inkDark);
    this.textLb = makeLabel(this.root, 22, -462, bot + 56, 0, 0.5, Palette.inkSoft);
    this.choicesDraw = DrawNode();
    this.choicesDraw.addTo(this.root);
    for (let i = 0; i < CHOICE_POOL; i++) {
      const lb = makeLabel(this.root, 20, 0, -h / 2 + 260 - i * 42, 0.5, 0.5, Palette.paleInk);
      if (lb !== undefined) {
        this.choiceLbs.push(lb);
      }
    }
  }

  open(node: StoryNode, speaker: string): void {
    this.node = node;
    this.fallbackSpeaker = speaker;
    this.lines = node.lines;
    this.lineIndex = 0;
    this.charShown = 0;
    this.shownCount = -1;
    this.choiceMode = false;
    this.selected = 0;
    this.openFlag = true;
    this.root.visible = true;
    this.choicesDraw.clear();
    this.applyLine();
  }

  close(): void {
    this.openFlag = false;
    this.root.visible = false;
    this.choiceMode = false;
    this.choicesDraw.clear();
  }

  isOpen(): boolean {
    return this.openFlag;
  }

  hasChoices(): boolean {
    return this.node !== undefined && this.node.choices !== undefined && this.node.choices.length > 0;
  }

  /** 选项列表是否已展示（choiceMode）。只有此时 confirmChoice() 才有效。 */
  inChoiceMode(): boolean {
    return this.openFlag && this.choiceMode;
  }

  choiceCount(): number {
    if (this.node === undefined || this.node.choices === undefined) {
      return 0;
    }
    return this.node.choices.length;
  }

  moveChoice(dir: number): void {
    if (!this.choiceMode || this.choiceCount() === 0) {
      return;
    }
    const n = this.choiceCount();
    this.selected = Math.max(0, Math.min(n - 1, this.selected + dir));
    this.drawChoices();
  }

  confirmChoice(): void {
    if (!this.choiceMode) {
      // 选项尚未展示时按确认 = 推进文本，而不是无动作（否则选项对话必卡死）。
      this.advance();
      return;
    }
    const idx = this.selected;
    const cb = this.onChoice;
    this.close();
    cb(idx);
  }

  advance(): void {
    if (!this.openFlag || this.choiceMode || this.lineIndex >= this.lines.length) {
      return;
    }
    const full = this.lines[this.lineIndex].text.length;
    if (this.charShown < full) {
      this.charShown = full;
      this.applyLine();
      return;
    }
    if (this.lineIndex < this.lines.length - 1) {
      this.lineIndex = this.lineIndex + 1;
      this.charShown = 0;
      this.shownCount = -1;
      this.applyLine();
      return;
    }
    if (this.hasChoices() && this.choiceCount() > 0) {
      this.choiceMode = true;
      this.selected = 0;
      this.applyChoices();
      this.drawChoices();
      return;
    }
    // 协议：无选项节点自然走完 → onChoice(-1)。
    // 若只 close 不回调，game.mode 会永远停在 "dialog"，所有按键失效（卡死）。
    const cb = this.onChoice;
    this.close();
    cb(-1);
  }

  update(dt: number): void {
    if (!this.openFlag || this.choiceMode || this.lineIndex >= this.lines.length) {
      return;
    }
    if (this.charShown >= this.lines[this.lineIndex].text.length) {
      return;
    }
    this.charShown = Math.min(this.charShown + CHARS_PER_SEC * dt, this.lines[this.lineIndex].text.length);
    this.applyLine();
  }

  private applyLine(): void {
    if (this.lineIndex >= this.lines.length) {
      return;
    }
    const line = this.lines[this.lineIndex];
    const speaker = line.speaker !== "" ? line.speaker : this.fallbackSpeaker;
    setText(this.speakerLb, speaker);
    const n = Math.floor(this.charShown);
    if (n !== this.shownCount) {
      this.shownCount = n;
      setText(this.textLb, line.text.slice(0, n));
    }
  }

  private applyChoices(): void {
    if (this.node === undefined || this.node.choices === undefined) {
      return;
    }
    for (let i = 0; i < this.choiceLbs.length; i++) {
      setText(this.choiceLbs[i], i < this.node.choices.length ? this.node.choices[i].text : "");
    }
  }

  private drawChoices(): void {
    this.choicesDraw.clear();
    if (this.choicePanelSp !== undefined) {
      this.choicePanelSp.visible = false;
    }
    if (!this.choiceMode || this.node === undefined || this.node.choices === undefined) {
      return;
    }
    const h = View.size.height;
    const n = this.node.choices.length;
    const boxH = n * 42 + 24;
    const boxY = -h / 2 + 260 - (n - 1) * 21;
    if (this.choicePanelSp !== undefined) {
      this.choicePanelSp.visible = true;
      this.choicePanelSp.position = Vec2(0, boxY);
      this.choicePanelSp.scaleX = CHOICE_W / 32;
      this.choicePanelSp.scaleY = boxH / 32;
    } else {
      this.choicesDraw.drawPolygon(
        [Vec2(-290, boxY - boxH / 2), Vec2(290, boxY - boxH / 2), Vec2(290, boxY + boxH / 2), Vec2(-290, boxY + boxH / 2)],
        col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 245)), 2, col(Palette.inkDark)
      );
    }
    for (let i = 0; i < this.choiceLbs.length; i++) {
      const sel = i === this.selected;
      const lb = this.choiceLbs[i];
      if (i >= n) {
        setText(lb, "");
        continue;
      }
      const y = -h / 2 + 260 - i * 42;
      lb.position = Vec2(30, y);
      lb.anchor = Vec2(0, 0.5);
      setLabelColor(lb, sel ? Palette.moonCyan : Palette.paleInk);
      if (sel) {
        this.choicesDraw.drawPolygon(
          [Vec2(-250, y + 9), Vec2(-241, y), Vec2(-250, y - 9), Vec2(-259, y)],
          col(Palette.moonCyan)
        );
        this.choicesDraw.drawPolygon(
          [Vec2(-270, y - 15), Vec2(270, y - 15), Vec2(270, y + 15), Vec2(-270, y + 15)],
          col(ink(Palette.moonCyan.r, Palette.moonCyan.g, Palette.moonCyan.b, 40))
        );
      }
    }
  }
}
