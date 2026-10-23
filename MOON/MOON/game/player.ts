// game/player.ts — 衍月玩家控制器：移动状态机 + 战斗（三连击/剑气/闪身/蹬墙）
import { BodyState, MoveResult, moveAndCollide, ladderAt, climbWallAt, clamp, rectOverlap, updateGroundState } from "game/physics";
import { Platform, Ladder, ClimbWall, Rect } from "core/types";
import { sfx } from "game/audio";

export interface PlayerInput {
  left: boolean;
  right: boolean;
  up: boolean;
  down: boolean;
  jumpPressed: boolean;
  attackPressed: boolean;
  qiPressed: boolean;
  dashPressed: boolean;
}

export type PlayerAnim =
  | "idle"
  | "run"
  | "jump"
  | "fall"
  | "wallslide"
  | "dash"
  | "attack"
  | "hurt"
  | "climb"
  | "land";

export interface QiRequest {
  x: number;
  y: number;
  dir: number;
}

export interface PlayerCtx {
  platforms: Platform[];
  ladders: Ladder[];
  climbWalls: ClimbWall[];
}

export interface AttackInfo {
  hitbox: Rect;
  index: number; // 0/1/2 三连击段
  dir: number; // 1 右 -1 左
  damage: number;
  kb: number;
}

// 手感参数（对齐队友规范的角色尺寸 32x82）
export const PlayerTuning = {
  runSpeed: 320,
  accel: 2800,
  decel: 2400,
  airControl: 0.7,
  gravity: 2300,
  maxFall: 1150,
  wallSlideFall: 170,
  climbSpeed: 150,
  jumpV: 900,
  doubleJumpV: 820,
  wallJumpVx: 440,
  wallJumpVy: 900,
  wallJumpLock: 0.16,
  coyote: 0.1,
  jumpBuffer: 0.12,
  dashSpeed: 760,
  dashTime: 0.15,
  dashCd: 0.55,
  dashIFrame: 0.25,
  attackTime: [0.22, 0.22, 0.3],
  attackActiveFrom: [0.03, 0.03, 0.05],
  attackActiveTo: [0.14, 0.14, 0.2],
  attackChainWindow: 0.34,
  hurtStun: 0.32,
  hurtInvuln: 1.1,
  hurtKb: 300,
  hurtKbUp: 380,
};

export class Player {
  body: BodyState;
  facing: number;
  anim: PlayerAnim;
  animTime: number;
  attackIndex: number;
  attackTimer: number;
  attackQueued: boolean;
  dashTimer: number;
  dashCd: number;
  dashDir: number;
  invuln: number;
  stunTimer: number;
  freezeTimer: number;
  coyoteTimer: number;
  jumpBufTimer: number;
  lockTimer: number;
  clinging: boolean;
  wallDir: number;
  onLadder: boolean;
  ladderId: string;
  jumpCount: number;
  detachTimer: number;
  attack: AttackInfo | undefined;
  qiReq: QiRequest | undefined;
  landing: boolean;
  wallJustAttached: boolean;
  intentCost: number;

  constructor(x: number, y: number) {
    this.body = {
      x: x,
      y: y,
      vx: 0,
      vy: 0,
      w: 32,
      h: 82,
      onGround: true,
      groundId: "",
      onLadder: false,
    };
    this.facing = 1;
    this.anim = "idle";
    this.animTime = 0;
    this.attackIndex = 0;
    this.attackTimer = 0;
    this.attackQueued = false;
    this.dashTimer = 0;
    this.dashCd = 0;
    this.dashDir = 1;
    this.invuln = 0;
    this.stunTimer = 0;
    this.freezeTimer = 0;
    this.coyoteTimer = 0;
    this.jumpBufTimer = 0;
    this.lockTimer = 0;
    this.clinging = false;
    this.wallDir = 0;
    this.onLadder = false;
    this.ladderId = "";
    this.jumpCount = 0;
    this.detachTimer = 0;
    this.attack = undefined;
    this.qiReq = undefined;
    this.landing = false;
    this.wallJustAttached = false;
    this.intentCost = 1;
  }

  respawn(x: number, y: number): void {
    this.body.x = x;
    this.body.y = y;
    this.body.vx = 0;
    this.body.vy = 0;
    this.body.onGround = true;
    this.body.groundId = "";
    this.onLadder = false;
    this.clinging = false;
    this.dashTimer = 0;
    this.attackTimer = 0;
    this.attack = undefined;
    this.stunTimer = 0;
    this.freezeTimer = 0;
    this.invuln = 1.2;
    this.anim = "idle";
  }

