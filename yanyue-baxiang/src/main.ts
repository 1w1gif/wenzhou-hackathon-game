/** 主入口:Phaser 配置与场景注册,HUD 常驻层 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H } from './constants';
import { getState } from './state';
import { TitleScene, IntroScene } from './scenes/Title';
import { TownScene } from './scenes/Town';
import { DivergeScene } from './scenes/Diverge';
import { WarpScene } from './scenes/Warp';
import { WheelScene } from './scenes/Wheel';
import { JournalScene } from './scenes/Journal';
import { TreeScene } from './scenes/Tree';
import { FinaleScene } from './scenes/Finale';
import { ModalScene } from './scenes/Modal';
import { makeText } from './ui/widget';
import { CLUES } from './data/script';

class HudScene extends Phaser.Scene {
  constructor() {
    super('Hud');
  }

  create(): void {
    const W = VIEW_W;
    const H = VIEW_H;

    const clueBtn = makeText(this, 36, H - 30, '📖 引月札', {
      size: 17,
      color: '#d8cfa8',
      font: 'ui',
    });
    clueBtn.setInteractive({ useHandCursor: true });
    clueBtn.on('pointerup', () => this.scene.launch('Journal'));

    const wheelBtn = makeText(this, W - 140, H - 30, '☾ 月相轮', {
      size: 17,
      color: '#d8cfa8',
      font: 'ui',
      align: 'right',
    });
    wheelBtn.setInteractive({ useHandCursor: true });
    wheelBtn.on('pointerup', () => this.openWheel());

    const treeBtn = makeText(this, W - 36, H - 30, '✦ 时空树', {
      size: 17,
      color: '#d8cfa8',
      font: 'ui',
      align: 'right',
    });
    treeBtn.setInteractive({ useHandCursor: true });
    treeBtn.on('pointerup', () => this.scene.launch('Tree'));

    // 线索计数
    const clueCount = makeText(this, 120, H - 30, '', { size: 13, color: '#8f7fc0', font: 'ui' });
    this.events.on('prefab-update', () => {});
    this.time.addEvent({
      delay: 500,
      loop: true,
      callback: () => {
        const s = getState();
        clueCount.setText(`线索 ${s.clues.length}/${Object.keys(CLUES).length}`);
      },
    });
  }

  private openWheel(): void {
    const town = this.scene.get('Town');
    if (town && town.scene.isActive()) {
      (town as unknown as { openWheel: () => void }).openWheel();
    }
  }
}

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  width: VIEW_W,
  height: VIEW_H,
  parent: 'game',
  backgroundColor: '#07060e',
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  scene: [TitleScene, IntroScene, TownScene, DivergeScene, WarpScene, WheelScene, JournalScene, TreeScene, FinaleScene, ModalScene, HudScene],
};

const game = new Phaser.Game(config);
(window as unknown as { __phaserGame?: Phaser.Game }).__phaserGame = game;
