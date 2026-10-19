/**
 * 全局状态（zustand + localStorage 持久化）。
 * 月相轮回溯 / 信任 / 收集 / 时空树节点。
 */
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

export const MOON_PHASES = ['新月', '蛾眉', '弦月', '盈凸', '望', '亏凸', '下弦', '残月'] as const;
export type MoonPhase = (typeof MOON_PHASES)[number];

export type EndingId = 'reunion' | 'sacrifice' | 'duel' | 'exhausted';

/* ---------------- 时空树 ---------------- */

export type TreeNodeKind = 'origin' | 'rewind' | 'trust' | 'clue' | 'choice' | 'ending';

export interface TreeNode {
  id: string;
  parentId: string | null;
  /** 第 N 夜（1 起） */
  night: number;
  kind: TreeNodeKind;
  label: string;
  time: number;
  /** 跳回时的落点 */
  x: number;
  y: number;
  zone: string;
  endingId?: EndingId;
  /** 这条世界线的完整快照 */
  snap: Snapshot;
}

export interface Snapshot {
  loopIndex: number;
  moonPhaseIndex: number;
  life: number;
  maxLife: number;
  swordIntent: number;
  maxSwordIntent: number;
  trust: number;
  drawnBlade: boolean;
  clues: string[];
  relics: string[];
  moonStones: number;
  metShenyan: boolean;
  visited: string[];
}

export function emptySnapshot(): Snapshot {
  return {
    loopIndex: 0, moonPhaseIndex: 0, life: 3, maxLife: 3,
    swordIntent: 3, maxSwordIntent: 3, trust: 0, drawnBlade: false,
    clues: [], relics: [], moonStones: 0, metShenyan: false, visited: [],
  };
}

export type Phase = 'title' | 'prologue' | 'world' | 'ending' | 'tree';

export interface TreeState {
  nodes: TreeNode[];
  activeId: string | null;
  seq: number;
}

interface GameStore extends TreeState {
  phase: Phase;
  // 当前世界线状态（= active 节点的 snap 的工作副本）
  cur: Snapshot;
  px: number;
  py: number;
  zone: string;
  endingSeen: EndingId | null;
  showTree: boolean;
  showJournal: boolean;

  // 流程
  goto: (p: Phase) => void;
  toggleTree: (v?: boolean) => void;
  toggleJournal: (v?: boolean) => void;

  // 世界线
  seedOrigin: () => void;
  record: (kind: TreeNodeKind, label: string, pos?: { x: number; y: number; zone: string }, endingId?: EndingId) => void;
  jumpTo: (id: string) => void;
  resetAll: () => void;

  // 状态修改
  setPos: (x: number, y: number, zone: string) => void;
  rewind: () => boolean;
  addTrust: (n: number) => void;
  addClue: (id: string) => boolean;
  addRelic: (id: string) => boolean;
  addMoonStone: () => void;
  spendIntent: () => boolean;
  markMet: () => void;
  markBlade: () => void;
  hurt: (n: number) => void;
  heal: (n: number) => void;

  judgeEnding: (choseSacrifice: boolean, defeated: boolean) => EndingId;
}

function nowSnap(s: GameStore): Snapshot {
  return JSON.parse(JSON.stringify(s.cur)) as Snapshot;
}

