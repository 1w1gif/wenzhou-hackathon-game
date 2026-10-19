/** 穿越过场:月相轮转动,世界重构 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H, PHASES } from '../constants';
import { getState } from '../state';
import { makeText } from '../ui/widget';

export class WarpScene extends Phaser.Scene {
  constructor() {
    super('Warp');
  }

  create(data: { nextPhase: string; fromPhase: string; nodeId: string }): void {
    const W = VIEW_W;
    const H = VIEW_H;
    this.add.rectangle(W / 2, H / 2, W, H, 0x05040c, 1);

    // 旋转的月相环
    const ring = this.add.container(W / 2, H / 2);
    const nodes: Phaser.GameObjects.Graphics[] = [];
    PHASES.forEach((p, i) => {
      const a = (i / 8) * Math.PI * 2 - Math.PI / 2;
      const rx = Math.cos(a) * 150;
      const ry = Math.sin(a) * 150 * 0.42;
      const g = this.add.graphics();
      const isTarget = p === data.nextPhase;
      const isFrom = p === data.fromPhase;
      g.fillStyle(isTarget ? 0xfff6d8 : isFrom ? 0x8f7fc0 : 0x4a4468, isTarget ? 1 : 0.7);
      if (p === data.nextPhase) {
        g.fillCircle(rx, ry, 26);
        g.lineStyle(2, 0xfff6d8, 0.5);
        g.strokeCircle(rx, ry, 40);
      } else {
        g.fillCircle(rx, ry, 14);
      }
      ring.add(g);
      nodes.push(g);
      const label = makeText(this, rx, ry + (isTarget ? 56 : 34), p, {
        size: isTarget ? 24 : 16,
        align: 'center',
        color: isTarget ? '#fff6d8' : '#6a6288',
      });
      ring.add(label);
    });

    const s = getState();
    const hint = makeText(this, W / 2, H / 2 + 150, '', { size: 20, align: 'center', color: '#d8cfa8' });
    const counter = makeText(this, W / 2, H * 0.16, `世界线 · 第 ${s.order.length} 条`, {
      size: 26,
      align: 'center',
      color: '#a89cc8',
    });
    const jumpNote = makeText(this, W / 2, H * 0.16 + 40, `引月札 · 第 ${s.jumps} 次穿越`, {
      size: 15,
      align: 'center',
      color: '#6a6288',
      font: 'ui',
    });

    ring.setScale(0.2);
    ring.setAlpha(0);
    this.tweens.add({ targets: ring, scale: 1, alpha: 1, duration: 700, ease: 'Cubic.easeOut' });
    this.tweens.add({ targets: ring, angle: 360, duration: 4200, ease: 'Cubic.easeOut' });

    this.time.delayedCall(700, () => {
      hint.setText(`月相轮指向「${data.nextPhase}」——`);
      this.cameras.main.flash(300, 255, 246, 216);
    });
    this.time.delayedCall(2000, () => {
      hint.setText('世界,在此分岔。');
    });
    this.time.delayedCall(2900, () => {
      this.cameras.main.fadeOut(500, 5, 4, 12);
    });
    this.time.delayedCall(3450, () => {
      this.scene.start('Town');
      void nodes; void counter; void jumpNote;
    });
  }
}
