// game/render_world.ts — 世界渲染器：视差水墨背景 + 世界层（地形/机关/角色）
// 分层：bgDraw（屏幕空间视差背景） <- worldRoot（世界坐标，随摄像机平移）
//       worldRoot 内：platformDraw（地形） -> propDraw（机关道具装饰） -> charDraw（角色动态）
import { Color, DrawNode, Node, Rect, Sprite, Texture2D, TextureFilter, Vec2, View } from "Dora";
import { Palette, ink } from "core/palette";
import {
  BellDef,
  CheckpointDef,
  ClimbWall,
  CollectibleDef,
  GateDef,
  Hazard,
  Ladder,
  LanternDef,
  LoopState,
  MoverDef,
  Platform,
  PlateDef,
  PushStoneDef,
  RopeDef,
  StoryTriggerDef,
} from "core/types";
import type { EnemySystem } from "game/enemies";
import type { MechanismSystem } from "game/mechanisms";
import type { Player } from "game/player";
import {
  arc,
  ATTACK_TIME,
  circle,
  clamp01,
  col,
  dot,
  drawEnemy,
  drawHero,
  drawObserver,
  drawPot,
  drawShenYan,
  drawWave,
  seg,
} from "game/render_chars";
import type { HeroPose } from "game/render_chars";

export interface TowerDataView {
  WORLD_W: number;
  WORLD_H: number;
  platforms: Platform[];
  ladders: Ladder[];
  climbWalls: ClimbWall[];
  hazards: Hazard[];
  collectibles: CollectibleDef[];
  checkpoints: CheckpointDef[];
  ropes: RopeDef[];
  bells: BellDef[];
  plates: PlateDef[];
  lanterns: LanternDef[];
  pushStones: PushStoneDef[];
  gates: GateDef[];
  storyTriggers: StoryTriggerDef[];
  movers: Platform[];
}

export interface NpcSpot {
  x: number;
  y: number;
  facing: number;
  hostile: boolean;
}

export interface ObserverSpot {
  x: number;
  y: number;
}

interface StarDot {
  x: number;
  y: number;
  s: number;
}

interface GatePart {
  gid: string;
  rects: Platform[];
}

const CULL = 900;
const GOLD = ink(212, 168, 84, 255);
const CYAN = ink(108, 156, 148, 255);
const PAPER_DIM = ink(219, 208, 184, 120);

interface BgSpriteRec {
  node: Node.Type;
  band: number;
  f: number;
  spanW: number;
  imgH: number;
  baseUp: number;
  copyIndex: number;
}

interface BgBand {
  node: Node.Type;
  floorTop: number;
}

interface TileGroup {
  node: Node.Type;
  x0: number;
  y0: number;
  x1: number;
  y1: number;
}

const TILE = 64; // 128px 原始瓦片 × 0.5（整数降采样，Point 采样保持像素锐利）
const TILE_SETS = ["autumn", "skyruins", "crystal", "skyruins", "graveyard", "crystal", "skyruins"];
const BAND_BOUNDS = [460, 940, 1430, 1930, 2430, 2985]; // 各带 floorTop 锚点（贴图纵向定位用）
// 带切换阈值（bandOf 用），与 floorTop 解耦：相机贴底后 0 层 camY 恒 ≈576，
// 若沿用 460 会把 0 层永远判给 band1，河滩全景不显示（出生屏大片空白）
const BAND_SWITCH = [620, 940, 1430, 1930, 2430, 2985];

const BG_LAYERS: { path: string; f: number; baseUp: number }[][] = [
  [
    { path: "assets/bg/river_sky.png", f: 0.03, baseUp: 0 },
    { path: "assets/bg/river_clouds1.png", f: 0.08, baseUp: 0 },
    { path: "assets/bg/river_clouds2.png", f: 0.13, baseUp: 0 },
    { path: "assets/bg/river_rocks.png", f: 0.22, baseUp: 0 },
    { path: "assets/bg/river_ground.png", f: 0.3, baseUp: 6 },
  ],
  [
    { path: "assets/bg/autumn_layer0.png", f: 0.12, baseUp: 0 },
    { path: "assets/bg/autumn_layer1.png", f: 0.26, baseUp: 0 },
  ],
  [
    { path: "assets/bg/crystal_layer0.png", f: 0.12, baseUp: 0 },
    { path: "assets/bg/crystal_layer1.png", f: 0.26, baseUp: 0 },
  ],
  [
    { path: "assets/bg/skyruins_layer0.png", f: 0.12, baseUp: 0 },
    { path: "assets/bg/skyruins_layer1.png", f: 0.26, baseUp: 0 },
  ],
  [
    { path: "assets/bg/graveyard_layer0.png", f: 0.12, baseUp: 0 },
    { path: "assets/bg/graveyard_layer1.png", f: 0.26, baseUp: 0 },
  ],
  [
    { path: "assets/bg/moon_far.png", f: 0.06, baseUp: 0 },
    { path: "assets/bg/moon_mid.png", f: 0.18, baseUp: 0 },
  ],
  [
    { path: "assets/bg/moon_far.png", f: 0.06, baseUp: 0 },
    { path: "assets/bg/moon_mid.png", f: 0.18, baseUp: 0 },
  ],
];

function bandOf(camY: number): number {
  let b = 0;
  for (let i = 0; i < BAND_SWITCH.length; i++) {
    if (camY > BAND_SWITCH[i]) {
      b = i + 1;
    }
  }
  return b;
}

function moverOffset(m: MoverDef, time: number): { ox: number; oy: number; k: number } {
  const span = m.period > 0 ? m.period : 3;
  const k = 0.5 + 0.5 * Math.sin((time * Math.PI * 2) / span + m.phase);
  return { ox: (m.bx - m.ax) * k, oy: (m.by - m.ay) * k, k: k };
}

function waveY(wx: number, time: number, i: number): number {
  return Math.sin(wx * 0.018 + time * 1.7 + i * 2.1) * 2.6 + Math.sin(wx * 0.006 - time * 0.8 + i) * 1.6;
}

export class WorldRenderer {
  private data: TowerDataView;
  private parent: Node.Type;
  private bgDraw: DrawNode.Type;
  private worldRoot: Node.Type;
  private platformDraw: DrawNode.Type;
  private propDraw: DrawNode.Type;
  private charDraw: DrawNode.Type;
  private camX: number;
  private camY: number;
  private vw: number;
  private vh: number;
  private stars: StarDot[];
  private gateParts: GatePart[];
  private bgSpriteRoot: Node.Type;
  private bgRecs: BgSpriteRec[] = [];
  private bgBands: BgBand[] = [];
  private tileGroups: TileGroup[] = [];
  private decorNode: Node.Type;
  private heroSprite: Sprite.Type | undefined;
  private heroFxDraw: DrawNode.Type;
  private heroTexOk = false;
  private heroScale = 0.065;
  private pixelBgOk = false;
  private activeBand = -1;
  private texCache: { [key: string]: Texture2D.Type | undefined } = {};
  shenYan: NpcSpot | undefined;
  observer: ObserverSpot | undefined;

