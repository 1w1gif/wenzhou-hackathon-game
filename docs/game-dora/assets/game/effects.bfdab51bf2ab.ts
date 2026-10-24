// game/effects.ts — 水墨粒子特效：墨雾、墨滴、月环、尘土、火星、星光
import { DrawNode, Vec2, Color } from "Dora";
import { Palette, InkColor } from "core/palette";

export type ParticleKind = "mist" | "drop" | "ring" | "dust" | "spark" | "star" | "ember";

export interface Particle {
  kind: ParticleKind;
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;
  maxLife: number;
  size: number;
  grow: number;
  gravity: number;
  color: InkColor;
  phase: number;
}

const RING_SEGS = 18;

export class EffectSystem {
  private parts: Particle[];
  // 像素雪碧图特效钩子：由 game.ts 注入 SheetFxSystem.spawn
  sheetHook: ((x: number, y: number, dir: number, big: boolean) => void) | undefined;

  constructor() {
    this.parts = [];
    this.sheetHook = undefined;
  }

  private push(p: Particle): void {
    if (this.parts.length < 600) {
      this.parts.push(p);
    }
  }

  // 敌人化墨雾：缓缓上浮、扩散、消散
  spawnMist(x: number, y: number, count: number, scale: number): void {
    for (let i = 0; i < count; i++) {
      const a = Math.random() * Math.PI * 2;
      const sp = 30 + Math.random() * 90 * scale;
      this.push({
        kind: "mist",
        x: x + (Math.random() - 0.5) * 30 * scale,
        y: y + Math.random() * 40 * scale,
        vx: Math.cos(a) * sp,
        vy: Math.sin(a) * sp * 0.6 + 40,
        life: 0.9 + Math.random() * 0.8,
        maxLife: 1.7,
        size: (10 + Math.random() * 16) * scale,
        grow: 26 * scale,
        gravity: -30,
        color: i % 3 === 0 ? Palette.mistLight : Palette.mist,
        phase: Math.random() * 6.28,
      });
    }
    // 死亡/消散：附加大型剑光像素特效
    if (this.sheetHook !== undefined) {
      this.sheetHook(x, y + 26, 1, true);
    }
  }

  // 受击墨滴飞溅
  spawnInkBurst(x: number, y: number, dir: number): void {
    for (let i = 0; i < 8; i++) {
      this.push({
        kind: "drop",
        x: x,
        y: y + (Math.random() - 0.5) * 20,
        vx: dir * (60 + Math.random() * 220) + (Math.random() - 0.5) * 80,
        vy: 60 + Math.random() * 220,
        life: 0.4 + Math.random() * 0.3,
        maxLife: 0.7,
        size: 2 + Math.random() * 3.5,
        grow: 0,
        gravity: 900,
        color: Palette.inkDark,
        phase: 0,
      });
    }
  }

  // 二段跳月环 / 检查点涟漪
  spawnRing(x: number, y: number, color: InkColor, size: number, grow: number, life: number): void {
    this.push({
      kind: "ring",
      x: x,
      y: y,
      vx: 0,
      vy: 0,
      life: life,
      maxLife: life,
      size: size,
      grow: grow,
      gravity: 0,
      color: color,
      phase: 0,
    });
  }

  spawnDust(x: number, y: number, dir: number): void {
    for (let i = 0; i < 6; i++) {
      this.push({
        kind: "dust",
        x: x + (Math.random() - 0.5) * 16,
        y: y,
        vx: dir * (30 + Math.random() * 90) + (Math.random() - 0.5) * 60,
        vy: 20 + Math.random() * 70,
        life: 0.35 + Math.random() * 0.25,
        maxLife: 0.6,
        size: 3 + Math.random() * 4,
        grow: 8,
        gravity: 60,
        color: Palette.paleInk,
        phase: 0,
      });
    }
  }

  spawnSpark(x: number, y: number, dir: number): void {
    for (let i = 0; i < 5; i++) {
      this.push({
        kind: "spark",
        x: x,
        y: y + (Math.random() - 0.5) * 24,
        vx: dir * (200 + Math.random() * 320),
        vy: (Math.random() - 0.5) * 260,
        life: 0.12 + Math.random() * 0.12,
        maxLife: 0.24,
        size: 2,
        grow: 0,
        gravity: 0,
        color: Palette.moonCyan,
        phase: 0,
      });
    }
    if (this.sheetHook !== undefined) {
      this.sheetHook(x, y, dir, false);
    }
  }

