/**
 * 程序化水墨素材工厂：全部用 Phaser Graphics 生成纹理。
 * 风格：宣纸底色 + 墨色 + 月光留白，无外部素材也能运行。
 */
import Phaser from 'phaser';

export const PALETTE = {
  paper: 0xf0ead8,      // 宣纸米白
  paperDark: 0xe2dac2,
  ink: 0x2a2a30,        // 浓墨
  inkMid: 0x4a4a52,     // 中墨
  inkLight: 0x8a8a90,   // 淡墨
  moonWhite: 0xf5f2e8,  // 月白
  moonBlue: 0xb8c8c8,   // 淡青月光
  cinnabar: 0xa83232,   // 朱砂
  gold: 0xb8924a,       // 暗金
};

export type YanyueAnims = 'idle' | 'run' | 'jump' | 'cling';

/** 生成衍月剪影 spritesheet：待机 / 跑 / 跳 / 攀墙 各 4 帧 */
export function makeYanyueSheet(scene: Phaser.Scene): void {
  const W = 64, H = 88, FRAMES = 16;
  const canvasTex = scene.textures.createCanvas('yanyue', W * FRAMES, H)!;
  const g = canvasTex.getContext();

  const drawFrame = (i: number, pose: YanyueAnims, f: number) => {
    const ox = i * W;
    g.save();
    g.translate(ox, 0);
    // 身体主剪影（束袖劲装 + 高马尾 + 背剑）
    const bob = pose === 'idle' ? Math.sin(f * Math.PI / 2) * 1.5 : 0;
    const legSwing = pose === 'run' ? Math.sin(f * Math.PI / 2) * 8 : 0;
    const armSwing = pose === 'run' ? -Math.sin(f * Math.PI / 2) * 6 : 0;
    const lean = pose === 'run' ? 4 : 0;

    g.fillStyle = rgba(PALETTE.ink, 0.95);
    // 头
    g.beginPath(); g.arc(32 + lean * 0.4, 16 + bob, 8, 0, Math.PI * 2); g.fill();
    // 高马尾（发梢星光用月白点）
    g.beginPath();
    g.moveTo(36 + lean, 12 + bob);
    g.quadraticCurveTo(48 + armSwing, 18 + bob, 50 + armSwing, 34 + bob);
    g.quadraticCurveTo(44, 24 + bob, 38, 20 + bob);
    g.fill();
    g.fillStyle = rgba(PALETTE.moonWhite, 0.9);
    g.beginPath(); g.arc(50 + armSwing, 34 + bob, 1.6, 0, Math.PI * 2); g.fill();
    g.beginPath(); g.arc(46 + armSwing, 28 + bob, 1.2, 0, Math.PI * 2); g.fill();
    // 躯干（束袖劲装）
    g.fillStyle = rgba(PALETTE.ink, 0.92);
    g.beginPath();
    g.moveTo(24 + lean, 24 + bob);
    g.lineTo(40 + lean, 24 + bob);
    g.lineTo(38 + lean, 52 + bob);
    g.lineTo(26 + lean, 52 + bob);
    g.closePath(); g.fill();
    // 腰带（朱砂）
    g.fillStyle = rgba(PALETTE.cinnabar, 0.85);
    g.fillRect(25 + lean, 40 + bob, 14, 3);
    // 背剑（剑柄在肩上，斜负）
    g.strokeStyle = rgba(PALETTE.gold, 0.95);
    g.lineWidth = 3;
    g.beginPath();
    g.moveTo(22 + lean, 26 + bob);
    g.lineTo(44 - lean * 0.5, 8 + bob);
    g.stroke();
    // 腿
    g.strokeStyle = rgba(PALETTE.ink, 0.92);
    g.lineWidth = 6;
    g.beginPath(); g.moveTo(29, 52 + bob); g.lineTo(28 + legSwing, 76 + bob); g.stroke();
    g.beginPath(); g.moveTo(35, 52 + bob); g.lineTo(36 - legSwing, 76 + bob); g.stroke();
    // 广袖手臂
    g.lineWidth = 7;
    g.beginPath(); g.moveTo(26, 28 + bob); g.lineTo(20 + armSwing, 44 + bob); g.stroke();
    g.beginPath(); g.moveTo(38, 28 + bob); g.lineTo(44 - armSwing, 44 + bob); g.stroke();

    if (pose === 'jump') {
      // 收腿
      g.lineWidth = 6;
      g.beginPath(); g.moveTo(29, 52); g.lineTo(26, 68); g.stroke();
      g.beginPath(); g.moveTo(35, 52); g.lineTo(40, 66); g.stroke();
    }
    if (pose === 'cling') {
      // 面向墙、单手扣墙姿态
      g.lineWidth = 7;
      g.beginPath(); g.moveTo(26, 28); g.lineTo(48, 24); g.stroke();
    }
    g.restore();
  };

  // 帧 0-3 idle, 4-7 run, 8-10 jump, 11-13 cling, 14-15 attack pose
  for (let i = 0; i < 16; i++) {
    if (i < 4) drawFrame(i, 'idle', i);
    else if (i < 8) drawFrame(i, 'run', i - 4);
    else if (i < 11) drawFrame(i, 'jump', 0);
    else if (i < 14) drawFrame(i, 'cling', 0);
    else drawFrame(i, 'run', 1);
  }
  canvasTex.refresh();
}

