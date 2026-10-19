/** 月相轮浮层:八相转盘 + 时空线切换(点击任意已存在的世界线跳转,同相合并) */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H, PHASES, WORLD_THEMES } from '../constants';
import { getState, currentNode } from '../state';
import { WorldId } from '../data/script';
import { makeText, makePanel, drawMoonIcon } from '../ui/widget';

export class WheelScene extends Phaser.Scene {
  constructor() {
    super('Wheel');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();
    const cur = currentNode();

    this.add.rectangle(W / 2, H / 2, W, H, 0x05040c, 0.82).setInteractive();
    makePanel(this, W * 0.2, H * 0.12, W * 0.6, H * 0.76, 0.95);

    makeText(this, W / 2, H * 0.17, '月 相 轮', { size: 32, align: 'center', color: '#f2ecda' });
    makeText(this, W / 2, H * 0.225, '同一月相的所有世界线在此交汇 · 点击月相前往', {
      size: 15,
      align: 'center',
      color: '#8f7fc0',
      font: 'ui',
    });

    const cx = W / 2;
    const cy = H * 0.47;
    const R = 170;

    // 环
    const ring = this.add.graphics();
    ring.lineStyle(1.5, 0x4a4468, 0.8);
    ring.strokeEllipse(cx, cy, R * 2, R * 1.3);

    PHASES.forEach((p, i) => {
      const a = (i / 8) * Math.PI * 2 - Math.PI / 2;
      const x = cx + Math.cos(a) * R;
      const y = cy + Math.sin(a) * R * 0.65;

      // 该月相下的世界线数量
      const lines = s.order
        .map((id) => s.nodes[id])
        .filter((n) => n.phase === p);
      const isCurrent = cur.phase === p;
      const theme = WORLD_THEMES[p];

      const g = this.add.graphics();
      // 底盘
      g.fillStyle(0x14122a, 0.9);
      g.fillCircle(x, y, 40);
      g.lineStyle(isCurrent ? 3 : 1.5, isCurrent ? 0xfff6d8 : theme.accent, isCurrent ? 1 : 0.9);
      g.strokeCircle(x, y, 40);

      // 月相图案
      drawMoonIcon(g, x, y, 20, theme.moon, i);

      g.setInteractive(new Phaser.Geom.Circle(x, y, 40), Phaser.Geom.Circle.Contains);
      g.input!.cursor = 'pointer';
      g.on('pointerover', () => this.tweens.add({ targets: g, scale: 1.1, duration: 120 }));
      g.on('pointerout', () => this.tweens.add({ targets: g, scale: 1, duration: 120 }));

      if (lines.length > 0) {
        g.on('pointerup', () => this.go(p));
      }

      const label = makeText(this, x, y + 56, p, {
        size: 18,
        align: 'center',
        color: lines.length > 0 ? '#e8e2f2' : '#5a5478',
      });
      const count = makeText(this, x, y + 78, lines.length > 0 ? `${lines.length} 条线` : '未至', {
        size: 12,
        align: 'center',
        color: lines.length > 0 ? '#8f7fc0' : '#4a4468',
        font: 'ui',
      });
      if (isCurrent) {
        makeText(this, x, y - 62, '◈ 当前', { size: 13, align: 'center', color: '#fff6d8', font: 'ui' });
      }
      void label; void count;
    });

    makeText(this, W / 2, H * 0.82, '提示:穿越不需要选择——但只有先在岔路做出选择,世界才会长出新的线。', {
      size: 14,
      align: 'center',
      color: '#6a6288',
      font: 'ui',
    });

    // 关闭
    const esc = this.input.keyboard!.addKey('ESC');
    esc.on('down', () => this.close());
    this.input.keyboard!.on('keydown-W', () => this.close());
  }

  private close(): void {
    this.scene.stop('Wheel');
    const town = this.scene.get('Town');
    if (town && town.scene.isActive()) {
      (town as unknown as { interacting: boolean }).interacting = false;
    }
  }

  private go(phase: WorldId): void {
    const s = getState();
    const cur = currentNode();
    if (cur.phase === phase) return;
    const target = s.order.map((id) => s.nodes[id]).find((n) => n.phase === phase);
    if (!target) return;

    s.currentNodeId = target.id;
    this.scene.stop('Wheel');
    this.scene.stop('Town');
    this.scene.start('Warp', { nextPhase: phase, fromPhase: cur.phase, nodeId: target.id });
  }
}
