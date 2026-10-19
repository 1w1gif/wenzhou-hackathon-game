/**
 * 时空树：玩家的每一次选择都会让树长出一条新枝。
 * 节点按「第 N 夜」分层（night = loopIndex + 1），点击任意节点跳回那条世界线。
 * 整棵树存在 localStorage，每位玩家的通关记录都是一棵独一无二的树。
 */
import type { GameStateData, EndingId } from './GameStore';

export type TreeNodeKind = 'origin' | 'rewind' | 'trust' | 'choice' | 'ending';

export interface TreeNode {
  id: string;
  parentId: string | null;
  /** 第 N 夜（1 起），由 state.loopIndex + 1 得到 */
  night: number;
  kind: TreeNodeKind;
  label: string;
  time: number;
  /** 长出这根枝条时玩家的位置（跳回时的落点） */
  x: number;
  y: number;
  endingId?: EndingId;
  /** 这条世界线的完整快照 */
  state: GameStateData;
}

export interface TreeLayoutNode extends TreeNode {
  lx: number;
  ly: number;
}

export const COL_W = 62;
export const ROW_H = 26;

const KEY = 'yanyue-timetree-v1';
const VERSION = 1;

class TimeTree {
  nodes: TreeNode[] = [];
  activeId: string | null = null;
  private seq = 0;

  constructor() {
    this.load();
  }

  get active(): TreeNode | null {
    return this.nodes.find(n => n.id === this.activeId) ?? null;
  }

  get maxNight(): number {
    return this.nodes.reduce((m, n) => Math.max(m, n.night), 1);
  }

  /** 长出一条新枝：以「当前所在节点」为父节点 */
  record(
    kind: TreeNodeKind,
    label: string,
    state: GameStateData,
    x: number,
    y: number,
    endingId?: EndingId
  ): TreeNode {
    const node: TreeNode = {
      id: `n${Date.now().toString(36)}_${this.seq++}`,
      parentId: this.activeId,
      night: state.loopIndex + 1,
      kind,
      label,
      time: Date.now(),
      x,
      y,
      state: JSON.parse(JSON.stringify(state)) as GameStateData,
    };
    if (endingId) node.endingId = endingId;
    this.nodes.push(node);
    this.activeId = node.id;
    this.save();
    return node;
  }

  /** 跳到某个节点：它成为当前所在世界线，之后的行动从这里长新枝 */
  jumpTo(id: string): TreeNode | null {
    const node = this.nodes.find(n => n.id === id);
    if (!node) return null;
    this.activeId = node.id;
    this.save();
    return node;
  }

  clear(): void {
    this.nodes = [];
    this.activeId = null;
    this.save();
  }

  /** 当前节点的祖先链（用于高亮通关路径） */
  ancestorIds(): Set<string> {
    const chain = new Set<string>();
    const byId = new Map(this.nodes.map(n => [n.id, n]));
    let cur = this.active;
    while (cur) {
      chain.add(cur.id);
      cur = cur.parentId ? byId.get(cur.parentId) ?? null : null;
    }
    return chain;
  }

  save(): void {
    try {
      localStorage.setItem(KEY, JSON.stringify({ version: VERSION, nodes: this.nodes, activeId: this.activeId }));
    } catch { /* 存储不可用时静默 */ }
  }

  load(): void {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return;
      const parsed = JSON.parse(raw);
      if (parsed.version !== VERSION || !Array.isArray(parsed.nodes)) return;
      this.nodes = parsed.nodes as TreeNode[];
      this.activeId = (parsed.activeId as string | null) ?? null;
    } catch { /* ignore */ }
  }
}

/** 全局单例 */
export const tree = new TimeTree();

/**
 * 布局：竖直为列 —— 「第 N 夜」一列，从左往右生长；同列内按父节点聚拢后均匀铺开。
 * 同一列里靠上的是先长出来的枝条，读起来像一条条时间线。
 */
export function layoutTree(): TreeLayoutNode[] {
  const indexOf = new Map(tree.nodes.map((n, i) => [n.id, i]));
  const byNight = new Map<number, TreeNode[]>();
  for (const n of tree.nodes) {
    const arr = byNight.get(n.night) ?? [];
    arr.push(n);
    byNight.set(n.night, arr);
  }

  const out: TreeLayoutNode[] = [];
  const nights = [...byNight.keys()].sort((a, b) => a - b);
  for (const night of nights) {
    const arr = byNight.get(night)!;
    // 同一列内：先按父节点在树里的先后聚拢，再按创建顺序
    arr.sort((a, b) => {
      const pa = a.parentId ? indexOf.get(a.parentId) ?? -1 : -1;
      const pb = b.parentId ? indexOf.get(b.parentId) ?? -1 : -1;
      return pa - pb || indexOf.get(a.id)! - indexOf.get(b.id)!;
    });
    const n = arr.length;
    arr.forEach((node, i) => {
      out.push({
        ...node,
        lx: (night - 1) * COL_W,
        ly: (i - (n - 1) / 2) * ROW_H,
      });
    });
  }
  return out;
}