/** 生成沈砚剪影（交领长袍，浓墨，可叠加被侵蚀纹路） */
export function makeShenyanSheet(scene: Phaser.Scene): void {
  const W = 64, H = 88, FRAMES = 8;
  const tex = scene.textures.createCanvas('shenyan', W * FRAMES, H)!;
  const g = tex.getContext();
  for (let i = 0; i < FRAMES; i++) {
    const ox = i * W;
    const bob = Math.sin(i * Math.PI / 4) * 1.2;
    g.save(); g.translate(ox, 0);
    // 头 + 束发
    g.fillStyle = rgba(PALETTE.ink, 0.95);
    g.beginPath(); g.arc(32, 15 + bob, 8, 0, Math.PI * 2); g.fill();
    g.fillRect(28, 5 + bob, 8, 6);
    // 交领长袍（梯形袍身）
    g.beginPath();
    g.moveTo(22, 24 + bob);
    g.lineTo(42, 24 + bob);
    g.lineTo(48, 78);
    g.lineTo(16, 78);
    g.closePath(); g.fill();
    // 交领（月白 V 领）
    g.strokeStyle = rgba(PALETTE.moonWhite, 0.7);
    g.lineWidth = 2;
    g.beginPath(); g.moveTo(28, 24 + bob); g.lineTo(32, 36 + bob); g.lineTo(38, 24 + bob); g.stroke();
    // 玉佩（淡青）
    g.fillStyle = rgba(PALETTE.moonBlue, 0.9);
    g.fillRect(38, 42 + bob, 4, 6);
    g.restore();
  }
  tex.refresh();
}

