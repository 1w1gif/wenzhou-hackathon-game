// game/render_chars.ts — 水墨角色绘制：女侠/强盗/投掷者/头目/沈砚/观测者/陶罐/剑气
// 风格约束：DrawNode 四方法（drawDot/drawSegment/drawPolygon/clear），
// 圆与弧用折线近似；身体粗线段 + 躯干多边形 + 头部圆点，纸色留白点睛。
import { Color, DrawNode, Vec2 } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import type { EnemyState } from "game/enemies";

export type HeroPose =
  | "idle"
  | "run"
  | "jump"
  | "fall"
  | "cling"
  | "dash"
  | "attack1"
  | "attack2"
  | "attack3"
  | "hurt"
  | "ladder";

// 敌人点缀暗金 / 头目暗红纹路（#8C3B3B）
export const EnemyGold = ink(155, 113, 56, 220);
export const EnemyRed = ink(140, 59, 59, 235);
export const SteelGray = ink(150, 150, 146, 235);
export const HeroScarf = ink(168, 197, 188, 235); // 青灰 #A8C5BC

export const ATTACK_TIME = [0.22, 0.22, 0.3];

export function clamp01(v: number): number {
  return Math.max(0, Math.min(1, v));
}

export function col(c: InkColor, mul?: number): Color.Type {
  if (mul === undefined) {
    return Color(c.r, c.g, c.b, c.a);
  }
  return Color(c.r, c.g, c.b, Math.floor(c.a * clamp01(mul)));
}

export function dot(
  d: DrawNode.Type,
  x: number,
  y: number,
  r: number,
  c: InkColor,
  mul?: number
): void {
  d.drawDot(Vec2(x, y), r, col(c, mul));
}

export function seg(
  d: DrawNode.Type,
  x0: number,
  y0: number,
  x1: number,
  y1: number,
  r: number,
  c: InkColor,
  mul?: number
): void {
  d.drawSegment(Vec2(x0, y0), Vec2(x1, y1), r, col(c, mul));
}

// 圆：折线近似（默认 16 段）
export function circle(
  d: DrawNode.Type,
  cx: number,
  cy: number,
  r: number,
  c: InkColor,
  segments?: number,
  mul?: number
): void {
  const n = segments === undefined ? 16 : segments;
  for (let i = 0; i < n; i++) {
    const a0 = (i / n) * Math.PI * 2;
    const a1 = ((i + 1) / n) * Math.PI * 2;
    seg(
      d,
      cx + Math.cos(a0) * r,
      cy + Math.sin(a0) * r,
      cx + Math.cos(a1) * r,
      cy + Math.sin(a1) * r,
      2,
      c,
      mul
    );
  }
}

// 弧：a0 到 a1（弧度，可反向），折线近似
export function arc(
  d: DrawNode.Type,
  cx: number,
  cy: number,
  r: number,
  a0: number,
  a1: number,
  segments: number,
  radius: number,
  c: InkColor,
  mul?: number
): void {
  for (let i = 0; i < segments; i++) {
    const t0 = i / segments;
    const t1 = (i + 1) / segments;
    const ang0 = a0 + (a1 - a0) * t0;
    const ang1 = a0 + (a1 - a0) * t1;
    seg(
      d,
      cx + Math.cos(ang0) * r,
      cy + Math.sin(ang0) * r,
      cx + Math.cos(ang1) * r,
      cy + Math.sin(ang1) * r,
      radius,
      c,
      mul
    );
  }
}

// 躯干多边形：给定左右边界 x 与上下 y
export function torso(
  d: DrawNode.Type,
  xL: number,
  xR: number,
  yTop: number,
  yBot: number,
  c: InkColor,
  mul?: number
): void {
  d.drawPolygon(
    [Vec2(xL, yTop), Vec2(xR, yTop), Vec2(xR + 2, yBot), Vec2(xL - 2, yBot)],
    col(c, mul),
    0,
    Color(0, 0, 0, 0)
  );
}

