// game/sheetfx.ts — 像素雪碧图打击特效：横条帧动画 + 点采样（"Point" as unknown as number）+ 方向镜像
// 死亡细胞式打击感：命中点瞬间爆出高对比像素火花帧动画
import { Node, Rect, Sprite, Texture2D, Vec2 } from "Dora";

type SheetKey = "hit" | "big";

interface SheetDef {
  file: string;
  frameW: number;
  frameH: number;
  frames: number;
  fps: number;
  scale: number;
}

// 实机探测规格：hit-effect-1.png 768×128 = 6帧128×128；hit-effect-2.png 320×64 = 5帧64×64
const SHEETS: Record<SheetKey, SheetDef> = {
  big: { file: "assets/effects/hit-effect-1.png", frameW: 128, frameH: 128, frames: 6, fps: 20, scale: 1.4 },
  hit: { file: "assets/effects/hit-effect-2.png", frameW: 64, frameH: 64, frames: 5, fps: 22, scale: 1.6 },
};

interface Active {
  sprite: Sprite.Type;
  def: SheetDef;
  t: number;
  dur: number;
}

export class SheetFxSystem {
  private parent: Node.Type;
  private actives: Active[];
  private tex: Record<string, Texture2D.Type | undefined>;

  constructor(parent: Node.Type) {
    this.parent = parent;
    this.actives = [];
    this.tex = {};
  }

  private texture(file: string): Texture2D.Type | undefined {
    const cached = this.tex[file];
    if (cached !== undefined) {
      return cached;
    }
    const loaded = Texture2D(file);
    this.tex[file] = loaded;
    return loaded;
  }

  // 在世界坐标 (x, y) 播放一段帧动画；dir<0 时水平镜像
  spawn(x: number, y: number, dir: number, big: boolean): void {
    if (this.actives.length > 24) {
      return; // 并发上限，防卡顿
    }
    const def = big ? SHEETS.big : SHEETS.hit;
    const tex = this.texture(def.file);
    if (tex === undefined) {
      return;
    }
    const sp = Sprite(tex, Rect(0, 0, def.frameW, def.frameH));
    sp.filter = "Point" as unknown as number;
    sp.position = Vec2(x, y);
    sp.scaleX = (dir >= 0 ? 1 : -1) * def.scale;
    sp.scaleY = def.scale;
    sp.addTo(this.parent);
    this.actives.push({ sprite: sp, def: def, t: 0, dur: def.frames / def.fps });
  }

  update(dt: number): void {
    let i = this.actives.length - 1;
    while (i >= 0) {
      const a = this.actives[i];
      a.t = a.t + dt;
      if (a.t >= a.dur) {
        a.sprite.removeFromParent();
        this.actives.splice(i, 1);
      } else {
        let idx = Math.floor(a.t * a.def.fps);
        if (idx >= a.def.frames) {
          idx = a.def.frames - 1;
        }
        a.sprite.textureRect = Rect(idx * a.def.frameW, 0, a.def.frameW, a.def.frameH);
      }
      i = i - 1;
    }
  }

  clear(): void {
    for (let i = 0; i < this.actives.length; i++) {
      this.actives[i].sprite.removeFromParent();
    }
    this.actives = [];
  }
}
