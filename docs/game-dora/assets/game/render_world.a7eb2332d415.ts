// game/render_world.ts — 世界渲染器：视差水墨背景 + 世界层（地形/机关/角色）
// 分层：bgDraw（屏幕空间视差背景） <- worldRoot（世界坐标，随摄像机平移）
//       worldRoot 内：platformDraw（地形） -> propDraw（机关道具装饰） -> charDraw（角色动态）
import { Color, DrawNode, Label, Node, Rect, Sprite, TextAlign, Texture2D, TextureFilter, Vec2, View } from "Dora";
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
  Platform,
  PlateDef,
  PortalDef,
  PushStoneDef,
  RopeDef,
  StarNodeDef,
  StoryTriggerDef,
  SwordSlotDef,
  WindSigilDef,
} from "core/types";
import type { EnemySystem } from "game/enemies";
import type { MechanismSystem } from "game/mechanisms";
import type { Player } from "game/player";
import {
  arc,
  circle,
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
import { HeroFrameSet, HeroFrame, HERO_FRAMES_FACE_RIGHT } from "game/hero_frames";
import { NinjaLayer } from "game/ninja_render";
import { LightDecor } from "game/decor_light";
// 藏身点坐标唯一来源：game/stealth.ts HIDE_SPOTS。直连 import 无循环依赖
// （stealth.ts 对 render_world 无任何引用，对 game/enemies 仅 import type）。
import { HIDE_SPOTS } from "game/stealth";

// 冲刺残影（Shift 闪身）：克隆当前动作帧，淡青色调 0x9ad7e8（月光残留），
// 向后偏移数像素 + 快速淡出；与黑化沈砚的红 tint 区分
const GHOST_TINT_R = 154; // 0x9a
const GHOST_TINT_G = 215; // 0xd7
const GHOST_TINT_B = 232; // 0xe8
const GHOST_ALPHA = 0.7; // 用户定版：恢复原始浓度，不减淡
const GHOST_DUR = 0.3;
const GHOST_INTERVAL = 0.04;
const GHOST_OFFSET = 12;
const GHOST_MAX = 8;

interface HeroGhost {
  sp: Sprite.Type;
  t: number;
  dur: number;
}

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
  portals: PortalDef[];
  lanterns: LanternDef[];
  pushStones: PushStoneDef[];
  gates: GateDef[];
  storyTriggers: StoryTriggerDef[];
  movers: Platform[];
  // 剑槽（可选：缺省不画）
  swordSlots?: SwordSlotDef[];
  // 风息符文（F3）/ 星位（F5）：必填，data/tower 具名导出直传
  windSigils: WindSigilDef[];
  starNodes: StarNodeDef[];
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

// 场景像素道具定义：w×h 为等比缩放包围盒；fit 决定基准——"w" 按宽（草丛），
// "h" 按高（常规立地物件），"min" contain 取小（枯坑等需同时限制宽高的贴地件）。
interface ScenePropDef {
  path: string;
  x: number;
  y: number;
  w: number;
  h: number;
  fit: "w" | "h" | "min";
}

const CULL = 900;
// 相机放大倍率：>1 时世界整体放大（视野变小、人物变大）。UI/HUD/视差背景保持屏幕尺寸不变。
// 2026-10-27 深夜用户终审=1.0（「我要之前的版本」）：1.5 是旧版没有的额外放大层，把视野缩小了一圈。
// game.ts 相机夹取与 fx/npc/立绘同步均已改为引用本常量，调视野只改这里，勿再各处硬编码。
export const CAM_ZOOM = 1.0;
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
  // 所属层（FLOORS 下标）；-1 = 世界边界墙等全程可见结构（新任务③④）
  floor: number;
}

// 检查点旗贴图组：off 未激活静态帧 + on 激活循环帧（均为非空 Sprite）
interface FlagSpriteSet {
  off: Sprite.Type;
  on: Sprite.Type[];
}

const TILE = 64; // 128px 原始瓦片 × 0.5（整数降采样，Point 采样保持像素锐利）
const TILE_SETS = ["autumn", "autumn", "skyruins", "skyruins", "skyruins", "skyruins", "skyruins"]; // 1F 图纸：古镇街巷统一秋日泥土系（f0/f1 同包）；F2 起统一天空遗迹系（移除异风格贴图）
// 各带 floorTop 锚点（= data/tower 的 TOPS，下标一一对应：带 i = 第 i 层，背景纵向视差定位用）。
// BAND_SWITCH/bandOf 已废弃：背景带不随相机高度切换，由 setFloorScene 按当前层整块切换，
// 层间距 1280px 下任意相机位置只命中当前层一套素材，绝不混排、绝不见邻层。
const FLOOR_TOPS = [220, 1500, 2800, 4100, 5400, 6700, 8000];

// 场景隔离：每种瓦片风格只配自己的背景层，BG_LAYERS 顺序必须与 TILE_SETS 一一对应。
// 用户整改：F1/F3/F6 换专属素材背景（江畔古镇/黄昏塔外/月夜观星台），F0/F2/F5 维持原风格。
interface BgLayerDef {
  path: string;
  f: number;
  baseUp: number;
}

const BG_AUTUMN: BgLayerDef[] = [
  { path: "assets/bg/autumn_layer0.png", f: 0.12, baseUp: 0 },
  { path: "assets/bg/autumn_layer1.png", f: 0.26, baseUp: 0 },
];
const BG_SKYRUINS: BgLayerDef[] = [
  { path: "assets/bg/skyruins_layer0.png", f: 0.12, baseUp: 0 },
  { path: "assets/bg/skyruins_layer1.png", f: 0.26, baseUp: 0 },
];
// 1 古镇街巷：江畔古镇五层（天空→远云→近云→礁石→河岸地面），呼应渡口向东入镇
const BG_RIVERSIDE: BgLayerDef[] = [
  { path: "assets/bg/river_sky.png", f: 0.06, baseUp: 0 },
  { path: "assets/bg/river_clouds1.png", f: 0.12, baseUp: 0 },
  { path: "assets/bg/river_clouds2.png", f: 0.18, baseUp: 0 },
  { path: "assets/bg/river_rocks.png", f: 0.28, baseUp: 0 },
  { path: "assets/bg/river_ground.png", f: 0.36, baseUp: 0 },
];
// 3 塔外环廊：黄昏塔外六层（天空→远云→远山→近山→近云→树影），环廊外望暮色
const BG_TOWERSIDE: BgLayerDef[] = [
  { path: "assets/bg/dusk/sky.png", f: 0.05, baseUp: 0 },
  { path: "assets/bg/dusk/far_clouds.png", f: 0.1, baseUp: 0 },
  { path: "assets/bg/dusk/far_mountains.png", f: 0.16, baseUp: 0 },
  { path: "assets/bg/dusk/mountains.png", f: 0.24, baseUp: 0 },
  { path: "assets/bg/dusk/near_clouds.png", f: 0.3, baseUp: 0 },
  { path: "assets/bg/dusk/trees.png", f: 0.38, baseUp: 0 },
];
// 6 观星台：月夜三层（远月→中月→满月特写），观星主题点题
const BG_MOONNIGHT: BgLayerDef[] = [
  { path: "assets/bg/moon_far.png", f: 0.08, baseUp: 0 },
  { path: "assets/bg/moon_mid.png", f: 0.18, baseUp: 0 },
  { path: "assets/bg/moon_big.png", f: 0.3, baseUp: 0 },
];
const BG_LAYERS: BgLayerDef[][] = [
  BG_AUTUMN, // 0 河滩·渡口（autumn）
  BG_RIVERSIDE, // 1 古镇街巷（江畔古镇 river_* 五层）
  BG_SKYRUINS, // 2 悬空工坊（skyruins，与观星塔主线风格统一）
  BG_TOWERSIDE, // 3 塔外环廊（黄昏 dusk 六层）
  [], // 4 机关层：不用天空遗迹图，改程序化机械室内背景（drawMechBackdrop）
  BG_SKYRUINS, // 5 观星者之间（skyruins）
  BG_MOONNIGHT, // 6 观星台（月夜 moon_* 三层）
];


