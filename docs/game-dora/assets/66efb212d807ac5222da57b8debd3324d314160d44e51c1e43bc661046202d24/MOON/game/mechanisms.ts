// game/mechanisms.ts — 机关系统：斩绳、击钟、压重石板、灯笼接力、检查点、收集品、推石
import {
  LoopState,
  RopeDef,
  BellDef,
  PlateDef,
  LanternDef,
  PushStoneDef,
  CheckpointDef,
  CollectibleDef,
  Platform,
  Rect,
  StarNodeDef,
  SwordSlotDef,
  WindSigilDef,
} from "core/types";
import { BodyState, rectOverlap, moveAndCollide, clamp } from "game/physics";
import { EffectSystem } from "game/effects";
import { PlayerTuning } from "game/player";

export interface StoneBody {
  x: number;
  y: number;
  vx: number;
  vy: number;
  w: number;
  h: number;
  onGround: boolean;
}

export interface MechanismEvents {
  onGateOpen: (gateId: string) => void;
  onBell: (x: number, y: number) => void;
  onLanternLit: (order: number) => void;
  onLanternFail: () => void;
  onCheckpoint: (id: string) => void;
  onCollect: (kind: string, x: number, y: number) => void;
  // 剑插入剑槽成功（可选回调，缺省静默）
  onSwordInserted?: () => void;
  // 想点灯但没有点灯石（可选回调，用于提示文案）
  onLanternNoStone?: () => void;
  // 风息符文被冲刺穿过激活（F3）
  onWindSigil: (id: string) => void;
  // 星位按序点亮成功（F5）
  onStarLit: (order: number) => void;
  // 星位点亮顺序错误（F5，已全部熄灭）
  onStarFail: () => void;
}

export interface MechanismCtx {
  platforms: Platform[];
}

const STONE_W = 56;
const STONE_H = 44;
const GRAV = 2300;

export class MechanismSystem {
  state: LoopState;
  fx: EffectSystem;
  events: MechanismEvents;
  stones: StoneBody[];

  constructor(state: LoopState, fx: EffectSystem, events: MechanismEvents) {
    this.state = state;
    this.fx = fx;
    this.events = events;
    this.stones = [];
  }

  syncStones(defs: PushStoneDef[]): void {
    this.stones.length = 0;
    for (let i = 0; i < defs.length; i++) {
      const d = defs[i];
      this.stones.push({ x: d.x, y: d.y + STONE_H / 2, vx: 0, vy: 0, w: STONE_W, h: STONE_H, onGround: false });
    }
  }

  // 回溯后的循环变体：标记为 precut 的绳在本循环开始时已被斩断
  applyLoopVariants(ropes: RopeDef[]): void {
    for (let i = 0; i < ropes.length; i++) {
      const r = ropes[i];
      if (r.loopState === "precut" && this.state.loopIndex >= 1) {
        this.state.cutRopes[r.id] = true;
        this.openGateSilent(r.gateId);
      }
    }
  }

  isGateOpen(gateId: string): boolean {
    return this.state.openedGates[gateId] === true;
  }

  openGate(gateId: string): void {
    if (this.state.openedGates[gateId]) {
      return;
    }
    this.state.openedGates[gateId] = true;
    this.events.onGateOpen(gateId);
  }

  openGateSilent(gateId: string): void {
    this.state.openedGates[gateId] = true;
  }

  private ropeRect(r: RopeDef): Rect {
    return { x: r.x - 6, y: r.y - r.length, w: 12, h: r.length };
  }

  private bellRect(b: BellDef): Rect {
    return { x: b.x - 26, y: b.y - 20, w: 52, h: 46 };
  }

  private stoneRect(s: StoneBody): Rect {
    return { x: s.x - s.w / 2, y: s.y - s.h / 2, w: s.w, h: s.h };
  }