// 马尾/发带：随 t 摆动的 2~3 段细线
function drawPonytail(d: DrawNode.Type, hx: number, hy: number, facing: number, t: number): void {
  const sway = Math.sin(t * 2.6) * 0.28;
  const sway2 = Math.sin(t * 3.4 + 1.2) * 0.22;
  let px = hx - facing * 5;
  let py = hy + 3;
  let ang = Math.PI - facing * (0.5 + sway);
  const lens = [11, 9, 7];
  const rads = [3, 2.3, 1.6];
  for (let i = 0; i < 3; i++) {
    ang = ang + (i === 0 ? sway * 0.6 : sway2 * 0.8) - 0.12;
    const nx = px + Math.cos(ang) * lens[i];
    const ny = py + Math.sin(ang) * lens[i];
    seg(d, px, py, nx, ny, rads[i], Palette.inkDark);
    px = nx;
    py = ny;
  }
  // 发带：青灰细线
  const ra = Math.PI + facing * (0.2 + sway2);
  seg(
    d,
    hx - facing * 3,
    hy + 6,
    hx - facing * 3 + Math.cos(ra) * 13,
    hy + 6 + Math.sin(ra) * 13,
    1.4,
    HeroScarf,
    0.9
  );
}

// 围巾拖尾：2 段，随动作与 t 波动
function drawScarf(
  d: DrawNode.Type,
  nx: number,
  ny: number,
  facing: number,
  t: number,
  pose: HeroPose
): void {
  let stretch = 0;
  let lift = 0;
  if (pose === "dash") {
    stretch = 1.5;
    lift = 0.1;
  } else if (pose === "run") {
    stretch = 0.9;
    lift = -0.15;
  } else if (pose === "fall" || pose === "jump") {
    stretch = 0.8;
    lift = 0.5;
  }
  const w1 = Math.sin(t * 4.2) * 3.5;
  const w2 = Math.sin(t * 5.1 + 0.8) * 4.5;
  const x1 = nx - facing * (12 + stretch * 8);
  const y1 = ny + lift * 10 + w1;
  const x2 = nx - facing * (20 + stretch * 16);
  const y2 = ny + lift * 14 + w2;
  seg(d, nx, ny, x1, y1, 3.4, HeroScarf);
  seg(d, x1, y1, x2, y2, 2.2, HeroScarf, 0.75);
}

// 腿：hip 出发，两段式，phase 控制摆动
function drawLeg(
  d: DrawNode.Type,
  hx: number,
  hy: number,
  facing: number,
  phase: number,
  lift: number,
  bend: number
): void {
  const kx = hx + facing * (4 + phase * 9 + bend * 4);
  const ky = hy - 19;
  const fx = hx + facing * (4 + phase * 17 + bend * 8);
  const fy = hy - 36 + lift;
  seg(d, hx, hy, kx, ky, 5, Palette.inkDark);
  seg(d, kx, ky, fx, fy, 4, Palette.inkDark);
}