  // 返回是否实际受伤（用于受击反馈）
  hurt(damage: number, fromX: number): boolean {
    if (this.invuln > 0 || this.dashTimer > 0 || this.stunTimer > 0) {
      return false;
    }
    const dir = this.body.x >= fromX ? 1 : -1;
    this.body.vx = dir * PlayerTuning.hurtKb;
    this.body.vy = PlayerTuning.hurtKbUp;
    this.stunTimer = PlayerTuning.hurtStun;
    this.invuln = PlayerTuning.hurtInvuln;
    this.clinging = false;
    this.onLadder = false;
    this.attackTimer = 0;
    this.attack = undefined;
    this.anim = "hurt";
    this.animTime = 0;
    return damage > 0;
  }

  // 是否处于无敌帧
  isInvulnerable(): boolean {
    return this.invuln > 0 || this.dashTimer > 0;
  }

  center(): { x: number; y: number } {
    return { x: this.body.x, y: this.body.y };
  }

  feetY(): number {
    return this.body.y - this.body.h / 2;
  }

  update(dt: number, input: PlayerInput, ctx: PlayerCtx): void {
    // 命中停顿
    if (this.freezeTimer > 0) {
      this.freezeTimer = this.freezeTimer - dt;
      this.attack = undefined;
      this.qiReq = undefined;
      return;
    }
    this.animTime = this.animTime + dt;
    if (this.invuln > 0) {
      this.invuln = this.invuln - dt;
    }
    if (this.dashCd > 0) {
      this.dashCd = this.dashCd - dt;
    }
    if (this.lockTimer > 0) {
      this.lockTimer = this.lockTimer - dt;
    }
    if (this.detachTimer > 0) {
      this.detachTimer = this.detachTimer - dt;
    }
    this.attack = undefined;
    this.qiReq = undefined;
    this.landing = false;
    this.wallJustAttached = false;

    const b = this.body;

    // 受击硬直
    if (this.stunTimer > 0) {
      this.stunTimer = this.stunTimer - dt;
      b.vy = clamp(b.vy - PlayerTuning.gravity * dt, -PlayerTuning.maxFall, PlayerTuning.maxFall);
      moveAndCollide(b, ctx.platforms, b.vx * dt, b.vy * dt, false);
      return;
    }

    // 攻击进行中
    if (this.attackTimer > 0) {
      this.updateAttack(dt, ctx);
    }

    // 梯子判定
    const ladder = ladderAt(b, ctx.ladders);
    const wantLadder = input.up || input.down;

    // --- 梯子 ---
    if (this.onLadder) {
      if (ladder === undefined) {
        this.onLadder = false;
      } else {
        b.vx = 0;
        b.vy = 0;
        let vy = 0;
        if (input.up) {
          vy = PlayerTuning.climbSpeed;
        } else if (input.down) {
          vy = -PlayerTuning.climbSpeed;
        }
        b.vy = vy;
        let vx = 0;
        if (input.left) {
          vx = -90;
        } else if (input.right) {
          vx = 90;
        }
        b.vx = vx;
        const res = moveAndCollide(b, ctx.platforms, vx * dt, vy * dt, false);
        this.anim = vy !== 0 || vx !== 0 ? "climb" : "climb";
        this.ladderId = ladder.id;
        if (input.jumpPressed || (res.landed && vy < 0)) {
          this.onLadder = false;
          if (input.jumpPressed) {
            b.vy = PlayerTuning.jumpV * 0.85;
            this.jumpCount = 1;
          }
        }
        if (this.attackTimer > 0) {
          this.onLadder = false;
        }
        if (input.dashPressed && this.dashCd <= 0) {
          this.onLadder = false;
          this.startDash();
        }
        return;
      }
    }

    if (!this.onLadder && ladder !== undefined && wantLadder && !this.clinging && this.dashTimer <= 0) {
      // 抓梯子
      this.onLadder = true;
      b.vx = 0;
      b.vy = 0;
      this.ladderId = ladder.id;
      this.jumpCount = 0;
      return;
    }

    // --- 闪身 ---
    if (input.dashPressed && this.dashCd <= 0 && this.dashTimer <= 0) {
      this.startDash();
    }

    // --- 跳跃缓冲 + 土狼时间 ---
    if (input.jumpPressed) {
      this.jumpBufTimer = PlayerTuning.jumpBuffer;
    }
    if (this.jumpBufTimer > 0) {
      this.jumpBufTimer = this.jumpBufTimer - dt;
    }
    if (b.onGround) {
      this.coyoteTimer = PlayerTuning.coyote;
      this.jumpCount = 0;
    } else if (this.coyoteTimer > 0) {
      this.coyoteTimer = this.coyoteTimer - dt;
    }

    // --- 蹬墙吸附 ---
    const dirInput = (input.left ? -1 : 0) + (input.right ? 1 : 0);
    const awayFromWall =
      (this.clinging && this.wallDir !== 0 && dirInput === -this.wallDir) ||
      (this.clinging && this.wallDir === 0);
    if (awayFromWall) {
      this.detachTimer = 0.12;
      this.clinging = false;
    }
    if (this.detachTimer <= 0 && this.dashTimer <= 0 && this.attackTimer <= 0) {
      if (!b.onGround && b.vy < 260 && !this.clinging && this.wallDir !== 0 && this.lockTimer <= 0) {
        const marker = climbWallAt(b, this.wallDir, ctx.climbWalls);
        if (marker !== undefined) {
          this.clinging = true;
          this.wallJustAttached = true;
          this.jumpCount = 0;
          b.vy = Math.min(b.vy, 0);
        }
      }
    }
    if (this.clinging && b.onGround) {
      this.clinging = false;
    }
    // 攀附墙面向墙
    if (this.clinging && this.wallDir !== 0) {
      this.facing = this.wallDir;
    }

    // --- 水平移动 ---
    let targetVx = 0;
    if (this.lockTimer <= 0 && this.dashTimer <= 0 && this.attackTimer <= 0) {
      targetVx = dirInput * PlayerTuning.runSpeed;
      if (dirInput !== 0 && this.attackTimer <= 0 && !this.clinging) {
        this.facing = dirInput;
      }
    }
    if (this.dashTimer > 0) {
      targetVx = this.dashDir * PlayerTuning.dashSpeed;
    }
    const control = b.onGround || this.clinging ? 1 : PlayerTuning.airControl;
    if (targetVx > b.vx) {
      b.vx = Math.min(targetVx, b.vx + PlayerTuning.accel * control * dt);
    } else if (targetVx < b.vx) {
      b.vx = Math.max(targetVx, b.vx - PlayerTuning.decel * control * dt);
    }

    // --- 垂直 ---
    if (this.dashTimer > 0) {
      this.dashTimer = this.dashTimer - dt;
      b.vy = 0;
    } else if (this.clinging) {
      let slide = true;
      if (input.up) {
        // 攀爬星轨墙
        b.vy = PlayerTuning.climbSpeed;
        slide = false;
      } else if (input.down) {
        b.vy = -PlayerTuning.climbSpeed * 1.4;
        slide = false;
      } else {
        b.vy = Math.max(b.vy - PlayerTuning.gravity * dt * 0.25, -PlayerTuning.wallSlideFall);
      }
      // 到达标记顶端则脱离
      const marker = climbWallAt(b, this.wallDir, ctx.climbWalls);
      if (marker === undefined && b.vy > 0) {
        this.clinging = false;
      }
      void slide;
    } else {
      b.vy = clamp(b.vy - PlayerTuning.gravity * dt, -PlayerTuning.maxFall, PlayerTuning.maxFall);
    }

    // --- 起跳 ---
    if (this.jumpBufTimer > 0 && this.dashTimer <= 0 && this.attackTimer <= 0) {
      if (this.clinging && this.wallDir !== 0) {
        // 蹬墙跳
        const away = -this.wallDir;
        b.vx = away * PlayerTuning.wallJumpVx;
        b.vy = PlayerTuning.wallJumpVy;
        this.facing = away;
        this.lockTimer = PlayerTuning.wallJumpLock;
        this.clinging = false;
        this.jumpBufTimer = 0;
        this.jumpCount = 1;
        this.wallJustAttached = false;
      } else if (b.onGround || this.coyoteTimer > 0) {
        b.vy = PlayerTuning.jumpV;
        b.onGround = false;
        this.coyoteTimer = 0;
        this.jumpBufTimer = 0;
        this.jumpCount = 1;
      } else if (this.jumpCount < 2) {
        b.vy = PlayerTuning.doubleJumpV;
        this.jumpCount = 2;
        this.jumpBufTimer = 0;
      }
    }

    // 下跳穿单向平台
    const dropThrough = input.down && input.jumpPressed;

    const wasAir = !b.onGround;
    const res: MoveResult = moveAndCollide(b, ctx.platforms, b.vx * dt, b.vy * dt, dropThrough);
    // 每帧刷新支撑状态：走出平台边缘立即失去支撑（防止空中连跳/带地面状态飞行）
    updateGroundState(b, ctx.platforms);
    if (res.hitWall) {
      this.wallDir = res.wallDir;
    } else if (b.onGround || this.clinging === false) {
      // 没有持续接触时逐步遗忘墙方向
      this.wallDir = 0;
    }
    if (res.landed) {
      this.landing = true;
      if (this.anim !== "land") {
        this.anim = "land";
        this.animTime = 0;
      }
    }

    // --- 攻击输入 ---
    if (input.attackPressed && this.dashTimer <= 0) {
      // 三连击链：攻击中按 J 排队下一击（attackChainCd 为遗留占位，恒可起手）
      if (this.attackTimer <= 0) {
        this.startAttack(0);
      } else {
        this.attackQueued = true;
      }
      if (this.clinging) {
        this.clinging = false;
      }
      this.onLadder = false;
    }

    // --- 剑气 ---
    if (input.qiPressed && this.dashTimer <= 0 && this.attackTimer <= 0) {
      this.qiReq = { x: b.x + this.facing * 20, y: b.y + 18, dir: this.facing };
    }

    // 动画状态
    if (this.attackTimer > 0) {
      this.anim = "attack";
    } else if (this.dashTimer > 0) {
      this.anim = "dash";
    } else if (this.clinging) {
      this.anim = "wallslide";
    } else if (!b.onGround) {
      this.anim = b.vy > 40 ? "jump" : "fall";
    } else if (this.stunTimer > 0) {
      this.anim = "hurt";
    } else if (this.anim === "land" && this.animTime < 0.14) {
      // 保持落地姿态
    } else if (Math.abs(b.vx) > 30) {
      this.anim = "run";
    } else {
      this.anim = "idle";
    }
    void wasAir;
  }

