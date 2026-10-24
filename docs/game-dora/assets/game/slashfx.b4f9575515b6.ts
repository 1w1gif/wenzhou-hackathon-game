// game/slashfx.ts — 剑气特效：挥剑弧 + 剑气弹贴图渲染
// 贴图优先：assets/effects/slash_white.png（普攻挥剑·白）/ slash_blue.png（剑气弹·蓝）。
// 素材包（Pack 3 Slash）转 ZIP 解包落位后自动生效；缺图回退程序化月牙弧（水墨风）。
// 蓝贴图可用时剑气弹本体也由本系统渲染（syncShots），game.ts 的程序化月牙只作回退。
import { Color, DrawNode, Node, Rect, Sprite, Texture2D, TextureFilter, Vec2 } from "Dora";

interface SwingFx {
  sprite: Sprite.Type;
  baseX: number;
  baseY: number;
  dir: number;
  t: number;
  dur: number;
  frames: number;
}

interface ArcFx {
  draw: DrawNode.Type;
  x: number;
  y: number;
  dir: number;
  blue: boolean;
  t: number;
  dur: number;
}

export interface ShotSync {
  x: number;
  y: number;
  dir: number;
}

const SWING_DUR = 0.16;
const ARC_DUR = 0.18;
const SWING_H = 96; // 挥剑弧目标高度（世界像素）
const SHOT_H = 66; // 剑气弹目标高度

export class SlashFxSystem {
  private parent: Node.Type;
  private whiteTex: Texture2D.Type | undefined;
  private blueTex: Texture2D.Type | undefined;
  private whiteFrames: number;
  private blueFrames: number;
  private checked: boolean;
  private swings: SwingFx[];
  private arcs: ArcFx[];
  private shotSprites: Sprite.Type[];

  constructor(parent: Node.Type) {
    this.parent = parent;
    this.whiteTex = undefined;
    this.blueTex = undefined;
    this.whiteFrames = 0;
    this.blueFrames = 0;
    this.checked = false;
    this.swings = [];
    this.arcs = [];
    this.shotSprites = [];
  }

  private ensureTextures(): void {
    if (this.checked) {
      return;
    }
    this.checked = true;
    // ImpactForge FX 64x64/帧横排雪碧图：slash.png(普攻白) / slash_ice-Sheet.png(冰蓝剑气)
    const white = Texture2D("assets/effects/slash_white.png");
    if (white !== undefined) {
      this.whiteTex = white;
      this.whiteFrames = Math.max(1, Math.floor(white.width / 64));
    }
    const blue = Texture2D("assets/effects/slash_blue.png");
    if (blue !== undefined) {
      this.blueTex = blue;
      this.blueFrames = Math.max(1, Math.floor(blue.width / 64));
    }
  }

  // 蓝色剑气弹贴图是否可用（game.ts 据此决定是否跳过程序化月牙）
  hasBlueTex(): boolean {
    this.ensureTextures();
    return this.blueTex !== undefined;
  }

  // 挥剑弧：blue=false 普攻（白）· true 剑气发射（蓝）
  spawnSwing(x: number, y: number, dir: number, blue: boolean): void {
    this.ensureTextures();
    const tex = blue ? this.blueTex : this.whiteTex;
    const frames = blue ? this.blueFrames : this.whiteFrames;
    if (tex !== undefined && frames > 0) {
      if (this.swings.length > 6) {
        return;
      }
      const sp = Sprite(tex, Rect(0, 0, 64, 64));
      if (sp === undefined) {
        return;
      }
      sp.filter = TextureFilter.Point;
      const k = SWING_H / 64;
      sp.scaleX = (dir >= 0 ? 1 : -1) * k;
      sp.scaleY = k;
      sp.opacity = 255;
      sp.position = Vec2(x + dir * 36, y + 8);
      sp.addTo(this.parent);
      this.swings.push({ sprite: sp, baseX: x + dir * 36, baseY: y + 8, dir: dir, t: 0, dur: SWING_DUR, frames: frames });
      return;
    }
    if (this.arcs.length > 6) {
      return;
    }
    const draw = DrawNode();
    draw.addTo(this.parent);
    this.drawArc(draw, x, y, dir, blue, 1);
    this.arcs.push({ draw: draw, x: x, y: y, dir: dir, blue: blue, t: 0, dur: ARC_DUR });
  }

