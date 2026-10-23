// data/tower.ts — 七层塔关卡数据（世界坐标：左下原点，Y 向上）
import { BellDef, CheckpointDef, ClimbWall, CollectibleDef, EnemySpawn, GateDef, Hazard, Ladder, LanternDef, Platform, PlateDef, PushStoneDef, RopeDef, StoryTriggerDef } from "core/types";

export const WORLD_W = 6400;
export const WORLD_H = 3800;

// 七层可行走地面高度（= 各层地面顶边 y）
export const TOPS = [220, 700, 1180, 1680, 2180, 2680, 3290];

export const FLOORS: string[] = [
  "河滩 · 渡口",
  "古镇街巷",
  "悬空工坊",
  "塔外环廊",
  "机关层",
  "观星者之间",
  "观星台",
];

function plat(id: string, kind: Platform["kind"], floor: number, x: number, y: number, w: number, h: number, gateId?: string): Platform {
  return { id, kind, floor, x, y, w, h, gateId };
}

export const platforms: Platform[] = [
  // 第 0 层 河滩（y=220）
  plat("g00", "solid", 0, 0, 140, 2060, 80),
  plat("g01", "solid", 0, 2200, 100, 900, 120),
  plat("p00", "one-way", 0, 900, 380, 180, 18),
  plat("p01", "one-way", 0, 1500, 390, 160, 18),
  plat("p02", "one-way", 0, 1200, 310, 180, 18),
  // 第 1 层 古镇街巷（y=700）
  plat("g10", "solid", 1, 2200, 620, 1300, 80),
  plat("g11", "solid", 1, 3650, 600, 1150, 100),
  plat("p10", "one-way", 1, 2600, 860, 200, 18),
  plat("p11", "one-way", 1, 3300, 870, 180, 18),
  plat("p13", "one-way", 1, 3050, 790, 160, 18),
  plat("p12", "one-way", 1, 3900, 870, 200, 18),
  // 第 2 层 悬空工坊（y=1180）
  plat("g20", "solid", 2, 3000, 1100, 900, 80),
  plat("g21", "solid", 2, 4060, 1080, 740, 100),
  plat("p20", "one-way", 2, 3400, 1340, 180, 18),
  plat("p21", "one-way", 2, 3900, 1350, 160, 18),
  plat("p23", "one-way", 2, 3700, 1270, 160, 18),
  plat("p22", "one-way", 2, 4400, 1350, 180, 18),
  // 第 3 层 塔外环廊（y=1680）
  plat("g30", "solid", 3, 3700, 1600, 1100, 80),
  plat("g31", "solid", 3, 4950, 1580, 850, 100),
  plat("mv30", "solid", 3, 4840, 1640, 170, 20, undefined),
  plat("p30", "one-way", 3, 4100, 1840, 180, 18),
  plat("p31", "one-way", 3, 4600, 1850, 160, 18),
  plat("p32", "one-way", 3, 4350, 1770, 160, 18),
  // 第 4 层 机关层（y=2180）
  plat("g40", "solid", 4, 4300, 2100, 1100, 80),
  plat("g41", "solid", 4, 5550, 2080, 850, 100),
  plat("p40", "one-way", 4, 4700, 2340, 180, 18),
  plat("p41", "one-way", 4, 5200, 2350, 170, 18),
  plat("p42", "one-way", 4, 4950, 2270, 160, 18),
  // 第 5 层 观星者之间（y=2680）
  plat("g50", "solid", 5, 4800, 2600, 1000, 80),
  plat("g51", "solid", 5, 5950, 2580, 450, 100),
  plat("p50", "one-way", 5, 5200, 2840, 170, 18),
  // 第 6 层 观星台（y=3290）
  plat("g60", "solid", 6, 5300, 3210, 1100, 80),
  plat("p60", "one-way", 6, 5700, 3450, 170, 18),
  // 机关门（闭合时阻挡、开门后通行；碰撞与渲染同用此数组）
  // gate_workshop 由灯笼谜题（lanternGate 同一串机关）与钟 bell0 联动开启——
  // 原版无任何机关指向它，是 2 层的一扇死门
  plat("gp_workshop", "gate", 2, 4020, 1180, 40, 230, "gate_workshop"),
  plat("gp_town", "gate", 1, 3140, 700, 40, 220, "gate_town"),
  plat("gp_corridor", "gate", 3, 4900, 1680, 40, 240, "gate_corridor"),
  plat("gp_mech", "gate", 4, 5560, 2180, 40, 240, "gate_mech"),
  plat("gp_lantern", "gate", 2, 4180, 1180, 40, 230, "lanternGate"),
  // 世界边界墙：左右封死，防止走出世界
  plat("wallL", "solid", 0, -80, 0, 80, 3800),
  plat("wallR", "solid", 0, 6400, 0, 80, 3800),
  // 层间缺口垫底：可以跳下去，也能跳回来，不再坠入虚空
  plat("pt0", "solid", 0, 2060, 140, 140, 80),
  plat("pt1", "solid", 1, 3500, 520, 150, 80),
  plat("pt2", "solid", 2, 3900, 1000, 160, 80),
  plat("pt3", "solid", 3, 4800, 1500, 150, 80),
  plat("pt4", "solid", 4, 5400, 2000, 150, 80),
  plat("pt5", "solid", 5, 5800, 2500, 150, 80),
  // 出生区左侧补充平台：开局画面从左到右都有内容（单跳 176px 内可达，顶部可站）
  plat("p03", "one-way", 0, 320, 370, 180, 18),
  plat("p04", "one-way", 0, 620, 340, 160, 18),
];

