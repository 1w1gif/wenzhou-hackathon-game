// ui/touch.ts — 触屏虚拟手柄：左侧 ◀▶ 方向盘 + 右侧 跳/攻/气/闪 + 顶部 E/Q/N/R
// 视觉与 HUD 同风格：水墨圆环 + 月光青高亮。仅粗指针设备（手机/平板）显示。
// 实现：整层一个触摸面，TapBegan/Moved/Ended 命中测试各按键区域，
// 不依赖多指（Web 导出下 SDL 单指最稳），方向键支持左右滑动手感。
import { Color, DrawNode, Label, Node, Vec2, View } from "Dora";
import { Palette, ink } from "core/palette";

const FONT = "sarasa-mono-sc-regular";
const HOLD_EPS = 12; // 判定移动死区（逻辑单位）

// 布局：以设计分辨率右下/左下为锚（竖屏横屏都贴边）
const PAD_R = 46;          // 按键半径
const PAD_GAP = 8;         // 键间距
const SIDE_MARGIN = 62;    // 距边缘
const BOTTOM_MARGIN = 64;

export interface PadState {
  left: boolean;
  right: boolean;
  up: boolean;
  down: boolean;
  // 一次性按键（按下瞬间置位，游戏侧消费后清除）
  jumpQueued: boolean;
  attackQueued: boolean;
  qiQueued: boolean;
  dashQueued: boolean;
  // 持续按住（攻击/剑气长按连发用不到，但保留状态供 UI 高亮）
  jumpHeld: boolean;
  attackHeld: boolean;
}

type ActionKey = "jump" | "attack" | "qi" | "dash" | "interact" | "rewind" | "note" | "revive";

export class TouchPad {
  private root: Node.Type;
  private padDraw: DrawNode.Type;
  private state: PadState;
  private keyLabels = new Map<ActionKey, Label.Type>();
  private ringDraws = new Map<"left" | "right" | ActionKey, DrawNode.Type>();
  private dirLabels = new Map<"left" | "right", Label.Type>();

  // 按键世界坐标（每帧布局，响应转屏）
  private layout = new Map<ActionKey, { x: number; y: number }>();
  private dirLayout = new Map<"left" | "right", { x: number; y: number }>();
  private topLayout = new Map<ActionKey, { x: number; y: number }>();

  // 触摸跟踪：当前按住的方向 + 起点坐标（用于左右滑动切换）
  private activePointer: { id: number; startX: number; zone: "dir" | ActionKey } | undefined;

  // 事件回调（game.ts 注入）
  onAction: (key: ActionKey) => void = () => {};
  onInteract: () => void = () => {};
  onRewind: () => void = () => {};
  onNote: () => void = () => {};
  onRevive: () => void = () => {};

  constructor(parent: Node.Type) {
    this.state = {
      left: false, right: false, up: false, down: false,
      jumpQueued: false, attackQueued: false, qiQueued: false, dashQueued: false,
      jumpHeld: false, attackHeld: false,
    };
    this.root = Node();
    this.root.addTo(parent);
    this.root.order = 900;

    this.padDraw = DrawNode();
    this.padDraw.addTo(this.root);

    this.buildButtons();
    this.relayout();

    // 触摸事件：挂在整层（全屏接收），自己命中测试
    this.root.touchEnabled = true;
    this.root.slot("TapBegan", (touch) => {
      const p = this.toLocal(touch.location.x, touch.location.y);
      this.handleDown(touch.id, p.x, p.y);
    });
    this.root.slot("TapMoved", (touch) => {
      if (this.activePointer === undefined || touch.id !== this.activePointer.id) return;
      const p = this.toLocal(touch.location.x, touch.location.y);
      this.handleMove(p.x, p.y);
    });
    this.root.slot("TapEnded", (touch) => {
      if (this.activePointer === undefined || touch.id !== this.activePointer.id) return;
      this.handleUp();
    });
  }

  get pad(): PadState { return this.state; }

  /** 供外部按模式隐藏/显示（game.ts 每帧比对） */
  get rootNode(): Node.Type { return this.root; }

  /** 消费一次性按键队列 */
  takeJump(): boolean { const v = this.state.jumpQueued; this.state.jumpQueued = false; return v; }
  takeAttack(): boolean { const v = this.state.attackQueued; this.state.attackQueued = false; return v; }
  takeQi(): boolean { const v = this.state.qiQueued; this.state.qiQueued = false; return v; }
  takeDash(): boolean { const v = this.state.dashQueued; this.state.dashQueued = false; return v; }

  /** 对话等场景隐藏/显示手柄 */
  setVisible(v: boolean): void {
    this.root.visible = v;
    if (!v) this.clearAll();
  }

  private clearAll(): void {
    this.state.left = false; this.state.right = false;
    this.state.up = false; this.state.down = false;
    this.state.jumpHeld = false; this.state.attackHeld = false;
    this.activePointer = undefined;
    this.refreshVisual();
  }

