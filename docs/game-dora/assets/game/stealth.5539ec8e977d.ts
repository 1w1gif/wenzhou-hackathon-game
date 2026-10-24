// game/stealth.ts — 潜行系统垂直切片：视野锥 / 听觉 / 草丛藏身 / 头顶反馈 / 警戒
// 兼容硬约束：本系统是纯附加层。主代理未创建 StealthSystem（未接线）时，
// game/enemies.ts 行为与旧版逐位一致；接线（构造 + attachTo + setEnabled）后由
// setStealthWired(true) 打开「巡逻近距离自动索敌关闭 + 背刺判定」两个咬合点。
import { DrawNode, Label, Node, Sprite, Texture2D, TextureFilter, Vec2 } from "Dora";
import { ink, Palette } from "core/palette";
import type { Platform } from "core/types";
import { TOPS } from "data/tower";
import type { EnemyStealthInfo, EnemySystem } from "game/enemies";

// ---- 调参常量（垂直切片口径，全部集中在此便于验收调整）----
const CONE_RADIUS = 272; // 视野半径（px，原 340×0.8，按验收意见调整）
const CONE_HALF_DEG = 33; // 视野半角（度，原 55×0.6，按验收意见收窄）
const CONE_HALF_RAD = (CONE_HALF_DEG * Math.PI) / 180;
const CONE_HALF_COS = Math.cos(CONE_HALF_RAD);
const CONE_SEGMENTS = 12; // 扇形折线段数
const DETECT_CLOSE_RATE = 2.6; // 贴脸时发现速率（满进度 1/s 的倍率）
const DETECT_DECAY = 0.8; // 脱离视野后进度衰减
const LOSE_SIGHT_TIME = 5; // 脱离视线 5 秒回到巡逻
const HEAR_RADIUS = 240; // 听觉半径：3 格
const NOISE_LANDING_SPEED = 420; // 落地竖直速度超过此值算跑步噪音
const PROX_SENSE = 90; // 贴身感知：无视锥也能察觉的距离
const HIDE_RADIUS = 40; // 草丛藏身判定半径
const HIDE_SAFE_DIST = 200; // 藏身时敌人距离大于此值则不可见
const MARK_LIFE = 2; // 头顶 ?/! 停留时长（s）
const MARK_FADE = 0.6; // 淡出时长
const MARK_TEX_Q = "assets/ui/stealth/mark_q.png"; // B3 警戒问号（高分辨率像素图）
const MARK_TEX_ALERT = "assets/ui/stealth/mark_alert.png"; // B4 警报感叹号
const MARK_H = 42; // 贴图标记目标世界高度（等比缩放，36~48 区间）
const MARK_RISE = 40; // 标记中心相对敌人头顶的高度（世界像素，30~50 区间）
const SEARCH_MARK_TIME = 1.4; // 问号最短停留
const STAND_Y = 34; // 地面站立时身体中心距地面顶边的高度

export interface HideSpot {
  id: string;
  x: number;
  y: number;
  r: number;
  floor: number;
  // 藏身点外观：grass=野外草丛（render_world 画灌木+枯苇，本系统画草叶提示）；
  // table=室内桌下（静态酒馆桌已由场景绘制，本系统不重复画草叶）
  kind?: "grass" | "table";
}

// 古镇层（f1）草丛藏身点：y 由 TOPS[1] 推算（地面顶边 + 站立身体中心高）。
// 三个点分别落在 e10/e12/e11/e13 巡逻带内，且避开 st2/st3/st4 剧情触发带。
export const HIDE_SPOTS: HideSpot[] = [
  // 1F 草丛压缩后三丛：西街 700（匪兵A 站桩旁）/坑东 1430（e12 巡逻带）/门后 2180（e11 巡逻带，躲 e13/弓箭）
  { id: "hs_town0", x: 700, y: TOPS[1] + STAND_Y, r: HIDE_RADIUS, floor: 1, kind: "grass" },
  { id: "hs_town1", x: 1430, y: TOPS[1] + STAND_Y, r: HIDE_RADIUS, floor: 1, kind: "grass" },
  // 整改一：酒馆桌下也是藏身点（蹲到 b7 方桌后面，脱离 200px 外敌人的视线）
  { id: "hs_table0", x: 550, y: TOPS[1] + 30, r: HIDE_RADIUS, floor: 1, kind: "table" },
  // 整改①·布置落地：0F 渡口滩涂草丛（e01 投石手巡逻带 1750-2050 内，潜行绕过投石手）；
  // 5F 星野芦苇丛（地刺带 950-1130 与 e51 巡逻 1450 之间的空档，两巡逻带间潜行通道）
  { id: "hs_river0", x: 2010, y: TOPS[0] + STAND_Y, r: HIDE_RADIUS, floor: 0, kind: "grass" },
  { id: "hs_star0", x: 1250, y: TOPS[5] + STAND_Y, r: HIDE_RADIUS, floor: 5, kind: "grass" },
];

