import Phaser from 'phaser';

export class GameScene extends Phaser.Scene {
  constructor() {
    super('GameScene');
  }

  create() {
    const { width, height } = this.scale;
    const W = 20;

    // 游戏状态
    this.score = 0;
    this.timeLeft = 30;
    this.gameEnded = false;

    // 地面边界（用图形代替素材，之后可换图片）
    this.add.rectangle(width / 2, height / 2, width, height, 0x16213e);

    // 运行时生成一个白色方块纹理，之后可替换成角色和物品图片
    if (!this.textures.exists('block')) {
      const g = this.make.graphics({ x: 0, y: 0, add: false });
      g.fillStyle(0xffffff, 1);
      g.fillRect(0, 0, 32, 32);
      g.generateTexture('block', 32, 32);
      g.destroy();
    }

    // 玩家（黄色方块，之后可换成角色图片）
    this.player = this.physics.add.sprite(width / 2, height / 2, 'block').setDisplaySize(40, 40).setTint(0xffd166);
    this.player.setCollideWorldBounds(true);

    // 键盘：方向键 + WASD
    this.cursors = this.input.keyboard.createCursorKeys();
    this.keys = this.input.keyboard.addKeys('W,A,S,D');

    // 收集物：5 个绿色圆点（鱼丸占位）
    this.collectibles = this.physics.add.group();
    for (let i = 0; i < 5; i++) {
      const x = Phaser.Math.Between(60, width - 60);
      const y = Phaser.Math.Between(60, height - 100);
      const c = this.collectibles.create(x, y, 'block').setDisplaySize(28, 28).setTint(0x06d6a0);
    }

    // 障碍：3 个红色捣蛋鬼，来回巡逻（离玩家出生点至少 150px，避免开局秒输）
    this.obstacles = this.physics.add.group();
    for (let i = 0; i < 3; i++) {
      let x, y;
      do {
        x = Phaser.Math.Between(100, width - 100);
        y = Phaser.Math.Between(100, height - 100);
      } while (Phaser.Math.Distance.Between(x, y, this.player.x, this.player.y) < 150);
      const o = this.obstacles.create(x, y, 'block').setDisplaySize(36, 36).setTint(0xef476f);
      o.setVelocity(Phaser.Math.Between(-120, 120), Phaser.Math.Between(-120, 120));
      o.setBounce(1);
      o.setCollideWorldBounds(true);
    }

    // 碰撞：收集 / 被抓
    this.physics.add.overlap(this.player, this.collectibles, (_player, c) => {
      c.destroy();
      this.score += 1;
      this.scoreText.setText(`鱼丸: ${this.score} / 5`);
      if (this.score >= 5) this.endGame(true);
    });
    this.physics.add.overlap(this.player, this.obstacles, () => this.endGame(false));

    // HUD：分数 + 倒计时
    this.scoreText = this.add.text(16, 16, '鱼丸: 0 / 5', { fontSize: '24px', color: '#ffffff' });
    this.timeText = this.add.text(width - 16, 16, '剩余: 30', { fontSize: '24px', color: '#ffffff' }).setOrigin(1, 0);

    this.time.addEvent({
      delay: 1000,
      loop: true,
      callback: () => {
        if (this.gameEnded) return;
        this.timeLeft -= 1;
        this.timeText.setText(`剩余: ${this.timeLeft}`);
        if (this.timeLeft <= 0) this.endGame(false);
      },
    });
  }

  update() {
    if (this.gameEnded) return;

    const speed = 260;
    const dir = { x: 0, y: 0 };
    if (this.cursors.left.isDown || this.keys.A.isDown) dir.x = -1;
    if (this.cursors.right.isDown || this.keys.D.isDown) dir.x = 1;
    if (this.cursors.up.isDown || this.keys.W.isDown) dir.y = -1;
    if (this.cursors.down.isDown || this.keys.S.isDown) dir.y = 1;

    this.player.setVelocity(dir.x * speed, dir.y * speed);
  }

  endGame(won) {
    if (this.gameEnded) return;
    this.gameEnded = true;
    this.scene.start('ResultScene', { won, score: this.score });
  }
}
