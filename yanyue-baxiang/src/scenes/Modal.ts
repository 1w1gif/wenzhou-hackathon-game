/** 通用信息弹窗 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H } from '../constants';
import { makeText, makePanel, makeButton } from '../ui/widget';

interface ModalData {
  title: string;
  body: string;
}

export class ModalScene extends Phaser.Scene {
  constructor() {
    super('Modal');
  }

  create(data: ModalData): void {
    const W = VIEW_W;
    const H = VIEW_H;
    this.add.rectangle(W / 2, H / 2, W, H, 0x05040c, 0.7).setInteractive();
    makePanel(this, W * 0.24, H * 0.28, W * 0.52, H * 0.44, 0.96);
    makeText(this, W / 2, H * 0.34, data.title, { size: 28, align: 'center', color: '#f2ecda' });
    makeText(this, W / 2, H * 0.47, data.body, {
      size: 18,
      align: 'center',
      wrap: W * 0.44,
      lineSpacing: 10,
      color: '#c8c2da',
    });
    makeButton(this, W / 2, H * 0.64, '知道了', () => this.close(), { w: 170, h: 46 });
    this.input.keyboard!.once('keydown-ESC', () => this.close());
  }

  private close(): void {
    this.scene.stop('Modal');
    const town = this.scene.get('Town');
    if (town && town.scene.isActive()) {
      (town as unknown as { interacting: boolean }).interacting = false;
    }
  }
}