export const useGame = create<GameStore>()(
  persist(
    (set, get) => ({
      phase: 'title',
      nodes: [],
      activeId: null,
      seq: 0,
      cur: emptySnapshot(),
      px: 2,
      py: 7,
      zone: 'riverbank',
      endingSeen: null,
      showTree: false,
      showJournal: false,

      goto: (p) => set({ phase: p, showTree: false, showJournal: false }),
      toggleTree: (v) => set(s => ({ showTree: v ?? !s.showTree })),
      toggleJournal: (v) => set(s => ({ showJournal: v ?? !s.showJournal })),

      seedOrigin: () => {
        const s = get();
        if (s.nodes.length > 0) return;
        const id = 'n0';
        set({
          nodes: [{
            id, parentId: null, night: 1, kind: 'origin', label: '起点 · 满月之夜',
            time: Date.now(), x: s.px, y: s.py, zone: s.zone, snap: nowSnap(s),
          }],
          activeId: id, seq: 1,
        });
      },

      record: (kind, label, pos, endingId) => {
        const s = get();
        const id = `n${s.seq}_${Date.now().toString(36)}`;
        const node: TreeNode = {
          id,
          parentId: s.activeId,
          night: s.cur.loopIndex + 1,
          kind, label,
          time: Date.now(),
          x: pos?.x ?? s.px,
          y: pos?.y ?? s.py,
          zone: pos?.zone ?? s.zone,
          snap: nowSnap(s),
        };
        if (endingId) node.endingId = endingId;
        set({ nodes: [...s.nodes, node], activeId: id, seq: s.seq + 1 });
      },

      jumpTo: (id) => {
        const s = get();
        const n = s.nodes.find(m => m.id === id);
        if (!n) return;
        set({
          activeId: id,
          cur: JSON.parse(JSON.stringify(n.snap)),
          px: n.x, py: n.y, zone: n.zone,
          phase: 'world', showTree: false, showJournal: false,
        });
      },

      resetAll: () => set({
        nodes: [], activeId: null, seq: 0, cur: emptySnapshot(),
        px: 2, py: 7, zone: 'riverbank', endingSeen: null,
        phase: 'world', showTree: false, showJournal: false,
      }),

      setPos: (x, y, zone) => set({ px: x, py: y, zone }),

      rewind: () => {
        const s = get();
        if (s.cur.life <= 1) return false;
        set({
          cur: {
            ...s.cur,
            life: s.cur.life - 1,
            loopIndex: s.cur.loopIndex + 1,
            moonPhaseIndex: Math.min(s.cur.moonPhaseIndex + 1, 7),
            swordIntent: s.cur.maxSwordIntent,
          },
        });
        get().record('rewind', `回溯 · ${MOON_PHASES[get().cur.moonPhaseIndex]}`);
        return true;
      },

      addTrust: (n) => set(s => ({ cur: { ...s.cur, trust: Math.max(0, s.cur.trust + n) } })),
      addClue: (id) => {
        const s = get();
        if (s.cur.clues.includes(id)) return false;
        set({ cur: { ...s.cur, clues: [...s.cur.clues, id] } });
        return true;
      },
      addRelic: (id) => {
        const s = get();
        if (s.cur.relics.includes(id)) return false;
        set({ cur: { ...s.cur, relics: [...s.cur.relics, id] } });
        return true;
      },
      addMoonStone: () => set(s => ({ cur: { ...s.cur, moonStones: s.cur.moonStones + 1 } })),
      spendIntent: () => {
        const s = get();
        if (s.cur.swordIntent <= 0) return false;
        set({ cur: { ...s.cur, swordIntent: s.cur.swordIntent - 1 } });
        return true;
      },
      markMet: () => set(s => ({ cur: { ...s.cur, metShenyan: true } })),
      markBlade: () => set(s => ({ cur: { ...s.cur, drawnBlade: true } })),
      hurt: (n) => set(s => ({ cur: { ...s.cur, life: Math.max(0, s.cur.life - n) } })),
      heal: (n) => set(s => ({ cur: { ...s.cur, life: Math.min(s.cur.maxLife, s.cur.life + n) } })),

      judgeEnding: (choseSacrifice, defeated) => {
        const s = get();
        if (choseSacrifice) return 'sacrifice';
        if (defeated) return 'duel';
        if (s.cur.trust >= 4 && !s.cur.drawnBlade) return 'reunion';
        return 'duel';
      },
    }),
    {
      name: 'yanyue-baxiang-v3',
      storage: createJSONStorage(() => localStorage),
      partialize: (s) => ({
        nodes: s.nodes, activeId: s.activeId, seq: s.seq, cur: s.cur,
        px: s.px, py: s.py, zone: s.zone, endingSeen: s.endingSeen,
      }) as unknown as GameStore,
    }
  )
);

/** 时空树祖先链（高亮通关路径） */
export function ancestorIds(nodes: TreeNode[], activeId: string | null): Set<string> {
  const chain = new Set<string>();
  const byId = new Map(nodes.map(n => [n.id, n]));
  let cur = activeId ? byId.get(activeId) ?? null : null;
  while (cur) {
    chain.add(cur.id);
    cur = cur.parentId ? byId.get(cur.parentId) ?? null : null;
  }
  return chain;
}