/** 强盗（环首刀+朱红头巾）与投掷劫匪 */
export function makeBanditSheet(scene: Phaser.Scene, key: string, thrower: boolean): void {
  const W = 56, H = 80, FRAMES = 6;
  const tex = scene.textures.createCanvas(key, W * FRAMES, H)!;
  const g = tex.getContext();
  for (let i = 0; i < FRAMES; i++) {
    const ox = i * W;
    const swing = Math.sin(i * Math.PI / 3) * 10;
    g.save(); g.translate(ox, 0);
    g.fillStyle = rgba(PALETTE.inkMid, 0.95);
    g.beginPath(); g.arc(28, 16, 7.5, 0, Math.PI * 2); g.fill();
    // 朱红头巾
    g.fillStyle = rgba(PALETTE.cinnabar, 0.95);
    g.fillRect(20, 8, 16, 6);
    // 短打身体
    g.beginPath();
    g.moveTo(20, 24); g.lineTo(36, 24);
    g.lineTo(39, 54); g.lineTo(17, 54);
    g.closePath(); g.fill();
    // 武器
    g.strokeStyle = rgba(PALETTE.ink, 0.95);
    g.lineWidth = 4;
    if (thrower) {
      // 火把（朱红光点）
      g.beginPath(); g.moveTo(36, 30); g.lineTo(44, 24 + swing * 0.3); g.stroke();
      g.fillStyle = rgba(0xd8763a, 0.95);
      g.beginPath(); g.arc(45, 22 + swing * 0.3, 4, 0, Math.PI * 2); g.fill();
    } else {
      g.beginPath(); g.moveTo(36, 30); g.lineTo(46, 30 + swing); g.stroke();
    }
    // 腿
    g.lineWidth = 5;
    g.beginPath(); g.moveTo(24, 54); g.lineTo(22 + swing * 0.5, 74); g.stroke();
    g.beginPath(); g.moveTo(32, 54); g.lineTo(34 - swing * 0.5, 74); g.stroke();
    g.restore();
  }
  tex.refresh();
}

/** 神秘观测者（斗笠旅人） */
export function makeObserverTex(scene: Phaser.Scene): void {
  const tex = scene.textures.createCanvas('observer', 64, 88)!;
  const g = tex.getContext();
  g.fillStyle = rgba(PALETTE.inkLight, 0.9);
  // 斗笠
  g.beginPath(); g.moveTo(12, 20); g.lineTo(52, 20); g.lineTo(32, 6); g.closePath(); g.fill();
  // 蓑衣（枯笔三角）
  g.beginPath(); g.moveTo(32, 20); g.lineTo(52, 80); g.lineTo(12, 80); g.closePath(); g.fill();
  tex.refresh();
}

/** 生成纸纹理背景（宣纸质感，带噪点与飞白） */
export function makePaperTex(scene: Phaser.Scene): void {
  const W = 512, H = 512;
  const tex = scene.textures.createCanvas('paper', W, H)!;
  const g = tex.getContext();
  g.fillStyle = '#f0ead8';
  g.fillRect(0, 0, W, H);
  // 纤维噪点
  for (let i = 0; i < 2400; i++) {
    const a = 0.02 + Math.random() * 0.05;
    g.fillStyle = Math.random() > 0.5
      ? `rgba(120,110,90,${a})`
      : `rgba(255,252,240,${a * 1.6})`;
    g.fillRect(Math.random() * W, Math.random() * H, 1 + Math.random() * 2, 1);
  }
  // 淡墨晕染斑块
  for (let i = 0; i < 14; i++) {
    const x = Math.random() * W, y = Math.random() * H, r = 30 + Math.random() * 80;
    const grad = g.createRadialGradient(x, y, 0, x, y, r);
    grad.addColorStop(0, 'rgba(90,90,100,0.05)');
    grad.addColorStop(1, 'rgba(90,90,100,0)');
    g.fillStyle = grad;
    g.fillRect(x - r, y - r, r * 2, r * 2);
  }
  tex.refresh();
}

/** 满月纹理（留白 + 淡墨晕圈） */
export function makeMoonTex(scene: Phaser.Scene): void {
  const S = 256;
  const tex = scene.textures.createCanvas('moon', S, S)!;
  const g = tex.getContext();
  const cx = S / 2;
  const grad = g.createRadialGradient(cx, cx, 40, cx, cx, 120);
  grad.addColorStop(0, 'rgba(245,242,232,1)');
  grad.addColorStop(0.72, 'rgba(245,242,232,0.95)');
  grad.addColorStop(0.85, 'rgba(232,228,210,0.35)');
  grad.addColorStop(1, 'rgba(232,228,210,0)');
  g.fillStyle = grad;
  g.fillRect(0, 0, S, S);
  // 月面淡墨
  g.fillStyle = 'rgba(180,175,160,0.25)';
  g.beginPath(); g.arc(cx - 30, cx - 20, 22, 0, Math.PI * 2); g.fill();
  g.beginPath(); g.arc(cx + 25, cx + 30, 14, 0, Math.PI * 2); g.fill();
  g.beginPath(); g.arc(cx + 40, cx - 35, 9, 0, Math.PI * 2); g.fill();
  tex.refresh();
}