// 主题装饰白名单：按 TILE_SETS 风格键判定装饰贴图是否允许出现在本层。
// skyruins → magicstone/portal；autumn 无主题装饰件 → 任何主题装饰都不放，异风格件绝不出现。
// skyruins_portal 属全游戏统一的功能传送门样式，仅由 buildPortals（各层功能门）
// 使用，不经其他途径进入异风格层。（6 层终点星门装饰已按用户需求 2026-10-26 删除）
function styleAllowsDecor(style: string, path: string): boolean {
  if (style === "skyruins") {
    return path === "assets/tiles/skyruins_magicstone.png" || path === "assets/tiles/skyruins_portal.png";
  }
  return false;
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
  private portalLayer: Node.Type;
  private charDraw: DrawNode.Type;
  private camX: number;
  private camY: number;
  private vw: number;
  private vh: number;
  private stars: StarDot[];
  private gateParts: GatePart[];
  private bgSpriteRoot: Node.Type;
  private bgRecs: BgSpriteRec[] = [];
  // 新任务③④：层间渲染隔离——activeFloor 为当前活动层，静态贴图按所属层挂进
  // 每层一个的容器节点（floorHolderIn），setFloorScene 换层时整容器切换可见；
  // 层内既有的逐件 visible 逻辑（树谜题/机关点亮等）不受影响。
  private activeFloor = 0;
  private sceneFloorHolders: Node.Type[] = [];
  private decorFloorHolders: Node.Type[] = [];
  private propSpriteFloorHolders: Node.Type[] = [];
  private bgBands: BgBand[] = [];
  private tileGroups: TileGroup[] = [];
  private decorNode: Node.Type;
  // 交互提示气泡：门/NPC 头顶「按 E …」浮动提示（世界坐标，随相机移动）
  private promptNode: Node.Type;
  private promptDraw: DrawNode.Type;
  // 纯文字提示：promptW/H = 文字尺寸（用于镜头可视范围钳制）
  private promptW = 0;
  private promptH = 0;
  private promptText = "";
  private promptX = 0;
  private promptY = 0;
  // 纯文字提示动效状态（弹入/淡出/浮动）
  private promptShown = false;
  private promptPopT = 0;
  private promptHideT = 0;
  private promptAnimT = 0;
  private promptRelayoutT = 0; // 文本变更后短暂重排，等排版稳定
  // 文本节点：单标签双居中（显式 TextAlign.Center + 锚点居中原点）
  private promptLbMain: Label.Type | undefined;
  private heroSprite: Sprite.Type | undefined;
  private heroFxDraw: DrawNode.Type;
  private heroTexOk = false;
  private heroScale = 0.065;
  private heroFrames: HeroFrameSet;
  // 冲刺残影：淡青月光残留克隆帧，独立层（敌人之上、主角帧之下）
  private ghostRoot: Node.Type;
  private ghosts: HeroGhost[] = [];
  private ghostCd = 0;
  private ninjaRoot: Node.Type;
  private ninja: NinjaLayer;
  private lightDecor: LightDecor;
  private pixelBgOk = false;
  private activeBand = -1;
  private sceneBand = 0;
  private portalNodes: { node: Node.Type; floor: number; x: number; gateId?: string; fade: number }[] = [];
  // 机关道具贴图层：夹在 propDraw（程序化道具）与传送门/角色之间
  private propSpriteRoot: Node.Type;
  // 场景像素道具装饰层：地形之上、机关道具/传送门/角色之下（纯装饰，不参与碰撞/交互）
  private scenePropsRoot: Node.Type;
  private stoneSprites: Sprite.Type[] = [];
  // 头目剑气贴图精灵池（用户需求①：素材包 slash_blue）；waveSpriteRoot 排在 charDraw 之前 → 剑刃在角色之下
  private waveSpriteRoot: Node.Type;
  private bossWaveSprites: Sprite.Type[] = [];
  private bossWaveTex: Texture2D.Type | undefined;
  private bossWaveChecked = false;
  private lampStoneSprites: { [key: string]: Sprite.Type } = {};
  private moonStoneSprites: { [key: string]: Sprite.Type } = {};
  private dewSprites: { [key: string]: Sprite.Type } = {};
  private tokenSprites: { [key: string]: Sprite.Type } = {};
  private flagSets: { [key: string]: FlagSpriteSet | undefined } = {};
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
    // 场景像素道具装饰层：树/井/酒馆物件/草丛等，画在角色层之下（草丛供玩家站入）
    this.scenePropsRoot = Node();
    this.scenePropsRoot.addTo(this.worldRoot);
    // 机关道具贴图层：推石/点灯石/检查点旗等 Sprite 挂这里（在角色之下）
    this.propSpriteRoot = Node();
    this.propSpriteRoot.addTo(this.worldRoot);
    // 传送门层：夹在道具与角色之间——门贴图永远画在人物后面（修复门挡住人物）
    this.portalLayer = Node();
    this.portalLayer.addTo(this.worldRoot);
    this.waveSpriteRoot = Node();
    this.waveSpriteRoot.addTo(this.worldRoot);
    this.charDraw = DrawNode();
    this.charDraw.addTo(this.worldRoot);
    // 忍者敌人雪碧图层：独立节点，懒建 Sprite 保持在主角之下
    this.ninjaRoot = Node();
    this.ninjaRoot.addTo(this.worldRoot);
    this.ninja = new NinjaLayer(this.ninjaRoot);
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
    // 残影层：插在主角帧集之前 → 残影画在主角之下、敌人之上
    this.ghostRoot = Node();
    this.ghostRoot.addTo(this.worldRoot);
    this.heroFrames = new HeroFrameSet(this.worldRoot);
    this.heroFxDraw = DrawNode();
    this.heroFxDraw.addTo(this.worldRoot);
    this.decorNode = Node();
    this.decorNode.addTo(this.worldRoot);
    this.lightDecor = new LightDecor(this.decorNode);
    // 提示气泡层：世界层最顶层
    this.promptNode = Node();
    this.promptNode.addTo(this.worldRoot);
    this.promptNode.visible = false;
    this.promptDraw = DrawNode();
    this.promptDraw.addTo(this.promptNode);
    this.promptDraw.visible = true; // 矢量圆角提示框（旧 UI 设计）
    this.promptNode.passOpacity = true;
    // 气泡动效：浮动/弹入/淡出由提示层自身调度驱动（该节点无其他调度，占用安全）
    this.promptNode.schedule((dt: number) => {
      this.updatePromptAnim(dt);
      return false;
    });
    this.buildPixelBackgrounds();
    this.buildPixelTerrain();
    this.buildPixelDecor();
    this.buildSceneProps();
    this.buildPortals();
    this.buildLightDecor();
    this.buildPropSprites();
  }

  // 交互提示气泡：矢量圆角框（旧 UI 设计），文字在框内，键位字母金色。
  // 动效：±3px 浮动（2s 循环）、出现 0.9→1.0 弹入 0.15s、消失淡出 0.1s；text=undefined 触发淡出。
  setPrompt(x: number, y: number, text: string | undefined): void {
    if (text === undefined) {
      if (this.promptShown) {
        this.promptShown = false;
        this.promptHideT = 0.1;
      }
      return;
    }
    if (this.promptShown && text === this.promptText && x === this.promptX && y === this.promptY) {
      return; // 内容与位置未变，不重画
    }
    const fresh = !this.promptShown;
    this.promptText = text;
    this.promptX = x;
    this.promptY = y;
    if (fresh) {
      this.promptShown = true;
      this.promptPopT = 0.15;
      this.promptHideT = 0;
      this.promptAnimT = 0;
      this.promptNode.visible = true;
      this.promptNode.opacity = 1;
      this.promptNode.scaleX = 0.9;
      this.promptNode.scaleY = 0.9;
    }
    this.redrawPrompt();
    this.applyPromptPosition(0);
    this.promptRelayoutT = 0.12; // 之后几帧用真实 Label 宽度重排
  }

  // 锚点语义：promptX/Y = 交互物体右上角；纯文字：文字中心悬在交互点正上方约 14px，并钳制在镜头可视范围内
  private applyPromptPosition(bob: number): void {
    const w = this.promptW;
    const h = this.promptH;
    let px = this.promptX;
    let py = this.promptY + h / 2 + 14;
    const minX = this.camX - this.vw / (2 * CAM_ZOOM) + w / 2 + 8;
    const maxX = this.camX + this.vw / (2 * CAM_ZOOM) - w / 2 - 8;
    const minY = this.camY - this.vh / (2 * CAM_ZOOM) + h / 2 + 8;
    const maxY = this.camY + this.vh / (2 * CAM_ZOOM) - h / 2 - 8;
    if (maxX > minX) {
      px = Math.max(minX, Math.min(maxX, px));
    }
    if (maxY > minY) {
      py = Math.max(minY, Math.min(maxY, py));
    }
    this.promptNode.position = Vec2(px, py + bob);
  }

  // 气泡动效：由提示层自身 schedule 逐帧驱动
  private updatePromptAnim(dt: number): void {
    if (!this.promptNode.visible) {
      return;
    }
    if (this.promptShown) {
      if (this.promptRelayoutT > 0) {
        this.promptRelayoutT -= dt;
        this.redrawPrompt();
      }
      this.promptAnimT += dt;
      if (this.promptPopT > 0) {
        this.promptPopT = Math.max(0, this.promptPopT - dt);
        const t = 1 - this.promptPopT / 0.15;
        const e = 1 - (1 - t) * (1 - t); // easeOutQuad
        const s = 0.9 + 0.1 * e;
        this.promptNode.scaleX = s;
        this.promptNode.scaleY = s;
      } else {
        this.promptNode.scaleX = 1;
        this.promptNode.scaleY = 1;
      }
      const bob = 3 * Math.sin(Math.PI * this.promptAnimT); // 2s 周期
      this.applyPromptPosition(bob);
      this.promptNode.opacity = 1;
    } else {
      this.promptHideT -= dt;
      if (this.promptHideT <= 0) {
        this.promptHideT = 0;
        this.promptNode.visible = false;
        this.promptNode.opacity = 1;
      } else {
        this.promptNode.opacity = this.promptHideT / 0.1;
      }
    }
  }

  private makePromptLabel(size: number): Label.Type | undefined {
    const lb = Label("assets/font/DialogFont.ttf", size);
    if (lb !== undefined) {
      return lb;
    }
    return Label("sarasa-mono-sc-regular", size);
  }

  private redrawPrompt(): void {
    // 只留文字：无底框无尾巴；纯白 18px，单标签双居中，超 280 限宽自动换行
    const draw = this.promptDraw;
    draw.clear();
    draw.visible = false;
    if (this.promptLbMain === undefined) {
      this.promptLbMain = this.makePromptLabel(21);
      if (this.promptLbMain !== undefined) {
        this.promptLbMain.anchor = Vec2(0.5, 0.5);
        this.promptLbMain.color = Color(255, 255, 255, 255);
        this.promptLbMain.addTo(this.promptNode);
      }
    }
    const main = this.promptLbMain;
    if (main === undefined) {
      return;
    }
    // 单标签双居中：显式 TextAlign.Center + 锚点(0.5,0.5)；分段多标签方案已弃用（分段测量有口径差会累积偏移）
    main.visible = true;
    main.color = Color(255, 255, 255, 255);
    main.alignment = TextAlign.Center;
    main.text = this.promptText;
    main.width = Label.AutomaticWidth;
    main.position = Vec2(0, 0);
    let textW = main.width;
    let textH = main.height > 0 ? main.height : 24;
    const maxTextW = 280;
    if (textW + 2 > maxTextW) {
      const rows = Math.ceil((textW + 2) / maxTextW);
      main.width = maxTextW; // 限宽触发自动换行
      textW = maxTextW;
      textH = Math.max(main.height, textH * rows);
    }
    this.promptW = textW;
    this.promptH = textH;
  }

  // 光源道具（灯笼/火把）只在约定三层出现：塔外环廊(3)/机关层·墓园(4)/观星者之间(5)。
  // 灯笼挂这三层检查点上方；火把只守这三层传送门两侧，其余层一律不放，防止异风格光源扩散。
  private buildLightDecor(): void {
    // FLOOR_TOPS 用模块级常量（= Tower.TOPS），光源层白名单不变
    const lightFloors = [3, 4, 5];
    const lanternFloors = [
      { top: FLOOR_TOPS[3], cx: 1000 },
      { top: FLOOR_TOPS[4], cx: 1200 },
      { top: FLOOR_TOPS[5], cx: 1700 },
    ];
    const lanternSpots: { x: number; y: number }[] = [];
    for (const lf of lanternFloors) {
      lanternSpots.push({ x: lf.cx - 350, y: lf.top + 240 });
      lanternSpots.push({ x: lf.cx, y: lf.top + 240 });
      lanternSpots.push({ x: lf.cx + 350, y: lf.top + 240 });
    }
    this.lightDecor.addLanterns(lanternSpots);
    const torchSpots: { x: number; y: number }[] = [];
    for (const rec of this.portalNodes) {
      let sanctioned = false;
      for (const lf of lightFloors) {
        if (lf === rec.floor) {
          sanctioned = true;
          break;
        }
      }
      if (!sanctioned) {
        continue; // 0/1/2 层（autumn/skyruins/crystal）传送门旁不放火把
      }
      const top = rec.floor >= 0 && rec.floor < FLOOR_TOPS.length ? FLOOR_TOPS[rec.floor] : 220;
      torchSpots.push({ x: rec.x - 90, y: top });
      torchSpots.push({ x: rec.x + 90, y: top });
    }
    this.lightDecor.addTorches(torchSpots);
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
      const top = FLOOR_TOPS[band];
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
      this.tileGroups.push({ node: node, x0: p.x, y0: p.y, x1: p.x + p.w, y1: topY, floor: p.floor });
    }
    // 世界边界墙（wallL/wallR，w=80 不满足石台铺装门槛）：用本层主题 _fill 竖向铺满，
    // 替代矢量兜底的整根褐色木台巨柱（用户所指"防掉落装置"）。
    for (const p of this.data.platforms) {
      if (p.id !== "wallL" && p.id !== "wallR") {
        continue;
      }
      const fillTex = this.loadTex("assets/tiles/" + TILE_SETS[p.floor] + "_fill.png");
      if (fillTex === undefined) {
        continue;
      }
      const node = Node();
      node.addTo(this.worldRoot);
      const rows = Math.ceil(p.h / TILE);
      for (let r = 0; r < rows; r++) {
        const rh = r === rows - 1 ? (p.h - (rows - 1) * TILE) * 2 : 128;
        if (rh <= 0) {
          break;
        }
        this.tileSprite(node, fillTex, p.x, p.y + p.h - (r + 1) * TILE, 160, rh);
      }
      // floor:-1 = 世界边界墙竖铺任何层都可见（左右黑边封闭，防“看到下一层”的同时保证每层边缘完整）
      this.tileGroups.push({ node: node, x0: p.x, y0: p.y, x1: p.x + p.w, y1: p.y + p.h, floor: -1 });
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
      this.tileGroups.push({ node: node, x0: hz.x, y0: hz.y, x1: hz.x + hz.w, y1: hz.y + hz.h, floor: hz.floor });
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
      this.tileGroups.push({ node: node, x0: l.x, y0: l.y, x1: l.x + l.w, y1: l.y + l.h, floor: l.floor });
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
      this.tileGroups.push({ node: node, x0: p.x, y0: p.y, x1: p.x + p.w, y1: p.y + p.h, floor: p.floor });
    }
  }

  private buildPixelDecor(): void {
    // 硬编码主题装饰点：floor 标注所属层，y 一律取 FLOOR_TOPS[floor]（与 Tower.TOPS 一致），
    // 逐条再过 styleAllowsDecor 白名单（风格不符直接跳过）。已删：
    // skyruins_magicstone @ 第 5 层、graveyard 墓碑/提灯 @ 第 4 层 —— 不放异风格装饰（用户需求）。
    const decor: { path: string; floor: number; x: number; y: number }[] = [
      // 观星台终点星门装饰已删（用户需求 2026-10-26：观星台画面里不出现传送门）
      { path: "assets/tiles/skyruins_magicstone.png", floor: 3, x: 1300, y: FLOOR_TOPS[3] },
      // 布置落地：3F 环廊补魔石（西端 600 近 checkpoint/st5，东侧 1900 呼应风息符文 ws2）；
      // 6F 观星台补魔石（700 近 dw4 晨露台、1900 在 Boss 巡逻带中段作地标）
      { path: "assets/tiles/skyruins_magicstone.png", floor: 3, x: 600, y: FLOOR_TOPS[3] },
      { path: "assets/tiles/skyruins_magicstone.png", floor: 3, x: 1900, y: FLOOR_TOPS[3] },
      { path: "assets/tiles/skyruins_magicstone.png", floor: 6, x: 700, y: FLOOR_TOPS[6] },
      { path: "assets/tiles/skyruins_magicstone.png", floor: 6, x: 1900, y: FLOOR_TOPS[6] },
    ];
    for (const d of decor) {
      if (!styleAllowsDecor(TILE_SETS[d.floor], d.path)) {
        continue;
      }
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
      sp.addTo(this.floorHolderIn(this.decorNode, this.decorFloorHolders, d.floor));
    }
  }

  // 新到像素场景道具（源 .agent/新增素材001/新增素材/ → assets/props/ ASCII 名）：
  // 纯装饰，不改任何玩法逻辑。布局避让 data/tower.ts（只读口径）：
  // 检查点/传送门/剧情触发带 st0-7 各留 300px；第 1 层另避主角出生点
  // （渡口检查点 cp_riverbank x=800 的落点 ±300）。高分辨率原图按世界像素等比缩放，
  // 底边贴层地面顶（FLOOR_TOPS = Tower.TOPS），Point 采样保持像素锐利。
  // —— 整改二：种树谜题动态道具（苗@700 坑@1200 主树/对侧树/双树桩 + 攀树梯） ——
  // —— 整改一：酒桶摆件引用（推倒谜题需旋转/位移动画） ——
  private treeSapling: Sprite.Type | undefined;
  private treePit: Sprite.Type | undefined;
  private treeMain: Sprite.Type | undefined;
  private treeMirror: Sprite.Type | undefined;
  private stumpMain: Sprite.Type | undefined;
  private stumpMirror: Sprite.Type | undefined;
  private treeLadderDraw: DrawNode.Type | undefined;
  private barrelSp: Sprite.Type | undefined;
  private puzzleBuilt = false;
  private barrelT = 0; // 倒伏动画进度 0..1
  private barrelLeft = false;

  // 引用版场景道具：缺图静默返回 undefined（与 addSceneProp 同口径，玩法零依赖）
  private makePropSprite(path: string, x: number, y: number, boxW: number, boxH: number, fit: "w" | "h" | "min"): Sprite.Type | undefined {
    const tex = this.loadTex(path);
    if (tex === undefined) {
      return undefined;
    }
    const sp = Sprite(tex);
    if (sp === undefined) {
      return undefined;
    }
    const sW = boxW / tex.width;
    const sH = boxH / tex.height;
    const s = fit === "w" ? sW : fit === "h" ? sH : Math.min(sW, sH);
    sp.anchor = Vec2(0.5, 0);
    sp.scaleX = s;
    sp.scaleY = s;
    sp.filter = TextureFilter.Point;
    sp.position = Vec2(x, y);
    sp.addTo(this.floorHolderIn(this.scenePropsRoot, this.sceneFloorHolders, this.floorOfY(y)));
    return sp;
  }

  private ensurePuzzleProps(): void {
    if (this.puzzleBuilt) {
      return;
    }
    this.puzzleBuilt = true;
    this.treeSapling = this.makePropSprite("assets/props/a2_sapling.png", 700, FLOOR_TOPS[0], 150, 120, "min");
    this.treePit = this.makePropSprite("assets/props/a1_pit.png", 1200, FLOOR_TOPS[0], 150, 26, "min");
    // 主树：种在枯坑上的成树（树冠月石 ms4 的载体）；对侧树：因果闪现在树苗原位的月影之树
    this.treeMain = this.makePropSprite("assets/props/a3_tree.png", 1200, FLOOR_TOPS[0], 260, 200, "min");
    this.treeMirror = this.makePropSprite("assets/props/a3_tree.png", 700, FLOOR_TOPS[0], 210, 162, "min");
    this.stumpMain = this.makePropSprite("assets/props/a4_stump.png", 1200, FLOOR_TOPS[0], 110, 80, "min");
    this.stumpMirror = this.makePropSprite("assets/props/a4_stump.png", 700, FLOOR_TOPS[0], 110, 80, "min");
    this.barrelSp = this.makePropSprite("assets/props/b6_barrel.png", 1900, FLOOR_TOPS[1], 92, 84, "min");
    const ladder = DrawNode();
    ladder.addTo(this.scenePropsRoot);
    // 攀树梯（与 game.TREE_LADDER 判定一致：x=1180，顶到树冠平台）
    const rail = Color(122, 88, 58, 255);
    const rung = Color(150, 112, 74, 255);
    ladder.drawSegment(Vec2(1160, FLOOR_TOPS[0]), Vec2(1160, FLOOR_TOPS[0] + 560), 4, rail);
    ladder.drawSegment(Vec2(1200, FLOOR_TOPS[0]), Vec2(1200, FLOOR_TOPS[0] + 560), 4, rail);
    for (let y = FLOOR_TOPS[0] + 40; y <= FLOOR_TOPS[0] + 540; y += 56) {
      ladder.drawSegment(Vec2(1160, y), Vec2(1200, y), 3, rung);
    }
    ladder.visible = false;
    this.treeLadderDraw = ladder;
  }

  private setVisible(sp: Sprite.Type | undefined, on: boolean): void {
    if (sp !== undefined) {
      sp.visible = on;
    }
  }

  // 每帧由 Game.updateVisuals 调用：按 flags 同步树谜题各阶段可见性
  syncTreePuzzle(flags: Record<string, boolean>): void {
    this.ensurePuzzleProps();
    const planted = flags["treePlanted"] === true;
    const cut = flags["treeCut"] === true;
    const taken = flags["saplingTaken"] === true;
    this.setVisible(this.treeSapling, !planted && !cut && !taken);
    this.setVisible(this.treePit, !planted);
    this.setVisible(this.treeMain, planted && !cut);
    this.setVisible(this.treeMirror, planted && !cut);
    this.setVisible(this.stumpMain, cut);
    this.setVisible(this.stumpMirror, cut);
    if (this.treeLadderDraw !== undefined) {
      this.treeLadderDraw.visible = planted && !cut && this.activeFloor === 0;
    }
  }

  // 整改一：酒桶推倒（down=false 直立复位；down=true 朝 left 方向倒下，0.35s 缓动）
  syncBarrel(dt: number, down: boolean, left: boolean): void {
    this.ensurePuzzleProps();
    if (this.barrelSp === undefined) {
      return;
    }
    if (!down) {
      this.barrelT = 0;
      this.barrelSp.angle = 0;
      this.barrelSp.position = Vec2(1900, FLOOR_TOPS[1]);
      return;
    }
    if (this.barrelLeft !== left) {
      this.barrelLeft = left;
      this.barrelT = 0;
    }
    if (this.barrelT < 1) {
      this.barrelT = Math.min(1, this.barrelT + dt * 3);
      const e = 1 - (1 - this.barrelT) * (1 - this.barrelT); // easeOut
      this.barrelSp.angle = (left ? -1 : 1) * 90 * e;
      this.barrelSp.position = Vec2(1900 + (left ? -1 : 1) * 40 * e, FLOOR_TOPS[1] + 6 * e);
    }
  }

  // 整改三：潜行系统需要挂进世界根（锥形视野随相机移动）
  getWorldRoot(): Node.Type {
    return this.worldRoot;
  }

  private buildSceneProps(): void {
    const defs: ScenePropDef[] = [
      // 第 1 层 河滩·渡口（地面顶 y=220；A 组全部在此）
      { path: "assets/props/a3_tree.png", x: 2000, y: FLOOR_TOPS[0], w: 340, h: 220, fit: "min" }, // 大树≈220 高
      { path: "assets/props/a5_well.png", x: 860, y: FLOOR_TOPS[0], w: 150, h: 110, fit: "min" }, // 水井≈110（树谜题井位）
      // 树苗@700 移入动态管理（ensurePuzzleProps）：整改二种树谜题需按 flags 切换可见性
      { path: "assets/props/a4_stump.png", x: 1550, y: FLOOR_TOPS[0], w: 110, h: 80, fit: "min" }, // 树桩≈80
      { path: "assets/props/a6_bucket.png", x: 1650, y: FLOOR_TOPS[0], w: 56, h: 42, fit: "min" }, // 木水桶
      // 枯坑@1200 移入动态管理（ensurePuzzleProps）：整改二种树谜题需按 flags 切换可见性
      // 1F 图纸场景装饰：街口灯笼（原“石座装饰”引用的 assets/props/push_stone.png 不存在，
      // 且与 mechanisms 推石贴图同源易误导玩家去推，已移除；机关石本体由 mechanisms 渲染）
      { path: "assets/decor/lantern_1.png", x: 980, y: FLOOR_TOPS[1], w: 42, h: 74, fit: "h" }, // 入口街灯
      { path: "assets/decor/lantern_1.png", x: 2150, y: FLOOR_TOPS[1], w: 42, h: 74, fit: "h" }, // 门后街灯（守传送门前）
      // 第 2 层 古镇街巷（地面顶 y=1500）：西街骰子/方桌避出生点 160±300；
      // 酒馆角集中 1700-2000（柜台 1755/酒桶@1900 动态/店小二 1985）；
      // 藏身草丛走 stealth HIDE_SPOTS（700/1430/2180），为藏身点本体不避让
      { path: "assets/props/e2_dice.png", x: 490, y: FLOOR_TOPS[1], w: 34, h: 30, fit: "min" }, // 骰子
      { path: "assets/props/b7_table.png", x: 550, y: FLOOR_TOPS[1], w: 190, h: 78, fit: "min" }, // 方桌长凳
      { path: "assets/props/e6_offering.png", x: 1020, y: FLOOR_TOPS[1], w: 52, h: 36, fit: "min" }, // 供品盘
      { path: "assets/props/b5_counter.png", x: 1755, y: FLOOR_TOPS[1], w: 160, h: 110, fit: "min" }, // 酒馆柜台≈110
      // 大酒桶@1900 移入动态管理（ensurePuzzleProps）：整改一酒桶推倒谜题需持有引用做倒伏动画
      // 整改①·布置落地：0F 渡口滩涂芦苇（st0/st1/树谜题区/检查点避让后的空档 1360/1690）
      { path: "assets/props/withered_reed.png", x: 1360, y: FLOOR_TOPS[0], w: 64, h: 78, fit: "w" }, // 东岸芦苇（e00 巡逻带下，纯装饰）
      { path: "assets/props/withered_reed.png", x: 1690, y: FLOOR_TOPS[0], w: 56, h: 70, fit: "w" }, // 缓冲带芦苇（e00/e01 之间空档）
      // 整改①·布置落地：2F 悬空工坊家具（工坊主题沿用 B 组木器；井边 660/门后 1980、桌 1750，避检查点 160±300）
      { path: "assets/props/b6_barrel.png", x: 660, y: FLOOR_TOPS[2], w: 92, h: 84, fit: "min" }, // 工坊货桶①（lt0 灯下西侧）
      { path: "assets/props/b7_table.png", x: 1750, y: FLOOR_TOPS[2], w: 190, h: 78, fit: "min" }, // 工作台（灯区东侧）
      { path: "assets/props/b6_barrel.png", x: 1980, y: FLOOR_TOPS[2], w: 92, h: 84, fit: "min" }, // 工坊货桶②（星门后传送门前）
      // 整改①·布置落地：5F 星野芦苇（e50 巡逻带右 480；1250 处为藏身草丛由 HIDE_SPOTS 自动画）
      { path: "assets/props/withered_reed.png", x: 480, y: FLOOR_TOPS[5], w: 60, h: 74, fit: "w" },
      // 药草/灵芝/人参/月华碎片：用户整改——观星者之间（F5）最右侧杂物清空，
      // 药材三件移到 1F 古镇街巷空档（1150/1310/1650，避藏身草丛 700/1430/2180、街灯与 tk1 旧物@1250），
      // 月华碎片移到观星台（F6）呼应观星主题。
      { path: "assets/props/e5_herb.png", x: 1150, y: FLOOR_TOPS[1], w: 36, h: 30, fit: "min" }, // 紫色药草（1150：避开 tk1 旧物@1250，拾取后旧物位不留残影道具）
      { path: "assets/props/e3_lingzhi.png", x: 1310, y: FLOOR_TOPS[1], w: 44, h: 36, fit: "min" }, // 灵芝
      { path: "assets/props/e4_ginseng.png", x: 1650, y: FLOOR_TOPS[1], w: 40, h: 34, fit: "min" }, // 人参
      // E7 月华碎片：core/types.CollectibleDef 仅 moonstone/mechanism/token/dew/lampstone
      // 五种 kind，收集品绘制分支（drawCollectibles）无月华碎片项 → 按规格作为静态
      // 装饰，不动收集品逻辑。
      { path: "assets/props/e7_shard.png", x: 980, y: FLOOR_TOPS[6], w: 46, h: 40, fit: "min" },
    ];
    for (const d of defs) {
      this.addSceneProp(d.path, d.x, d.y, d.w, d.h, d.fit);
    }
    // 藏身草丛：坐标来源 game/stealth.ts HIDE_SPOTS（古镇层 4 点）。HIDE_SPOTS.y 是
    // 站立身体中心（地面顶+34），渲染底边贴地面顶。灌木+枯苇双层叠画增茂密感；
    // 场景道具层在角色层之下，玩家可站入草丛区域。
    for (const hs of HIDE_SPOTS) {
      const top = hs.floor >= 0 && hs.floor < FLOOR_TOPS.length ? FLOOR_TOPS[hs.floor] : FLOOR_TOPS[1];
      this.addSceneProp("assets/props/b1_bush.png", hs.x, top, 104, 64, "w"); // 灌木宽≈104
      this.addSceneProp("assets/props/withered_reed.png", hs.x, top, 96, 72, "w"); // 枯苇宽≈96
    }
  }

  // 场景道具落图：等比缩放 + 底边贴地 + 水平居中；贴图缺失静默跳过（纯装饰零依赖）
  private addSceneProp(path: string, x: number, y: number, boxW: number, boxH: number, fit: "w" | "h" | "min"): void {
    const tex = this.loadTex(path);
    if (tex === undefined) {
      return;
    }
    const sp = Sprite(tex);
    if (sp === undefined) {
      return;
    }
    const sW = boxW / tex.width;
    const sH = boxH / tex.height;
    const s = fit === "w" ? sW : fit === "h" ? sH : Math.min(sW, sH);
    sp.anchor = Vec2(0.5, 0);
    sp.scaleX = s;
    sp.scaleY = s;
    sp.filter = TextureFilter.Point;
    sp.position = Vec2(x, y);
    sp.addTo(this.floorHolderIn(this.scenePropsRoot, this.sceneFloorHolders, this.floorOfY(y)));
  }

  setCamera(camX: number, camY: number, shakeX: number, shakeY: number): void {
    this.camX = camX;
    this.camY = camY;
    const vw = View.size.width;
    const vh = View.size.height;
    this.vw = vw;
    this.vh = vh;
    // Dora 屏幕中心原点：世界坐标直接减相机。此前误用左上角原点写法 +vw/2 +vh/2，
    // 导致整个世界右移半屏、上移半屏——人物钉死右缘、画面内容挤在右上角、左下露出地图外虚空。
    // 相机放大：worldRoot 整体放大 CAM_ZOOM 倍，平移量同步乘 zoom 使相机点保持在屏幕中心。
    this.worldRoot.scaleX = CAM_ZOOM;
    this.worldRoot.scaleY = CAM_ZOOM;
    this.worldRoot.position = Vec2(-camX * CAM_ZOOM + shakeX, -camY * CAM_ZOOM + shakeY);
    this.updatePixelBackdrop(camX, camY, vw, vh);
    for (const g of this.tileGroups) {
      // 新任务④：瓦片只渲染本层（floor<0 = 世界边界墙，任何层都保持可见）
      g.node.visible = (g.floor < 0 || g.floor === this.activeFloor) && this.inView(g.x0, g.y0 - 40, g.x1, g.y1 + 40);
    }
  }

  // 场景切换：传送/检查点激活换层时整块切换背景带（不再按相机高度渐变）
  setFloorScene(floor: number): void {
    this.sceneBand = Math.max(0, Math.min(BG_LAYERS.length - 1, Math.floor(floor)));
    // 新任务③④：换层时本层静态件（场景道具/主题装饰/机关贴图）整容器切换可见，
    // 相机在任何高度都不会露出邻层的建筑与物件。
    this.activeFloor = this.sceneBand;
    this.applyFloorHolders(this.sceneFloorHolders);
    this.applyFloorHolders(this.decorFloorHolders);
    this.applyFloorHolders(this.propSpriteFloorHolders);
  }

  private applyFloorHolders(holders: Node.Type[]): void {
    for (let i = 0; i < holders.length; i++) {
      holders[i].visible = i === this.activeFloor;
    }
  }

  // 取（必要时补建）root 下第 floor 层的静态件容器
  private floorHolderIn(root: Node.Type, holders: Node.Type[], floor: number): Node.Type {
    while (holders.length <= floor) {
      const n = Node();
      n.addTo(root);
      n.visible = holders.length === this.activeFloor;
      holders.push(n);
    }
    return holders[floor];
  }

  // 由 y 推所属层（FLOOR_TOPS[f] ≤ y 的最大 f）；矢量兜底绘制与无 floor 字段的
  // 静态件按落点层门控，杜绝跨层渗漏
  private floorOfY(y: number): number {
    let f = 0;
    for (let i = FLOOR_TOPS.length - 1; i >= 0; i--) {
      if (y >= FLOOR_TOPS[i]) {
        f = i;
        break;
      }
    }
    return f;
  }

  // 传送门节点：门贴图立在层尽头，玩家行至门左侧 350px 内才显现
  private buildPortals(): void {
    const list = this.data.portals;
    for (let i = 0; i < list.length; i++) {
      const p = list[i];
      const holder = Node();
      holder.addTo(this.portalLayer);
      holder.visible = false;
      const tex = this.loadTex("assets/tiles/skyruins_portal.png");
      if (tex !== undefined) {
        const s = 130 / tex.height;
        const sp = Sprite(tex);
        sp.anchor = Vec2(0.5, 0);
        sp.scaleX = s;
        sp.scaleY = s;
        sp.filter = TextureFilter.Point;
        sp.position = Vec2(p.x, p.y);
        sp.addTo(holder);
      } else {
        const d = DrawNode();
        d.addTo(holder);
        d.drawPolygon([
          Vec2(p.x - 26, p.y),
          Vec2(p.x + 26, p.y),
          Vec2(p.x + 26, p.y + 86),
          Vec2(p.x, p.y + 118),
          Vec2(p.x - 26, p.y + 86),
        ], Color(120, 200, 255, 200));
      }
      this.portalNodes.push({ node: holder, floor: p.floor, x: p.x, gateId: p.gateId, fade: 0 });
    }
  }

  // 机关道具贴图：推石/点灯石/检查点旗（Texture2D 判空，缺失回退现有程序化画法）
  private buildPropSprites(): void {
    // 推石：逻辑 56×44（StoneBody w/h），中心对齐石中心；坐标只信 mechanisms 每帧写入值
    const stoneTex = this.loadTex("assets/tiles/push_stone.png");
    if (stoneTex !== undefined) {
      const sx = 56 / stoneTex.width;
      const sy = 44 / stoneTex.height;
      for (const def of this.data.pushStones) {
        const sp = Sprite(stoneTex);
        if (sp === undefined) {
          continue;
        }
        sp.anchor = Vec2(0.5, 0.5);
        sp.scaleX = sx;
        sp.scaleY = sy;
        sp.position = Vec2(def.x, def.y + 22);
        sp.visible = false;
        sp.addTo(this.floorHolderIn(this.propSpriteRoot, this.propSpriteFloorHolders, this.floorOfY(def.y + 22)));
        this.stoneSprites.push(sp);
      }
    }
    // 点灯石收集品：逻辑高≈36px，运行时加轻微上下浮动（表现层动画）
    const lampTex = this.loadTex("assets/tiles/lamp_stone.png");
    if (lampTex !== undefined) {
      const s = 36 / lampTex.height;
      for (const c of this.data.collectibles) {
        if (c.kind !== "lampstone") {
          continue;
        }
        const sp = Sprite(lampTex);
        if (sp === undefined) {
          continue;
        }
        sp.anchor = Vec2(0.5, 0.5);
        sp.scaleX = s;
        sp.scaleY = s;
        sp.position = Vec2(c.x, c.y + 18);
        sp.visible = false;
        sp.addTo(this.floorHolderIn(this.propSpriteRoot, this.propSpriteFloorHolders, this.floorOfY(c.y)));
        this.lampStoneSprites[c.id] = sp;
      }
    }
    // 月石收集品：与点灯石同一套用户素材（assets/tiles/moon_stone.png），逻辑高≈36px，随波浮动；缺失回退程序化月点
    const moonTex = this.loadTex("assets/tiles/moon_stone.png");
    if (moonTex !== undefined) {
      const msc = 36 / moonTex.height;
      for (const c of this.data.collectibles) {
        if (c.kind !== "moonstone") {
          continue;
        }
        const sp = Sprite(moonTex);
        if (sp === undefined) {
          continue;
        }
        sp.anchor = Vec2(0.5, 0.5);
        sp.scaleX = msc;
        sp.scaleY = msc;
        sp.position = Vec2(c.x, c.y + 18);
        sp.visible = false;
        sp.addTo(this.floorHolderIn(this.propSpriteRoot, this.propSpriteFloorHolders, this.floorOfY(c.y)));
        this.moonStoneSprites[c.id] = sp;
      }
    }
    // 晨露（血包）收集品：用户素材 .agent/血包.png，逻辑高≈36px 随波浮动；缺失回退程序化露珠
    const dewTex = this.loadTex("assets/props/blood_dew.png"); // 导出包内有效路径（原 .agent/血包.png 不进导出包）
    if (dewTex !== undefined) {
      print("[DewSprite] loaded assets/props/blood_dew.png (" + dewTex.width + "x" + dewTex.height + ")");
      const dc = 36 / dewTex.height;
      for (const c of this.data.collectibles) {
        if (c.kind !== "dew") {
          continue;
        }
        const sp = Sprite(dewTex);
        if (sp === undefined) {
          continue;
        }
        sp.anchor = Vec2(0.5, 0.5);
        sp.scaleX = dc;
        sp.scaleY = dc;
        sp.position = Vec2(c.x, c.y + 18);
        sp.visible = false;
        sp.addTo(this.floorHolderIn(this.propSpriteRoot, this.propSpriteFloorHolders, this.floorOfY(c.y)));
        this.dewSprites[c.id] = sp;
      }
    }
    // 旧物收集品（tk0-tk5）：改用引月札同款蓝色月华碎片 assets/props/e7_shard.png，
    // 逻辑高≈36px 随波浮动；缺失回退原程序化纸牌画法（2026-10-26 用户需求）
    const tokenTex = this.loadTex("assets/props/e7_shard.png");
    if (tokenTex !== undefined) {
      const tsc = 36 / tokenTex.height;
      for (const c of this.data.collectibles) {
        if (c.kind !== "token") {
          continue;
        }
        const sp = Sprite(tokenTex);
        if (sp === undefined) {
          continue;
        }
        sp.anchor = Vec2(0.5, 0.5);
        sp.scaleX = tsc;
        sp.scaleY = tsc;
        sp.position = Vec2(c.x, c.y + 18);
        sp.visible = false;
        sp.addTo(this.floorHolderIn(this.propSpriteRoot, this.propSpriteFloorHolders, this.floorOfY(c.y)));
        this.tokenSprites[c.id] = sp;
      }
    }
    // 检查点旗：off 静态 + on 四帧循环（≈8fps，time 驱动帧索引），逻辑高≈90px 底边对齐地面
    const offTex = this.loadTex("assets/ui/flag/checkpoint_off.png");
    for (const cp of this.data.checkpoints) {
      if (cp.id === "cp_riverbank") {
        continue; // 出生点旗已按需求移除，不建贴图
      }
      const onFrames: Sprite.Type[] = [];
      for (let fi = 0; fi < 4; fi++) {
        const tex = this.loadTex("assets/ui/flag/checkpoint_on_" + fi + ".png");
        if (tex === undefined) {
          continue;
        }
        const sp = Sprite(tex);
        if (sp === undefined) {
          continue;
        }
        this.setupFlagSprite(sp, tex.height, cp.x, cp.y, this.floorOfY(cp.y));
        onFrames.push(sp);
      }
      if (offTex !== undefined && onFrames.length > 0) {
        const spOff = Sprite(offTex);
        if (spOff !== undefined) {
          this.setupFlagSprite(spOff, offTex.height, cp.x, cp.y, this.floorOfY(cp.y));
          this.flagSets[cp.id] = { off: spOff, on: onFrames };
        }
      }
    }
  }

  private setupFlagSprite(sp: Sprite.Type, texH: number, x: number, y: number, floor: number): void {
    const s = 90 / texH;
    sp.anchor = Vec2(0.5, 0);
    sp.scaleX = s;
    sp.scaleY = s;
    sp.filter = TextureFilter.Point;
    sp.position = Vec2(x, y);
    sp.visible = false;
    sp.addTo(this.floorHolderIn(this.propSpriteRoot, this.propSpriteFloorHolders, floor));
  }

  private updatePortals(player: Player, state: LoopState, dt: number): void {
    for (let i = 0; i < this.portalNodes.length; i++) {
      const rec = this.portalNodes[i];
      // 传送门 gating：本层通关门（gateId）未开前传送门尚未产生——不渲染。
      // 用户反馈：开门后门不应远处常驻——改为双向近距（280px）才显形，淡入淡出过渡
      const unlocked = rec.gateId === undefined || state.openedGates[rec.gateId] === true;
      const want = unlocked && rec.floor === this.sceneBand && Math.abs(player.body.x - rec.x) < 280;
      rec.fade += ((want ? 1 : 0) - rec.fade) * Math.min(1, dt * 8);
      if (rec.fade < 0.005) {
        rec.fade = 0;
      }
      rec.node.visible = rec.fade > 0.02;
      rec.node.opacity = rec.fade;
    }
  }

  // 像素视差：横向环绕 + 纵向随层顶对齐，按摄像机所在层带切换
  private updatePixelBackdrop(camX: number, camY: number, vw: number, vh: number): void {
    if (!this.pixelBgOk) {
      return;
    }
    const band = Math.max(0, Math.min(this.bgBands.length - 1, this.sceneBand));
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
    // 相机放大后世界视野 = 屏幕视野 / zoom
    const hw = this.vw / (2 * CAM_ZOOM);
    return x1 >= this.camX - hw - CULL && x0 <= this.camX + hw + CULL;
  }

  private inViewY(y0: number, y1: number): boolean {
    const hh = this.vh / (2 * CAM_ZOOM);
    return y1 >= this.camY - hh - CULL && y0 <= this.camY + hh + CULL;
  }

  private inView(x0: number, y0: number, x1: number, y1: number): boolean {
    return this.inViewX(x0, x1) && this.inViewY(y0, y1);
  }

  update(dt: number, state: LoopState, player: Player, enemies: EnemySystem, mech: MechanismSystem, time: number): void {
    this.lightDecor.update(time, dt);
    this.updatePortals(player, state, dt);
    this.drawBackground(time);
    this.drawTerrain(time);
    this.drawProps(time, state);
    this.drawChars(time, state, player, enemies, mech, dt);
  }

  // 背景层：宣纸底 + 星点 + 三重山脊 + 宝塔剪影 + 雾带 + 底部水纹（全部屏幕空间）
  private drawBackground(time: number): void {
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
    // 远星（极低视差，随摄像机横向缓移并环绕）；机关层为塔内机械空间，不放星星
    const span = vw + 80;
    const starsOn = this.sceneBand !== 4;
    for (let i = 0; starsOn && i < this.stars.length; i++) {
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
    // 月亮已按用户要求整体移除：原白月盘+月相遮挡黑盘在右上角挡背景（phaseIndex=4 时黑白两圆并排最明显）；天空保留星点
    // 机关层专属：塔内机械室背景（齿轮/立柱/管道/吊链/机关辉光），替代天空遗迹图
    if (this.pixelBgOk && this.sceneBand === 4) {
      this.drawMechBackdrop(time);
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

  // 机关层程序化背景：深色青铜机械室内——远景巨齿轮剪影与承重立柱、中景管道与吊链、
  // 近景咬合齿轮组与青色机关辉光；全部屏幕空间 + 横向环绕视差，层顶锚定轻纵向视差。
  private drawMechBackdrop(time: number): void {
    const d = this.bgDraw;
    const vw = this.vw;
    const vh = this.vh;
    const x0 = -vw / 2;
    const y0 = -vh / 2;
    // 室内基调：深色暖墨底（替代天空）
    d.drawPolygon(
      [Vec2(x0 - 4, y0 - 4), Vec2(x0 + vw + 8, y0 - 4), Vec2(x0 + vw + 8, y0 + vh + 8), Vec2(x0 - 4, y0 + vh + 8)],
      col(ink(30, 26, 22, 255)),
      0,
      Color(0, 0, 0, 0)
    );
    const yShift = -(this.camY - FLOOR_TOPS[4]) * 0.06;
    const mod = (x: number, m: number): number => {
      const r = x % m;
      return r < 0 ? r + m : r;
    };
    const glowCyan = ink(168, 197, 188, 255);
    // 远景（视差 0.1）：巨型齿轮剪影半嵌墙内 + 承重立柱
    const spanFar = 1500;
    const offFar = mod(this.camX * 0.1, spanFar);
    for (let i = 0; i < 3; i++) {
      const wx = mod(i * 520 + 240 - offFar, spanFar) - 200;
      const gx = wx - vw / 2;
      if (gx < -260 || gx > vw / 2 + 260) {
        continue;
      }
      const gy = y0 + 210 + yShift * 0.5;
      const dir = i === 1 ? -1 : 1;
      this.drawGearShape(d, gx, gy, 190 - i * 24, 12, time * (0.12 + i * 0.04) * dir, ink(50, 42, 33, 235), ink(40, 33, 26, 235));
    }
    for (let i = 0; i < 4; i++) {
      const wx = mod(i * 430 + 90 - offFar, spanFar) - 200;
      const cx = wx - vw / 2;
      if (cx < -60 || cx > vw / 2 + 60) {
        continue;
      }
      d.drawPolygon(
        [Vec2(cx - 22, y0 - 4), Vec2(cx + 22, y0 - 4), Vec2(cx + 16, y0 + vh + 8), Vec2(cx - 16, y0 + vh + 8)],
        col(ink(42, 36, 29, 220)),
        0,
        Color(0, 0, 0, 0)
      );
      seg(d, cx - 19, y0 + 40, cx - 19, y0 + vh - 20, 2, ink(34, 29, 24, 160));
    }
    // 中景（视差 0.26）：管道排线 + 吊链 + 青色脉动机关辉光
    const spanMid = 1200;
    const offMid = mod(this.camX * 0.26, spanMid);
    const pipeYs = [y0 + vh * 0.72, y0 + vh * 0.5, y0 + vh * 0.3];
    for (let pi = 0; pi < pipeYs.length; pi++) {
      const py = pipeYs[pi] + yShift;
      seg(d, x0 - 20, py, x0 + vw + 20, py, 10 - pi * 2, ink(60, 50, 38, 235));
      for (let jx = -((offMid + 60) % 150); jx < vw + 20; jx += 150) {
        circle(d, x0 + jx, py, 7 - pi, ink(72, 60, 45, 235), 5);
      }
      for (let jx = -((offMid + 105) % 300); jx < vw; jx += 300) {
        dot(d, x0 + jx, py + 12, 3.2, glowCyan, 0.3 + 0.22 * Math.sin(time * 2.4 + pi * 1.9 + jx));
      }
    }
    // 吊链：顶端垂下，末端微摆
    for (let i = 0; i < 5; i++) {
      const wx = mod(i * 260 + 130 - offMid, spanMid) - 150;
      const cx = wx - vw / 2;
      if (cx < -40 || cx > vw / 2 + 40) {
        continue;
      }
      const sway = Math.sin(time * 0.7 + i * 1.3) * 6;
      const topY = y0 + vh + 8;
      const botY = y0 + 120 + yShift + (i % 2) * 46;
      seg(d, cx, topY, cx + sway, botY, 2.4, ink(70, 59, 45, 220));
      for (let k = 1; k < 7; k++) {
        const t = k / 7;
        dot(d, cx + sway * t, topY + (botY - topY) * t, 3.4, ink(80, 68, 52, 220), 0.9);
      }
      circle(d, cx + sway, botY - 8, 9, ink(76, 63, 48, 235), 6);
    }
    // 近景（视差 0.4）：两只咬合转轮 + 青光轴心
    const spanNear = 900;
    const offNear = mod(this.camX * 0.4, spanNear);
    for (let i = 0; i < 2; i++) {
      const wx = mod(i * 470 + 300 - offNear, spanNear) - 150;
      const gx = wx - vw / 2;
      if (gx < -140 || gx > vw / 2 + 140) {
        continue;
      }
      const gy = y0 + 150 + yShift * 1.4;
      const dir = i === 0 ? 1 : -1;
      this.drawGearShape(d, gx, gy, 74, 9, time * 0.5 * dir, ink(66, 55, 42, 240), ink(52, 43, 33, 240));
      dot(d, gx, gy, 5, glowCyan, 0.5 + 0.3 * Math.sin(time * 3 + i));
      this.drawGearShape(d, gx + 96, gy + 26, 40, 7, -time * 0.5 * dir * (74 / 40), ink(60, 50, 38, 235), ink(48, 40, 31, 235));
    }
  }

  // 齿轮剪影：多边形齿圈 + 轮毂环 + 四辐条（angle 驱动旋转）
  private drawGearShape(d: DrawNode.Type, cx: number, cy: number, r: number, teeth: number, angle: number, body: Color.Type, hub: Color.Type): void {
    const verts: Vec2.Type[] = [];
    const n = teeth * 2;
    for (let i = 0; i < n; i++) {
      const rr = i % 2 === 0 ? r : r * 0.8;
      const a = angle + (i / n) * Math.PI * 2;
      verts.push(Vec2(cx + Math.cos(a) * rr, cy + Math.sin(a) * rr));
    }
    d.drawPolygon(verts, col(body), 0, Color(0, 0, 0, 0));
    circle(d, cx, cy, r * 0.34, hub, 5);
    for (let i = 0; i < 4; i++) {
      const a = angle + i * Math.PI * 0.5 + Math.PI * 0.25;
      const c = Math.cos(a);
      const s = Math.sin(a);
      seg(d, cx + c * r * 0.3, cy + s * r * 0.3, cx + c * r * 0.78, cy + s * r * 0.78, 4, body);
    }
  }

  private drawPagoda(time: number): void {
    const d = this.bgDraw;
    const vw = this.vw;
    const baseX = 1500 - this.camX * 0.7;
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
      // 新任务④：矢量兑底只画本层（按顶边所属层判定，像素瓦片为主渲染）
      if (this.floorOfY(p.y + p.h) !== this.activeFloor) {
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
      if (l.floor !== this.activeFloor) {
        continue;
      }
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
      if (this.floorOfY(cw.y + cw.h) !== this.activeFloor) {
        continue;
      }
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
    // 渲染直接使用逻辑位置（game.updateMovers 每帧写入 p.x/p.y）：
    // 旧实现在此用 sin 公式重算位置，与逻辑侧的 cos 公式相位差 π/2
    // （period 7.5s 时约 1.9s），导致“升降梯先动、主角几秒后才跟上”。
    // 改画权威逻辑位置后，对话/回溯等暂停 sim 的模式也会同步静止。
    const x = p.x;
    const y = p.y;
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
    this.drawSwordSlots(d, time, state);
    this.drawWindSigils(d, time, state);
    this.drawStarNodes(d, time, state);
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
      if (this.floorOfY(y1) !== this.activeFloor) {
        continue;
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
      if (this.floorOfY(r.y) !== this.activeFloor) {
        continue;
      }
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
      if (this.floorOfY(b.y) !== this.activeFloor) {
        continue;
      }
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
      if (this.floorOfY(pl.y) !== this.activeFloor) {
        continue;
      }
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

  // 剑槽：石座 + 竖直插槽缝；插入后画一柄竖直插着的剑剪影（水墨金色调）
  private drawSwordSlots(d: DrawNode.Type, time: number, state: LoopState): void {
    const slots = this.data.swordSlots;
    if (slots === undefined) {
      return;
    }
    for (const slot of slots) {
      if (this.floorOfY(slot.y) !== this.activeFloor) {
        continue;
      }
      if (!this.inView(slot.x - 44, slot.y, slot.x + 44, slot.y + 110)) {
        continue;
      }
      const inserted = state.flags["swordslot_" + slot.id] === true;
      // 石座
      d.drawPolygon(
        [Vec2(slot.x - 24, slot.y + 12), Vec2(slot.x + 24, slot.y + 12), Vec2(slot.x + 20, slot.y), Vec2(slot.x - 20, slot.y)],
        col(ink(58, 54, 48, 235)),
        0,
        Color(0, 0, 0, 0)
      );
      seg(d, slot.x - 20, slot.y + 12, slot.x + 20, slot.y + 12, 1.6, PAPER_DIM, 0.8);
      // 竖直插槽缝
      d.drawPolygon(
        [Vec2(slot.x - 3.5, slot.y + 58), Vec2(slot.x + 3.5, slot.y + 58), Vec2(slot.x + 3.5, slot.y + 10), Vec2(slot.x - 3.5, slot.y + 10)],
        col(ink(28, 26, 23, 240)),
        0,
        Color(0, 0, 0, 0)
      );
      seg(d, slot.x - 3.5, slot.y + 34, slot.x - 3.5, slot.y + 56, 1.2, GOLD, inserted ? 0.9 : 0.4);
      seg(d, slot.x + 3.5, slot.y + 34, slot.x + 3.5, slot.y + 56, 1.2, GOLD, inserted ? 0.9 : 0.4);
      if (inserted) {
        // 剑剪影：竖直剑身 + 护手 + 剑柄，带月光呼吸
        const glow = 0.75 + 0.25 * Math.sin(time * 2.2);
        d.drawPolygon(
          [Vec2(slot.x - 4, slot.y + 62), Vec2(slot.x + 4, slot.y + 62), Vec2(slot.x + 2.4, slot.y + 16), Vec2(slot.x - 2.4, slot.y + 16)],
          col(ink(198, 204, 196, 235)),
          0,
          Color(0, 0, 0, 0)
        );
        d.drawPolygon(
          [Vec2(slot.x - 4, slot.y + 62), Vec2(slot.x, slot.y + 62), Vec2(slot.x, slot.y + 16), Vec2(slot.x - 2.4, slot.y + 16)],
          col(ink(236, 240, 232, 120)),
          0,
          Color(0, 0, 0, 0)
        );
        seg(d, slot.x - 12, slot.y + 58, slot.x + 12, slot.y + 58, 4, GOLD, 0.95);
        seg(d, slot.x - 12, slot.y + 56.4, slot.x + 12, slot.y + 56.4, 1.2, ink(120, 92, 44, 220), 0.8);
        seg(d, slot.x, slot.y + 56, slot.x, slot.y + 44, 3.2, ink(74, 58, 40, 235), 0.95);
        dot(d, slot.x, slot.y + 42.5, 3, GOLD, glow);
        dot(d, slot.x, slot.y + 70, 10, Palette.moonWhite, 0.04 + 0.05 * glow);
      }
    }
  }

  // 风息符文（F3 塔外环廊）：地面风纹石环 + 三道旋臂；冲刺穿过激活后旋臂转动、青光脉冲、气流升腾
  private drawWindSigils(d: DrawNode.Type, time: number, state: LoopState): void {
    for (let i = 0; i < this.data.windSigils.length; i++) {
      const s = this.data.windSigils[i];
      if (this.floorOfY(s.y) !== this.activeFloor || !this.inView(s.x - 60, s.y - 10, s.x + 60, s.y + 110)) {
        continue;
      }
      const on = state.flags["wind_" + s.id] === true;
      const cy = s.y + 34;
      circle(d, s.x, cy, 26, ink(58, 54, 48, 200), 3, 0.9);
      const spin = on ? time * 1.6 : 0;
      for (let k = 0; k < 3; k++) {
        const a = spin + (k * Math.PI * 2) / 3;
        const ax = s.x + Math.cos(a) * 13;
        const ay = cy + Math.sin(a) * 11;
        const bx = s.x + Math.cos(a + 0.9) * 23;
        const by = cy + Math.sin(a + 0.9) * 19;
        seg(d, ax, ay, bx, by, 2.6, on ? CYAN : PAPER_DIM, on ? 0.95 : 0.7);
      }
      dot(d, s.x, cy, on ? 5 : 3, on ? CYAN : PAPER_DIM, on ? 0.95 : 0.8);
      if (on) {
        for (let k = 0; k < 3; k++) {
          const t = (time * 0.7 + k / 3) % 1;
          dot(d, s.x + Math.sin((t * 6 + k) * 2) * 8, s.y + 20 + t * 56, 2.4, CYAN, (1 - t) * 0.7);
        }
        const pulse = (time * 0.9) % 1;
        circle(d, s.x, cy, 20 + pulse * 40, CYAN, 14, (1 - pulse) * 0.5);
      }
    }
  }

  // 星位（F5 观星者之间）：石柱顶悬浮星芒；相邻已亮星位间月光连线，连成星图
  private drawStarNodes(d: DrawNode.Type, time: number, state: LoopState): void {
    const nodes = this.data.starNodes;
    for (let i = 0; i < nodes.length - 1; i++) {
      const a = nodes[i];
      const b = nodes[i + 1];
      if (this.floorOfY(a.y) !== this.activeFloor || this.floorOfY(b.y) !== this.activeFloor) {
        continue;
      }
      if (state.flags["star_" + a.id] === true && state.flags["star_" + b.id] === true) {
        const pulse = 0.5 + 0.25 * Math.sin(time * 2.4 + i);
        seg(d, a.x, a.y + 58, b.x, b.y + 58, 1.6, Palette.moonWhite, pulse);
      }
    }
    for (let i = 0; i < nodes.length; i++) {
      const s = nodes[i];
      if (this.floorOfY(s.y) !== this.activeFloor || !this.inView(s.x - 44, s.y - 20, s.x + 44, s.y + 110)) {
        continue;
      }
      const lit = state.flags["star_" + s.id] === true;
      seg(d, s.x, s.y, s.x, s.y + 40, 4, ink(70, 60, 46, 235));
      seg(d, s.x - 9, s.y + 40, s.x + 9, s.y + 40, 3, ink(70, 60, 46, 235));
      const cy = s.y + 58;
      const c = lit ? Palette.moonWhite : PAPER_DIM;
      const tw = lit ? 0.75 + 0.25 * Math.sin(time * 3 + i * 1.7) : 0.5;
      const r = lit ? 12 : 7;
      seg(d, s.x - r, cy, s.x + r, cy, 1.8, c, tw);
      seg(d, s.x, cy - r, s.x, cy + r, 1.8, c, tw);
      dot(d, s.x, cy, lit ? 5.5 : 3, c, tw);
      if (lit) {
        dot(d, s.x, cy, 15, Palette.moonWhite, 0.06);
      }
    }
  }

  private drawLanterns(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const ln of this.data.lanterns) {
      if (this.floorOfY(ln.y) !== this.activeFloor) {
        continue;
      }
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
      if (this.floorOfY(cp.y) !== this.activeFloor) {
        continue;
      }
      if (!this.inView(cp.x - 60, cp.y, cp.x + 60, cp.y + 90)) {
        continue;
      }
      if (cp.id === "cp_riverbank") {
        continue; // 出生点旗已移除：整块不画（含石座/程序化回退旗），检查点重生功能不受影响
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
      const fs = this.flagSets[cp.id];
      if (fs !== undefined) {
        // 旗贴图模式：旗面整体贴图（逻辑高≈90，底边对齐地面），保留石座；激活后四帧循环≈8fps
        fs.off.visible = !active;
        const frame = Math.floor(time * 8) % fs.on.length;
        for (let fi = 0; fi < fs.on.length; fi++) {
          fs.on[fi].visible = active && fi === frame;
        }
        if (active) {
          const pulse = (time * 0.7) % 1;
          circle(d, cp.x, cp.y + 24, 14 + pulse * 30, CYAN, 16, (1 - pulse) * 0.5);
        }
      } else {
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
  }

  private drawCollectibles(d: DrawNode.Type, time: number, state: LoopState): void {
    for (const c of this.data.collectibles) {
      if (this.floorOfY(c.y) !== this.activeFloor) {
        continue;
      }
      if (c.loops !== undefined && c.loops.indexOf(state.loopIndex) < 0) {
        const gone1 = this.lampStoneSprites[c.id];
        if (gone1 !== undefined) {
          gone1.visible = false;
        }
        const gone1m = this.moonStoneSprites[c.id];
        if (gone1m !== undefined) {
          gone1m.visible = false;
        }
        const gone1d = this.dewSprites[c.id];
        if (gone1d !== undefined) {
          gone1d.visible = false;
        }
        const gone1t = this.tokenSprites[c.id];
        if (gone1t !== undefined) {
          gone1t.visible = false;
        }
        continue;
      }
      if (state.collectedIds[c.id] === true) {
        const gone2 = this.lampStoneSprites[c.id];
        if (gone2 !== undefined) {
          gone2.visible = false;
        }
        const gone2m = this.moonStoneSprites[c.id];
        if (gone2m !== undefined) {
          gone2m.visible = false;
        }
        const gone2d = this.dewSprites[c.id];
        if (gone2d !== undefined) {
          gone2d.visible = false;
        }
        const gone2t = this.tokenSprites[c.id];
        if (gone2t !== undefined) {
          gone2t.visible = false;
        }
        continue;
      }
      if (!this.inView(c.x - 40, c.y - 10, c.x + 40, c.y + 40)) {
        continue;
      }
      const bob = Math.sin(time * 2 + c.x * 0.1) * 3;
      const cx = c.x;
      const cy = c.y + bob;
      if (c.kind === "lampstone") {
        // 点灯石：贴图（逻辑高≈36px，随波浮动）；缺失回退程序化石子
        const ls = this.lampStoneSprites[c.id];
        if (ls !== undefined) {
          ls.visible = true;
          ls.position = Vec2(cx, cy + 18);
        } else {
          circle(d, cx, cy + 14, 13, GOLD, 18, 0.22);
          d.drawPolygon(
            [Vec2(cx - 7, cy + 6), Vec2(cx + 7, cy + 6), Vec2(cx + 4, cy + 22), Vec2(cx - 4, cy + 22)],
            col(ink(196, 168, 108, 235)),
            0,
            Color(0, 0, 0, 0)
          );
          dot(d, cx, cy + 14, 3.4, Palette.moonWhite, 0.9);
        }
      } else if (c.kind === "moonstone") {
        // 月石：贴图（与点灯石同素材，逻辑高≈36px）；缺失回退程序化月点
        const ms = this.moonStoneSprites[c.id];
        if (ms !== undefined) {
          ms.visible = true;
          ms.position = Vec2(cx, cy + 18);
        } else {
          dot(d, cx, cy + 12, 13, CYAN, 0.25);
          dot(d, cx, cy + 12, 6.5, CYAN);
          dot(d, cx - 2, cy + 14, 2, Palette.moonWhite, 0.9);
        }
      } else if (c.kind === "mechanism") {
        const rot = time * 1.2;
        circle(d, cx, cy + 10, 7, GOLD, 12, 0.95);
        for (let i = 0; i < 6; i++) {
          const a = rot + (i / 6) * Math.PI * 2;
          seg(d, cx + Math.cos(a) * 7, cy + 10 + Math.sin(a) * 7, cx + Math.cos(a) * 10.5, cy + 10 + Math.sin(a) * 10.5, 2.2, GOLD, 0.95);
        }
        dot(d, cx, cy + 10, 2.2, GOLD, 0.9);
      } else if (c.kind === "token") {
        // 旧物：引月札同款蓝色月华碎片贴图（缺失回退程序化纸牌）
        const tk = this.tokenSprites[c.id];
        if (tk !== undefined) {
          tk.visible = true;
          tk.position = Vec2(cx, cy + 18);
        } else {
          d.drawPolygon(
            [Vec2(cx - 7, cy + 16), Vec2(cx + 7, cy + 16), Vec2(cx + 7, cy + 4), Vec2(cx - 7, cy + 4)],
            col(ink(112, 84, 56, 225)),
            0,
            Color(0, 0, 0, 0)
          );
          circle(d, cx, cy + 20, 3.2, Palette.inkDark, 8, 0.9);
          seg(d, cx - 3.5, cy + 12, cx + 3.5, cy + 12, 1, PAPER_DIM, 0.9);
        }
      } else {
        // 晨露（血包）：用户素材贴图优先，缺失回退程序化露珠
        const dw = this.dewSprites[c.id];
        if (dw !== undefined) {
          dw.visible = true;
          dw.position = Vec2(cx, cy + 18);
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
  }

  // 装饰：机关层双齿轮 + 观星台星盘 + 月相装置（y 均由 FLOOR_TOPS 按层推导）
  private drawDecor(d: DrawNode.Type, time: number): void {
    if (this.activeFloor === 4 && this.inView(500, FLOOR_TOPS[4], 2100, FLOOR_TOPS[4] + 160)) {
      this.drawGear(d, 800, FLOOR_TOPS[4] + 80, 46, 18, time * 0.35);
      this.drawGear(d, 1800, FLOOR_TOPS[4] + 80, 34, 14, -time * 0.5 + 0.4);
    }
    if (this.activeFloor === 6 && this.inView(900, FLOOR_TOPS[6] - 90, 1500, FLOOR_TOPS[6] + 310)) {
      const cx = 1200;
      const cy = FLOOR_TOPS[6] + 180;
      circle(d, cx, cy, 34, GOLD, 24, 0.5);
      circle(d, cx, cy, 22, GOLD, 20, 0.65);
      arc(d, cx, cy, 28, time * 0.4, time * 0.4 + Math.PI * 1.4, 14, 2, CYAN, 0.7);
      for (let i = 0; i < 12; i++) {
        const a = (i / 12) * Math.PI * 2 + time * 0.05;
        seg(d, cx + Math.cos(a) * 34, cy + Math.sin(a) * 34, cx + Math.cos(a) * 39, cy + Math.sin(a) * 39, 1.6, GOLD, 0.6);
      }
      dot(d, cx, cy, 3.4, CYAN, 0.9);
    }
    if (this.activeFloor === 6 && this.inView(1900, FLOOR_TOPS[6] - 40, 2300, FLOOR_TOPS[6] + 260)) {
      const cx = 2100;
      const cy = FLOOR_TOPS[6] + 100;
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

  // 用户需求①：头目剑气震波贴图渲染（素材包 slash_blue，64px/帧横排雪碧图）。
  // 返回 false 表示贴图不可用，调用方回退程序化月牙；true 时本帧已用精灵同步全部震波。
  private syncBossWaveSprites(enemies: EnemySystem): boolean {
    if (!this.bossWaveChecked) {
      this.bossWaveChecked = true;
      this.bossWaveTex = this.loadTex("assets/effects/slash_blue.png");
    }
    const tex = this.bossWaveTex;
    if (tex === undefined) {
      return false;
    }
    const waves = enemies.waves;
    const frames = Math.max(1, Math.floor(tex.width / 64));
    while (this.bossWaveSprites.length > waves.length) {
      const sp = this.bossWaveSprites.pop();
      if (sp !== undefined) {
        sp.removeFromParent();
      }
    }
    while (this.bossWaveSprites.length < waves.length) {
      const created = Sprite(tex, Rect(Math.floor(frames / 2) * 64, 0, 64, 64));
      if (created === undefined) {
        return false;
      }
      created.filter = TextureFilter.Point;
      created.addTo(this.waveSpriteRoot);
      this.bossWaveSprites.push(created);
    }
    // 波判定盒 28×40（y-18..y+22）不变，视觉放大为 ~92px 竖直剑刃，中心对齐 y+20
    const k = 92 / 64;
    for (let i = 0; i < this.bossWaveSprites.length; i++) {
      const sp = this.bossWaveSprites[i];
      const wv = waves[i];
      sp.position = Vec2(wv.x, wv.y + 20);
      sp.scaleX = (wv.dir >= 0 ? 1 : -1) * k;
      sp.scaleY = k;
      sp.opacity = wv.life < 0.4 ? Math.floor(255 * (wv.life / 0.4)) : 255;
    }
    return true;
  }

  // 弓手箭矢：短杆+白亮箭镞，方向随速度矢量
  private drawArrow(d: DrawNode.Type, x: number, y: number, vx: number, vy: number): void {
    const lenRaw = Math.sqrt(vx * vx + vy * vy);
    const len = lenRaw > 0.0001 ? lenRaw : 1;
    const ux = vx / len;
    const uy = vy / len;
    seg(d, x - ux * 12, y - uy * 12, x + ux * 6, y + uy * 6, 2.2, ink(196, 188, 168, 235));
    dot(d, x + ux * 7, y + uy * 7, 2.4, ink(244, 240, 226, 255));
  }

  // 角色层：投掷物/震波/敌人/推石/NPC/玩家（后画在上）
  private drawChars(time: number, state: LoopState, player: Player, enemies: EnemySystem, mech: MechanismSystem, dt: number): void {
    const d = this.charDraw;
    d.clear();
    this.ninja.beginFrame(dt);
    for (const p of enemies.pots) {
      if (!p.alive) {
        continue;
      }
      if (this.inView(p.x - 20, p.y - 20, p.x + 20, p.y + 20)) {
        drawPot(d, p.x, p.y, time);
      }
    }
    // 用户需求①：头目剑刃改用素材包贴图；缺图回退程序化月牙
    if (!this.syncBossWaveSprites(enemies)) {
      for (const wv of enemies.waves) {
        if (this.inView(wv.x - 40, wv.y - 20, wv.x + 40, wv.y + 50)) {
          drawWave(d, wv.x, wv.y, wv.dir, time);
        }
      }
    }
    // 弓手箭矢（1F 弓手C）：短杆+亮头，方向随速度，命中/撞板即由逻辑层清除
    for (const ar of enemies.arrows) {
      if (!ar.alive) {
        continue;
      }
      if (this.inView(ar.x - 30, ar.y - 30, ar.x + 30, ar.y + 30)) {
        this.drawArrow(d, ar.x, ar.y, ar.vx, ar.vy);
      }
    }
    for (const e of enemies.enemies) {
      if (e.dead && e.deathTimer <= 0) {
        continue;
      }
      // 新任务④：敌人（含忍者雪碧图与程序化两种渲染）只渲染本层
      if (this.floorOfY(e.body.y) !== this.activeFloor) {
        continue;
      }
      if (this.inView(e.body.x - 60, e.body.y - e.body.h / 2, e.body.x + 60, e.body.y + e.body.h / 2)) {
        if (!this.ninja.drawEnemy(e)) {
          drawEnemy(d, e, e.animTime);
        }
      }
    }
    this.ninja.endFrame();
    for (let si = 0; si < mech.stones.length; si++) {
      const s = mech.stones[si];
      const inR = this.inView(s.x - 40, s.y - 40, s.x + 40, s.y + 40);
      if (si < this.stoneSprites.length) {
        // 贴图模式：只画逻辑权威坐标（mechanisms 每帧写入的 StoneBody），不做时间重算
        const sp = this.stoneSprites[si];
        sp.visible = inR;
        if (inR) {
          sp.position = Vec2(s.x, s.y);
        }
        continue;
      }
      if (!inR) {
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
    // 石体数量可能少于贴图池（同步后）：多余的贴图隐藏
    for (let si = mech.stones.length; si < this.stoneSprites.length; si++) {
      this.stoneSprites[si].visible = false;
    }
    if (this.shenYan !== undefined) {
      const sy = this.shenYan;
      if (this.floorOfY(sy.y) === this.activeFloor && this.inView(sy.x - 60, sy.y - 20, sy.x + 60, sy.y + 100)) {
        drawShenYan(d, sy.x, sy.y, sy.facing, time, sy.hostile);
      }
    }
    if (this.observer !== undefined) {
      const ob = this.observer;
      if (this.floorOfY(ob.y) === this.activeFloor && this.inView(ob.x - 50, ob.y, ob.x + 50, ob.y + 130)) {
        drawObserver(d, ob.x, ob.y, time);
      }
    }
    const px = player.body.x;
    const py = player.body.y - player.body.h / 2;
    const pose = this.heroPose(player);
    // 出生/受击无敌期保持实体可见，不再闪烁虚化（无敌保护逻辑仍在 player 内生效）
    const visible = this.inView(px - 80, py - 20, px + 80, py + 120);
    // 爬梯姿势相位用 climbT（只在攀爬移动时推进），其余姿势维持 animTime
    const animT = pose === "ladder" ? player.climbT : player.animTime;
    if (this.heroTexOk) {
      this.updateHeroSprite(px, py, player.facing, pose, animT, state.phaseIndex, visible, dt);
    } else if (visible) {
      drawHero(d, px, py, player.facing, pose, animT, state.phaseIndex);
    }
  }

  // 立绘模式：Sprite 定位/翻转/呼吸浮动，受伤红闪叠画在 heroFxDraw；冲刺残影在 ghostRoot
  private updateHeroSprite(
    x: number,
    y: number,
    facing: number,
    pose: HeroPose,
    t: number,
    phaseIndex: number,
    visible: boolean,
    dt: number
  ): void {
    const sp = this.heroSprite;
    const f = this.heroFxDraw;
    f.clear();
    this.updateGhosts(dt);
    if (!visible) {
      if (sp !== undefined) {
        sp.visible = false;
      }
      this.heroFrames.hideAll();
      return;
    }
    // 动作帧优先：命中姿势表则驱动对应 Sprite，缺帧回退单张立绘
    const fr = this.heroFrames.pick(pose, t);
    if (fr !== undefined) {
      if (sp !== undefined) {
        sp.visible = false;
      }
      this.heroFrames.hideAll();
      fr.sp.visible = true;
      let bobF = 0;
      if (pose === "jump") {
        bobF = 2;
      } else if (pose === "fall") {
        bobF = -2;
      }
      fr.sp.position = Vec2(x, y + bobF);
      fr.sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT ? 1 : -1);
      fr.sp.scaleY = fr.scale;
      // 残影：冲刺 / 跳跃（含普通跳、二段跳、贴墙跳） / 下落，同款淡青残影（ghostCd 共享节流）
      if (this.ghostCd <= 0 && (pose === "dash" || pose === "jump" || pose === "fall")) {
        this.spawnGhost(fr, x, y + bobF, facing);
        this.ghostCd = GHOST_INTERVAL;
      }
      this.drawHeroFx(f, x, y, facing, pose, t, phaseIndex, 0);
      return;
    }
    this.heroFrames.hideAll();
    if (sp === undefined) {
      this.drawHeroFx(f, x, y, facing, pose, t, phaseIndex, 0);
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
    this.drawHeroFx(f, x, y, facing, pose, t, phaseIndex, bob);
  }

  // 受伤红闪（帧动画/立绘通用，叠加在 heroFxDraw）
  // 普攻程序化剑光弧已删：与 slashfx 白剑气弧（slash_white.png，缺图回退程序月牙）重复，
  // 用户反馈普攻特效过多；普攻/剑气（K）弧线统一由 slashfx 渲染
  private drawHeroFx(
    f: DrawNode.Type,
    x: number,
    y: number,
    _facing: number,
    pose: HeroPose,
    _t: number,
    _phaseIndex: number,
    _bob: number
  ): void {
    // 月光淡晕白圈已按需求移除（用户反馈女主角身上有白色圆圈）
    // 受伤红闪
    if (pose === "hurt") {
      dot(f, x, y + 46, 26, ink(220, 70, 60, 160), 0.5);
    }
  }

  // 冲刺残影：淡出更新
  private updateGhosts(dt: number): void {
    if (this.ghostCd > 0) {
      this.ghostCd = this.ghostCd - dt;
    }
    let i = this.ghosts.length - 1;
    while (i >= 0) {
      const g = this.ghosts[i];
      g.t = g.t + dt;
      if (g.t >= g.dur) {
        g.sp.removeFromParent();
        this.ghosts.splice(i, 1);
      } else {
        g.sp.opacity = GHOST_ALPHA * (1 - g.t / g.dur);
      }
      i = i - 1;
    }
  }

  // 克隆当前动作帧为残影：淡青月光色调 + 向后偏移，置于主角之下
  private spawnGhost(fr: HeroFrame, x: number, y: number, facing: number): void {
    if (this.ghosts.length >= GHOST_MAX) {
      return;
    }
    const tex = fr.sp.texture;
    if (tex === undefined) {
      return;
    }
    const sp = Sprite(tex);
    if (sp === undefined) {
      return;
    }
    sp.anchor = Vec2(0.5, 0);
    sp.position = Vec2(x - facing * GHOST_OFFSET, y);
    sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT ? 1 : -1);
    sp.scaleY = fr.scale;
    sp.color = Color(GHOST_TINT_R, GHOST_TINT_G, GHOST_TINT_B, 255);
    sp.opacity = GHOST_ALPHA;
    sp.addTo(this.ghostRoot);
    this.ghosts.push({ sp: sp, t: 0, dur: GHOST_DUR });
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
      return idx <= 0 ? "attack1" : idx === 1 ? "attack2" : idx === 2 ? "attack3" : "heavy";
    }
    if (a === "land") {
      return "idle";
    }
    return a;
  }
}