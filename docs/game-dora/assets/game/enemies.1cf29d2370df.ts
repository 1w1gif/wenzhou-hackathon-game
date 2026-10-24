// game/enemies.ts — 敌人 AI：强盗（近战）、投掷者（远程）、头目（冲锋+震波）
import { BodyState, moveAndCollide, rectOverlap, clamp } from "game/physics";
import { EnemySpawn, Platform, Rect } from "core/types";
import { EffectSystem } from "game/effects";
import { TOPS, WORLD_W } from "data/tower";

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
  // 潜行警戒后的巡逻带（默认等于出生带；仅 StealthSystem 接线后会被 setAlert 偏移）
  patrolMinCur: number;
  patrolMaxCur: number;
  // 巡逻防卡死看门狗：窗口累计时长与窗口起点 x
  stuckT: number;
  stuckX: number;
}

// 潜行系统只读快照（enemies.stealthInfos() → StealthSystem 每帧消费）
export interface EnemyStealthInfo {
  index: number;
  id: string;
  kind: string;
  floor: number;
  x: number;
  y: number;
  w: number;
  h: number;
  facing: number;
  state: EnemyFSM;
  patrolMin: number;
  patrolMax: number;
  basePatrolMin: number;
  basePatrolMax: number;
  dead: boolean;
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

// 弓手箭矢：直线弹道（锁定出手瞬间方向），撞实体板消失，命中玩家 1 伤
export interface Arrow {
  x: number;
  y: number;
  vx: number;
  vy: number;
  alive: boolean;
  life: number;
}

export interface EnemyCtx {
  platforms: Platform[];
}

export interface EnemyEvents {
  onPlayerHit: (damage: number, fromX: number) => void;
  onDeath: (def: EnemySpawn, x: number, y: number) => void;
  onPoof: (x: number, y: number) => void;
}

const GRAV = 2300;

export class EnemySystem {
  enemies: EnemyState[];
  pots: ThrownPot[];
  waves: ShockWave[];
  arrows: Arrow[];
  private hits: EnemyHit[];
  private fx: EffectSystem;
  private events: EnemyEvents;
  // 潜行接线标志（默认 false = 行为与旧版完全一致）：
  // stealthDriven=true 时巡逻近距离自动索敌关闭，发现/听觉由 StealthSystem 驱动；
  // backstabEnabled=true 时 takeHit 支持背刺一击必杀（需调用方传 attackerX）
  private stealthDriven = false;
  private backstabEnabled = false;

  constructor(fx: EffectSystem, events: EnemyEvents) {
    this.enemies = [];
    this.pots = [];
    this.waves = [];
    this.arrows = [];
    this.hits = [];
    this.fx = fx;
    this.events = events;
  }

