import Phaser from 'phaser';

export class ResultScene extends Phaser.Scene {
  constructor() {
    super('ResultScene');
  }

  init(data) {
    this.won = data.won ?? false;
    this.score = data.score ?? 0;
  }

  create() {
    const { width, height } = this.scale;

    if (this.won) {
      this.add.text(width / 2, height / 2 - 60, '挑战成功！', {
        fontSize: '56px',
        color: '#06d6a0',
        fontStyle: 'bold',
      }).setOrigin(0.5);
      this.add.text(width / 2, height / 2, '你收集齐了所有鱼丸', {
        fontSize: '24px',
        color: '#eeeeee',
      }).setOrigin(0.5);
    } else {
      this.add.text(width / 2, height / 2 - 60, '挑战失败', {
        fontSize: '56px',
        color: '#ef476f',
        fontStyle: 'bold',
      }).setOrigin(0.5);
      this.add.text(width / 2, height / 2, `收集了 ${this.score} / 5 个鱼丸`, {
        fontSize: '24px',
        color: '#eeeeee',
      }).setOrigin(0.5);
    }

    const retryBtn = this.add.text(width / 2, height / 2 + 100, '重新开始', {
      fontSize: '30px',
      color: '#1a1a2e',
      backgroundColor: '#ffd166',
      padding: { x: 24, y: 12 },
    }).setOrigin(0.5).setInteractive({ useHandCursor: true });

    retryBtn.on('pointerdown', () => this.scene.start('GameScene'));
    retryBtn.on('pointerover', () => retryBtn.setBackgroundColor('#ffffff'));
    retryBtn.on('pointerout', () => retryBtn.setBackgroundColor('#ffd166'));
  }
}