// 主代理每帧传给 update 的玩家附加状态（均可选）
export interface StealthPlayerExtras {
  landingSpeed?: number; // 落地瞬间下落速度大小；>= NOISE_LANDING_SPEED 触发听觉
  floor?: number; // 玩家所在层；缺省按 y 距各层地面最近者推算
  attackX?: number; // 本帧近战挥刀起点 x（挥刀视为轻噪音，转向声源）
}

// per-enemy 查询快照（views() 返回）
export interface StealthEnemyView {
  index: number;
  id: string;
  kind: string;
  floor: number;
  x: number;
  y: number;
  facing: number;
  state: string;
  detection: number; // 0..1 发现进度
  alerted: boolean; // 已发现（追击中）
  searching: boolean; // 搜索中（问号）
}

// 线段与 AABB 求交（slab 法）：用于「扇形线段与平台矩形求交」的视线遮挡判定
function segHitsRect(x0: number, y0: number, x1: number, y1: number, r: RectLike): boolean {
  let tmin = 0;
  let tmax = 1;
  const dx = x1 - x0;
  const dy = y1 - y0;
  if (dx > -1e-6 && dx < 1e-6) {
    if (x0 < r.x || x0 > r.x + r.w) {
      return false;
    }
  } else {
    let t1 = (r.x - x0) / dx;
    let t2 = (r.x + r.w - x0) / dx;
    if (t1 > t2) {
      const tt = t1;
      t1 = t2;
      t2 = tt;
    }
    if (t1 > tmin) {
      tmin = t1;
    }
    if (t2 < tmax) {
      tmax = t2;
    }
    if (tmin > tmax) {
      return false;
    }
  }
  if (dy > -1e-6 && dy < 1e-6) {
    if (y0 < r.y || y0 > r.y + r.h) {
      return false;
    }
  } else {
    let t1 = (r.y - y0) / dy;
    let t2 = (r.y + r.h - y0) / dy;
    if (t1 > t2) {
      const tt = t1;
      t1 = t2;
      t2 = tt;
    }
    if (t1 > tmin) {
      tmin = t1;
    }
    if (t2 < tmax) {
      tmax = t2;
    }
    if (tmin > tmax) {
      return false;
    }
  }
  return true;
}

interface RectLike {
  x: number;
  y: number;
  w: number;
  h: number;
}

// per-enemy 潜行运行时（按敌人数组下标索引，spawnAll 后按 id 序列变化自动重建）
interface EnemyRT {
  detection: number;
  alerted: boolean;
  lostT: number;
  searchT: number;
  lastSeenX: number;
  markKind: number; // 0 无 1 问号 2 感叹号
  markT: number;
}

export class StealthSystem {
  private enemies: EnemySystem;
  private platforms: Platform[];
  private enabled = true;
  private showCones = true;
  private rt: EnemyRT[];
  private idsKey: string;
  private blockers: Platform[][];
  private root: Node.Type | undefined;
  private coneDraw: DrawNode.Type | undefined;
  private marks: MarkLabel[];
  private spriteMarks: MarkSprite[];
  private markTexQ: Texture2D.Type | undefined;
  private markTexA: Texture2D.Type | undefined;

  constructor(enemies: EnemySystem, platforms: Platform[]) {
    this.enemies = enemies;
    this.platforms = platforms;
    this.rt = [];
    this.idsKey = "";
    this.blockers = [];
    this.marks = [];
    this.spriteMarks = [];
  }

