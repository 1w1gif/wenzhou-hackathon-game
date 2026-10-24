// game/decor_light.ts — 灯笼（5 帧显隐循环 + 光晕脉动）与火把（30 帧火焰循环）装饰层
// 灯笼 assets/decor/lantern_1..5.png 256²；火把 assets/decor/torch.png 1920x64=30 帧 64²（实机探测确认）
import { DrawNode, Node, Rect, Sprite, Texture2D, TextureFilter, Vec2 } from "Dora";
import { ink } from "core/palette";
import { dot } from "game/render_chars";

interface LanternSpot {
  x: number;
  y: number; // 挂点（灯笼顶）
  phase: number;
  sprites: Sprite.Type[];
}

interface TorchSpot {
  x: number;
  y: number;
  sp: Sprite.Type;
  phase: number;
}

const LANTERN_COUNT = 5;
const LANTERN_FPS = 5;
const LANTERN_SCALE = 0.42; // 256 → 约 108px
const TORCH_FRAMES = 30;
const TORCH_FPS = 14;
const TORCH_SCALE = 1.15; // 64 → 约 74px

export class LightDecor {
  private root: Node.Type;
  private glow: DrawNode.Type;
  private lanternTex: { [i: number]: Texture2D.Type } = {};
  private torchTex: Texture2D.Type | undefined;
  private lanterns: LanternSpot[] = [];
  private torches: TorchSpot[] = [];
  private t = 0;
  ok = false;

  constructor(parent: Node.Type) {
    this.root = Node();
    this.root.addTo(parent);
    let anyTex = false;
    for (let i = 1; i <= LANTERN_COUNT; i++) {
      const tex = Texture2D("assets/decor/lantern_" + i + ".png");
      if (tex === undefined) {
        continue;
      }
      this.lanternTex[i - 1] = tex;
      anyTex = true;
    }
    if (anyTex) {
      this.ok = true;
    }
    this.torchTex = Texture2D("assets/decor/torch.png");
    if (this.torchTex !== undefined) {
      this.ok = true;
    }
    this.glow = DrawNode();
    this.glow.addTo(this.root);
  }

  // spots 为灯笼挂点（世界坐标）
  addLanterns(spots: { x: number; y: number }[]): void {
    if (!this.ok) {
      return;
    }
    for (const s of spots) {
      const sprites: Sprite.Type[] = [];
      for (let i = 0; i < LANTERN_COUNT; i++) {
        const tex = this.lanternTex[i];
        if (tex === undefined) {
          continue;
        }
        const sp = Sprite(tex);
        sp.filter = TextureFilter.Point;
        sp.anchor = Vec2(0.5, 1);
        sp.scaleX = LANTERN_SCALE;
        sp.scaleY = LANTERN_SCALE;
        sp.position = Vec2(s.x, s.y);
        sp.visible = false;
        sp.addTo(this.root);
        sprites.push(sp);
      }
      if (sprites.length > 0) {
        this.lanterns.push({ x: s.x, y: s.y, phase: (s.x * 0.013) % 6.28, sprites: sprites });
      }
    }
  }

  // spots 为火把落点（世界坐标，y=地面）
  addTorches(spots: { x: number; y: number }[]): void {
    if (this.torchTex === undefined) {
      return;
    }
    for (const s of spots) {
      const sp = Sprite(this.torchTex, Rect(0, 0, 64, 64));
      sp.filter = TextureFilter.Point;
      sp.anchor = Vec2(0.5, 0);
      sp.scaleX = TORCH_SCALE;
      sp.scaleY = TORCH_SCALE;
      sp.position = Vec2(s.x, s.y);
      sp.addTo(this.root);
      this.torches.push({ x: s.x, y: s.y, sp: sp, phase: (s.x * 0.017) % 6.28 });
    }
  }

  update(time: number, dt: number): void {
    this.t = this.t + dt;
    for (const ln of this.lanterns) {
      const idx = Math.floor(this.t * LANTERN_FPS + ln.phase) % ln.sprites.length;
      for (let j = 0; j < ln.sprites.length; j++) {
        ln.sprites[j].visible = j === idx;
      }
    }
    for (const tc of this.torches) {
      const idx = Math.floor(this.t * TORCH_FPS + tc.phase * 2) % TORCH_FRAMES;
      tc.sp.textureRect = Rect(idx * 64, 0, 64, 64);
    }
    this.glow.clear();
    for (const ln of this.lanterns) {
      dot(this.glow, ln.x, ln.y - 50, 52, ink(255, 186, 96, 90), 0.1 + 0.05 * Math.sin(time * 3 + ln.phase));
    }
    for (const tc of this.torches) {
      dot(this.glow, tc.x, tc.y + 40, 40, ink(255, 150, 60, 110), 0.12 + 0.06 * Math.sin(time * 9 + tc.phase));
    }
  }
}
