/** 通用 UI 小件:按钮、面板、文字排版、水墨氛围粒子 */
import Phaser from 'phaser';
import { FONT, FONT_UI } from '../constants';

export function makeText(
  scene: Phaser.Scene,
  x: number,
  y: number,
  content: string,
  opts: {
    size?: number;
    color?: string;
    font?: 'serif' | 'ui';
    wrap?: number;
    align?: 'left' | 'center' | 'right';
    alpha?: number;
    bold?: boolean;
    lineSpacing?: number;
  } = {},
): Phaser.GameObjects.Text {
  const family = opts.font === 'ui' ? FONT_UI : FONT;
  const t = scene.add.text(x, y, content, {
    fontFamily: family,
    fontSize: `${opts.size ?? 20}px`,
    color: opts.color ?? '#e8e2f2',
    wordWrap: opts.wrap ? { width: opts.wrap } : undefined,
    align: opts.align ?? 'left',
    fontStyle: opts.bold ? 'bold' : 'normal',
    lineSpacing: opts.lineSpacing ?? 8,
  });
  t.setOrigin(opts.align === 'center' ? 0.5 : opts.align === 'right' ? 1 : 0, 0.5);
  t.setAlpha(opts.alpha ?? 1);
  return t;
}

export function makeButton(
  scene: Phaser.Scene,
  x: number,
  y: number,
  label: string,
  onClick: () => void,
  opts: { w?: number; h?: number; size?: number; accent?: number; ghost?: boolean } = {},
): Phaser.GameObjects.Container {
  const w = opts.w ?? 220;
  const h = opts.h ?? 54;
  const c = scene.add.container(x, y);

  const g = scene.add.graphics();
  g.fillStyle(opts.ghost ? 0x000000 : 0x14122a, 0.75);
  g.fillRoundedRect(-w / 2, -h / 2, w, h, 10);
  g.lineStyle(1.5, opts.accent ?? 0x8f7fc0, 0.9);
  g.strokeRoundedRect(-w / 2, -h / 2, w, h, 10);
  c.add(g);

  const txt = makeText(scene, 0, 0, label, { size: opts.size ?? 20, align: 'center' });
  txt.setOrigin(0.5);
  c.add(txt);

  g.setInteractive(new Phaser.Geom.Rectangle(-w / 2, -h / 2, w, h), Phaser.Geom.Rectangle.Contains);
  g.on('pointerover', () => {
    scene.tweens.add({ targets: c, scale: 1.05, duration: 120 });
    txt.setColor('#fff6d8');
  });
  g.on('pointerout', () => {
    scene.tweens.add({ targets: c, scale: 1, duration: 120 });
    txt.setColor('#e8e2f2');
  });
  g.on('pointerdown', () => scene.tweens.add({ targets: c, scale: 0.97, duration: 60, yoyo: true }));
  g.on('pointerup', onClick);
  return c;
}

/** 半透明叙事面板(对话框底) */
export function makePanel(
  scene: Phaser.Scene,
  x: number,
  y: number,
  w: number,
  h: number,
  alpha = 0.82,
): Phaser.GameObjects.Graphics {
  const g = scene.add.graphics();
  g.fillStyle(0x0a0918, alpha);
  g.fillRoundedRect(x, y, w, h, 14);
  g.lineStyle(1.5, 0x8f7fc0, 0.5);
  g.strokeRoundedRect(x, y, w, h, 14);
  return g;
}

/** 打字机效果,返回完成句柄 */
export interface TyperHandle {
  done: boolean;
  skip: () => void;
}

export function typewrite(
  scene: Phaser.Scene,
  text: Phaser.GameObjects.Text,
  full: string,
  speed = 28,
): TyperHandle {
  const handle: TyperHandle = { done: false, skip: () => {} };
  let i = 0;
  let timer: Phaser.Time.TimerEvent | null = scene.time.addEvent({
    delay: speed,
    loop: true,
    callback: () => {
      i += 1;
      text.setText(full.slice(0, i));
      if (i >= full.length) {
        timer?.remove();
        timer = null;
        handle.done = true;
      }
    },
  });
  handle.skip = () => {
    if (timer) {
      timer.remove();
      timer = null;
    }
    text.setText(full);
    handle.done = true;
  };
  return handle;
}

/** 萤火/星尘粒子氛围层 */
export function addAmbient(scene: Phaser.Scene, accent: number, count = 40): void {
  for (let i = 0; i < count; i++) {
    const x = Phaser.Math.Between(0, scene.scale.width);
    const y = Phaser.Math.Between(0, scene.scale.height);
    const s = scene.add.circle(x, y, Phaser.Math.FloatBetween(0.8, 2.2), accent, 0.7);
    s.setAlpha(Phaser.Math.FloatBetween(0.15, 0.6));
    scene.tweens.add({
      targets: s,
      y: y - Phaser.Math.Between(20, 70),
      alpha: 0.05,
      duration: Phaser.Math.Between(4000, 9000),
      repeat: -1,
      delay: Phaser.Math.Between(0, 5000),
      onRepeat: () => {
        s.x = Phaser.Math.Between(0, scene.scale.width);
        s.y = scene.scale.height + 10;
      },
    });
  }
}

/** 画一轮月相图案到 graphics(供月相轮/背景复用) */
export function drawMoonIcon(
  g: Phaser.GameObjects.Graphics,
  cx: number,
  cy: number,
  r: number,
  color: number,
  phaseIndex: number,
): void {
  // phaseIndex: 0朔 1峨眉 2弦 3盈凸 4望 5亏凸 6下弦 7残
  g.fillStyle(color, 1);
  if (phaseIndex === 0) {
    g.fillCircle(cx, cy, r * 0.35); // 朔:暗淡小盘
    return;
  }
  if (phaseIndex === 4) {
    g.fillCircle(cx, cy, r); // 望:满月
    return;
  }
  // 其余:用两个圆的并/差模拟月相
  const waxing = phaseIndex < 4; // 1,2,3 盈;5,6,7 亏
  const k = [0, 0.45, 0.75, 0.92, 1, 0.92, 0.75, 0.45][phaseIndex]; // 明亮比例
  g.fillCircle(cx, cy, r);
  // 用背景色圆偏移遮出月牙(近似)
  const dark = 0x0a0918;
  g.fillStyle(dark, 1);
  const off = (1 - k) * r * 2 * (waxing ? -1 : 1);
  g.fillCircle(cx + off * 0.62, cy, r * 0.98);
}