export function drawHero(
  d: DrawNode.Type,
  x: number,
  y: number,
  facing: number,
  pose: HeroPose,
  t: number,
  phaseIndex: number
): void {
  // 月光淡晕：phaseIndex 4（满月）最强，新月最弱
  const moonK = clamp01(1 - Math.abs(phaseIndex - 4) / 4);
  dot(d, x, y + 40, 34, Palette.moonWhite, 0.06 + 0.1 * moonK);

  const bob = pose === "idle" ? Math.sin(t * 2) * 1.4 : 0;
  let lean = 0;
  if (pose === "run") {
    lean = 0.18;
  } else if (pose === "dash") {
    lean = 0.55;
  } else if (pose === "attack1" || pose === "attack2") {
    lean = 0.3;
  } else if (pose === "attack3") {
    lean = 0.42;
  } else if (pose === "hurt") {
    lean = -0.35;
  } else if (pose === "jump" || pose === "cling") {
    lean = 0.1;
  }
  const crouch = pose === "hurt" ? -5 : pose === "cling" ? -3 : pose === "ladder" ? -2 : 0;

  const hipY = y + 36 + bob + crouch;
  const shX = x + facing * Math.sin(lean) * 16;
  const shY = y + 60 + bob + crouch;
  const hx = x + facing * Math.sin(lean) * 24;
  const hy = y + 72 + bob + crouch;

  // 腿部姿态
  if (pose === "run") {
    const sw = Math.sin(t * 12);
    drawLeg(d, x, hipY, facing, sw, Math.max(0, Math.cos(t * 12)) * 5, 0);
    drawLeg(d, x, hipY, facing, -sw, Math.max(0, -Math.cos(t * 12)) * 5, 0);
  } else if (pose === "jump") {
    drawLeg(d, x, hipY, facing, 0.7, 14, -1);
    drawLeg(d, x, hipY, facing, -0.3, 8, -1);
  } else if (pose === "fall") {
    drawLeg(d, x, hipY, facing, 0.45, -2, 1);
    drawLeg(d, x, hipY, facing, -0.45, -4, 1);
  } else if (pose === "cling") {
    drawLeg(d, x, hipY, facing, 0.5, 6, -1.4);
    drawLeg(d, x, hipY, facing, 0.15, 2, -1.2);
  } else if (pose === "dash") {
    drawLeg(d, x, hipY, facing, 1.5, 4, 0);
    drawLeg(d, x, hipY, facing, -0.9, 2, 0);
  } else if (pose === "ladder") {
    const sw = Math.sin(t * 6);
    drawLeg(d, x, hipY, 1, sw * 0.4, 6 + sw * 4, 0);
    drawLeg(d, x, hipY, 1, -sw * 0.4, 6 - sw * 4, 0);
  } else {
    drawLeg(d, x, hipY, facing, 0.35, 0, 0);
    drawLeg(d, x, hipY, facing, -0.3, 0, 0);
  }

  // 躯干（收腰多边形）
  torso(d, shX - 6.5, shX + 6.5, shY, hipY + 2, Palette.inkSoft);
  seg(d, shX, shY + 2, x, hipY, 8, Palette.inkSoft); // 脊柱体积

  // 手臂 + 兵器
  const swordOut = pose === "attack1" || pose === "attack2" || pose === "attack3";
  if (swordOut) {
    const idx = pose === "attack1" ? 0 : pose === "attack2" ? 1 : 2;
    const dur = ATTACK_TIME[idx];
    const p = clamp01(t / dur);
    const handX = shX + facing * (16 + p * 8);
    const handY = shY - 4 + (idx === 2 ? 12 - p * 26 : -p * 2);
    const bladeLen = idx === 2 ? 40 : 32;
    const ang = idx === 2 ? 2.1 - p * 3.8 : -0.5 + p * 1.5;
    seg(d, handX, handY, handX + Math.cos(ang) * bladeLen * facing, handY + Math.sin(ang) * bladeLen, 2.6, Palette.white, 0.95);
    // 剑光弧线（白色细弧折线）
    const a0 = facing > 0 ? -0.7 : Math.PI + 0.7;
    const a1 = a0 + facing * (0.6 + p * 1.9);
    arc(d, shX, shY - 4, bladeLen + 8, a0, a1, 10, 2, Palette.white, 0.5 * (1 - p * 0.35));
    // 后手
    const bx = shX - facing * 8;
    seg(d, shX, shY - 4, bx, shY - 16, 3.6, Palette.inkDark);
    seg(d, bx, shY - 16, bx - facing * 6, shY - 22, 3, Palette.inkDark);
  } else if (pose === "ladder") {
    const sw = Math.sin(t * 6);
    seg(d, shX, shY, shX + 5, shY + 20 + sw * 5, 3.6, Palette.inkDark);
    seg(d, shX, shY, shX - 5, shY + 20 - sw * 5, 3.6, Palette.inkDark);
  } else if (pose === "dash") {
    seg(d, shX, shY, shX + facing * 16, shY - 6, 3.6, Palette.inkDark);
    seg(d, shX, shY, shX - facing * 14, shY + 6, 3.6, Palette.inkDark);
  } else {
    const armSw = pose === "run" ? Math.sin(t * 12) * 0.5 : 0;
    seg(d, shX + facing * 4, shY - 2, shX + facing * (8 + armSw * 8), shY - 16, 3.8, Palette.inkDark);
    seg(d, shX - facing * 4, shY - 2, shX - facing * (8 - armSw * 8), shY - 16, 3.8, Palette.inkDark);
    // 收剑于腰后：短鞘线
    seg(d, x - facing * 6, hipY + 2, x - facing * 14, hipY - 12, 2.4, SteelGray, 0.8);
  }

  // 头 + 纸色留白点睛
  dot(d, hx, hy, 7, Palette.inkDark);
  dot(d, hx + facing * 3.4, hy - 1, 2.6, Palette.paper);
  dot(d, hx + facing * 4.2, hy, 1, Palette.inkDark);

  drawPonytail(d, hx, hy, facing, t);
  drawScarf(d, shX, shY + 4, facing, t, pose);
}

