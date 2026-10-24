// ui/tree_gallery.ts — 时空树仓库浮层：左侧通关名录 + 右侧该旅人的时空树预览
// 数据来自 core/archive 的存档；与 ui/tree_overlay 画法一致（枝干描线 + 月相节点），但只读展示
import { makeTechPanel } from "ui/tech_ui";
import { Color, DrawNode, KeyName, Label, Node, Size, Touch, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { ArchiveEntry, ArchiveNode } from "core/archive";

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

function col(c: InkColor): Color.Type {
  return Color(c.r, c.g, c.b, c.a);
}

interface MiniPoint {
  id: string;
  x: number;
  y: number;
}

/** 由 currentId 沿 parent 回溯得到根→当前的 id 链（存档里无链表，按需重建） */
function chainOf(nodes: ArchiveNode[], currentId: string): string[] {
  const chain: string[] = [];
  let cur: ArchiveNode | undefined = undefined;
  for (let i = 0; i < nodes.length; i++) {
    if (nodes[i].id === currentId) {
      cur = nodes[i];
      break;
    }
  }
  while (cur !== undefined) {
    chain.unshift(cur.id);
    let next: ArchiveNode | undefined = undefined;
    if (cur.parent !== "") {
      for (let i = 0; i < nodes.length; i++) {
        if (nodes[i].id === cur.parent) {
          next = nodes[i];
          break;
        }
      }
    }
    cur = next;
  }
  return chain;
}

export class TreeGallery {
  private root: Node.Type;
  private listDraw: DrawNode.Type;
  private treeDraw: DrawNode.Type;
  private hit: Node.Type;
  private titleLb: Label.Type | undefined;
  private infoLb: Label.Type | undefined;
  private hintLb: Label.Type | undefined;
  private rowLbs: Label.Type[];
  private entries: ArchiveEntry[];
  private sel: number;
  private scroll: number;
  private openFlag: boolean;
  private w: number;
  private h: number;
  private rowH: number;
  private listTop: number;
  private visibleRows: number;

  constructor(parent: Node.Type) {
    this.entries = [];
    this.sel = 0;
    this.scroll = 0;
    this.openFlag = false;
    this.rowLbs = [];
    this.w = View.size.width;
    this.h = View.size.height;
    this.rowH = 44;
    this.listTop = this.h / 2 - 170;
    this.visibleRows = Math.floor((this.h - 320) / this.rowH);
    this.root = Node();
    this.root.addTo(parent);
    this.root.visible = false;
    const hw = this.w / 2;
    const hh = this.h / 2;
    const bg = DrawNode();
    bg.addTo(this.root);
    bg.drawPolygon([Vec2(-hw, -hh), Vec2(hw, -hh), Vec2(hw, hh), Vec2(-hw, hh)], Color(0, 0, 0, 212));
    // 科技风主面板（框体贴图，替代描金内框）
    makeTechPanel(this.root, this.w - 36, this.h - 36);
    this.listDraw = DrawNode();
    this.listDraw.addTo(this.root);
    this.treeDraw = DrawNode();
    this.treeDraw.addTo(this.root);
    // 标题与信息条
    const title = makeText(30);
    if (title !== undefined) {
      title.text = "时空树仓库";
      title.anchor = Vec2(0.5, 0.5);
      title.position = Vec2(0, hh - 66);
      title.color = col(ink(255, 255, 255, 255));
      title.addTo(this.root);
      this.titleLb = title;
    }
    const info = makeText(17);
    if (info !== undefined) {
      info.anchor = Vec2(0.5, 0.5);
      info.position = Vec2(this.w / 2 - 380, -hh + 92);
      info.color = col(ink(255, 255, 255, 255));
      info.addTo(this.root);
      this.infoLb = info;
    }
    const hint = makeText(14);
    if (hint !== undefined) {
      hint.text = "W / S  选择旅人 · Esc 返回 · 每通过一局，这里便多一棵独一无二的时空树";
      hint.anchor = Vec2(0.5, 0.5);
      hint.position = Vec2(0, -hh + 44);
      hint.color = col(ink(255, 255, 255, 255));
      hint.addTo(this.root);
      this.hintLb = hint;
    }
    // 名录行标签池（复用，多余隐藏）
    for (let i = 0; i < this.visibleRows; i++) {
      const lb = makeText(18);
      if (lb === undefined) {
        break;
      }
      lb.anchor = Vec2(0, 0.5);
      lb.position = Vec2(-this.w / 2 + 58, this.listTop - i * this.rowH);
      lb.addTo(this.root);
      this.rowLbs.push(lb);
    }
    this.hit = Node();
    this.hit.size = Size(this.w, this.h);
    this.hit.position = Vec2(0, 0);
    this.hit.touchEnabled = false;
    this.hit.addTo(this.root);
    this.hit.onTapBegan((touch: Touch.Type) => {
      if (!this.openFlag) {
        return;
      }
      const local = touch.location;
      const px = local.x - this.w * 0.5;
      const py = local.y - this.h * 0.5;
      for (let i = 0; i < this.visibleRows; i++) {
        const idx = this.scroll + i;
        if (idx >= this.entries.length) {
          break;
        }
        const rowY = this.listTop - i * this.rowH;
        if (px >= -this.w / 2 + 30 && px <= 120 && Math.abs(py - rowY) <= this.rowH / 2) {
          this.sel = idx;
          this.render();
          return;
        }
      }
    });
  }

  open(entries: ArchiveEntry[]): void {
    this.entries = entries;
    this.sel = Math.max(0, Math.min(this.sel, entries.length - 1));
    this.scroll = 0;
    this.openFlag = true;
    this.root.visible = true;
    this.hit.touchEnabled = true;
    this.render();
  }

  close(): void {
    this.openFlag = false;
    this.root.visible = false;
    this.hit.touchEnabled = false;
  }

  isOpen(): boolean {
    return this.openFlag;
  }

  /** 由 game.onKey 转发：W/S 选择、A/D 翻页、Esc 关闭 */
  handleKey(key: KeyName): void {
    if (!this.openFlag) {
      return;
    }
    if (key === KeyName.Escape || key === KeyName.Q) {
      this.close();
    } else if (key === KeyName.W || key === KeyName.Up) {
      this.moveSel(-1);
    } else if (key === KeyName.S || key === KeyName.Down) {
      this.moveSel(1);
    } else if (key === KeyName.A || key === KeyName.Left) {
      this.moveSel(-this.visibleRows);
    } else if (key === KeyName.D || key === KeyName.Right) {
      this.moveSel(this.visibleRows);
    }
  }

  private moveSel(delta: number): void {
    if (this.entries.length === 0) {
      return;
    }
    let s = this.sel + delta;
    if (s < 0) {
      s = 0;
    }
    if (s > this.entries.length - 1) {
      s = this.entries.length - 1;
    }
    if (s !== this.sel) {
      this.sel = s;
      this.render();
    }
  }

  private render(): void {
    this.renderList();
    this.renderTree();
  }

  private renderList(): void {
    // 滚动窗口跟随选中行
    if (this.sel < this.scroll) {
      this.scroll = this.sel;
    }
    if (this.sel > this.scroll + this.visibleRows - 1) {
      this.scroll = this.sel - this.visibleRows + 1;
    }
    this.listDraw.clear();
    for (let i = 0; i < this.rowLbs.length; i++) {
      this.rowLbs[i].visible = false;
    }
    if (this.entries.length === 0) {
      if (this.infoLb !== undefined) {
        this.infoLb.text = "仓库空空如也 —— 通关一局，时空树便会留存于此";
      }
      return;
    }
    const selIdx = this.sel - this.scroll;
    for (let i = 0; i < this.visibleRows; i++) {
      const idx = this.scroll + i;
      if (idx >= this.entries.length || i >= this.rowLbs.length) {
        break;
      }
      const e = this.entries[idx];
      const lb = this.rowLbs[i];
      lb.visible = true;
      lb.text = (idx + 1) + ". " + e.name;
      const selected = idx === this.sel;
      lb.color = col(ink(255, 255, 255, 255));
      if (selected) {
        const y = this.listTop - i * this.rowH;
        this.listDraw.drawPolygon(
          [Vec2(-this.w / 2 + 36, y - 16), Vec2(-this.w / 2 + 496, y - 16), Vec2(-this.w / 2 + 496, y + 16), Vec2(-this.w / 2 + 36, y + 16)],
          Color(96, 200, 255, 30), 1, Color(96, 200, 255, 150),
        );
      }
    }
  }

  private renderTree(): void {
    this.treeDraw.clear();
    if (this.entries.length === 0 || this.sel >= this.entries.length) {
      return;
    }
    const e = this.entries[this.sel];
    if (this.infoLb !== undefined) {
      this.infoLb.text = "「" + e.name + "」的时空树 · " + e.nodes.length + " 条枝 · 回溯 " + e.rewindCount + " 次 · " + e.endingTitle;
    }
    // 深度分层布局：树底根、向上生长，限定在右侧预览区
    const nodes = e.nodes;
    let maxDepth = 0;
    for (let i = 0; i < nodes.length; i++) {
      if (nodes[i].depth > maxDepth) {
        maxDepth = nodes[i].depth;
      }
    }
    const cx = 330;
    const yBot = -this.h / 2 + 140;
    const yTop = this.h / 2 - 190;
    const rows = maxDepth + 1;
    const rowH = rows <= 1 ? 0 : Math.min(96, (yTop - yBot) / (rows - 1));
    const groups: ArchiveNode[][] = [];
    for (let d = 0; d <= maxDepth; d++) {
      groups.push([]);
    }
    for (let i = 0; i < nodes.length; i++) {
      const d = Math.max(0, Math.min(maxDepth, nodes[i].depth));
      groups[d].push(nodes[i]);
    }
    const pts: MiniPoint[] = [];
    for (let d = 0; d < groups.length; d++) {
      const g = groups[d];
      const spacing = Math.min(72, 560 / Math.max(1, g.length));
      for (let i = 0; i < g.length; i++) {
        pts.push({ id: g[i].id, x: cx + (i - (g.length - 1) / 2) * spacing, y: yBot + d * rowH });
      }
    }
    const chain = chainOf(nodes, e.currentId);
    // 枝干：当前链描金、灰枝淡墨、正常枝墨色
    for (let i = 0; i < nodes.length; i++) {
      const n = nodes[i];
      if (n.parent === "") {
        continue;
      }
      const from = this.findPos(pts, n.parent);
      const to = this.findPos(pts, n.id);
      if (from === undefined || to === undefined) {
        continue;
      }
      const onChain = chain.indexOf(n.id) >= 0 && chain.indexOf(n.parent) >= 0;
      const lineColor = onChain ? col(Palette.gold) : n.abandoned ? col(Palette.paleInkFar) : col(Palette.inkWash);
      this.treeDraw.drawSegment(Vec2(from.x, from.y), Vec2(to.x, to.y), onChain ? 3 : 2, lineColor);
    }
    // 月相节点：缩小的满盘圆 + 描金当前
    for (let i = 0; i < nodes.length; i++) {
      const n = nodes[i];
      const p = this.findPos(pts, n.id);
      if (p === undefined) {
        continue;
      }
      const r = 10;
      if (n.id === e.currentId) {
        this.treeDraw.drawDot(Vec2(p.x, p.y), r + 7, Color(Palette.gold.r, Palette.gold.g, Palette.gold.b, 70));
        this.treeDraw.drawDot(Vec2(p.x, p.y), r + 3, col(Palette.gold));
      }
      const lit = n.abandoned ? col(Palette.paleInkFar) : col(Palette.moonWhite);
      const rim = n.abandoned ? col(Palette.paleInkFar) : col(Palette.moonCyanSoft);
      this.treeDraw.drawDot(Vec2(p.x, p.y), r, lit);
      this.treeDraw.drawDot(Vec2(p.x, p.y - r * 0.3), r * 0.55, col(ink(14, 17, 22, 255)));
      if (n.phase === 0) {
        this.treeDraw.drawDot(Vec2(p.x, p.y), r, col(ink(14, 17, 22, 255)));
      }
    }
  }

  private findPos(pts: MiniPoint[], id: string): MiniPoint | undefined {
    for (let i = 0; i < pts.length; i++) {
      if (pts[i].id === id) {
        return pts[i];
      }
    }
    return undefined;
  }
}
