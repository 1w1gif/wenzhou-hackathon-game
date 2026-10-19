/** 分歧选择浮层:每条世界线的最终抉择,选择后创建新世界线并写日记 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H } from '../constants';
import { getState, currentNode, arriveNode } from '../state';
import { choicesFor, DIVERGENCE_PROMPT, WORLDS, WorldId } from '../data/script';
import { requestDiary } from '../ai/diary';
import { makeText, makePanel, makeButton } from '../ui/widget';

export class DivergeScene extends Phaser.Scene {
  constructor() {
    super('Diverge');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    this.add.rectangle(W / 2, H / 2, W, H, 0x05040c, 0.78).setInteractive();

    const s = getState();
    const node = currentNode();

    makePanel(this, W * 0.14, H * 0.16, W * 0.72, H * 0.68, 0.94);
    makeText(this, W / 2, H * 0.22, '岔 路', { size: 34, align: 'center', color: '#f2ecda' });
    makeText(this, W / 2, H * 0.29, DIVERGENCE_PROMPT, {
      size: 19,
      align: 'center',
      color: '#a89cc8',
      wrap: W * 0.6,
    });

    const choices = choicesFor(node.phase as WorldId);
    choices.forEach((opt, i) => {
      const btn = makeButton(
        this,
        W / 2,
        H * 0.44 + i * 84,
        opt.text,
        () => this.choose(opt.id, opt.toPhase, opt.summary),
        { w: 460, h: 62, size: 19 }
      );
      btn.setDepth(10);
    });

    makeText(this, W / 2, H * 0.75, '此界的故事将随之定格,写入引月札。', {
      size: 15,
      color: '#6a6288',
      align: 'center',
      font: 'ui',
    });
    void s;
  }

  private choose(optionId: string, toPhase: WorldId, summary: string): void {
    const s = getState();
    const parent = currentNode();
    const fromPhase = parent.phase;

    // 1. 在旧节点定格日记(AI,异步)
    const clueNames = s.clues.map((c) => c);
    requestDiary(
      fromPhase,
      WORLDS[fromPhase as WorldId].xieRole,
      clueNames,
      summary,
      (r) => {
        parent.diary = r.text;
      },
    );

    // 2. 创建新世界线节点
    const newNode = arriveNode(toPhase, {
      optionId,
      optionText: summary,
      fromDivergence: fromPhase,
      toPhase,
    }, parent);

    // 3. 关闭浮层,切换场景
    this.scene.stop('Diverge');
    const town = this.scene.get('Town');
    this.scene.stop('Town');
    this.scene.start('Warp', { nextPhase: toPhase, fromPhase, nodeId: newNode.id });
    void town;
  }
}