// 敌人水墨剪影：bandit 兜帽弯刀 / thrower 驼背抱罐 / boss 角面巨刃
// 死亡压扁淡出：整体 y 绕脚底缩放 + 宽度外扩，透明度随 deathTimer 递减
export function drawEnemy(d: DrawNode.Type, e: EnemyState, t: number): void {
  const x = e.body.x;
  const feetY = e.body.y - e.body.h / 2;
  const kind = e.def.kind;
  const dying = e.dead && e.deathTimer > 0;
  const aMul = dying ? clamp01(e.deathTimer / 0.55) : 1;
  const squash = dying ? 0.35 + 0.65 * aMul : 1;
  const wide = 1 + (1 - squash) * 0.6;
  const bodyH = e.body.h * squash;
  const face = e.facing;

  // 冲刺/挥砍残影：身后 1~2 个透明度递减重影
  if (e.state === "swing" || e.state === "charge") {
    for (let g = 1; g <= 2; g++) {
      const gx = x - face * g * 16;
      const ga = 0.3 / g;
      torso(d, gx - e.body.w * 0.28, gx + e.body.w * 0.28, feetY + bodyH * 0.52, feetY + bodyH * 0.9, Palette.inkSoft, ga);
      dot(d, gx, feetY + bodyH * 0.94, kind === "boss" ? 9 : 6.5, Palette.inkSoft, ga);
    }
  }

  const hipY = feetY + bodyH * 0.42;
  const shY = feetY + bodyH * 0.78;
  const headY = feetY + bodyH * 0.92;
  const headR = kind === "boss" ? 9 : 6.5;
  let jit = 0;
  if (e.state === "windup" || e.state === "telegraph") {
    jit = Math.sin(t * 45) * 1.5; // 蓄力微抖
  }
  let lean = 0;
  if (e.state === "windup") {
    lean = -0.15;
  } else if (e.state === "swing" || e.state === "charge") {
    lean = 0.4;
  } else if (e.state === "hurt") {
    lean = -0.4;
  } else if (e.state === "patrol") {
    lean = 0.06 * Math.sin(t * 3);
  }
  const shX = x + face * Math.sin(lean) * 14 + jit;

  // 腿
  const legLift = dying ? -bodyH * 0.1 : e.state === "charge" ? 3 : 0;
  if (kind === "boss") {
    seg(d, x - 10, hipY, x - 15, feetY + legLift, 7, Palette.inkDark);
    seg(d, x + 10, hipY, x + 16, feetY + legLift, 7, Palette.inkDark);
  } else {
    const legSw = e.state === "patrol" || e.state === "chase" ? Math.sin(t * 10) : 0;
    seg(d, x - 3, hipY, x - 6 - legSw * 6, feetY + legLift, 4.5, Palette.inkDark);
    seg(d, x + 3, hipY, x + 6 + legSw * 6, feetY + legLift, 4.5, Palette.inkDark);
  }

  // 躯干
  const torsoW = kind === "boss" ? e.body.w * 0.42 : e.body.w * 0.3;
  torso(d, shX - torsoW, shX + torsoW, shY, hipY + 2, Palette.inkSoft);
  seg(d, shX, shY - 4, x, hipY, torsoW * 1.5, Palette.inkSoft);

  if (kind === "bandit") {
    // 兜帽短打 + 弯刀 + 暗金腰带
    seg(d, shX - torsoW, shY - 8, shX + torsoW, shY - 10, 2.6, EnemyGold, 0.9);
    dot(d, shX + face * 2 + jit, headY, headR, Palette.inkDark);
    seg(d, shX + face * 2 + jit, headY + headR * 0.6, shX + face * 8 + jit, headY + headR + 4, 3.4, Palette.inkDark);
    dot(d, shX + face * 4.4 + jit, headY + 1, 1.8, Palette.paper);
    const armUp = e.state === "windup" ? 18 : e.state === "swing" ? -6 : 4;
    const hx = shX + face * (torsoW + 4);
    const hy = shY - 6 + armUp;
    seg(d, shX, shY - 6, hx, hy, 4, Palette.inkDark);
    // 弯刀：外弧折线
    const a0 = face > 0 ? -0.9 : Math.PI + 0.9;
    const a1 = a0 + face * 1.7;
    arc(d, hx, hy, 15, a0, a1, 6, 2.4, SteelGray, aMul);
    seg(d, hx, hy, hx + face * 14, hy + (e.state === "swing" ? -4 : 9), 1.6, SteelGray, 0.8 * aMul);
  } else if (kind === "thrower") {
    // 驼背抱陶罐
    const hunchX = shX + face * 6;
    dot(d, hunchX + face * 3 + jit, headY + 2, headR, Palette.inkDark);
    dot(d, hunchX + face * 6 + jit, headY + 2, 1.8, Palette.paper);
    seg(d, shX, shY - 4, hunchX + face * 12, shY - 12, 3.4, Palette.inkDark);
    const potX = hunchX + face * 13;
    const potY = shY - 12;
    dot(d, potX, potY, 6.5, Palette.inkWash);
    seg(d, potX - 5, potY + 5, potX + 5, potY + 5, 2, Palette.inkDark);
    seg(d, shX, hipY + 4, shX + face * 2, hipY - 4, 1.6, EnemyGold, 0.8);
  } else {
    // 头目：魁梧 + 角面 + 巨刃
    dot(d, shX + face * 2 + jit, headY, headR, Palette.inkDark);
    seg(d, shX - 4 + jit, headY + headR * 0.7, shX - 9 + jit, headY + headR + 8, 3, Palette.inkDark);
    seg(d, shX + 6 + jit, headY + headR * 0.7, shX + 11 + jit, headY + headR + 8, 3, Palette.inkDark);
    dot(d, shX + face * 5 + jit, headY + 1, 2.2, EnemyRed);
    const swingK = e.state === "swing" ? 1 : e.state === "windup" ? 0.2 : 0.5;
    const ang = face > 0 ? -0.4 + swingK * 1.8 : Math.PI + 0.4 - swingK * 1.8;
    const bx = shX + face * 12;
    const by = shY - 8;
    const tipX = bx + Math.cos(ang) * 52;
    const tipY = by + Math.sin(ang) * 52;
    const nx = Math.cos(ang + Math.PI / 2) * 4;
    const ny = Math.sin(ang + Math.PI / 2) * 4;
    d.drawPolygon(
      [
        Vec2(bx + nx, by + ny),
        Vec2(tipX + nx * 0.4, tipY + ny * 0.4),
        Vec2(tipX - nx * 0.4, tipY - ny * 0.4),
        Vec2(bx - nx, by - ny),
      ],
      col(SteelGray, 0.85 * aMul),
      0,
      Color(0, 0, 0, 0)
    );
    seg(d, bx, by, bx + Math.cos(ang) * 46, by + Math.sin(ang) * 46, 3, Palette.inkDark, aMul);
    if (e.phase2) {
      const pulse = 0.6 + 0.4 * Math.sin(t * 5);
      seg(d, shX - torsoW + 3, shY - 10, shX + torsoW - 3, shY - 16, 2.2, EnemyRed, pulse * aMul);
      seg(d, shX - torsoW + 5, hipY + 12, shX + torsoW - 5, hipY + 18, 2, EnemyRed, pulse * aMul);
      dot(d, shX, hipY + 6, 3, EnemyRed, pulse * aMul);
    }
    seg(d, shX - torsoW, shY + 2, shX + torsoW, shY + 2, 2.4, EnemyGold, 0.7);
  }
}

