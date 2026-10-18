import Phaser from 'phaser';

export class MenuScene extends Phaser.Scene {
  constructor() {
    super('MenuScene');
  }

  create() {
    const { width, height } = this.scale;

    this.add.text(width / 2, height / 2 - 80, '温州小侦探', {
      fontSize: '52px',
      color: '#ffd166',
      fontStyle: 'bold',
    }).setOrigin(0.5);

    this.add.text(width / 2, height / 2 - 20, '收集 5 个温州鱼丸，躲开捣蛋鬼', {
      fontSize: '22px',
      color: '#eeeeee',
    }).setOrigin(0.5);

    this.add.text(width / 2, height / 2 + 20, '方向键 或 WASD 移动', {
      fontSize: '18px',
      color: '#aaaaaa',
    }).setOrigin(0.5);

    const startBtn = this.add.text(width / 2, height / 2 + 100, '开始游戏', {
      fontSize: '32px',
      color: '#1a1a2e',
      backgroundColor: '#ffd166',
      padding: { x: 24, y: 12 },
    }).setOrigin(0.5).setInteractive({ useHandCursor: true });

    startBtn.on('pointerdown', () => this.scene.start('GameScene'));
    startBtn.on('pointerover', () => startBtn.setBackgroundColor('#ffffff'));
    startBtn.on('pointerout', () => startBtn.setBackgroundColor('#ffd166'));
  }
}
