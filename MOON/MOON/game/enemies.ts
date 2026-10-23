// game/enemies.ts — 敌人 AI：强盗（近战）、投掷者（远程）、头目（冲锋+震波）
import { BodyState, moveAndCollide, rectOverlap, clamp } from "game/physics";
import { EnemySpawn, Platform, Rect } from "core/types";
import { EffectSystem } from "game/effects";

export type EnemyFSM =
  | "patrol"
  | "chase"
  | "windup"
  | "swing"
  | "recover"
  | "hurt"
  | "telegraph"
  | "charge"
  | "throw"
  | "dead";

export interface EnemyState {
  def: EnemySpawn;
  body: BodyState;
  hp: number;
  maxHp: number;
  facing: number;
  state: EnemyFSM;
  timer: number;
  atkCd: number;
  throwCd: number;
  animTime: number;
  invuln: number;
  phase2: boolean;
  dead: boolean;
  deathTimer: number;
  hitThisSwing: boolean;
}

export interface EnemyHit {
  x: number;
  y: number;
  w: number;
  h: number;
  damage: number;
  kind: "slash" | "charge" | "wave";
}

export interface ThrownPot {
  x: number;
  y: number;
  vx: number;
  vy: number;
  alive: boolean;
  life: number;
}

export interface ShockWave {
  x: number;
  y: number;
  dir: number;
  life: number;
}

export interface EnemyCtx {
  platforms: Platform[];
}

export interface EnemyEvents {
  onPlayerHit: (damage: number, fromX: number) => void;
  onDeath: (def: EnemySpawn) => void;
  onPoof: (x: number, y: number) => void;
}

const GRAV = 2300;

export class EnemySystem {
  enemies: EnemyState[];
  pots: ThrownPot[];
  waves: ShockWave[];
  private hits: EnemyHit[];
  private fx: EffectSystem;
  private events: EnemyEvents;

  constructor(fx: EffectSystem, events: EnemyEvents) {
    this.enemies = [];
    this.pots = [];
    this.waves = [];
    this.hits = [];
    this.fx = fx;
    this.events = events;
  }

  spawnAll(defs: EnemySpawn[], loopIndex: number): void {
    this.enemies.length = 0;
    this.pots.length = 0;
    this.waves.length = 0;
    for (let i = 0; i < defs.length; i++) {
      const d = defs[i];
      if (d.loops !== undefined && d.loops.indexOf(loopIndex) < 0) {
        continue;
      }
      let w = 36;
      let h = 76;
      let hp = 3;
      if (d.kind === "thrower") {
        w = 34;
        h = 82;
        hp = 2;
      } else if (d.kind === "boss") {
        w = 52;
        h = 112;
        hp = 16;
      }
      this.enemies.push({
        def: d,
        body: {
          x: d.x,
          y: d.y + h / 2,
          vx: 0,
          vy: 0,
          w: w,
          h: h,
          onGround: false,
          groundId: "",
          onLadder: false,
        },
        hp: hp,
        maxHp: hp,
        facing: -1,
        state: "patrol",
        timer: 0,
        atkCd: 0,
        throwCd: 1.2,
        animTime: Math.random() * 6,
        invuln: 0,
        phase2: false,
        dead: false,
        deathTimer: 0,
        hitThisSwing: false,
      });
    }
  }

  aliveCount(): number {
    let n = 0;
    for (let i = 0; i < this.enemies.length; i++) {
      if (!this.enemies[i].dead) {
        n = n + 1;
      }
    }
    return n;
  }