// 沈砚：长衫书生剑客；hostile 时剑出鞘 + 暗红点缀
export function drawShenYan(
  d: DrawNode.Type,
  x: number,
  y: number,
  facing: number,
  t: number,
  hostile: boolean
): void {
  const sway = Math.sin(t * 1.6) * 2;
  const bob = Math.sin(t * 2) * 1;
  const hipY = y + 34 + bob;
  const shY = y + 58 + bob;
  const shX = x + facing * (hostile ? 3 : 0);
  const hx = x + facing * (hostile ? 4 : 1);
  const hy = y + 70 + bob;
  const accent = hostile ? EnemyRed : Palette.paleInk;

  // 长衫下摆：梯形多边形，微幅摆动
  d.drawPolygon(
    [
      Vec2(x - 8, shY),
      Vec2(x + 8, shY),
      Vec2(x + 13 + sway, y + 2),
      Vec2(x - 13 + sway, y + 2),
    ],
    col(Palette.inkSoft),
    0,
    Color(0, 0, 0, 0)
  );
  seg(d, x, shY, x, hipY, 9, Palette.inkSoft); // 身量
  // 腿脚（隐于长衫，只露脚尖）
  seg(d, x - 4 + sway, y + 4, x - 6, y, 3, Palette.inkDark);
  seg(d, x + 5 + sway, y + 4, x + 7, y, 3, Palette.inkDark);

  // 宽袖
  const sleeveA = hostile ? -0.5 : 0.9;
  seg(d, shX + facing * 5, shY - 2, shX + facing * 14, shY - 2 - sleeveA * 10, 4.4, Palette.inkDark);
  seg(d, shX - facing * 5, shY - 2, shX - facing * 12, shY + 4, 4.2, Palette.inkDark);

  // 腰带 + 玉佩点缀
  seg(d, x - 8, hipY, x + 8, hipY, 2.6, accent, hostile ? 0.95 : 0.8);
  seg(d, x + facing * 6, hipY - 2, x + facing * 6, hipY - 9, 1.8, accent, 0.8);

  // 头 + 束发 + 纸色留白
  dot(d, hx, hy, 6.6, Palette.inkDark);
  dot(d, hx, hy + 7, 3, Palette.inkDark); // 发髻
  seg(d, hx - 2, hy + 9, hx + 4, hy + 11, 1.4, accent, 0.9); // 簪
  dot(d, hx + facing * 3, hy - 1, 2.4, Palette.paper);

  if (hostile) {
    // 剑出鞘：前指亮刃 + 暗红剑穗
    const gx = shX + facing * 14;
    const gy = shY - 12;
    seg(d, gx, gy, gx + facing * 34, gy + 6, 2.6, Palette.white, 0.95);
    seg(d, gx + facing * 30, gy + 5, gx + facing * 40, gy + 8, 1.4, Palette.white, 0.6);
    seg(d, gx - facing * 4, gy + 2, gx - facing * 10, gy + 10, 1.6, EnemyRed, 0.9);
  } else {
    // 收剑于腰后
    seg(d, x - facing * 8, hipY + 2, x - facing * 20, hipY - 10, 2.2, SteelGray, 0.85);
  }
}

