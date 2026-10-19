/** 终章:满月祭台,把某条世界线指定为唯一现实,双结局 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H } from '../constants';
import { getState, currentNode, addClue } from '../state';
import { ENDINGS } from '../data/script';
import { makeText, makePanel, makeButton, addAmbient, typewrite } from '../ui/widget';
import { drawYanyue } from '../ui/yanyue';

interface EndingDef {
  id: string;
  title: string;
  text: string;
}

export class FinaleScene extends Phaser.Scene {
  constructor() {
    super('Finale');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();

    // 满月背景
    const bg = this.add.graphics();
    bg.fillStyle(0x1a2140, 1);
    bg.fillRect(0, 0, W, H);
    bg.fillStyle(0xfff6d8, 0.95);
    bg.fillCircle(W / 2, H * 0.3, 110);
    bg.fillStyle(0x1a2140, 0.25);
    bg.fillCircle(W / 2 - 30, H * 0.3 - 20, 90);
    addAmbient(this, 0xd8cfa8, 40);

    makeText(this, W / 2, H * 0.3, '', { align: 'center' });

    const hero = drawYanyue(this, W * 0.2, H * 0.68, 1.2);
    hero.setAlpha(0);
    this.tweens.add({ targets: hero, alpha: 1, duration: 1200 });

    makePanel(this, W * 0.34, H * 0.42, W * 0.56, H * 0.4, 0.9);
    const txt = makeText(this, W * 0.34 + 40, H * 0.5, '', {
      size: 20,
      wrap: W * 0.56 - 80,
      lineSpacing: 12,
    });
    const full = [
      '满月祭台。八重钟声自所有世界同时响起。',
      '引月札自动翻开,停在最末一页。页上只有一行问题:',
      '「若只许一条世界线成为真实,你选哪一条?」',
    ].join('\n');
    const typer = typewrite(this, txt, full, 30);

    this.time.delayedCall(2200, () => {
      const proceed = () => {
        this.input.off('pointerdown', proceed);
        this.showChoice();
      };
      const wait = () => {
        if (!typer.done) {
          typer.skip();
          return;
        }
        proceed();
      };
      this.input.on('pointerdown', wait);
    });

    void s;
  }

  private showChoice(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();

    makeText(this, W * 0.62, H * 0.46, '你合上眼,伸出手指——', {
      size: 18,
      color: '#d8cfa8',
      align: 'center',
    });

    makeButton(this, W * 0.62, H * 0.56, '点亮所有世界', () => this.ending(ENDINGS.union), {
      w: 320,
      h: 58,
      accent: 0xfff6d8,
    });
    makeButton(this, W * 0.62, H * 0.56 + 78, '熄灭其余,只留一条', () => this.ending(ENDINGS.alone), {
      w: 320,
      h: 58,
      accent: 0x8f7fc0,
    });

    makeText(this, W * 0.62, H * 0.56 + 130, '(两条终局都将解锁通关图;选择会影响结局)', {
      size: 13,
      color: '#6a6288',
      align: 'center',
      font: 'ui',
    });
    void s;
  }

  private ending(def: EndingDef): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();

    // 记录结局 + 清空浮层
    if (!s.endingsSeen.includes(def.id)) s.endingsSeen.push(def.id);
    if (!s.clues.includes('clue_kite')) addClue('clue_kite');
    s.chosenReality = currentNode().id;

    // 终章本身也是一条世界线
    const node = currentNode();
    node.kind = 'ending';

    this.children.removeAll();
    const bg = this.add.graphics();
    bg.fillStyle(def.id === 'union' ? 0x232a56 : 0x0c0a18, 1);
    bg.fillRect(0, 0, W, H);
    if (def.id === 'union') {
      // 八轮同天
      for (let i = 0; i < 8; i++) {
        const mg = this.add.graphics();
        mg.fillStyle(0xfff6d8, 0.75);
        mg.fillCircle(W * (0.12 + i * 0.108), H * 0.14, 22);
      }
      addAmbient(this, 0xfff6d8, 60);
    } else {
      const mg = this.add.graphics();
      mg.fillStyle(0xfff6d8, 0.9);
      mg.fillCircle(W * 0.82, H * 0.16, 46);
      addAmbient(this, 0x5a5478, 20);
    }

    const hero = drawYanyue(this, W * 0.18, H * 0.62, 1.25);
    hero.setAlpha(0);
    this.tweens.add({ targets: hero, alpha: 1, duration: 1500 });

    makeText(this, W / 2, H * 0.3, def.title, { size: 38, align: 'center', color: '#f2ecda' });
    const txt = makeText(this, W * 0.34, H * 0.46, '', {
      size: 20,
      wrap: W * 0.56,
      lineSpacing: 13,
    });
    const t = typewrite(this, txt, def.text, 32);

    this.time.delayedCall(3000, () => {
      const proceed = () => {
        this.input.off('pointerdown', proceed);
        this.showCoda();
      };
      const wait = () => {
        if (!t.done) {
          t.skip();
          return;
        }
        proceed();
      };
      this.input.on('pointerdown', wait);
    });
  }

  private showCoda(): void {
    const W = VIEW_W;
    const H = VIEW_H;
    const s = getState();

    makeText(this, W / 2, H * 0.76, `通关 · 共 ${s.order.length} 条世界线 · ${s.jumps} 次穿越 · ${s.clues.length}/8 线索`, {
      size: 17,
      color: '#d8cfa8',
      align: 'center',
    });

    makeButton(this, W / 2 - 140, H * 0.87, '重入轮回(新游戏)', () => {
      this.scene.start('Title');
    }, { w: 240 });
    makeButton(this, W / 2 + 140, H * 0.87, '回到时空树', () => {
      this.scene.start('Town');
    }, { w: 200, ghost: true });

    makeText(this, W / 2, H * 0.95, '衍月·八相 — 平行时空 · AI+游戏赛道', {
      size: 13,
      color: '#5a5478',
      align: 'center',
      font: 'ui',
    });
  }
}