  // 创建渲染根并挂到世界坐标父节点（父节点须与 worldRoot 同步平移，
  // 本系统内部全部使用世界坐标绘制）。接线即启用：打开潜行门控与背刺咬合点。
  attachTo(parent: Node.Type): void {
    if (this.root !== undefined) {
      return;
    }
    this.root = Node();
    this.root.addTo(parent);
    const draw = DrawNode();
    draw.addTo(this.root);
    this.coneDraw = draw;
    this.setEnabled(true);
    // 头顶标记贴图（B3/B4）：同步加载一次；任一失败则整组走 Label 程序化回退
    this.markTexQ = Texture2D(MARK_TEX_Q);
    this.markTexA = Texture2D(MARK_TEX_ALERT);
    if (this.markTexQ === undefined || this.markTexA === undefined) {
      this.markTexQ = undefined;
      this.markTexA = undefined;
    }
  }

  // 逻辑总开关：关闭后敌人恢复旧版近距离自动索敌、背刺失效（渲染保留可单独关）
  setEnabled(on: boolean): void {
    this.enabled = on;
    this.enemies.setStealthWired(on);
  }

  isEnabled(): boolean {
    return this.enabled;
  }

  // 调试开关：视野锥扇形绘制
  setShowCones(on: boolean): void {
    this.showCones = on;
  }

  isShowingCones(): boolean {
    return this.showCones;
  }

  // ---- per-enemy 查询接口 ----
  detectionOf(enemyIndex: number): number {
    const r = this.rt[enemyIndex];
    if (r === undefined) {
      return 0;
    }
    return r.detection;
  }

  isAlerted(enemyIndex: number): boolean {
    const r = this.rt[enemyIndex];
    if (r === undefined) {
      return false;
    }
    return r.alerted;
  }

  // 全局询问：是否有任意敌人已进入发现（追击）状态（HUD/结算/不杀判定用）
  anyAlerted(): boolean {
    for (let i = 0; i < this.rt.length; i++) {
      const r = this.rt[i];
      if (r !== undefined && r.alerted) {
        return true;
      }
    }
    return false;
  }

  // 整改一·丢石子：石子/酒桶等道具落地发声，把同层半径内的巡逻敌人转向声源（只转向不直接开战）。
  // loud=true 时额外抬升一点发现进度（酒桶砸晕这类大动静）。
  emitNoise(x: number, floor: number, radius = 300, loud = false): void {
    if (!this.enabled) {
      return;
    }
    const infos = this.enemies.stealthInfos();
    for (let i = 0; i < infos.length; i++) {
      const info = infos[i];
      const r = this.rt[i];
      if (r === undefined || info.dead || info.floor !== floor) {
        continue;
      }
      if (Math.abs(info.x - x) > radius) {
        continue;
      }
      this.enemies.faceToward(info.index, x);
      r.searchT = Math.max(r.searchT, SEARCH_MARK_TIME + 0.6);
      if (loud) {
        r.detection = Math.min(0.85, r.detection + 0.2);
      }
      if (r.markKind === 0) {
        r.markKind = 1;
        r.markT = MARK_LIFE;
      }
    }
  }

  // 整改三·回溯复位：清空全部发现/警戒运行时，敌人回巡逻带（保留已死敌人由 spawnAll 负责）
  resetRuntime(): void {
    for (let i = 0; i < this.rt.length; i++) {
      const r = this.rt[i];
      if (r === undefined) {
        continue;
      }
      r.detection = 0;
      r.alerted = false;
      r.lostT = 0;
      r.searchT = 0;
      r.markKind = 0;
      r.markT = 0;
    }
    this.hideAllMarks();
    const infos = this.enemies.stealthInfos();
    for (let i = 0; i < infos.length; i++) {
      if (!infos[i].dead) {
        this.enemies.setCalm(infos[i].index);
      }
    }
  }

