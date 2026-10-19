/**
 * 玩家控制器：衍月（女侠）。
 * 手感要点：
 *  - 移动加速/减速、土狼时间、跳跃缓冲
 *  - 可变跳跃高度（松开 Space 截断上升）
 *  - 二段跳（淡墨月轮特效）
 *  - 碰墙自动吸附（不需要按键），缓慢下滑，体力限制
 *  - Space 蹬墙跳
 *  - S 快速滑降
 *  - 三段连击 / 剑气 / 闪身（无敌帧）
 */
import Phaser from 'phaser';
import { store } from '../core/GameStore';

export class PlayerController {
  sprite: Phaser.Physics.Arcade.Sprite;
  private scene: Phaser.Scene;
  private keys: Record<string, Phaser.Input.Keyboard.Key>;

  // 移动手感
  private readonly SPEED = 340;
  private readonly ACCEL = 2600;
  private readonly DECEL = 3200;
  private readonly JUMP_VEL = 700;
  private readonly DOUBLE_JUMP_VEL = 640;
  private readonly GRAVITY = 1900;
  private readonly MAX_FALL = 1250;
  private readonly COYOTE_MS = 110;
  private readonly BUFFER_MS = 120;

  // 攀墙
  private readonly WALL_SLIDE = 90;
  private readonly WALL_JUMP_X = 420;
  private readonly WALL_JUMP_Y = 660;
  private readonly CLIMB_UP = 150;
  private readonly STAMINA_MAX = 100;
  private readonly STAMINA_DRAIN = 34;   // 每秒
  private readonly STAMINA_REGEN = 42;   // 每秒（离墙）
  private stamina = this.STAMINA_MAX;

  // 闪身
  private readonly DASH_SPEED = 860;
  private readonly DASH_MS = 150;
  private readonly DASH_CD = 550;
  private dashUntil = 0;
  private dashCdUntil = 0;

  // 状态
  private jumpsUsed = 0;
  private lastGroundedAt = 0;
  private lastJumpPressAt = 0;
  private wallSide: -1 | 0 | 1 = 0;   // -1 墙在左侧，1 墙在右侧
  public isClinging = false;
  public attackCombo = 0;
  private attackUntil = 0;
  private nextAttackOkAt = 0;
  private invulnUntil = 0;
  private facing: 1 | -1 = 1;

  // 特效
  private jumpRing: Phaser.GameObjects.Arc | null = null;
  private onAttackFrame: ((combo: number, dir: 1 | -1) => void) | null = null;

  constructor(scene: Phaser.Scene, x: number, y: number) {
    this.scene = scene;
    this.sprite = scene.physics.add.sprite(x, y, 'yanyue', 0);
    this.sprite.setGravityY(this.GRAVITY);
    this.sprite.body!.setSize(34, 74);
    this.sprite.body!.setOffset(15, 13);
    this.sprite.setDepth(50);
    this.sprite.setMaxVelocity(this.DASH_SPEED, this.MAX_FALL);

    const kb = scene.input.keyboard!;
    const K = Phaser.Input.Keyboard.KeyCodes;
    this.keys = {
      left: kb.addKey(K.A),
      right: kb.addKey(K.D),
      up: kb.addKey(K.W),
      down: kb.addKey(K.S),
      jump: kb.addKey(K.SPACE),
      atk: kb.addKey(K.J),
      qi: kb.addKey(K.K),
      dash: kb.addKey(K.SHIFT),
      interact: kb.addKey(K.E),
      wheel: kb.addKey(K.Q),
    };
  }

  setAttackListener(fn: (combo: number, dir: 1 | -1) => void): void {
    this.onAttackFrame = fn;
  }

  get isDashing(): boolean {
    return this.scene.time.now < this.dashUntil;
  }

  get isInvulnerable(): boolean {
    return this.scene.time.now < this.invulnUntil;
  }

  get isAttacking(): boolean {
    return this.scene.time.now < this.attackUntil;
  }

  get facingDir(): 1 | -1 {
    return this.facing;
  }