  constructor(parent: Node.Type, data: TowerDataView) {
    this.data = data;
    this.parent = parent;
    this.camX = 0;
    this.camY = 0;
    this.vw = View.size.width;
    this.vh = View.size.height;
    this.shenYan = undefined;
    this.observer = undefined;
    this.stars = [];
    for (let i = 0; i < 42; i++) {
      this.stars.push({
        x: (i * 617) % 2600,
        y: 60 + ((i * 149) % 330),
        s: 0.5 + ((i * 37) % 10) / 14,
      });
    }
    this.gateParts = [];
    const byId: { [key: string]: Platform[] } = {};
    for (const p of data.platforms) {
      if (p.kind === "gate" && p.gateId !== undefined) {
        const list = byId[p.gateId];
        if (list === undefined) {
          byId[p.gateId] = [p];
        } else {
          list.push(p);
        }
      }
    }
    for (const g of data.gates) {
      this.gateParts.push({ gid: g.id, rects: byId[g.id] === undefined ? [] : byId[g.id] });
    }
    this.bgSpriteRoot = Node();
    this.bgSpriteRoot.addTo(parent);
    this.bgDraw = DrawNode();
    this.bgDraw.addTo(parent);
    this.worldRoot = Node();
    this.worldRoot.addTo(parent);
    this.platformDraw = DrawNode();
    this.platformDraw.addTo(this.worldRoot);
    this.propDraw = DrawNode();
    this.propDraw.addTo(this.worldRoot);
    this.charDraw = DrawNode();
    this.charDraw.addTo(this.worldRoot);
    // 衍月立绘：位于角色层之上、装饰之下；heroFxDraw 程序化剑光叠在立绘上方
    const heroTex = this.loadTex("assets/characters/衍月.png");
    if (heroTex !== undefined) {
      const sp = Sprite(heroTex);
      sp.anchor = Vec2(0.5, 0);
      this.heroScale = 90 / heroTex.height;
      sp.scaleX = this.heroScale;
      sp.scaleY = this.heroScale;
      sp.addTo(this.worldRoot);
      this.heroSprite = sp;
      this.heroTexOk = true;
    }
    this.heroFxDraw = DrawNode();
    this.heroFxDraw.addTo(this.worldRoot);
    this.decorNode = Node();
    this.decorNode.addTo(this.worldRoot);
    this.buildPixelBackgrounds();
    this.buildPixelTerrain();
    this.buildPixelDecor();
  }

  private loadTex(path: string): Texture2D.Type | undefined {
    const hit = this.texCache[path];
    if (hit !== undefined) {
      return hit;
    }
    const tex = Texture2D(path);
    if (tex === undefined) {
      return undefined;
    }
    this.texCache[path] = tex;
    return tex;
  }

  // title/prologue 下隐藏世界与像素背景（renderer.update 每帧都跑）
  setWorldVisible(v: boolean): void {
    this.bgSpriteRoot.visible = v;
    this.worldRoot.visible = v;
  }

  // 冒烟用统计
  debugPixelStats(): string {
    return "bgRecs=" + this.bgRecs.length + " bands=" + this.bgBands.length + " tiles=" + this.tileGroups.length + " pixelOk=" + this.pixelBgOk + " band=" + this.activeBand;
  }

  private buildPixelBackgrounds(): void {
    const vw = View.size.width;
    const vh = View.size.height;
    for (let band = 0; band < BG_LAYERS.length; band++) {
      const bandNode = Node();
      bandNode.addTo(this.bgSpriteRoot);
      bandNode.visible = false;
      const top = band === 0 ? 220 : BAND_BOUNDS[band - 1];
      this.bgBands.push({ node: bandNode, floorTop: top });
      for (const layer of BG_LAYERS[band]) {
        const tex = this.loadTex(layer.path);
        if (tex === undefined) {
          continue;
        }
        this.pixelBgOk = true;
        const s = Math.max(vw / tex.width, (vh + 40) / tex.height);
        const spanW = tex.width * s;
        const copies = Math.ceil(vw / spanW) + 2;
        for (let j = 0; j < copies; j++) {
          const sp = Sprite(tex);
          if (sp === undefined) {
            continue;
          }
          sp.anchor = Vec2(0, 0);
          sp.scaleX = s;
          sp.scaleY = s;
          sp.filter = TextureFilter.Point;
          sp.addTo(bandNode);
          this.bgRecs.push({
            node: sp,
            band: band,
            f: layer.f,
            spanW: spanW,
            imgH: tex.height * s,
            baseUp: layer.baseUp,
            copyIndex: j,
          });
        }
      }
    }
  }

  private tileSprite(band: Node.Type, tex: Texture2D.Type, x: number, y: number, cropW: number, cropH: number): void {
    const sp = Sprite(tex, Rect(0, 0, cropW, cropH));
    if (sp === undefined) {
      return;
    }
    sp.anchor = Vec2(0, 0);
    sp.scaleX = 0.5;
    sp.scaleY = 0.5;
    sp.filter = TextureFilter.Point;
    sp.position = Vec2(x, y);
    sp.addTo(band);
  }