// 观测者：瘦高苍白长袍 + 头顶悬浮光环（虚线圆，t 旋转），底部无脚渐隐
export function drawObserver(d: DrawNode.Type, x: number, y: number, t: number): void {
  const pale = ink(196, 192, 182, 225);
  const bob = Math.sin(t * 1.2) * 2;
  const topY = y + 104 + bob;
  const headY = y + 96 + bob;
  // 长袍：上宽下窄细长多边形
  d.drawPolygon(
    [Vec2(x - 9, topY - 8), Vec2(x + 9, topY - 8), Vec2(x + 4, y + 26), Vec2(x - 4, y + 26)],
    col(pale, 0.95),
    0,
    Color(0, 0, 0, 0)
  );
  // 下段渐隐：两段低透明度
  seg(d, x - 4, y + 26, x - 3, y + 12, 5, pale, 0.35);
  seg(d, x + 4, y + 26, x + 3, y + 12, 5, pale, 0.35);
  seg(d, x - 3, y + 12, x - 2, y + 2, 4, pale, 0.14);
  seg(d, x + 3, y + 12, x + 2, y + 2, 4, pale, 0.14);
  // 交叠双手
  seg(d, x - 8, topY - 14, x + 8, topY - 16, 3.2, pale, 0.8);
  // 头：苍白尖顶兜帽 + 纸色面留白
  dot(d, x, headY, 7, pale);
  d.drawPolygon(
    [Vec2(x - 6, headY + 4), Vec2(x + 6, headY + 4), Vec2(x, headY + 15)],
    col(pale, 0.9),
    0,
    Color(0, 0, 0, 0)
  );
  dot(d, x, headY - 1, 3, Palette.paper, 0.9);
  dot(d, x - 1.2, headY - 1, 1, Palette.inkFaint);
  dot(d, x + 1.2, headY - 1, 1, Palette.inkFaint);
  // 悬浮光环：旋转虚线圆
  const rot = t * 1.2;
  const r = 16;
  const nSeg = 10;
  for (let i = 0; i < nSeg; i++) {
    if (i % 2 === 0) {
      continue;
    }
    const a0 = rot + (i / nSeg) * Math.PI * 2;
    const a1 = rot + ((i + 1) / nSeg) * Math.PI * 2;
    seg(
      d,
      x + Math.cos(a0) * r,
      headY + 22 + Math.sin(a0) * r * 0.45,
      x + Math.cos(a1) * r,
      headY + 22 + Math.sin(a1) * r * 0.45,
      1.8,
      Palette.moonCyanSoft,
      0.7
    );
  }
}