// 移动平台（game.ts 用 lerp pingpong 驱动 mover）——按 id 查找，避免数组顺序变化导致索引错位（曾把 mover 错挂到 p22 上）
const mv30 = platforms.find((p) => p.id === "mv30");
if (mv30 !== undefined) {
  mv30.mover = { ax: 4840, ay: 1640, bx: 4940, by: 2100, period: 7.5, phase: 0 };
}

export const movers: Platform[] = platforms.filter((p) => p.mover !== undefined);

export const ladders: Ladder[] = [
  { id: "l0", floor: 0, x: 2050, y: 220, w: 46, h: 560 },
  { id: "l1", floor: 1, x: 2950, y: 700, w: 46, h: 560 },
  { id: "l2", floor: 2, x: 3760, y: 1180, w: 46, h: 580 },
  { id: "l3", floor: 3, x: 4800, y: 1680, w: 46, h: 580 },
  { id: "l4", floor: 4, x: 5450, y: 2180, w: 46, h: 580 },
  { id: "l5", floor: 5, x: 5900, y: 2680, w: 46, h: 690 },
];

export const climbWalls: ClimbWall[] = [
  { id: "cw0", floor: 0, x: 1980, y: 220, w: 60, h: 480 },
  { id: "cw1", floor: 2, x: 3960, y: 1180, w: 60, h: 460 },
  { id: "cw2", floor: 4, x: 5350, y: 2180, w: 60, h: 460 },
];

export const hazards: Hazard[] = [
  { id: "hz0", floor: 0, x: 1200, y: 140, w: 220, h: 80, damage: 1 },
  { id: "hz1", floor: 1, x: 3100, y: 620, w: 200, h: 80, damage: 1 },
  { id: "hz2", floor: 3, x: 4300, y: 1600, w: 240, h: 80, damage: 1 },
  { id: "hz3", floor: 4, x: 5800, y: 2080, w: 220, h: 80, damage: 2 },
];

export const enemies: EnemySpawn[] = [
  { id: "e00", kind: "bandit", floor: 0, x: 1650, y: 300, patrolMin: 1350, patrolMax: 1950, loops: undefined },
  { id: "e01", kind: "thrower", floor: 0, x: 2900, y: 300, patrolMin: 2700, patrolMax: 3050, loops: undefined },
  { id: "e10", kind: "bandit", floor: 1, x: 2600, y: 780, patrolMin: 2350, patrolMax: 3000, loops: undefined },
  { id: "e11", kind: "bandit", floor: 1, x: 4300, y: 780, patrolMin: 4000, patrolMax: 4600, loops: undefined },
  { id: "e20", kind: "thrower", floor: 2, x: 3500, y: 1260, patrolMin: 3250, patrolMax: 3700, loops: undefined },
  { id: "e30", kind: "bandit", floor: 3, x: 4200, y: 1760, patrolMin: 3950, patrolMax: 4500, loops: undefined },
  { id: "e40", kind: "bandit", floor: 4, x: 4700, y: 2260, patrolMin: 4450, patrolMax: 5100, loops: undefined },
  { id: "e41", kind: "thrower", floor: 4, x: 6000, y: 2260, patrolMin: 5800, patrolMax: 6200, loops: [1, 2, 3, 4, 5, 6, 7] },
  { id: "eboss", kind: "boss", floor: 6, x: 5700, y: 3370, patrolMin: 5450, patrolMax: 6100, loops: undefined },
];

