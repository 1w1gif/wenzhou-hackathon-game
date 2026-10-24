// ui/name_entry.ts — 开局游戏名输入面板：暗幕 + 水墨面板 + IME 文本输入
// 输入路径：node.attachIME() 后 TextInput 进字；退格/回车/Esc 由 game.onKey → handleKey 转发
import { Color, DrawNode, KeyName, Label, Node, Size, Vec2, View } from "Dora";
import { makeTechPanel } from "ui/tech_ui";
import { DEFAULT_NAME, sanitizeName } from "core/archive";

const FONT = "assets/font/DialogFont.ttf";

// 面板文字统一项目自带字体，加载失败回退内置像素字体
function makeText(size: number): Label.Type | undefined {
  let lb = Label(FONT, size);
  if (lb === undefined) {
    lb = Label("sarasa-mono-sc-regular", size);
  }
  return lb;
}
const NAME_MAX = 12;

/** 删去字符串最后一个 UTF-8 字符（Lua 字符串按字节处理） */
function deleteLastChar(s: string): string {
  let i = s.length - 1;
  while (i > 0 && (s.charCodeAt(i) & 0xc0) === 0x80) {
    i = i - 1;
  }
  return i <= 0 ? "" : s.substring(0, i);
}

/** 统计 UTF-8 字符数 */
function charCount(s: string): number {
  let n = 0;
  for (let i = 0; i < s.length; i++) {
    if ((s.charCodeAt(i) & 0xc0) !== 0x80) {
      n = n + 1;
    }
  }
  return n;
}

export class NameEntry {
  private root: Node.Type;
  private inputNode: Node.Type;
  private bufLb: Label.Type | undefined;
  private bufDraw: DrawNode.Type;
  private openFlag: boolean;
  private buf: string;
  private caretT: number;
  private caretVisible: boolean;
  private onConfirm: ((name: string) => void) | undefined;
  private onCancel: (() => void) | undefined;

  constructor(parent: Node.Type) {
    this.openFlag = false;
    this.buf = "";
    this.caretT = 0;
    this.caretVisible = true;
    this.onConfirm = undefined;
    this.onCancel = undefined;
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
    const w = View.size.width;
    const h = View.size.height;
    const hw = w / 2;
    const hh = h / 2;
    const bg = DrawNode();
    bg.addTo(this.root);
    bg.drawPolygon([Vec2(-hw, -hh), Vec2(hw, -hh), Vec2(hw, hh), Vec2(-hw, hh)], Color(0, 0, 0, 200));
    // 中央面板（科技风框体，替代描金面板）
    const pw = 560;
    const ph = 300;
    makeTechPanel(this.root, pw, ph);
    const title = makeText(26);
    if (title !== undefined) {
      title.text = "刻下旅人之名";
      title.anchor = Vec2(0.5, 0.5);
      title.position = Vec2(0, 84);
      title.color = Color(255, 255, 255, 255);
      title.addTo(this.root);
    }
    this.bufDraw = DrawNode();
    this.bufDraw.addTo(this.root);
    this.bufLb = makeText(34);
    if (this.bufLb !== undefined) {
      this.bufLb.anchor = Vec2(0.5, 0.5);
      this.bufLb.position = Vec2(0, 12);
      this.bufLb.color = Color(255, 255, 255, 255);
      this.bufLb.addTo(this.root);
    }
    // 仅保留存档说明一行；操作键位提示行（回车确认出发等）按需求删除
    const hint2 = makeText(15);
    if (hint2 !== undefined) {
      hint2.text = "名字将随你的时空树一起留入仓库（留空则名为「" + DEFAULT_NAME + "」）";
      hint2.anchor = Vec2(0.5, 0.5);
      hint2.position = Vec2(0, -66);
      hint2.color = Color(255, 255, 255, 255);
      hint2.addTo(this.root);
    }
    // IME 输入挂点：只接 TextInput，键由 game.onKey 统一转发
    this.inputNode = Node();
    this.inputNode.addTo(this.root);
    this.inputNode.onTextInput((text: string) => {
      if (!this.openFlag || text === undefined) {
        return;
      }
      if (charCount(this.buf + text) <= NAME_MAX) {
        this.buf = this.buf + text;
        this.renderBuf();
      }
    });
    // 光标闪烁：竖线用 DrawNode 画，不用字形字符（DialogFont 缺块元素字形会渲染成方块）
    this.inputNode.schedule((dt: number) => {
      if (!this.openFlag) {
        return false;
      }
      this.caretT = this.caretT + dt;
      if (this.caretT >= 0.5) {
        this.caretT = 0;
        this.caretVisible = !this.caretVisible;
        this.drawCaret();
      }
      return false;
    });
  }

  open(prefill: string, onConfirm: (name: string) => void, onCancel: () => void): void {
    this.openFlag = true;
    this.buf = sanitizeName(prefill, NAME_MAX);
    this.onConfirm = onConfirm;
    this.onCancel = onCancel;
    this.root.visible = true;
    this.inputNode.attachIME();
    this.renderBuf();
  }

  close(): void {
    this.openFlag = false;
    this.root.visible = false;
    this.inputNode.detachIME();
    this.onConfirm = undefined;
    this.onCancel = undefined;
  }

  isOpen(): boolean {
    return this.openFlag;
  }

  /** 由 game.onKey 转发：回车确认 / Esc 取消 / 退格删字 */
  handleKey(key: KeyName): void {
    if (!this.openFlag) {
      return;
    }
    if (key === KeyName.Return) {
      const name = sanitizeName(this.buf, NAME_MAX);
      const finalName = name === "" ? DEFAULT_NAME : name;
      const cb = this.onConfirm;
      this.close();
      if (cb !== undefined) {
        cb(finalName);
      }
    } else if (key === KeyName.Escape) {
      const cb = this.onCancel;
      this.close();
      if (cb !== undefined) {
        cb();
      }
    } else if (key === KeyName.BackSpace) {
      this.buf = deleteLastChar(this.buf);
      this.renderBuf();
    }
  }

  private renderBuf(): void {
    if (this.bufLb !== undefined) {
      this.bufLb.text = this.buf;
    }
    this.drawCaret();
  }

  // 光标：闪烁竖线画在 bufDraw（文本右缘 +6px），替代原来的字符光标
  private drawCaret(): void {
    this.bufDraw.clear();
    if (!this.openFlag || !this.caretVisible || this.bufLb === undefined) {
      return;
    }
    const x = this.bufLb.width * 0.5 + 6;
    this.bufDraw.drawSegment(Vec2(x, -6), Vec2(x, 30), 1.5, Color(255, 255, 255, 220));
  }
}