  update(
    dt: number,
    playerRect: Rect,
    playerPushDir: number,
    attackRect: Rect | undefined,
    qiRects: Rect[],
    ctx: MechanismCtx
  ): void {
    // 双条件门自检（用户需求③⑤）：任一条件完成、或循环重置后旗标组合变化，
    // 都按当前旗标重新判定——条件齐备才开门，未齐备保持关闭。
    const reqGates = Object.keys(this.gateReqs);
    for (let i = 0; i < reqGates.length; i++) {
      this.refreshGate(reqGates[i]);
    }
    // --- 推石 ---
    for (let i = 0; i < this.stones.length; i++) {
      const s = this.stones[i];
      const sr = this.stoneRect(s);
      // 玩家推：站在地面且与石头水平相邻
      const adjacent =
        playerRect.x < sr.x + sr.w + 4 &&
        playerRect.x + playerRect.w > sr.x - 4 &&
        playerRect.y < sr.y + sr.h &&
        playerRect.y + playerRect.h > sr.y;
      if (adjacent && playerPushDir !== 0 && s.onGround) {
        // 人推箱子（用户需求）：石头速度与主角移速一致（runSpeed=320），
        // 加/减速也对齐主角（accel/decel）：起步同步、松手同停，不窜出不掉队
        const pushRight = playerRect.x + playerRect.w / 2 < s.x;
        if ((pushRight && playerPushDir > 0) || (!pushRight && playerPushDir < 0)) {
          const targetVx = playerPushDir * PlayerTuning.runSpeed;
          s.vx += clamp(targetVx - s.vx, -PlayerTuning.accel * dt, PlayerTuning.accel * dt);
        } else {
          s.vx += clamp(0 - s.vx, -PlayerTuning.decel * dt, PlayerTuning.decel * dt);
        }
      } else {
        s.vx += clamp(0 - s.vx, -PlayerTuning.decel * dt, PlayerTuning.decel * dt);
      }
      s.vy = clamp(s.vy - GRAV * dt, -1150, 1150);
      const body: BodyState = {
        x: s.x,
        y: s.y,
        vx: s.vx,
        vy: s.vy,
        w: s.w,
        h: s.h,
        onGround: s.onGround,
        groundId: "",
        onLadder: false,
      };
      moveAndCollide(body, ctx.platforms, s.vx * dt, s.vy * dt, false);
      s.x = body.x;
      s.y = body.y;
      s.vx = body.vx;
      s.vy = body.vy;
      s.onGround = body.onGround;
    }

    // --- 斩绳（攻击或剑气命中） ---
    for (let i = 0; i < this.ropesList.length; i++) {
      const r = this.ropesList[i];
      if (this.state.cutRopes[r.id]) {
        continue;
      }
      const rr = this.ropeRect(r);
      let cut = false;
      if (attackRect !== undefined && rectOverlap(attackRect, rr)) {
        cut = true;
      }
      for (let k = 0; k < qiRects.length; k++) {
        if (rectOverlap(qiRects[k], rr)) {
          cut = true;
        }
      }
      if (cut) {
        this.state.cutRopes[r.id] = true;
        this.fx.spawnRopeCut(r.x, r.y - r.length / 2);
        this.fx.spawnRing(r.x, r.y - r.length / 2, this.fxGold, 10, 90, 0.5);
        this.refreshGate(r.gateId);
      }
    }

    // --- 剑槽（攻击或剑气命中插入，永久开关联闸门） ---
    for (let i = 0; i < this.swordSlotsList.length; i++) {
      const slot = this.swordSlotsList[i];
      const key = "swordslot_" + slot.id;
      if (this.state.flags[key] === true) {
        continue; // 已插入，不重复触发
      }
      const sr: Rect = { x: slot.x - 26, y: slot.y, w: 52, h: 56 };
      let hit = false;
      if (attackRect !== undefined && rectOverlap(attackRect, sr)) {
        hit = true;
      }
      if (!hit) {
        for (let k = 0; k < qiRects.length; k++) {
          if (rectOverlap(qiRects[k], sr)) {
            hit = true;
            break;
          }
        }
      }
      if (hit) {
        // 插入状态记入 flags（渲染据此画插着的剑剪影）
        this.state.flags[key] = true;
        this.fx.spawnRing(slot.x, slot.y + 30, this.fxGold, 12, 80, 0.7);
        this.refreshGate(slot.gateId);
        if (this.events.onSwordInserted !== undefined) {
          this.events.onSwordInserted();
        }
      }
    }

    // --- 击钟（仅剑气可触发） ---
    for (let i = 0; i < this.bellsList.length; i++) {
      const b = this.bellsList[i];
      if (this.state.rungBells[b.id]) {
        continue;
      }
      const br = this.bellRect(b);
      for (let k = 0; k < qiRects.length; k++) {
        if (rectOverlap(qiRects[k], br)) {
          this.state.rungBells[b.id] = true;
          this.fx.spawnRing(b.x, b.y, this.fxCyan, 14, 130, 0.8);
          for (let s = 0; s < 10; s++) {
            this.fx.spawnStars(b.x, b.y, 2);
          }
          this.events.onBell(b.x, b.y);
          this.refreshGate(b.gateId);
          break;
        }
      }
    }

    // --- 压重石板 ---
    for (let i = 0; i < this.platesList.length; i++) {
      const p = this.platesList[i];
      if (this.state.platesActive[p.id]) {
        continue;
      }
      for (let k = 0; k < this.stones.length; k++) {
        const s = this.stones[k];
        const sr = this.stoneRect(s);
        const nearX = Math.abs(s.x - p.x) < 40;
        // 石底贴板判定：stoneRect 的 y 已是矩形底边（落地后=地面顶面），旧式再减半高恒差 22px 致压板永不触发
        const onTop = Math.abs(sr.y - p.y) < 8;
        if (nearX && onTop && s.onGround) {
          this.state.platesActive[p.id] = true;
          this.fx.spawnRing(p.x, p.y + 4, this.fxGold, 12, 70, 0.6);
          this.refreshGate(p.gateId);
          break;
        }
      }
    }
  }

