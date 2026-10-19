import Phaser from 'phaser';
import { Enemy } from '../entities/Enemies';

export class CombatSystem {
  private scene: Phaser.Scene;
  private enemies: Enemy[] = [];
  constructor(scene: Phaser.Scene) { this.scene = scene; }
  add(enemy: Enemy): void { this.enemies.push(enemy); }
  update(player: Phaser.Physics.Arcade.Sprite): void { this.enemies = this.enemies.filter(e => e.active && !e.dead); for (const e of this.enemies) e.updateAI(player); }
  attack(player: Phaser.Physics.Arcade.Sprite, combo: number, dir: 1 | -1): void {
    const slash = this.scene.add.image(player.x + dir * 34, player.y - 4, 'slash').setScale(combo === 3 ? 1.2 : 1).setFlipX(dir < 0).setDepth(60);
    this.scene.tweens.add({ targets: slash, alpha: 0, x: slash.x + dir * 15, duration: 130, onComplete: () => slash.destroy() });
    for (const e of this.enemies) if (e.active && !e.dead && Math.abs(e.x - player.x) < 68 && Math.abs(e.y - player.y) < 66) e.takeDamage(combo === 3 ? 2 : 1, dir * 170);
  }
  swordQi(player: Phaser.Physics.Arcade.Sprite, dir: 1 | -1): void {
    const slash = this.scene.add.image(player.x + dir * 45, player.y - 10, 'slash').setTint(0x75cbd1).setFlipX(dir < 0).setDepth(60);
    this.scene.tweens.add({ targets: slash, x: slash.x + dir * 130, alpha: 0, duration: 260, onUpdate: () => { for (const e of this.enemies) if (!e.dead && Math.abs(e.x - slash.x) < 30 && Math.abs(e.y - slash.y) < 45) e.takeDamage(2, dir * 220); }, onComplete: () => slash.destroy() });
  }
}
