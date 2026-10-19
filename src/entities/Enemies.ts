import Phaser from 'phaser';
import { PIXEL } from '../media/pixel';

export class Enemy extends Phaser.Physics.Arcade.Sprite {
  hp: number; maxHp: number; dead = false; private speed: number;
  constructor(scene: Phaser.Scene, x: number, y: number, texture: string, hp: number, speed = 50) { super(scene, x, y, texture); this.hp = hp; this.maxHp = hp; this.speed = speed; scene.add.existing(this); scene.physics.add.existing(this); this.setCollideWorldBounds(true); this.setGravityY(1500); this.setDepth(40); }
  updateAI(player: Phaser.Physics.Arcade.Sprite): void { if (this.dead) return; const dx = player.x - this.x; if (Math.abs(dx) > 34) this.setVelocityX(Math.sign(dx) * this.speed); else this.setVelocityX(0); this.setFlipX(dx < 0); }
  takeDamage(dmg: number, knockback: number): void { if (this.dead) return; this.hp -= dmg; this.setVelocityX(knockback); this.setTint(0xffffff); this.scene.time.delayedCall(80, () => this.clearTint()); if (this.hp <= 0) this.die(); }
  protected die(): void { this.dead = true; this.setVelocity(0, -160); this.setAlpha(.7); for (let i = 0; i < 8; i++) { const p = this.scene.add.rectangle(this.x, this.y, 4, 4, PIXEL.ink3).setDepth(45); this.scene.tweens.add({ targets: p, x: p.x + Phaser.Math.Between(-30, 30), y: p.y + Phaser.Math.Between(-30, 10), alpha: 0, duration: 450, onComplete: () => p.destroy() }); } this.scene.time.delayedCall(420, () => this.destroy()); }
}

export class Bandit extends Enemy { constructor(scene: Phaser.Scene, x: number, y: number) { super(scene, x, y, 'bandit', 3, 65); } }
export class Thrower extends Enemy { private shotAt = 0; constructor(scene: Phaser.Scene, x: number, y: number) { super(scene, x, y, 'thrower', 2, 38); } updateAI(player: Phaser.Physics.Arcade.Sprite): void { if (this.dead) return; super.updateAI(player); if (this.scene.time.now > this.shotAt && Math.abs(player.x - this.x) < 360) { this.shotAt = this.scene.time.now + 1600; const b = this.scene.add.rectangle(this.x, this.y - 20, 8, 8, PIXEL.fire).setDepth(42); this.scene.physics.add.existing(b); const body = b.body as Phaser.Physics.Arcade.Body; body.setVelocity((player.x > this.x ? 1 : -1) * 180, -180); this.scene.time.delayedCall(2500, () => b.destroy()); } } }
export class BanditBoss extends Enemy { constructor(scene: Phaser.Scene, x: number, y: number) { super(scene, x, y, 'boss', 14, 80); } }
export class ShenYan extends Enemy { constructor(scene: Phaser.Scene, x: number, y: number) { super(scene, x, y, 'shenyan', 20, 75); } }