  /** 受击后短暂无敌 */
  hurt(dmg: number): void {
    if (this.isInvulnerable) return;
    const s = store.get();
    s.heroineLife = Math.max(0, s.heroineLife - dmg);
    store.save();
    this.invulnUntil = this.scene.time.now + 900;
    this.sprite.setAlpha(0.55);
    this.scene.time.delayedCall(700, () => this.sprite.setAlpha(1));
    this.scene.cameras.main.shake(120, 0.008);
  }

  update(time: number, delta: number): void {
    const kb = this.keys;
    const body = this.sprite.body as Phaser.Physics.Arcade.Body;
    const onGround = body.blocked.down || body.touching.down;
    const dt = delta / 1000;

    // ---- 体力 ----
    if (this.isClinging) {
      this.stamina -= this.STAMINA_DRAIN * dt;
      if (this.stamina <= 0) {
        this.stamina = 0;
        this.isClinging = false;
        this.wallSide = 0;
      }
    } else {
      this.stamina = Math.min(this.STAMINA_MAX, this.stamina + this.STAMINA_REGEN * dt);
    }

    // ---- 闪身 ----
    if (Phaser.Input.Keyboard.JustDown(kb.dash) && time >= this.dashCdUntil && !this.isClinging) {
      this.dashUntil = time + this.DASH_MS;
      this.dashCdUntil = time + this.DASH_CD;
      this.invulnUntil = Math.max(this.invulnUntil, time + this.DASH_MS + 40);
      const dir = kb.left.isDown ? -1 : kb.right.isDown ? -1 * -1 : this.facing;
      this.facing = (kb.left.isDown ? -1 : 1) as 1 | -1;
      body.setVelocityX(this.DASH_SPEED * this.facing);
      body.setVelocityY(0);
      this.spawnInkPuff();
    }

    if (this.isDashing) {
      body.setAllowGravity(false);
      body.setVelocityY(0);
      this.sprite.setFlipX(this.facing === -1);
      return;
    }
    body.setAllowGravity(true);

    // ---- 水平移动 ----
    const dir = (kb.right.isDown ? 1 : 0) - (kb.left.isDown ? 1 : 0);
    if (dir !== 0) {
      this.facing = dir as 1 | -1;
      body.setAccelerationX(this.ACCEL * dir);
      if (Math.abs(body.velocity.x) > this.SPEED && onGround) {
        body.setVelocityX(this.SPEED * Math.sign(body.velocity.x));
      }
      this.sprite.setMaxVelocity(this.SPEED, this.MAX_FALL);
    } else {
      body.setAccelerationX(0);
      body.setVelocityX(
        Phaser.Math.Linear(body.velocity.x, 0, Math.min(1, this.DECEL * dt / Math.max(1, Math.abs(body.velocity.x))))
      );
    }
    this.sprite.setFlipX(this.facing === -1);

    // ---- 碰墙自动吸附 ----
    const pressingToward = (body.blocked.left && kb.left.isDown) || (body.blocked.right && kb.right.isDown);
    const canCling =
      !onGround &&
      (body.blocked.left || body.blocked.right) &&
      pressingToward &&
      this.stamina > 5 &&
      body.velocity.y > -80;

    if (canCling) {
      this.isClinging = true;
      this.wallSide = body.blocked.left ? -1 : 1;
      this.jumpsUsed = 0;
      // 吸附瞬间特效（只触发一次）
      if (body.velocity.y > 220) this.spawnClingFx();
      // 缓慢下滑 / W 上爬 / S 快速滑降
      if (kb.up.isDown) body.setVelocityY(-this.CLIMB_UP);
      else if (kb.down.isDown) body.setVelocityY(420);
      else body.setVelocityY(this.WALL_SLIDE);
      body.setVelocityX(0);
    } else if (onGround || !(body.blocked.left || body.blocked.right)) {
      this.isClinging = false;
      this.wallSide = 0;
    }

    // ---- 落地 / 土狼时间 ----
    if (onGround) {
      this.lastGroundedAt = time;
      this.jumpsUsed = 0;
    }

    // ---- 跳跃（含蹬墙跳 + 二段跳 + 缓冲） ----
    if (Phaser.Input.Keyboard.JustDown(kb.jump)) {
      this.lastJumpPressAt = time;
    }
    const jumpBuffered = time - this.lastJumpPressAt < this.BUFFER_MS;

    if (jumpBuffered) {
      if (onGround || time - this.lastGroundedAt < this.COYOTE_MS) {
        body.setVelocityY(-this.JUMP_VEL);
        this.jumpsUsed = 1;
        this.lastJumpPressAt = 0;
        this.spawnJumpRing(0.9);
      } else if (this.isClinging || ((body.blocked.left || body.blocked.right) && !onGround)) {
        // 蹬墙跳
        const away = this.wallSide === 0 ? -this.facing : -this.wallSide;
        body.setVelocityX(this.WALL_JUMP_X * away);
        body.setVelocityY(-this.WALL_JUMP_Y);
        this.facing = (away as 1 | -1);
        this.isClinging = false;
        this.jumpsUsed = 1;
        this.lastJumpPressAt = 0;
        this.stamina = Math.min(this.STAMINA_MAX, this.stamina + 20);
        this.spawnJumpRing(1.1);
      } else if (this.jumpsUsed < 2) {
        // 二段跳
        body.setVelocityY(-this.DOUBLE_JUMP_VEL);
        this.jumpsUsed = 2;
        this.lastJumpPressAt = 0;
        this.spawnJumpRing(1.3);
        this.spawnMoonRing();
      }
    }

    // ---- 可变跳跃高度：松开 Space 截断 ----
    if (!kb.jump.isDown && body.velocity.y < -260 && !this.isClinging) {
      body.setVelocityY(-260);
    }

    // ---- 攻击（三段连击） ----
    if (Phaser.Input.Keyboard.JustDown(kb.atk) && time >= this.nextAttackOkAt) {
      this.attackCombo = time < this.attackUntil ? (this.attackCombo % 3) + 1 : 1;
      this.attackUntil = time + 240;
      this.nextAttackOkAt = time + 200;
      this.onAttackFrame?.(this.attackCombo, this.facing);
    }

    // ---- 剑气由 GameScene 监听 ----
  }