  private buildPixelTerrain(): void {
    for (const p of this.data.platforms) {
      if (p.kind !== "solid" || p.mover !== undefined || p.w < 300) {
        continue;
      }
      const key = TILE_SETS[p.floor];
      const topTex = this.loadTex("assets/tiles/" + key + "_top.png");
      const fillTex = this.loadTex("assets/tiles/" + key + "_fill.png");
      if (topTex === undefined) {
        continue;
      }
      const node = Node();
      node.addTo(this.worldRoot);
      const topY = p.y + p.h;
      const cols = Math.ceil(p.w / TILE);
      const rows = Math.max(1, Math.ceil(p.h / TILE));
      const remW = p.w - (cols - 1) * TILE;
      for (let c = 0; c < cols; c++) {
        const cw = c === cols - 1 ? remW * 2 : 128;
        this.tileSprite(node, topTex, p.x + c * TILE, topY - TILE, cw, 128);
      }
      for (let r = 1; r < rows; r++) {
        if (fillTex === undefined) {
          break;
        }
        const fy = topY - TILE * (r + 1);
        const fh = r === rows - 1 ? (topY - p.y - TILE * rows) * 2 : 128;
        if (fh <= 0) {
          break;
        }
        for (let c = 0; c < cols; c++) {
          const cw = c === cols - 1 ? remW * 2 : 128;
          this.tileSprite(node, fillTex, p.x + c * TILE, fy, cw, fh);
        }
      }
      this.tileGroups.push({ node: node, x0: p.x, y0: p.y, x1: p.x + p.w, y1: topY });
    }
    // 尖刺坑：主题瓦片铺底
    for (const hz of this.data.hazards) {
      const key = TILE_SETS[hz.floor];
      const spikeTex = this.loadTex("assets/tiles/" + key + "_spike.png");
      if (spikeTex === undefined) {
        continue;
      }
      const node = Node();
      node.addTo(this.worldRoot);
      const cols = Math.ceil(hz.w / TILE);
      for (let c = 0; c < cols; c++) {
        this.tileSprite(node, spikeTex, hz.x + c * TILE, hz.y + 4, 128, 64);
      }
      this.tileGroups.push({ node: node, x0: hz.x, y0: hz.y, x1: hz.x + hz.w, y1: hz.y + hz.h });
    }
    // 梯子：主题 _ladder 竖向铺（裁 92 纹素宽 = 46 世界像素，与碰撞宽度一致）
    for (const l of this.data.ladders) {
      const key = TILE_SETS[l.floor];
      const tex = this.loadTex("assets/tiles/" + key + "_ladder.png");
      if (tex === undefined) {
        continue;
      }
      const node = Node();
      node.addTo(this.worldRoot);
      const rows = Math.ceil(l.h / TILE);
      for (let r = 0; r < rows; r++) {
        const rh = r === rows - 1 ? (l.h - (rows - 1) * TILE) * 2 : 128;
        if (rh <= 0) {
          break;
        }
        this.tileSprite(node, tex, l.x, l.y + l.h - (r + 1) * TILE, 92, rh);
      }
      this.tileGroups.push({ node: node, x0: l.x, y0: l.y, x1: l.x + l.w, y1: l.y + l.h });
    }
    // one-way 薄板：主题 _brick 顶条（36 纹素 = 18 世界像素，整板覆盖）
    for (const p of this.data.platforms) {
      if (p.kind !== "one-way") {
        continue;
      }
      const key = TILE_SETS[p.floor];
      const tex = this.loadTex("assets/tiles/" + key + "_brick.png");
      if (tex === undefined) {
        continue;
      }
      const node = Node();
      node.addTo(this.worldRoot);
      const cols = Math.ceil(p.w / TILE);
      for (let c = 0; c < cols; c++) {
        const cw = c === cols - 1 ? (p.w - (cols - 1) * TILE) * 2 : 128;
        if (cw <= 0) {
          break;
        }
        this.tileSprite(node, tex, p.x + c * TILE, p.y, cw, 36);
      }
      this.tileGroups.push({ node: node, x0: p.x, y0: p.y, x1: p.x + p.w, y1: p.y + p.h });
    }
  }

  private buildPixelDecor(): void {
    const decor: { path: string; x: number; y: number }[] = [
      { path: "assets/tiles/skyruins_portal.png", x: 6050, y: 3290 },
      { path: "assets/tiles/graveyard_lantern.png", x: 4560, y: 2180 },
      { path: "assets/tiles/graveyard_lantern.png", x: 5680, y: 2180 },
      { path: "assets/tiles/graveyard_headstone.png", x: 4700, y: 2180 },
      { path: "assets/tiles/graveyard_headstone.png", x: 6050, y: 2180 },
      { path: "assets/tiles/skyruins_magicstone.png", x: 5000, y: 1680 },
      { path: "assets/tiles/skyruins_magicstone.png", x: 5200, y: 2680 },
    ];
    for (const d of decor) {
      const tex = this.loadTex(d.path);
      if (tex === undefined) {
        continue;
      }
      const sp = Sprite(tex);
      if (sp === undefined) {
        continue;
      }
      sp.anchor = Vec2(0.5, 0);
      sp.scaleX = 0.5;
      sp.scaleY = 0.5;
      sp.filter = TextureFilter.Point;
      sp.position = Vec2(d.x, d.y);
      sp.addTo(this.decorNode);
    }
  }

  setCamera(camX: number, camY: number, shakeX: number, shakeY: number): void {
    this.camX = camX;
    this.camY = camY;
    const vw = View.size.width;
    const vh = View.size.height;
    this.vw = vw;
    this.vh = vh;
    this.worldRoot.position = Vec2(vw / 2 - camX + shakeX, vh / 2 - camY + shakeY);
    this.updatePixelBackdrop(camX, camY, vw, vh);
    for (const g of this.tileGroups) {
      g.node.visible = this.inView(g.x0, g.y0 - 40, g.x1, g.y1 + 40);
    }
  }

  // 像素视差：横向环绕 + 纵向随层顶对齐，按摄像机所在层带切换
  private updatePixelBackdrop(camX: number, camY: number, vw: number, vh: number): void {
    if (!this.pixelBgOk) {
      return;
    }
    const band = bandOf(camY);
    for (let i = 0; i < this.bgBands.length; i++) {
      this.bgBands[i].node.visible = i === band;
    }
    const bandTop = this.bgBands[band].floorTop;
    const mod = (x: number, m: number): number => {
      const r = x % m;
      return r < 0 ? r + m : r;
    };
    for (const rec of this.bgRecs) {
      if (rec.band !== band) {
        continue;
      }
      const offX = mod(camX * rec.f, rec.spanW);
      rec.node.x = -vw / 2 - offX + rec.copyIndex * rec.spanW;
      const yBase = -vh / 2 + 1 + rec.baseUp;
      const targetY = yBase + (bandTop - camY) * rec.f * 0.6;
      const yMin = vh / 2 - rec.imgH + 1;
      rec.node.y = targetY < yMin ? yMin : targetY;
    }
    this.activeBand = band;
  }

  private inViewX(x0: number, x1: number): boolean {
    return x1 >= this.camX - this.vw / 2 - CULL && x0 <= this.camX + this.vw / 2 + CULL;
  }

  private inViewY(y0: number, y1: number): boolean {
    return y1 >= this.camY - this.vh / 2 - CULL && y0 <= this.camY + this.vh / 2 + CULL;
  }

  private inView(x0: number, y0: number, x1: number, y1: number): boolean {
    return this.inViewX(x0, x1) && this.inViewY(y0, y1);
  }

  update(dt: number, state: LoopState, player: Player, enemies: EnemySystem, mech: MechanismSystem, time: number): void {
    void dt;
    this.drawBackground(time, state.phaseIndex % 8);
    this.drawTerrain(time);
    this.drawProps(time, state);
    this.drawChars(time, state, player, enemies, mech);
  }