  views(): StealthEnemyView[] {
    const out: StealthEnemyView[] = [];
    for (let i = 0; i < this.lastInfos.length && i < this.rt.length; i++) {
      const info = this.lastInfos[i];
      const r = this.rt[i];
      if (r === undefined) {
        continue;
      }
      out.push({
        index: info.index,
        id: info.id,
        kind: info.kind,
        floor: info.floor,
        x: info.x,
        y: info.y,
        facing: info.facing,
        state: info.state,
        detection: r.detection,
        alerted: r.alerted,
        searching: r.searchT > 0,
      });
    }
    return out;
  }

  // 敌人重生/换层后运行时按 id 序列变化自动重建（spawnAll 不需要显式通知）
  private syncRuntime(infos: EnemyStealthInfo[]): void {
    let key = "";
    for (let i = 0; i < infos.length; i++) {
      key = key + infos[i].id + ";";
    }
    if (key === this.idsKey) {
      return;
    }
    this.idsKey = key;
    this.rt = [];
    for (let i = 0; i < infos.length; i++) {
      this.rt.push({
        detection: 0,
        alerted: false,
        lostT: 0,
        searchT: 0,
        lastSeenX: infos[i].x,
        markKind: 0,
        markT: 0,
      });
    }
    this.hideAllMarks();
  }

  // 同层遮挡物缓存：solid + gate 视为不透光（简化：开启后的门仍按遮挡处理），
  // one-way 平台是薄檐不挡视线（头顶檐上/檐下互见）
  private blockersOf(floor: number): Platform[] {
    let list = this.blockers[floor];
    if (list !== undefined) {
      return list;
    }
    list = [];
    for (let i = 0; i < this.platforms.length; i++) {
      const p = this.platforms[i];
      if (p.floor === floor && (p.kind === "solid" || p.kind === "gate")) {
        list.push(p);
      }
    }
    this.blockers[floor] = list;
    return list;
  }

  private nearestFloor(y: number): number {
    let best = 0;
    let bestD = -1;
    for (let f = 0; f < TOPS.length; f++) {
      const d = Math.abs(TOPS[f] + STAND_Y - y);
      if (bestD < 0 || d < bestD) {
        bestD = d;
        best = f;
      }
    }
    return best;
  }

  private inHideSpot(px: number, py: number, floor: number): boolean {
    for (let i = 0; i < HIDE_SPOTS.length; i++) {
      const s = HIDE_SPOTS[i];
      if (s.floor !== floor) {
        continue;
      }
      const dx = px - s.x;
      const dy = py - s.y;
      if (Math.sqrt(dx * dx + dy * dy) <= s.r) {
        return true;
      }
    }
    return false;
  }

  private segBlocked(info: EnemyStealthInfo, eyeY: number, px: number, py: number): boolean {
    const list = this.blockersOf(info.floor);
    for (let i = 0; i < list.length; i++) {
      if (segHitsRect(info.x, eyeY, px, py, list[i])) {
        return true;
      }
    }
    return false;
  }