/** 墨迹圆点（敌人死亡墨雾粒子） */
export function makeInkDot(scene: Phaser.Scene): void {
  const S = 32;
  const tex = scene.textures.createCanvas('inkdot', S, S)!;
  const g = tex.getContext();
  const grad = g.createRadialGradient(S / 2, S / 2, 2, S / 2, S / 2, S / 2);
  grad.addColorStop(0, 'rgba(42,42,48,0.95)');
  grad.addColorStop(0.7, 'rgba(42,42,48,0.6)');
  grad.addColorStop(1, 'rgba(42,42,48,0)');
  g.fillStyle = grad;
  g.fillRect(0, 0, S, S);
  tex.refresh();
}

/** 星光（收集品） */
export function makeStarTex(scene: Phaser.Scene): void {
  const S = 28;
  const tex = scene.textures.createCanvas('star', S, S)!;
  const g = tex.getContext();
  g.strokeStyle = 'rgba(184,200,200,0.95)';
  g.fillStyle = 'rgba(245,242,232,0.9)';
  g.lineWidth = 1.5;
  g.beginPath();
  g.moveTo(S / 2, 2); g.lineTo(S / 2 + 4, S / 2 - 4); g.lineTo(S - 2, S / 2);
  g.lineTo(S / 2 + 4, S / 2 + 4); g.lineTo(S / 2, S - 2);
  g.lineTo(S / 2 - 4, S / 2 + 4); g.lineTo(2, S / 2);
  g.lineTo(S / 2 - 4, S / 2 - 4);
  g.closePath(); g.fill(); g.stroke();
  tex.refresh();
}

/** 月相轮纹理（暗金圆盘 + 八相刻度） */
export function makeMoonWheelTex(scene: Phaser.Scene): void {
  const S = 128;
  const tex = scene.textures.createCanvas('moonwheel', S, S)!;
  const g = tex.getContext();
  const cx = S / 2, r = 52;
  // 盘底
  const grad = g.createRadialGradient(cx, cx, 10, cx, cx, r);
  grad.addColorStop(0, '#3a352a');
  grad.addColorStop(1, '#241f18');
  g.fillStyle = grad;
  g.beginPath(); g.arc(cx, cx, r, 0, Math.PI * 2); g.fill();
  // 暗金环
  g.strokeStyle = 'rgba(184,146,74,0.95)';
  g.lineWidth = 4;
  g.beginPath(); g.arc(cx, cx, r, 0, Math.PI * 2); g.stroke();
  // 八相刻度
  for (let i = 0; i < 8; i++) {
    const a = (i / 8) * Math.PI * 2 - Math.PI / 2;
    const x1 = cx + Math.cos(a) * (r - 14);
    const y1 = cx + Math.sin(a) * (r - 14);
    const x2 = cx + Math.cos(a) * (r - 4);
    const y2 = cx + Math.sin(a) * (r - 4);
    g.strokeStyle = i % 2 === 0 ? 'rgba(245,242,232,0.9)' : 'rgba(184,200,200,0.7)';
    g.lineWidth = 3;
    g.beginPath(); g.moveTo(x1, y1); g.lineTo(x2, y2); g.stroke();
  }
  // 中心月
  g.fillStyle = 'rgba(245,242,232,0.95)';
  g.beginPath(); g.arc(cx, cx, 10, 0, Math.PI * 2); g.fill();
  tex.refresh();
}

function rgba(c: number, a: number): string {
  const r = (c >> 16) & 0xff, g2 = (c >> 8) & 0xff, b = c & 0xff;
  return `rgba(${r},${g2},${b},${a})`;
}