  // 背景层：宣纸底 + 星月 + 三重山脊 + 宝塔剪影 + 雾带 + 底部水纹（全部屏幕空间）
  private drawBackground(time: number, phase: number): void {
    const d = this.bgDraw;
    d.clear();
    const vw = this.vw;
    const vh = this.vh;
    const x0 = -vw / 2;
    const y0 = -vh / 2;
    if (!this.pixelBgOk) {
      d.drawPolygon(
        [Vec2(x0 - 4, y0 - 4), Vec2(x0 + vw + 8, y0 - 4), Vec2(x0 + vw + 8, y0 + vh + 8), Vec2(x0 - 4, y0 + vh + 8)],
        col(Palette.paper),
        0,
        Color(0, 0, 0, 0)
      );
    }
    // 远星（极低视差，随摄像机横向缓移并环绕）
    const span = vw + 80;
    for (let i = 0; i < this.stars.length; i++) {
      const st = this.stars[i];
      let wx = st.x - this.camX * 0.04;
      wx = wx % span;
      if (wx < 0) {
        wx += span;
      }
      const sx = wx - 40 - vw / 2;
      const sy = y0 + st.y;
      const tw = 0.22 + 0.3 * (0.5 + 0.5 * Math.sin(time * 1.8 + i * 1.7));
      dot(d, sx, sy, st.s, Palette.moonWhite, tw);
    }
    // 月亮：halo + 月盘 + 纸色遮挡圆成相（phase 4 满月，0 新月）
    const mx = vw * 0.32 - this.camX * 0.015;
    const my = y0 + vh * 0.78 + this.camY * 0.008;
    const r = 44;
    dot(d, mx, my, 84, ink(246, 241, 226, 9));
    dot(d, mx, my, 64, ink(246, 241, 226, 15));
    dot(d, mx, my, 50, ink(246, 241, 226, 26));
    dot(d, mx, my, r, Palette.moonWhite);
    dot(d, mx - r * 0.22, my + r * 0.18, r * 0.12, ink(196, 200, 192, 46));
    dot(d, mx + r * 0.3, my - r * 0.12, r * 0.08, ink(196, 200, 192, 40));
    dot(d, mx + r * 0.05, my - r * 0.4, r * 0.06, ink(196, 200, 192, 36));
    const k = phase / 8;
    if (k < 1) {
      const off = 4 * r * Math.min(k, 1 - k);
      const sign = k <= 0.5 ? -1 : 1;
      dot(d, mx + sign * off, my, r + 1.5, this.pixelBgOk ? ink(14, 18, 30, 255) : Palette.paper);
    }
    // 三重山脊（视差 0.12 / 0.22 / 0.35，sin 叠加脊线，折带填充）
    if (!this.pixelBgOk) {
      const ridges = [
        { p: 0.12, base: -70, a1: 46, a2: 18, c: ink(101, 112, 107, 50), s: 0.006, s2: 0.017 },
        { p: 0.22, base: -120, a1: 58, a2: 22, c: ink(84, 94, 90, 85), s: 0.007, s2: 0.021 },
        { p: 0.35, base: -180, a1: 70, a2: 26, c: ink(66, 74, 70, 130), s: 0.008, s2: 0.026 },
      ];
      for (let ri = 0; ri < ridges.length; ri++) {
        const rg = ridges[ri];
        const verts: Vec2.Type[] = [];
        for (let sx = -64; sx <= vw + 64; sx += 64) {
          const wxs = sx + this.camX * rg.p;
          const ry = rg.base - this.camY * rg.p * 0.5 + rg.a1 * Math.sin(wxs * rg.s + ri * 2.3) + rg.a2 * Math.sin(wxs * rg.s2 + ri * 1.1);
          verts.push(Vec2(sx - vw / 2, ry));
        }
        verts.push(Vec2(vw / 2 + 64, y0 - 6));
        verts.push(Vec2(-vw / 2 - 64, y0 - 6));
        d.drawPolygon(verts, col(rg.c), 0, Color(0, 0, 0, 0));
      }
      this.drawPagoda(time);
      this.drawMist(time);
      if (this.camY - vh / 2 < 300) {
        this.drawWaterFront(time);
      }
    }
  }

  private drawPagoda(time: number): void {
    const d = this.bgDraw;
    const vw = this.vw;
    const baseX = 4300 - this.camX * 0.7;
    const px = baseX - vw / 2;
    if (Math.abs(px) > vw / 2 + 220) {
      return;
    }
    const baseY = -150 - this.camY * 0.35;
    const inkTower = ink(72, 80, 76, 190);
    // 塔身：七层逐收的窄梯形
    let w = 150;
    let h = 30;
    let cy = baseY;
    for (let i = 0; i < 7; i++) {
      const nw = w * 0.86;
      d.drawPolygon(
        [Vec2(px - w / 2, cy), Vec2(px + w / 2, cy), Vec2(px + nw / 2, cy + h), Vec2(px - nw / 2, cy + h)],
        col(inkTower),
        0,
        Color(0, 0, 0, 0)
      );
      // 层檐外挑
      seg(d, px - w / 2 - 14, cy + h, px + w / 2 + 14, cy + h, 4.5, inkTower);
      seg(d, px - w / 2 - 14, cy + h, px - w / 2 - 20, cy + h - 7, 2.6, inkTower);
      seg(d, px + w / 2 + 14, cy + h, px + w / 2 + 20, cy + h - 7, 2.6, inkTower);
      cy += h;
      h *= 0.92;
      w = nw;
    }
    // 塔刹
    seg(d, px, cy, px, cy + 30, 3, inkTower);
    circle(d, px, cy + 34, 6, inkTower, 10);
    // 檐下灯火：随 time 微闪的暖点
    const flick = 0.6 + 0.4 * Math.sin(time * 2.2);
    for (let i = 0; i < 4; i++) {
      dot(d, px - 26 + i * 17, baseY + 60 + i * 32, 2.4, GOLD, 0.35 + 0.3 * flick);
    }
  }

  private drawMist(time: number): void {
    const d = this.bgDraw;
    const vw = this.vw;
    const span = vw + 500;
    for (let i = 0; i < 3; i++) {
      const speed = 12 + i * 9;
      const bandY = -170 + i * 55 + Math.sin(time * 0.3 + i * 1.7) * 8;
      for (let c = 0; c < 3; c++) {
        let wx = time * speed + c * 460 + i * 190;
        wx = wx % span;
        if (wx < 0) {
          wx += span;
        }
        const cx0 = wx - 250 - vw / 2;
        for (let j = 0; j < 6; j++) {
          const jx = cx0 + j * 84;
          if (jx < -vw / 2 - 120 || jx > vw / 2 + 120) {
            continue;
        }
          const jy = bandY + Math.sin(jx * 0.01 + time * 0.5 + i) * 6;
          dot(d, jx, jy, 16 - i * 3, Palette.paleInk, 0.1 + i * 0.02);
        }
      }
    }
  }

  private drawWaterFront(time: number): void {
    const d = this.bgDraw;
    const vw = this.vw;
    const bot = -this.vh / 2;
    const top = bot + 46;
    d.drawPolygon(
      [Vec2(-vw / 2 - 4, bot - 4), Vec2(vw / 2 + 8, bot - 4), Vec2(vw / 2 + 8, top), Vec2(-vw / 2 - 4, top)],
      col(ink(90, 110, 105, 26)),
      0,
      Color(0, 0, 0, 0)
    );
    for (let i = 0; i < 3; i++) {
      const wy = bot + 12 + i * 12;
      for (let sx = -vw / 2; sx < vw / 2; sx += 46) {
        seg(
          d,
          sx,
          wy + waveY(sx, time, i),
          sx + 46,
          wy + waveY(sx + 46, time, i),
          1.6,
          i === 0 ? CYAN : Palette.paleInk,
          0.22 + i * 0.06
        );
      }
    }
  }