  // ---- 每帧驱动：发现/听觉/藏身/警戒 ----
  // playerDashing：玩家本帧是否冲刺（跑步噪音之一）；extras 可带落地速度/层号/挥刀声源
  update(dt: number, playerX: number, playerY: number, playerDashing: boolean, extras?: StealthPlayerExtras): void {
    const infos = this.enemies.stealthInfos();
    this.syncRuntime(infos);
    this.lastInfos = infos;
    if (!this.enabled) {
      this.drawFrame(infos, playerX, playerY);
      return;
    }
    const pfloor = extras !== undefined && extras.floor !== undefined ? extras.floor : this.nearestFloor(playerY);
    const landing = extras !== undefined && extras.landingSpeed !== undefined ? extras.landingSpeed : 0;
    const runNoise = playerDashing || landing >= NOISE_LANDING_SPEED;
    const attackX = extras !== undefined && extras.attackX !== undefined ? extras.attackX : -1;
    const attackNoise = attackX >= 0;
    const hidden = this.inHideSpot(playerX, playerY, pfloor);
    for (let i = 0; i < infos.length; i++) {
      const info = infos[i];
      const r = this.rt[i];
      if (r === undefined || info.dead) {
        continue;
      }
      if (info.kind === "boss") {
        // Boss 不参与潜行：无视野锥/无警戒进度/无 ?! 标记，由敌人 AI 近距索敌直接追击
        continue;
      }
      if (info.floor !== pfloor) {
        // 不同层：互不感知，进度缓慢冷却，标记隐藏
        r.detection = Math.max(0, r.detection - DETECT_DECAY * dt);
        r.searchT = Math.max(0, r.searchT - dt);
        r.markT = Math.max(0, r.markT - dt);
        continue;
      }
      const eyeY = info.y + info.h * 0.3;
      const dx = playerX - info.x;
      const dy = playerY - eyeY;
      const dist = Math.sqrt(dx * dx + dy * dy);
      // 扇形判定：与朝向向量夹角 <= 半角（dot >= dist·cos(半角)）且距离在半径内；
      // 贴身 90px 内无视锥也能察觉（防止贴背绕前仍不可见）
      let inCone = false;
      if (dist > 1 && dist <= CONE_RADIUS) {
        if (dx * info.facing >= dist * CONE_HALF_COS) {
          inCone = true;
        }
      }
      let visible = inCone || dist <= PROX_SENSE;
      if (visible && dist > PROX_SENSE && this.segBlocked(info, eyeY, playerX, playerY)) {
        visible = false; // 视线被同层实体平台/门矩形遮挡
      }
      if (visible && hidden && dist > HIDE_SAFE_DIST) {
        visible = false; // 草丛藏身：站进草丛且敌人距离 >200px 则不可见
      }
      if (r.alerted) {
        if (visible) {
          r.lostT = 0;
          r.lastSeenX = playerX;
        } else {
          r.lostT = r.lostT + dt;
          if (r.lostT >= LOSE_SIGHT_TIME) {
            // 脱离视线 5 秒：回到巡逻，巡逻带中心已向最后发现位置偏移（警戒提高）
            this.enemies.setCalm(info.index);
            r.alerted = false;
            r.lostT = 0;
            r.detection = 0.55;
            r.searchT = SEARCH_MARK_TIME;
          }
        }
      } else if (visible) {
        const closeness = 1 - Math.min(1, dist / CONE_RADIUS);
        r.detection = r.detection + DETECT_CLOSE_RATE * (0.45 + 0.55 * closeness) * dt;
        r.lastSeenX = playerX;
        r.searchT = Math.max(r.searchT, 0.9);
        if (r.detection >= 1) {
          r.detection = 1;
          r.alerted = true;
          r.lostT = 0;
          r.markKind = 2;
          r.markT = MARK_LIFE;
          this.enemies.setAlert(info.index, r.lastSeenX); // 发现瞬间：强制追击 + 警戒带偏移
        }
      } else {
        r.detection = Math.max(0, r.detection - DETECT_DECAY * dt);
        let heard = false;
        if (dist <= HEAR_RADIUS && (runNoise || (attackNoise && dist > 0))) {
          heard = true;
          // 听觉：跑步声/挥刀声把巡逻敌人吸引转向声源（只转向，不直接进入战斗）
          this.enemies.faceToward(info.index, runNoise ? playerX : attackX);
          r.searchT = Math.max(r.searchT, SEARCH_MARK_TIME);
          r.detection = Math.min(0.85, r.detection + 0.35 * dt);
        }
        if (!heard) {
          r.searchT = Math.max(0, r.searchT - dt);
        }
      }
      if (r.markT > 0) {
        r.markT = Math.max(0, r.markT - dt);
      }
    }
    this.drawFrame(infos, playerX, playerY);
  }

  private lastInfos: EnemyStealthInfo[] = [];