  private toLocal(viewX: number, viewY: number): Vec2TypeLocal {
    // touch.location 是相对 root 的坐标；root 铺满屏幕时即视口坐标（原点左下）
    return { x: viewX, y: viewY };
  }

  // ---------- 布局与绘制 ----------

  private buildButtons(): void {
    // 右侧战斗四键：菱形排布 跳(上) 攻(左) 气(右) 闪(下)
    const fight: Array<[ActionKey, string]> = [
      ["jump", "跳"], ["attack", "攻"], ["qi", "气"], ["dash", "闪"],
    ];
    for (const [key, text] of fight) {
      this.addLabel(key, text);
    }
    // 顶部功能键：E 交互 / Q 回溯 / N 手札 / R 复活
    const tops: Array<[ActionKey, string]> = [
      ["interact", "E"], ["rewind", "Q"], ["note", "札"], ["revive", "R"],
    ];
    for (const [key, text] of tops) {
      this.addLabel(key, text);
    }
    // 方向箭头
    for (const dir of ["left", "right"] as const) {
      const lb = Label(FONT, 30);
      if (lb !== undefined) {
        lb.text = dir === "left" ? "◀" : "▶";
        lb.color = Color(232, 223, 199, 210);
        lb.addTo(this.root);
        this.dirLabels.set(dir, lb);
      }
    }
    this.drawAllRings();
  }

  private addLabel(key: ActionKey, text: string): void {
    const lb = Label(FONT, key === "jump" ? 30 : 26);
    if (lb === undefined) return;
    lb.text = text;
    lb.color = Color(232, 223, 199, 215);
    lb.addTo(this.root);
    this.keyLabels.set(key, lb);
  }

  private buttonCenter(sizeW: number, sizeH: number): { rightX: number; bottomY: number; topY: number } {
    return {
      rightX: sizeW - SIDE_MARGIN,
      bottomY: BOTTOM_MARGIN,
      topY: sizeH - 70,
    };
  }

  private relayout(): void {
    const w = View.size.width;
    const h = View.size.height;
    const { rightX, bottomY, topY } = this.buttonCenter(w, h);

    // 方向键：左下
    this.dirLayout.set("left", { x: SIDE_MARGIN, y: bottomY });
    this.dirLayout.set("right", { x: SIDE_MARGIN + PAD_R * 2 + PAD_GAP, y: bottomY });

    // 战斗键：右下菱形（跳在上，攻/气在两侧，闪在下）
    this.layout.set("jump", { x: rightX, y: bottomY + PAD_R * 2 + PAD_GAP });
    this.layout.set("attack", { x: rightX - PAD_R * 2 - PAD_GAP, y: bottomY });
    this.layout.set("qi", { x: rightX + PAD_R * 2 + PAD_GAP, y: bottomY });
    this.layout.set("dash", { x: rightX, y: bottomY });

    // 顶部功能键：右上横排 E Q 札 R（复活键默认隐藏，死亡时显示）
    this.topLayout.set("interact", { x: w - SIDE_MARGIN, y: topY });
    this.topLayout.set("rewind", { x: w - SIDE_MARGIN - PAD_R * 2 - PAD_GAP, y: topY });
    this.topLayout.set("note", { x: w - SIDE_MARGIN - (PAD_R * 2 + PAD_GAP) * 2, y: topY });
    this.topLayout.set("revive", { x: w / 2, y: h * 0.35 });

    this.placeLabels();
    this.drawAllRings();
  }

  private placeLabels(): void {
    const put = (lb: Label.Type | undefined, pos: { x: number; y: number } | undefined, r: number) => {
      if (lb === undefined || pos === undefined) return;
      lb.position = Vec2(pos.x, pos.y + r * 0.36);
    };
    for (const [key, lb] of this.keyLabels) {
      put(lb, this.layout.get(key) ?? this.topLayout.get(key), PAD_R);
    }
    for (const [dir, lb] of this.dirLabels) {
      put(lb, this.dirLayout.get(dir), PAD_R);
    }
  }

  private drawRing(d: DrawNode.Type | undefined, pos: { x: number; y: number } | undefined, active: boolean, radius = PAD_R): void {
    if (d === undefined || pos === undefined) return;
    d.clear();
    const fill = active ? ink(168, 197, 188, 80) : ink(30, 37, 36, 96);
    const ring = active ? Palette.moonCyan : ink(232, 223, 199, 130);
    d.drawDot(Vec2(pos.x, pos.y), radius, fill);
    // 圆环：分段 drawSegment 近似描边
    const seg = 36;
    for (let i = 0; i < seg; i++) {
      const a0 = (i / seg) * Math.PI * 2;
      const a1 = ((i + 1) / seg) * Math.PI * 2;
      const r0 = radius - 2;
      d.drawSegment(
        Vec2(pos.x + Math.cos(a0) * r0, pos.y + Math.sin(a0) * r0),
        Vec2(pos.x + Math.cos(a1) * r0, pos.y + Math.sin(a1) * r0),
        2.5,
        ring,
      );
    }
  }