  spawnStars(x: number, y: number, n: number): void {
    for (let i = 0; i < n; i++) {
      const a = Math.random() * Math.PI * 2;
      const sp = 40 + Math.random() * 120;
      this.push({
        kind: "star",
        x: x,
        y: y,
        vx: Math.cos(a) * sp,
        vy: Math.sin(a) * sp + 60,
        life: 0.6 + Math.random() * 0.5,
        maxLife: 1.1,
        size: 2 + Math.random() * 2.5,
        grow: 0,
        gravity: 140,
        color: Palette.moonCyan,
        phase: Math.random() * 6.28,
      });
    }
  }

  // 灯笼火苗（持续生成由外部每帧调用）
  spawnEmber(x: number, y: number): void {
    this.push({
      kind: "ember",
      x: x + (Math.random() - 0.5) * 8,
      y: y,
      vx: (Math.random() - 0.5) * 20,
      vy: 30 + Math.random() * 50,
      life: 0.5 + Math.random() * 0.4,
      maxLife: 0.9,
      size: 2 + Math.random() * 2,
      grow: 0,
      gravity: -40,
      color: Palette.vermilion,
      phase: 0,
    });
  }

  // 斩绳断口墨丝
  spawnRopeCut(x: number, y: number): void {
    for (let i = 0; i < 10; i++) {
      this.push({
        kind: "drop",
        x: x + (Math.random() - 0.5) * 8,
        y: y + (Math.random() - 0.5) * 20,
        vx: (Math.random() - 0.5) * 180,
        vy: -40 + Math.random() * 160,
        life: 0.5 + Math.random() * 0.3,
        maxLife: 0.8,
        size: 1.5 + Math.random() * 2,
        grow: 0,
        gravity: 700,
        color: Palette.gold,
        phase: 0,
      });
    }
  }

  update(dt: number): void {
    let w = 0;
    for (let i = 0; i < this.parts.length; i++) {
      const p = this.parts[i];
      p.life = p.life - dt;
      if (p.life <= 0) {
        continue;
      }
      p.vy = p.vy + p.gravity * dt;
      p.x = p.x + p.vx * dt;
      p.y = p.y + p.vy * dt;
      p.size = p.size + p.grow * dt;
      this.parts[w] = p;
      w = w + 1;
    }
    this.parts.length = w;
  }

  draw(draw: DrawNode.Type): void {
    for (let i = 0; i < this.parts.length; i++) {
      const p = this.parts[i];
      const t = p.life / p.maxLife;
      const alpha = Math.max(0, Math.min(1, t));
      const c = Color(p.color.r, p.color.g, p.color.b, Math.floor(p.color.a * alpha));
      if (p.kind === "ring") {
        const r = p.size;
        const segs = RING_SEGS;
        for (let s = 0; s < segs; s++) {
          const a0 = (s / segs) * Math.PI * 2 + p.phase;
          const a1 = ((s + 1) / segs) * Math.PI * 2 + p.phase;
          draw.drawSegment(
            Vec2(p.x + Math.cos(a0) * r, p.y + Math.sin(a0) * r),
            Vec2(p.x + Math.cos(a1) * r, p.y + Math.sin(a1) * r),
            2.5,
            c
          );
        }
      } else if (p.kind === "spark") {
        draw.drawSegment(Vec2(p.x, p.y), Vec2(p.x - p.vx * 0.03, p.y - p.vy * 0.03), p.size, c);
      } else if (p.kind === "star") {
        // 四芒星光
        const s = p.size * (0.6 + 0.4 * Math.sin(p.phase + p.life * 10));
        draw.drawSegment(Vec2(p.x - s, p.y), Vec2(p.x + s, p.y), 1.5, c);
        draw.drawSegment(Vec2(p.x, p.y - s), Vec2(p.x, p.y + s), 1.5, c);
      } else {
        draw.drawDot(Vec2(p.x, p.y), p.size * (0.5 + 0.5 * alpha), c);
      }
    }
  }

  count(): number {
    return this.parts.length;
  }

  clearAll(): void {
    this.parts.length = 0;
  }
}