  // 渲染：草丛提示（常驻）+ 视野锥扇形/进度条（调试开关）+ 头顶 ?/! 标记
  private drawFrame(infos: EnemyStealthInfo[], playerX: number, playerY: number): void {
    const draw = this.coneDraw;
    if (draw === undefined) {
      return;
    }
    draw.clear();
    const pfloor = this.nearestFloor(playerY);
    for (let i = 0; i < HIDE_SPOTS.length; i++) {
      const s = HIDE_SPOTS[i];
      if (s.floor !== pfloor || s.kind === "table") {
        continue;
      }
      const baseY = s.y - STAND_Y;
      draw.drawSegment(Vec2(s.x - 14, baseY), Vec2(s.x - 6, baseY + 26), 3, Palette.moonCyanSoft);
      draw.drawSegment(Vec2(s.x, baseY), Vec2(s.x + 1, baseY + 34), 3, Palette.moonCyanSoft);
      draw.drawSegment(Vec2(s.x + 14, baseY), Vec2(s.x + 8, baseY + 24), 3, Palette.moonCyanSoft);
    }
    if (!this.showCones) {
      return;
    }
    for (let i = 0; i < infos.length; i++) {
      const info = infos[i];
      const r = this.rt[i];
      if (r === undefined || info.dead || info.floor !== pfloor || info.kind === "boss") {
        continue;
      }
      const eyeY = info.y + info.h * 0.3;
      const base = info.facing > 0 ? 0 : Math.PI;
      const verts: Vec2.Type[] = [Vec2(info.x, eyeY)];
      for (let k = 0; k <= CONE_SEGMENTS; k++) {
        const ang = base - CONE_HALF_RAD + (2 * CONE_HALF_RAD * k) / CONE_SEGMENTS;
        verts.push(Vec2(info.x + Math.cos(ang) * CONE_RADIUS, eyeY + Math.sin(ang) * CONE_RADIUS));
      }
      let fill;
      if (r.alerted) {
        fill = ink(Palette.vermilion.r, Palette.vermilion.g, Palette.vermilion.b, 70);
      } else {
        const t = r.detection;
        fill = ink(
          Math.floor(101 + 54 * t),
          Math.floor(112 + 1 * t),
          Math.floor(107 - 51 * t),
          Math.floor(38 + 52 * t)
        );
      }
      draw.drawPolygon(verts, fill);
      if (!r.alerted && r.detection > 0.02) {
        const hy = info.y + info.h / 2 + 12;
        draw.drawPolygon(
          [Vec2(info.x - 19, hy), Vec2(info.x + 19, hy), Vec2(info.x + 19, hy + 6), Vec2(info.x - 19, hy + 6)],
          ink(30, 37, 36, 90)
        );
        const w = 38 * r.detection;
        draw.drawPolygon(
          [Vec2(info.x - 19, hy), Vec2(info.x - 19 + w, hy), Vec2(info.x - 19 + w, hy + 6), Vec2(info.x - 19, hy + 6)],
          Palette.gold
        );
      }
      this.updateMark(info, r);
    }
    this.hideStaleMarks();
  }

  private updateMark(info: EnemyStealthInfo, r: EnemyRT): void {
    if (r.markT <= 0 && r.markKind === 2) {
      r.markKind = 0;
    }
    let want = r.markKind;
    if (want === 0 && !r.alerted && r.searchT > 0 && r.detection > 0.04) {
      want = 1;
    }
    if (want === 0) {
      return;
    }
    // 优先 B3/B4 贴图；贴图未就绪（加载失败）时回退 Label 程序化画法
    const srec = this.markSpriteRec(info.index);
    if (srec !== undefined) {
      this.showSpriteMark(srec, want, info, r);
      return;
    }
    const rec = this.markRec(info.index);
    if (rec === undefined) {
      return;
    }
    const lb = rec.lb;
    const text = want === 2 ? "!" : "?";
    if (lb.text !== text) {
      lb.text = text;
    }
    lb.color = want === 2 ? Palette.gold : Palette.paleInk;
    lb.position = Vec2(info.x, info.y + info.h / 2 + (want === 2 ? 34 : 26));
    lb.visible = true;
    lb.opacity = want === 2 ? Math.min(1, r.markT / MARK_FADE) : 1;
    rec.shown = true;
  }

  private markRec(index: number): MarkLabel | undefined {
    for (let i = 0; i < this.marks.length; i++) {
      if (this.marks[i].enemyIndex === index) {
        return this.marks[i];
      }
    }
    if (this.marks.length >= 24 || this.root === undefined) {
      return undefined;
    }
    const lb = Label("sarasa-mono-sc-regular", 22);
    if (lb === undefined) {
      return undefined;
    }
    lb.addTo(this.root);
    const rec: MarkLabel = { enemyIndex: index, lb: lb, shown: false };
    this.marks.push(rec);
    return rec;
  }

