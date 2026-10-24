// scenes/intro.ts — 《衍月·八相》悲剧序章（黄昏像素视差背景 + 程序化水墨前景/回退）
// 时间轴总长约 24s，由游戏主循环调用 update(dt) 驱动累计时间 t。
import { Color, DrawNode, Keyboard, KeyName, Label, Node, Sprite, Texture2D, TextureFilter, Vec2, View } from "Dora";
import { InkColor, Palette } from "core/palette";
import { playBgm } from "game/audio";

export interface IntroHandle {
  update(dt: number): void;
  skip(): void;
  done(): boolean;
}

// ---------- 数学辅助（确定性，无 Math.random） ----------
const clamp = (v: number, lo: number, hi: number): number => Math.min(hi, Math.max(lo, v));
const lerp = (a: number, b: number, u: number): number => a + (b - a) * u;
const smooth = (a: number, b: number, t: number): number => {
  const u = clamp((t - a) / (b - a), 0, 1);
  return u * u * (3 - 2 * u);
};
// 固定种子伪随机（震屏抖动用，保证每次播放一致）
const hash = (n: number): number => {
  const s = Math.sin(n * 127.1 + 311.7) * 43758.5453;
  return s - Math.floor(s);
};

// InkColor -> Dora Color（DrawNode 绘图参数必须是 Color 实例）
const col = (c: InkColor, alphaMul?: number): Color.Type =>
  Color(c.r, c.g, c.b, Math.round(c.a * (alphaMul === undefined ? 1 : clamp(alphaMul, 0, 1))));

// 圆周点集（drawPolygon 填充近似圆）
const circlePts = (cx: number, cy: number, r: number, seg: number): Vec2.Type[] => {
  const pts: Vec2.Type[] = [];
  for (let i = 0; i < seg; i++) {
    const a = (i / seg) * Math.PI * 2;
    pts.push(Vec2(cx + Math.cos(a) * r, cy + Math.sin(a) * r));
  }
  return pts;
};

// 圆弧折线（drawSegment 多段近似圆环/弧）
const ring = (d: DrawNode.Type, cx: number, cy: number, r: number, seg: number, w: number,
  c: Color.Type, a0?: number, a1?: number): void => {
  const from = a0 === undefined ? 0 : a0;
  const to = a1 === undefined ? Math.PI * 2 : a1;
  let px = cx + Math.cos(from) * r;
  let py = cy + Math.sin(from) * r;
  for (let i = 1; i <= seg; i++) {
    const ang = from + ((to - from) * i) / seg;
    const nx = cx + Math.cos(ang) * r;
    const ny = cy + Math.sin(ang) * r;
    d.drawSegment(Vec2(px, py), Vec2(nx, ny), w, c);
    px = nx;
    py = ny;
  }
};

// 矩形 4 顶点（DrawNode 无 drawRect）
const rectPts = (x: number, y: number, w: number, h: number): Vec2.Type[] => [
  Vec2(x, y), Vec2(x + w, y), Vec2(x + w, y + h), Vec2(x, y + h),
];

// 扇形顶点（圆心 + 弧点，画弦月/凸月符号）
const sectorPts = (cx: number, cy: number, r: number, a0: number, a1: number, seg: number): Vec2.Type[] => {
  const pts: Vec2.Type[] = [Vec2(cx, cy)];
  for (let i = 0; i <= seg; i++) {
    const a = a0 + ((a1 - a0) * i) / seg;
    pts.push(Vec2(cx + Math.cos(a) * r, cy + Math.sin(a) * r));
  }
  return pts;
};

// ---------- 时间轴：总时长约 24 秒 ----------
const DURATION = 24;
// 底部字幕：阶段起止秒 + 文案（淡入 0.4s / 淡出 0.4s）
const SUBS: { from: number; to: number; text: string }[] = [
  { from: 0.2, to: 4.2, text: "那一夜，满月如盘。他死在我面前。" },
  { from: 4.4, to: 8.4, text: "我这一剑，斩得断强盗，斩不断天意。" },
  { from: 8.6, to: 13.0, text: "月亮把时间还给了我——以八相为约，满月为限。" },
  { from: 13.2, to: 17.4, text: "代价是，我的性命。每回溯一次，折损一分。" },
  { from: 17.6, to: 21.0, text: "而他忘记了我。连那枚糖人的约定，也一并忘了。" },
  { from: 21.2, to: 23.6, text: "没关系。这一次，换我用剑，护你周全。" },
];

