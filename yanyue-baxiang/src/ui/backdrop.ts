/** 场景背景:程序化水墨夜景(天空渐变 + 月亮 + 山峦剪影 + 地面) */
import Phaser from 'phaser';
import { WorldTheme } from '../constants';

export function drawWorldBackground(
  scene: Phaser.Scene,
  theme: WorldTheme,
  phaseIndex: number,
): { groundY: number } {
  const W = scene.scale.width;
  const H = scene.scale.height;
  const groundY = H * 0.72;

  // 天空渐变
  const sky = scene.add.graphics();
  const top = Phaser.Display.Color.ValueToColor(theme.sky);
  const bottom = Phaser.Display.Color.ValueToColor(theme.hills[0]);
  for (let y = 0; y <= groundY; y += 4) {
    const t = y / groundY;
    const col = Phaser.Display.Color.Interpolate.ColorWithColor(top, bottom, 100, t);
    sky.fillStyle(Phaser.Display.Color.GetColor(col.r, col.g, col.b), 1);
    sky.fillRect(0, y, W, 4);
  }

  // 星
  for (let i = 0; i < 90; i++) {
    const s = scene.add.circle(
      Phaser.Math.Between(0, W),
      Phaser.Math.Between(0, groundY * 0.8),
      Phaser.Math.FloatBetween(0.5, 1.6),
      0xffffff,
    );
    s.setAlpha(Phaser.Math.FloatBetween(0.1, 0.7) * (phaseIndex === 0 ? 0.7 : 1));
    if (Math.random() < 0.25) {
      scene.tweens.add({
        targets: s,
        alpha: 0.05,
        duration: Phaser.Math.Between(1200, 3200),
        yoyo: true,
        repeat: -1,
      });
    }
  }

  // 月亮(右上)
  const mg = scene.add.graphics();
  const moonColor = phaseIndex === 0 ? 0x2a2a40 : theme.moon;
  mg.fillStyle(moonColor, phaseIndex === 0 ? 0.5 : 0.95);
  const mr = phaseIndex === 4 ? 46 : 38;
  mg.fillCircle(W - 180, 120, mr);
  if (phaseIndex !== 0 && phaseIndex !== 4) {
    // 月牙:遮暗圆
    const waxing = phaseIndex < 4;
    mg.fillStyle(theme.sky, 1);
    const k = [0, 0.45, 0.75, 0.92, 1, 0.92, 0.75, 0.45][phaseIndex];
    mg.fillCircle(W - 180 + (1 - k) * mr * 1.35 * (waxing ? -1 : 1), 120, mr * 0.96);
  }
  if (phaseIndex === 4) {
    mg.lineStyle(1.5, 0xfff6d8, 0.35);
    mg.strokeCircle(W - 180, 120, mr + 10);
  }

  // 山峦(两层剪影)
  const hills = scene.add.graphics();
  drawHills(hills, theme.hills[0], groundY, H, 140, 0.55);
  drawHills(hills, theme.hills[1], groundY, H, 90, 0.9);

  // 地面
  const gr = scene.add.graphics();
  gr.fillStyle(theme.ground, 1);
  gr.fillRect(0, groundY, W, H - groundY);
  // 地面微光线
  gr.lineStyle(1, theme.accent, 0.4);
  gr.lineBetween(0, groundY, W, groundY);

  return { groundY };
}

function drawHills(
  g: Phaser.GameObjects.Graphics,
  color: number,
  baseY: number,
  H: number,
  amp: number,
  alpha: number,
): void {
  const W = g.scene.scale.width;
  g.fillStyle(color, alpha);
  g.beginPath();
  g.moveTo(0, H);
  const seed = Phaser.Math.Between(1, 1000);
  for (let x = 0; x <= W; x += 16) {
    const y =
      baseY -
      amp * 0.5 -
      Math.sin((x + seed) * 0.004) * amp * 0.5 -
      Math.sin((x + seed * 2) * 0.011) * amp * 0.22;
    g.lineTo(x, y);
  }
  g.lineTo(W, H);
  g.closePath();
  g.fillPath();
}