  private drawAllRings(): void {
    // 环在 refreshVisual 里按状态懒创建/重画，这里无需预处理
  }

  private refreshVisual(): void {
    const st = this.state;
    // 方向
    this.drawRingDir("left", st.left);
    this.drawRingDir("right", st.right);
    // 战斗
    this.drawRingAct("jump", st.jumpHeld);
    this.drawRingAct("attack", st.attackHeld);
    this.drawRingAct("qi", st.qiQueued);
    this.drawRingAct("dash", st.dashQueued);
  }

  private drawRingDir(dir: "left" | "right", active: boolean): void {
    // 方向环复用战斗环绘制（画进 root 的独立 DrawNode）
    let d = this.ringDraws.get(dir) ?? undefined;
    if (d === undefined) {
      d = DrawNode();
      d.addTo(this.root);
      d.order = -1;
      this.ringDraws.set(dir, d);
    }
    this.drawRing(d, this.dirLayout.get(dir), active);
  }

  private drawRingAct(key: ActionKey, active: boolean): void {
    let d = this.ringDraws.get(key);
    if (d === undefined) {
      d = DrawNode();
      d.addTo(this.root);
      d.order = -1;
      this.ringDraws.set(key, d);
    }
    const radius = key === "revive" ? PAD_R + 14 : PAD_R;
    this.drawRing(d, this.layout.get(key) ?? this.topLayout.get(key), active, radius);
  }

  // ---------- 触摸命中 ----------

  private hitTest(x: number, y: number): { zone: "dir" | "dirNone" | ActionKey; dir?: "left" | "right" } {
    const hitR = PAD_R + 18;
    const near = (pos: { x: number; y: number } | undefined) =>
      pos !== undefined && (x - pos.x) * (x - pos.x) + (y - pos.y) * (y - pos.y) <= hitR * hitR;

    for (const dir of ["left", "right"] as const) {
      if (near(this.dirLayout.get(dir))) return { zone: "dir", dir };
    }
    for (const key of ["jump", "attack", "qi", "dash", "interact", "rewind", "note", "revive"] as const) {
      if (near(this.layout.get(key)) || near(this.topLayout.get(key))) return { zone: key };
    }
    return { zone: "dirNone" };
  }

  private handleDown(id: number, x: number, y: number): void {
    const hit = this.hitTest(x, y);
    if (hit.zone === "dirNone") {
      // 空白处：屏幕左半点按 = 交互（对话推进），右半忽略
      if (x < View.size.width / 2) {
        this.onInteract();
      }
      return;
    }
    if (hit.zone === "dir") {
      this.activePointer = { id, startX: x, zone: "dir" };
      this.applyDir(x);
      return;
    }
    this.activePointer = { id, startX: x, zone: hit.zone };
    this.fireAction(hit.zone);
  }

  private handleMove(x: number, y: number): void {
    if (this.activePointer === undefined) return;
    if (this.activePointer.zone === "dir") {
      this.applyDir(x);
    }
  }

  private handleUp(): void {
    if (this.activePointer === undefined) return;
    const zone = this.activePointer.zone;
    this.activePointer = undefined;
    if (zone === "dir") {
      this.state.left = false;
      this.state.right = false;
      this.state.up = false;
      this.state.down = false;
    } else if (zone === "jump") this.state.jumpHeld = false;
    else if (zone === "attack") this.state.attackHeld = false;
    this.refreshVisual();
  }

  private applyDir(x: number): void {
    const leftPos = this.dirLayout.get("left");
    const rightPos = this.dirLayout.get("right");
    if (leftPos === undefined || rightPos === undefined) return;
    const mid = (leftPos.x + rightPos.x) / 2;
    this.state.left = x < mid - HOLD_EPS;
    this.state.right = x > mid + HOLD_EPS;
    this.state.up = false;
    this.state.down = false;
    this.refreshVisual();
  }

  private fireAction(key: ActionKey): void {
    switch (key) {
      case "jump":
        this.state.jumpQueued = true; this.state.jumpHeld = true; break;
      case "attack":
        this.state.attackQueued = true; this.state.attackHeld = true; break;
      case "qi":
        this.state.qiQueued = true; break;
      case "dash":
        this.state.dashQueued = true; break;
      case "interact":
        this.onInteract(); break;
      case "rewind":
        this.onRewind(); break;
      case "note":
        this.onNote(); break;
      case "revive":
        this.onRevive(); break;
    }
    this.refreshVisual();
  }
}

interface Vec2TypeLocal { x: number; y: number }