  private fxGold = { r: 155, g: 113, b: 56, a: 255 };
  private fxCyan = { r: 168, g: 197, b: 188, a: 255 };
  private ropesList: RopeDef[] = [];
  private bellsList: BellDef[] = [];
  private platesList: PlateDef[] = [];
  private swordSlotsList: SwordSlotDef[] = [];
  // 点灯石持有数：拾取 lampstone 收集品时 +1，成功点亮一盏灯笼 -1
  public lampStoneCount = 0;
  // 双条件门（用户需求③⑤）：gateId → 需全部满足的机关条件（"kind:id"，id 段可 "a+b" 表任一）
  private gateReqs: Record<string, string[]> = {};

  bindLists(ropes: RopeDef[], bells: BellDef[], plates: PlateDef[]): void {
    this.ropesList = ropes;
    this.bellsList = bells;
    this.platesList = plates;
  }

  bindSwordSlots(slots: SwordSlotDef[]): void {
    this.swordSlotsList = slots;
  }

  // 绑定多条件门需求表（data/tower.gateRequirements）
  bindGateRequirements(reqs: Record<string, string[]>): void {
    this.gateReqs = reqs;
  }

  // 风息符文/星位列表（data/tower.windSigils / starNodes）
  private windSigils: WindSigilDef[] = [];
  private starNodes: StarNodeDef[] = [];

  bindWindSigils(list: WindSigilDef[]): void {
    this.windSigils = list;
  }

  bindStarNodes(list: StarNodeDef[]): void {
    this.starNodes = list;
  }

  // 单条机关旗标查询（kind ∈ bell/rope/plate/slot）
  private kindFlag(kind: string, id: string): boolean {
    if (kind === "bell") {
      return this.state.rungBells[id] === true;
    }
    if (kind === "rope") {
      return this.state.cutRopes[id] === true;
    }
    if (kind === "plate") {
      return this.state.platesActive[id] === true;
    }
    if (kind === "slot") {
      return this.state.flags["swordslot_" + id] === true;
    }
    if (kind === "wind") {
      return this.state.flags["wind_" + id] === true;
    }
    if (kind === "star") {
      return this.state.flags["star_" + id] === true;
    }
    return false;
  }

  // 单条需求是否满足："kind:id" 或 "kind:a+b"（任一即满足；不依赖字符串 split）
  private requirementMet(req: string): boolean {
    const sep = req.indexOf(":");
    if (sep < 0) {
      return false;
    }
    const kind = req.substring(0, sep);
    const ids = req.substring(sep + 1);
    const plus = ids.indexOf("+");
    const head = plus >= 0 ? ids.substring(0, plus) : ids;
    if (this.kindFlag(kind, head)) {
      return true;
    }
    if (plus >= 0 && this.kindFlag(kind, ids.substring(plus + 1))) {
      return true;
    }
    return false;
  }