  /* ---------- 特效 ---------- */

  private spawnJumpRing(scale: number): void {
    const ring = this.scene.add.circle(
      this.sprite.x, this.sprite.y + 30, 6 * scale, 0xf5f2e8, 0.5
    );
    ring.setDepth(49);
    this.scene.tweens.add({
      targets: ring,
      radius: 26 * scale,
      alpha: 0,
      duration: 260,
      onComplete: () => ring.destroy(),
    });
  }

  /** 二段跳淡墨月轮 */
  private spawnMoonRing(): void {
    const ring = this.scene.add.ellipse(
      this.sprite.x, this.sprite.y + 10, 70, 24, 0xd8d4c4, 0.4
    );
    ring.setStrokeStyle(2, 0xb8c8c8, 0.8);
    ring.setDepth(49);
    this.scene.tweens.add({
      targets: ring,
      scaleX: 1.8,
      scaleY: 2.0,
      alpha: 0,
      duration: 340,
      ease: 'Cubic.Out',
      onComplete: () => ring.destroy(),
    });
  }

  private spawnInkPuff(): void {
    for (let i = 0; i < 5; i++) {
      const p = this.scene.add.circle(
        this.sprite.x - this.facing * 20 + Phaser.Math.Between(-8, 8),
        this.sprite.y + Phaser.Math.Between(-20, 20),
        Phaser.Math.Between(3, 7),
        0x2a2a30, 0.55
      );
      p.setDepth(48);
      this.scene.tweens.add({
        targets: p,
        x: p.x - this.facing * Phaser.Math.Between(30, 70),
        alpha: 0,
        scale: 0.2,
        duration: 300,
        onComplete: () => p.destroy(),
      });
    }
  }

  private spawnClingFx(): void {
    for (let i = 0; i < 4; i++) {
      const p = this.scene.add.circle(
        this.sprite.x + this.wallSide * 20,
        this.sprite.y + Phaser.Math.Between(-24, 24),
        Phaser.Math.Between(2, 5),
        0xb8c8c8, 0.7
      );
      p.setDepth(48);
      this.scene.tweens.add({
        targets: p,
        y: p.y + Phaser.Math.Between(10, 30),
        alpha: 0,
        duration: 280,
        onComplete: () => p.destroy(),
      });
    }
  }
}