  private startDash(): void {
    sfx("dash", 0.5);
    this.dashTimer = PlayerTuning.dashTime;
    this.dashCd = PlayerTuning.dashCd;
    this.dashDir = this.facing;
    this.clinging = false;
    this.onLadder = false;
  }

  private startAttack(index: number): void {
    sfx("sword", 0.9);
    this.attackIndex = index;
    this.attackTimer = PlayerTuning.attackTime[index];
    this.anim = "attack";
    this.animTime = 0;
  }

  private updateAttack(dt: number, ctx: PlayerCtx): void {
    this.attackTimer = this.attackTimer - dt;
    const idx = this.attackIndex;
    const from = PlayerTuning.attackActiveFrom[idx];
    const to = PlayerTuning.attackActiveTo[idx];
    const elapsed = PlayerTuning.attackTime[idx] - this.attackTimer;
    if (elapsed >= from && elapsed <= to) {
      const reach = idx === 2 ? 70 : 60;
      const height = idx === 2 ? 64 : 54;
      this.attack = {
        hitbox: {
          x: this.facing > 0 ? this.body.x : this.body.x - reach,
          y: this.body.y - height / 2 + 6,
          w: reach,
          h: height,
        },
        index: idx,
        dir: this.facing,
        damage: idx === 2 ? 2 : 1,
        kb: idx === 2 ? 380 : 240,
      };
    }
    if (this.attackTimer <= 0) {
      if (this.attackQueued) {
        this.attackQueued = false;
        const next = (idx + 1) % 3;
        this.startAttack(next);
      }
    }
    void ctx;
  }

  // 攻击是否刚激活（用于命中停顿判断/音效时机）
  attackJustActivated(): boolean {
    return this.attack !== undefined && this.animTime >= PlayerTuning.attackActiveFrom[this.attackIndex];
  }

  overlapRect(r: Rect): boolean {
    return rectOverlap(
      { x: this.body.x - this.body.w / 2, y: this.body.y - this.body.h / 2, w: this.body.w, h: this.body.h },
      r
    );
  }
}