  // 帧同步剑气弹贴图（蓝）。无蓝贴图时不接管（game.ts 保留程序化月牙回退）。
  syncShots(items: ShotSync[]): void {
    this.ensureTextures();
    if (this.blueTex === undefined || this.blueFrames <= 0) {
      this.clearShots();
      return;
    }
    const tex = this.blueTex;
    while (this.shotSprites.length > items.length) {
      const sp = this.shotSprites.pop();
      if (sp !== undefined) {
        sp.removeFromParent();
      }
    }
    while (this.shotSprites.length < items.length) {
      const created = Sprite(tex, Rect(this.shotFrame() * 64, 0, 64, 64));
      if (created === undefined) {
        return;
      }
      created.filter = TextureFilter.Point;
      created.addTo(this.parent);
      this.shotSprites.push(created);
    }
    const k = SHOT_H / 64;
    for (let i = 0; i < this.shotSprites.length; i++) {
      const sp = this.shotSprites[i];
      const it = items[i];
      sp.position = Vec2(it.x, it.y);
      sp.scaleX = (it.dir >= 0 ? 1 : -1) * k;
      sp.scaleY = k;
    }
  }

  // 剑气弹定格在弧线最饱满的中段帧
  private shotFrame(): number {
    return Math.floor(this.blueFrames / 2);
  }

  private clearShots(): void {
    for (let i = 0; i < this.shotSprites.length; i++) {
      this.shotSprites[i].removeFromParent();
    }
    this.shotSprites.length = 0;
  }

  update(dt: number): void {
    let i = this.swings.length - 1;
    while (i >= 0) {
      const s = this.swings[i];
      s.t = s.t + dt;
      if (s.t >= s.dur) {
        s.sprite.removeFromParent();
        this.swings.splice(i, 1);
      } else {
        const p = s.t / s.dur;
        let idx = Math.floor(p * s.frames + 0.0001);
        if (idx > s.frames - 1) {
          idx = s.frames - 1;
        }
        s.sprite.textureRect = Rect(idx * 64, 0, 64, 64);
        s.sprite.opacity = Math.floor(255 * (1 - p));
        s.sprite.position = Vec2(s.baseX + s.dir * 54 * p, s.baseY);
      }
      i = i - 1;
    }
    i = this.arcs.length - 1;
    while (i >= 0) {
      const a = this.arcs[i];
      a.t = a.t + dt;
      if (a.t >= a.dur) {
        a.draw.removeFromParent();
        this.arcs.splice(i, 1);
      } else {
        a.draw.clear();
        this.drawArc(a.draw, a.x, a.y, a.dir, a.blue, 1 - a.t / a.dur);
      }
      i = i - 1;
    }
  }

  clear(): void {
    for (let i = 0; i < this.swings.length; i++) {
      this.swings[i].sprite.removeFromParent();
    }
    this.swings.length = 0;
    for (let i = 0; i < this.arcs.length; i++) {
      this.arcs[i].draw.removeFromParent();
    }
    this.arcs.length = 0;
    this.clearShots();
  }

  // 程序化月牙弧回退（与 game.ts 旧剑气弹同款几何）：blue ? 蓝弧 : 白弧
  private drawArc(draw: DrawNode.Type, x: number, y: number, dir: number, blue: boolean, alpha: number): void {
    const c = blue ? Color(130, 180, 255, 255) : Color(255, 255, 255, 255);
    const layers = [
      { s: 0.78, ox: -30, a: 70 },
      { s: 0.92, ox: -12, a: 120 },
      { s: 1.0, ox: 0, a: 200 },
    ];
    for (let i = 0; i < layers.length; i++) {
      const L = layers[i];
      draw.drawPolygon(this.crescent(x, y, dir, L.s, L.ox), Color(c.r, c.g, c.b, Math.floor(L.a * alpha)));
    }
    draw.drawPolygon(this.crescent(x, y, dir, 0.55, 6), Color(255, 255, 255, Math.floor(210 * alpha)));
  }

  private crescent(x: number, y: number, dir: number, scale: number, ox: number): Vec2.Type[] {
    const pts: Vec2.Type[] = [];
    const R = 44 * scale;
    const aOut = 1.45;
    for (let k = 0; k <= 10; k++) {
      const t = aOut - (2 * aOut * k) / 10;
      pts.push(Vec2(x + dir * (ox + R * Math.cos(t)), y + R * Math.sin(t)));
    }
    const c2 = -0.6 * R;
    const ri = 1.2266 * R;
    const aIn = 0.9425;
    for (let k = 0; k <= 10; k++) {
      const t = -aIn + (2 * aIn * k) / 10;
      pts.push(Vec2(x + dir * (ox + c2 + ri * Math.cos(t)), y + ri * Math.sin(t)));
    }
    return pts;
  }
}