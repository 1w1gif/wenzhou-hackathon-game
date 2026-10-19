/**
 * 通用 UI 小件：面板、按钮、文字、月相圆盘。
 * 做法沿用旧原型 ui/widget.ts：圆角面板 + 描边、悬停放大的幽灵按钮、月相双圆相减。
 */
import Phaser from 'phaser';

export const UI_ACCENT = 0x8f7fc0;
export const UI_GOLD = 0xd8cfa8;
export const UI_MOON = 0xfff6d8;
export const UI_TEXT = '#e8e2f2';

/** 八相配色：从冷寂到丰盈再归于萧瑟（下标 = moonPhaseIndex） */
export const PHASE_STYLE: Array<{ moon: number; accent: number }> = [
  { moon: 0x1c1c2e, accent: 0x3a3a6e }, // 新月
  { moon: 0xc8c2da, accent: 0x6f5fa8 }, // 蛾眉
  { moon: 0xd8d2e6, accent: 0x8f7fc0 }, // 弦月
  { moon: 0xe6e0f0, accent: 0xa8a0d8 }, // 盈凸
  { moon: 0xfff6d8, accent: 0xd8cfa8 }, // 望
  { moon: 0xeae2f2, accent: 0xb0a8d0 }, // 亏凸
  { moon: 0xd6d0e0, accent: 0x8a84b8 }, // 下弦
  { moon: 0xb8b2c8, accent: 0x5a4a80 }, // 残月
];

export function makePanel(
  scene: Phaser.Scene,
  x: number,
  y: number,
  w: number,
  h: number,
  alpha = 0.94
): Phaser.GameObjects.Graphics {
  const g = scene.add.graphics();
  g.fillStyle(0x0a0918, alpha);
  g.fillRoundedRect(x, y, w, h, 6);
  g.lineStyle(1, UI_ACCENT, 0.5);
  g.strokeRoundedRect(x, y, w, h, 6);
  return g;
}

export function makeButton(
  scene: Phaser.Scene,
  x: number,
  y: number,
  label: string,
  onClick: () => void,
  opts: { w?: number; h?: number; size?: number; accent?: number; ghost?: boolean } = {}
): Phaser.GameObjects.Container {
  const w = opts.w ?? 64;
  const h = opts.h ?? 20;
  const c = scene.add.container(x, y);
  const g = scene.add.graphics();
  g.fillStyle(opts.ghost ? 0x000000 : 0x14122a, 0.75);
  g.fillRoundedRect(-w / 2, -h / 2, w, h, 4);
  g.lineStyle(1, opts.accent ?? UI_ACCENT, 0.9);
  g.strokeRoundedRect(-w / 2, -h / 2, w, h, 4);
  c.add(g);

  const txt = scene.add.text(0, 0, label, {
    fontFamily: 'serif',
    fontSize: `${opts.size ?? 9}px`,
    color: UI_TEXT,
  }).setOrigin(0.5);
  c.add(txt);

  g.setInteractive(new Phaser.Geom.Rectangle(-w / 2, -h / 2, w, h), Phaser.Geom.Rectangle.Contains);
  g.input!.cursor = 'pointer';
  g.on('pointerover', () => { scene.tweens.add({ targets: c, scale: 1.05, duration: 110 }); txt.setColor('#fff6d8'); });
  g.on('pointerout', () => { scene.tweens.add({ targets: c, scale: 1, duration: 110 }); txt.setColor(UI_TEXT); });
  g.on('pointerdown', () => scene.tweens.add({ targets: c, scale: 0.96, duration: 60, yoyo: true }));
  g.on('pointerup', onClick);
  return c;
}

/**
 * 画月相圆盘（双圆相减近似）。
 * phaseIndex: 0 朔 · 1 蛾眉 · 2 弦 · 3 盈凸 · 4 望 · 5 亏凸 · 6 下弦 · 7 残
 */
export function drawMoonPhase(
  g: Phaser.GameObjects.Graphics,
  cx: number,
  cy: number,
  r: number,
  color: number,
  phaseIndex: number
): void {
  g.fillStyle(color, 1);
  if (phaseIndex === 0) {
    g.fillCircle(cx, cy, r * 0.4);
    return;
  }
  if (phaseIndex === 4) {
    g.fillCircle(cx, cy, r);
    return;
  }
  const waxing = phaseIndex < 4;
  const k = [0, 0.45, 0.75, 0.9, 1, 0.9, 0.75, 0.45][phaseIndex];
  g.fillCircle(cx, cy, r);
  const off = (1 - k) * r * 2 * (waxing ? -1 : 1);
  g.fillStyle(0x0a0918, 1);
  g.fillCircle(cx + off * 0.62, cy, r * 0.98);
}