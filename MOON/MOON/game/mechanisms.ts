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
} from "core/types";
import { BodyState, rectOverlap, moveAndCollide, clamp } from "game/physics";
import { EffectSystem } from "game/effects";

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
        // 推向石头且方向一致才移动
        const pushRight = playerRect.x + playerRect.w / 2 < s.x;
        if ((pushRight && playerPushDir > 0) || (!pushRight && playerPushDir < 0)) {
          s.vx = playerPushDir * 70;
        } else {
          s.vx = s.vx * 0.6;
        }
      } else {
        s.vx = s.vx * 0.6;
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
        this.openGate(r.gateId);
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
          this.openGate(b.gateId);
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
        const onTop = Math.abs(sr.y - sr.h / 2 - p.y) < 8;
        if (nearX && onTop && s.onGround) {
          this.state.platesActive[p.id] = true;
          this.fx.spawnRing(p.x, p.y + 4, this.fxGold, 12, 70, 0.6);
          this.openGate(p.gateId);
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

  bindLists(ropes: RopeDef[], bells: BellDef[], plates: PlateDef[]): void {
    this.ropesList = ropes;
    this.bellsList = bells;
    this.platesList = plates;
  }

  // E 键点灯笼：按顺序点亮，错误则全部重置
  tryLightLantern(lanterns: LanternDef[], px: number, py: number): boolean {
    let nearest: LanternDef | undefined = undefined;
    let bestDist = 60;
    for (let i = 0; i < lanterns.length; i++) {
      const l = lanterns[i];
      const d = Math.abs(l.x - px) + Math.abs(l.y - py) * 0.5;
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
      const expected = this.state.lanternSequence + 1;
      if (nearest.order === expected) {
        this.state.lanternsLit[nearest.id] = true;
        this.state.lanternSequence = expected;
        this.state.lanternFailed = false;
        this.fx.spawnRing(nearest.x, nearest.y + 14, this.fxCyan, 10, 60, 0.6);
        this.events.onLanternLit(nearest.order);
        if (expected >= lanterns.length) {
          // 灯笼接力完成：点亮观星灯，同时开启 2 层的两扇门（工坊门 + 灯门）
          this.openGate("lanternGate");
          this.openGate("gate_workshop");
        }
        return true;
      }
    // 顺序错误：全部熄灭重来
    const ids = Object.keys(this.state.lanternsLit);
    for (let i = 0; i < ids.length; i++) {
      this.state.lanternsLit[ids[i]] = false;
    }
    this.state.lanternSequence = 0;
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
          this.state.shenyanTrust = this.state.shenyanTrust + 1;
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
