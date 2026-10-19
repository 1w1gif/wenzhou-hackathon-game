/**
 * 全局游戏状态：时间循环 + 月相轮 + 信任值 + 收集 + 存档。
 * 《衍月·八相》v2 —— 中秋满月，强盗攻塔，沈砚之死与八相回溯。
 */
export type MoonPhaseName =
  | '新月' | '蛾眉' | '弦月' | '盈凸' | '望' | '亏凸' | '下弦' | '残月';

export const MOON_PHASES: MoonPhaseName[] = [
  '新月', '蛾眉', '弦月', '盈凸', '望', '亏凸', '下弦', '残月'
];

export type EndingId = 'reunion' | 'sacrifice' | 'duel' | 'exhausted';

export interface CheckpointData {
  x: number;
  y: number;
  floorId: string;
}

export interface GameStateData {
  loopIndex: number;
  moonPhaseIndex: number;
  heroineLife: number;
  maxLife: number;
  swordIntent: number;
  maxSwordIntent: number;
  shenyanTrust: number;
  drawnBladeAgainst: boolean;
  clues: string[];
  moonStones: number;
  parts: number;
  relics: string[];
  solvedMechanisms: string[];
  killedBoss: boolean;
  metShenyan: boolean;
  shenyanCorruption: number;
  checkpoint: CheckpointData | null;
  visitedFloors: string[];
  endingSeen: EndingId | null;
}

const SAVE_KEY = 'yanyue-baxiang-v2';
const SAVE_VERSION = 2;

function freshState(): GameStateData {
  return {
    loopIndex: 0,
    moonPhaseIndex: 0,
    heroineLife: 3,
    maxLife: 3,
    swordIntent: 3,
    maxSwordIntent: 3,
    shenyanTrust: 0,
    drawnBladeAgainst: false,
    clues: [],
    moonStones: 0,
    parts: 0,
    relics: [],
    solvedMechanisms: [],
    killedBoss: false,
    metShenyan: false,
    shenyanCorruption: 0,
    checkpoint: null,
    visitedFloors: [],
    endingSeen: null,
  };
}

export class GameStore {
  private data: GameStateData = freshState();
  private scene: Phaser.Scene | null = null;

  attach(scene: Phaser.Scene): void {
    this.scene = scene;
  }

  get(): GameStateData {
    return this.data;
  }

  /* ---------- 月相轮 / 时间循环 ---------- */

  canRewind(): boolean {
    return this.data.heroineLife > 1;
  }

  /** 转动月相轮回溯：消耗 1 生命，推进月相刻度，加深沈砚被侵蚀 */
  rewind(): boolean {
    if (!this.canRewind()) return false;
    this.data.heroineLife -= 1;
    this.data.loopIndex += 1;
    this.data.moonPhaseIndex = Math.min(this.data.moonPhaseIndex + 1, 7);
    this.data.shenyanCorruption = Math.min(this.data.loopIndex * 2, 10);
    if (this.data.swordIntent < this.data.maxSwordIntent) {
      this.data.swordIntent = this.data.maxSwordIntent;
    }
    this.save();
    return true;
  }

  currentPhase(): MoonPhaseName {
    return MOON_PHASES[this.data.moonPhaseIndex];
  }

  /* ---------- 信任 ---------- */

  addTrust(n: number): void {
    this.data.shenyanTrust = Math.max(0, this.data.shenyanTrust + n);
    this.save();
  }

  markBladeDrawn(): void {
    this.data.drawnBladeAgainst = true;
    this.save();
  }

  /* ---------- 收集 ---------- */

  addClue(id: string): boolean {
    if (this.data.clues.includes(id)) return false;
    this.data.clues.push(id);
    this.save();
    return true;
  }

  hasClue(id: string): boolean {
    return this.data.clues.includes(id);
  }

  addRelic(id: string): boolean {
    if (this.data.relics.includes(id)) return false;
    this.data.relics.push(id);
    this.save();
    return true;
  }

  hasRelic(id: string): boolean {
    return this.data.relics.includes(id);
  }

  addMoonStone(n = 1): void {
    this.data.moonStones += n;
    this.save();
  }

  addPart(n = 1): void {
    this.data.parts += n;
    this.save();
  }

  solveMechanism(id: string): boolean {
    if (this.data.solvedMechanisms.includes(id)) return false;
    this.data.solvedMechanisms.push(id);
    this.save();
    return true;
  }

  isSolved(id: string): boolean {
    return this.data.solvedMechanisms.includes(id);
  }

  /* ---------- 检查点 / 存档 ---------- */

  setCheckpoint(cp: CheckpointData): void {
    this.data.checkpoint = cp;
    this.save();
  }

  visitFloor(id: string): void {
    if (!this.data.visitedFloors.includes(id)) {
      this.data.visitedFloors.push(id);
      this.save();
    }
  }

  markMetShenyan(): void {
    this.data.metShenyan = true;
    this.save();
  }

  markBossKilled(): void {
    this.data.killedBoss = true;
    this.save();
  }

  setEnding(id: EndingId): void {
    this.data.endingSeen = id;
    this.save();
  }

  /** 结局判定：
   *  reunion  团圆（真结局）：信任>=4 且从未拔剑，选择「放下剑」
   *  duel     剑锋相向：信任不足或拔过剑，击败沈砚
   *  sacrifice 以命换命：对峙中选择使用月相轮
   */
  judgeEnding(choseSacrifice: boolean, defeatedShenyan: boolean): EndingId {
    if (choseSacrifice) return 'sacrifice';
    if (defeatedShenyan) return 'duel';
    if (this.data.shenyanTrust >= 4 && !this.data.drawnBladeAgainst) return 'reunion';
    return 'duel';
  }

  save(): void {
    try {
      localStorage.setItem(
        SAVE_KEY,
        JSON.stringify({ version: SAVE_VERSION, state: this.data })
      );
    } catch { /* 存储不可用时静默 */ }
  }

  load(): boolean {
    try {
      const raw = localStorage.getItem(SAVE_KEY);
      if (!raw) return false;
      const parsed = JSON.parse(raw);
      if (parsed.version !== SAVE_VERSION) return false;
      this.data = { ...freshState(), ...parsed.state };
      return true;
    } catch {
      return false;
    }
  }

  hasSave(): boolean {
    try {
      return localStorage.getItem(SAVE_KEY) !== null;
    } catch {
      return false;
    }
  }

  reset(): void {
    this.data = freshState();
    try {
      localStorage.removeItem(SAVE_KEY);
    } catch { /* ignore */ }
  }

  /* ---------- 时空树跳转 ---------- */

  /** 用某条世界线的快照覆盖当前状态（时空树点击节点时调用） */
  restoreState(state: GameStateData): void {
    this.data = { ...freshState(), ...(JSON.parse(JSON.stringify(state)) as GameStateData) };
    this.save();
  }

  /** 时空树跳转的落点（瞬时数据，不写入存档） */
  private pendingSpawn: { x: number; y: number } | null = null;

  setPendingSpawn(p: { x: number; y: number }): void {
    this.pendingSpawn = p;
  }

  takePendingSpawn(): { x: number; y: number } | null {
    const p = this.pendingSpawn;
    this.pendingSpawn = null;
    return p;
  }
}

/** 全局单例 */
export const store = new GameStore();