  // 门条件是否齐备（不在需求表内的门恒视为齐备，保持旧的单条件开门行为）
  private gateSatisfied(gateId: string): boolean {
    const reqs = this.gateReqs[gateId];
    if (reqs === undefined) {
      return true;
    }
    for (let i = 0; i < reqs.length; i++) {
      if (!this.requirementMet(reqs[i])) {
        return false;
      }
    }
    return true;
  }

  // 机关完成统一经此开门：双条件门仅在条件齐备时开启，未齐备保持关闭
  private refreshGate(gateId: string): void {
    if (this.gateReqs[gateId] === undefined) {
      this.openGate(gateId);
      return;
    }
    if (this.state.openedGates[gateId] === true) {
      return;
    }
    if (this.gateSatisfied(gateId)) {
      this.openGate(gateId);
    }
  }

  // 拾取点灯石（game.ts 在收集 lampstone 时调用）
  public addLampStone(): void {
    this.lampStoneCount += 1;
  }

  // 冲刺穿过风息符文（F3）：|dx|<46 且 |dy|<90 内激活（走路不触发）；已亮的跳过不重复触发。
  // 每次穿越都幂等刷新门状态：回溯若重置了门，重穿符文即可重新开门，不会死锁。
  tryDashWindSigils(px: number, py: number): void {
    for (let i = 0; i < this.windSigils.length; i++) {
      const s = this.windSigils[i];
      if (Math.abs(s.x - px) >= 46 || Math.abs(s.y - py) >= 90) {
        continue;
      }
      if (this.state.flags["wind_" + s.id] !== true) {
        this.state.flags["wind_" + s.id] = true;
        this.fx.spawnRing(s.x, s.y + 40, this.fxCyan, 12, 78, 0.6);
        this.events.onWindSigil(s.id);
      }
      this.refreshGate(s.gateId);
    }
  }

  // E 键点亮星位（F5）：与提示气泡同口径——|dx|<110 且 |dy|<150 内可点（dy=|星位y-玩家y|，
  // 站台站立 dy≈41）。旧口径 |dx|+|dy|*0.5<60 实际只在约 40px 内生效，会出现「气泡已亮按 E 无效」。
  // 同箱内最近者优先；顺序=已亮星位数+1；错序清空全部星位重来。返回 true 表示 E 键已被星位交互消耗。
  tryLightStar(px: number, py: number): boolean {
    let nearest: StarNodeDef | undefined = undefined;
    let bestDist = 999999;
    for (let i = 0; i < this.starNodes.length; i++) {
      const s = this.starNodes[i];
      const dx = Math.abs(s.x - px);
      const dy = Math.abs(s.y - py);
      if (dx >= 110 || dy >= 150) {
        continue;
      }
      const d = dx + dy * 0.5;
      if (d < bestDist) {
        bestDist = d;
        nearest = s;
      }
    }
    if (nearest === undefined) {
      return false;
    }
    // 已亮星位：幂等刷新门（回溯重置门后可重新开门），不消耗按键
    if (this.state.flags["star_" + nearest.id] === true) {
      this.refreshGate(nearest.gateId);
      return false;
    }
    const expected = this.countLitStars() + 1;
    if (nearest.order === expected) {
      this.state.flags["star_" + nearest.id] = true;
      this.fx.spawnRing(nearest.x, nearest.y + 60, this.fxGold, 10, 66, 0.6);
      this.events.onStarLit(nearest.order);
      this.refreshGate(nearest.gateId);
      return true;
    }
    // 顺序错误：全部熄灭重来
    const ids = Object.keys(this.state.flags);
    for (let i = 0; i < ids.length; i++) {
      if (ids[i].indexOf("star_") === 0) {
        this.state.flags[ids[i]] = false;
      }
    }
    this.events.onStarFail();
    return true;
  }

  // 已点亮星位数（按 star_ 前缀旗标计数，不新增 LoopState 字段）
  private countLitStars(): number {
    let n = 0;
    const ids = Object.keys(this.state.flags);
    for (let i = 0; i < ids.length; i++) {
      if (ids[i].indexOf("star_") === 0 && this.state.flags[ids[i]] === true) {
        n += 1;
      }
    }
    return n;
  }

