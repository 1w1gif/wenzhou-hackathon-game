// game/causality_fx.ts — 整改二/三：因果事件全屏转场（种树/砍树/救人/打水/回溯）
// 程序绘制：全屏色纱 + 月环扩散 + 纯白说明文字；挂 uiRoot，由 Game.tick 常驻 update。
import { Color, DrawNode, Label, Node, Vec2, View } from "Dora";

export type CausalityKind = "rewind" | "grow" | "cut" | "rescue" | "fill";

const DUR = 1.1;
const FONT = "sarasa-mono-sc-regular";

// 各事件主题色（柔和月色系）
const TINT: Record<CausalityKind, { r: number; g: number; b: number }> = {
  rewind: { r: 214, g: 226, b: 235 },
  grow: { r: 168, g: 214, b: 156 },
  cut: { r: 196, g: 116, b: 104 },
  rescue: { r: 232, g: 202, b: 138 },
  fill: { r: 150, g: 190, b: 216 },
};

export class CausalityFx {
  private root: Node.Type;
  private draw: DrawNode.Type;
  private caption: Label.Type | undefined;
  private t: number; // <0 表示空闲
  private kind: CausalityKind;

  constructor(parent: Node.Type) {
    this.t = -1;
    this.kind = "rewind";
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
    this.draw = DrawNode();
    this.draw.addTo(this.root);
    const lb = Label(FONT, 30);
    if (lb !== undefined) {
      lb.anchor = Vec2(0.5, 0.5);
      lb.position = Vec2(0, -View.size.height / 2 + 130);
      lb.color = Color(255, 255, 255, 0);
      lb.addTo(this.root);
      this.caption = lb;
    }
  }

  play(kind: CausalityKind, caption: string): void {
    this.kind = kind;
    this.t = 0;
    this.root.visible = true;
    if (this.caption !== undefined) {
      this.caption.text = caption;
    }
  }

  clear(): void {
    this.t = -1;
    this.root.visible = false;
    this.draw.clear();
  }

  isBusy(): boolean {
    return this.t >= 0;
  }

  update(dt: number): void {
    if (this.t < 0) {
      return;
    }
    this.t += dt;
    if (this.t >= DUR) {
      this.clear();
      return;
    }
    const p = this.t / DUR;
    const env = Math.sin(p * Math.PI); // 淡入淡出包络
    const w = View.size.width;
    const h = View.size.height;
    const c = TINT[this.kind];
    this.draw.clear();
    // 全屏色纱
    this.draw.drawPolygon(
      [Vec2(-w / 2, -h / 2), Vec2(w / 2, -h / 2), Vec2(w / 2, h / 2), Vec2(-w / 2, h / 2)],
      Color(c.r, c.g, c.b, Math.floor(120 * env))
    );
    // 月环扩散：三圈自上方月心逐层外扩
    const cy = h * 0.12;
    for (let i = 0; i < 3; i++) {
      const pr = (p + i * 0.18) % 1;
      const r = 60 + pr * Math.max(w, h) * 0.5;
      const pts: Vec2.Type[] = [];
      for (let k = 0; k <= 26; k++) {
        const a = (k / 26) * Math.PI * 2;
        pts.push(Vec2(Math.cos(a) * r, Math.sin(a) * r + cy));
      }
      this.draw.drawPolygon(pts, Color(c.r, c.g, c.b, Math.floor(60 * env)), 2, Color(255, 255, 255, Math.floor(210 * env)));
    }
    if (this.caption !== undefined) {
      this.caption.color = Color(255, 255, 255, Math.floor(255 * env));
    }
  }
}
