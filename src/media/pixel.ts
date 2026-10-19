import Phaser from 'phaser';

export const PIXEL = {
  ink: 0x161821, ink2: 0x282b39, ink3: 0x45495d,
  paper: 0xd8d1bd, paper2: 0xb9b19e,
  moon: 0xc5eef0, cyan: 0x75cbd1,
  red: 0xc9504c, gold: 0xd6a85d, fire: 0xf08a53,
};

function canvas(scene: Phaser.Scene, key: string, w: number, h: number, draw: (g: CanvasRenderingContext2D) => void) {
  if (scene.textures.exists(key)) return;
  const t = scene.textures.createCanvas(key, w, h)!;
  draw(t.getContext());
  t.refresh();
}

function actor(ctx: CanvasRenderingContext2D, kind: 'hero'|'shenyan'|'bandit'|'thrower'|'boss') {
  const c = kind === 'hero' ? PIXEL.ink : kind === 'shenyan' ? PIXEL.ink2 : PIXEL.ink;
  const rgb = (n: number) => `#${n.toString(16).padStart(6, '0')}`;
  ctx.imageSmoothingEnabled = false;
  ctx.fillStyle = rgb(c); ctx.fillRect(12, 18, 24, 39);
  ctx.fillRect(16, 10, 16, 14); ctx.fillRect(7, 24, 34, 20);
  ctx.fillRect(16, 54, 8, 22); ctx.fillRect(27, 54, 8, 22);
  ctx.fillStyle = rgb(kind === 'hero' ? PIXEL.red : kind === 'boss' ? PIXEL.gold : PIXEL.paper2);
  ctx.fillRect(11, 18, 26, 4);
  if (kind === 'hero') { ctx.fillStyle = rgb(PIXEL.moon); ctx.fillRect(34, 8, 5, 5); ctx.fillRect(39, 3, 3, 3); ctx.fillStyle = rgb(PIXEL.gold); ctx.fillRect(5, 17, 4, 34); }
  if (kind === 'shenyan') { ctx.fillStyle = rgb(PIXEL.moon); ctx.fillRect(20, 24, 8, 2); ctx.fillRect(28, 24, 2, 8); }
  if (kind === 'bandit' || kind === 'thrower' || kind === 'boss') { ctx.fillStyle = rgb(kind === 'boss' ? PIXEL.red : PIXEL.red); ctx.fillRect(12, 10, 25, 5); }
  if (kind === 'thrower') { ctx.fillStyle = rgb(PIXEL.fire); ctx.fillRect(38, 22, 7, 7); ctx.fillRect(42, 18, 4, 4); }
  if (kind === 'boss') { ctx.fillStyle = rgb(PIXEL.gold); ctx.fillRect(7, 7, 6, 8); ctx.fillRect(37, 7, 6, 8); ctx.fillRect(41, 30, 8, 4); }
}

export function createPixelTextures(scene: Phaser.Scene): void {
  canvas(scene, 'yanyue', 48, 88, c => actor(c, 'hero'));
  canvas(scene, 'shenyan', 48, 88, c => actor(c, 'shenyan'));
  canvas(scene, 'bandit', 48, 80, c => actor(c, 'bandit'));
  canvas(scene, 'thrower', 48, 80, c => actor(c, 'thrower'));
  canvas(scene, 'boss', 56, 96, c => actor(c, 'boss'));
  canvas(scene, 'moon', 128, 128, c => {
    c.fillStyle = '#c5eef0'; c.beginPath(); c.arc(64, 64, 45, 0, Math.PI * 2); c.fill();
    c.fillStyle = '#9dbdc2'; c.fillRect(38, 40, 12, 7); c.fillRect(70, 73, 18, 9); c.fillRect(77, 34, 8, 6);
  });
  canvas(scene, 'moonwheel', 96, 96, c => {
    c.fillStyle = '#252431'; c.beginPath(); c.arc(48, 48, 40, 0, Math.PI * 2); c.fill();
    c.strokeStyle = '#d6a85d'; c.lineWidth = 4; c.beginPath(); c.arc(48, 48, 39, 0, Math.PI * 2); c.stroke();
    c.fillStyle = '#c5eef0'; c.beginPath(); c.arc(48, 48, 12, 0, Math.PI * 2); c.fill();
    for (let i = 0; i < 8; i++) { const a = i * Math.PI / 4; c.fillStyle = i % 2 ? '#75cbd1' : '#f2e7c8'; c.fillRect(46 + Math.cos(a) * 30, 46 + Math.sin(a) * 30, 4, 4); }
  });
  canvas(scene, 'star', 16, 16, c => { c.fillStyle = '#c5eef0'; c.fillRect(7, 0, 2, 16); c.fillRect(0, 7, 16, 2); c.fillStyle = '#ffffff'; c.fillRect(5, 5, 6, 6); });
  canvas(scene, 'lantern', 24, 32, c => { c.fillStyle = '#c9504c'; c.fillRect(5, 6, 14, 20); c.fillStyle = '#f08a53'; c.fillRect(8, 9, 8, 14); c.fillStyle = '#d6a85d'; c.fillRect(9, 0, 6, 6); });
  canvas(scene, 'slash', 64, 24, c => { c.fillStyle = '#c5eef0'; c.fillRect(4, 17, 50, 3); c.fillRect(12, 11, 42, 3); c.fillStyle = '#ffffff'; c.fillRect(20, 5, 28, 2); });
  canvas(scene, 'paper', 32, 32, c => { c.fillStyle = '#d8d1bd'; c.fillRect(0, 0, 32, 32); c.fillStyle = '#c5bda9'; for (let i = 0; i < 60; i++) c.fillRect(Math.random() * 32, Math.random() * 32, 1, 1); });
}

export function drawPixelBackground(g: Phaser.GameObjects.Graphics, width: number, height: number): void {
  g.fillStyle(0x11131d, 1); g.fillRect(0, 0, width, height);
  g.fillStyle(0x1b2735, 1); g.fillTriangle(width * .1, height, width * .43, height * .18, width * .72, height);
  g.fillStyle(0x202d3a, 1); g.fillTriangle(width * .48, height, width * .76, height * .28, width * 1.05, height);
  g.fillStyle(0x75cbd1, .08); g.fillCircle(width * .78, height * .18, 110);
}
