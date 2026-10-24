// ui/hud.ts — 抬头显示：生命/剑意/目标/提示/Boss血条/受击红晕/回溯遮罩/结局/标题菜单/暂停
import { Audio, Color, Content, DrawNode, KeyName, Label, Node, Size, Sprite, Texture2D, TextureFilter, Touch, Vec2, VideoNode, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { LoopState } from "core/types";
import { ENDINGS, PHASE_NAMES } from "data/story";
import { ENDING_IMAGES } from "data/ending_images";
import { EnemyState } from "game/enemies";
import { Player } from "game/player";
import { makeTechPanel, TECH_BTN_PATH } from "ui/tech_ui";
import { playBgm, stopBgm } from "game/audio";

const FONT = "sarasa-mono-sc-regular";
// 标题字：NameFont 优先，DialogFont 次之，均失败回退内置像素字体
const TITLE_FONTS: string[] = ["assets/font/NameFont.ttf", "assets/font/DialogFont.ttf"];
const PANEL_FONT = "assets/font/DialogFont.ttf";
const NO_FILL = ink(0, 0, 0, 0);
const HEART_TEX = "assets/ui/icon_heart.png";
const HEART_SCALE = 3;
const HEART_STEP = 52;
const BAR_W = 192;
const BAR_H = 36;
const BAR_PAD = 3;
const HUD_MAX_HEARTS = 8;
// —— HUD 月相轮三态（右上角）：三图齐备才启用，缺一整体回退程序化圆环 ——
const WHEEL_TEX_NORMAL = "assets/ui/moon_wheel_normal.png";
const WHEEL_TEX_ACTIVE = "assets/ui/moon_wheel_active.png";
const WHEEL_TEX_DIM = "assets/ui/moon_wheel_dim.png";
const WHEEL_PX = 46;
// —— 标题菜单 / 标题特效常量 ——
const MENU_W = 320;
const MENU_H = 60;
const MENU_HALF_X = MENU_W / 2 + 28;
const MENU_HALF_Y = MENU_H / 2 + 16;
// 菜单在左下角纵列：MENU_X_OFF=按钮中心距左缘；MENU_YS=各按钮中心距底缘（自上而下 PLAY/时空树仓库/SETTINGS）
const MENU_X_OFF = 240; // 用户反馈太靠左，右移（原 196）；第十五轮曾移主标题下方，用户要求退回左下角
const MENU_YS: number[] = [216, 140, 64];
const MENU_FLASH_T = 0.28;
const PANEL_W = 560;
const PANEL_H = 470;
const TITLE_PARTICLE_N = 3;
const FLASH_TIME = 0.45;
// —— 封面/序幕视频路径（钉死，避免 .agent 下多个 ogv 被顺序扫描抢占）——
const COVER_VIDEO_PIN = ".agent/封面动画.ogv";
// ⚠️ 素材规格红线：VideoNode 是 Theora 软件解码。实测 2560×1440/45MB 的序幕远低于实时（90s 窗口播不完，
// 画面看似卡死在首帧；剥掉音轨的纯视频轨同样慢，音轨无关）。1280×720/4.5MB 的封面可实时播放。
// 序幕视频必须按 ≤1280×720 重新导出后替换本文件（ffmpeg 参考：-vf scale=1280:-2 -c:v libtheora -q:v 6 -an）。
const PROLOGUE_VIDEO_FILE = ".agent/720.ogv"; // 用户重导出的 720p 前情提要（2026 新传）
const PROLOGUE_EXCLUDED_NAME = "游戏前情提要.ogv"; // 封面回退扫描时跳过序幕文件
const PROLOGUE_START_TIMEOUT = 8; // 起播兜底秒数：超时视为播完，防止 PLAY 流程卡死
const PROLOGUE_VIDEO_DELAY = 0.4; // 音画同步：先起配轨，延迟本秒数再创建视频起播
const PROLOGUE_AUDIO_TAIL = 5.2; // 音画收尾：视频比配轨短约 5s，自然播完后保尾帧等余音再结束（用户需求① 2026-10-26）
// 序幕视频配轨：VideoNode 仅渲染视频不出声，播放序幕时若存在以下任一音频文件则同步播放（按序取第一个命中的）
const PROLOGUE_AUDIO_FILES: string[] = ["assets/audio/bgm-prologue.mp3", "assets/audio/bgm-prologue.ogg"];

const SETTINGS_KEYS: string[] = [
  "A / D　移动", "W / S　爬梯", "Space　跳跃", "J　攻击", "K　剑气",
  "LShift　冲刺", "E　交互", "R　月相轮回", "Tab　笔记", "Esc　暂停",
];

const PAUSE_KEYS: string[] = [
  "A / D　移动", "Space　跳跃 / 二段跳", "J　攻击", "K　剑气", "Shift　闪身", "W / S　攀爬",
  "E　交互", "R　月相轮回", "N　引月札", "Tab　手札", "Esc　暂停",
];

interface TitleParticle {
  x: number;
  y: number;
  vy: number;
  r: number;
  ph: number;
  gold: boolean;
}

export interface HudArgs {
  state: LoopState;
  player: Player;
  boss: EnemyState | undefined;
  objective: string;
  mission: string;
  floorName: string;
  guideLight?: boolean; // 观星台（月夜）：指引面板文字切白色
  hint: string;
  fade?: number;
  time: number;
}

function loadTex(path: string): Texture2D.Type | undefined {
  return Texture2D(path);
}

function pxSprite(tex: Texture2D.Type): Sprite.Type {
  const sp = Sprite(tex);
  sp.filter = TextureFilter.Point;
  return sp;
}

function col(c: InkColor): Color.Type { return Color(c.r, c.g, c.b, c.a); }

function makeLabel(parent: Node.Type, size: number, x: number, y: number, ax: number, ay: number, color: InkColor): Label.Type | undefined {
  const lb = Label(FONT, size);
  if (lb === undefined) {
    return undefined;
  }
  lb.anchor = Vec2(ax, ay);
  lb.position = Vec2(x, y);
  lb.color = Color(color.r, color.g, color.b, color.a);
  lb.addTo(parent);
  return lb;
}

function setText(lb: Label.Type | undefined, text: string): void {
  if (lb !== undefined && lb.text !== text) {
    lb.text = text;
  }
}

// 右上角指引面板用：项目自带白色像素字体（NameFont → DialogFont），失败回退内置字体
function makePixelLabel(parent: Node.Type, size: number, x: number, y: number, ax: number, ay: number, color: InkColor): Label.Type | undefined {
  for (let i = 0; i < TITLE_FONTS.length; i++) {
    const lb = Label(TITLE_FONTS[i], size);
    if (lb !== undefined) {
      lb.anchor = Vec2(ax, ay);
      lb.position = Vec2(x, y);
      lb.color = Color(color.r, color.g, color.b, color.a);
      lb.addTo(parent);
      return lb;
    }
  }
  return makeLabel(parent, size, x, y, ax, ay, color);
}

// 指引面板断行：优先在句读处断，超长硬断；按 UTF-8 码点计数与切分
// （Lua 字符串按字节存储，charAt/length 对中文是字节碎片与字节数，会提前约 3 倍换行）
function wrapCjk(text: string, maxChars: number): string {
  const breaks: string[] = ["，", "；", "。", "！", "？", "：", "）"];
  const glyphs: string[] = [];
  let i = 0;
  while (i < text.length) {
    const b = text.charCodeAt(i);
    const seq = b >= 0xF0 ? 4 : b >= 0xE0 ? 3 : b >= 0xC0 ? 2 : 1;
    glyphs.push(text.substring(i, i + seq));
    i += seq;
  }
  const lines: string[] = [];
  let start = 0;
  while (start < glyphs.length) {
    let end = Math.min(start + maxChars, glyphs.length); // 硬断位置（不含）
    if (end < glyphs.length) {
      // 优先在行尾 4 个码点内的句读后断开
      for (let k = end - 1; k >= end - 4 && k > start; k--) {
        if (breaks.indexOf(glyphs[k]) >= 0) {
          end = k + 1;
          break;
        }
      }
    }
    let line = "";
    for (let k = start; k < end; k++) {
      line += glyphs[k];
    }
    lines.push(line);
    start = end;
  }
  if (lines.length === 0) {
    lines.push("");
  }
  return lines.join("\n");
}

export class HUD {
  private hudNode: Node.Type;
  private endingNode: Node.Type;
  private titleNode: Node.Type;
  private pauseNode: Node.Type;
  private hud: DrawNode.Type;
  private flash: DrawNode.Type;
  private rewindDraw: DrawNode.Type;
  private endingBg: DrawNode.Type;
  private titleBg: DrawNode.Type;
  // 右上角「月相轮的指引」：标题 + 本层任务 + 当前指引
  private guideTitleLb: Label.Type | undefined;
  private guideMissionLb: Label.Type | undefined;
  private guideStepLb: Label.Type | undefined;
  private hintLb: Label.Type | undefined;
  private phaseLb: Label.Type | undefined;
  private loopLb: Label.Type | undefined;
  private rewindLb: Label.Type | undefined;
  private endingTitleLb: Label.Type | undefined;
  private endingLineLbs: Label.Type[];
  private endingHintLb: Label.Type | undefined;
  // 结局插图 Sprite（按结局 id 惰性换 texture）与缓存检查的文件名
  private endingSp: Sprite.Type | undefined;
  private endingTexId: string;
  private flashTimer: number;
  private rewindV: number;
  private heartTex: Texture2D.Type | undefined;
  private heartSps: Sprite.Type[];
  // —— 标题菜单公开契约（新增成员，不改既有方法）——
  public titleMenuEnabled: boolean = false;
  public onPlayConfirmed: (() => void) | undefined;
  public onGalleryConfirmed: (() => void) | undefined;
  // 暂停菜单「回到标题」点击回调（由游戏层注入，走与结局返回相同的收尾链路）
  public onReturnTitle: (() => void) | undefined;
  private coverSp: Sprite.Type | undefined;
  private coverVideo: VideoNode.Type | undefined; // 标题封面循环视频（.ogv/Theora）；非空时优先于静态图
  private coverBaseScale: number;
  private titleNameLb: Label.Type | undefined;
  private menuDraws: DrawNode.Type[];
  private menuLbs: Label.Type[];
  private menuBtns: Sprite.Type[];
  private menuBtnOk: boolean[];
  private menuBtnW: number;
  private menuBtnH: number;
  private menuSel: number;
  private menuFlashT: number;
  private playLock: boolean;
  private settingsOpen: boolean;
  private settingsNode: Node.Type;
  private particlesDraw: DrawNode.Type;
  private particles: TitleParticle[];
  // —— HUD 月相轮三态 ——
  private wheelNormalSp: Sprite.Type | undefined;
  private wheelActiveSp: Sprite.Type | undefined;
  private wheelDimSp: Sprite.Type | undefined;
  private wheelDraw: DrawNode.Type;
  private wheelMode: "normal" | "active" | "dim";
  // —— 序幕覆盖层：「游戏前情提要」视频（PLAY 后先播再进名字输入）——
  private prologueNode: Node.Type;
  private prologueBlack: DrawNode.Type;
  private prologueVideo: VideoNode.Type | undefined;
  private prologueHintLb: Label.Type | undefined;
  private prologuePlaying: boolean;
  private prologueStarted: boolean;
  private prologueWaitT: number;
  private prologueDelayT: number;
  private prologueTailT: number;
  private prologueCard: Node.Type | undefined;
  private prologueCardTitle: Label.Type | undefined;
  private prologueCardSub: Label.Type | undefined;
  private prologueCardBg: DrawNode.Type | undefined;
  private prologueCoverVideo: VideoNode.Type | undefined;
  private prologueCoverFailed: boolean;
  private prologueAudio: string;
  private guideWhite: boolean;
  // —— 结局层点击返回：onEndingTap 由 game 接线（ending 模式才生效）——
  onEndingTap: (() => void) | undefined;
  private endingTapGuard: number;
  private prologueOnDone: (() => void) | undefined;

  constructor(parent: Node.Type) {
    this.endingLineLbs = [];
    this.endingTexId = "";
    this.flashTimer = 0;
    this.rewindV = -1;
    this.coverBaseScale = 1;
    this.coverSp = undefined;
    this.titleNameLb = undefined;
    this.menuDraws = [];
    this.menuLbs = [];
    this.menuBtns = [];
    this.menuBtnOk = [];
    this.prologueCoverFailed = false;
    this.menuBtnW = 1;
    this.menuBtnH = 1;
    this.menuSel = 0;
    this.menuFlashT = 0;
    this.playLock = false;
    this.settingsOpen = false;
    this.particles = [];
    this.wheelNormalSp = undefined;
    this.wheelActiveSp = undefined;
    this.wheelDimSp = undefined;
    this.wheelMode = "normal";
    this.prologueVideo = undefined;
    this.prologueHintLb = undefined;
    this.prologuePlaying = false;
    this.prologueStarted = false;
    this.prologueWaitT = 0;
    this.prologueDelayT = 0;
    this.prologueTailT = 0;
    this.prologueAudio = "";
    this.guideWhite = false;
    this.prologueOnDone = undefined;
    this.onEndingTap = undefined;
    this.endingTapGuard = 0;
    this.hudNode = Node();
    this.hudNode.addTo(parent);
    this.flash = DrawNode();
    this.flash.addTo(this.hudNode);
    this.rewindDraw = DrawNode();
    this.rewindDraw.addTo(this.hudNode);
    this.hud = DrawNode();
    this.hud.addTo(this.hudNode);
    // 像素素材层：生命心形（纹理加载失败则保持程序化画法）
    this.heartSps = [];
    this.heartTex = loadTex(HEART_TEX);
    if (this.heartTex !== undefined) {
      for (let i = 0; i < HUD_MAX_HEARTS; i++) {
        const sp = pxSprite(this.heartTex);
        sp.anchor = Vec2(0, 0);
        sp.scaleX = HEART_SCALE;
        sp.scaleY = HEART_SCALE;
        sp.visible = false;
        sp.addTo(this.hudNode);
        this.heartSps.push(sp);
      }
    }
    // 月相轮三态贴图：三图齐备才启用；新精修图分辨率大，按槽位最长边等比缩到 WHEEL_PX
    const wheelNTex = loadTex(WHEEL_TEX_NORMAL);
    const wheelATex = loadTex(WHEEL_TEX_ACTIVE);
    const wheelDTex = loadTex(WHEEL_TEX_DIM);
    if (wheelNTex !== undefined && wheelATex !== undefined && wheelDTex !== undefined) {
      this.wheelNormalSp = this.makeWheelSprite(wheelNTex, WHEEL_PX / Math.max(wheelNTex.width, wheelNTex.height));
      this.wheelActiveSp = this.makeWheelSprite(wheelATex, WHEEL_PX / Math.max(wheelATex.width, wheelATex.height));
      this.wheelDimSp = this.makeWheelSprite(wheelDTex, WHEEL_PX / Math.max(wheelDTex.width, wheelDTex.height));
    }
    this.wheelDraw = DrawNode();
    this.wheelDraw.addTo(this.hudNode);
    const w = View.size.width;
    const h = View.size.height;
    const left = -w / 2;
    const top = h / 2;
    // 右上角「月相轮的指引」：纯黑像素字体加大版，任务紧贴标题正下方向下生长
    const gr = w / 2 - 24;
    this.guideTitleLb = makePixelLabel(this.hudNode, 36, gr, top - 142, 1, 0.5, ink(0, 0, 0));
    setText(this.guideTitleLb, "— 月相轮的指引 —");
    this.guideMissionLb = makePixelLabel(this.hudNode, 30, gr, top - 178, 1, 1, ink(0, 0, 0));
    this.guideStepLb = makePixelLabel(this.hudNode, 26, gr, top - 178, 1, 1, ink(0, 0, 0));
    this.hintLb = makeLabel(this.hudNode, 18, 0, -top + 30, 0.5, 0.5, Palette.paleInkMid);
    this.rewindLb = makeLabel(this.hudNode, 26, 0, 96, 0.5, 0.5, Palette.moonCyan);
    setText(this.rewindLb, "回溯中…");
    if (this.rewindLb !== undefined) {
      this.rewindLb.visible = false;
    }
    const cx = w / 2 - 74;
    this.phaseLb = makeLabel(this.hudNode, 17, cx, top - 78, 0.5, 0.5, Palette.gold);
    this.loopLb = makeLabel(this.hudNode, 15, cx, top - 102, 0.5, 0.5, Palette.paleInk);
    // 结局层
    this.endingNode = Node();
    this.endingNode.addTo(parent);
    this.endingNode.visible = false;
    this.endingBg = DrawNode();
    this.endingBg.addTo(this.endingNode);
    this.endingTitleLb = makeLabel(this.endingNode, 46, 0, top - 150, 0.5, 0.5, Palette.inkDark);
    for (let i = 0; i < 8; i++) {
      const lb = makeLabel(this.endingNode, 20, 0, top - 224 - i * 34, 0.5, 0.5, Palette.inkSoft);
      if (lb !== undefined) {
        this.endingLineLbs.push(lb);
      }
    }
    this.endingHintLb = makeLabel(this.endingNode, 20, 0, -top + 46, 0.5, 0.5, Palette.paleInk);
    setText(this.endingHintLb, "点击 或 按 R 返回标题");
    // 结局页点击返回标题：刚显示 0.8s 内忽略点击（防结算连点误触直接跳回）
    const endingTouch = Node();
    endingTouch.size = Size(w, h);
    endingTouch.position = Vec2(0, 0);
    endingTouch.touchEnabled = true;
    endingTouch.addTo(this.endingNode);
    endingTouch.onTapBegan(() => {
      if (this.endingTapGuard > 0) {
        return;
      }
      if (this.onEndingTap !== undefined) {
        this.onEndingTap();
      }
    });
    this.endingNode.schedule((dt: number) => {
      if (this.endingTapGuard > 0) {
        this.endingTapGuard = this.endingTapGuard - dt;
      }
      return false;
    });
    // 标题层
    this.titleNode = Node();
    this.titleNode.addTo(parent);
    this.titleNode.visible = false;
    this.titleBg = DrawNode();
    this.titleBg.addTo(this.titleNode);
    // 封面：只认循环视频（用户定版「其他的都不要」，静态图封面已移除）——
    // 钉死 .agent/封面动画.ogv（新序幕 ogv 不再抢占封面）；找不到再回退扫描，
    // 扫描时跳过序幕文件名，仍取第一个 .ogv；都失败回退程序水墨背景
    let videoFile: string | undefined;
    if (Content.exist(COVER_VIDEO_PIN)) {
      videoFile = COVER_VIDEO_PIN;
    }
    if (videoFile === undefined) {
      const ogvDirs: string[] = ["assets/art", ".agent"];
      for (const dir of ogvDirs) {
        const names = Content.getFiles(dir);
        if (names === undefined) continue;
        for (const name of names) {
          if (name === PROLOGUE_EXCLUDED_NAME) continue;
          const ext = name.length >= 4 ? name.substring(name.length - 4) : "";
          if (ext === ".ogv" || ext === ".OGV") {
            videoFile = dir + "/" + name;
            break;
          }
        }
        if (videoFile !== undefined) break;
      }
    }
    const coverVideo = videoFile !== undefined ? VideoNode(videoFile, true) : undefined; // looped=true 循环播放
    if (coverVideo !== undefined) {
      const vw = coverVideo.width;
      const vh = coverVideo.height;
      if (vw > 0 && vh > 0) {
        const cs = Math.max(w / vw, h / vh); // 满屏铺底：等比取大
        coverVideo.anchor = Vec2(0.5, 0.5);
        coverVideo.position = Vec2(0, 0);
        coverVideo.scaleX = cs;
        coverVideo.scaleY = cs;
      }
      coverVideo.addTo(this.titleNode);
      this.coverVideo = coverVideo;
      if (!this.titleNode.visible) {
        coverVideo.pause(); // 初始隐藏不解码，setTitleVisible(true) 时恢复
      }
    }
    if (this.coverVideo === undefined) {
      this.drawTitleBg(w, h);
    }
    // 用户要求：封面底部原来的渐变暗角层（挡住封面下半）已移除；
    // 菜单按钮为全息半透明贴图，不依赖暗角保证可读性。
    // 游戏标题：NameFont → DialogFont → 内置像素字体
    this.titleNameLb = this.makeTitleFontLabel(this.titleNode, 74, 0, top - 168);
    if (this.titleNameLb !== undefined) {
      this.titleNameLb.color = Color(255, 255, 255, 255);
    }
    // 菜单：左下角纵列（全息透明按钮贴图），自上而下 PLAY / 时空树仓库 / SETTINGS
    const menuTexts: string[] = ["PLAY", "时空树仓库", "SETTINGS"];
    const btnTex = loadTex(TECH_BTN_PATH);
    if (btnTex !== undefined) {
      this.menuBtnW = btnTex.width;
      this.menuBtnH = btnTex.height;
    }
    const menuX = left + MENU_X_OFF;
    for (let i = 0; i < MENU_YS.length; i++) {
      const item = Node();
      item.position = Vec2(menuX, -h / 2 + MENU_YS[i]);
      item.addTo(this.titleNode);
      const d = DrawNode();
      d.addTo(item);
      this.menuDraws.push(d);
      if (btnTex !== undefined) {
        const sp = Sprite(btnTex);
        if (sp !== undefined) {
          sp.anchor = Vec2(0.5, 0.5);
          sp.position = Vec2(0, 0);
          sp.scaleX = MENU_W / this.menuBtnW;
          sp.scaleY = MENU_H / this.menuBtnH;
          sp.opacity = 0.8; // 全息按钮半透明，不挡封面
          sp.addTo(item);
          this.menuBtns.push(sp);
          this.menuBtnOk.push(true);
        } else {
          this.menuBtnOk.push(false);
        }
      } else {
        this.menuBtnOk.push(false);
      }
      const lb = makeLabel(item, 27, 0, 0, 0.5, 0.5, ink(255, 255, 255, 255));
      setText(lb, menuTexts[i]);
      if (lb !== undefined) {
        this.menuLbs.push(lb);
      }
    }
    // 缓落光点
    this.particlesDraw = DrawNode();
    this.particlesDraw.addTo(this.titleNode);
    for (let i = 0; i < TITLE_PARTICLE_N; i++) {
      this.particles.push({
        x: left + 90 + ((w - 180) / TITLE_PARTICLE_N) * i + Math.random() * 60,
        y: -top + Math.random() * h,
        vy: -(14 + Math.random() * 14),
        r: 2 + Math.random() * 1.6,
        ph: Math.random() * Math.PI * 2,
        gold: i % 2 === 0,
      });
    }
    // SETTINGS 键位面板：科技风框体（半透明暗底+角框），先建后藏
    this.settingsNode = Node();
    this.settingsNode.addTo(this.titleNode);
    this.settingsNode.visible = false;
    makeTechPanel(this.settingsNode, PANEL_W, PANEL_H);
    const panelBg = DrawNode();
    panelBg.addTo(this.settingsNode);
    this.makePanelLabel(panelBg, 24, 0, PANEL_H / 2 - 44, "操 作 键 位", ink(255, 255, 255, 255));
    for (let i = 0; i < SETTINGS_KEYS.length; i++) {
      this.makePanelLabel(panelBg, 19, 0, PANEL_H / 2 - 86 - i * 32, SETTINGS_KEYS[i], ink(255, 255, 255, 255));
    }
    this.makePanelLabel(panelBg, 16, 0, -PANEL_H / 2 + 34, "Esc 或再次点击 SETTINGS 关闭", ink(255, 255, 255, 255));
    // 标题态触摸：吞掉触摸，命中区域按文字外扩矩形
    const touchNode = Node();
    touchNode.size = Size(w, h);
    touchNode.position = Vec2(0, 0);
    touchNode.touchEnabled = true;
    touchNode.addTo(this.titleNode);
    touchNode.onTapBegan((touch) => {
      this.onTitleTap(touch, w, h);
    });
    // —— 序幕覆盖层：「游戏前情提要」视频（PLAY 后先播，见 playPrologue）——
    // 置于 titleNode 之上：黑色满屏底 + 非循环视频满屏铺底 + 底部跳过提示
    this.prologueNode = Node();
    this.prologueNode.addTo(parent);
    this.prologueNode.visible = false;
    this.prologueBlack = DrawNode();
    this.prologueBlack.addTo(this.prologueNode);
    this.prologueBlack.drawPolygon(this.screenVerts(w, h), Color(0, 0, 0, 255));
    if (Content.exist(PROLOGUE_VIDEO_FILE)) {
      const pv = VideoNode(PROLOGUE_VIDEO_FILE, false); // 非循环：播完 paused 变 true
      if (pv !== undefined) {
        const pvw = pv.width;
        const pvh = pv.height;
        if (pvw > 0 && pvh > 0) {
          const ps = Math.max(w / pvw, h / pvh); // 满屏铺底：等比取大
          pv.anchor = Vec2(0.5, 0.5);
          pv.position = Vec2(0, 0);
          pv.scaleX = ps;
          pv.scaleY = ps;
        }
        // 速度修复：VideoNode 创建即自动解码且隐藏时照常推进（探针实测 createdPaused=false），
        // 必须立即暂停：否则序幕视频从启动起就在封面底下持续解码（双解码抢性能→封面慢放），
        // 且点 PLAY 时已播到中途，与从头播的配轨音频错位；playPrologue 里 resume() 才真正起播
        pv.pause();
        pv.visible = true;
        pv.addTo(this.prologueNode);
        this.prologueVideo = pv;
      }
    }
    // 尾幕题名卡（2026-10-26）：视频素材末尾约 5s 为黑场淡出，仅保尾帧观感仍是
    // 「画面先于声音结束」。自然播完即切黑底淡入题名，让画面覆盖到余音结束。
    this.prologueCard = Node();
    this.prologueCard.visible = false;
    this.prologueCard.renderOrder = 10; // 高于尾幕动态封面视频（默认 0），保证金字叠在画面上
    this.prologueCard.addTo(this.prologueNode);
    const cardBg = DrawNode();
    cardBg.addTo(this.prologueCard);
    cardBg.drawPolygon(this.screenVerts(w, h), Color(0, 0, 0, 255));
    this.prologueCardBg = cardBg;
    this.prologueCardTitle = makeLabel(this.prologueCard, 46, 0, 52, 0.5, 0.5, ink(255, 236, 200, 255));
    if (this.prologueCardTitle !== undefined) {
      setText(this.prologueCardTitle, "衍 月 · 八 相");
      this.prologueCardTitle.opacity = 0;
    }
    this.prologueCardSub = makeLabel(this.prologueCard, 21, 0, -14, 0.5, 0.5, ink(255, 255, 255, 255));
    if (this.prologueCardSub !== undefined) {
      setText(this.prologueCardSub, "以八相为约 · 满月为限");
      this.prologueCardSub.opacity = 0;
    }
    this.prologueHintLb = makeLabel(this.prologueNode, 18, 0, -h / 2 + 34, 0.5, 0.5, ink(255, 255, 255, 255));
    setText(this.prologueHintLb, "Esc / 点击画面跳过");
    const prologueTouch = Node();
    prologueTouch.size = Size(w, h);
    prologueTouch.position = Vec2(0, 0);
    prologueTouch.touchEnabled = true;
    prologueTouch.addTo(this.prologueNode);
    prologueTouch.onTapBegan(() => {
      this.finishPrologue();
    });
    this.prologueNode.onKeyDown((key) => {
      if (this.prologuePlaying && (key === KeyName.Escape || key === KeyName.Space || key === KeyName.Return)) {
        this.finishPrologue();
      }
    });
    // 暂停层：与封面 SETTINGS 面板同款科技风框体（用户要求暂停 UI 与封面设置 UI 一致）
    this.pauseNode = Node();
    this.pauseNode.addTo(parent);
    this.pauseNode.visible = false;
    makeTechPanel(this.pauseNode, PANEL_W, PANEL_H);
    const pausePanel = DrawNode();
    pausePanel.addTo(this.pauseNode);
    this.makePanelLabel(pausePanel, 24, 0, PANEL_H / 2 - 44, "暂 停", ink(255, 255, 255, 255));
    for (let i = 0; i < PAUSE_KEYS.length; i++) {
      this.makePanelLabel(pausePanel, 18, 0, PANEL_H / 2 - 88 - i * 28, PAUSE_KEYS[i], ink(255, 255, 255, 255));
    }
    // 「回到标题」可点按钮（用户需求：暂停处增加回到标题选项，点击回标题封面）
    this.makePanelLabel(pausePanel, 20, 0, -172, "【 回到标题 】", ink(255, 236, 200, 255));
    this.makePanelLabel(pausePanel, 16, 0, -206, "Esc 继续游戏", ink(255, 255, 255, 255));
    // 暂停层触摸：全屏吞触摸，仅命中「回到标题」按钮区（屏幕中心坐标系）
    const pauseTouch = Node();
    pauseTouch.size = Size(w, h);
    pauseTouch.position = Vec2(0, 0);
    pauseTouch.touchEnabled = true;
    pauseTouch.addTo(this.pauseNode);
    pauseTouch.onTapBegan((touch) => {
      const local = touch.location;
      const cx = local.x - w / 2;
      const cy = local.y - h / 2;
      if (Math.abs(cx) <= 160 && cy >= -194 && cy <= -150 && this.onReturnTitle !== undefined) {
        this.onReturnTitle();
      }
    });
  }

  private rectVerts(x: number, y: number, w: number, h: number): Vec2.Type[] {
    return [Vec2(x, y), Vec2(x + w, y), Vec2(x + w, y + h), Vec2(x, y + h)];
  }

  private screenVerts(w: number, h: number): Vec2.Type[] {
    return this.rectVerts(-w / 2, -h / 2, w, h);
  }

  private circle(draw: DrawNode.Type, cx: number, cy: number, r: number, segs: number, width: number, color: InkColor, from: number, sweep: number): void {
    for (let i = 0; i < segs; i++) {
      const a0 = from + (i / segs) * sweep;
      const a1 = from + ((i + 1) / segs) * sweep;
      draw.drawSegment(Vec2(cx + Math.cos(a0) * r, cy + Math.sin(a0) * r), Vec2(cx + Math.cos(a1) * r, cy + Math.sin(a1) * r), width, col(color));
    }
  }

  private diamond(draw: DrawNode.Type, x: number, y: number, s: number, fill: InkColor, bw: number, border: InkColor): void {
    draw.drawPolygon([Vec2(x, y + s), Vec2(x + s, y), Vec2(x, y - s), Vec2(x - s, y)], col(fill), bw, col(border));
  }

  private makeTitleFontLabel(parent: Node.Type, size: number, x: number, y: number): Label.Type | undefined {
    for (let i = 0; i < TITLE_FONTS.length; i++) {
      const lb = Label(TITLE_FONTS[i], size);
      if (lb !== undefined) {
        lb.anchor = Vec2(0.5, 0.5);
        lb.position = Vec2(x, y);
        lb.addTo(parent);
        return lb;
      }
    }
    return makeLabel(parent, size - 4, x, y, 0.5, 0.5, Palette.paleInk);
  }

  private makeWheelSprite(tex: Texture2D.Type, scale: number): Sprite.Type | undefined {
    const sp = Sprite(tex);
    if (sp === undefined) {
      return undefined;
    }
    sp.anchor = Vec2(0.5, 0.5);
    sp.scaleX = scale;
    sp.scaleY = scale;
    sp.visible = false;
    sp.addTo(this.hudNode);
    return sp;
  }

  private makePanelLabel(parent: Node.Type, size: number, x: number, y: number, text: string, c: InkColor): void {
    let lb = Label(PANEL_FONT, size);
    if (lb === undefined) {
      lb = makeLabel(parent, size, x, y, 0.5, 0.5, c);
    } else {
      lb.anchor = Vec2(0.5, 0.5);
      lb.position = Vec2(x, y);
      lb.color = Color(c.r, c.g, c.b, c.a);
      lb.addTo(parent);
    }
    setText(lb, text);
  }

  // 像素心形 + 程序绘制封闭矩形血条；心形纹理缺失才回退程序化菱形
  private updatePixelLife(st: LoopState, x0: number, rowY: number): boolean {
    if (this.heartTex === undefined) {
      return false;
    }
    const bottomY = rowY - 24;
    // 整改三：HP 上限最多 8 格——超过 5 格压缩心距，血条起点按有效心距推算（旧实现硬编码 3 心位）
    const step = st.maxLife > 5 ? 36 : HEART_STEP;
    const barX = x0 + Math.min(st.maxLife, HUD_MAX_HEARTS) * step + 16;
    const ratio = st.maxLife > 0 ? Math.max(0, Math.min(1, st.heroineLife / st.maxLife)) : 0;
    for (let i = 0; i < this.heartSps.length; i++) {
      const sp = this.heartSps[i];
      const active = i < st.maxLife;
      sp.visible = active;
      if (active) {
        sp.position = Vec2(x0 + i * step, bottomY);
        sp.color = i < st.heroineLife ? Color(255, 255, 255, 255) : Color(255, 255, 255, 70);
      }
    }
    this.hud.drawPolygon(this.rectVerts(barX, bottomY, BAR_W, BAR_H), col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 245)), 2, col(Palette.inkDark));
    if (ratio > 0) {
      const fw = (BAR_W - BAR_PAD * 2) * ratio;
      this.hud.drawPolygon(this.rectVerts(barX + BAR_PAD, bottomY + BAR_PAD, fw, BAR_H - BAR_PAD * 2), col(Palette.vermilion));
    }
    return true;
  }

  // 程序水墨标题底（封面缺失时的回退）
  private drawTitleBg(w: number, h: number): void {
    this.titleBg.clear();
    this.titleBg.drawPolygon(this.screenVerts(w, h), Palette.paper);
    const mx = w / 2 - 190;
    const my = h / 2 - 170;
    this.circle(this.titleBg, mx, my, 96, 40, 2, Palette.goldSoft, 0, Math.PI * 2);
    this.titleBg.drawDot(Vec2(mx, my), 84, col(Palette.moonWhite));
    for (let i = 0; i < 4; i++) {
      const x0 = -w / 2 + i * (w / 3.2);
      this.titleBg.drawSegment(Vec2(x0, -h / 2 + 40 + i * 14), Vec2(x0 + w / 3.6, -h / 2 + 26 + i * 14), 26 + i * 8, col(Palette.paleInkFar));
    }
  }

  // 标题触摸命中：以菜单项中心为基准的文字外扩矩形
  private onTitleTap(touch: Touch.Type, w: number, h: number): void {
    if (!this.titleMenuEnabled) {
      return;
    }
    const x = touch.location.x - w / 2;
    const y = touch.location.y - h / 2;
    const menuX = -w / 2 + MENU_X_OFF;
    for (let i = 0; i < MENU_YS.length; i++) {
      const yy = -h / 2 + MENU_YS[i];
      if (Math.abs(x - menuX) <= MENU_HALF_X && Math.abs(y - yy) <= MENU_HALF_Y) {
        if (this.settingsOpen) {
          if (i === 2) {
            this.closeSettings();
          }
          return;
        }
        if (this.menuSel === i) {
          this.confirmCurrent();
        } else {
          this.menuSel = i;
        }
        return;
      }
    }
  }

  private confirmCurrent(): void {
    if (this.playLock) {
      return;
    }
    if (this.menuSel === 0) {
      this.playLock = true;
      this.menuFlashT = MENU_FLASH_T;
      const cb = this.onPlayConfirmed;
      if (cb !== undefined) {
        cb();
      }
    } else if (this.menuSel === 1) {
      const gb = this.onGalleryConfirmed;
      if (gb !== undefined) {
        gb();
      }
    } else {
      this.openSettings();
    }
  }

  private openSettings(): void {
    this.settingsOpen = true;
    this.settingsNode.visible = true;
  }

  private closeSettings(): void {
    this.settingsOpen = false;
    this.settingsNode.visible = false;
  }

  flashDamage(): void {
    this.flashTimer = FLASH_TIME;
  }

  setRewind(v: number): void {
    this.rewindV = v;
    if (this.rewindLb !== undefined) {
      this.rewindLb.visible = v >= 0;
    }
  }

  showEnding(id: string): void {
    const e = ENDINGS[id];
    if (e === undefined) {
      return;
    }
    const w = View.size.width;
    const h = View.size.height;
    this.endingBg.clear();
    this.endingBg.drawPolygon(this.screenVerts(w, h), col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 242)));
    this.endingBg.drawPolygon(this.rectVerts(-w / 2 + 14, -h / 2 + 14, w - 28, h - 28), col(NO_FILL), 1, col(Palette.goldSoft));
    setText(this.endingTitleLb, e.title);
    for (let i = 0; i < this.endingLineLbs.length; i++) {
      setText(this.endingLineLbs[i], i < e.lines.length ? e.lines[i] : "");
    }
    // 结局插图：按候选路径找到第一张存在的图；「cover 最短边贴满屏幕」等比铺底（可整幅覆盖旧结局背景），
    // z 序在 endingBg 之上、文字之下；全部缺图时保持原纯排版结局页
    const cands = ENDING_IMAGES[id];
    if (cands !== undefined) {
      let tex: Texture2D.Type | undefined;
      let used = "";
      for (const p of cands) {
        tex = Texture2D(p);
        if (tex !== undefined) {
          used = p;
          break;
        }
      }
      if (tex !== undefined && used !== "") {
        if (this.endingSp === undefined || this.endingTexId !== used) {
          const oldSp = this.endingSp;
          if (oldSp !== undefined) {
            oldSp.removeFromParent(true);
          }
          this.endingSp = undefined;
          const sp = Sprite(tex);
          if (sp !== undefined) {
            sp.addTo(this.endingNode);
            sp.position = Vec2(0, 0);
            sp.anchor = Vec2(0.5, 0.5);
            this.endingSp = sp;
            this.endingTexId = used;
          }
        }
        if (this.endingSp !== undefined) {
          const iw = tex.width;
          const ih = tex.height;
          if (iw > 0 && ih > 0) {
            const s = Math.max(w / iw, h / ih);
            this.endingSp.scaleX = s;
            this.endingSp.scaleY = s;
          }
          this.endingSp.visible = true;
        }
      } else {
        if (this.endingSp !== undefined) {
          this.endingSp.visible = false;
        }
      }
    } else if (this.endingSp !== undefined) {
      this.endingSp.visible = false;
    }
    this.endingTapGuard = 0.8;
    this.endingNode.visible = true;
  }

  hideEnding(): void {
    this.endingNode.visible = false;
  }

  setTitleVisible(v: boolean): void {
    this.titleNode.visible = v;
    if (this.coverVideo !== undefined) {
      // 视频封面：标题显示时循环播放，进游戏后暂停解码省 CPU
      if (v) {
        this.coverVideo.resume();
      } else {
        this.coverVideo.pause();
      }
    }
    if (v) {
      // 重新进入标题时复位菜单状态，确保 onPlayConfirmed 每次进入仅触发一次
      this.playLock = false;
      this.menuSel = 0;
      this.menuFlashT = 0;
      if (this.settingsOpen) {
        this.closeSettings();
      }
    }
  }

  // 序幕播放：重建视频节点并靠「创建即自动播放」起播 → 自身 schedule 轮询视频状态；
  // 自然播完（起播后 paused 变 true）或玩家跳过（Esc/Space/Return/点击）→ finishPrologue
  // 创建并布局序幕视频节点；靠「创建即自动播放」从第 0 帧起播（绝不 pause，见 playPrologue 注）
  private createPrologueVideo(): VideoNode.Type | undefined {
    const pv = VideoNode(PROLOGUE_VIDEO_FILE, false);
    if (pv === undefined) {
      return undefined;
    }
    const vw = View.size.width;
    const vh = View.size.height;
    if (pv.width > 0 && pv.height > 0) {
      const ps = Math.max(vw / pv.width, vh / pv.height); // 满屏铺底：等比取大
      pv.anchor = Vec2(0.5, 0.5);
      pv.position = Vec2(0, 0);
      pv.scaleX = ps;
      pv.scaleY = ps;
    }
    pv.visible = true;
    pv.addTo(this.prologueNode);
    this.prologueVideo = pv;
    return pv;
  }

  playPrologue(onDone: () => void): void {
    // 起播前重建：Theora 无 seek/reset，播完后 resume 不保证从头重播；重建后靠 VideoNode
    // 「创建即自动播放」从第 0 帧起播。不要对新节点 pause 再 resume——实测（2026 用户报
    // 声音正常画面卡死）：创建后立即 pause 会让后续 resume 只翻标志位、画面不解码
    const oldVid = this.prologueVideo;
    if (oldVid !== undefined) {
      oldVid.removeFromParent();
      this.prologueVideo = undefined;
    }
    if (this.prologuePlaying) {
      return; // 幂等：已在播放中忽略重复触发
    }
    this.prologuePlaying = true;
    this.prologueStarted = false;
    this.prologueWaitT = 0;
    this.prologueDelayT = 0;
    this.prologueTailT = 0;
    if (this.prologueCard !== undefined) {
      this.prologueCard.visible = false;
    }
    if (this.prologueCardTitle !== undefined) {
      this.prologueCardTitle.opacity = 0;
    }
    if (this.prologueCardSub !== undefined) {
      this.prologueCardSub.opacity = 0;
    }
    // 尾幕动态封面视频：每次起播前清掉旧节点（Theora 无 seek，下次尾段重建即自动从头播）
    const oldTailVid = this.prologueCoverVideo;
    if (oldTailVid !== undefined) {
      oldTailVid.removeFromParent();
      this.prologueCoverVideo = undefined;
    }
    this.prologueCoverFailed = false;
    if (this.prologueCardBg !== undefined) {
      this.prologueCardBg.visible = true; // 先恢复黑底；尾段封面视频就绪后再隐藏
    }
    this.prologueOnDone = onDone;
    this.prologueNode.visible = true;
    // 慢放修复：暂停标题封面循环视频，避免两个 Theora 解码器并发抢性能；收尾按需恢复
    const coverVid = this.coverVideo;
    if (coverVid !== undefined) {
      coverVid.pause();
    }
    // 声音修复：VideoNode 不出声，存在配轨文件则停掉封面 BGM 换播视频音频
    this.prologueAudio = "";
    for (let i = 0; i < PROLOGUE_AUDIO_FILES.length; i++) {
      const f = PROLOGUE_AUDIO_FILES[i];
      if (Content.exist(f)) {
        this.prologueAudio = f;
        break;
      }
    }
    if (this.prologueAudio !== "") {
      stopBgm(0.15);
      try {
        Audio.playStream(this.prologueAudio, false, 0.15);
      } catch (e) {
        void e; // 无音频设备时静默降级
      }
    }
    // 两段式调度（音画同步修复）：黑屏期只放配轨（playStream 开流有延迟），延迟
    // PROLOGUE_VIDEO_DELAY 再创建视频起播，画面不再抢在音频前；随后轮询自然播完
    this.prologueNode.schedule((dt: number) => {
      if (!this.prologuePlaying) {
        return true; // 已收尾：结束调度
      }
      if (this.prologueVideo === undefined) {
        this.prologueDelayT += dt;
        if (this.prologueDelayT < PROLOGUE_VIDEO_DELAY) {
          return false; // 黑屏等待期：音频先行
        }
        const pv = this.createPrologueVideo();
        if (pv === undefined) {
          this.finishPrologue(); // 素材缺失：走统一收尾链路，不阻断 PLAY
          return true;
        }
        this.prologueWaitT = 0;
        return false;
      }
      const video = this.prologueVideo;
      if (!this.prologueStarted) {
        if (!video.paused) {
          this.prologueStarted = true; // 已观察到起播
        } else {
          this.prologueWaitT += dt;
          if (this.prologueWaitT > PROLOGUE_START_TIMEOUT) {
            this.finishPrologue(); // 久未起播：按播完处理，防流程卡死
            return true;
          }
        }
      } else if (video.paused) {
        // 非循环视频自然播完：保住尾帧等配轨余音（画面比音频短约 5s，用户需求① 2026-10-26）；
        // 等待期间仍可 Esc/Space/Return/点击直接跳过（finishPrologue 不等余音）
        this.prologueTailT += dt;
        // 尾幕：自然播完才亮出（0.05s 防单帧误闪），1.2s 平方缓入；动态封面 + 题名卡
        // 覆盖素材尾部黑场，让真实画面持续到配轨余音结束（用户裁定 2026-10-26：纯黑底
        // 题名卡仍显「画面提早结束」，尾等待期必须有画面）
        const tailOn = this.prologueTailT > 0.05;
        if (this.prologueCard !== undefined) {
          this.prologueCard.visible = tailOn;
        }
        if (tailOn && this.prologueCoverVideo === undefined && !this.prologueCoverFailed && Content.exist(COVER_VIDEO_PIN)) {
          // 封面动画循环视频做尾幕动态背景：靠「创建即自动播放」起播（同 createPrologueVideo
          // 原理，规避 pause→resume 只翻标志位画面不解码的已知问题）；renderOrder 低于卡片
          const cv = VideoNode(COVER_VIDEO_PIN, true);
          if (cv !== undefined) {
            const cw = cv.width;
            const ch = cv.height;
            const vw = View.size.width;
            const vh = View.size.height;
            if (cw > 0 && ch > 0) {
              const cs = Math.max(vw / cw, vh / ch); // 满屏铺底：等比取大
              cv.anchor = Vec2(0.5, 0.5);
              cv.position = Vec2(0, 0);
              cv.scaleX = cs;
              cv.scaleY = cs;
            }
            cv.opacity = 0; // Node.opacity 范围 0~1（Dora.d.ts）
            cv.addTo(this.prologueNode);
            this.prologueCoverVideo = cv;
          } else {
            this.prologueCoverFailed = true; // 加载失败：保留黑底题名卡兑底，不再重试
          }
        }
        if (this.prologueCardBg !== undefined) {
          this.prologueCardBg.visible = this.prologueCoverVideo === undefined; // 封面在播则露画面，黑底只作兑底
        }
        const cardU = Math.min(1, this.prologueTailT / 1.2);
        const cardA = Math.round(cardU * cardU * 255);
        if (this.prologueCardTitle !== undefined) {
          this.prologueCardTitle.opacity = cardA;
        }
        if (this.prologueCardSub !== undefined) {
          this.prologueCardSub.opacity = cardA;
        }
        if (this.prologueCoverVideo !== undefined) {
          this.prologueCoverVideo.opacity = cardU * cardU; // 与题名卡同缓入（0~1）
        }
        if (this.prologueTailT >= PROLOGUE_AUDIO_TAIL) {
          this.finishPrologue();
          return true;
        }
        return false;
      } else {
        // 连续性保护：播放中偶发解码停顿不得累计尾等待，也不得残留题名卡
        this.prologueTailT = 0;
        if (this.prologueCard !== undefined) {
          this.prologueCard.visible = false;
        }
      }
      return false;
    });
  }

  // 幂等收尾：只触发一次 onDone；隐藏层并暂停视频解码；标题层保持原可见状态
  private finishPrologue(): void {
    if (!this.prologuePlaying) {
      return;
    }
    this.prologuePlaying = false;
    const cb = this.prologueOnDone;
    this.prologueOnDone = undefined;
    const video = this.prologueVideo;
    if (video !== undefined) {
      video.pause();
    }
    const tailVid = this.prologueCoverVideo;
    if (tailVid !== undefined) {
      tailVid.removeFromParent(); // 停止尾幕封面解码，避免与恢复中的封面循环视频抢性能
      this.prologueCoverVideo = undefined;
    }
    this.prologueNode.visible = false;
    // 配轨收尾：停视频音频并恢复封面 BGM（仅放过配轨才动过 BGM）；恢复封面视频循环解码
    if (this.prologueAudio !== "") {
      this.prologueAudio = "";
      try {
        Audio.stopStream(0.4);
      } catch (e) {
        void e;
      }
      playBgm("cover");
    }
    const coverVid = this.coverVideo;
    if (coverVid !== undefined && this.titleNode.visible) {
      coverVid.resume();
    }
    if (cb !== undefined) {
      cb();
    }
  }

  setPauseVisible(v: boolean): void {
    this.pauseNode.visible = v;
  }

  // 月相轮三态：恢复右上角显示（新精修贴图，槽位 WHEEL_PX）；贴图缺失时由 update 回退程序化圆环
  setMoonWheel(mode: "normal" | "active" | "dim"): void {
    this.wheelMode = mode;
    const nSp = this.wheelNormalSp;
    const aSp = this.wheelActiveSp;
    const dSp = this.wheelDimSp;
    if (nSp !== undefined && aSp !== undefined && dSp !== undefined) {
      nSp.visible = mode === "normal";
      aSp.visible = mode === "active";
      dSp.visible = mode === "dim";
    }
  }

  // 游戏层转发标题按键：仅 titleMenuEnabled 为 true 时处理；序幕播放中吞掉全部标题键
  handleTitleKey(key: KeyName): void {
    if (!this.titleMenuEnabled || this.prologuePlaying) {
      return;
    }
    if (key === KeyName.Escape) {
      if (this.settingsOpen) {
        this.closeSettings();
      }
      return;
    }
    if (this.settingsOpen) {
      // 面板打开时 PLAY 不可确认，仅 Esc（上方）或点击 SETTINGS 可关闭
      return;
    }
    const n = 3;
    if (key === KeyName.W || key === KeyName.Up) {
      this.menuSel = (this.menuSel + n - 1) % n;
    } else if (key === KeyName.S || key === KeyName.Down) {
      this.menuSel = (this.menuSel + 1) % n;
    } else if (key === KeyName.Return || key === KeyName.Space) {
      this.confirmCurrent();
    }
  }

  update(dt: number, args: HudArgs): void {
    const st = args.state;
    const w = View.size.width;
    const h = View.size.height;
    const top = h / 2;
    this.hud.clear();
    // 生命印记 + 剑意（像素心形/血条优先，纹理缺失回退程序化菱形）
    const baseX = -w / 2 + 44;
    const rowY = top - 44;
    const pxLife = this.updatePixelLife(st, baseX - 4, rowY);
    if (!pxLife) {
      for (let i = 0; i < st.maxLife; i++) {
        const x = baseX + i * 30;
        if (i < st.heroineLife) {
          this.diamond(this.hud, x, rowY, 12, Palette.vermilion, 2, Palette.inkDark);
        } else {
          this.diamond(this.hud, x, rowY, 12, NO_FILL, 2, Palette.inkFaint);
        }
      }
    }
    const ix0 = pxLife
      ? baseX - 4 + Math.min(st.maxLife, HUD_MAX_HEARTS) * (st.maxLife > 5 ? 36 : HEART_STEP) + 16 + BAR_W + 16
      : baseX + st.maxLife * 30 + 26;
    for (let i = 0; i < st.maxSwordIntent; i++) {
      const x = ix0 + i * 16;
      if (i < st.swordIntent) {
        this.hud.drawSegment(Vec2(x, rowY - 10), Vec2(x, rowY + 10), 4, col(Palette.moonCyan));
      } else {
        this.hud.drawSegment(Vec2(x, rowY - 10), Vec2(x, rowY + 10), 2, col(Palette.inkFaint));
      }
    }
    setText(this.phaseLb, st.phaseIndex >= 0 && st.phaseIndex < PHASE_NAMES.length ? PHASE_NAMES[st.phaseIndex] : "");
    setText(this.loopLb, "第" + (st.loopIndex + 1) + "周目");
    // 右上角「月相轮的指引」：任务紧贴标题正下方，当前指引跟随任务底部（句读断行）
    const missionLb = this.guideMissionLb;
    const stepLb = this.guideStepLb;
    setText(missionLb, wrapCjk("「" + args.floorName + "」" + args.mission, 13));
    setText(stepLb, wrapCjk(args.objective, 14));
    if (missionLb !== undefined && stepLb !== undefined) {
      const mh = missionLb.height;
      stepLb.y = missionLb.y - (mh > 0 ? mh : 30) - 8;
    }
    // 观星台（月夜）背景偏暗：指引面板三行文字切白色，其余层保持纯黑
    const gw = args.guideLight === true;
    if (gw !== this.guideWhite) {
      this.guideWhite = gw;
      const c = gw ? Color(255, 255, 255, 255) : Color(0, 0, 0, 255);
      if (this.guideTitleLb !== undefined) {
        this.guideTitleLb.color = c;
      }
      if (missionLb !== undefined) {
        missionLb.color = c;
      }
      if (stepLb !== undefined) {
        stepLb.color = c;
      }
    }
    setText(this.hintLb, args.hint);
    // Boss 血条
    const boss = args.boss;
    if (boss !== undefined && !boss.dead && boss.maxHp > 0) {
      const bw = 520;
      const bx = -bw / 2;
      const by = -top + 66;
      this.hud.drawPolygon(this.rectVerts(bx, by, bw, 12), col(NO_FILL), 2, col(Palette.inkDark));
      const frac = Math.max(0, Math.min(1, boss.hp / boss.maxHp));
      if (frac > 0) {
        this.hud.drawPolygon(this.rectVerts(bx + 2, by + 2, (bw - 4) * frac, 8), col(Palette.vermilion));
      }
    }
    // 月相轮三态（右上角）：按 wheelMode 切 visible；三图缺一用程序化圆环回退
    const wheelCx = w / 2 - 74;
    const wheelCy = top - 40;
    const nSp = this.wheelNormalSp;
    const aSp = this.wheelActiveSp;
    const dSp = this.wheelDimSp;
    if (nSp !== undefined && aSp !== undefined && dSp !== undefined) {
      nSp.position = Vec2(wheelCx, wheelCy);
      aSp.position = Vec2(wheelCx, wheelCy);
      dSp.position = Vec2(wheelCx, wheelCy);
      nSp.visible = this.wheelMode === "normal";
      aSp.visible = this.wheelMode === "active";
      dSp.visible = this.wheelMode === "dim";
      this.wheelDraw.clear();
    } else {
      this.wheelDraw.clear();
      this.circle(this.wheelDraw, wheelCx, wheelCy, 22, 28, 2, this.wheelMode === "active" ? Palette.moonWhite : Palette.gold, 0, Math.PI * 2);
    }
    // 受击红晕
    this.flash.clear();
    if (this.flashTimer > 0) {
      this.flashTimer = Math.max(0, this.flashTimer - dt);
      const a = Math.floor(255 * 0.35 * (this.flashTimer / FLASH_TIME));
      this.flash.drawPolygon(this.screenVerts(w, h), col(ink(Palette.vermilion.r, Palette.vermilion.g, Palette.vermilion.b, a)));
    }
    // 回溯遮罩 + 进度弧
    this.rewindDraw.clear();
    if (this.rewindV >= 0) {
      const v = Math.max(0, Math.min(1, this.rewindV));
      this.rewindDraw.drawPolygon(this.screenVerts(w, h), col(Palette.mist));
      this.circle(this.rewindDraw, 0, 0, 46, 36, 4, Palette.moonCyan, -Math.PI / 2, v * Math.PI * 2);
    }
    // 传送转场黑幕（整屏淡入淡出）
    if (args.fade !== undefined && args.fade > 0) {
      const f = Math.max(0, Math.min(1, args.fade));
      this.hud.drawPolygon(this.screenVerts(w, h), col(ink(6, 8, 16, Math.floor(255 * f))));
    }
    // 标题层特效：封面呼吸缩放 / 标题微光 / 菜单高亮 / 缓落光点
    if (this.titleNode.visible) {
      this.updateTitleEffects(dt, args.time, w, h);
    }
  }

  private updateTitleEffects(dt: number, time: number, w: number, h: number): void {
    if (this.coverSp !== undefined) {
      // 封面缓慢呼吸：锚点居中，1.0 → 1.03 循环
      const breath = 1 + 0.015 * (1 + Math.sin(time * 0.7));
      this.coverSp.scaleX = this.coverBaseScale * breath;
      this.coverSp.scaleY = this.coverBaseScale * breath;
    }
    if (this.titleNameLb !== undefined) {
      const a = 205 + Math.floor(50 * Math.sin(time * 2.2));
      this.titleNameLb.color = Color(255, 233, 172, a);
    }
    this.menuFlashT = Math.max(0, this.menuFlashT - dt);
    this.drawMenu(time);
    this.particlesDraw.clear();
    for (let i = 0; i < this.particles.length; i++) {
      const p = this.particles[i];
      p.y += p.vy * dt;
      if (p.y < -h / 2 - 12) {
        p.y = h / 2 + 12;
        p.x = -w / 2 + 40 + Math.random() * (w - 80);
      }
      const tw = 0.55 + 0.45 * Math.sin(time * 2 + p.ph);
      const a = Math.floor(210 * tw);
      this.particlesDraw.drawDot(Vec2(p.x, p.y), p.r + 1.4 * tw, p.gold ? Color(255, 216, 130, a) : Color(216, 230, 255, a));
    }
  }

  private drawMenu(time: number): void {
    let bi = 0;
    for (let i = 0; i < this.menuDraws.length; i++) {
      const d = this.menuDraws[i];
      const selected = i === this.menuSel && !this.settingsOpen;
      d.clear();
      if (this.menuBtnOk[i] === true) {
        const sp = this.menuBtns[bi];
        bi = bi + 1;
        if (sp !== undefined) {
          const s = selected ? 1.07 : 1;
          sp.scaleX = (MENU_W / this.menuBtnW) * s;
          sp.scaleY = (MENU_H / this.menuBtnH) * s;
          sp.opacity = selected ? 1 : 0.72; // 透明按钮：选中实、未选更透
        }
      } else if (selected) {
        // 贴图缺失回退：科技青描边（不再用旧黄框）
        d.drawPolygon(this.rectVerts(-MENU_W / 2, -MENU_H / 2, MENU_W, MENU_H), Color(96, 200, 255, 26), 2, Color(96, 200, 255, 220));
      }
      const lb = this.menuLbs[i];
      if (lb !== undefined) {
        if (selected) {
          const glow = 215 + Math.floor(40 * Math.sin(time * 3.4));
          const flash = this.menuFlashT > 0;
          lb.color = flash ? Color(255, 255, 255, 255) : Color(255, 255, 255, glow);
          lb.scaleX = 1.06;
          lb.scaleY = 1.06;
        } else {
          lb.color = Color(255, 255, 255, 205);
          lb.scaleX = 1;
          lb.scaleY = 1;
        }
      }
    }
  }
}
