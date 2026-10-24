// game/boomfx.ts — 敌人死亡爆炸：多纹理散帧序列（exp 大爆 / cir 圆爆），显隐轮播一次性播放
// 帧文件 assets/fx/boom/exp_1..10.png、cir_1..10.png（256x256，实机探测确认）
import { Node, Sprite, Texture2D, TextureFilter, Vec2 } from "Dora";

interface BoomKindDef {
  base: string;
  count: number;
  fps: number;
  scale: number;
}

const KINDS: { [k: string]: BoomKindDef } = {
  big: { base: "exp", count: 10, fps: 15, scale: 1.0 },
  ring: { base: "cir", count: 10, fps: 15, scale: 0.9 },
};

interface ActiveFx {
  sprites: Sprite.Type[];
  count: number;
  fps: number;
  t: number;
}

export class BoomFxSystem {
  private parent: Node.Type;
  private tex: { [key: string]: Texture2D.Type } = {};
  private actives: ActiveFx[] = [];
  ok = false;

  constructor(parent: Node.Type) {
    this.parent = parent;
    let ok = true;
    for (const k in KINDS) {
      const kd = KINDS[k];
      for (let i = 0; i < kd.count; i++) {
        const tex = Texture2D("assets/fx/boom/" + kd.base + "_" + (i + 1) + ".png");
        if (tex === undefined) {
          ok = false;
        } else {
          this.tex[k + "_" + i] = tex;
        }
      }
    }
    this.ok = ok;
  }

  // big=true 用 exp 大爆，否则 cir 圆爆；x,y 为爆心（世界坐标）
  spawn(x: number, y: number, big: boolean): void {
    if (!this.ok) {
      return;
    }
    const k = big ? "big" : "ring";
    const kd = KINDS[k];
    if (kd === undefined) {
      return;
    }
    const sprites: Sprite.Type[] = [];
    for (let i = 0; i < kd.count; i++) {
      const tex = this.tex[k + "_" + i];
      if (tex === undefined) {
        continue;
      }
      const sp = Sprite(tex);
      sp.filter = TextureFilter.Point;
      sp.anchor = Vec2(0.5, 0.5);
      sp.position = Vec2(x, y);
      sp.scaleX = kd.scale;
      sp.scaleY = kd.scale;
      sp.visible = false;
      sp.addTo(this.parent);
      sprites.push(sp);
    }
    if (sprites.length > 0) {
      this.actives.push({ sprites: sprites, count: sprites.length, fps: kd.fps, t: 0 });
    }
  }

  update(dt: number): void {
    const keep: ActiveFx[] = [];
    for (const fx of this.actives) {
      fx.t = fx.t + dt;
      const idx = Math.floor(fx.t * fx.fps);
      if (idx >= fx.count) {
        for (const sp of fx.sprites) {
          sp.removeFromParent();
        }
        continue;
      }
      for (let j = 0; j < fx.sprites.length; j++) {
        fx.sprites[j].visible = j === idx;
      }
      keep.push(fx);
    }
    this.actives = keep;
  }

  clear(): void {
    for (const fx of this.actives) {
      for (const sp of fx.sprites) {
        sp.removeFromParent();
      }
    }
    this.actives = [];
  }
}