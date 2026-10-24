// game/world.ts — 循环状态（月相轮回溯的核心账本）
import { LoopState } from "core/types";
import { bells, checkpoints, lanterns, plates, ropes } from "data/tower";

// 整改三：总 HP 上限 8 格；本层回溯每耗 1 格上限，过层恢复
export const LIFE_CAP = 8;

export function createLoopState(): LoopState {
  return {
    loopIndex: 0,
    // 序章发生在满月之夜，之后每回溯一次月相推进一位
    phaseIndex: 4,
    heroineLife: LIFE_CAP,
    maxLife: LIFE_CAP,
    swordIntent: 3,
    maxSwordIntent: 3,
    shenyanTrust: 0,
    drawnBladeAgainst: false,
    rewindCount: 0,
    moonstones: 0,
    mechanismParts: 0,
    tokens: 0,
    memories: [],
    flags: {},
    cutRopes: {},
    rungBells: {},
    platesActive: {},
    lanternsLit: {},
    lanternSequence: 0,
    lanternFailed: false,
    openedGates: {},
    collectedIds: {},
    checkpointsActivated: {},
    currentCheckpointId: "cp_riverbank",
    storySeen: {},
    askedChoices: {},
    objective: "走近树苗按 E 拾起；种入东侧枯坑，渡口传送门自会亮起",
    stealthAlert: false,
    sneakBonus: false,
    rewindPenalty: 0,
    pebbles: 0,
    causalityLog: [],
  };
}

export function addTrust(state: LoopState, amount: number): void {
  state.shenyanTrust = Math.max(0, state.shenyanTrust + amount);
}

export function recordMemory(state: LoopState, text: string): void {
  for (let i = 0; i < state.memories.length; i++) {
    if (state.memories[i] === text) {
      return;
    }
  }
  state.memories.push(text);
}

// 回溯时重置“时间线内”的进度：沈砚记忆清零、机关回到本循环变体基线。
// 收集品、已激活检查点、图鉴记忆保留。（旧叙事轮回用，见 game.loopAdvance）
export function rewindTimeline(state: LoopState): void {
  state.loopIndex = state.loopIndex + 1;
  state.phaseIndex = (state.phaseIndex + 1) % 8;
  state.rewindCount = state.rewindCount + 1;
  state.shenyanTrust = 0;
  state.cutRopes = {};
  state.rungBells = {};
  state.platesActive = {};
  state.lanternsLit = {};
  state.lanternSequence = 0;
  state.lanternFailed = false;
  state.openedGates = {};
  state.storySeen = {};
  state.stealthAlert = false;
  state.sneakBonus = false;
}

// 整改三·本层回溯：月相推进一位、本层 HP 上限耗 1 格，回到本层开局。
// 保留：钥匙/线索/已开的门/收集品/记忆/信任；只复位本层机关与潜行警报。
export function rewindFloor(state: LoopState): void {
  state.rewindCount = state.rewindCount + 1;
  state.phaseIndex = (state.phaseIndex + 1) % 8;
  state.rewindPenalty = state.rewindPenalty + 1;
  state.maxLife = Math.max(1, state.maxLife - 1);
  if (state.heroineLife > state.maxLife) {
    state.heroineLife = state.maxLife;
  }
  resetFloorMechanisms(state);
  state.stealthAlert = false;
  state.swordIntent = state.maxSwordIntent;
}

// 只清当前层（currentCheckpointId 所在层）的绳/钟/压力板/灯笼机关记录；
// openedGates 保留——已开的门不因回溯重新关上（可反证的因果由种树谜题承担）。
export function resetFloorMechanisms(state: LoopState): void {
  let floor = -1;
  for (let i = 0; i < checkpoints.length; i++) {
    if (checkpoints[i].id === state.currentCheckpointId) {
      floor = checkpoints[i].floor;
      break;
    }
  }
  for (let i = 0; i < ropes.length; i++) {
    if (ropes[i].floor === floor) {
      delete state.cutRopes[ropes[i].id];
    }
  }
  for (let i = 0; i < bells.length; i++) {
    if (bells[i].floor === floor) {
      delete state.rungBells[bells[i].id];
    }
  }
  for (let i = 0; i < plates.length; i++) {
    if (plates[i].floor === floor) {
      delete state.platesActive[plates[i].id];
    }
  }
  for (let i = 0; i < lanterns.length; i++) {
    if (lanterns[i].floor === floor) {
      delete state.lanternsLit[lanterns[i].id];
    }
  }
  state.lanternSequence = 0;
  state.lanternFailed = false;
}

// 整改三：过层恢复 HP 上限（换层传送到达时调用）
export function restoreFloorCap(state: LoopState): void {
  state.rewindPenalty = 0;
  state.maxLife = LIFE_CAP;
  if (state.heroineLife > state.maxLife) {
    state.heroineLife = state.maxLife;
  }
}

export function lifeFraction(state: LoopState): number {
  return state.heroineLife / state.maxLife;
}

export function intentFraction(state: LoopState): number {
  return state.swordIntent / state.maxSwordIntent;
}
