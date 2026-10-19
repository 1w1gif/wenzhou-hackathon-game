/** 标题 + 序章叙事场景 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H } from '../constants';
import { newGame } from '../state';
import { makeText, makeButton, addAmbient, makePanel } from '../ui/widget';
import { drawYanyue } from '../ui/yanyue';

export class TitleScene extends Phaser.Scene {
  constructor() {
    super('Title');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;

    // 深空底色
    const bg = this.add.graphics();
    bg.fillStyle(0x07060e, 1);
    bg.fillRect(0, 0, W, H);

    // 大月亮背景
    const moon = this.add.graphics();
    moon.fillStyle(0xfff6d8, 0.12);
    moon.fillCircle(W / 2, H * 0.42, 210);
    moon.fillStyle(0xfff6d8, 0.1);
    moon.fillCircle(W / 2, H * 0.42, 160);

    addAmbient(this, 0x8f7fc0, 60);

    // 标题
    const title = makeText(this, W / 2, H * 0.3, '衍 月 · 八 相', {
      size: 72,
      align: 'center',
      color: '#f2ecda',
    });
    title.setAlpha(0);
    this.tweens.add({ targets: title, alpha: 1, y: H * 0.28, duration: 1600, ease: 'Cubic.easeOut' });

    const sub = makeText(this, W / 2, H * 0.42, '一念之分,八相之界', {
      size: 22,
      align: 'center',
      color: '#a89cc8',
    });
    sub.setAlpha(0);
    this.tweens.add({ targets: sub, alpha: 1, duration: 1600, delay: 800 });

    // 主角立绘
    const hero = drawYanyue(this, W / 2, H * 0.66, 1.15);
    hero.setAlpha(0);
    this.tweens.add({ targets: hero, alpha: 1, duration: 1400, delay: 500 });

    // 按钮
    const start = makeButton(this, W / 2 - 130, H * 0.86, '入 梦', () => {
      this.cameras.main.fadeOut(500, 7, 6, 14);
      this.time.delayedCall(520, () => this.scene.start('Intro'));
    }, { w: 200 });
    const about = makeButton(this, W / 2 + 130, H * 0.86, '引月札说明', () => {
      this.scene.launch('Modal', {
        title: '引月札',
        body: '引月札是衍月随身的笔记,贯穿所有平行时空。\n\n· 在任意世界解开的谜题与获得的线索,都会记入札中,带到所有世界。\n· 穿越会创造新的世界线,你随时可以在「时空树」中回到任意一条线。\n· 时空树在屏幕右下角,引月札在左下角。',
      });
    }, { w: 200, ghost: true });
    start.setAlpha(0);
    about.setAlpha(0);
    this.tweens.add({ targets: [start, about], alpha: 1, duration: 800, delay: 1400 });

    // 版本行
    makeText(this, 20, H - 22, 'INTERCITY HACK 2026 · AI+游戏 · 平行时空', {
      size: 13,
      color: '#5a5478',
      font: 'ui',
    });
  }
}

const INTRO_LINES: Array<{ text: string; hero?: boolean }> = [
  { text: '八月十五,祭月之夜。' },
  { text: '镇上的人都说,那一夜谢郎登上了祭月台,然后就再也没有下来。' },
  { text: '没有尸首,没有遗书。他只是从这个世界里,被轻轻取走了。' },
  { text: '只有你记得——月亮在那一夜缺了一角。' },
  { text: '而你手中这册引月札的第一页,不知何时多了一行小字:', hero: false },
  { text: '「月有八相,相相皆世界。欲寻其人,遍历八相。」', hero: false },
  { text: '于是你翻开月相轮。第一个世界,是「朔」——无光之夜。', hero: true },
];

export class IntroScene extends Phaser.Scene {
  private idx = 0;
  private txt?: Phaser.GameObjects.Text;
  private typer?: { done: boolean; skip: () => void };
  private hint?: Phaser.GameObjects.Text;

  constructor() {
    super('Intro');
  }

  create(): void {
    newGame(); // 每次开场重置存档
    const W = VIEW_W;
    const H = VIEW_H;

    const bg = this.add.graphics();
    bg.fillStyle(0x07060e, 1);
    bg.fillRect(0, 0, W, H);
    addAmbient(this, 0x8f7fc0, 30);

    makePanel(this, W * 0.14, H * 0.36, W * 0.72, 200, 0.85);
    this.txt = makeText(this, W * 0.14 + 48, H * 0.36 + 100, '', {
      size: 26,
      wrap: W * 0.72 - 96,
      lineSpacing: 14,
    });
    this.hint = makeText(this, W - 48, H - 40, '点击继续 ▸', { size: 15, color: '#8f7fc0', font: 'ui', align: 'right' });
    this.hint.setAlpha(0.6);

    this.showLine();

    this.input.on('pointerdown', () => {
      if (this.typer && !this.typer.done) {
        this.typer.skip();
        return;
      }
      this.idx += 1;
      if (this.idx >= INTRO_LINES.length) {
        this.scene.start('Town');
      } else {
        this.showLine();
      }
    });
  }

  private showLine(): void {
    const line = INTRO_LINES[this.idx];
    const y = this.scale.height * 0.36 + 100;
    if (this.idx === INTRO_LINES.length - 1) {
      // 最后一行:衍月现身
      const hero = drawYanyue(this, this.scale.width * 0.5, this.scale.height * 0.78, 0.9);
      hero.setAlpha(0);
      this.tweens.add({ targets: hero, alpha: 1, y: this.scale.height * 0.74, duration: 900 });
      makeText(this, this.scale.width * 0.5 + 110, this.scale.height * 0.74, '衍月', {
        size: 20,
        color: '#d8cfa8',
      });
    }
    this.txt?.setY(y);
    this.txt?.setText('');
    this.typer = require_typewrite(this, this.txt!, line.text);
    // 衍月台词用暖色
    if (line.hero) this.txt?.setColor('#f2e2cf');
    else this.txt?.setColor('#e8e2f2');
  }
}

// 避免循环依赖的小包装
import { typewrite } from '../ui/widget';
function require_typewrite(
  scene: Phaser.Scene,
  text: Phaser.GameObjects.Text,
  full: string,
): { done: boolean; skip: () => void } {
  return typewrite(scene, text, full, 34);
}