  boss(): EnemyState | undefined {
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      if (e.def.kind === "boss" && !e.dead) {
        return e;
      }
    }
    return undefined;
  }

  enemyRect(e: EnemyState): Rect {
    return { x: e.body.x - e.body.w / 2, y: e.body.y - e.body.h / 2, w: e.body.w, h: e.body.h };
  }

  // 玩家攻击/剑气命中敌人，返回命中数（供命中停顿）
  takeHit(rect: Rect, damage: number, dir: number, kb: number): number {
    let hits = 0;
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      if (e.dead || e.invuln > 0) {
        continue;
      }
      if (!rectOverlap(this.enemyRect(e), rect)) {
        continue;
      }
      hits = hits + 1;
      e.hp = e.hp - damage;
      e.invuln = 0.18;
      e.body.vx = dir * kb * (e.def.kind === "boss" ? 0.3 : 1);
      this.fx.spawnInkBurst(e.body.x, e.body.y, dir);
      this.fx.spawnSpark(e.body.x + dir * -14, e.body.y + 10, dir);
      if (e.hp <= 0) {
        e.dead = true;
        e.state = "dead";
        e.deathTimer = 0.55;
        this.fx.spawnMist(e.body.x, e.body.y - 20, e.def.kind === "boss" ? 22 : 12, e.def.kind === "boss" ? 1.6 : 1);
        this.events.onDeath(e.def);
      } else if (e.state !== "charge") {
        e.state = "hurt";
        e.timer = 0.24;
      }
      if (e.def.kind === "boss") {
        e.phase2 = e.hp <= e.maxHp / 2;
      }
    }
    return hits;
  }

  consumeHits(): EnemyHit[] {
    const out = this.hits;
    this.hits = [];
    return out;
  }

  private groundAhead(e: EnemyState, ctx: EnemyCtx): boolean {
    const probe: Rect = {
      x: e.body.x + e.facing * (e.body.w / 2 + 4) - 6,
      y: e.body.y - e.body.h / 2 - 12,
      w: 12,
      h: 14,
    };
    for (let i = 0; i < ctx.platforms.length; i++) {
      const p = ctx.platforms[i];
      if (p.kind === "one-way") {
        continue;
      }
      if (rectOverlap(probe, p)) {
        return true;
      }
    }
    return false;
  }

  private moveEnemy(e: EnemyState, ctx: EnemyCtx, dt: number): boolean {
    e.body.vy = clamp(e.body.vy - GRAV * dt, -1150, 1150);
    const res = moveAndCollide(e.body, ctx.platforms, e.body.vx * dt, e.body.vy * dt, false);
    return res.hitWall;
  }

  update(dt: number, px: number, py: number, playerRect: Rect, playerInvuln: boolean, ctx: EnemyCtx): void {
    // 命中检测过期的伤害盒直接清空
    this.hits.length = 0;
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      e.animTime = e.animTime + dt;
      if (e.invuln > 0) {
        e.invuln = e.invuln - dt;
      }
      if (e.dead) {
        e.deathTimer = e.deathTimer - dt;
        continue;
      }
      if (e.atkCd > 0) {
        e.atkCd = e.atkCd - dt;
      }
      const dx = px - e.body.x;
      const dy = py - e.body.y;
      const adx = Math.abs(dx);

      switch (e.state) {
        case "patrol": {
          e.body.vx = e.facing * (e.def.kind === "thrower" ? 62 : 88);
          if (!this.groundAhead(e, ctx) || this.moveEnemy(e, ctx, dt)) {
            e.facing = -e.facing;
            e.body.vx = e.facing * 88;
          }
          if (adx < 330 && Math.abs(dy) < 150) {
            e.state = "chase";
          }
          break;
        }
        case "chase": {
          e.facing = dx > 0 ? 1 : -1;
          const spd = e.def.kind === "boss" ? 150 : 148;
          if (e.def.kind === "thrower") {
            // 远程：保持距离
            if (adx < 190) {
              e.body.vx = -e.facing * 110;
            } else {
              e.body.vx = 0;
            }
            e.throwCd = e.throwCd - dt;
            if (e.throwCd <= 0 && adx < 430 && Math.abs(dy) < 190) {
              e.state = "throw";
              e.timer = 0.4;
            }
          } else {
            e.body.vx = e.facing * spd;
            if (!this.groundAhead(e, ctx) && e.body.onGround) {
              e.body.vx = 0;
            }
            const range = e.def.kind === "boss" ? 96 : 58;
            if (adx < range && Math.abs(dy) < 90 && e.atkCd <= 0) {
              e.state = "windup";
              e.timer = e.def.kind === "boss" ? (e.phase2 ? 0.42 : 0.55) : 0.45;
              e.hitThisSwing = false;
            }
            if (e.def.kind === "boss" && e.atkCd <= 0 && adx > 280 && adx < 620) {
              e.state = "telegraph";
              e.timer = e.phase2 ? 0.38 : 0.5;
            }
          }
          if (adx > 560 || Math.abs(dy) > 260) {
            e.state = "patrol";
          }
          this.moveEnemy(e, ctx, dt);
          break;
        }
        case "windup": {
          e.body.vx = 0;
          e.facing = dx > 0 ? 1 : -1;
          e.timer = e.timer - dt;
          this.moveEnemy(e, ctx, dt);
          if (e.timer <= 0) {
            e.state = "swing";
            e.timer = 0.16;
            const reach = e.def.kind === "boss" ? 92 : 56;
            const hh = e.def.kind === "boss" ? 78 : 50;
            this.hits.push({
              x: e.facing > 0 ? e.body.x : e.body.x - reach,
              y: e.body.y - hh / 2,
              w: reach,
              h: hh,
              damage: e.def.kind === "boss" ? 2 : 1,
              kind: "slash",
            });
            this.fx.spawnInkBurst(e.body.x + e.facing * reach * 0.6, e.body.y + 6, e.facing);
          }
          break;
        }
        case "swing": {
          e.body.vx = e.facing * 40;
          e.timer = e.timer - dt;
          this.moveEnemy(e, ctx, dt);
          if (e.timer <= 0) {
            if (e.def.kind === "boss") {
              // 头目挥砍产生沿地面行进的剑气震波
              this.waves.push({ x: e.body.x + e.facing * 50, y: e.body.y - e.body.h / 2 + 20, dir: e.facing, life: 1.5 });
              e.atkCd = e.phase2 ? 0.9 : 1.4;
            } else {
              e.atkCd = 0.85;
            }
            e.state = "recover";
            e.timer = e.def.kind === "boss" ? 0.3 : 0.42;
          }
          break;
        }
        case "recover": {
          e.body.vx = 0;
          e.timer = e.timer - dt;
          this.moveEnemy(e, ctx, dt);
          if (e.timer <= 0) {
            e.state = "chase";
          }
          break;
        }
        case "telegraph": {
          e.body.vx = 0;
          e.facing = dx > 0 ? 1 : -1;
          e.timer = e.timer - dt;
          this.moveEnemy(e, ctx, dt);
          if (e.timer <= 0) {
            e.state = "charge";
            e.timer = 0.7;
            e.hitThisSwing = false;
          }
          break;
        }
        case "charge": {
          e.body.vx = e.facing * (e.phase2 ? 520 : 460);
          e.timer = e.timer - dt;
          const blocked = this.moveEnemy(e, ctx, dt);
          if (blocked) {
            e.timer = 0;
            this.fx.spawnDust(e.body.x, e.body.y - e.body.h / 2, -e.facing);
          }
          if (!e.hitThisSwing && rectOverlap(this.enemyRect(e), playerRect)) {
            e.hitThisSwing = true;
            if (!playerInvuln) {
              this.events.onPlayerHit(1, e.body.x);
            }
          }
          if (e.timer <= 0) {
            e.body.vx = 0;
            e.atkCd = e.phase2 ? 1.1 : 1.8;
            e.state = "recover";
            e.timer = 0.4;
          }
          break;
        }
        case "throw": {
          e.body.vx = 0;
          e.facing = dx > 0 ? 1 : -1;
          e.timer = e.timer - dt;
          this.moveEnemy(e, ctx, dt);
          if (e.timer <= 0) {
            const t = 0.85;
            const vx = (px - e.body.x) / t;
            const vy = (py - e.body.y + 0.5 * 1400 * t * t) / t;
            this.pots.push({ x: e.body.x + e.facing * 18, y: e.body.y + 20, vx: vx, vy: vy, alive: true, life: 3 });
            e.throwCd = 2.1 + Math.random() * 0.8;
            e.state = "recover";
            e.timer = 0.5;
          }
          break;
        }
        case "hurt": {
          e.timer = e.timer - dt;
          this.moveEnemy(e, ctx, dt);
          if (e.timer <= 0) {
            e.state = "chase";
          }
          break;
        }
        default:
          break;
      }
    }

    // 投掷物
    for (let i = 0; i < this.pots.length; i++) {
      const p = this.pots[i];
      if (!p.alive) {
        continue;
      }
      p.life = p.life - dt;
      p.vy = p.vy - 1400 * dt;
      p.x = p.x + p.vx * dt;
      p.y = p.y + p.vy * dt;
      const pr: Rect = { x: p.x - 8, y: p.y - 8, w: 16, h: 16 };
      let hitPlat = false;
      for (let k = 0; k < ctx.platforms.length; k++) {
        const plat = ctx.platforms[k];
        if (plat.kind === "one-way") {
          continue;
        }
        if (rectOverlap(pr, plat)) {
          hitPlat = true;
          break;
        }
      }
      if (hitPlat || p.life <= 0) {
        p.alive = false;
        this.fx.spawnInkBurst(p.x, p.y, p.vx > 0 ? 1 : -1);
        this.events.onPoof(p.x, p.y);
        continue;
      }
      if (rectOverlap(pr, playerRect) && !playerInvuln) {
        p.alive = false;
        this.events.onPlayerHit(1, p.x);
      }
    }
    // 清理死投掷物
    let w = 0;
    for (let i = 0; i < this.pots.length; i++) {
      if (this.pots[i].alive) {
        this.pots[w] = this.pots[i];
        w = w + 1;
      }
    }
    this.pots.length = w;

    // 头目震波
    for (let i = 0; i < this.waves.length; i++) {
      const wv = this.waves[i];
      wv.life = wv.life - dt;
      wv.x = wv.x + wv.dir * 270 * dt;
      const wr: Rect = { x: wv.x - 14, y: wv.y - 18, w: 28, h: 40 };
      if (rectOverlap(wr, playerRect) && !playerInvuln) {
        this.events.onPlayerHit(1, wv.x);
        wv.life = 0;
      }
    }
    let wv2 = 0;
    for (let i = 0; i < this.waves.length; i++) {
      if (this.waves[i].life > 0) {
        this.waves[wv2] = this.waves[i];
        wv2 = wv2 + 1;
      }
    }
    this.waves.length = wv2;

    // 近战挥砍命中玩家（伤害盒在本帧内检测一次）
    for (let i = 0; i < this.hits.length; i++) {
      const h = this.hits[i];
      if (rectOverlap(h, playerRect) && !playerInvuln) {
        this.events.onPlayerHit(h.damage, h.x + h.w / 2);
      }
    }
  }
}