  // 世界层地形：石台/木台/单向薄板/移动平台/梯子/攀爬壁（视野±900 裁剪）
  private drawTerrain(time: number): void {
    const d = this.platformDraw;
    d.clear();
    for (const p of this.data.platforms) {
      if (p.kind === "gate") {
        continue;
      }
      if (!this.inView(p.x, p.y - 60, p.x + p.w, p.y + p.h + 60)) {
        continue;
      }
      if (p.mover !== undefined) {
        this.drawMover(d, p, time);
        continue;
      }
      if (p.kind === "solid") {
        if (p.w >= 300) {
          // 石台：深墨梯形 + 浅色顶边线 + 一道裂纹
          d.drawPolygon(
            [
              Vec2(p.x + 5, p.y + p.h),
              Vec2(p.x + p.w - 5, p.y + p.h),
              Vec2(p.x + p.w - 1, p.y + 1),
              Vec2(p.x + 1, p.y + 1),
            ],
            col(ink(38, 45, 44, 225)),
            0,
            Color(0, 0, 0, 0)
          );
          seg(d, p.x + 4, p.y + p.h - 1, p.x + p.w - 4, p.y + p.h - 1, 2, PAPER_DIM);
          const crackX = p.x + 30 + (p.x % Math.max(60, p.w - 90));
          seg(d, crackX, p.y + p.h - 8, crackX + 22, p.y + 8, 1.4, ink(26, 32, 31, 80));
        } else {
          // 木台：褐墨厚板 + 顶边高光 + 端头钉点
          d.drawPolygon(
            [
              Vec2(p.x, p.y + p.h),
              Vec2(p.x + p.w, p.y + p.h),
              Vec2(p.x + p.w, p.y + 2),
              Vec2(p.x, p.y + 2),
            ],
            col(ink(96, 70, 48, 220)),
            0,
            Color(0, 0, 0, 0)
          );
          seg(d, p.x + 2, p.y + p.h - 1, p.x + p.w - 2, p.y + p.h - 1, 1.8, ink(158, 120, 84, 150));
          dot(d, p.x + 5, p.y + p.h - 5, 1.6, Palette.inkDark, 0.75);
          dot(d, p.x + p.w - 5, p.y + p.h - 5, 1.6, Palette.inkDark, 0.75);
        }
      } else {
        // one-way：细窄木板
        d.drawPolygon(
          [
            Vec2(p.x, p.y + p.h),
            Vec2(p.x + p.w, p.y + p.h),
            Vec2(p.x + p.w, p.y + p.h - 8),
            Vec2(p.x, p.y + p.h - 8),
          ],
          col(ink(110, 82, 56, 200)),
          0,
          Color(0, 0, 0, 0)
        );
        seg(d, p.x + 2, p.y + p.h - 1, p.x + p.w - 2, p.y + p.h - 1, 1.5, PAPER_DIM);
      }
    }
    for (const l of this.data.ladders) {
      if (!this.inView(l.x, l.y, l.x + l.w, l.y + l.h)) {
        continue;
      }
      const wood = ink(84, 66, 44, 235);
      seg(d, l.x + 2, l.y, l.x + 2, l.y + l.h, 3, wood);
      seg(d, l.x + l.w - 2, l.y, l.x + l.w - 2, l.y + l.h, 3, wood);
      for (let ry = l.y + 10; ry < l.y + l.h - 4; ry += 18) {
        seg(d, l.x + 4, ry, l.x + l.w - 4, ry, 2.4, ink(102, 80, 52, 220));
      }
    }
    for (const cw of this.data.climbWalls) {
      if (!this.inView(cw.x, cw.y, cw.x + cw.w, cw.y + cw.h)) {
        continue;
      }
      const crag = ink(64, 58, 52, 200);
      seg(d, cw.x, cw.y + cw.h, cw.x + cw.w, cw.y + cw.h, 3, crag);
      for (let i = 0; i <= 4; i++) {
        const xx = cw.x + 6 + (i * (cw.w - 12)) / 4;
        seg(d, xx, cw.y + cw.h, xx + 7, cw.y + cw.h * 0.55, 3.4, crag);
        seg(d, xx + 7, cw.y + cw.h * 0.55, xx + 2, cw.y + 4, 2.6, ink(64, 58, 52, 130));
      }
    }
  }

  private drawMover(d: DrawNode.Type, p: Platform, time: number): void {
    const m = p.mover;
    if (m === undefined) {
      return;
    }
    const mv = moverOffset(m, time);
    const x = m.ax + mv.ox;
    const y = m.ay + mv.oy;
    // 轨道虚线
    for (let i = 0; i < 8; i++) {
      const t0 = i / 8 + 0.02;
      const t1 = t0 + 0.06;
      seg(
        d,
        m.ax + (m.bx - m.ax) * t0 + p.w / 2,
        m.ay + (m.by - m.ay) * t0 + p.h / 2,
        m.ax + (m.bx - m.ax) * t1 + p.w / 2,
        m.ay + (m.by - m.ay) * t1 + p.h / 2,
        2,
        PAPER_DIM
      );
    }
    d.drawPolygon(
      [Vec2(x, y + p.h), Vec2(x + p.w, y + p.h), Vec2(x + p.w, y + 2), Vec2(x, y + 2)],
      col(ink(52, 60, 58, 230)),
      0,
      Color(0, 0, 0, 0)
    );
    seg(d, x + 2, y + p.h - 1, x + p.w - 2, y + p.h - 1, 1.8, PAPER_DIM);
    dot(d, x + p.w / 2, y + p.h / 2, 4 + Math.sin(time * 3) * 1, GOLD, 0.85);
  }

  // 世界层机关道具：绳/钟/压板/灯笼/门/检查点/收集品/装饰
  private drawProps(time: number, state: LoopState): void {
    const d = this.propDraw;
    d.clear();
    this.drawGates(d, state);
    this.drawRopes(d, time, state);
    this.drawBells(d, time, state);
    this.drawPlates(d, time, state);
    this.drawLanterns(d, time, state);
    this.drawCheckpoints(d, time, state);
    this.drawCollectibles(d, time, state);
    this.drawDecor(d, time);
  }

