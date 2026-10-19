/**
 * 状态机:全局唯一存档(单例)。
 * 时空树 = 节点(世界线状态)+ 边(玩家在分歧点做的选择)。
 * 引月札(线索)跨世界永久保留 —— 这是解谜循环的核心资源。
 */
import { PhaseName } from './constants';

export type NodeKind = 'root' | 'branch' | 'ending';

/** 分歧点选项:玩家在某个世界的最终抉择 */
export interface ChoiceEdge {
  /** 选项 id,对应剧情数据 choices */
  optionId: string;
  optionText: string;
  /** 分歧点 id */
  fromDivergence: string;
  /** 新世界线 */
  toPhase: PhaseName;
}

export interface TimelineNode {
  id: string;
  kind: NodeKind;
  phase: PhaseName;
  /** 父节点 id(root 为 null) */
  parent: string | null;
  /** 从父节点经哪次选择而来 */
  via: ChoiceEdge | null;
  /** 该节点创建时的高度,用于画树 */
  depth: number;
  /** 该线达成的事件 id 集合(进度快照) */
  events: string[];
  /** AI 日记(可能为降级文本),到达该线时生成 */
  diary: string | null;
  createdAt: number;
}

export interface GameState {
  currentNodeId: string;
  nodes: Record<string, TimelineNode>;
  order: string[];
  /** 跨时空引月札:已获得的线索 id */
  clues: string[];
  /** 阅读过的日记 id */
  diariesRead: string[];
  /** 结局选择:哪个节点被指定为唯一现实 */
  chosenReality: string | null;
  /** 已达成的结局 id */
  endingsSeen: string[];
  /** 是否已进入终章 */
  finaleReached: boolean;
  /** 引月札页数(穿越次数),用于开场教程节奏 */
  jumps: number;
  /** 是否启用了 AI 日记(运行时探测结果) */
  aiEnabled: boolean;
}

let state: GameState | null = null;

export function newGame(): GameState {
  const root: TimelineNode = {
    id: 'n0',
    kind: 'root',
    phase: '朔',
    parent: null,
    via: null,
    depth: 0,
    events: [],
    diary: null,
    createdAt: Date.now(),
  };
  state = {
    currentNodeId: root.id,
    nodes: { [root.id]: root },
    order: [root.id],
    clues: [],
    diariesRead: [],
    chosenReality: null,
    endingsSeen: [],
    finaleReached: false,
    jumps: 0,
    aiEnabled: false,
  };
  return state;
}

export function getState(): GameState {
  if (!state) newGame();
  return state!;
}

export function currentNode(): TimelineNode {
  return getState().nodes[getState().currentNodeId];
}

/** 穿越后到达新世界线 */
export function arriveNode(phase: PhaseName, via: ChoiceEdge | null, parent: TimelineNode | null): TimelineNode {
  const s = getState();
  const id = `n${s.order.length}`;
  const node: TimelineNode = {
    id,
    kind: 'branch',
    phase,
    parent: parent?.id ?? null,
    via,
    depth: (parent?.depth ?? -1) + 1,
    events: parent ? [...parent.events] : [],
    diary: null,
    createdAt: Date.now(),
  };
  s.nodes[id] = node;
  s.order.push(id);
  s.currentNodeId = id;
  s.jumps += via ? 1 : 0;
  return node;
}

export function addClue(clueId: string): boolean {
  const s = getState();
  if (s.clues.includes(clueId)) return false;
  s.clues.push(clueId);
  return true;
}

export function hasClue(clueId: string): boolean {
  return getState().clues.includes(clueId);
}

export function markEvent(eventId: string): void {
  const s = getState();
  const n = s.nodes[s.currentNodeId];
  if (!n.events.includes(eventId)) n.events.push(eventId);
}

export function hasEvent(eventId: string): boolean {
  return currentNode().events.includes(eventId);
}
