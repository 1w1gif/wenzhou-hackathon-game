import Phaser from 'phaser';
import { store, MOON_PHASES } from '../core/GameStore';
import { PIXEL } from '../media/pixel';

export class Hud {
  private scene: Phaser.Scene;
  private root: Phaser.GameObjects.Container;
  private lifeText: Phaser.GameObjects.Text;
  private intentBar: Phaser.GameObjects.Rectangle;
  private phaseText: Phaser.GameObjects.Text;
  private objectiveText: Phaser.GameObjects.Text;
  private toast?: Phaser.GameObjects.Text;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.root = scene.add.container(12, 10).setScrollFactor(0).setDepth(200);
    this.lifeText = scene.add.text(0, 0, '', this.textStyle(13, '#f2e7c8')).setResolution(2);
    this.intentBar = scene.add.rectangle(68, 27, 86, 5, PIXEL.cyan).setOrigin(0, .5);
    this.phaseText = scene.add.text(348, 5, '', this.textStyle(12, '#d6a85d')).setOrigin(.5, 0).setResolution(2);
    this.objectiveText = scene.add.text(0, 50, '', this.textStyle(10, '#c5eef0')).setResolution(2);
    this.root.add([this.lifeText, this.intentBar, this.phaseText, this.objectiveText]);
    scene.add.text(468, 252, 'T 时空树 · N 引月札', {
      fontFamily: 'serif', fontSize: '8px', color: '#54687a',
      stroke: '#11131d', strokeThickness: 2,
    }).setOrigin(1, 0).setScrollFactor(0).setDepth(200);
    this.update();
  }

  private textStyle(size: number, color: string): Phaser.Types.GameObjects.Text.TextStyle { return { fontFamily: 'serif', fontSize: `${size}px`, color, stroke: '#11131d', strokeThickness: 3 }; }

  update(): void {
    const s = store.get();
    const hearts = '◈ '.repeat(s.heroineLife).trim() || '—';
    this.lifeText.setText(`生命 ${hearts}   剑意`);
    this.intentBar.setScale(Math.max(0, s.swordIntent / s.maxSwordIntent), 1);
    this.phaseText.setText(`☾ ${MOON_PHASES[s.moonPhaseIndex]} · 第 ${s.loopIndex + 1} 夜`);
  }

  showObjective(text: string): void { this.objectiveText.setText(`目标  ${text}`); }

  showToast(text: string, duration = 1800): void {
    this.toast?.destroy();
    this.toast = this.scene.add.text(240, 220, text, this.textStyle(13, '#f2e7c8')).setOrigin(.5).setScrollFactor(0).setDepth(230).setBackgroundColor('#11131ddd').setPadding(10, 6);
    this.scene.tweens.add({ targets: this.toast, alpha: 0, delay: duration, duration: 400, onComplete: () => this.toast?.destroy() });
  }

  destroy(): void { this.root.destroy(true); this.toast?.destroy(); }
}