  private drawGates(d: DrawNode.Type, state: LoopState): void {
    for (const gp of this.gateParts) {
      if (gp.rects.length === 0) {
        continue;
      }
      const open = state.openedGates[gp.gid] === true;
      let x0 = 1e9;
      let y0 = 1e9;
      let x1 = -1e9;
      let y1 = -1e9;
      for (const r of gp.rects) {
        x0 = Math.min(x0, r.x);
        y0 = Math.min(y0, r.y);
        x1 = Math.max(x1, r.x + r.w);
        y1 = Math.max(y1, r.y + r.h);
      }
      if (!this.inView(x0, y0, x1, y1)) {
        continue;
      }
      // 两柱：取最左/最右的栅条矩形外缘
      const postC = ink(52, 46, 38, 235);
      for (const r of gp.rects) {
        const isPost = r.w <= 14 || r.h >= (y1 - y0) * 0.9;
        if (!open || isPost) {
          d.drawPolygon(
            [Vec2(r.x, r.y + r.h), Vec2(r.x + r.w, r.y + r.h), Vec2(r.x + r.w, r.y), Vec2(r.x, r.y)],
            col(isPost ? postC : ink(64, 58, 50, 220)),
            0,
            Color(0, 0, 0, 0)
          );
        }
      }
      // 横梁 + 门楣装饰
      seg(d, x0 - 6, y1 + 4, x1 + 6, y1 + 4, 4, postC);
      seg(d, x0 - 6, y1 + 8, x1 + 6, y1 + 8, 1.6, GOLD, 0.5);
      if (!open) {
        // 栅条斜撑：三道细斜线
        for (let i = 1; i <= 3; i++) {
          const sx = x0 + ((x1 - x0) * i) / 4;
          seg(d, sx - 10, y0 + 6, sx + 10, y1 - 6, 1.8, ink(84, 76, 62, 180));
        }
      }
    }
  }