  // 每敌人一对贴图标记（上限与 Label 路径同为 24）；贴图缺失时返回 undefined 走回退
  private markSpriteRec(index: number): MarkSprite | undefined {
    for (let i = 0; i < this.spriteMarks.length; i++) {
      if (this.spriteMarks[i].enemyIndex === index) {
        return this.spriteMarks[i];
      }
    }
    if (this.spriteMarks.length >= 24 || this.root === undefined) {
      return undefined;
    }
    const qTex = this.markTexQ;
    const aTex = this.markTexA;
    if (qTex === undefined || aTex === undefined) {
      return undefined;
    }
    const q = Sprite(qTex);
    const a = Sprite(aTex);
    if (q === undefined || a === undefined) {
      return undefined;
    }
    q.addTo(this.root);
    a.addTo(this.root);
    q.anchor = Vec2(0.5, 0.5);
    a.anchor = Vec2(0.5, 0.5);
    q.filter = TextureFilter.Point;
    a.filter = TextureFilter.Point;
    q.visible = false;
    a.visible = false;
    const rec: MarkSprite = {
      enemyIndex: index,
      q: q,
      a: a,
      qScale: qTex.height > 0 ? MARK_H / qTex.height : 1,
      aScale: aTex.height > 0 ? MARK_H / aTex.height : 1,
      shown: false,
    };
    this.spriteMarks.push(rec);
    return rec;
  }

  private showSpriteMark(rec: MarkSprite, want: number, info: EnemyStealthInfo, r: EnemyRT): void {
    const sp = want === 2 ? rec.a : rec.q;
    const other = want === 2 ? rec.q : rec.a;
    other.visible = false;
    const topY = info.y + info.h / 2;
    let rise = MARK_RISE;
    let opacity = 1;
    let scale = want === 2 ? rec.aScale : rec.qScale;
    if (want === 2) {
      // 感叹号：发现瞬间从小弹起（约 0.15s），markT 进入最后 MARK_FADE 秒开始淡出
      const age = MARK_LIFE - r.markT;
      const pop = Math.min(1, age / 0.15);
      scale = scale * (0.7 + 0.3 * pop);
      rise = rise + (1 - pop) * 10;
      opacity = Math.min(1, r.markT / MARK_FADE);
    }
    sp.position = Vec2(info.x, topY + rise);
    sp.scaleX = scale;
    sp.scaleY = scale;
    sp.opacity = opacity;
    sp.visible = true;
    rec.shown = true;
  }

  // 帧尾清理：本帧未刷新的标记隐藏（死亡/换层/标记到期）；shown 标志复位
  private hideStaleMarks(): void {
    for (let i = 0; i < this.spriteMarks.length; i++) {
      const rec = this.spriteMarks[i];
      if (rec.shown) {
        rec.shown = false;
      } else {
        rec.q.visible = false;
        rec.a.visible = false;
      }
    }
    for (let i = 0; i < this.marks.length; i++) {
      const rec = this.marks[i];
      if (rec.shown) {
        rec.shown = false;
      } else {
        rec.lb.visible = false;
      }
    }
  }

  // 运行时重建（重生/换层）时全部隐藏
  private hideAllMarks(): void {
    for (let i = 0; i < this.spriteMarks.length; i++) {
      this.spriteMarks[i].q.visible = false;
      this.spriteMarks[i].a.visible = false;
      this.spriteMarks[i].shown = false;
    }
    for (let i = 0; i < this.marks.length; i++) {
      this.marks[i].lb.visible = false;
      this.marks[i].shown = false;
    }
  }
}

interface MarkLabel {
  enemyIndex: number;
  lb: Label.Type;
  shown: boolean; // 本帧已展示（帧尾 hideStaleMarks 用）
}

// B3/B4 贴图标记：每敌人一对 Sprite（问号/感叹号），独立位置与透明度动画
interface MarkSprite {
  enemyIndex: number;
  q: Sprite.Type;
  a: Sprite.Type;
  qScale: number; // 目标世界高度等比缩放
  aScale: number;
  shown: boolean;
}