export const collectibles: CollectibleDef[] = [
  { id: "ms0", kind: "moonstone", floor: 0, x: 960, y: 460, note: "月石·渡口", loops: undefined },
  { id: "ms1", kind: "moonstone", floor: 1, x: 3900, y: 950, note: "月石·屋檐", loops: undefined },
  { id: "ms2", kind: "moonstone", floor: 2, x: 4480, y: 1430, note: "月石·工坊", loops: undefined },
  { id: "mp0", kind: "mechanism", floor: 3, x: 4680, y: 1960, note: "机关部件", loops: undefined },
  { id: "mp1", kind: "mechanism", floor: 4, x: 5280, y: 2460, note: "机关部件", loops: undefined },
  { id: "tk0", kind: "token", floor: 5, x: 5250, y: 2920, note: "引月札残页", loops: undefined },
  { id: "dw0", kind: "dew", floor: 0, x: 500, y: 320, note: "晨露", loops: undefined },
  { id: "dw1", kind: "dew", floor: 3, x: 4160, y: 1920, note: "晨露", loops: undefined },
  { id: "ms7", kind: "moonstone", floor: 6, x: 5760, y: 3530, note: "月石·观星台", loops: undefined },
];

export const checkpoints: CheckpointDef[] = [
  { id: "cp_riverbank", floor: 0, x: 800, y: 220, label: "渡口石阶" },
  { id: "cp_town", floor: 1, x: 2500, y: 700, label: "古镇牌坊" },
  { id: "cp_workshop", floor: 2, x: 3300, y: 1180, label: "悬空工坊" },
  { id: "cp_corridor", floor: 3, x: 4300, y: 1680, label: "塔外环廊" },
  { id: "cp_mechanism", floor: 4, x: 5000, y: 2180, label: "机关层枢纽" },
  { id: "cp_observer", floor: 5, x: 5400, y: 2680, label: "观星者之间" },
  { id: "cp_observatory", floor: 6, x: 6000, y: 3290, label: "观星台" },
];
export const ropes: RopeDef[] = [
  { id: "rope0", floor: 1, x: 3320, y: 1180, length: 260, gateId: "gate_town", loopState: "resets" },
  { id: "rope1", floor: 3, x: 4780, y: 2180, length: 280, gateId: "gate_corridor", loopState: "resets" },
];

export const bells: BellDef[] = [
  { id: "bell0", floor: 1, x: 2450, y: 940, gateId: "gate_town" },
  { id: "bell1", floor: 3, x: 4200, y: 1940, gateId: "gate_corridor" },
];

export const plates: PlateDef[] = [
  { id: "plate0", floor: 4, x: 4600, y: 2180, gateId: "gate_mech" },
  { id: "plate1", floor: 4, x: 5300, y: 2180, gateId: "gate_mech" },
];

export const lanterns: LanternDef[] = [
  { id: "lt0", floor: 2, x: 3250, y: 1260, order: 1 },
  { id: "lt1", floor: 2, x: 3700, y: 1260, order: 2 },
  { id: "lt2", floor: 2, x: 4150, y: 1260, order: 3 },
];

export const pushStones: PushStoneDef[] = [
  { id: "stone0", floor: 4, x: 4850, y: 2180 },
];

export const gates: GateDef[] = [
  { id: "gate_town", floor: 1 },
  { id: "gate_workshop", floor: 2 },
  { id: "gate_corridor", floor: 3 },
  { id: "gate_mech", floor: 4 },
  { id: "lanternGate", floor: 2 },
];

// 门平台引用：gate 已并入 platforms（openedGates 内为 true 时通行/开启）
export const gatePlatforms: Platform[] = platforms.filter((p) => p.kind === "gate");

export const storyTriggers: StoryTriggerDef[] = [
  { id: "st0", floor: 0, x: 1180, y: 100, w: 220, h: 360, storyId: "story_check_intro", once: true },
  { id: "st1", floor: 0, x: 1500, y: 100, w: 260, h: 360, storyId: "story_riverside", once: true },
  { id: "st2", floor: 1, x: 2820, y: 580, w: 300, h: 360, storyId: "story_town", once: true },
  { id: "st3", floor: 2, x: 3220, y: 1060, w: 320, h: 360, storyId: "story_sneak_hint", once: true },
  { id: "st4", floor: 3, x: 4320, y: 1560, w: 300, h: 360, storyId: "story_workshop", once: true },
  // 观测者（斗笠旅人）在 5 层等候：初见 + 再问，两段都接上了
  { id: "st_obs1", floor: 5, x: 5120, y: 2560, w: 260, h: 360, storyId: "story_observer_1", once: true },
  { id: "st_obs2", floor: 5, x: 5520, y: 2560, w: 260, h: 360, storyId: "story_observer_2", once: true },
  // 替沈砚挡箭：可重复剧情（回溯后可再选），冷却 8 秒防止连播
  { id: "st5", floor: 4, x: 5150, y: 2060, w: 300, h: 360, storyId: "story_arrow", once: false, repeatCd: 8 },
];

export function mapSummary(): string {
  let s = "七层·衍月塔：";
  for (let i = 0; i < FLOORS.length; i++) {
    s += FLOORS[i];
    if (i < FLOORS.length - 1) {
      s += " → ";
    }
  }
  return s;
}