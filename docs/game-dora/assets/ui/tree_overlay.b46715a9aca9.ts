// ui/tree_overlay.ts — 时空树浮层：暗幕 + 水墨枝干 + 月相节点 + via 标注 + 统计条
// 依赖单向：本文件不 import game/timeline_tree（用本地结构接口，避免回环 import）；
// game/timeline_tree.ts 顶部 import 本文件，attachTo 时创建浮层（隐藏待命）。
import { Color, DrawNode, Label, Node, Size, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { makeTechPanel } from "ui/tech_ui";

const FONT = "assets/font/DialogFont.ttf";

// 面板文字统一项目自带字体，加载失败回退内置像素字体
function makeText(size: number): Label.Type | undefined {
  let lb = Label(FONT, size);
  if (lb === undefined) {
    lb = Label("sarasa-mono-sc-regular", size);
  }
  return lb;
}
const PHASE_NAMES: string[] = ["朔", "眉月", "上弦", "盈凸", "望", "亏凸", "下弦", "残月"];
// 遮挡小圆用的暗色（近似面板底，月相缺口用）
const PANEL_DARK: InkColor = { r: 14, g: 17, b: 22, a: 255 };

/** 浮层节点（TreeSystem.TreeNode 结构兼容） */
export interface OverlayNode {
  id: string;
  parent: string;
  via: string;
  phase: number;
  depth: number;
  abandoned: boolean;
}

/** 浮层所需最小数据源（TreeSystem 结构兼容，无反向依赖） */
export interface TreeOverlaySource {
  nodes: OverlayNode[];
  currentId: string;
  rewindCount: number;
  onJumpTo?: (id: string) => void;
  jumpTo(id: string): void;
  getStats(): string;
  currentChain(): string[];
}

function col(c: InkColor): Color.Type {
  return Color(c.r, c.g, c.b, c.a);
}

interface LayoutPoint {
  id: string;
  x: number;
  y: number;
}

/** 圆弧折线点集（角度制，y 向上） */
function circlePts(cx: number, cy: number, r: number, a0: number, a1: number, steps: number): Vec2.Type[] {
  const pts: Vec2.Type[] = [];
  for (let i = 0; i <= steps; i++) {
    const a = ((a0 + ((a1 - a0) * i) / steps) * Math.PI) / 180;
    pts.push(Vec2(cx + Math.cos(a) * r, cy + Math.sin(a) * r));
  }
  return pts;
}

function phaseName(phase: number): string {
  return phase >= 0 && phase < PHASE_NAMES.length ? PHASE_NAMES[phase] : "";
}

export class TreeOverlay {
  private root: Node.Type;
  private bgDraw: DrawNode.Type;
  private treeDraw: DrawNode.Type;
  private hit: Node.Type;
  private viaLbs: Label.Type[];
  private noteLb: Label.Type | undefined;
  private statsLb: Label.Type | undefined;
  private hintLb: Label.Type | undefined;
  private layout: LayoutPoint[];
  private source: TreeOverlaySource | undefined;
  private openFlag: boolean;
  private w: number;
  private h: number;

  constructor(parent: Node.Type) {
    this.layout = [];
    this.viaLbs = [];
    this.source = undefined;
    this.openFlag = false;
    this.w = View.size.width;
    this.h = View.size.height;
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
    const hw = this.w / 2;
    const hh = this.h / 2;
    // 暗幕 + 科技风框体（静态，建时画一次）
    this.bgDraw = DrawNode();
    this.bgDraw.addTo(this.root);
    this.bgDraw.drawPolygon([Vec2(-hw, -hh), Vec2(hw, -hh), Vec2(hw, hh), Vec2(-hw, hh)], Color(0, 0, 0, 205));
    makeTechPanel(this.root, this.w - 36, this.h - 36);
    // 枝干与月相层（每次打开重画）
    this.treeDraw = DrawNode();
    this.treeDraw.addTo(this.root);
    // 顶部说明
    const note = makeText(14);
    if (note !== undefined) {
      note.text = "按第 N 夜分层 · 描金为当前世界线 · 点击节点跳回";
      note.anchor = Vec2(0.5, 0.5);
      note.position = Vec2(0, hh - 78);
      note.color = col(Palette.paleInk);
      note.addTo(this.root);
      this.noteLb = note;
    }
    // 底部统计条与操作提示
    const stats = makeText(17);
    if (stats !== undefined) {
      stats.anchor = Vec2(0.5, 0.5);
      stats.position = Vec2(0, -hh + 82);
      stats.color = col(Palette.inkSoft);
      stats.addTo(this.root);
      this.statsLb = stats;
    }
    const hint = makeText(14);
    if (hint !== undefined) {
      hint.text = "T 关闭 · 点击节点＝跳回该世界线（灰枝已放弃，永远保留可再跳回）";
      hint.anchor = Vec2(0.5, 0.5);
      hint.position = Vec2(0, -hh + 46);
      hint.color = col(Palette.paleInk);
      hint.addTo(this.root);
      this.hintLb = hint;
    }
    // 触摸命中层：尺寸=全屏，位置在屏幕中心；命中换算见 onTapBegan
    this.hit = Node();
    this.hit.size = Size(this.w, this.h);
    this.hit.position = Vec2(0, 0);
    this.hit.touchEnabled = false;
    this.hit.addTo(this.root);
    this.hit.onTapBegan((touch) => {
      if (!this.openFlag || this.source === undefined) {
        return;
      }
      const local = touch.location;
      const px = local.x - this.w * 0.5;
      const py = local.y - this.h * 0.5;
      for (let i = this.layout.length - 1; i >= 0; i--) {
        const p = this.layout[i];
        const dx = px - p.x;
        const dy = py - p.y;
        if (dx * dx + dy * dy <= 784) {
          this.jumpToNode(this.source, p.id);
          return;
        }
      }
    });
  }
  open(system: TreeOverlaySource): void {
    this.source = system;
    this.openFlag = true;
    this.root.visible = true;
    this.hit.touchEnabled = true;
    this.render(system);
  }

  close(): void {
    this.openFlag = false;
    this.root.visible = false;
    this.hit.touchEnabled = false;
  }

  toggle(system: TreeOverlaySource): void {
    if (this.openFlag) {
      this.close();
    } else {
      this.open(system);
    }
  }

  isOpen(): boolean {
    return this.openFlag;
  }

  private render(system: TreeOverlaySource): void {
    this.computeLayout(system);
    this.treeDraw.clear();
    this.drawBranches(system);
    this.drawMoons(system);
    this.updateLabels(system);
    if (this.statsLb !== undefined) {
      this.statsLb.text = system.getStats() + "　·　本树只增不减";
    }
  }

  /** 按深度分行、同行按索引横向均布：树底根、向上生长 */
  private computeLayout(system: TreeOverlaySource): void {
    const pts: LayoutPoint[] = [];
    let maxDepth = 0;
    for (let i = 0; i < system.nodes.length; i++) {
      if (system.nodes[i].depth > maxDepth) {
        maxDepth = system.nodes[i].depth;
      }
    }
    const yBot = -this.h / 2 + 120;
    const yTop = this.h / 2 - 150;
    const rows = maxDepth + 1;
    const rowH = rows <= 1 ? 0 : Math.min(120, (yTop - yBot) / (rows - 1));
    const groups: OverlayNode[][] = [];
    for (let d = 0; d <= maxDepth; d++) {
      groups.push([]);
    }
    for (let i = 0; i < system.nodes.length; i++) {
      const n = system.nodes[i];
      const d = Math.max(0, Math.min(maxDepth, n.depth));
      groups[d].push(n);
    }
    for (let d = 0; d < groups.length; d++) {
      const g = groups[d];
      const n = g.length;
      const spacing = Math.min(150, (this.w - 220) / Math.max(1, n));
      for (let i = 0; i < n; i++) {
        pts.push({ id: g[i].id, x: (i - (n - 1) / 2) * spacing, y: yBot + d * rowH });
      }
    }
    this.layout = pts;
  }

  private findPos(id: string): LayoutPoint | undefined {
    for (let i = 0; i < this.layout.length; i++) {
      if (this.layout[i].id === id) {
        return this.layout[i];
      }
    }
    return undefined;
  }

  /** 父到子画枝：当前链描金、灰枝淡墨、正常枝墨色（平铺列表禁止） */
  private drawBranches(system: TreeOverlaySource): void {
    const chain = system.currentChain();
    for (let i = 0; i < system.nodes.length; i++) {
      const n = system.nodes[i];
      if (n.parent === "") {
        continue;
      }
      const from = this.findPos(n.parent);
      const to = this.findPos(n.id);
      if (from === undefined || to === undefined) {
        continue;
      }
      const onChain = chain.indexOf(n.id) >= 0 && chain.indexOf(n.parent) >= 0;
      const lineColor = onChain ? col(Palette.gold) : n.abandoned ? col(Palette.paleInkFar) : col(Palette.inkWash);
      const lineW = onChain ? 3 : 2;
      this.treeDraw.drawSegment(Vec2(from.x, from.y), Vec2(to.x, to.y), lineW, lineColor);
    }
  }

  /** 月相节点：朔→望→残 8 相，描金当前、灰化已弃 */
  private drawMoons(system: TreeOverlaySource): void {
    for (let i = 0; i < system.nodes.length; i++) {
      const n = system.nodes[i];
      const p = this.findPos(n.id);
      if (p === undefined) {
        continue;
      }
      const r = 13;
      if (n.id === system.currentId) {
        this.treeDraw.drawDot(Vec2(p.x, p.y), r + 9, Color(Palette.gold.r, Palette.gold.g, Palette.gold.b, 70));
        this.treeDraw.drawPolygon(circlePts(p.x, p.y, r + 5, 0, 360, 24), ink(0, 0, 0, 0), 2, col(Palette.gold));
      }
      this.drawMoonShape(p.x, p.y, r, n.phase, n.abandoned);
    }
  }

  private drawMoonShape(x: number, y: number, r: number, phase: number, abandoned: boolean): void {
    const lit = abandoned ? col(Palette.paleInkFar) : col(Palette.moonWhite);
    const rim = abandoned ? col(Palette.paleInkFar) : col(Palette.moonCyanSoft);
    const dark = col(PANEL_DARK);
    if (phase === 0) {
      // 朔：只有描边暗轮
      this.treeDraw.drawPolygon(circlePts(x, y, r, 0, 360, 24), ink(0, 0, 0, 0), 2, rim);
      return;
    }
    if (phase === 1 || phase === 7) {
      // 眉月/残月：两段弧合成的月牙（右/左）
      const s = phase === 1 ? 1 : -1;
      const pts = circlePts(x, y, r, s === 1 ? -75 : 105, s === 1 ? 75 : 255, 12)
        .concat(circlePts(x - s * r * 0.5, y, r * 0.9, s === 1 ? 75 : 255, s === 1 ? -75 : 105, 12));
      this.treeDraw.drawPolygon(pts, lit, 1, rim);
      return;
    }
    if (phase === 2 || phase === 6) {
      // 上弦/下弦：半圆亮面（右/左）
      const pts = circlePts(x, y, r, phase === 2 ? -90 : 90, phase === 2 ? 90 : 270, 12).concat([Vec2(x, y)]);
      this.treeDraw.drawPolygon(pts, lit, 1, rim);
      return;
    }
    if (phase === 3 || phase === 5) {
      // 盈凸/亏凸：满盘 + 遮挡小圆（近似）
      this.treeDraw.drawPolygon(circlePts(x, y, r, 0, 360, 24), lit, 1, rim);
      this.treeDraw.drawDot(Vec2(x + (phase === 3 ? -r * 0.8 : r * 0.8), y), r * 0.62, dark);
      return;
    }
    // 望（及其余回退）：满盘
    this.treeDraw.drawPolygon(circlePts(x, y, r, 0, 360, 24), lit, 1, rim);
  }

  /** 节点旁 via 短标注：「月相 · 取舍」；标签池复用，多余的隐藏 */
  private updateLabels(system: TreeOverlaySource): void {
    const count = system.nodes.length;
    while (this.viaLbs.length < count) {
      const lb = makeText(14);
      if (lb === undefined) {
        break;
      }
      lb.anchor = Vec2(0.5, 1);
      lb.addTo(this.root);
      this.viaLbs.push(lb);
    }
    for (let i = 0; i < this.viaLbs.length; i++) {
      this.viaLbs[i].visible = false;
    }
    for (let i = 0; i < count; i++) {
      const n = system.nodes[i];
      const p = this.findPos(n.id);
      if (p === undefined || i >= this.viaLbs.length) {
        continue;
      }
      const lb = this.viaLbs[i];
      lb.visible = true;
      lb.text = phaseName(n.phase) + " · " + n.via;
      lb.position = Vec2(p.x, p.y - 20);
      lb.color = n.id === system.currentId
        ? col(Palette.gold)
        : n.abandoned ? col(Palette.paleInkFar) : col(Palette.paleInk);
    }
  }

  private jumpToNode(system: TreeOverlaySource, id: string): void {
    if (id === system.currentId) {
      return; // 已在当前世界线，不重复回溯
    }
    if (system.onJumpTo !== undefined) {
      system.onJumpTo(id);
    }
    system.jumpTo(id);
    this.render(system);
  }
}