export function createIntro(parent: Node.Type, onFinish: () => void): IntroHandle {
  // ---------- 布局常量（屏幕中心为原点，X 右 Y 上） ----------
  const W = View.size.width;
  const H = View.size.height;
  const MX = W / 2 - 190; // 右上月亮中心
  const MY = H / 2 - 150;
  const MR = 110; // 月亮半径
  const TX = W / 2 - 250; // 观星塔中轴
  const TBY = -H / 2 + 140; // 塔基高度
  const TTH = 300; // 塔身总高
  const TTY = TBY + TTH; // 塔顶平台
  const BANK = -H / 2 + 120; // 河岸高度
  const SUBY = -H / 2 + 90; // 字幕中心线
  const WHEEL_R = 95; // 月相轮半径

  // ---------- 节点层级：纸底/远景在 sceneRoot，特效与 UI 在上层 ----------
  const root = Node();
  root.addTo(parent);
  const sceneRoot = Node();
  sceneRoot.addTo(root);
  const bgDraw = DrawNode();
  bgDraw.addTo(sceneRoot);
  const sceneDraw = DrawNode();
  sceneDraw.addTo(sceneRoot);
  const fxDraw = DrawNode();
  fxDraw.addTo(root);
  const uiDraw = DrawNode();
  uiDraw.addTo(root);

  // ---------- 序章 BGM（进入序章即起播，game/audio 内部交叉淡入/无设备静默降级） ----------
  playBgm("dusk", 1.5);

  // ---------- 黄昏像素视差背景（assets/bg/dusk，任一贴图加载失败整体回退程序化水墨） ----------
  // 层序（底→顶）：sky → far_clouds → far_mountains → [月亮层] → mountains → near_clouds → trees
  interface DuskLayer {
    sprites: Sprite.Type[];
    tileW: number;
    speed: number;
  }
  const DUSK_DEFS: { file: string; speed: number }[] = [
    { file: "far_clouds.png", speed: 2 },
    { file: "far_mountains.png", speed: 1 },
    { file: "mountains.png", speed: 4 },
    { file: "near_clouds.png", speed: 7 },
    { file: "trees.png", speed: 10 },
  ];
  const duskRoot = Node();
  duskRoot.addTo(sceneRoot); // 先于 bgDraw 加入 → 处于场景最底层（随震屏一起抖动）
  const duskLayers: DuskLayer[] = [];
  const moonDraw = DrawNode(); // 场景 A 的满月/裂纹画层：远山之上、中山近树之下
  // 单层装载：纵向拉伸满屏高，横向等比平铺 ceil(视宽/层宽)+1 份，供漂移取模回卷
  const loadDuskLayer = (file: string, speed: number): boolean => {
    const tex = Texture2D("assets/bg/dusk/" + file);
    if (tex === undefined) return false;
    const sy = H / tex.height;
    const tileW = tex.width * sy;
    const count = Math.ceil(W / tileW) + 1;
    const sprites: Sprite.Type[] = [];
    for (let j = 0; j < count; j++) {
      const sp = Sprite(tex);
      sp.filter = TextureFilter.Point;
      sp.scaleX = sy;
      sp.scaleY = sy;
      sp.position = Vec2(-W / 2 + tileW / 2 + j * tileW, 0);
      sp.addTo(duskRoot);
      sprites.push(sp);
    }
    duskLayers.push({ sprites, tileW, speed });
    return true;
  };
  let duskOk = false;
  {
    const skyTex = Texture2D("assets/bg/dusk/sky.png");
    if (skyTex !== undefined) {
      const sky = Sprite(skyTex); // 天空底：单张直接拉伸覆盖全屏，不动
      sky.filter = TextureFilter.Point;
      sky.scaleX = W / skyTex.width;
      sky.scaleY = H / skyTex.height;
      sky.position = Vec2(0, 0);
      sky.addTo(duskRoot);
      duskOk = loadDuskLayer(DUSK_DEFS[0].file, DUSK_DEFS[0].speed)
        && loadDuskLayer(DUSK_DEFS[1].file, DUSK_DEFS[1].speed);
      moonDraw.addTo(duskRoot); // 满月层卡在 far_mountains 与 mountains 之间
      duskOk = duskOk && loadDuskLayer(DUSK_DEFS[2].file, DUSK_DEFS[2].speed)
        && loadDuskLayer(DUSK_DEFS[3].file, DUSK_DEFS[3].speed)
        && loadDuskLayer(DUSK_DEFS[4].file, DUSK_DEFS[4].speed);
    }
  }
  if (!duskOk) {
    duskLayers.length = 0;
    duskRoot.visible = false; // 整体回退：隐藏像素背景，render 走原程序化水墨路径
  }

  // ---------- 开场主视觉卡（素材整合：assets/art/yanyue-key-visual.png 2560×1506） ----------
  // 盖在程序化水墨场景之上：0-0.5s 淡入、3.6-5s 淡出交还场景；字幕/提示标签在 root 上层不受影响。
  // 贴图加载失败（headless 等）时保持 undefined，开场自动退回纯程序化水墨，不影响可玩性。
  let cardSp: Sprite.Type | undefined;
  const cardTex = Texture2D("assets/art/yanyue-key-visual.png");
  if (cardTex !== undefined) {
    const s = Math.max(W / cardTex.width, H / cardTex.height);
    const sp = Sprite(cardTex);
    sp.scaleX = s;
    sp.scaleY = s;
    sp.position = Vec2(0, 0);
    sp.opacity = 0;
    sp.visible = false;
    sp.addTo(sceneRoot);
    cardSp = sp;
  }

  // ---------- UI 标签（Label 工厂可能返回 undefined，全部判空） ----------
  const hintLb = Label("sarasa-mono-sc-regular", 15);
  if (hintLb !== undefined) {
    hintLb.text = "按 J 跳过序章";
    hintLb.color = col(Palette.paleInk);
    hintLb.anchor = Vec2(1, 0.5);
    hintLb.position = Vec2(W / 2 - 24, H / 2 - 26);
    hintLb.addTo(root);
  }
  const subLb = Label("sarasa-mono-sc-regular", 26);
  if (subLb !== undefined) {
    subLb.color = col(Palette.inkDark);
    subLb.anchor = Vec2(0.5, 0.5);
    subLb.position = Vec2(0, SUBY);
    subLb.addTo(root);
  }
  const BUBX = -150;
  const BUBY = BANK + 128;
  const bubLb = Label("sarasa-mono-sc-regular", 20);
  if (bubLb !== undefined) {
    bubLb.text = "你是谁？";
    bubLb.color = col(Palette.inkDark);
    bubLb.anchor = Vec2(0.5, 0.5);
    bubLb.position = Vec2(BUBX, BUBY);
    bubLb.addTo(root);
    bubLb.visible = false;
  }

  // ---------- 远景：山脊（sin 噪声山脊点 + 缓慢视差平移） ----------
  const ridgeY = (wx: number, base: number, amp: number, seed: number): number =>
    base + amp * (0.55 * Math.sin(wx * 0.0042 + seed)
      + 0.3 * Math.sin(wx * 0.0113 + seed * 2.1)
      + 0.15 * Math.sin(wx * 0.027 + seed * 0.7));
  const drawRidge = (d: DrawNode.Type, base: number, amp: number, seed: number, drift: number,
    c: Color.Type): void => {
    const pts: Vec2.Type[] = [];
    for (let x = -W / 2 - 60; x <= W / 2 + 60; x += 48) {
      pts.push(Vec2(x, ridgeY(x + drift, base, amp, seed)));
    }
    pts.push(Vec2(W / 2 + 60, -H / 2 - 80));
    pts.push(Vec2(-W / 2 - 60, -H / 2 - 80));
    d.drawPolygon(pts, c);
  };

  // 左下古镇屋顶剪影（连绵坡顶 + 一座小宝塔）
  const drawTown = (d: DrawNode.Type, c: Color.Type): void => {
    const y0 = -H / 2 + 96;
    const pts: Vec2.Type[] = [Vec2(-W / 2 - 40, y0)];
    let x = -W / 2 - 20;
    let i = 0;
    while (x < 40) {
      const w = 64 + hash(i * 5.7) * 26;
      const hgt = 22 + hash(i * 3.1) * 18;
      pts.push(Vec2(x + w * 0.5, y0 + hgt));
      pts.push(Vec2(x + w, y0 + 6));
      x += w;
      i++;
    }
    pts.push(Vec2(x, -H / 2 - 80));
    pts.push(Vec2(-W / 2 - 40, -H / 2 - 80));
    d.drawPolygon(pts, c);
    d.drawPolygon(rectPts(-W / 2 + 34, y0 + 6, 30, 74), c);
    d.drawPolygon([Vec2(-W / 2 + 24, y0 + 80), Vec2(-W / 2 + 74, y0 + 80), Vec2(-W / 2 + 49, y0 + 104)], c);
  };

  // 观星塔：多层收分塔身 + 纸色镂空窗 + 顶部亭子 + 左侧盘梯
  const drawTower = (d: DrawNode.Type, a: number): void => {
    if (a <= 0.01) return;
    const cBody = col(Palette.paleInkMid, a);
    const cTop = col(Palette.inkSoft, a);
    for (let i = 0; i < 5; i++) {
      const w = 150 - i * 20;
      const y = TBY + i * 56;
      const hw = w - 14;
      d.drawPolygon([
        Vec2(TX - w / 2, y), Vec2(TX + w / 2, y),
        Vec2(TX + hw / 2, y + 56), Vec2(TX - hw / 2, y + 56),
      ], cBody);
      d.drawPolygon(rectPts(TX - hw / 2 + 16, y + 32, hw - 32, 10), col(Palette.paper, a * 0.85));
    }
    const py = TBY + 5 * 56;
    d.drawPolygon(rectPts(TX - 95, py, 190, 10), cTop);
    d.drawPolygon([Vec2(TX - 100, py + 10), Vec2(TX + 100, py + 10), Vec2(TX + 30, py + 46), Vec2(TX - 30, py + 46)], cTop);
    d.drawSegment(Vec2(TX, py + 46), Vec2(TX, py + 66), 4, cTop);
    d.drawDot(Vec2(TX, py + 70), 5, cTop);
    const stC = col(Palette.inkSoft, a * 0.7);
    d.drawSegment(Vec2(TX - 96, TBY + 4), Vec2(TX - 60, TBY + 56), 3, stC);
    d.drawSegment(Vec2(TX - 60, TBY + 56), Vec2(TX - 96, TBY + 112), 3, stC);
    d.drawSegment(Vec2(TX - 96, TBY + 112), Vec2(TX - 60, TBY + 168), 3, stC);
    d.drawSegment(Vec2(TX - 60, TBY + 168), Vec2(TX - 96, TBY + 224), 3, stC);
    d.drawSegment(Vec2(TX - 96, TBY + 224), Vec2(TX - 40, py + 4), 3, stC);
  };

  // ---------- 人物剪影（浓墨 drawSegment/圆点组成） ----------
  type Pose = "walk" | "stand" | "push" | "kneel" | "lie" | "back";
  const drawFigure = (d: DrawNode.Type, x: number, y: number, s: number, a: number,
    female: boolean, pose: Pose): void => {
    if (a <= 0.01) return;
    const c = col(Palette.inkDark, a);
    const lw = 3 * s;
    const seg = (x1: number, y1: number, x2: number, y2: number): void => {
      d.drawSegment(Vec2(x + x1 * s, y + y1 * s), Vec2(x + x2 * s, y + y2 * s), lw, c);
    };
    if (pose === "lie") {
      d.drawDot(Vec2(x - 16 * s, y + 5 * s), 4.5 * s, c);
      seg(-10, 5, 14, 7);
      seg(14, 7, 32, 3);
      seg(-10, 6, 6, 12);
      return;
    }
    if (pose === "kneel") {
      d.drawDot(Vec2(x, y + 24 * s), 4.5 * s, c);
      seg(0, 20, 0, 8);
      seg(0, 8, -8, 2);
      seg(0, 8, 6, 1);
      seg(0, 17, 9, 9);
      seg(0, 15, -7, 9);
      if (female) d.drawSegment(Vec2(x - 3 * s, y + 26 * s), Vec2(x - 9 * s, y + 18 * s), lw * 0.9, c);
      return;
    }
    d.drawDot(Vec2(x, y + 30 * s), 4.5 * s, c);
    seg(0, 26, 0, 12);
    if (pose === "walk") {
      seg(0, 12, -7 * s, 0);
      seg(0, 12, 7 * s, 0);
      seg(0, 23, -6 * s, 16);
      seg(0, 23, 6 * s, 17);
    } else if (pose === "push") {
      seg(0, 12, -6 * s, 0);
      seg(0, 12, 6 * s, 0);
      seg(0, 24, 12 * s, 22);
      seg(0, 22, 13 * s, 18);
    } else {
      seg(0, 12, -5 * s, 0);
      seg(0, 12, 5 * s, 0);
      seg(0, 23, -6 * s, 15);
      seg(0, 23, 6 * s, 15);
    }
    if (female) {
      d.drawSegment(Vec2(x - 3 * s, y + 32 * s), Vec2(x - 10 * s, y + 24 * s), lw * 0.9, c);
      d.drawSegment(Vec2(x + 7 * s, y + 16 * s), Vec2(x + 16 * s, y + 4 * s), 2 * s, col(Palette.paleInk, a));
      d.drawDot(Vec2(x + 8 * s, y + 17 * s), 1.8 * s, c);
    } else if (pose === "back") {
      d.drawSegment(Vec2(x - 6 * s, y + 8 * s), Vec2(x + 8 * s, y + 30 * s), 2 * s, col(Palette.paleInk, a));
    } else {
      d.drawDot(Vec2(x, y + 34 * s), 2 * s, c);
    }
  };

  // 黑衣强盗剪影（黑袍多边形 + 头 + 前伸手臂）
  const drawBandit = (d: DrawNode.Type, x: number, y: number, s: number, a: number): void => {
    if (a <= 0.01) return;
    const c = col(Palette.inkDark, a);
    d.drawPolygon([
      Vec2(x - 12 * s, y), Vec2(x + 12 * s, y),
      Vec2(x + 6 * s, y + 26 * s), Vec2(x - 4 * s, y + 26 * s),
    ], c);
    d.drawDot(Vec2(x + 1 * s, y + 30 * s), 4.5 * s, c);
    d.drawSegment(Vec2(x - 2 * s, y + 26 * s), Vec2(x - 9 * s, y + 13 * s), 3 * s, c);
  };

  // 塔身盘梯路径（两个小人 3.5-8s 沿此向上）
  const climbPath: Vec2.Type[] = [
    Vec2(TX - 108, TBY + 6), Vec2(TX - 72, TBY + 56), Vec2(TX - 108, TBY + 112),
    Vec2(TX - 72, TBY + 168), Vec2(TX - 108, TBY + 224), Vec2(TX - 26, TTY + 6),
  ];
  const pathPos = (p: number): { x: number; y: number } => {
    const u = clamp(p, 0, 1) * (climbPath.length - 1);
    const i = Math.min(Math.floor(u), climbPath.length - 2);
    const f = u - i;
    return { x: lerp(climbPath[i].x, climbPath[i + 1].x, f), y: lerp(climbPath[i].y, climbPath[i + 1].y, f) };
  };

  // 渐伸折线：按进度 u 从起点画到部分长度（裂纹生长用）
  const drawPolyline = (d: DrawNode.Type, pts: Vec2.Type[], u: number, c: Color.Type, w: number): void => {
    const total = pts.length - 1;
    const f = clamp(u, 0, 1) * total;
    const full = Math.floor(f);
    for (let i = 0; i < full; i++) {
      d.drawSegment(pts[i], pts[i + 1], w, c);
    }
    if (full < total && full >= 0) {
      const fr = f - full;
      d.drawSegment(pts[full],
        Vec2(lerp(pts[full].x, pts[full + 1].x, fr), lerp(pts[full].y, pts[full + 1].y, fr)), w, c);
    }
  };

  // 月亮裂纹：主干自上而下 + 两条分支（确定性生成，8s 起生长）
  const crackMain: Vec2.Type[] = [];
  {
    let cx0 = MX + 8;
    let cy0 = MY + MR - 6;
    crackMain.push(Vec2(cx0, cy0));
    for (let i = 0; i < 6; i++) {
      cx0 += (i % 2 === 0 ? 14 : -18) + hash(i * 3.7) * 6;
      cy0 -= 26 + hash(i * 9.1) * 10;
      crackMain.push(Vec2(cx0, cy0));
    }
  }
  const crackBranch1: Vec2.Type[] = [
    Vec2(crackMain[2].x, crackMain[2].y),
    Vec2(crackMain[2].x + 22, crackMain[2].y - 18),
    Vec2(crackMain[2].x + 38, crackMain[2].y - 40),
  ];
  const crackBranch2: Vec2.Type[] = [
    Vec2(crackMain[4].x, crackMain[4].y),
    Vec2(crackMain[4].x - 24, crackMain[4].y - 16),
    Vec2(crackMain[4].x - 36, crackMain[4].y - 38),
  ];

  // 暗月光柱：从月亮射向目标点（暗金外晕 + 月白内芯，四边形多边形）
  const drawBeam = (d: DrawNode.Type, tx0: number, ty0: number, a: number): void => {
    if (a <= 0.01) return;
    const dx = tx0 - MX;
    const dy = ty0 - MY;
    const len = Math.sqrt(dx * dx + dy * dy);
    const ux = dx / len;
    const uy = dy / len;
    const px = -uy;
    const py = ux;
    const quad = (w0: number, w1: number, c: Color.Type): void => {
      d.drawPolygon([
        Vec2(MX + px * w0, MY + py * w0),
        Vec2(tx0 + px * w1, ty0 + py * w1),
        Vec2(tx0 - px * w1, ty0 - py * w1),
        Vec2(MX - px * w0, MY - py * w0),
      ], c);
    };
    quad(16, 40, col(Palette.goldSoft, a * 0.85));
    quad(7, 20, col(Palette.moonWhite, a));
  };

  // 暗金月相轮：大圆环 + 8 辐条 + 8 个月相符号，rot 随时间加速
  const drawWheel = (d: DrawNode.Type, cx: number, cy: number, rot: number, a: number): void => {
    if (a <= 0.01) return;
    ring(d, cx, cy, WHEEL_R, 24, 4, col(Palette.gold, a));
    ring(d, cx, cy, WHEEL_R - 16, 24, 2, col(Palette.goldSoft, a));
    for (let i = 0; i < 8; i++) {
      const ang = rot + (i / 8) * Math.PI * 2;
      const ca = Math.cos(ang);
      const sa = Math.sin(ang);
      d.drawSegment(
        Vec2(cx + ca * 22, cy + sa * 22),
        Vec2(cx + ca * (WHEEL_R - 4), cy + sa * (WHEEL_R - 4)), 3, col(Palette.gold, a));
      const sx = cx + ca * (WHEEL_R + 20);
      const sy = cy + sa * (WHEEL_R + 20);
      const ph = i % 4;
      if (ph === 0) {
        d.drawDot(Vec2(sx, sy), 3.5, col(Palette.inkDark, a)); // 新月：小圆点
      } else if (ph === 1) {
        d.drawPolygon(circlePts(sx, sy, 11, 16), col(Palette.moonWhite, a)); // 满月：小圆
        ring(d, sx, sy, 11, 12, 2, col(Palette.inkDark, a));
      } else if (ph === 2) {
        d.drawPolygon(sectorPts(sx, sy, 11, -Math.PI / 2, Math.PI / 2, 12), col(Palette.inkDark, a)); // 弦月：半圆
      } else {
        d.drawPolygon(sectorPts(sx, sy, 12, -Math.PI / 3, Math.PI + Math.PI / 3, 16), col(Palette.inkDark, a)); // 凸月：大半圆
      }
    }
    d.drawDot(Vec2(cx, cy), 11, col(Palette.gold, a));
    d.drawDot(Vec2(cx, cy), 26 + 6 * Math.sin(rot * 3), col(Palette.moonCyanSoft, a * 0.8));
    d.drawDot(Vec2(cx, cy), 46, col(Palette.moonCyanFaint, a * 0.7));
  };

  // 朱砂火把队伍：左山脊依次亮起，沿坡向观星塔移动，14.5s 后渐灭
  const torchPos = (i: number, tt: number): { x: number; y: number; a: number } => {
    const sx = -W / 2 + 50 + i * 26;
    const sy = BANK - 10 + i * 3;
    const ex = TX - 150 + i * 12;
    const ey = TBY + 10;
    const p = smooth(11 + i * 0.28, 13.6 + i * 0.12, tt);
    const on = smooth(11 + i * 0.28, 11.35 + i * 0.28, tt);
    const out = 1 - smooth(15.0, 15.8, tt);
    return { x: lerp(sx, ex, p), y: lerp(sy, ey, p) - p * 24, a: on * out };
  };

  // 重置后的河边场景：蛾眉月（满月叠偏移纸圆）+ 河岸 + 月光倒影 + 两岸人影
  const drawRiverside = (d: DrawNode.Type, a: number, tt: number): void => {
    if (a <= 0.01) return;
    d.drawDot(Vec2(MX, MY), MR + 55, col(Palette.moonHalo, a));
    d.drawPolygon(circlePts(MX, MY, MR, 32), col(Palette.moonWhite, a));
    d.drawDot(Vec2(MX - 34, MY + 12), MR - 6, col(Palette.paper)); // 偏移纸圆遮出蛾眉月
    drawRidge(d, H / 2 - 210, 55, 1.3, 24 + 6 * tt, col(Palette.paleInkFar, a));
    drawRidge(d, H / 2 - 140, 75, 4.2, 40 + 11 * tt, col(Palette.paleInkMid, a));
    d.drawPolygon(rectPts(-W / 2, BANK - 46, W, 46), col(Palette.moonCyanFaint, a * 0.9));
    d.drawSegment(Vec2(-W / 2, BANK), Vec2(W / 2, BANK), 4, col(Palette.inkSoft, a));
    for (let i = 0; i < 5; i++) {
      const ry = BANK - 8 - i * 9;
      const rw = 60 - i * 9;
      d.drawSegment(
        Vec2(MX - rw / 2 + i * 6, ry), Vec2(MX + rw / 2 + i * 6, ry),
        3, col(Palette.moonWhite, a * (0.75 - i * 0.12)));
    }
    const reeds = [-W / 2 + 90, -W / 2 + 120, -W / 2 + 150, W / 2 - 120, W / 2 - 90];
    for (let i = 0; i < reeds.length; i++) {
      const rx = reeds[i];
      d.drawSegment(
        Vec2(rx, BANK + 2),
        Vec2(rx + (i % 2 === 0 ? 8 : -8), BANK + 30 + (i % 3) * 8),
        2.5, col(Palette.inkSoft, a));
    }
    drawFigure(d, -170, BANK + 2, 1.15, a, false, "back");
    drawFigure(d, 150, BANK + 2, 1.1, a, true, "stand");
  };

  // 对话气泡：宣纸切角矩形 + 浓墨描边 + 三角尾巴（内文用 Label）
  const drawBubble = (d: DrawNode.Type, a: number): void => {
    if (a <= 0.01) return;
    const bw = 170;
    const bh = 58;
    const x0 = BUBX - bw / 2;
    const y0 = BUBY - bh / 2;
    const r = 10;
    const fill = col(Palette.paper, a);
    const outline = col(Palette.inkDark, a);
    d.drawPolygon(rectPts(x0, y0, bw, bh), fill);
    const border: Vec2.Type[] = [
      Vec2(x0, y0 + r), Vec2(x0 + r, y0), Vec2(x0 + bw - r, y0), Vec2(x0 + bw, y0 + r),
      Vec2(x0 + bw, y0 + bh - r), Vec2(x0 + bw - r, y0 + bh), Vec2(x0 + r, y0 + bh),
      Vec2(x0, y0 + bh - r), Vec2(x0, y0 + r),
    ];
    for (let i = 0; i < border.length - 1; i++) {
      d.drawSegment(border[i], border[i + 1], 2.5, outline);
    }
    d.drawPolygon([Vec2(BUBX - 26, y0 + 1), Vec2(BUBX - 2, y0 + 1), Vec2(BUBX - 18, y0 - 20)], fill);
    d.drawSegment(Vec2(BUBX - 26, y0 + 1), Vec2(BUBX - 18, y0 - 20), 2.5, outline);
    d.drawSegment(Vec2(BUBX - 18, y0 - 20), Vec2(BUBX - 2, y0 + 1), 2.5, outline);
  };

  // 墨色径向擦除半径：20.5-21.45 从中心扩散覆盖，21.55-22.4 收开
  const SCENE_B = 21.45; // 完全遮黑的瞬间切到河边场景
  const wipeRadius = (tt: number): number => {
    const maxR = Math.sqrt((W / 2) * (W / 2) + (H / 2) * (H / 2)) + 30;
    if (tt < SCENE_B) return maxR * smooth(20.5, SCENE_B, tt);
    return maxR * (1 - smooth(21.55, 22.4, tt));
  };

  let t = 0;
  let finished = false;

  // 契约：时间轴走完后调用一次 onFinish()（内部保证只调一次），之后 done() 为 true；
  // 同时隐藏场景节点。主循环既可依赖 onFinish 回调，也可轮询 done() 自行衔接。
  const finalize = (): void => {
    if (finished) return;
    finished = true;
    root.visible = false;
    onFinish();
  };

  // 字幕透明度：淡入 0.4s，按 hold 停留，淡出 0.4s
  const subAlpha = (i: number): number => {
    const s = SUBS[i];
    return smooth(s.from, s.from + 0.4, t) * (1 - smooth(s.to - 0.4, s.to, t));
  };

  const render = (): void => {
    const fadeIn = smooth(0, 3.5, t);
    const sceneB = t >= SCENE_B;
    // 主视觉卡：开场展示后淡出，此后不再绘制
    if (cardSp !== undefined) {
      const ca = smooth(0, 0.5, t) * (1 - smooth(3.6, 5, t));
      cardSp.opacity = ca;
      cardSp.visible = ca > 0.02;
    }
    {
      // 像素黄昏底仅在场景 A 生效；scene B（黑场切换后的宣纸河边）整屏回退程序化水墨
      const useDusk = duskOk && !sceneB;
      duskRoot.visible = useDusk;
      if (useDusk) {
        // 视差漂移：offset = (speed * t) % tileW，各层向左循环回卷（方向向左）
        for (let i = 0; i < duskLayers.length; i++) {
          const L = duskLayers[i];
          const dx = (L.speed * t) % L.tileW;
          for (let j = 0; j < L.sprites.length; j++) {
            L.sprites[j].position = Vec2(-W / 2 + L.tileW / 2 + j * L.tileW - dx, 0);
          }
        }
      }
      bgDraw.clear();
      moonDraw.clear();
      // 像素底时满月/裂纹画进 moonDraw（远山之上、中山近树之下）；回退时仍画在 bgDraw
      const skyD = useDusk ? moonDraw : bgDraw;
      if (!useDusk) {
        bgDraw.drawPolygon(rectPts(-W / 2, -H / 2, W, H), col(Palette.paper));
      }
      if (!sceneB) {
        skyD.drawDot(Vec2(MX, MY), MR + 52, col(Palette.moonHalo, fadeIn));
        skyD.drawPolygon(circlePts(MX, MY, MR, 32), col(Palette.moonWhite, fadeIn));
        skyD.drawDot(Vec2(MX - 30, MY + 34), 14, col(Palette.paleInkFar, fadeIn * 0.5));
        skyD.drawDot(Vec2(MX + 24, MY - 20), 10, col(Palette.paleInkFar, fadeIn * 0.4));
        const cu = smooth(8.0, 10.6, t);
        if (cu > 0.01) {
          const cc = col(Palette.moonWhite, 0.95 * cu * fadeIn);
          drawPolyline(skyD, crackMain, cu, cc, 2);
          drawPolyline(skyD, crackBranch1, smooth(8.9, 10.6, t), cc, 1.6);
          drawPolyline(skyD, crackBranch2, smooth(9.6, 10.6, t), cc, 1.6);
        }
        if (!useDusk) {
          drawRidge(bgDraw, H / 2 - 210, 55, 1.3, 24 + 6 * t, col(Palette.paleInkFar, fadeIn));
          drawRidge(bgDraw, H / 2 - 140, 75, 4.2, 40 + 11 * t, col(Palette.paleInkMid, fadeIn));
          drawTown(bgDraw, col(Palette.inkSoft, fadeIn * 0.95));
        }
      } else {
        drawRiverside(bgDraw, smooth(SCENE_B, 22.4, t), t);
      }
    }
    {
      sceneDraw.clear();
      if (!sceneB) {
        drawTower(sceneDraw, smooth(3.5, 4.6, t));
        const cp = smooth(3.7, 8.0, t);
        if (t < 14.5) {
          const fpos = pathPos(Math.min(cp / 0.92, 1));
          const mpos = pathPos(Math.max(cp / 0.92 - 0.08, 0));
          const walkPose: Pose = cp >= 1 ? "stand" : "walk";
          drawFigure(sceneDraw, fpos.x, fpos.y, 0.8, fadeIn, true, walkPose);
          drawFigure(sceneDraw, mpos.x, mpos.y, 0.8, fadeIn, false, walkPose);
        } else {
          // 塔顶悲剧：强盗逼近 -> 男子推开女子 -> 暗月光击中 -> 倒下渐隐 -> 女子跪抱
          const u5 = t - 14.5;
          const topY = TTY + 12;
          const pushU = smooth(0.55, 0.95, u5);
          const hitU = smooth(1.1, 1.5, u5);
          const wx = lerp(TX - 16, TX - 86, pushU);
          const mx2 = lerp(TX + 6, TX - 30, hitU);
          const mAlpha = 1 - smooth(1.7, 2.4, u5);
          const bxA = lerp(TX + 180, TX + 46, smooth(0, 0.9, u5));
          drawBandit(sceneDraw, bxA, topY, 1.0, smooth(0, 0.4, u5) * (1 - smooth(2.2, 2.5, u5)));
          drawBeam(sceneDraw, mx2, topY + 16, smooth(1.05, 1.25, u5) * (1 - smooth(1.6, 1.95, u5)));
          const fPose: Pose = u5 > 1.7 ? "kneel" : (pushU > 0 && pushU < 1 ? "walk" : "stand");
          drawFigure(sceneDraw, wx, topY, 1.0, 1, true, fPose);
          const mPose: Pose = hitU >= 1 ? "lie" : (u5 > 0.5 && u5 < 1.0 ? "push" : "stand");
          drawFigure(sceneDraw, mx2, topY, 1.0, mAlpha, false, mPose);
        }
        if (t >= 10.8 && t <= 15.9) {
          for (let i = 0; i < 8; i++) {
            const tp = torchPos(i, t);
            if (tp.a > 0.02) {
              sceneDraw.drawDot(Vec2(tp.x, tp.y), 9, col(Palette.vermilion, 0.18 * tp.a));
              sceneDraw.drawDot(Vec2(tp.x, tp.y), 4.5, col(Palette.vermilion, tp.a));
            }
          }
        }
        if (t >= 17 && t < SCENE_B) {
          const hover = t > 18.2 ? 4 * Math.sin((t - 18.2) * 2) : 0;
          const wy = lerp(H / 2 + 180, WHEEL_CY, smooth(17, 18.2, t)) + hover;
          drawWheel(sceneDraw, 0, wy, 1.2 * (t - 17) * (t - 17), smooth(17, 17.7, t));
        }
      }
    }

    {
      fxDraw.clear();
      const bubA = smooth(22.7, 23.1, t);
      if (bubA > 0.02) drawBubble(fxDraw, bubA);
      const fl = smooth(8.0, 8.5, t) * (1 - smooth(10.4, 11.0, t));
      if (fl > 0.01) {
        fxDraw.drawPolygon(
          rectPts(-W / 2, -H / 2, W, H),
          col(Palette.moonHalo, fl * (0.45 + 0.45 * Math.sin(t * 9))));
      }
      const wr = wipeRadius(t);
      if (wr > 1) {
        fxDraw.drawPolygon(circlePts(0, 0, wr, 48), col(Palette.inkDark));
      }
      const endA = smooth(23.0, DURATION, t);
      if (endA > 0.01) {
        fxDraw.drawPolygon(rectPts(-W / 2, -H / 2, W, H), col(Palette.paper, endA));
      }
    }
    let si = -1;
    let sa = 0;
    for (let i = 0; i < SUBS.length; i++) {
      const a2 = subAlpha(i);
      if (a2 > sa) {
        sa = a2;
        si = i;
      }
    }
    {
      uiDraw.clear();
      if (sa > 0.01) {
        uiDraw.drawPolygon(rectPts(-W / 2, SUBY - 24, W, 48), col(Palette.paperDim, 0.55 * sa));
      }
    }
    if (subLb !== undefined) {
      subLb.visible = si >= 0 && sa > 0.02;
      if (si >= 0) subLb.text = SUBS[si].text;
      subLb.opacity = si >= 0 ? sa : 0;
    }
    if (hintLb !== undefined) hintLb.opacity = smooth(1.0, 2.2, t) * 0.9;
    if (bubLb !== undefined) {
      const bubA = smooth(22.7, 23.1, t);
      bubLb.visible = bubA > 0.02;
      bubLb.opacity = bubA;
    }
    // 屏幕震动（11-14.5s，幅度随时间衰减，固定种子伪随机抖动）
    if (t >= 11 && t <= 14.5) {
      const k = 1 - (t - 11) / 3.5;
      const amp = 8 * k * k;
      const fi = Math.floor(t * 28);
      sceneRoot.position = Vec2((hash(fi) * 2 - 1) * amp, (hash(fi + 57) * 2 - 1) * amp);
    } else {
      sceneRoot.position = Vec2(0, 0);
    }
  };

  // 月相轮悬停中心高度（render 内引用，调用时已初始化）
  const WHEEL_CY = 40;

  const doSkip = (): void => {
    if (finished) return;
    t = DURATION;
    render();
    finalize();
  };

  return {
    update(dt: number): void {
      if (finished) return;
      if (Keyboard.isKeyDown(KeyName.Space) || Keyboard.isKeyDown(KeyName.J)
        || Keyboard.isKeyDown(KeyName.E) || Keyboard.isKeyDown(KeyName.Return)) {
        doSkip();
        return;
      }
      t += dt;
      if (t > DURATION) t = DURATION;
      render();
      if (t >= DURATION) finalize();
    },
    skip(): void {
      doSkip();
    },
    done(): boolean {
      return finished;
    },
  };
}