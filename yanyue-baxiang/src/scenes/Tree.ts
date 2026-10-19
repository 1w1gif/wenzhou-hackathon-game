/** 时空树浮层:可视化全部世界线(玩家亲手长出的树)+ 终章入口 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H, PHASES, WORLD_THEMES } from '../constants';
import { getState, currentNode } from '../state';
import { WORLDS, WorldId } from '../data/script';
import { makeText, makePanel, makeButton } from '../ui/widget';

export class TreeScene extends Phaser.Scene {
  constructor() {
    super('Tree');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();
    const cur = currentNode();

    this.add.rectangle(W / 2, H / 2, W, H, 0x05040c, 0.86).setInteractive();
    makePanel(this, W * 0.08, H * 0.08, W * 0.84, H * 0.84, 0.96);

    makeText(this, W / 2, H * 0.13, '时 空 树', { size: 30, align: 'center', color: '#f2ecda' });
    makeText(this, W / 2, H * 0.175, '你走过的每一条世界线 · 点击节点跳转', {
      size: 14,
      align: 'center',
      color: '#8f7fc0',
      font: 'ui',
    });

    // ---- 布局:深度为列,兄弟为行 ----
    const nodes = s.order.map((id) => s.nodes[id]);
    const byDepth: Record<number, typeof nodes> = {};
    for (const n of nodes) {
      (byDepth[n.depth] ??= []).push(n);
    }
    const maxDepth = Math.max(...nodes.map((n) => n.depth));
    const colW = Math.min(150, (W * 0.74) / (maxDepth + 1));
    const x0 = W * 0.13;

    interface Laid { id: string; x: number; y: number }
    const laid: Record<string, Laid> = {};

    for (let d = 0; d <= maxDepth; d++) {
      const row = byDepth[d] ?? [];
      row.forEach((n, i) => {
        const x = x0 + d * colW;
        const y = H * 0.26 + i * ((H * 0.6) / Math.max(8, row.length)) + 20;
        laid[n.id] = { id: n.id, x, y };
      });
    }

    // ---- 边 ----
    const edges = this.add.graphics();
    edges.setDepth(1);
    for (const n of nodes) {
      if (!n.parent) continue;
      const p = laid[n.parent];
      const c = laid[n.id];
      if (!p || !c) continue;
      const isCurrent = n.id === cur.id;
      edges.lineStyle(isCurrent ? 2.5 : 1.2, isCurrent ? 0xfff6d8 : 0x5a5478, isCurrent ? 0.95 : 0.6);
      edges.beginPath();
      edges.moveTo(p.x + 20, p.y);
      edges.lineTo(p.x + colW * 0.45, p.y);
      edges.lineTo(p.x + colW * 0.45, c.y);
      edges.lineTo(c.x - 20, c.y);
      edges.strokePath();
      // 边上的选择注记
      if (n.via) {
        makeText(this, (p.x + c.x) / 2, c.y - 12, n.via.optionText.slice(0, 10) + '…', {
          size: 10,
          color: '#6a6288',
          font: 'ui',
          align: 'center',
        }).setDepth(2);
      }
    }

    // ---- 节点 ----
    for (const n of nodes) {
      const { x, y } = laid[n.id];
      const theme = WORLD_THEMES[n.phase];
      const isCurrent = n.id === cur.id;
      const phaseIdx = PHASES.indexOf(n.phase);

      const g = this.add.graphics();
      g.setDepth(3);
      g.fillStyle(isCurrent ? 0xfff6d8 : 0x14122a, 1);
      g.fillCircle(x, y, isCurrent ? 17 : 14);
      g.fillStyle(theme.moon, 1);
      g.fillCircle(x, y, isCurrent ? 12 : 10);
      if (phaseIdx === 0) {
        g.fillStyle(0x2a2a40, 1);
        g.fillCircle(x, y, 12);
      }
      g.lineStyle(1.5, theme.accent, 0.9);
      g.strokeCircle(x, y, isCurrent ? 17 : 14);

      g.setInteractive(new Phaser.Geom.Circle(x, y, 20), Phaser.Geom.Circle.Contains);
      g.input!.cursor = 'pointer';
      g.on('pointerup', () => {
        if (n.id === cur.id) return;
        s.currentNodeId = n.id;
        this.scene.stop('Tree');
        this.scene.stop('Town');
        this.scene.start('Warp', { nextPhase: n.phase, fromPhase: cur.phase, nodeId: n.id });
      });
      g.on('pointerover', () => {
        makeText(this, x, y - 34, `${WORLDS[n.phase as WorldId].title}`, {
          size: 12,
          align: 'center',
          color: '#f2e2cf',
          font: 'ui',
        }).setDepth(20).setName(`tip_${n.id}`);
      });
      g.on('pointerout', () => {
        const tip = this.children.getByName(`tip_${n.id}`);
        tip?.destroy();
      });

      // 深度列标
      if (n.depth === (byDepth[n.depth]?.[0]?.depth ?? 0)) {
        makeText(this, x, H * 0.225, `第 ${n.depth + 1} 夜`, {
          size: 11,
          color: '#5a5478',
          align: 'center',
          font: 'ui',
        });
      }
    }

    // ---- 终章按钮 ----
    const canFinale = this.checkFinale();
    const finaleBtn = makeButton(
      this,
      W * 0.84,
      H * 0.86,
      canFinale ? '祭月台 · 终章' : '终章(线索未足)',
      () => {
        if (!canFinale) {
          this.scene.launch('Modal', {
            title: '祭月台沉默着',
            body: '终章需要三条关键线索:\n「祭文的空行」「渡口的回执」「未寄出的雁书」。\n\n它们藏在不同月相的世界里。继续穿行吧。',
          });
          return;
        }
        this.scene.stop('Tree');
        this.scene.stop('Town');
        this.scene.start('Finale');
      },
      { w: 210, h: 50, accent: canFinale ? 0xd8cfa8 : 0x4a4468, ghost: !canFinale },
    );
    finaleBtn.setDepth(5);

    makeButton(this, W * 0.13, H * 0.86, '返回', () => this.close(), { w: 130, h: 44, ghost: true }).setDepth(5);
    this.input.keyboard!.once('keydown-ESC', () => this.close());
  }

  private checkFinale(): boolean {
    const s = getState();
    return (
      s.clues.includes('clue_shrine') &&
      s.clues.includes('clue_boat') &&
      s.clues.includes('clue_kite')
    );
  }

  private close(): void {
    this.scene.stop('Tree');
    const town = this.scene.get('Town');
    if (town && town.scene.isActive()) {
      (town as unknown as { interacting: boolean }).interacting = false;
    }
  }
}
