/** 引月札浮层:线索 + 各世界线日记(可插拔 AI 文案展示) */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H } from '../constants';
import { getState } from '../state';
import { CLUES, WORLDS, WorldId } from '../data/script';
import { makeText, makePanel, makeButton } from '../ui/widget';

export class JournalScene extends Phaser.Scene {
  constructor() {
    super('Journal');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();

    this.add.rectangle(W / 2, H / 2, W, H, 0x05040c, 0.82).setInteractive();
    makePanel(this, W * 0.12, H * 0.08, W * 0.76, H * 0.84, 0.96);

    makeText(this, W / 2, H * 0.13, '引 月 札', { size: 32, align: 'center', color: '#f2ecda' });

    const aiBadge = s.aiEnabled ? 'AI 叙事:已连接' : 'AI 叙事:离线(本地文案)';
    makeText(this, W / 2, H * 0.175, aiBadge, {
      size: 13,
      align: 'center',
      color: s.aiEnabled ? '#9ad8a0' : '#6a6288',
      font: 'ui',
    });

    // 线索区
    makeText(this, W * 0.16, H * 0.24, `◆ 线索(${s.clues.length}/8)`, { size: 19, color: '#d8cfa8' });
    const clueTexts = s.clues.map((id) => {
      const c = CLUES[id];
      return `「${c.name}」 ${c.text}`;
    });
    if (clueTexts.length === 0) clueTexts.push('(尚无线索。去各世界解谜,谜底会记在这里,并跨越所有时空。)');
    makeText(this, W * 0.16, H * 0.28, clueTexts.join('\n\n'), {
      size: 15,
      wrap: W * 0.33,
      color: '#c8c2da',
      lineSpacing: 6,
    });

    // 日记区
    makeText(this, W * 0.53, H * 0.24, `◆ 世界线日记(${s.order.length} 条)`, { size: 19, color: '#d8cfa8' });
    let y = H * 0.28;
    const diaryLines = s.order.map((id) => s.nodes[id]);
    // 最新的在上
    diaryLines.reverse();
    for (const n of diaryLines) {
      const world = WORLDS[n.phase as WorldId];
      const diary = n.diary ?? '(此界的日记尚未落笔)';
      const block = makeText(
        this,
        W * 0.53,
        y,
        `【${world.title}】${diary}`,
        { size: 14, wrap: W * 0.32, color: '#b0a8c8', lineSpacing: 5 },
      );
      y += Math.max(46, block.height + 18);
      if (y > H * 0.86) {
        makeText(this, W * 0.53, y, '……', { size: 14, color: '#5a5478' });
        break;
      }
    }

    makeButton(this, W / 2, H * 0.94, '合上札记', () => this.close(), { w: 180, h: 44, ghost: true });
    this.input.keyboard!.once('keydown-ESC', () => this.close());
  }

  private close(): void {
    this.scene.stop('Journal');
    const town = this.scene.get('Town');
    if (town && town.scene.isActive()) {
      (town as unknown as { interacting: boolean }).interacting = false;
    }
  }
}
