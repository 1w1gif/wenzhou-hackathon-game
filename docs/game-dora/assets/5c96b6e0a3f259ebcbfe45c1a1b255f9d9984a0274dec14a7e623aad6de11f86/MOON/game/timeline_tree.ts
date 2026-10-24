// game/timeline_tree.ts — 时空树最小可用版：关键选择长枝 / 可跳回 / 统计
// 数据结构：parent/via/phase/depth/abandoned；跳回语义：只改 currentId，绝不删枝。
// 依赖方向单向：本文件 → ui/tree_overlay.ts；overlay 自持本地结构接口，无回环 import。
import { KeyName, Node } from "Dora";
import { TreeOverlay } from "ui/tree_overlay";

/** 时空树节点：玩家的一个关键选择长成的一条世界线 */
export interface TreeNode {
  /** 唯一 id（根为 "tn0"，其后自增） */
  id: string;
  /** 父节点 id；根节点为 "" */
  parent: string;
  /** 当时的取舍文字（如「种树」「救人」「不杀」） */
  via: string;
  /** 月相 0..7：按深度映射 朔→望→残 共 8 相循环 */
  phase: number;
  /** 第 N 夜：树的纵向分层 */
  depth: number;
  /** 被放弃的世界线（灰化但永远保留） */
  abandoned: boolean;
}

/** 时空树系统：纯数据 + 轻量浮层控制，读档回溯由游戏层通过 onJumpTo 对接 */
export class TreeSystem {
  public nodes: TreeNode[];
  public currentId: string;
  public rewindCount: number;
  /** 可选回调：点击节点跳回时触发，游戏层后续接真正的读档回溯 */
  public onJumpTo?: (id: string) => void;
  /** 可选回调：新节点长成时触发（含分叉与续枝），游戏层借此刻下世界快照供跳回 */
  public onNodeAdded?: (id: string) => void;

  private seq: number;
  private noKill: boolean;
  private overlay: TreeOverlay | undefined;

  constructor(rootVia: string) {
    this.seq = 1;
    this.noKill = false;
    this.rewindCount = 0;
    this.nodes = [];
    const root: TreeNode = {
      id: "tn0",
      parent: "",
      via: rootVia,
      phase: 0,
      depth: 0,
      abandoned: false,
    };
    this.nodes.push(root);
    this.currentId = root.id;
    this.overlay = undefined;
  }

  /** 在当前节点的父节点处分叉出一条新枝并设为当前；原枝标 abandoned（只增不减） */
  addChoice(via: string): void {
    const cur = this.findById(this.currentId);
    if (cur === undefined) {
      return;
    }
    const parentId = cur.parent;
    const parent = parentId === "" ? undefined : this.findById(parentId);
    const parentDepth = parent !== undefined ? parent.depth : 0;
    const node: TreeNode = {
      id: "tn" + ("" + this.seq),
      parent: parentId,
      via: via,
      phase: (parentDepth + 1) % 8,
      depth: parentDepth + 1,
      abandoned: false,
    };
    this.seq = this.seq + 1;
    cur.abandoned = true;
    this.nodes.push(node);
    this.currentId = node.id;
    if (this.onNodeAdded !== undefined) {
      this.onNodeAdded(node.id);
    }
  }

  /** 探索生长：在当前世界线末端续长一节（不弃枝）——进层、开闸、斩敌、夜循环皆记于此 */
  extend(via: string): void {
    const cur = this.findById(this.currentId);
    if (cur === undefined) {
      return;
    }
    const node: TreeNode = {
      id: "tn" + ("" + this.seq),
      parent: cur.id,
      via: via,
      phase: (cur.depth + 1) % 8,
      depth: cur.depth + 1,
      abandoned: false,
    };
    this.seq = this.seq + 1;
    this.nodes.push(node);
    this.currentId = node.id;
    if (this.onNodeAdded !== undefined) {
      this.onNodeAdded(node.id);
    }
  }

  /** 跳回某条世界线：设 currentId 并 rewindCount+1；随后关闭浮层让游戏层演出回溯 */
  jumpTo(id: string): void {
    const node = this.findById(id);
    if (node === undefined) {
      return;
    }
    this.currentId = id;
    this.rewindCount = this.rewindCount + 1;
    if (this.overlay !== undefined && this.overlay.isOpen()) {
      this.overlay.close();
    }
  }

  /** 由游戏层转发按键：T 键开合浮层，Esc 关闭 */
  handleKey(key: KeyName): void {
    if (this.overlay === undefined) {
      return;
    }
    if (key === KeyName.T) {
      this.overlay.toggle(this);
    } else if (key === KeyName.Escape && this.overlay.isOpen()) {
      this.overlay.close();
    }
  }

  /** 创建浮层根节点（隐藏待命）；重复调用无效 */
  attachTo(parent: Node.Type): void {
    if (this.overlay !== undefined) {
      return;
    }
    this.overlay = new TreeOverlay(parent);
  }

  /** 浮层是否打开（供游戏层决定 Esc 优先关树而非暂停） */
  isOverlayOpen(): boolean {
    return this.overlay !== undefined && this.overlay.isOpen();
  }

  /** 记录「全程不杀」达成与否（统计占位字段） */
  setStats(noKill: boolean): void {
    this.noKill = noKill;
  }

  /** 底部统计条文案：共 N 条枝 / M 次回溯 / 不杀达成与否 */
  getStats(): string {
    const noKillText = this.noKill ? "达成" : "未达成";
    return "共 " + this.nodes.length + " 条枝 · 回溯 " + this.rewindCount + " 次 · 不杀：" + noKillText;
  }

  findById(id: string): TreeNode | undefined {
    for (let i = 0; i < this.nodes.length; i++) {
      if (this.nodes[i].id === id) {
        return this.nodes[i];
      }
    }
    return undefined;
  }

  /** 当前世界线从根到当前的 id 链（浮层描金用） */
  currentChain(): string[] {
    const chain: string[] = [];
    let cur = this.findById(this.currentId);
    while (cur !== undefined) {
      chain.unshift(cur.id);
      cur = cur.parent === "" ? undefined : this.findById(cur.parent);
    }
    return chain;
  }
}