  // E 键点灯笼：按顺序点亮，错误则全部重置。判距与星位同口径：|dx|<110 且 |dy|<150
  // （旧口径 60 只在约 40px 生效，气泡 110 就亮——按 E 无效的体验修正 2026-10-27）
  tryLightLantern(lanterns: LanternDef[], px: number, py: number): boolean {
    let nearest: LanternDef | undefined = undefined;
    let bestDist = 999999;
    for (let i = 0; i < lanterns.length; i++) {
      const l = lanterns[i];
      const dx = Math.abs(l.x - px);
      const dy = Math.abs(l.y - py);
      if (dx >= 110 || dy >= 150) {
        continue;
      }
      const d = dx + dy * 0.5;
      if (d < bestDist) {
        bestDist = d;
        nearest = l;
      }
    }
    if (nearest === undefined) {
      return false;
    }
    if (this.state.lanternsLit[nearest.id]) {
      return false;
    }
    // 没有点灯石：不点亮也不打乱已有顺序，只发提示事件
    if (this.lampStoneCount <= 0) {
      if (this.events.onLanternNoStone !== undefined) {
        this.events.onLanternNoStone();
      }
      return false;
    }
    const expected = this.state.lanternSequence + 1;
    if (nearest.order === expected) {
      this.state.lanternsLit[nearest.id] = true;
      this.lampStoneCount -= 1;
      this.state.lanternSequence = expected;
      this.state.lanternFailed = false;
      this.fx.spawnRing(nearest.x, nearest.y + 14, this.fxCyan, 10, 60, 0.6);
      this.events.onLanternLit(nearest.order);
      if (expected >= lanterns.length) {
        this.openGate("lanternGate");
      }
      return true;
    }
    // 顺序错误（2026-10-26 整改）：仅拒绝本次，不再全熄重来——五灯跨图依序后，
    // 一处错点就清空全部进度的惩罚被误读为「新增的灯点不亮」；进度保留，反馈仍走 onLanternFail
    this.state.lanternFailed = true;
    this.events.onLanternFail();
    return false;
  }

  // 检查点自动激活
  touchCheckpoints(checkpoints: CheckpointDef[], px: number, py: number): void {
    for (let i = 0; i < checkpoints.length; i++) {
      const c = checkpoints[i];
      if (this.state.checkpointsActivated[c.id]) {
        continue;
      }
      const dx = Math.abs(c.x - px);
      const dy = Math.abs(c.y - py);
      if (dx < 52 && dy < 70) {
        this.state.checkpointsActivated[c.id] = true;
        this.state.currentCheckpointId = c.id;
        this.fx.spawnRing(c.x, c.y + 40, this.fxCyan, 14, 110, 0.9);
        this.events.onCheckpoint(c.id);
      }
    }
  }

  // 收集品拾取
  touchCollectibles(collectibles: CollectibleDef[], px: number, py: number): void {
    for (let i = 0; i < collectibles.length; i++) {
      const c = collectibles[i];
      if (this.state.collectedIds[c.id]) {
        continue;
      }
      if (c.loops !== undefined && c.loops.indexOf(this.state.loopIndex) < 0) {
        continue;
      }
      const dx = c.x - px;
      const dy = c.y - py;
      if (dx * dx + dy * dy < 38 * 38) {
        this.state.collectedIds[c.id] = true;
        if (c.kind === "moonstone") {
          this.state.moonstones = this.state.moonstones + 1;
        } else if (c.kind === "mechanism") {
          this.state.mechanismParts = this.state.mechanismParts + 1;
        } else if (c.kind === "token") {
          this.state.tokens = this.state.tokens + 1;
          // 信物 +2：对峙放剑低信任会进新周目（信任清零、对话不重播），
          // 双信物=4 恰好凑满 reunion 门槛，「回溯再试试」的承诺才真正可达
          this.state.shenyanTrust = this.state.shenyanTrust + 2;
        } else if (c.kind === "dew") {
          this.state.heroineLife = Math.min(this.state.maxLife, this.state.heroineLife + 1);
        }
        this.fx.spawnStars(c.x, c.y, 8);
        this.fx.spawnRing(c.x, c.y, c.kind === "moonstone" ? this.fxCyan : this.fxGold, 8, 80, 0.5);
        this.events.onCollect(c.kind, c.x, c.y);
      }
    }
  }
}
