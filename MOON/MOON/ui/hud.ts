// ui/hud.ts — 抬头显示：生命/剑意/月相轮/目标/提示/Boss血条/受击红晕/回溯遮罩/结局/标题/暂停
import { Color, DrawNode, Label, Node, Rect, Sprite, Texture2D, Vec2, View } from "Dora";
import { InkColor, Palette, ink } from "core/palette";
import { LoopState } from "core/types";
import { ENDINGS, PHASE_NAMES, UI_TEXT } from "data/story";
import { EnemyState } from "game/enemies";
import { Player } from "game/player";

const FONT = "sarasa-mono-sc-regular";
const NO_FILL = ink(0, 0, 0, 0);
// 像素素材：心形生命图标 + 血条外框/填充（Point 采样，整数倍放大）
const HEART_TEX = "assets/ui/icon_heart.png";
const FRAME_TEX = "assets/ui/bar_frame.png";
const FILL_TEX = "assets/ui/bar_fill_health.png";
const HEART_SCALE = 3;
const HEART_STEP = 52;
const BAR_SCALE = 3;
const FILL_SCALE_X = 11;
const FILL_SCALE_Y = 3;
const FILL_PAD_X = 8;
const FILL_PAD_Y = 9;
const HUD_MAX_HEARTS = 8;

function loadTex(path: string): Texture2D.Type | undefined {
  return Texture2D(path);
}

function pxSprite(tex: Texture2D.Type): Sprite.Type {
  const sp = Sprite(tex);
  sp.filter = "Point" as unknown as number;
  return sp;
}

function col(c: InkColor): Color.Type { return Color(c.r, c.g, c.b, c.a); }
const FLASH_TIME = 0.45;

export interface HudArgs {
  state: LoopState;
  player: Player;
  boss: EnemyState | undefined;
  objective: string;
  hint: string;
  time: number;
}

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

