// core/types.ts — 《衍月·八相》共享类型定义
// 坐标约定：世界坐标以左下角为原点，Y 轴向上（Dora 原生约定）。
// 所有平台/区域矩形用左下角 + 宽高表示。

export interface Rect {
  x: number;
  y: number;
  w: number;
  h: number;
}

export type PlatformKind = "solid" | "one-way" | "gate";

export interface MoverDef {
  ax: number;
  ay: number;
  bx: number;
  by: number;
  period: number;
  phase: number;
}

export interface Platform extends Rect {
  id: string;
  kind: PlatformKind;
  floor: number;
  // gate 平台由机关控制开关；mover 平台按轨道移动
  gateId?: string;
  mover?: MoverDef;
}

export interface Ladder extends Rect {
  id: string;
  floor: number;
}

export interface ClimbWall extends Rect {
  id: string;
  floor: number;
}

export interface Hazard extends Rect {
  id: string;
  floor: number;
  damage: number;
}

export interface EnemySpawn {
  id: string;
  kind: "bandit" | "thrower" | "boss";
  x: number;
  y: number;
  patrolMin: number;
  patrolMax: number;
  floor: number;
  // 仅在指定循环存在；undefined 表示所有循环都存在
  loops?: number[];
}

export interface CollectibleDef {
  id: string;
  kind: "moonstone" | "mechanism" | "token" | "dew";
  x: number;
  y: number;
  floor: number;
  note?: string;
  loops?: number[];
}

export interface CheckpointDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  label: string;
}

export interface RopeDef {
  id: string;
  x: number;
  y: number;
  length: number;
  floor: number;
  gateId: string;
  // 回溯后此绳/门是否重置或改变
  loopState?: "resets" | "precut";
}

export interface BellDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  gateId: string;
}

export interface PlateDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  gateId: string;
}

export interface LanternDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  order: number;
}

export interface PushStoneDef {
  id: string;
  x: number;
  y: number;
  floor: number;
}

export interface GateDef {
  id: string;
  floor: number;
}

export interface StoryTriggerDef {
  id: string;
  x: number;
  y: number;
  w: number;
  h: number;
  floor: number;
  storyId: string;
  once: boolean;
  // 可重复触发剧情的再次触发冷却（秒）；once=true 时忽略
  repeatCd?: number;
}

export interface DialogLine {
  speaker: string;
  text: string;
}

export interface DialogChoice {
  text: string;
  trust: number;
  memory?: string;
}

export interface StoryNode {
  id: string;
  lines: DialogLine[];
  choices?: DialogChoice[];
  objective?: string;
  setFlag?: string;
}

export interface EndingDef {
  id: "reunion" | "sacrifice" | "blade" | "exhausted";
  title: string;
  lines: string[];
}

export interface LoopState {
  loopIndex: number;
  phaseIndex: number; // 0-7 八相
  heroineLife: number;
  maxLife: number;
  swordIntent: number;
  maxSwordIntent: number;
  shenyanTrust: number;
  drawnBladeAgainst: boolean;
  rewindCount: number;
  moonstones: number;
  mechanismParts: number;
  tokens: number;
  memories: string[];
  flags: Record<string, boolean>;
  cutRopes: Record<string, boolean>;
  rungBells: Record<string, boolean>;
  platesActive: Record<string, boolean>;
  lanternsLit: Record<string, boolean>;
  lanternSequence: number;
  lanternFailed: boolean;
  openedGates: Record<string, boolean>;
  collectedIds: Record<string, boolean>;
  checkpointsActivated: Record<string, boolean>;
  currentCheckpointId: string;
  storySeen: Record<string, boolean>;
  objective: string;
  stealthAlert: boolean;
  sneakBonus: boolean;
}
