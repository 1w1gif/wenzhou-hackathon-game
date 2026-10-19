/** 衍月的形象:程序化绘制的立绘(发梢缀星、星轨汉服) */
import Phaser from 'phaser';

export function drawYanyue(
  scene: Phaser.Scene,
  x: number,
  y: number,
  scale = 1,
): Phaser.GameObjects.Container {
  const c = scene.add.container(x, y);
  c.setScale(scale);

  const g = scene.add.graphics();

  // 袖袍(宽袖,下摆展开)
  g.fillStyle(0x2a2440, 1);
  g.fillEllipse(0, 46, 74, 84);
  // 腰身
  g.fillStyle(0x37305a, 1);
  g.fillRoundedRect(-20, 6, 40, 52, 12);
  // 左右大袖
  g.fillStyle(0x2a2440, 1);
  g.fillEllipse(-40, 26, 36, 58);
  g.fillEllipse(40, 26, 36, 58);
  // 袖口月白
  g.fillStyle(0xd8d2e6, 0.9);
  g.fillEllipse(-40, 52, 22, 14);
  g.fillEllipse(40, 52, 22, 14);
  // 腰带
  g.fillStyle(0x8f7fc0, 1);
  g.fillRect(-20, 30, 40, 7);
  // 星轨纹(腰带上的银线)
  g.lineStyle(1, 0xd8d2e6, 0.8);
  g.lineBetween(-16, 33.5, 16, 33.5);

  // 头
  g.fillStyle(0xf2e2cf, 1);
  g.fillCircle(0, -18, 15);
  // 发(上髻)
  g.fillStyle(0x1a1626, 1);
  g.fillEllipse(0, -30, 34, 26);
  g.fillCircle(0, -40, 9);
  // 发簪
  g.lineStyle(2, 0xd8cfa8, 1);
  g.lineBetween(-16, -36, 14, -46);
  g.fillStyle(0xfff6d8, 1);
  g.fillCircle(14, -46, 2.5);

  // 发梢星光
  g.fillStyle(0xfff6d8, 0.9);
  g.fillCircle(-12, -44, 1.4);
  g.fillCircle(-16, -39, 1.1);
  g.fillCircle(8, -48, 1.2);
  g.fillStyle(0xd8d2e6, 0.7);
  g.fillCircle(11, -40, 1);
  g.fillCircle(-6, -49, 1);

  // 眼(低垂)
  g.fillStyle(0x1a1626, 1);
  g.fillRect(-7, -19, 4, 1.5);
  g.fillRect(3, -19, 4, 1.5);
  // 唇
  g.fillStyle(0xc06060, 0.9);
  g.fillRect(-2, -12, 4, 1.5);

  c.add(g);

  // 环绕星光微闪
  for (let i = 0; i < 6; i++) {
    const star = scene.add.circle(
      Phaser.Math.Between(-34, 34),
      Phaser.Math.Between(-52, 60),
      Phaser.Math.FloatBetween(0.8, 1.6),
      0xfff6d8,
    );
    star.setAlpha(0.4);
    c.add(star);
    scene.tweens.add({
      targets: star,
      alpha: 0.9,
      scale: 1.4,
      duration: Phaser.Math.Between(900, 1800),
      yoyo: true,
      repeat: -1,
      delay: Phaser.Math.Between(0, 1500),
    });
  }

  return c;
}

/** 小尺寸行走立绘(2.5D 世界中的衍月,含行走摇摆) */
export function drawYanyueWalker(scene: Phaser.Scene, x: number, y: number): Phaser.GameObjects.Container {
  const c = scene.add.container(x, y);
  const g = scene.add.graphics();
  // 裙摆
  g.fillStyle(0x2a2440, 1);
  g.fillTriangle(-11, 8, 11, 8, 0, -14);
  // 身
  g.fillStyle(0x37305a, 1);
  g.fillRoundedRect(-8, -26, 16, 24, 5);
  // 头
  g.fillStyle(0xf2e2cf, 1);
  g.fillCircle(0, -33, 7);
  // 发
  g.fillStyle(0x1a1626, 1);
  g.fillCircle(0, -36, 7.4);
  g.slice(0, -36, 7.4, Phaser.Math.DegToRad(200), Phaser.Math.DegToRad(340), false);
  // 发簪星光
  g.fillStyle(0xfff6d8, 1);
  g.fillCircle(4, -41, 1.3);
  g.fillCircle(-4, -40, 1);
  c.add(g);
  return c;
}
