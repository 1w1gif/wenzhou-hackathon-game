import Phaser from 'phaser';
import { Enemy } from '../entities/Enemies';

export class CombatSystem {
  private scene: Phaser.Scene;
  private enemies: Enemy[] = [];
  constructor(scene: Phaser.Scene) { this.scene = scene; }
  add(enemy: Enemy): void { this.enemies.push(enemy); }
  update(player: Phaser.Physics.Arcade.Sprite): void { this.enemies = this.enemies.filter(e => e.active && !e.dead); for (const e of this.enemies) e.updateAI(player); }
  attack(player: Phaser.Physics.Arcade.Sprite, combo: number, dir: 1 | -1): void {
    this.scene.sound.play('sfx_sword', { volume: .3, detune: combo === 3 ? 200 : 0 });
    // Ultimate Slash 序列帧（160x120，10 帧），第三击放大
    const scale = combo === 3 ? 1.25 : .9;
    const slash = this.scene.add.sprite(player.x + dir * 30, player.y - 4, 'slash_sheet')
      .setScale(scale * (dir < 0 ? -1 : 1), scale).setDepth(60);
    slash.play('fx_slash');
    slash.once('animationcomplete', () => slash.destroy());
    for (const e of this.enemies) if (e.active && !e.dead && Math.abs(e.x - player.x) < 68 && Math.abs(e.y - player.y) < 66) {
      e.takeDamage(combo === 3 ? 2 : 1, dir * 170);
      this.hitSpark(e.x, e.y);
    }
  }
  swordQi(player: Phaser.Physics.Arcade.Sprite, dir: 1 | -1): void {
    this.scene.sound.play('sfx_sword', { volume: .35, detune: -300 });
    const slash = this.scene.add.sprite(player.x + dir * 45, player.y - 10, 'slash_sheet')
      .setScale(.8 * (dir < 0 ? -1 : 1), .8).setTint(0x75cbd1).setDepth(60);
    slash.play('fx_slash');
    this.scene.tweens.add({ targets: slash, x: slash.x + dir * 130, alpha: 0, duration: 260,
      onUpdate: () => { for (const e of this.enemies) if (!e.dead && Math.abs(e.x - slash.x) < 30 && Math.abs(e.y - slash.y) < 45) { e.takeDamage(2, dir * 220); this.hitSpark(e.x, e.y); } },
      onComplete: () => slash.destroy() });
  }
  /** 命中白光（Hit_Effect 6 帧） */
  private hitSpark(x: number, y: number): void {
    const s = this.scene.add.sprite(x, y - 6, 'hit_sheet').setScale(.45).setDepth(61);
    s.play('fx_hit');
    s.once('animationcomplete', () => s.destroy());
  }
}