  spawnAll(defs: EnemySpawn[], loopIndex: number): void {
    this.enemies.length = 0;
    this.pots.length = 0;
    this.waves.length = 0;
    this.arrows.length = 0;
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
      } else if (d.kind === "archer") {
        // 弓手C（1F 屋顶露台）：与投掷者同体型，低血量，固定站位
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
          // 站立出生：中心 = 层地面顶边 + 半高，脚底恰好贴 TOPS。
          // 禁止写 -h/2：那会把身体嵌进地板板体内，首帧 moveX 先于 moveY 执行，
          // 会把重叠的身体整体横推出板外（x≈-18 或 6418），moveY 从此接不住——
          // 全部敌人开局数秒内掉出世界（"盗贼怪物都消失"实锤根因，无头探针已复现）
          y: d.kind === "archer" ? d.y : TOPS[d.floor] + h / 2,
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
        facing: d.face !== undefined ? d.face : -1,
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
        patrolMinCur: d.patrolMin,
        patrolMaxCur: d.patrolMax,
        stuckT: 0,
        stuckX: d.x,
      });
    }
  }

  // 潜行接线开关：StealthSystem 构造/attachTo 时调用，打开潜行门控与背刺判定；
  // 传 false 则完全恢复旧版行为（近距离自动索敌 + 背刺失效）
  setStealthWired(on: boolean): void {
    this.stealthDriven = on;
    this.backstabEnabled = on;
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

  // 玩家攻击/剑气命中敌人，返回命中数（供命中停顿）。
  // attackerX（可选）：攻击瞬间玩家中心 x（近战盒贴近玩家一侧的 rect.x/rect.x+w）。
  // 仅接线潜行且 backstabEnabled 时用于背刺判定，不传则与旧版完全一致。
  takeHit(rect: Rect, damage: number, dir: number, kb: number, attackerX?: number): number {
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
      let dmg = damage;
      // 背刺：接线潜行后，攻击瞬间玩家位于敌人面向的反方向侧且水平距离 <55px → 一击必杀。
      // 复用现有死亡流程（spawnMist + onDeath），boss 免疫背刺
      if (attackerX !== undefined && this.backstabEnabled && e.def.kind !== "boss") {
        const behind = (e.facing > 0 && attackerX < e.body.x) || (e.facing < 0 && attackerX > e.body.x);
        if (behind && Math.abs(attackerX - e.body.x) < 55) {
          dmg = e.hp;
          this.fx.spawnInkBurst(e.body.x, e.body.y + 26, dir);
        }
      }
      e.hp = e.hp - dmg;
      e.invuln = 0.18;
      e.body.vx = dir * kb * (e.def.kind === "boss" ? 0.3 : 1);
      this.fx.spawnInkBurst(e.body.x, e.body.y, dir);
      this.fx.spawnSpark(e.body.x + dir * -14, e.body.y + 10, dir);
      if (e.hp <= 0) {
        e.dead = true;
        e.state = "dead";
        e.deathTimer = 0.55;
        this.fx.spawnMist(e.body.x, e.body.y - 20, e.def.kind === "boss" ? 22 : 12, e.def.kind === "boss" ? 1.6 : 1);
        this.events.onDeath(e.def, e.body.x, e.body.y);
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

  // ---- 潜行增量接口（只读快照 + 最小咬合点）----
  // 未接线时以下方法不被任何调用方触碰，巡逻/索敌与旧版一致
  stealthInfos(): EnemyStealthInfo[] {
    const out: EnemyStealthInfo[] = [];
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      out.push({
        index: i,
        id: e.def.id,
        kind: e.def.kind,
        floor: e.def.floor,
        x: e.body.x,
        y: e.body.y,
        w: e.body.w,
        h: e.body.h,
        facing: e.facing,
        state: e.state,
        patrolMin: e.patrolMinCur,
        patrolMax: e.patrolMaxCur,
        basePatrolMin: e.def.patrolMin,
        basePatrolMax: e.def.patrolMax,
        dead: e.dead,
      });
    }
    return out;
  }

  // 发现咬合点：强制从巡逻进入追击，并把巡逻带中心向最后发现位置偏移一半（警戒提高，带宽不变）
  setAlert(index: number, lastSeenX: number): void {
    const e = this.enemies[index];
    if (e.dead) {
      return;
    }
    const min = e.def.patrolMin;
    const max = e.def.patrolMax;
    const width = max - min;
    const center = (min + max) / 2;
    const nc = center + (lastSeenX - center) * 0.5;
    const nMin = Math.max(min, Math.min(nc - width / 2, max - width));
    e.patrolMinCur = nMin;
    e.patrolMaxCur = nMin + width;
    if (e.state === "patrol") {
      e.state = "chase";
    }
  }

  // 脱离视线咬合点：回到巡逻（保留已偏移的警戒带）；蓄力/挥砍/受击等战斗态不打断
  setCalm(index: number): void {
    const e = this.enemies[index];
    if (e.dead) {
      return;
    }
    if (e.state === "chase") {
      e.state = "patrol";
      e.body.vx = 0;
    }
  }

  // 听觉咬合点：被声源吸引转向（仅巡逻态生效，不打断战斗）
  faceToward(index: number, targetX: number): void {
    const e = this.enemies[index];
    if (e.dead || e.state !== "patrol") {
      return;
    }
    e.facing = targetX >= e.body.x ? 1 : -1;
  }

  // 整改一·酒桶砸晕：同层半径内敌人进入较长受击硬直（创造潜行窗口）；头目免疫。
  // 晕眩结束后的去向由 hurt 出口决定（接线潜行 → 回巡逻）。
  stunNear(x: number, floor: number, radius: number, seconds: number): number {
    let n = 0;
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      if (e.dead || e.def.floor !== floor || e.def.kind === "boss") {
        continue;
      }
      if (Math.abs(e.body.x - x) > radius) {
        continue;
      }
      e.state = "hurt";
      e.timer = Math.max(e.timer, seconds);
      e.body.vx = 0;
      e.atkCd = Math.max(e.atkCd, 1);
      n = n + 1;
    }
    return n;
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
    // 世界边界钳制：击退/冲锋不许把敌人推到 x<0 或 x>6400 的板外（出去即永坠）
    const half = e.body.w / 2 + 4;
    if (e.body.x < half) {
      e.body.x = half;
    } else if (e.body.x > WORLD_W - half) {
      e.body.x = WORLD_W - half;
    }
    // 坠落救援兜底：脚底低于本层地面 300px 视为异常离层（正常巡逻/追击不该发生），
    // 回出生点重置为巡逻态，杜绝任何路径导致的"敌人凭空消失"。
    // 弓手驻守屋顶露台（脚底远高于地面），不适用地面坠落救援，被击落露台后就地站桩继续射箭
    if (e.def.kind !== "archer" && e.body.y - e.body.h / 2 < TOPS[e.def.floor] - 300) {
      e.body.x = e.def.x;
      e.body.y = TOPS[e.def.floor] + e.body.h / 2;
      e.body.vx = 0;
      e.body.vy = 0;
      e.body.onGround = true;
      e.state = "patrol";
    }
    return res.hitWall;
  }

  update(dt: number, px: number, py: number, playerRect: Rect, playerInvuln: boolean, ctx: EnemyCtx, playerVy?: number): void {
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
      // 防卡死看门狗窗口：仅巡逻态计时，离开巡逻即重置（回到巡逻从当前位置重新计时）
      if (e.state !== "patrol") {
        e.stuckT = 0;
        e.stuckX = e.body.x;
      }
      const dx = px - e.body.x;
      const dy = py - e.body.y;
      const adx = Math.abs(dx);
      // 垂直脱战判定：玩家已落地站定（|vy| 足够小）且脚底比敌人脚底高 110px 以上
      // → 站在敌人够不着的层内平台上（one-way 平台顶普遍高出地面 120~180px），
      // 敌人放弃目标回巡逻（用户设计：跳上另一高度，下面的怪物就找不到你）；
      // 跳跃途中 |vy| 大，不会误判成站定
      const elevatedGround = playerVy !== undefined
        && Math.abs(playerVy) < 25
        && (playerRect.y - (e.body.y - e.body.h / 2)) > 110;

      switch (e.state) {
        case "patrol": {
          // 弓手改为可移动（用户反馈）：非索敌时沿 patrolMin/patrolMax 贴地来回巡逻；
          // 索敌（横向 460 / 垂直 620 内）时风筝走位——太远贴近、太近后撤、中距离站定放箭，
          // 走位全程受巡逻拴绳与边缘翻转约束，不会走下露台。holdPosition 对弓手不再生效。
          if (e.def.kind === "archer") {
            const inSight = !elevatedGround && adx < 460 && Math.abs(dy) < 620;
            const pspd = 62;
            let vx = 0;
            if (inSight) {
              e.facing = dx > 0 ? 1 : -1;
              if (adx > 380) {
                vx = e.facing * pspd; // 太远：贴地走向玩家
              } else if (adx < 150) {
                vx = -e.facing * pspd; // 太近：后撤拉开距离
              }
            } else if (e.patrolMaxCur > e.patrolMinCur) {
              if (e.body.x < e.patrolMinCur) {
                e.facing = 1;
              } else if (e.body.x > e.patrolMaxCur) {
                e.facing = -1;
              }
              vx = e.facing * pspd;
            }
            e.body.vx = vx;
            const blocked = this.moveEnemy(e, ctx, dt);
            if (vx !== 0 && e.body.vy > -0.5 && (!this.groundAhead(e, ctx) || blocked)) {
              e.facing = -e.facing;
              e.body.vx = e.facing * pspd;
            }
            if (inSight && e.atkCd <= 0 && adx >= 150 && adx <= 420) {
              e.state = "telegraph";
              e.timer = 0.6;
            }
            break;
          }
          // 站桩敌（1F 教学敌：匪兵A 静止站路中央 / 弓手C 固定露台）：不巡逻，原地站桩。
          // 弓手：玩家进入射界即抬手（0.6s 前摇可打断/可闪避），玩家占高处则不射（垂直脱战）
          if (e.def.holdPosition === true) {
            e.body.vx = 0;
            this.moveEnemy(e, ctx, dt);
            if (!elevatedGround && !this.stealthDriven && adx < 330 && Math.abs(dy) < 150) {
              e.state = "chase";
            }
            break;
          }
          const pspd = e.def.kind === "thrower" ? 62 : 88;
          // 巡逻拴绳（patrolMin/patrolMax）：S1 后每层是一整条全宽地板，没有天然边界，
          // 不拴住的话敌人会朝一个方向直走到底、掉出世界边缘——“怪物不动/变少”的根因
          if (e.body.x < e.patrolMinCur) {
            e.facing = 1;
          } else if (e.body.x > e.patrolMaxCur) {
            e.facing = -1;
          }
          e.body.vx = e.facing * pspd;
          // 常驻移动+重力：moveEnemy 每帧必须执行（原先藏在短路条件里，离地时被跳过→悬浮）
          const blocked = this.moveEnemy(e, ctx, dt);
          // 边缘翻转只在落地（moveEnemy 后 vy 归零）时判定；空中保持当前 facing 直到落地
          if (e.body.vy > -0.5 && (!this.groundAhead(e, ctx) || blocked)) {
            e.facing = -e.facing;
            e.body.vx = e.facing * pspd;
          }
          // 近距离自动索敌：接线潜行后由视野锥/贴身感知接管（90px 内仍会被察觉），
          // 未接线时保持旧版 330px 行为完全不变；
          // Boss 不参与潜行系统：保持旧版见人（330px）即追砍，无视野锥无潜行博弈
          // 玩家站上够不着的高台时不触发（否则刚追两步又被垂直脱战打断，反复横跳）
          if (!elevatedGround && (!this.stealthDriven || e.def.kind === "boss") && adx < 330 && Math.abs(dy) < 150) {
            e.state = "chase";
          }
          // 防卡死看门狗：巡逻 1.2s 净位移 <10px（异常停滞）→ 强制换向重试
          e.stuckT = e.stuckT + dt;
          if (e.stuckT > 1.2) {
            if (Math.abs(e.body.x - e.stuckX) < 10) {
              e.facing = -e.facing;
            }
            e.stuckT = 0;
            e.stuckX = e.body.x;
          }
          break;
        }
        case "chase": {
          e.facing = dx > 0 ? 1 : -1;
          // 弓手被潜行系统警觉时也不移动：原地站桩放箭（同 patrol 射击条件）
          if (e.def.kind === "archer") {
            e.body.vx = 0;
            if (!elevatedGround && e.atkCd <= 0 && adx < 460 && Math.abs(dy) < 620) {
              e.state = "telegraph";
              e.timer = 0.6;
            }
            if (adx > 560 || Math.abs(dy) > 620 || elevatedGround) {
              e.state = "patrol";
            }
            this.moveEnemy(e, ctx, dt);
            break;
          }
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
            if (adx < 14) {
              // 死区：目标几乎在正上方时停止横移，消除过冲导致的左右抖动
              e.body.vx = 0;
            } else {
              e.body.vx = e.facing * spd;
            }
            if (!this.groundAhead(e, ctx) && e.body.onGround) {
              e.body.vx = 0;
            }
            // 突进敌（1F eB 匪兵B）：中距离先蓄力（telegraph 抬手可见）再直线冲撞——教完美闪避
            if (
              e.def.lunge === true
              && e.atkCd <= 0
              && adx > 120
              && adx < 420
              && Math.abs(dy) < 120
            ) {
              e.state = "telegraph";
              e.timer = 0.42;
              e.hitThisSwing = false;
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
          if (adx > 560 || Math.abs(dy) > 260 || elevatedGround) {
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
              damage: e.def.kind === "boss" ? 1.5 : 1,
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
            if (e.def.kind === "archer") {
              // 放箭：前摇期间持续修正朝向，出手瞬间锁定玩家中心——前摇内横移/翻滚即闪开
              const sp = 520;
              const tx = px - e.body.x;
              const ty = py + 12 - e.body.y;
              const lenRaw = Math.sqrt(tx * tx + ty * ty);
              const len = lenRaw > 0.0001 ? lenRaw : 1;
              this.arrows.push({
                x: e.body.x + e.facing * 18,
                y: e.body.y + 26,
                vx: (tx / len) * sp,
                vy: (ty / len) * sp,
                alive: true,
                life: 2.2,
              });
              e.atkCd = 1.7;
              e.state = "recover";
              e.timer = 0.36;
            } else {
              e.state = "charge";
              e.timer = 0.7;
              e.hitThisSwing = false;
            }
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
            // 旧版：受击后直接咬死玩家（追击）。接线潜行后：回到巡逻，由视野锥重新判定——
            // 酒桶砸晕等硬直结束后不会凭空获得玩家位置信息。
            e.state = this.stealthDriven ? "patrol" : "chase";
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

    // 弓手箭矢：直线弹道、撞实体板消失（one-way 檐板不挡箭），命中玩家 1 伤
    for (let i = 0; i < this.arrows.length; i++) {
      const ar = this.arrows[i];
      if (!ar.alive) {
        continue;
      }
      ar.life = ar.life - dt;
      ar.x = ar.x + ar.vx * dt;
      ar.y = ar.y + ar.vy * dt;
      const arr: Rect = { x: ar.x - 10, y: ar.y - 3, w: 20, h: 6 };
      let hitPlat2 = false;
      for (let k = 0; k < ctx.platforms.length; k++) {
        const plat2 = ctx.platforms[k];
        if (plat2.kind === "one-way") {
          continue;
        }
        if (rectOverlap(arr, plat2)) {
          hitPlat2 = true;
          break;
        }
      }
      if (hitPlat2 || ar.life <= 0) {
        ar.alive = false;
        this.fx.spawnSpark(ar.x, ar.y, ar.vx > 0 ? 1 : -1);
        continue;
      }
      if (rectOverlap(arr, playerRect) && !playerInvuln) {
        ar.alive = false;
        this.events.onPlayerHit(1, ar.x);
      }
    }
    let an = 0;
    for (let i = 0; i < this.arrows.length; i++) {
      if (this.arrows[i].alive) {
        this.arrows[an] = this.arrows[i];
        an = an + 1;
      }
    }
    this.arrows.length = an;

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
