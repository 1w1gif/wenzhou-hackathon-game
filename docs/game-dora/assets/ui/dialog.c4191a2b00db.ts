// ui/dialog.ts — 剧情对话框：封闭矩形纸底面板 + 打字机 + 选项按钮（参考 dialogue-lite 布局）
import { Color, DrawNode, Label, Node, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { DialogChoice, DialogLine, StoryNode } from "core/types";

const FONT = "sarasa-mono-sc-regular";
const CHARS_PER_SEC = 28;
const CHOICE_POOL = 4;

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

/** 等宽字宽：sarasa 全角＝字号、半角＝半字号（CJK 与全角标点按全角计） */
function charW(ch: string, size: number): number {
  const code = ch.charCodeAt(0);
  return code > 0x2000 ? size : Math.round(size / 2);
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
  // 打字机字符池：每字一个 Label，逐字显示只切换 visible。
  // 已打出的字符纹理不再整行重建，根除「已打出的文字一闪一闪」（用户反馈）。
  private charLbs: Label.Type[];
  private appliedLine: string;
  private choiceLbs: Label.Type[];
  private lines: DialogLine[];
  private node: StoryNode | undefined;
  private fallbackSpeaker: string;
  private lineIndex: number;
  private charShown: number;
  private glyphCount: number;
  private shownCount: number;
  private choiceMode: boolean;
  private selected: number;
  private choiceDone: boolean;
  private pendingChoice: number;
  private openFlag: boolean;
  public onChoice: (index: number) => void;
  // 连问模式：每次选中选项即时回调（信任/记忆在 game 侧按次结算）
  public onChoiceAsk: (index: number) => void;
  // 待就地重开的剩余选项（空 = 无）
  private nextChoices: DialogChoice[];
  private hintLb: Label.Type | undefined;

  constructor(parent: Node.Type) {
    this.lines = [];
    this.charLbs = [];
    this.appliedLine = "";
    this.glyphCount = 0;
    this.choiceLbs = [];
    this.node = undefined;
    this.fallbackSpeaker = "";
    this.lineIndex = 0;
    this.charShown = 0;
    this.shownCount = -1;
    this.choiceMode = false;
    this.selected = 0;
    this.choiceDone = false;
    this.pendingChoice = -1;
    this.openFlag = false;
    this.onChoice = function (_index: number): void {};
    this.onChoiceAsk = function (_index: number): void {};
    this.nextChoices = [];
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
    // 说话人名牌：封闭小矩形（填纸底 + 墨框），贴在分隔线下方左上角
    this.panel.drawPolygon(
      [Vec2(-478, top - 46), Vec2(-318, top - 46), Vec2(-318, top - 10), Vec2(-478, top - 10)],
      col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), 2, col(Palette.inkDark)
    );
    this.speakerLb = makeLabel(this.root, 24, -462, top - 28, 0, 0.5, Palette.inkDark);
    // 字符池：容量 64 ≈ 两行 × 32 全角字，覆盖现网最长台词（约 34 字）；初始 y 同首行基线（紧贴分隔线下方）
    for (let i = 0; i < 64; i++) {
      const lb = makeLabel(this.root, 22, -462, -h / 2 + 112, 0, 0.5, Palette.inkSoft);
      if (lb !== undefined) {
        lb.text = "";
        lb.visible = false;
        this.charLbs.push(lb);
      }
    }
    // 继续提示（右下角，选项模式时隐藏）
    this.hintLb = makeLabel(this.root, 16, 455, bot + 20, 1, 0.5, Palette.paleInkMid);
    setText(this.hintLb, "空格 / 回车 继续…");
    if (this.hintLb !== undefined) {
      this.hintLb.visible = false;
    }
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
    this.appliedLine = "";
    this.choiceMode = false;
    this.selected = 0;
    this.choiceDone = false;
    this.pendingChoice = -1;
    this.nextChoices = [];
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
    for (let i = 0; i < this.choiceLbs.length; i++) {
      setText(this.choiceLbs[i], "");
    }
  }

  /** 连问模式：应答播完后要就地重开的剩余选项列表（空数组 = 不重开）。 */
  setNextChoices(choices: DialogChoice[]): void {
    this.nextChoices = choices;
  }

  // 就地重开剩余选项：node.choices 换成剩余列表并重新进入选项模式（不重播正文）
  private reopenChoices(): boolean {
    if (this.nextChoices.length === 0) {
      return false;
    }
    const base = this.node;
    if (base === undefined) {
      this.nextChoices = [];
      return false;
    }
    this.node = { ...base, choices: this.nextChoices };
    this.nextChoices = [];
    this.pendingChoice = -1;
    this.choiceDone = false;
    this.choiceMode = true;
    this.selected = 0;
    this.applyChoices();
    this.drawChoices();
    this.updateHint();
    return true;
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
    const node = this.node;
    const replies = node !== undefined && node.choices !== undefined ? node.choices[idx].replies : undefined;
    if (replies !== undefined && replies.length > 0) {
      // 分支应答：插入所选选项的后续台词继续播放；信任/记忆结算推迟到应答播完（onChoice(idx)）。
      this.pendingChoice = idx;
      this.choiceDone = true;
      this.choiceMode = false;
      this.selected = 0;
      this.choicesDraw.clear();
      for (let i = 0; i < this.choiceLbs.length; i++) {
        setText(this.choiceLbs[i], "");
      }
      const insertAt = Math.min(this.lineIndex + 1, this.lines.length);
      const tail = this.lines.slice(insertAt);
      this.lines = this.lines.slice(0, insertAt).concat(replies, tail);
      this.lineIndex = insertAt;
      this.charShown = 0;
      this.shownCount = -1;
      this.applyLine();
      this.onChoiceAsk(idx);
      return;
    }
    this.onChoiceAsk(idx);
    if (this.reopenChoices()) {
      return;
    }
    const cb = this.onChoice;
    this.close();
    cb(idx);
  }

  advance(): void {
    if (!this.openFlag || this.choiceMode || this.lineIndex >= this.lines.length) {
      return;
    }
    const full = this.glyphCount;
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
    if (this.hasChoices() && this.choiceCount() > 0 && !this.choiceDone) {
      this.choiceMode = true;
      this.selected = 0;
      this.applyChoices();
      this.drawChoices();
      this.updateHint();
      return;
    }
    if (this.reopenChoices()) {
      return;
    }
    // 协议：无选项节点自然走完 → onChoice(-1)；选项分支应答播完 → onChoice(最后一次所选索引)。
    // 若只 close 不回调，game.mode 会永远停在 "dialog"，所有按键失效（卡死）。
    const done = this.pendingChoice;
    this.pendingChoice = -1;
    const cb = this.onChoice;
    this.close();
    cb(done);
  }

  update(dt: number): void {
    if (!this.openFlag || this.choiceMode || this.lineIndex >= this.lines.length) {
      return;
    }
    if (this.charShown >= this.glyphCount) {
      return;
    }
    this.charShown = Math.min(this.charShown + CHARS_PER_SEC * dt, this.glyphCount);
    this.applyLine();
  }

  private applyLine(): void {
    if (this.lineIndex >= this.lines.length) {
      this.updateHint();
      return;
    }
    const line = this.lines[this.lineIndex];
    const speaker = line.speaker !== "" ? line.speaker : this.fallbackSpeaker;
    setText(this.speakerLb, speaker);
    const n = Math.floor(this.charShown);
    if (line.text !== this.appliedLine) {
      this.appliedLine = line.text;
      this.layoutLine(line.text);
    }
    if (n !== this.shownCount) {
      this.shownCount = n;
      for (let i = 0; i < this.charLbs.length; i++) {
        this.charLbs[i].visible = i < n;
      }
    }
    this.updateHint();
  }

  // 整行排版：按 UTF-8 码点逐字拆分（Lua 字符串按字节存，charAt 拆中文会得到非法单字节碎片→渲染空白），
  // 每字一个 Label 定位，步进用 Label 实测字宽（任何字体度量下不重叠/不漂移）；最多两行，超出截断
  private layoutLine(text: string): void {
    const maxW = 924;
    const rowH = 32;
    const baseY = -View.size.height / 2 + 112; // 首行紧贴分隔线下方（顶在对话框上部），第二行在其下一行
    let x = -462;
    let row = 0;
    let used = 0;
    let laid = 0;
    let i = 0;
    while (i < text.length && laid < this.charLbs.length) {
      const b = text.charCodeAt(i);
      const seq = b >= 0xF0 ? 4 : b >= 0xE0 ? 3 : b >= 0xC0 ? 2 : 1;
      const ch = text.substring(i, i + seq);
      const lb = this.charLbs[laid];
      lb.text = ch;
      const w = lb.width > 0 ? lb.width : charW(ch, 22);
      if (used + w > maxW && row === 0) {
        row = 1;
        used = 0;
        x = -462;
      }
      if (used + w > maxW) {
        break;
      }
      lb.visible = false;
      lb.position = Vec2(x, baseY - row * rowH);
      used = used + w;
      x = x + w;
      laid = laid + 1;
      i = i + seq;
    }
    for (let j = laid; j < this.charLbs.length; j++) {
      this.charLbs[j].text = "";
      this.charLbs[j].visible = false;
    }
    this.glyphCount = laid;
  }

  // 继续提示：正文打完且未进入选项模式时显示（同 dialogue-lite 的 hint 行为）
  private updateHint(): void {
    if (this.hintLb === undefined) {
      return;
    }
    const full = this.lineIndex < this.lines.length ? this.glyphCount : 0;
    this.hintLb.visible = this.openFlag && !this.choiceMode && full > 0 && this.charShown >= full;
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
    if (!this.choiceMode || this.node === undefined || this.node.choices === undefined) {
      return;
    }
    const h = View.size.height;
    const n = this.node.choices.length;
    const boxH = n * 42 + 24;
    const boxY = -h / 2 + 260 - (n - 1) * 21;
    // 选项面板：封闭矩形（纸底 + 墨框 + 金线内描）
    this.choicesDraw.drawPolygon(
      [Vec2(-290, boxY - boxH / 2), Vec2(290, boxY - boxH / 2), Vec2(290, boxY + boxH / 2), Vec2(-290, boxY + boxH / 2)],
      col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), 2, col(Palette.inkDark)
    );
    this.choicesDraw.drawPolygon(
      [Vec2(-282, boxY - boxH / 2 + 8), Vec2(282, boxY - boxH / 2 + 8), Vec2(282, boxY + boxH / 2 - 8), Vec2(-282, boxY + boxH / 2 - 8)],
      col(ink(0, 0, 0, 0)), 1, col(Palette.goldSoft)
    );
    for (let i = 0; i < this.choiceLbs.length; i++) {
      const sel = i === this.selected;
      const lb = this.choiceLbs[i];
      if (i >= n) {
        setText(lb, "");
        continue;
      }
      const y = -h / 2 + 260 - i * 42;
      // 选项文字宽度自适应：常规左对齐（菱形箭头右侧留 9px）；超宽则按钮内居中，保证不出框。
      const tw = lb.width;
      const leftAlign = tw <= 470;
      lb.position = Vec2(leftAlign ? -232 : Math.max(-250, -tw / 2), y);
      lb.anchor = Vec2(leftAlign ? 0 : 0.5, 0.5);
      setLabelColor(lb, sel ? Palette.inkDark : Palette.paleInk);
      // 每个选项 = 封闭按钮矩形；选中项月华青描边 + 高亮底 + 菱形箭头
      this.choicesDraw.drawPolygon(
        [Vec2(-262, y - 16), Vec2(262, y - 16), Vec2(262, y + 16), Vec2(-262, y + 16)],
        sel ? col(ink(Palette.moonCyan.r, Palette.moonCyan.g, Palette.moonCyan.b, 46)) : col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 255)),
        sel ? 2 : 1,
        sel ? col(Palette.moonCyan) : col(Palette.inkFaint)
      );
      if (sel) {
        this.choicesDraw.drawPolygon(
          [Vec2(-250, y + 9), Vec2(-241, y), Vec2(-250, y - 9), Vec2(-259, y)],
          col(Palette.moonCyan)
        );
      }
    }
  }
}
