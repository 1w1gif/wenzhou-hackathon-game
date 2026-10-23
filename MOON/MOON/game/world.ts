// game/world.ts — 循环状态（月相轮回溯的核心账本）
import { LoopState } from "core/types";

export function createLoopState(): LoopState {
  return {
    loopIndex: 0,
    // 序章发生在满月之夜，之后每回溯一次月相推进一位
    phaseIndex: 4,
    heroineLife: 3,
    maxLife: 3,
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
    objective: "目标：向东探索河滩渡口（A/D 移动 · J 挥剑）",
    stealthAlert: false,
    sneakBonus: false,
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

export function lifeFraction(state: LoopState): number {
  return state.heroineLife / state.maxLife;
}

export function intentFraction(state: LoopState): number {
  return state.swordIntent / state.maxSwordIntent;
}