const PAUSE_KEYS: string[] = [
  "A / D　移动", "Space　跳跃 / 二段跳", "J　攻击", "K　剑气", "Shift　闪身", "W / S　攀爬",
  "E　交互", "Q　月相轮回", "N　引月札", "Tab　手札", "Esc　暂停",
];

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
  private pauseBg: DrawNode.Type;
  private objectiveLb: Label.Type | undefined;
  private hintLb: Label.Type | undefined;
  private phaseLb: Label.Type | undefined;
  private loopLb: Label.Type | undefined;
  private trustLb: Label.Type | undefined;
  private rewindLb: Label.Type | undefined;
  private endingTitleLb: Label.Type | undefined;
  private endingLineLbs: Label.Type[];
  private endingHintLb: Label.Type | undefined;
  private titleStartLb: Label.Type | undefined;
  private flashTimer: number;
  private rewindV: number;
  private heartTex: Texture2D.Type | undefined;
  private barTex: Texture2D.Type | undefined;
  private fillTex: Texture2D.Type | undefined;
  private heartSps: Sprite.Type[];
  private barFrameSp: Sprite.Type | undefined;
  private barFillSp: Sprite.Type | undefined;

  constructor(parent: Node.Type) {
    this.endingLineLbs = [];
    this.flashTimer = 0;
    this.rewindV = -1;
    this.hudNode = Node();
    this.hudNode.addTo(parent);
    this.flash = DrawNode();
    this.flash.addTo(this.hudNode);
    this.rewindDraw = DrawNode();
    this.rewindDraw.addTo(this.hudNode);
    this.hud = DrawNode();
    this.hud.addTo(this.hudNode);
    // 像素素材层：生命心形 + 血条（纹理加载失败则保持程序化画法）
    this.heartSps = [];
    this.heartTex = loadTex(HEART_TEX);
    this.barTex = loadTex(FRAME_TEX);
    this.fillTex = loadTex(FILL_TEX);
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
    if (this.barTex !== undefined && this.fillTex !== undefined) {
      const frame = pxSprite(this.barTex);
      frame.anchor = Vec2(0, 0);
      frame.scaleX = BAR_SCALE;
      frame.scaleY = BAR_SCALE;
      frame.addTo(this.hudNode);
      this.barFrameSp = frame;
      const fill = pxSprite(this.fillTex);
      fill.anchor = Vec2(0, 0);
      fill.scaleX = FILL_SCALE_X;
      fill.scaleY = FILL_SCALE_Y;
      fill.visible = false;
      fill.addTo(this.hudNode);
      this.barFillSp = fill;
    }
    const w = View.size.width;
    const h = View.size.height;
    const left = -w / 2;
    const top = h / 2;
    this.objectiveLb = makeLabel(this.hudNode, 20, left + 24, top - 92, 0, 0.5, Palette.paleInk);
    this.hintLb = makeLabel(this.hudNode, 18, 0, -top + 30, 0.5, 0.5, Palette.paleInkMid);
    this.rewindLb = makeLabel(this.hudNode, 26, 0, 96, 0.5, 0.5, Palette.moonCyan);
    setText(this.rewindLb, "回溯中…");
    if (this.rewindLb !== undefined) {
      this.rewindLb.visible = false;
    }
    const cx = w / 2 - 74;
    this.phaseLb = makeLabel(this.hudNode, 17, cx, top - 78, 0.5, 0.5, Palette.gold);
    this.loopLb = makeLabel(this.hudNode, 15, cx, top - 102, 0.5, 0.5, Palette.paleInk);
    this.trustLb = makeLabel(this.hudNode, 15, cx, top - 124, 0.5, 0.5, Palette.paleInk);
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
    setText(this.endingHintLb, "按 R 返回标题");
    // 标题层
    this.titleNode = Node();
    this.titleNode.addTo(parent);
    this.titleNode.visible = false;
    this.titleBg = DrawNode();
    this.titleBg.addTo(this.titleNode);
    const titleMain = makeLabel(this.titleNode, 76, 0, 80, 0.5, 0.5, Palette.inkDark);
    setText(titleMain, UI_TEXT.title);
    const titleSub = makeLabel(this.titleNode, 24, 0, -16, 0.5, 0.5, Palette.paleInk);
    setText(titleSub, UI_TEXT.subtitle);
    this.titleStartLb = makeLabel(this.titleNode, 24, 0, -110, 0.5, 0.5, Palette.inkSoft);
    setText(this.titleStartLb, "按任意键开始");
    this.drawTitleBg(w, h);
    // 暂停层
    this.pauseNode = Node();
    this.pauseNode.addTo(parent);
    this.pauseNode.visible = false;
    this.pauseBg = DrawNode();
    this.pauseBg.addTo(this.pauseNode);
    const pauseTitle = makeLabel(this.pauseNode, 28, 0, 166, 0.5, 0.5, Palette.inkDark);
    setText(pauseTitle, "暂停");
    for (let i = 0; i < PAUSE_KEYS.length; i++) {
      const lb = makeLabel(this.pauseNode, 18, 0, 96 - i * 30, 0.5, 0.5, Palette.inkSoft);
      if (lb !== undefined) {
        setText(lb, PAUSE_KEYS[i]);
      }
    }
    this.drawPauseBg(w, h);
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

  // 像素生命/血条：三张纹理齐全才启用；任一缺失返回 false 回退程序化菱形
  private updatePixelLife(st: LoopState, x0: number, rowY: number): boolean {
    if (this.heartTex === undefined || this.barFrameSp === undefined || this.barFillSp === undefined) {
      return false;
    }
    const bottomY = rowY - 24;
    const barX = x0 + 3 * HEART_STEP + 16;
    const ratio = st.maxLife > 0 ? Math.max(0, Math.min(1, st.heroineLife / st.maxLife)) : 0;
    for (let i = 0; i < this.heartSps.length; i++) {
      const sp = this.heartSps[i];
      const active = i < st.maxLife;
      sp.visible = active;
      if (active) {
        sp.position = Vec2(x0 + i * HEART_STEP, bottomY);
        sp.color = i < st.heroineLife ? Color(255, 255, 255, 255) : Color(255, 255, 255, 70);
      }
    }
    if (this.barFrameSp !== undefined) {
      this.barFrameSp.visible = true;
      this.barFrameSp.position = Vec2(barX, bottomY);
    }
    if (this.barFillSp !== undefined) {
      const rw = Math.round(16 * ratio);
      this.barFillSp.visible = rw > 0;
      if (rw > 0) {
        this.barFillSp.textureRect = Rect(0, 0, rw, 10);
        this.barFillSp.position = Vec2(barX + FILL_PAD_X, bottomY + FILL_PAD_Y);
      }
    }
    return true;
  }

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

  private drawPauseBg(w: number, h: number): void {
    this.pauseBg.clear();
    this.pauseBg.drawPolygon(this.screenVerts(w, h), col(Palette.inkWash));
    this.pauseBg.drawPolygon(this.rectVerts(-320, -220, 640, 440), col(Palette.paper), 2, col(Palette.inkDark));
    this.pauseBg.drawPolygon(this.rectVerts(-308, -208, 616, 416), col(NO_FILL), 1, col(Palette.goldSoft));
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
    this.endingNode.visible = true;
  }

  hideEnding(): void {
    this.endingNode.visible = false;
  }

  setTitleVisible(v: boolean): void {
    this.titleNode.visible = v;
  }

  setPauseVisible(v: boolean): void {
    this.pauseNode.visible = v;
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
    const ix0 = pxLife ? baseX - 4 + 3 * HEART_STEP + 16 + 64 * BAR_SCALE + 16 : baseX + st.maxLife * 30 + 26;
    for (let i = 0; i < st.maxSwordIntent; i++) {
      const x = ix0 + i * 16;
      if (i < st.swordIntent) {
        this.hud.drawSegment(Vec2(x, rowY - 10), Vec2(x, rowY + 10), 4, col(Palette.moonCyan));
      } else {
        this.hud.drawSegment(Vec2(x, rowY - 10), Vec2(x, rowY + 10), 2, col(Palette.inkFaint));
      }
    }
    // 月相轮（右上）
    const cx = w / 2 - 74;
    const cy = top - 40;
    this.circle(this.hud, cx, cy, 22, 28, 2, Palette.gold, 0, Math.PI * 2);
    const phase = st.phaseIndex;
    const illum = (1 - Math.cos((phase / 8) * Math.PI * 2)) / 2;
    if (phase === 0) {
      this.hud.drawDot(Vec2(cx, cy), 9, col(Palette.inkWash));
    } else {
      this.hud.drawDot(Vec2(cx, cy), 5 + 12 * illum, col(Palette.moonWhite));
      this.hud.drawDot(Vec2(cx + (phase < 4 ? 12 : -12), cy), 3, col(Palette.goldSoft));
    }
    setText(this.phaseLb, phase >= 0 && phase < PHASE_NAMES.length ? PHASE_NAMES[phase] : "");
    setText(this.loopLb, "第" + (st.loopIndex + 1) + "周目");
    // 沈砚信任：达成「终之相·望」需 ≥4，满信任后数字转青色提示
    const trust = st.shenyanTrust;
    setText(this.trustLb, "砚·信任 " + trust + " / 4");
    if (this.trustLb !== undefined) {
      this.trustLb.color = trust >= 4
        ? Color(Palette.moonCyan.r, Palette.moonCyan.g, Palette.moonCyan.b, 255)
        : Color(Palette.paleInk.r, Palette.paleInk.g, Palette.paleInk.b, 255);
    }
    // 目标 / 提示
    setText(this.objectiveLb, args.objective);
    setText(this.hintLb, args.hint);
    // Boss 血条
    const boss = args.boss;
    if (boss !== undefined && !boss.dead && boss.maxHp > 0) {
      const bw = 520;
      const bx = -bw / 2;
      const by = -h / 2 + 66;
      this.hud.drawPolygon(this.rectVerts(bx, by, bw, 12), col(NO_FILL), 2, col(Palette.inkDark));
      const frac = Math.max(0, Math.min(1, boss.hp / boss.maxHp));
      if (frac > 0) {
        this.hud.drawPolygon(this.rectVerts(bx + 2, by + 2, (bw - 4) * frac, 8), col(Palette.vermilion));
      }
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
    // 标题呼吸闪烁
    if (this.titleNode.visible && this.titleStartLb !== undefined) {
      const a = 150 + Math.floor(100 * Math.sin(args.time * 2.6));
      this.titleStartLb.color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, a);
    }
  }
}


