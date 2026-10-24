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
  // archer = 弓手：固定站位远程射箭（抬手前摇），1F 屋顶教学敌
  kind: "bandit" | "thrower" | "boss" | "archer";
  x: number;
  y: number;
  patrolMin: number;
  patrolMax: number;
  floor: number;
  // 仅在指定循环存在；undefined 表示所有循环都存在
  loops?: number[];
  // 初始朝向：1 右 -1 左（缺省 1）；站桩教学敌用它面向来路
  face?: number;
  // 巡逻是否被禁用（true = 纯站桩，只在原地转向索敌）
  holdPosition?: boolean;
  // 突进：chase 中距离 140~420 时先 telegraph 再高速冲刺接近
  lunge?: boolean;
}

export interface CollectibleDef {
  id: string;
  // lampstone = 点灯石：点灯解谜的拾取道具，必须持有才能点亮灯笼
  kind: "moonstone" | "mechanism" | "token" | "dew" | "lampstone";
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

// 传送门：每层尽头显现的跨层传送点（进入后切到目标层检查点，背景整块切换）
export interface PortalDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  targetFloor: number;
  /** 本层玩法通关门：该 gate 开启后传送门才显现/可触发；缺省 = 一直存在 */
  gateId?: string;
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

// 剑槽：用剑（近战攻// 剑槽（F4）：用剑插入后当钥匙，永久打开关联闸门
export interface SwordSlotDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  gateId: string;
}

// 风息符文（F3 塔外环廊）：冲刺穿过激活（走路不触发），全亮开关联闸门
export interface WindSigilDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  gateId: string;
}

// 星位（F5 观星者之间）：按 order 依序点亮，错序全部熄灭重来；全亮开关联闸门
export interface StarNodeDef {
  id: string;
  x: number;
  y: number;
  floor: number;
  order: number;
  gateId: string;
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
  // 战斗教学浮字：命中触发带时在画面上浮现教学提示（不弹对话框、不阻断）
  hint?: string;
}

export interface DialogLine {
  speaker: string;
  text: string;
}

export interface DialogChoice {
  text: string;
  trust: number;
  memory?: string;
  // 选项分支应答：确认该选项后插入台词队列继续播放（缺省沿用旧行为直接结束）
  replies?: DialogLine[];
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
  // 连问记录：key = storyId + "|" + 选项文本。与 storySeen 一样跨回溯快照保留，
  // 保证时空树跳回后不会因「已问过」而过滤掉全部选项、把记忆判成永久丢失。
  askedChoices: Record<string, boolean>;
  objective: string;
  stealthAlert: boolean;
  sneakBonus: boolean;
  // 本层已回溯次数（= 本层已消耗的 HP 上限格数；过层恢复清零）
  rewindPenalty: number;
  // 丢石子余量（潜行道具：石子落地发声引开敌人视线）
  pebbles: number;
  // 时空因果记录（引月札：种树/砍树/救人/不杀等关键事件的顺序账本）
  causalityLog: string[];
}