  private drawRopes(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const r of this.data.ropes) {
      if (!this.inView(r.x - 30, r.y - r.length - 30, r.x + 30, r.y + 10)) {
        continue;
      }
      if (state.cutRopes[r.id] === true) {
        // 已断：短桩 + 下坠半截淡出
        seg(d, r.x, r.y, r.x - 2, r.y - 12, 3, Palette.inkDark, 0.9);
        const fall = Math.min(r.length * 0.5, 60);
        for (let i = 0; i < 4; i++) {
          const yy0 = r.y - 12 - (i * fall) / 4;
          const yy1 = r.y - 12 - ((i + 1) * fall) / 4;
          const sway = Math.sin(time * 2.4 + i) * 3;
          seg(d, r.x - 2 + sway * 0.5, yy0, r.x - 4 + sway, yy1, 2.2, Palette.inkSoft, 0.5 - i * 0.1);
        }
      } else {
        // 未断：从锚点垂下的微摆弧线
        let px = r.x;
        let py = r.y;
        for (let i = 1; i <= 8; i++) {
          const tt = i / 8;
          const yy = r.y - r.length * tt;
          const sway = Math.sin(time * 1.6 + tt * 3 + r.x * 0.05) * 4 * tt;
          const nx = r.x + sway;
          seg(d, px, py, nx, yy, 2.6, Palette.inkDark, 0.92);
          px = nx;
          py = yy;
        }
        dot(d, px, py, 3, Palette.inkDark, 0.9);
      }
    }
  }

  private drawBells(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const b of this.data.bells) {
      if (!this.inView(b.x - 40, b.y, b.x + 40, b.y + 60)) {
        continue;
      }
      const frame = ink(58, 50, 40, 230);
      seg(d, b.x - 20, b.y, b.x - 20, b.y + 46, 3.5, frame);
      seg(d, b.x + 20, b.y, b.x + 20, b.y + 46, 3.5, frame);
      seg(d, b.x - 26, b.y + 46, b.x + 26, b.y + 46, 3.5, frame);
      d.drawPolygon(
        [Vec2(b.x - 13, b.y + 44), Vec2(b.x + 13, b.y + 44), Vec2(b.x + 16, b.y + 24), Vec2(b.x - 16, b.y + 24)],
        col(ink(46, 52, 50, 235)),
        0,
        Color(0, 0, 0, 0)
      );
      seg(d, b.x - 17, b.y + 24, b.x + 17, b.y + 24, 2, GOLD, 0.5);
      dot(d, b.x, b.y + 21, 2.2, GOLD, 0.8);
      if (state.rungBells[b.id] === true) {
        const pulse = (time * 0.9) % 1;
        const pulse2 = (pulse + 0.5) % 1;
        circle(d, b.x, b.y + 30, 10 + pulse * 46, GOLD, 18, (1 - pulse) * 0.8);
        circle(d, b.x, b.y + 30, 10 + pulse2 * 46, GOLD, 18, (1 - pulse2) * 0.5);
      }
    }
  }

  private drawPlates(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const pl of this.data.plates) {
      if (!this.inView(pl.x - 44, pl.y, pl.x + 44, pl.y + 16)) {
        continue;
      }
      const on = state.platesActive[pl.id] === true;
      const sink = on ? 4 : 0;
      d.drawPolygon(
        [
          Vec2(pl.x - 36, pl.y + 10 - sink),
          Vec2(pl.x + 36, pl.y + 10 - sink),
          Vec2(pl.x + 32, pl.y + 2 - sink),
          Vec2(pl.x - 32, pl.y + 2 - sink),
        ],
        col(ink(on ? 30 : 42, on ? 36 : 50, on ? 34 : 48, 235)),
        0,
        Color(0, 0, 0, 0)
      );
      if (on) {
        seg(d, pl.x - 36, pl.y + 11 - sink, pl.x + 36, pl.y + 11 - sink, 1.6, GOLD, 0.55 + 0.25 * Math.sin(time * 6));
      } else {
        seg(d, pl.x - 32, pl.y + 10, pl.x + 32, pl.y + 10, 1.2, PAPER_DIM);
      }
    }
  }

  private drawLanterns(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const ln of this.data.lanterns) {
      if (!this.inView(ln.x - 30, ln.y, ln.x + 30, ln.y + 76)) {
        continue;
      }
      const pole = ink(70, 60, 46, 235);
      seg(d, ln.x, ln.y, ln.x, ln.y + 60, 4, pole);
      seg(d, ln.x - 11, ln.y + 60, ln.x + 11, ln.y + 60, 3, pole);
      seg(d, ln.x, ln.y + 60, ln.x, ln.y + 58, 1.6, pole);
      const bx = ln.x;
      const by = ln.y + 46;
      const lit = state.lanternsLit[ln.id] === true;
      let alpha = 1;
      if (state.lanternFailed) {
        const flash = 0.5 + 0.5 * Math.sin(time * 9);
        alpha = lit ? 0.5 + 0.5 * flash : 0.35;
      }
      if (lit) {
        dot(d, bx, by, 17, ink(244, 196, 120, 42), alpha);
        d.drawPolygon(
          [Vec2(bx - 9, by + 11), Vec2(bx + 9, by + 11), Vec2(bx + 7.5, by - 11), Vec2(bx - 7.5, by - 11)],
          col(ink(238, 178, 92, 150), alpha),
          0,
          Color(0, 0, 0, 0)
        );
        dot(d, bx, by, 5, ink(255, 232, 180, 220), alpha);
      } else {
        d.drawPolygon(
          [Vec2(bx - 9, by + 11), Vec2(bx + 9, by + 11), Vec2(bx + 7.5, by - 11), Vec2(bx - 7.5, by - 11)],
          col(ink(58, 62, 60, 200)),
          0,
          Color(0, 0, 0, 0)
        );
      }
      seg(d, bx - 9, by + 11, bx + 9, by + 11, 2, ink(120, 84, 44, 235), alpha);
      seg(d, bx - 7.5, by - 11, bx + 7.5, by - 11, 2, ink(120, 84, 44, 235), alpha);
      if (state.lanternFailed && lit) {
        dot(d, bx, by, 8, ink(140, 59, 59, 90), alpha);
      }
    }
  }

  private drawCheckpoints(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const cp of this.data.checkpoints) {
      if (!this.inView(cp.x - 60, cp.y, cp.x + 60, cp.y + 90)) {
        continue;
      }
      const active = state.checkpointsActivated[cp.id] === true;
      const stone = ink(44, 50, 48, 235);
      d.drawPolygon(
        [Vec2(cp.x - 7, cp.y + 40), Vec2(cp.x + 7, cp.y + 40), Vec2(cp.x + 8, cp.y), Vec2(cp.x - 8, cp.y)],
        col(stone),
        0,
        Color(0, 0, 0, 0)
      );
      dot(d, cp.x, cp.y + 40, 7, stone);
      seg(d, cp.x - 4, cp.y + 28, cp.x + 4, cp.y + 28, 1.2, PAPER_DIM, 0.8);
      seg(d, cp.x + 10, cp.y, cp.x + 10, cp.y + 64, 2.6, ink(70, 60, 46, 235));
      if (active) {
        // 幡立起并随风微动 + 青色光环脉冲
        const flap = Math.sin(time * 3) * 2;
        d.drawPolygon(
          [Vec2(cp.x + 10, cp.y + 64), Vec2(cp.x + 32, cp.y + 60 + flap), Vec2(cp.x + 32, cp.y + 50 + flap), Vec2(cp.x + 10, cp.y + 54)],
          col(CYAN, 0.8),
          0,
          Color(0, 0, 0, 0)
        );
        seg(d, cp.x + 10, cp.y + 54, cp.x + 32, cp.y + 50 + flap, 1.2, CYAN, 0.5);
        const pulse = (time * 0.7) % 1;
        circle(d, cp.x, cp.y + 24, 14 + pulse * 30, CYAN, 16, (1 - pulse) * 0.5);
      } else {
        seg(d, cp.x + 10, cp.y + 64, cp.x + 13, cp.y + 50, 5, Palette.inkSoft, 0.85);
      }
    }
  }

  private drawCollectibles(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const c of this.data.collectibles) {
      if (c.loops !== undefined && c.loops.indexOf(state.loopIndex) < 0) {
        continue;
      }
      if (state.collectedIds[c.id] === true) {
        continue;
      }
      if (!this.inView(c.x - 40, c.y - 10, c.x + 40, c.y + 40)) {
        continue;
      }
      const bob = Math.sin(time * 2 + c.x * 0.1) * 3;
      const cx = c.x;
      const cy = c.y + bob;
      if (c.kind === "moonstone") {
        dot(d, cx, cy + 12, 13, CYAN, 0.25);
        dot(d, cx, cy + 12, 6.5, CYAN);
        dot(d, cx - 2, cy + 14, 2, Palette.moonWhite, 0.9);
      } else if (c.kind === "mechanism") {
        const rot = time * 1.2;
        circle(d, cx, cy + 10, 7, GOLD, 12, 0.95);
        for (let i = 0; i < 6; i++) {
          const a = rot + (i / 6) * Math.PI * 2;
          seg(d, cx + Math.cos(a) * 7, cy + 10 + Math.sin(a) * 7, cx + Math.cos(a) * 10.5, cy + 10 + Math.sin(a) * 10.5, 2.2, GOLD, 0.95);
        }
        dot(d, cx, cy + 10, 2.2, GOLD, 0.9);
      } else if (c.kind === "token") {
        d.drawPolygon(
          [Vec2(cx - 7, cy + 16), Vec2(cx + 7, cy + 16), Vec2(cx + 7, cy + 4), Vec2(cx - 7, cy + 4)],
          col(ink(112, 84, 56, 225)),
          0,
          Color(0, 0, 0, 0)
        );
        circle(d, cx, cy + 20, 3.2, Palette.inkDark, 8, 0.9);
        seg(d, cx - 3.5, cy + 12, cx + 3.5, cy + 12, 1, PAPER_DIM, 0.9);
      } else {
        dot(d, cx, cy + 8, 5.5, CYAN, 0.75);
        d.drawPolygon(
          [Vec2(cx, cy + 18), Vec2(cx + 3.4, cy + 10), Vec2(cx - 3.4, cy + 10)],
          col(CYAN, 0.75),
          0,
          Color(0, 0, 0, 0)
        );
        dot(d, cx - 1.6, cy + 7.5, 1.6, Palette.moonWhite, 0.9);
      }
    }
  }

  // 装饰：机关层双齿轮 + 观星台星盘 + 月相装置
  private drawDecor(d: DrawNode.Type, time: number): void {
    if (this.inView(1100, 2180, 2300, 2340)) {
      this.drawGear(d, 1200, 2260, 46, 18, time * 0.35);
      this.drawGear(d, 2200, 2260, 34, 14, -time * 0.5 + 0.4);
    }
    if (this.inView(3900, 3200, 4500, 3600)) {
      const cx = 4200;
      const cy = 3470;
      circle(d, cx, cy, 34, GOLD, 24, 0.5);
      circle(d, cx, cy, 22, GOLD, 20, 0.65);
      arc(d, cx, cy, 28, time * 0.4, time * 0.4 + Math.PI * 1.4, 14, 2, CYAN, 0.7);
      for (let i = 0; i < 12; i++) {
        const a = (i / 12) * Math.PI * 2 + time * 0.05;
        seg(d, cx + Math.cos(a) * 34, cy + Math.sin(a) * 34, cx + Math.cos(a) * 39, cy + Math.sin(a) * 39, 1.6, GOLD, 0.6);
      }
      dot(d, cx, cy, 3.4, CYAN, 0.9);
    }
    if (this.inView(5950, 3250, 6350, 3550)) {
      const cx = 6150;
      const cy = 3390;
      circle(d, cx, cy, 46, GOLD, 28, 0.55);
      circle(d, cx, cy, 34, GOLD, 24, 0.7);
      circle(d, cx, cy, 22, GOLD, 20, 0.85);
      dot(d, cx, cy, 8, CYAN, 0.85 + 0.15 * Math.sin(time * 2.4));
      const oa = time * 1.1;
      const ox = cx + Math.cos(oa) * 22;
      const oy = cy + Math.sin(oa) * 22;
      dot(d, ox, oy, 8, CYAN, 0.3);
      dot(d, ox, oy, 4, Palette.moonWhite, 0.95);
    }
  }

  private drawGear(d: DrawNode.Type, cx: number, cy: number, r: number, teeth: number, rot: number): void {
    const c = ink(70, 62, 50, 200);
    circle(d, cx, cy, r * 0.62, c, 20, 0.9);
    for (let i = 0; i < teeth; i++) {
      const a = rot + (i / teeth) * Math.PI * 2;
      seg(d, cx + Math.cos(a) * r * 0.62, cy + Math.sin(a) * r * 0.62, cx + Math.cos(a) * r, cy + Math.sin(a) * r, 3.4, c, 0.95);
    }
    for (let i = 0; i < 4; i++) {
      const a = rot + (i / 4) * Math.PI * 2;
      seg(d, cx, cy, cx + Math.cos(a) * r * 0.5, cy + Math.sin(a) * r * 0.5, 2.2, c, 0.6);
    }
    dot(d, cx, cy, 3.6, c, 0.95);
  }

  // 角色层：投掷物/震波/敌人/推石/NPC/玩家（后画在上）
  private drawChars(time: number, state: LoopState, player: Player, enemies: EnemySystem, mech: MechanismSystem): void {
    const d = this.charDraw;
    d.clear();
    for (const p of enemies.pots) {
      if (!p.alive) {
        continue;
      }
      if (this.inView(p.x - 20, p.y - 20, p.x + 20, p.y + 20)) {
        drawPot(d, p.x, p.y, time);
      }
    }
    for (const wv of enemies.waves) {
      if (this.inView(wv.x - 40, wv.y - 20, wv.x + 40, wv.y + 50)) {
        drawWave(d, wv.x, wv.y, wv.dir, time);
      }
    }
    for (const e of enemies.enemies) {
      if (e.dead && e.deathTimer <= 0) {
        continue;
      }
      if (this.inView(e.body.x - 60, e.body.y - e.body.h / 2, e.body.x + 60, e.body.y + e.body.h / 2)) {
        drawEnemy(d, e, e.animTime);
      }
    }
    for (const s of mech.stones) {
      if (!this.inView(s.x - 40, s.y - 40, s.x + 40, s.y + 40)) {
        continue;
      }
      d.drawPolygon(
        [
          Vec2(s.x - s.w / 2, s.y + s.h / 2),
          Vec2(s.x + s.w / 2, s.y + s.h / 2),
          Vec2(s.x + s.w / 2 - 2, s.y - s.h / 2),
          Vec2(s.x - s.w / 2 + 2, s.y - s.h / 2),
        ],
        col(ink(58, 54, 48, 235)),
        0,
        Color(0, 0, 0, 0)
      );
      seg(d, s.x - s.w / 2 + 6, s.y + s.h / 2 - 6, s.x, s.y - s.h / 2 + 8, 1.4, ink(40, 37, 33, 120));
      dot(d, s.x - s.w / 4, s.y + s.h / 4, 2.4, PAPER_DIM, 0.8);
    }
    if (this.shenYan !== undefined) {
      const sy = this.shenYan;
      if (this.inView(sy.x - 60, sy.y - 20, sy.x + 60, sy.y + 100)) {
        drawShenYan(d, sy.x, sy.y, sy.facing, time, sy.hostile);
      }
    }
    if (this.observer !== undefined) {
      const ob = this.observer;
      if (this.inView(ob.x - 50, ob.y, ob.x + 50, ob.y + 130)) {
        drawObserver(d, ob.x, ob.y, time);
      }
    }
    const px = player.body.x;
    const py = player.body.y - player.body.h / 2;
    const blink = player.invuln > 0 && Math.sin(time * 40) < -0.4;
    const pose = this.heroPose(player);
    const visible = !blink && this.inView(px - 80, py - 20, px + 80, py + 120);
    if (this.heroTexOk) {
      this.updateHeroSprite(px, py, player.facing, pose, player.animTime, state.phaseIndex, visible);
    } else if (visible) {
      drawHero(d, px, py, player.facing, pose, player.animTime, state.phaseIndex);
    }
  }

  // 立绘模式：Sprite 定位/翻转/呼吸浮动，攻击剑光弧线与月光淡晕叠画在 heroFxDraw
  private updateHeroSprite(
    x: number,
    y: number,
    facing: number,
    pose: HeroPose,
    t: number,
    phaseIndex: number,
    visible: boolean
  ): void {
    const sp = this.heroSprite;
    const f = this.heroFxDraw;
    f.clear();
    if (sp === undefined || !visible) {
      if (sp !== undefined) {
        sp.visible = false;
      }
      return;
    }
    sp.visible = true;
    let bob = 0;
    if (pose === "idle") {
      bob = Math.sin(t * 2) * 1.6;
    } else if (pose === "run") {
      bob = -Math.abs(Math.sin(t * 12)) * 2.2;
    } else if (pose === "jump") {
      bob = 2.5;
    } else if (pose === "fall") {
      bob = -1.5;
    }
    sp.position = Vec2(x, y + bob);
    sp.scaleX = this.heroScale * facing;
    sp.scaleY = this.heroScale;
    // 月光淡晕：phaseIndex 4（满月）最强，保留阶段氛围信号
    const moonK = clamp01(1 - Math.abs(phaseIndex - 4) / 4);
    dot(f, x, y + 44, 30, Palette.moonWhite, 0.05 + 0.08 * moonK);
    // 攻击剑光弧线（与程序化版同参数）
    if (pose === "attack1" || pose === "attack2" || pose === "attack3") {
      const idx = pose === "attack1" ? 0 : pose === "attack2" ? 1 : 2;
      const p = clamp01(t / ATTACK_TIME[idx]);
      const shX = x + facing * 4;
      const shY = y + 56 + bob;
      const a0 = facing > 0 ? -0.7 : Math.PI + 0.7;
      const a1 = a0 + facing * (0.6 + p * 1.9);
      arc(f, shX, shY, 54, a0, a1, 12, 2.4, Palette.white, 0.55 * (1 - p * 0.35));
      arc(f, shX, shY, 44, a0, a1, 10, 1.6, Palette.white, 0.32 * (1 - p));
    }
    // 受伤红闪
    if (pose === "hurt") {
      dot(f, x, y + 46, 26, ink(220, 70, 60, 160), 0.5);
    }
  }

  private heroPose(p: Player): HeroPose {
    if (p.onLadder) {
      return "ladder";
    }
    const a = p.anim;
    if (a === "wallslide") {
      return "cling";
    }
    if (a === "climb") {
      return "ladder";
    }
    if (a === "attack") {
      const idx = p.attackIndex;
      return idx <= 0 ? "attack1" : idx === 1 ? "attack2" : "attack3";
    }
    if (a === "land") {
      return "idle";
    }
    return a;
  }
}