// 陶罐：圆罐 + 旋转标记（t 控制自转）
export function drawPot(d: DrawNode.Type, x: number, y: number, t: number): void {
  dot(d, x, y, 9, Palette.inkWash);
  circle(d, x, y, 9, Palette.inkDark, 12, 0.85);
  seg(d, x - 6, y + 7, x + 6, y + 7, 2.2, Palette.inkDark); // 罐口沿
  const a = t * 6;
  seg(d, x - Math.cos(a) * 5, y - Math.sin(a) * 5, x + Math.cos(a) * 5, y + Math.sin(a) * 5, 1.2, Palette.inkDark, 0.6);
  dot(d, x - 3 + Math.sin(a) * 1.5, y + 2, 1.6, Palette.paper, 0.8);
}

// 头目剑气震波：竖月牙形折线 + 拖尾（dir 为行进方向）
export function drawWave(d: DrawNode.Type, x: number, y: number, dir: number, t: number): void {
  const flick = 0.75 + 0.25 * Math.sin(t * 20);
  for (let g = 0; g < 3; g++) {
    const gx = x - dir * g * 11;
    const ga = flick * (1 - g * 0.32);
    // 外弧：竖向月牙外缘
    const a0 = Math.PI / 2 - dir * 1.25;
    const a1 = Math.PI / 2 + dir * 1.25;
    arc(d, gx + dir * 8, y + 20, 22, a0, a1, 8, 2.6, Palette.moonCyan, ga);
    arc(d, gx + dir * 13, y + 20, 14, a0, a1, 6, 1.8, Palette.moonCyan, ga * 0.7);
  }
  dot(d, x + dir * 8, y + 20, 3, Palette.white, 0.8 * flick);
}
