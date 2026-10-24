// game/game.ts — 《衍月·八相》主状态机与游戏主循环
import { Color, Director, DrawNode, KeyName, Keyboard, Node, Sprite, Texture2D, Vec2, View } from "Dora";
import { EnemySpawn, DialogChoice, Ladder, LoopState, Platform, PortalDef, Rect, StoryNode, StoryTriggerDef } from "core/types";
import { activePlatforms, bodyRect, clamp, lerp, rectOverlap } from "game/physics";
import { addTrust, createLoopState, restoreFloorCap, rewindFloor } from "game/world";
import { Player, PlayerCtx, PlayerInput } from "game/player";
import { EffectSystem } from "game/effects";
import { EnemySystem } from "game/enemies";
import { StealthSystem } from "game/stealth";
import { MechanismSystem } from "game/mechanisms";
import { WorldRenderer } from "game/render_world";
import { HUD } from "ui/hud";
import { DialogUI } from "ui/dialog";
import { NotebookUI } from "ui/notebook";
import { ENDINGS, STORY_NODES } from "data/story";
import * as Tower from "data/tower";
import { drawShenYan, drawObserver } from "game/render_chars";
import { playBgm, sfx, type BgmName } from "game/audio";
import { SheetFxSystem } from "game/sheetfx";
import { BoomFxSystem } from "game/boomfx";
import { ShotSync, SlashFxSystem } from "game/slashfx";
import { TreeSystem } from "game/timeline_tree";
import { CausalityFx } from "game/causality_fx";
import { NameEntry } from "ui/name_entry";
import { TreeGallery } from "ui/tree_gallery";
import { ArchiveEntry, appendArchive, loadArchive, loadPlayerName, savePlayerName } from "core/archive";
import { DEFAULT_NAME } from "core/archive";

type Mode = "title" | "prologue" | "play" | "dialog" | "confront" | "rewind" | "dead" | "ending";

interface QiShot {
  x: number;
  y: number;
  dir: number;
  life: number;
  alive: boolean;
  phase: number;
  hits: number;
  hitCd: number;
  trailT: number;
}

// 传送门交互半径（世界像素，水平）：此距离内显示“按 E 进入”提示
const PORTAL_USE_RADIUS = 120;

const GOLD = { r: 155, g: 113, b: 56, a: 255 };
const CYAN = { r: 168, g: 197, b: 188, a: 255 };

// 整改二：种树谜题——攀树梯判定（视觉梯在 render_world.ensurePuzzleProps，坐标保持一致）
const TREE_LADDER: Ladder[] = [{ id: "l_tree", floor: 0, x: 1180, y: 220, w: 44, h: 560 }];

export class Game {
  private root: Node.Type;
  private uiRoot: Node.Type;
  private renderer: WorldRenderer;
  private fxDraw: DrawNode.Type;
  private npcDraw: DrawNode.Type;
  private shenNode: Node.Type; // 申言立绘层（男主/男主黑化版，替代水墨程序小人）
  private shenSpNormal: Sprite.Type | undefined;
  private shenSpDark: Sprite.Type | undefined;
  private obsNode: Node.Type; // 观测者立绘层（与男主立绘层同机制，独立同步相机）
  private obsSp: Sprite.Type | undefined;
  private shenTexOk = false;
  private shenShownIdx = 0; // 男主立绘显示站位索引：滞后于故事进度，玩家接近新站位才推进（换位发生在屏幕外）
  private fx: EffectSystem;
  private hud: HUD;
  private dialog: DialogUI;
  private notebook: NotebookUI;
  private state: LoopState;
  private player: Player;
  private enemies: EnemySystem;
  private mech: MechanismSystem;
  private mode: Mode;
  private paused: boolean;
  private time: number;
  private hitstop: number;
  private shakeT: number;
  private shakeMag: number;
  private camX: number;
  private camY: number;
  private attackApplied: boolean;
  private intentRegenT: number;
  private qiShots: QiShot[];
  private rewindT: number;
  private bladeT: number;
  private intro: { update(dt: number): void; skip(): void; done(): boolean } | undefined;
  private endingId: string;
  private sheetNode: Node.Type;
  private sheetFx: SheetFxSystem;
  private boomFx: BoomFxSystem;
  private slashFx: SlashFxSystem;
  private lastSwingSeq: number;
  private qiSwingT: number;
  private gallery: TreeGallery;
  private nameEntry: NameEntry;
  private tree: TreeSystem | undefined;
  private treeArchived: boolean;
  // 时空树·探索生长去重：每夜每层记一次 / 每局每闸记一次 / 每夜首次殒落记一次
  private treeFloorSeen: Record<number, boolean> = {};
  private treeGateSeen: Record<string, boolean> = {};
  private treeDeathSeen: boolean = false;
  private playerName: string;
  // —— 整改一/二/三新增 ——
  private stealth: StealthSystem;
  private causFx: CausalityFx;
  private treeSnap: Record<string, LoopState>; // 时空树快照：节点 id → 该节点长成瞬间的完整世界状态（跳回数据源）
  private treeJumpPending: boolean; // 跳回节点触发的回溯演出进行中（doRewind 收尾时长枝守卫）
  private floor1Kill: boolean; // 本层（古镇）是否杀敌——过层结算用
  private floor1Alert: boolean; // 本层是否触发过潜行警报
  private deadT: number; // 死亡后自动回溯倒计时（>0 时倒数）

  constructor() {
    this.root = Node();
    this.root.addTo(Director.entry);
    this.renderer = new WorldRenderer(this.root, Tower);
    this.fxDraw = DrawNode();
    this.fxDraw.addTo(this.root);
    this.npcDraw = DrawNode();
    this.npcDraw.addTo(this.root);
    this.shenNode = Node();
    this.shenNode.addTo(this.root);
    this.shenSpNormal = this.makeNpcSprite(["assets/characters/male_hero.png", ".agent/男主.png"], this.shenNode, "ShenSprite");
    this.shenSpDark = this.makeNpcSprite(["assets/characters/male_hero_dark.png", ".agent/男主黑化版.png"], this.shenNode, "ShenSprite");
    // 观测者立绘（用户上传素材）：加载失败回退原程序水墨小人
    this.obsNode = Node();
    this.obsNode.addTo(this.root);
    this.obsSp = this.makeNpcSprite([".agent/观测者.png"], this.obsNode, "Observer");
    this.shenTexOk = this.shenSpNormal !== undefined || this.shenSpDark !== undefined;
    this.sheetNode = Node();
    this.sheetNode.addTo(this.root);
    this.uiRoot = Node();
    this.uiRoot.addTo(this.root);
    this.fx = new EffectSystem();
    this.sheetFx = new SheetFxSystem(this.sheetNode);
    this.boomFx = new BoomFxSystem(this.sheetNode);
    this.slashFx = new SlashFxSystem(this.sheetNode);
    this.lastSwingSeq = -1;
    this.qiSwingT = 0;
    this.fx.sheetHook = (x, y, dir, big) => this.sheetFx.spawn(x, y, dir, big);
    this.state = createLoopState();
    this.player = new Player(800, 410);
    this.enemies = new EnemySystem(this.fx, {
      onPlayerHit: (dmg, fromX) => this.onPlayerHit(dmg, fromX),
      onDeath: (def, x, y) => this.onEnemyDeath(def, x, y),
      onPoof: (x, y) => this.fx.spawnDust(x, y, 0),
    });
    this.mech = new MechanismSystem(this.state, this.fx, {
      onGateOpen: (gateId: string) => {
        this.fx.spawnRing(this.player.body.x, this.player.body.y + 20, GOLD, 16, 170, 0.7);
        this.growGate(gateId);
      },
      onBell: () => this.shake(0.25, 5),
      onLanternLit: () => this.fx.spawnStars(this.player.body.x, this.player.body.y + 40, 6),
      onLanternFail: () => this.shake(0.15, 3),
      onCheckpoint: () => this.syncFloorScene(),
      onCollect: (kind: string) => {
        if (kind === "lampstone") {
          this.mech.addLampStone();
          this.fx.spawnRing(this.player.body.x, this.player.body.y + 30, GOLD, 10, 60, 0.6);
        }
      },
      onSwordInserted: () => {
        this.shake(0.3, 7);
        this.fx.spawnStars(this.player.body.x, this.player.body.y + 30, 10);
      },
      onLanternNoStone: () => {
        this.shake(0.12, 2);
      },
      // 风息符文激活（F3）：青光震屏 + 星尘，与点灯成功同款反馈口径
      onWindSigil: () => {
        this.shake(0.18, 4);
        this.fx.spawnStars(this.player.body.x, this.player.body.y + 30, 6);
      },
      // 星位按序点亮成功（F5）
      onStarLit: () => {
        this.fx.spawnStars(this.player.body.x, this.player.body.y + 40, 6);
      },
      // 星位顺序错误（F5）：轻震提示已全部熄灭
      onStarFail: () => {
        this.shake(0.15, 3);
      },
    });
    this.mech.bindLists(Tower.ropes, Tower.bells, Tower.plates);
    this.mech.bindSwordSlots(Tower.swordSlots);
    this.mech.bindGateRequirements(Tower.gateRequirements);
    this.mech.bindWindSigils(Tower.windSigils);
    this.mech.bindStarNodes(Tower.starNodes);
    // 整改一：潜行系统（锥形视野+听觉+藏身点），绘制层挂进世界根随相机移动
    this.stealth = new StealthSystem(this.enemies, Tower.platforms);
    this.stealth.attachTo(this.renderer.getWorldRoot());
    this.hud = new HUD(this.uiRoot);
    this.nameEntry = new NameEntry(this.uiRoot);
    this.gallery = new TreeGallery(this.uiRoot);
    this.treeArchived = false;
    this.playerName = "";
    this.causFx = new CausalityFx(this.uiRoot);
    this.treeSnap = {};
    this.treeJumpPending = false;
    this.floor1Kill = false;
    this.floor1Alert = false;
    this.deadT = 0;
    // PLAY → 全屏序幕视频「游戏前情提要」（可跳过/播完自动回调）→ 刻旅人之名 → 进游戏循环
    this.hud.onPlayConfirmed = () => {
      sfx("click", 0.8);
      this.hud.playPrologue(() => {
        this.nameEntry.open(loadPlayerName(), (name: string) => {
          this.playerName = name;
          savePlayerName(name);
          this.hud.setTitleVisible(false);
          this.beginLoop();
        }, () => {
          // 取消：回标题菜单（title 可见时重置 playLock）
          this.hud.setTitleVisible(true);
        });
      });
    };
    // 时空树仓库：翻看每位通关旅人的独一无二之树
    this.hud.onGalleryConfirmed = () => {
      sfx("click", 0.8);
      this.gallery.open(loadArchive());
    };
    this.dialog = new DialogUI(this.uiRoot);
    this.notebook = new NotebookUI(this.uiRoot);
    this.mode = "title";
    this.paused = false;
    this.time = 0;
    this.hitstop = 0;
    this.shakeT = 0;
    this.shakeMag = 0;
    this.camX = 800;
    this.camY = 400;
    this.attackApplied = false;
    this.intentRegenT = 0;
    this.qiShots = [];
    this.rewindT = 0;
    this.bladeT = 0;
    this.endingId = "";
    this.hud.setTitleVisible(true);
    // 封面配乐：开机进入标题即起播（playStream 交叉淡入；无音频设备静默降级）
    playBgm("cover", 1.5);
    // 暂停菜单「回到标题」：走与结局返回标题相同的收尾链路
    this.hud.onReturnTitle = (): void => {
      this.toTitle();
    };
    // 结局页点击返回标题（与按 R 同链路；仅 ending 模式生效）
    this.hud.onEndingTap = (): void => {
      if (this.mode === "ending") {
        this.toTitle();
      }
    };
  }

  start(): void {
    this.resetRun();
    // 标题交互全部由 HUD 标题菜单接管（菜单项点击 + handleTitleKey），此处每帧同步菜单可用状态
    this.root.schedule((dt) => {
      this.hud.titleMenuEnabled = this.mode === "title";
      this.tick(dt);
      return false;
    });
    this.root.onKeyDown((key) => this.onKey(key));
    // 触屏：名字输入面板打开时点屏幕 = 确认当前名字（web 端无键盘/IME 的完整路径）
    this.root.touchEnabled = true;
    this.root.slot("Tapped", () => {
      if (this.mode === "title" && this.nameEntry.isOpen()) {
        this.nameEntry.handleKey(KeyName.Return);
      }
    });
    // 启动流程：直接进封面（序章场景保留在 scenes/intro.ts，暂不启用）
  }

  private resetRun(): void {
    this.state = createLoopState();
    this.mech.state = this.state;
    this.mech.syncStones(Tower.pushStones);
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
    this.qiShots.length = 0;
    this.attackApplied = false;
    this.intentRegenT = 0;
    this.bladeT = 0;
    this.rewindT = 0;
    this.stealth.resetRuntime();
    this.causFx.clear();
    this.treeSnap = {};
    this.treeJumpPending = false;
    this.floor1Kill = false;
    this.floor1Alert = false;
    this.deadT = 0;
    // 用户指令②：开局即自动播 F0 入口独白。此前这里只手动 player.respawn，
    // 没走 respawnAt → pendingFloorStory 从未挂上 → 出生点（x=160）看不到任何提示与独白。
    // respawnAt 还会补 setFloorScene 初始层与相机定位（BGM 在标题态会自行跳过）。
    this.respawnAt(this.state.currentCheckpointId);
  }

  private findCheckpoint(id: string): { x: number; y: number; floor: number } | undefined {
    for (let i = 0; i < Tower.checkpoints.length; i++) {
      if (Tower.checkpoints[i].id === id) {
        return Tower.checkpoints[i];
      }
    }
    return undefined;
  }

  // —— 分层配乐：1层=用户曲 1f · 2层=紧张 · 3层=武侠热闹 · 4层=用户曲 安静治愈 · 5层=夜空空灵 · 6层=冲突紧张 · 7层=高燃战斗 ——
  private playFloorBgm(fade = 1.2): void {
    if (this.mode !== "play" && this.mode !== "confront" && this.mode !== "rewind") {
      return; // 标题/结局由 cover/calm 曲负责，不抢拍
    }
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    const floor = cp ? cp.floor : 0;
    const names: BgmName[] = ["floor1", "tension", "wuxia", "floor4", "dusk", "conflict", "floor7"];
    const name = names[Math.max(0, Math.min(names.length - 1, floor))];
    playBgm(name, fade);
  }

  private findStoryTrigger(id: string): StoryTriggerDef | undefined {
    for (let i = 0; i < Tower.storyTriggers.length; i++) {
      if (Tower.storyTriggers[i].storyId === id) {
        return Tower.storyTriggers[i];
      }
    }
    return undefined;
  }

  // 内心独白节点：进场景/触发带自动播放，不再按 E（story_town 尾句为远处喊声，整体仍属独白演出）
  private isAutoMonologue(id: string): boolean {
    return id === "story_check_intro" || id === "story_town" || id === "story_sneak_hint" || id === "story_workshop";
  }

  // 层入口独白：本层最左侧未看过的内心独白触发带（F0=潮声独白 / F1=街巷独白）
  private floorIntroStory(floor: number): string | undefined {
    let best: StoryTriggerDef | undefined;
    for (let i = 0; i < Tower.storyTriggers.length; i++) {
      const t = Tower.storyTriggers[i];
      if (t.floor !== floor || !this.isAutoMonologue(t.storyId) || this.state.storySeen[t.storyId]) {
        continue;
      }
      if (best === undefined || t.x < best.x) {
        best = t;
      }
    }
    return best !== undefined ? best.storyId : undefined;
  }

  // 延时触发进层独白：等黑幕淡入完成，且确认仍在目标层（回溯/跳节点/继续存档不误播）
  private tickPendingFloorStory(dt: number): void {
    const id = this.pendingFloorStory;
    if (id === undefined) {
      return;
    }
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    if (cp === undefined || cp.floor !== this.pendingFloorStoryFloor || this.state.storySeen[id]) {
      this.pendingFloorStory = undefined;
      return;
    }
    this.pendingFloorStoryT -= dt;
    if (this.pendingFloorStoryT > 0 || this.teleportT >= 0) {
      return;
    }
    this.pendingFloorStory = undefined;
    this.openDialog(id);
  }

  // 对话提示锚点（用户指令③）：男主对话挂男主头顶、观测者对话挂观测者头顶，其余退回触发带中心贴地
  private storyPromptAnchor(id: string): { x: number; y: number } {
    const trig = this.findStoryTrigger(id);
    const groundY = Tower.TOPS[trig !== undefined ? trig.floor : 0];
    const cx = trig !== undefined ? trig.x + trig.w / 2 : this.player.body.x;
    const node = STORY_NODES[id];
    const kind = node !== undefined && node.lines.length > 0 ? node.lines[0].speaker : "";
    if (kind.indexOf("观测者") >= 0) {
      return { x: 800, y: groundY + 88 };
    }
    if ((kind.indexOf("沈砚") >= 0 || kind.indexOf("申言") >= 0) && this.shenRenderOk) {
      return { x: this.shenRenderX, y: this.shenRenderY + 92 };
    }
    return { x: cx, y: groundY + 52 };
  }

  // 交互提示气泡：传送门旁「按 E 传送」/ NPC 头顶「按 E 对话」，替代底部一行提示
  private syncInteractPrompt(): void {
    if (this.mode === "play" && !this.paused) {
      // 教学浮字优先于传送门/对话提示（三场教学不可合并，浮字必须真实出现在画面上）
      if (this.hintBubbleText !== undefined) {
        this.renderer.setPrompt(this.hintBubbleX, this.hintBubbleY, this.hintBubbleText);
        return;
      }
      // 战斗中（附近有敌意敌人）隐藏「按 E」交互框；教学浮字不受影响（闪避教学本就发生在战斗中）
      if (!this.inCombatNear()) {
        // 终局对峙：靠近沈砚给三选一按键气泡（结局入口就近指引；远离即隐，同其他气泡口径）
        if (this.state.flags.confront) {
          const cx6 = this.shenX();
          const cy6 = this.shenY();
          if (Math.abs(this.player.body.x - cx6) < 420 && Math.abs(this.player.body.y - cy6) < 260) {
            this.renderer.setPrompt(cx6, cy6 + 130, "E 放下剑 · Q 以命换命 · J 剑锋相向");
            return;
          }
        }
        const portal = this.nearPortal(this.player.body.x, this.player.body.y);
        if (portal !== undefined) {
          // 门贴图高 130：提示贴门顶正中（气泡锚底后自动再抬 14px）
          this.renderer.setPrompt(portal.x, portal.y + 130, "按 E 传送");
          return;
        }
        if (this.nearStoryId !== undefined) {
          const anchor = this.storyPromptAnchor(this.nearStoryId);
          this.renderer.setPrompt(anchor.x, anchor.y, "按 E 对话");
          return;
        }
      }
    }
    // F0 树谜题：可交互物旁的按键气泡（补齐「怎么种树」的可见提示；战斗中隐藏同传送门口径）
    const cpHere = this.findCheckpoint(this.state.currentCheckpointId);
    if ((cpHere ? cpHere.floor : 0) === 0 && !this.inCombatNear()) {
      const fx = this.state.flags;
      const pxHere = this.player.body.x;
      if (!fx.treePlanted && !fx.saplingTaken && Math.abs(pxHere - 700) < 90) {
        this.renderer.setPrompt(700, Tower.TOPS[0] + 46, "按 E 移取树苗");
        return;
      }
      if (!fx.bucketFull && !fx.treePlanted && Math.abs(pxHere - 860) < 90) {
        this.renderer.setPrompt(860, Tower.TOPS[0] + 64, "按 E 打一桶井水");
        return;
      }
      if (fx.saplingTaken === true && fx.treePlanted !== true && Math.abs(pxHere - 1200) < 100) {
        this.renderer.setPrompt(1200, Tower.TOPS[0] + 46, "按 E 种下树苗");
        return;
      }
    }
    // F1 古镇街巷：石子/酒桶/店小二的按键气泡（此前完全无提示，玩家不知可按 E）。
    // 判距与 tryPebblePickup/tryBarrel/tryWaiter 完全同半径，优先序与 interact() 一致
    // （石子→酒桶→店小二，重叠区显示的就是 E 会触发的那件事）；战斗中隐藏同传送门口径
    const cpF1 = this.findCheckpoint(this.state.currentCheckpointId);
    if ((cpF1 ? cpF1.floor : 0) === 1 && !this.inCombatNear()) {
      const px1 = this.player.body.x;
      const py1 = this.player.body.y;
      if (Math.abs(py1 - (Tower.TOPS[1] + 42)) < 90) {
        if (this.state.pebbles <= 0 && Math.abs(px1 - 1450) < 80) {
          this.renderer.setPrompt(1450, Tower.TOPS[1] + 96, "按 E 拾取石子（Q 丢石引开视线）");
          return;
        }
        if (this.state.flags.barrelDown !== true && Math.abs(px1 - 1900) < 90) {
          this.renderer.setPrompt(1900, Tower.TOPS[1] + 96, "按 E 踢倒酒桶（震晕附近守卫）");
          return;
        }
        if (this.state.flags.waiterFreed !== true && Math.abs(px1 - 1985) < 80) {
          this.renderer.setPrompt(1985, Tower.TOPS[1] + 96, "按 E 割绳救出店小二");
          return;
        }
      }
    }
    // F4 机关层（用户需求④）：推石/剑槽无按键交互，靠近时给操作提示气泡（战斗中隐藏，同传送门口径）
    const cpF4 = this.findCheckpoint(this.state.currentCheckpointId);
    if ((cpF4 ? cpF4.floor : 0) === 4 && !this.mech.isGateOpen("gate_mech")) {
      const px4 = this.player.body.x;
      const py4 = this.player.body.y;
      const top4 = Tower.TOPS[4];
      const plateDone = this.state.platesActive["plate0"] === true || this.state.platesActive["plate1"] === true;
      const slotDone = this.state.flags["swordslot_slot_mech"] === true;
      // 推石提示：石未上板时，靠近石块或任一空石板都提示（石块起始 600，石板 900/1300）
      if (!plateDone && Math.abs(py4 - (top4 + 40)) < 170 && this.mech.stones.length > 0) {
        const sx4 = this.mech.stones[0].x;
        const nearStone = Math.abs(px4 - sx4) < 170;
        const nearPlate = Math.abs(px4 - 900) < 120 || Math.abs(px4 - 1300) < 120;
        if (nearStone || nearPlate) {
          const ax4 = nearStone ? sx4 : px4 < 1100 ? 900 : 1300;
          this.renderer.setPrompt(ax4, top4 + 92, "按住 A/D 顶着石块推上石板");
          return;
        }
      }
      // 剑槽提示：未插入时靠近剑槽（x=1500）提示用剑气 K 插入
      if (!slotDone && Math.abs(px4 - 1500) < 140 && Math.abs(py4 - (top4 + 40)) < 170) {
        this.renderer.setPrompt(1500, top4 + 100, "以剑气 K 插入剑槽");
        return;
      }
    }
    // F3 风息符文：靠近未亮符文给冲刺提示（战斗中隐藏，同其他气泡口径）
    const cpF3 = this.findCheckpoint(this.state.currentCheckpointId);
    if ((cpF3 ? cpF3.floor : 0) === 3 && !this.mech.isGateOpen("gate_corridor") && !this.inCombatNear()) {
      const px3 = this.player.body.x;
      const py3 = this.player.body.y;
      for (let i = 0; i < Tower.windSigils.length; i++) {
        const s3 = Tower.windSigils[i];
        if (this.state.flags["wind_" + s3.id] === true || Math.abs(px3 - s3.x) >= 130) {
          continue;
        }
        // 逐符文高度门：ws3/ws4 在高台（p30 顶4278/p33 顶4248），旧版只按地面高度判距，高台符文永不显示提示
        if (Math.abs(py3 - (s3.y + 40)) >= 170) {
          continue;
        }
        let lit3 = 0;
        for (let k = 0; k < Tower.windSigils.length; k++) {
          if (this.state.flags["wind_" + Tower.windSigils[k].id] === true) {
            lit3 += 1;
          }
        }
        // 计数用数组长度（2026-10-26 扩到 5 枚后旧文案仍写 /3）
        this.renderer.setPrompt(s3.x, s3.y + 96, "冲刺穿过风息符文（" + lit3 + "/" + Tower.windSigils.length + "）");
        return;
      }
    }
    // F2 悬空工坊：靠近未亮悬灯给依序点亮提示（战斗中隐藏，同 F3/F5 口径）；
    // 未轮到顺序时明说该点第几盏，避免「点不亮」的误判（2026-10-26）
    const cpF2 = this.findCheckpoint(this.state.currentCheckpointId);
    if ((cpF2 ? cpF2.floor : 0) === 2 && !this.mech.isGateOpen("lanternGate") && !this.inCombatNear()) {
      const px2 = this.player.body.x;
      const py2 = this.player.body.y;
      for (let i = 0; i < Tower.lanterns.length; i++) {
        const lt2 = Tower.lanterns[i];
        if (this.state.lanternsLit[lt2.id] === true) {
          continue;
        }
        if (Math.abs(px2 - lt2.x) >= 110 || Math.abs(py2 - lt2.y) >= 150) {
          continue;
        }
        let lit2 = 0;
        for (let k = 0; k < Tower.lanterns.length; k++) {
          if (this.state.lanternsLit[Tower.lanterns[k].id] === true) {
            lit2 += 1;
          }
        }
        const expected2 = this.state.lanternSequence + 1;
        const tip2 = lt2.order === expected2
          ? "按 E 点亮悬灯（" + lit2 + "/" + Tower.lanterns.length + "，依序）"
          : "此灯未轮到——先点亮第 " + expected2 + " 盏悬灯";
        this.renderer.setPrompt(lt2.x, lt2.y + 96, tip2);
        return;
      }
    }
    // F5 星位：靠近未亮星位给顺序点亮提示（战斗中隐藏）
    const cpF5 = this.findCheckpoint(this.state.currentCheckpointId);
    if ((cpF5 ? cpF5.floor : 0) === 5 && !this.mech.isGateOpen("gate_star") && !this.inCombatNear()) {
      const px5 = this.player.body.x;
      const py5 = this.player.body.y;
      for (let i = 0; i < Tower.starNodes.length; i++) {
        const s5 = Tower.starNodes[i];
        if (this.state.flags["star_" + s5.id] === true) {
          continue;
        }
        if (Math.abs(px5 - s5.x) >= 110 || Math.abs(py5 - s5.y) >= 150) {
          continue;
        }
        let lit5 = 0;
        for (let k = 0; k < Tower.starNodes.length; k++) {
          if (this.state.flags["star_" + Tower.starNodes[k].id] === true) {
            lit5 += 1;
          }
        }
        this.renderer.setPrompt(s5.x, s5.y + 96, "按 E 点亮星位（" + lit5 + "/" + Tower.starNodes.length + "，错序将熄灭）");
        return;
      }
    }
    this.renderer.setPrompt(0, 0, undefined);
  }

  // 战斗中：本层任一存活敌人处于敌意状态（非 patrol/dead）且在玩家附近
  private inCombatNear(): boolean {
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    const floor = cp ? cp.floor : 0;
    const infos = this.enemies.stealthInfos();
    for (let i = 0; i < infos.length; i++) {
      const inf = infos[i];
      if (inf.floor !== floor) {
        continue;
      }
      if (inf.state === "patrol" || inf.state === "dead") {
        continue;
      }
      if (Math.abs(inf.x - this.player.body.x) < 560) {
        return true;
      }
    }
    return false;
  }

  private shake(t: number, mag: number): void {
    this.shakeT = t;
    this.shakeMag = mag;
  }

  private buildInput(active: boolean): PlayerInput {
    if (!active) {
      return { left: false, right: false, up: false, down: false, jumpPressed: false, attackPressed: false, qiPressed: false, dashPressed: false };
    }
    return {
      left: Keyboard.isKeyPressed(KeyName.A),
      right: Keyboard.isKeyPressed(KeyName.D),
      up: Keyboard.isKeyPressed(KeyName.W),
      down: Keyboard.isKeyPressed(KeyName.S),
      jumpPressed: Keyboard.isKeyDown(KeyName.Space),
      attackPressed: Keyboard.isKeyDown(KeyName.J),
      qiPressed: Keyboard.isKeyDown(KeyName.K),
      dashPressed: Keyboard.isKeyDown(KeyName.LShift),
    };
  }

  private onKey(key: KeyName): void {
    if (key === KeyName.Escape) {
      // 时空树浮层打开时先关浮层，不进入暂停
      if (this.tree !== undefined && this.tree.isOverlayOpen()) {
        this.tree.handleKey(key);
        return;
      }
      const inPlay = this.mode === "play" || this.mode === "confront";
      if (inPlay || this.paused) {
        this.paused = !this.paused;
        this.hud.setPauseVisible(this.paused);
        return;
      }
    }
    switch (this.mode) {
      case "title":
        // 输入名字 / 仓库浮层优先接管按键，再落回标题菜单
        if (this.nameEntry.isOpen()) {
          this.nameEntry.handleKey(key);
          break;
        }
        if (this.gallery.isOpen()) {
          this.gallery.handleKey(key);
          break;
        }
        this.hud.handleTitleKey(key);
        break;
      case "prologue":
        if (key === KeyName.Escape && this.intro) {
          this.intro.skip();
        }
        break;
      case "play":
      case "confront":
        if (!this.paused) {
          this.onPlayKey(key);
        }
        break;
      case "dialog":
        if (key === KeyName.W) {
          this.dialog.moveChoice(-1);
        } else if (key === KeyName.S) {
          this.dialog.moveChoice(1);
        } else if (key === KeyName.E || key === KeyName.Space || key === KeyName.Return) {
          // 仅当选项列表已展示才确认，否则推进文本（修复选项类对话死键卡死）。
          if (this.dialog.inChoiceMode()) {
            this.dialog.confirmChoice();
          } else {
            this.dialog.advance();
          }
        }
        break;
      case "dead":
        if (key === KeyName.R) {
          // 整改三：死亡 R=提前触发本层回溯；HP 上限已耗尽（力竭结局）则回标题
          if (this.state.maxLife <= 1) {
            this.toTitle();
          } else {
            this.startRewind();
          }
        }
        break;
      case "ending":
        if (key === KeyName.R) {
          this.toTitle();
        }
        break;
      default:
        break;
    }
  }

  private onPlayKey(key: KeyName): void {
    // T 键：时空树浮层开合（Esc 关树已在 onKey 上游分流）
    if (this.tree !== undefined) {
      this.tree.handleKey(key);
    }
    if (key === KeyName.Tab) {
      this.notebook.toggle();
      return;
    }
    if (key === KeyName.E) {
      this.interact();
      return;
    }
    if (key === KeyName.R) {
      this.startRewind();
    }
    if (key === KeyName.Q) {
      this.onQ();
    }
  }

  // 整改一/三：Q 键 = 丢石子（潜行引开守卫）/ 以命换命（终局月相装置旁；替代旧全局轮回死键）
  private onQ(): void {
    if (this.mode === "play") {
      this.throwPebble();
      return;
    }
    if (this.mode === "confront") {
      const px = this.player.body.x;
      const py = this.player.body.y;
      if (Math.abs(px - this.shenX()) < 150 && Math.abs(py - this.shenY()) < 200) {
        if (this.tree !== undefined) {
          this.tree.addChoice("以命换命");
        }
        this.logCause("以命换命·月相永驻");
        this.endGame("sacrifice");
      }
    }
  }

  private tick(dt: number): void {
    this.time += dt;
    this.causFx.update(dt);
    let shakeX = 0;
    let shakeY = 0;
    if (this.shakeT > 0) {
      this.shakeT -= dt;
      shakeX = (Math.random() * 2 - 1) * this.shakeMag;
      shakeY = (Math.random() * 2 - 1) * this.shakeMag;
    }
    if (this.mode === "prologue" && this.intro) {
      // 钳制首帧/加载卡顿产生的大 dt，防止动画时间轴跳帧导致提前结束
      this.intro.update(Math.min(dt, 0.05));
      if (this.intro.done()) {
        this.intro = undefined;
        this.toTitle();
      }
    } else if (this.mode === "rewind") {
      // 整改三：本层回溯动画 2 秒（死亡自动触发/R 提前触发，进度条同步）
      this.rewindT += dt;
      this.hud.setRewind(Math.min(1, this.rewindT / 2.0));
      if (this.rewindT >= 2.0) {
        this.hud.setRewind(-1);
        this.doRewind();
      }
    } else if (this.mode === "dead") {
      // 整改三：死亡 0.8s 后自动回溯本层；R 可提前
      if (this.deadT > 0) {
        this.deadT -= dt;
        if (this.deadT <= 0) {
          this.startRewind();
        }
      }
    } else if (this.mode === "dialog") {
      // 自愈：框已关闭但 mode 仍停在 dialog → 一帧内恢复 play，杜绝全键失效。
      if (!this.dialog.isOpen()) {
        this.mode = "play";
      } else {
        this.dialog.update(dt);
      }
    } else if ((this.mode === "play" || this.mode === "confront") && !this.paused) {
      if (this.hitstop > 0) {
        this.hitstop -= dt;
      } else {
        if (this.bladeT > 0) {
          this.bladeT -= dt;
          if (this.bladeT <= 0) {
            this.endGame("blade");
          }
        }
        this.tickPendingFloorStory(dt);
        if (this.mode === "play" || this.mode === "confront") {
          if (this.teleportT >= 0) {
            this.advanceTeleport(dt);
          } else {
            this.simWorld(dt);
          }
        }
      }
    }
    this.updateVisuals(dt, shakeX, shakeY);
  }

  private updateMovers(): void {
    const plats = Tower.platforms;
    for (let i = 0; i < plats.length; i++) {
      const p = plats[i];
      if (!p.mover) {
        continue;
      }
      const m = p.mover;
      const s = 0.5 - 0.5 * Math.cos((this.time / m.period + m.phase) * 6.2831853);
      const nx = lerp(m.ax, m.bx, s);
      const ny = lerp(m.ay, m.by, s);
      const dx = nx - p.x;
      const dy = ny - p.y;
      p.x = nx;
      p.y = ny;
      if (this.player.body.groundId === p.id) {
        this.player.body.x += dx;
        this.player.body.y += dy;
      }
    }
  }

  private beginLoop(): void {
    // 新的一局：新的时空树（T 键查看；通关时快照入仓）
    this.tree = new TreeSystem("启程");
    this.tree.attachTo(this.uiRoot);
    // 整改三补：跳回节点 = 回到该节点所在检查点（触发 2s 回溯演出）；侧枝快照清零
    this.tree.onJumpTo = (id: string) => this.jumpToNode(id);
    // 节点长成即存世界快照（根节点在回调挂上前已生成，此处补记）
    this.tree.onNodeAdded = (id: string) => {
      this.treeSnap[id] = this.cloneLoopState(this.state);
    };
    this.treeSnap[this.tree.nodes[0].id] = this.cloneLoopState(this.state);
    this.treeArchived = false;
    // 探索生长去重清零；开局根上先长「初临河滩」，树自此随探索进化
    this.treeFloorSeen = {};
    this.treeGateSeen = {};
    this.treeDeathSeen = false;
    this.growFloor(0);
    this.causFx.clear();
    this.stealth.resetRuntime();
    this.applyLoopVariants();
    this.mode = "play";
    this.playFloorBgm(1.5); // 进入第一层即播本层配乐（1 层=用户提供的 1f）
  }

  // —— 时空树·探索生长（用户需求：一次次探索长出对应分支，通关自成其树） ——
  // 文字≤16 字（仓库 sanitizeName(via,16) 截断安全）；所有生长走 extend 续枝不弃线，
  // 只有真正的抉择/结局走 addChoice 分叉。
  private growFloor(floor: number): void {
    if (this.tree === undefined || this.treeFloorSeen[floor] === true) {
      return;
    }
    this.treeFloorSeen[floor] = true;
    // ≤5 汉字（.length 在 Lua 是字节数，archive sanitizeName(via,16) 按字节截断，中文超 5 字会烂尾）
    const short = ["初临河滩", "入古镇街巷", "上悬空工坊", "登塔外环廊", "探机关层", "入观星之间", "登观星台"];
    const name = floor >= 0 && floor < short.length ? short[floor] : "行至新境";
    this.tree.extend(name);
  }

  private growGate(gateId: string): void {
    if (this.tree === undefined || this.treeGateSeen[gateId] === true) {
      return;
    }
    this.treeGateSeen[gateId] = true;
    const via = gateId === "gate_bell"
      ? "钟鸣桥落"
      : gateId === "gate_corridor"
        ? "双信闸启"
        : gateId === "gate_mech"
          ? "压石嵌剑"
          : gateId === "gate_star"
            ? "星门台现"
            : "闸开";
    this.tree.extend(via);
  }

  private growNight(): void {
    if (this.tree === undefined) {
      return;
    }
    const n = this.state.loopIndex + 1;
    const cn = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"];
    const label = n <= 9 ? "第" + cn[n] + "夜重溯" : "第" + n + "夜";
    this.tree.extend(label);
  }

  private simWorld(dt: number): void {
    this.updateMovers();
    const plats = activePlatforms(Tower.platforms, this.state.openedGates);
    // 整改二：种树后本层新增攀树梯（砍树后消失——因果可反证）
    const ctx: PlayerCtx = { platforms: plats, ladders: this.activeLadders(), climbWalls: Tower.climbWalls };
    const wasGround = this.player.body.onGround;
    const vyBefore = this.player.body.vy;
    const input = this.buildInput(true);
    this.player.update(dt, input, ctx);
    this.consumeAttack();
    this.consumeQi();
    this.updateSwingArc(dt);
    const pbody = this.player.body;
    const prect = bodyRect(pbody);
    this.enemies.update(dt, pbody.x, pbody.y, prect, this.player.isInvulnerable(), ctx, pbody.vy);
    // 整改一：潜行感知（落地巨响/所处层/挥剑声源）；本层古镇警报跟踪供过层结算
    const cpNow = this.findCheckpoint(this.state.currentCheckpointId);
    const pfloor = cpNow ? cpNow.floor : 0;
    const landing = !wasGround && this.player.body.onGround && vyBefore < -420 ? -vyBefore : 0;
    // 新任务①：取消坠落伤害——落地冲击只作为潜行噪音源（stealth.update 的 landingSpeed），
    // 不再扣血；高空失足不再惩罚。
    this.stealth.update(dt, pbody.x, pbody.y, this.player.dashTimer > 0, {
      landingSpeed: landing > 0 ? landing : undefined,
      floor: pfloor,
      attackX: this.player.attack !== undefined ? pbody.x : undefined,
    });
    const alerted = this.stealth.anyAlerted();
    this.state.stealthAlert = alerted;
    if (alerted && pfloor === 1) {
      this.floor1Alert = true;
    }
    // 推石方向：接玩家水平输入（旧硬编码 0，机关推石永远不动——用户误以为是纯贴图）
    const pushDir = (input.right ? 1 : 0) - (input.left ? 1 : 0);
    this.mech.update(dt, prect, pushDir, this.playerAttackRect(), this.qiRects(), ctx);
    // 风息符文（F3 塔外环廊）：仅冲刺穿过激活，走路不触发
    if (this.player.dashTimer > 0) {
      this.mech.tryDashWindSigils(pbody.x, pbody.y);
    }
    this.clampPlayerToStones(prect);
    this.updateQiShots(dt, plats);
    if (pbody.y < -240 && (this.mode === "play" || this.mode === "confront")) {
      this.pitFall();
    }
    if (this.mode === "play") {
      this.mech.touchCheckpoints(Tower.checkpoints, pbody.x, pbody.y);
      this.mech.touchCollectibles(Tower.collectibles, pbody.x, pbody.y);
      this.checkStoryTriggers();
      this.checkHazards();
    }
    const boss = this.enemies.boss();
    if (boss && !this.state.storySeen["story_boss_intro"] && !this.state.flags.bossDown) {
      const b = boss.body;
      if (Math.abs(b.x - pbody.x) < 520 && Math.abs(b.y - pbody.y) < 320) {
        this.openDialog("story_boss_intro");
      }
    }
    this.regenIntent(dt);
    if (pbody.y < -80) {
      if (this.player.hurt(1, pbody.x)) {
        this.applyHurt(1);
      }
      if (this.state.heroineLife > 0) {
        this.respawnAt(this.state.currentCheckpointId);
      }
    }
  }

  private playerAttackRect(): Rect | undefined {
    return this.player.attack ? this.player.attack.hitbox : undefined;
  }

  // 人推箱子：玩家与石头实体互斥（速度同步后必须硬约束，否则人走进石头里穿模）。
  // 水平穿透 ≤30px 才推挤回贴面；从上方砸进中心的深穿透放行避免瞬移。
  private clampPlayerToStones(prect: Rect): void {
    const b = this.player.body;
    for (let i = 0; i < this.mech.stones.length; i++) {
      const s = this.mech.stones[i];
      const sx = s.x - s.w / 2;
      const sy = s.y - s.h / 2;
      const overlapX = prect.x < sx + s.w && prect.x + prect.w > sx;
      const overlapY = prect.y < sy + s.h && prect.y + prect.h > sy;
      if (!overlapX || !overlapY) {
        continue;
      }
      const penLeft = prect.x + prect.w - sx;
      const penRight = sx + s.w - prect.x;
      if (penLeft < penRight && penLeft <= 30) {
        b.x = sx - prect.w / 2;
      } else if (penRight < penLeft && penRight <= 30) {
        b.x = sx + s.w + prect.w / 2;
      }
    }
  }

  private consumeAttack(): void {
    const atk = this.player.attack;
    if (!atk) {
      this.attackApplied = false;
      return;
    }
    if (this.attackApplied) {
      return;
    }
    this.attackApplied = true;
    const hits = this.enemies.takeHit(atk.hitbox, 1, atk.dir, 220, this.player.body.x);
    // 整改二：树干命中判定——砍倒已种下的小树（两端同时枯成树桩，因果反噬）
    if (this.state.flags.treePlanted === true && this.state.flags.treeCut !== true) {
      const hb = atk.hitbox;
      const tx = 1120;
      if (hb.x < tx + 160 && hb.x + hb.w > tx && hb.y < Tower.TOPS[0] + 300 && hb.y + hb.h > Tower.TOPS[0]) {
        this.cutTree();
      }
    }
    if (hits > 0) {
      this.hitstop = 0.06;
      sfx("heroHit", 0.9);
      sfx("enemyHurt", 0.65);
      this.fx.spawnSpark(atk.hitbox.x + (atk.dir > 0 ? atk.hitbox.w : 0), atk.hitbox.y + atk.hitbox.h / 2, atk.dir);
    }
    if (this.state.flags.confront && !this.state.drawnBladeAgainst) {
      const dx = Math.abs(atk.hitbox.x + atk.hitbox.w / 2 - this.shenX());
      const dy = Math.abs(atk.hitbox.y + atk.hitbox.h / 2 - this.shenY());
      if (dx < 130 && dy < 130) {
        this.state.drawnBladeAgainst = true;
        this.state.flags.bladeClash = true;
        this.bladeT = 0.9;
        this.shake(0.3, 7);
        this.fx.spawnRing(this.shenX(), this.shenY() + 30, { r: 43, g: 40, b: 36, a: 255 }, 20, 180, 0.6);
        // 整改三补：剑锋相向记入时空树与因果账本
        if (this.tree !== undefined) {
          this.tree.addChoice("剑锋相向");
        }
        this.logCause("剑锋相向·因果断裂");
      }
    }
  }

  private consumeQi(): void {
    const req = this.player.qiReq;
    if (!req) {
      return;
    }
    this.player.qiReq = undefined;
    if (this.state.swordIntent < 1) {
      this.fx.spawnDust(req.x, req.y, req.dir);
      return;
    }
    this.state.swordIntent -= 1;
    sfx("sword", 1.0);
    this.qiShots.push({ x: req.x, y: req.y, dir: req.dir, life: 1.6, alive: true, phase: this.qiShots.length * 1.7, hits: 0, hitCd: 0, trailT: 0 });
    this.fx.spawnInkBurst(req.x, req.y, req.dir);
    this.sheetFx.spawn(req.x + req.dir * 14, req.y, req.dir, true);
    // 蓝色剑气挥击弧（K 发射）；qiSwingT 抑制普攻白弧重复触发
    this.slashFx.spawnSwing(req.x + req.dir * 10, req.y, req.dir, true);
    this.qiSwingT = 0.2;
  }

  // 普攻挥剑弧：每一段完整挥击（attackSeq 变化）都播白弧；seq 必消费避免 K 抑制窗口过后补弧
  private updateSwingArc(dt: number): void {
    if (this.qiSwingT > 0) {
      this.qiSwingT -= dt;
    }
    if (this.player.attackTimer <= 0) {
      this.lastSwingSeq = -1;
      return;
    }
    const seq = this.player.attackSeq;
    if (seq !== this.lastSwingSeq) {
      this.lastSwingSeq = seq;
      if (this.qiSwingT <= 0) {
        this.slashFx.spawnSwing(this.player.body.x + this.player.facing * 26, this.player.body.y + 8, this.player.facing, false);
      }
    }
  }

  private qiRects(): Rect[] {
    const list: Rect[] = [];
    for (let i = 0; i < this.qiShots.length; i++) {
      const q = this.qiShots[i];
      if (q.alive) {
        list.push({ x: q.x - 20, y: q.y - 32, w: 90, h: 64 });
      }
    }
    return list;
  }

  private updateQiShots(dt: number, plats: Platform[]): void {
    for (let i = 0; i < this.qiShots.length; i++) {
      const q = this.qiShots[i];
      if (!q.alive) {
        continue;
      }
      q.x += q.dir * 720 * dt;
      q.life -= dt;
      q.hitCd -= dt;
      q.trailT -= dt;
      if (q.trailT <= 0) {
        this.sheetFx.spawn(q.x - q.dir * 18, q.y, q.dir, false);
        q.trailT = 0.1;
      }
      if (q.life <= 0) {
        q.alive = false;
        continue;
      }
      const rect: Rect = { x: q.x - 20, y: q.y - 32, w: 90, h: 64 };
      if (q.hitCd <= 0 && this.enemies.takeHit(rect, 1, q.dir, 160) > 0) {
        q.hits += 1;
        q.hitCd = 0.22;
        this.hitstop = 0.05;
        this.fx.spawnInkBurst(q.x, q.y, q.dir);
        this.sheetFx.spawn(q.x + q.dir * 6, q.y, q.dir, true);
        if (q.hits >= 3) {
          q.alive = false;
          continue;
        }
      }
      for (let j = 0; j < plats.length; j++) {
        const p = plats[j];
        if (p.kind !== "one-way" && rectOverlap(rect, p)) {
          q.alive = false;
          this.fx.spawnDust(q.x, q.y, -q.dir);
          this.sheetFx.spawn(q.x, q.y, q.dir, false);
          break;
        }
      }
    }
  }

  private regenIntent(dt: number): void {
    if (this.state.swordIntent >= this.state.maxSwordIntent) {
      return;
    }
    this.intentRegenT += dt;
    if (this.intentRegenT >= 5) {
      this.intentRegenT = 0;
      this.state.swordIntent += 1;
    }
  }

  // 当前可对话的剧情触发点（重叠且未看过/可重复的；与传送门一致：靠近提示，按 E 才触发）
  private nearStoryId: string | undefined;
  // 男主立绘当前渲染位（drawNpcs 每帧更新）：对话提示统一挂其头顶（用户指令①）
  private shenRenderX = 0;
  private shenRenderY = 0;
  private shenRenderOk = false;
  // 进层自动播放的入口独白（用户指令②：进入场景自动播，不再按 E）
  private pendingFloorStory: string | undefined;
  private pendingFloorStoryFloor = 0;
  private pendingFloorStoryT = 0;
  // 1F 教学浮字：重叠即显示（不按 E、不进对话、不标 storySeen），离开触发带即消失。
  // 命名避开既有 hintText() 方法（底部键位提示行）
  private hintBubbleText: string | undefined;
  private hintBubbleX = 0;
  private hintBubbleY = 0;
  private hintBubbleBestD = 1e9;

  private checkStoryTriggers(): void {
    this.nearStoryId = undefined;
    this.hintBubbleText = undefined;
    this.hintBubbleBestD = 1e9;
    const prect = bodyRect(this.player.body);
    const trigs = Tower.storyTriggers;
    let bestD = 1e9;
    for (let i = 0; i < trigs.length; i++) {
      const t = trigs[i];
      // 教学浮字触发带（1F 图纸）：重叠即亮字，可重复，不需要交互键、不进剧情账
      if (t.hint !== undefined) {
        if (rectOverlap(prect, { x: t.x, y: t.y, w: t.w, h: t.h })) {
          // 同屏多带重叠时取离玩家最近的一条（提示框规格：只显示最近 1 个）
          const d = Math.abs(this.player.body.x - (t.x + t.w / 2));
          if (d < this.hintBubbleBestD) {
            this.hintBubbleBestD = d;
            this.hintBubbleText = t.hint;
            this.hintBubbleX = t.x + t.w;
            this.hintBubbleY = t.y + t.h;
          }
        }
        continue;
      }
      // 冷箭事件保持自动触发（突发演出，不给提示框）；其余剧情点同传送门：按 E 才对话
      if (t.storyId === "story_arrow") {
        if (!this.state.storySeen[t.storyId] && rectOverlap(prect, { x: t.x, y: t.y, w: t.w, h: t.h })) {
          this.openDialog(t.storyId);
          return;
        }
        continue;
      }
      if (t.once && this.state.storySeen[t.storyId]) {
        continue;
      }
      // 内心独白：走进触发带自动播放（用户指令②），不设按 E 提示、不入 nearStoryId
      if (this.isAutoMonologue(t.storyId)) {
        if (rectOverlap(prect, { x: t.x, y: t.y, w: t.w, h: t.h })) {
          this.openDialog(t.storyId);
          return;
        }
        continue;
      }
      if (rectOverlap(prect, { x: t.x, y: t.y, w: t.w, h: t.h })) {
        const d = Math.abs(this.player.body.x - (t.x + t.w / 2));
        if (d < bestD) {
          bestD = d;
          this.nearStoryId = t.storyId;
        }
      }
    }
  }

  private checkHazards(): void {
    const prect = bodyRect(this.player.body);
    const hs = Tower.hazards;
    for (let i = 0; i < hs.length; i++) {
      if (rectOverlap(prect, hs[i])) {
        if (this.player.hurt(hs[i].damage, this.player.body.x)) {
          this.applyHurt(hs[i].damage);
        }
        // 持续伤害（用户反馈）：不再强制弹跳（player.hurt 自带击退+上抛与 1.1s 无敌帧），
        // 玩家停在尖刺上按无敌帧节奏反复掉血，直到离开尖刺区
        break;
      }
    }
  }

  // Boss 血条只在玩家真正贴近 Boss（观星台 Boss 房内开战距离）时才显示，
  // 否则从出生起屏幕底部就挂着 6 层 Boss 的红条，看起来像一条无意义的血条。
  private nearBoss(): boolean {
    const b = this.enemies.boss();
    if (b === undefined) {
      return false;
    }
    return Math.abs(b.body.x - this.player.body.x) < 720 && Math.abs(b.body.y - this.player.body.y) < 240;
  }

  private onPlayerHit(dmg: number, fromX: number): void {
    if (this.player.hurt(dmg, fromX)) {
      this.applyHurt(dmg);
    }
  }

  private applyHurt(dmg: number): void {
    this.state.heroineLife = Math.max(0, this.state.heroineLife - dmg);
    this.hud.flashDamage();
    this.shake(0.22, 6);
    this.hitstop = 0.08;
    if (this.state.heroineLife <= 0) {
      this.die();
    }
  }

  private interact(): void {
    const px = this.player.body.x;
    const py = this.player.body.y;
    const portal = this.nearPortal(px, py);
    if (portal !== undefined) {
      this.startPortal(portal);
      return;
    }
    if (this.nearStoryId !== undefined) {
      const id = this.nearStoryId;
      this.nearStoryId = undefined;
      this.openDialog(id);
      return;
    }
    if (this.mech.tryLightLantern(Tower.lanterns, px, py)) {
      return;
    }
    // F5 星位：按序点亮（错序熄灭重来，返回 true 表示按键已被星位交互消耗）
    if (this.mech.tryLightStar(px, py)) {
      return;
    }
    // 整改一/二：渡口种树谜题 → 拾石子 → 推酒桶 → 救店小二
    if (this.tryTreePuzzle(px, py)) {
      return;
    }
    if (this.tryPebblePickup(px, py)) {
      return;
    }
    if (this.tryBarrel(px, py)) {
      return;
    }
    if (this.tryWaiter(px, py)) {
      return;
    }
    const nearShen = Math.abs(px - this.shenX()) < 90 && Math.abs(py - this.shenY()) < 140;
    if (this.state.flags.confront && nearShen) {
      this.putDownSword();
      return;
    }
    if (!this.state.storySeen["story_check_intro"] && nearShen) {
      this.openDialog("story_check_intro");
      return;
    }
    // 河滩初见兜底：贴身站在男主旁（触发带未覆盖的左侧贴身位）按 E 也能开场对话
    if (!this.state.storySeen["story_riverside"] && nearShen) {
      this.openDialog("story_riverside");
    }
  }

  private putDownSword(): void {
    this.state.drawnBladeAgainst = false;
    this.state.flags.putDownSword = true;
    if (this.state.shenyanTrust >= 4) {
      if (this.tree !== undefined) {
        this.tree.addChoice("重逢月满");
      }
      this.endGame("reunion");
    } else {
      this.state.objective = "他叹息离去——也许，还有下一次轮回。（回溯再试试）";
      this.loopAdvance();
    }
  }

  // 连问模式：当前对话可选的选项镜像（随 openDialog 过滤结果），供 onChoiceAsk 计算剩余
  private askList: DialogChoice[] = [];

  private openDialog(id: string): void {
    const node: StoryNode | undefined = STORY_NODES[id];
    if (node === undefined) {
      return;
    }
    this.state.storySeen[id] = true;
    if (node.setFlag) {
      this.state.flags[node.setFlag] = true;
    }
    if (node.objective) {
      this.state.objective = node.objective;
    }
    this.mode = "dialog";
    // {loops} 占位：观测者台词里的周目数（本局 = 第 7+回溯数 次轮回），动态替换
    const loops = "" + (7 + this.state.rewindCount);
    const lines = node.lines.map((ln) => ({ speaker: ln.speaker, text: ln.text.replace("{loops}", loops) }));
    // 连问模式（仅观测者保留）：过滤本轮回已问过的选项；其余节点选完一题、应答播完即收束（2026-10-26 用户裁定）
    const asked = this.state.askedChoices;
    const allChoices = node.choices;
    const openChoices = allChoices !== undefined ? allChoices.filter((c) => !asked[node.id + "|" + c.text]) : undefined;
    const runtime: StoryNode = { ...node, lines, choices: openChoices };
    this.askList = openChoices !== undefined ? openChoices.slice() : [];
    this.dialog.onChoiceAsk = (index: number) => this.onChoiceAsk(runtime, index);
    this.dialog.onChoice = (index: number) => this.applyChoice(runtime, index);
    const speaker = runtime.lines.length > 0 ? runtime.lines[0].speaker : "沈砚";
    this.dialog.open(runtime, speaker);
  }

  // 提问即时结算（连问模式）：信任/记忆立刻入账，剩余未问选项在应答播完后就地重开。
  private onChoiceAsk(node: StoryNode, index: number): void {
    const choice = node.choices !== undefined ? node.choices[index] : undefined;
    if (choice === undefined) {
      return;
    }
    this.state.shenyanTrust += choice.trust;
    if (choice.memory && this.state.memories.indexOf(choice.memory) < 0) {
      this.state.memories.push(choice.memory);
    }
    this.fx.spawnRing(this.player.body.x, this.player.body.y + 30, CYAN, 10, 90, 0.5);
    this.state.askedChoices[node.id + "|" + choice.text] = true;
    // 用户裁定（2026-10-26）：选完一个答案、听完应答即收束对话，不再弹出剩余选项——
    // 连问重开仅保留观测者节点；挡下冷箭后同样不回头问「（不挡）」（那一刻已定格）。
    let remaining: DialogChoice[] = [];
    if (node.id === "story_observer_1") {
      remaining = this.askList.filter((c) => !this.state.askedChoices[node.id + "|" + c.text]);
    }
    this.dialog.setNextChoices(remaining);
  }

  // 对话收束回调（应答播完/对话关闭）：只管演出与模式切换；
  // 信任/记忆结算已移至 onChoiceAsk（每次提问即时结算，支持一段对话连问多题）。
  private applyChoice(node: StoryNode, index: number): void {
    // 挡箭代价（用户需求）：替沈砚挡下冷箭 → 玩家真实受伤 + 受击特效（红晕/震屏/顿帧/击退）
    if (node.id === "story_arrow" && index === 0) {
      this.onPlayerHit(1, this.player.body.x + 60);
    }
    if (node.id === "story_final") {
      this.state.flags.confront = true;
      this.state.objective = "走近沈砚：E 放下剑 · Q 以命换命 · J 剑锋相向";
      this.mode = "confront";
    } else if (this.mode === "dialog") {
      this.mode = "play";
    }
  }

  private shenProgress(): number {
    const trigs = Tower.storyTriggers;
    let n = 0;
    for (let i = 0; i < trigs.length; i++) {
      if (this.state.storySeen[trigs[i].storyId]) {
        n += 1;
      }
    }
    return n;
  }

  private shenX(): number {
    if (this.state.flags.confront) {
      return 2200;
    }
    const xs = [560, 500, 650, 480, 520, 460];
    return xs[Math.min(this.shenProgress(), xs.length - 1)];
  }

  private shenY(): number {
    // 终局对峙固定在观星台（Boss 层顶）：旧逻辑按剧情进度取 TOPS[0..5]，满进度钉在 TOPS[5]=6700，
    // 而对峙发生在 F6（8000）——沈砚被放到另一层，E/Q/J 三个结局入口全部永远打不中（通关死锁根因）
    if (this.state.flags.confront) {
      return Tower.TOPS[Tower.TOPS.length - 1];
    }
    // 直接取层顶数据（场景隔离后各层 y 由 Tower.TOPS 决定，沈砚站位 0..5 层）
    const tops = Tower.TOPS;
    return tops[Math.min(this.shenProgress(), tops.length - 2)];
  }

  // 坠入虚空兜底：扣 1 命并回到检查点
  private pitFall(): void {
    this.state.heroineLife -= 1;
    this.hud.flashDamage();
    this.shake(0.3, 8);
    this.qiShots.length = 0;
    if (this.state.heroineLife <= 0) {
      this.die();
      return;
    }
    this.respawnAt(this.state.currentCheckpointId);
  }

  private onEnemyDeath(def: EnemySpawn, x: number, y: number): void {
    this.fx.spawnMist(def.x, def.y, def.kind === "boss" ? 10 : 4, def.kind === "boss" ? 1.6 : 1);
    this.boomFx.spawn(x, y + 40, def.kind === "boss");
    // 整改一：古镇层（f1）杀敌跟踪——过层结算「不杀奖励」的反证条件
    if (def.floor === 1) {
      this.floor1Kill = true;
    }
    if (def.kind === "boss") {
      this.shake(0.5, 9);
      this.startConfront();
    }
    if (def.id === "e00" && !this.state.flags.banditDown) {
      this.state.flags.banditDown = true;
      this.state.objective = "强盗已退——登上东边木梯（W 攀爬），进入古镇街巷";
    }
  }

  private startConfront(): void {
    this.state.flags.bossDown = true;
    if (this.tree !== undefined) {
      this.tree.extend("斩观星者");
    }
    this.openDialog("story_final");
  }

  // 整改三：HP 归零不再直接结局——上限>1 时进入死亡回溯（本层重来）；上限耗尽才「力竭而终」
  private die(): void {
    this.mode = "dead";
    if (this.state.maxLife <= 1) {
      if (this.tree !== undefined) {
        this.tree.addChoice("力竭而终");
      }
      this.logCause("力竭而终·月相永滞");
      this.endGame("exhausted"); // 走统一结局链（mode=ending+入仓+R 回标题）；旧 hud.showEnding 直调漏了这些
      return;
    }
    this.deadT = 0.8;
    this.hud.flashDamage();
    this.state.objective = "月相逆卷——正在回溯本层……（R 立即回溯）";
  }

  // 整改三：R/死亡触发的本层回溯（耗 1 格 HP 上限，月相推进，复位本层机关与警报）
  private startRewind(): void {
    if (this.mode === "ending" || this.mode === "title" || this.mode === "prologue") {
      return;
    }
    this.hud.hideEnding();
    this.mode = "rewind";
    this.rewindT = 0;
    this.causFx.play("rewind", "月相逆卷·本层回溯");
    rewindFloor(this.state);
    this.hud.setRewind(0);
  }

  // 2 秒回溯演出结束：回本层检查点，敌人重置、潜行复位
  private doRewind(): void {
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
    this.stealth.resetRuntime();
    this.floor1Kill = false;
    this.floor1Alert = false;
    this.qiShots.length = 0;
    if (!this.treeDeathSeen && !this.treeJumpPending) {
      this.treeDeathSeen = true;
      if (this.tree !== undefined) {
        this.tree.extend("殒落再临");
      }
    }
    this.treeJumpPending = false;
    this.respawnAt(this.state.currentCheckpointId);
    this.mode = "play";
  }

  // 布尔记录浅拷贝（快照用；直引用会让跳回后的改动污染历史节点快照）
  private copyBoolRecord(src: Record<string, boolean>): Record<string, boolean> {
    const out: Record<string, boolean> = {};
    for (const k in src) {
      out[k] = src[k];
    }
    return out;
  }

  // 深拷贝循环状态：值/串逐字段、布尔记录浅拷、字符串数组切拷，构成可独立演化的世界快照
  private cloneLoopState(s: LoopState): LoopState {
    return {
      loopIndex: s.loopIndex,
      phaseIndex: s.phaseIndex,
      heroineLife: s.heroineLife,
      maxLife: s.maxLife,
      swordIntent: s.swordIntent,
      maxSwordIntent: s.maxSwordIntent,
      shenyanTrust: s.shenyanTrust,
      drawnBladeAgainst: s.drawnBladeAgainst,
      rewindCount: s.rewindCount,
      moonstones: s.moonstones,
      mechanismParts: s.mechanismParts,
      tokens: s.tokens,
      memories: s.memories.slice(),
      flags: this.copyBoolRecord(s.flags),
      cutRopes: this.copyBoolRecord(s.cutRopes),
      rungBells: this.copyBoolRecord(s.rungBells),
      platesActive: this.copyBoolRecord(s.platesActive),
      lanternsLit: this.copyBoolRecord(s.lanternsLit),
      lanternSequence: s.lanternSequence,
      lanternFailed: s.lanternFailed,
      openedGates: this.copyBoolRecord(s.openedGates),
      collectedIds: this.copyBoolRecord(s.collectedIds),
      checkpointsActivated: this.copyBoolRecord(s.checkpointsActivated),
      currentCheckpointId: s.currentCheckpointId,
      storySeen: this.copyBoolRecord(s.storySeen),
      askedChoices: this.copyBoolRecord(s.askedChoices),
      objective: s.objective,
      stealthAlert: s.stealthAlert,
      sneakBonus: s.sneakBonus,
      rewindPenalty: s.rewindPenalty,
      pebbles: s.pebbles,
      causalityLog: s.causalityLog.slice(),
    };
  }

  // 整改三补·时空树跳回（真回溯）：恢复该节点长成瞬间的完整世界快照
  //（生命/旗标/夜数/机关与剧情记录），敌人机关重刷、相机落回该节点检查点，
  // 随后 2s 回溯演出；收尾 doRewind 借 treeJumpPending 不再重复定位/长枝。
  private jumpToNode(id: string): void {
    const snap = this.treeSnap[id];
    if (snap === undefined) {
      return; // 无快照的节点（旧存档残留）不动作
    }
    if (this.dialog.isOpen() || this.teleportT >= 0) {
      return; // 对话/传送演出进行中不跳回，避免互踩
    }
    // 剧情认知不随跳回回退：已看过的对话/已问过的问题/已获记忆按并集合回。
    // 否则跳回旧节点（根「启程」/「初临河滩」快照都在 F0 对话发生之前）
    // 会把第一层沈砚对话与独白整段重播（玩家反馈：第一层重复对话）。
    const prevSeen = this.state.storySeen;
    const prevAsked = this.state.askedChoices;
    const prevMemories = this.state.memories.slice();
    this.state = this.cloneLoopState(snap);
    for (const k in prevSeen) {
      this.state.storySeen[k] = true;
    }
    for (const k in prevAsked) {
      this.state.askedChoices[k] = true;
    }
    for (let i = 0; i < prevMemories.length; i++) {
      if (this.state.memories.indexOf(prevMemories[i]) < 0) {
        this.state.memories.push(prevMemories[i]);
      }
    }
    this.mech.state = this.state;
    this.mech.syncStones(Tower.pushStones);
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
    this.stealth.resetRuntime();
    this.qiShots.length = 0;
    this.attackApplied = false;
    this.intentRegenT = 0;
    this.bladeT = 0;
    this.floor1Kill = false;
    this.floor1Alert = false;
    // 新世界线随探索重新生长：进层/开闸/殒落去重清零
    this.treeFloorSeen = {};
    this.treeGateSeen = {};
    this.treeDeathSeen = false;
    this.treeJumpPending = true;
    this.respawnAt(this.state.currentCheckpointId);
    this.mode = "rewind";
    this.rewindT = 0;
    this.causFx.play("rewind", "时空回溯·跳回节点");
    this.hud.setRewind(0);
  }

  private respawnAt(id: string): void {
    const cp = this.findCheckpoint(id);
    const x = cp ? cp.x : 800;
    // 出生即站在地面（旧 +90 会从空中掉落）；换层后切本层配乐
    const y = (cp ? cp.y : 320) + 42;
    this.player.respawn(x, y);
    this.camX = x;
    this.camY = y;
    this.renderer.setFloorScene(cp ? cp.floor : 0);
    this.playFloorBgm();
    // 进入场景自动播放该层入口独白（用户指令②）；回溯回已看过的层 storySeen 守卫不会重播
    if (cp !== undefined) {
      const intro = this.floorIntroStory(cp.floor);
      if (intro !== undefined) {
        this.pendingFloorStory = intro;
        this.pendingFloorStoryFloor = cp.floor;
        this.pendingFloorStoryT = 0.6;
      }
    }
  }

  // —— 传送门：靠近显示“按 E 进入”，按 E 才触发：黑幕淡出 → 换层重定位（背景整块切换）→ 淡入 ——
  private teleportT = -1;
  private pendingPortalTarget: { cpId: string; floor: number; x: number; y: number } | undefined;

  // 玩家是否站在某传送门旁（同层地面）；传送冷却中/非游玩模式返回 undefined（提示与交互共用同一判定）
  private nearPortal(px: number, py: number): PortalDef | undefined {
    if (this.teleportT >= 0 || this.mode !== "play") {
      return undefined;
    }
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    const floor = cp ? cp.floor : -1;
    for (let i = 0; i < Tower.portals.length; i++) {
      const p = Tower.portals[i];
      // 传送门 gating：本层玩法未通关（gateId 未开）时传送门尚未产生，不可交互
      if (p.gateId !== undefined && this.mech.isGateOpen(p.gateId) !== true) {
        continue;
      }
      if (p.floor === floor && Math.abs(px - p.x) < PORTAL_USE_RADIUS && Math.abs(py - (p.y + 55)) < 95) {
        return p;
      }
    }
    return undefined;
  }

  // E 键确认进入：沿用原自动触发的那套换层流程（黑幕/检查点重定位/setFloorScene 全保留）
  private startPortal(p: PortalDef): void {
    const cp = this.checkpointOfFloor(p.targetFloor);
    if (cp === undefined) {
      return;
    }
    this.teleportT = 0;
    this.pendingPortalTarget = { cpId: cp.id, floor: cp.floor, x: cp.x, y: cp.y };
    this.fx.spawnStars(p.x, p.y + 50, 8);
    this.shake(0.2, 3);
  }

  private checkpointOfFloor(floor: number): { id: string; x: number; y: number; floor: number } | undefined {
    for (let i = 0; i < Tower.checkpoints.length; i++) {
      const c = Tower.checkpoints[i];
      if (c.floor === floor) {
        return { id: c.id, x: c.x, y: c.y, floor: c.floor };
      }
    }
    return undefined;
  }

  private advanceTeleport(dt: number): void {
    this.teleportT += dt;
    const t = this.pendingPortalTarget;
    if (t !== undefined && this.teleportT >= 0.45) {
      this.pendingPortalTarget = undefined;
      this.state.currentCheckpointId = t.cpId;
      this.state.checkpointsActivated[t.cpId] = true;
      // 整改三：过层恢复 HP 上限（本层回溯消耗的格数不复原到下一层）
      restoreFloorCap(this.state);
      this.settleFloorSneak(t.floor);
      this.respawnAt(t.cpId);
      this.growFloor(t.floor);
      this.camY = t.y + 160;
      this.fx.spawnRing(t.x, t.y + 60, GOLD, 16, 170, 0.7);
    }
    if (this.teleportT >= 0.9) {
      this.teleportT = -1;
    }
  }

  private teleportFade(): number {
    if (this.teleportT < 0) {
      return 0;
    }
    if (this.teleportT < 0.45) {
      return this.teleportT / 0.45;
    }
    return Math.max(0, 1 - (this.teleportT - 0.45) / 0.45);
  }

  private syncFloorScene(): void {
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    this.renderer.setFloorScene(cp ? cp.floor : 0);
  }

  // 整改二：本层可用梯子 = 常规梯 + 种树谜题攀树梯（种下且未砍时出现）
  private activeLadders(): Ladder[] {
    if (this.state.flags.treePlanted === true && this.state.flags.treeCut !== true) {
      return TREE_LADDER;
    }
    return Tower.ladders;
  }

  // 因果账本：写入手札「因果」栏（只展示最近 4 条，超过 12 条裁剪）；同文只记一次（重复浇灌/回溯重演不刷屏）
  private logCause(text: string): void {
    if (this.state.causalityLog.indexOf(text) >= 0) {
      return;
    }
    this.state.causalityLog.push(text);
    if (this.state.causalityLog.length > 12) {
      this.state.causalityLog.splice(0, this.state.causalityLog.length - 12);
    }
  }

  private floorOfCheckpoint(): number {
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    return cp ? cp.floor : 0;
  }

  // 整改一：丢石子——前方落地声引开附近守卫视线（不消耗剑意）
  private throwPebble(): void {
    if (this.state.pebbles <= 0) {
      return;
    }
    this.state.pebbles -= 1;
    const px = this.player.body.x;
    const py = this.player.body.y;
    const landX = px + this.player.facing * 260;
    this.stealth.emitNoise(landX, this.floorOfCheckpoint(), 320);
    this.fx.spawnDust(landX, py, this.player.facing);
    sfx("dash", 0.4);
    this.state.objective = "石子落地——附近的守卫被吸引了过去";
  }

  // 整改二：渡口种树谜题（教学必做）——打水（井 860）→ 移苗（700）→ 种下（枯坑 1200）
  private tryTreePuzzle(px: number, py: number): boolean {
    if (this.state.flags.treeCut === true) {
      return false;
    }
    if (this.floorOfCheckpoint() !== 0 || Math.abs(py - (Tower.TOPS[0] + 42)) > 90) {
      return false;
    }
    const planted = this.state.flags.treePlanted === true;
    if (!planted && this.state.flags.saplingTaken !== true && Math.abs(px - 700) < 90) {
      this.state.flags.saplingTaken = true;
      this.logCause("渡口移苗·根带旧土");
      sfx("click", 0.9);
      this.fx.spawnStars(px, py + 40, 6);
      this.state.objective = "树苗在手——东边枯坑（x≈1200）在等它；路过水井（x≈860）可先打一桶水";
      return true;
    }
    if (this.state.flags.bucketFull !== true && Math.abs(px - 860) < 90) {
      this.state.flags.bucketFull = true;
      this.logCause("井水打满·一桶月色");
      this.causFx.play("fill", "一桶井水");
      this.state.objective = "水已打好——去移树苗（x≈700），再种进枯坑（x≈1200）";
      return true;
    }
    if (!planted && Math.abs(px - 1200) < 100) {
      if (this.state.flags.saplingTaken === true) {
        this.state.flags.treePlanted = true;
        this.state.flags.saplingTaken = false;
        if (this.state.flags.bucketFull === true) {
          // 用户需求③：桶中之水随苗倒进枯坑——种下后井（x≈860）仍可再打水，回坑边即可浇灌
          this.state.flags.bucketFull = false;
        }
        this.mech.openGate("gate_ferry"); // F0 通关：传送门 pt_f0（gateId=gate_ferry）自此产生
        if (this.tree !== undefined) {
          this.tree.addChoice("种下树苗");
        }
        this.logCause("枯坑种树·因果成立");
        this.causFx.play("grow", "种下·对岸月影同时落地");
        this.fx.spawnRing(px, py + 30, CYAN, 14, 130, 0.8);
        sfx("click", 1.0);
        this.state.objective = "树影成双——月华凝成新的月石（攀树梯而上，x≈1180 按 W）；渡口尽头的传送门亮起了";
        return true;
      }
      this.state.objective = "枯坑沉默着……像在等一株树苗（西边有井，也有苗）";
      return true;
    }
    // 用户需求③：种下之后仍可打水浇灌——拎满水桶回到小树旁（x≈1200）按 E 浇下
    if (planted && this.state.flags.bucketFull === true && Math.abs(px - 1200) < 100) {
      this.state.flags.bucketFull = false;
      this.logCause("月色浇灌·新苗抽枝");
      this.causFx.play("grow", "浇灌·月华入土");
      this.fx.spawnRing(px, py + 30, CYAN, 12, 120, 0.7);
      sfx("click", 1.0);
      this.state.objective = "浇透了——小树轻轻颤了颤；井（x≈860）随时可再打一桶";
      return true;
    }
    return false;
  }

  // 整改二：砍树——两端同时枯成树桩（因果反噬；树冠月石随之湮灭不可及）
  private cutTree(): void {
    this.state.flags.treeCut = true;
    if (this.tree !== undefined) {
      this.tree.addChoice("砍倒小树");
    }
    this.logCause("刀落砍树·两树同枯");
    this.causFx.play("cut", "砍伐·因果反噬");
    this.shake(0.35, 7);
    sfx("enemyHurt", 0.8);
    this.state.objective = "树桩无言——砍倒它，树冠上的月华也随之湮灭";
  }

  // 整改一：拾石子（古镇层一次性 3 枚）
  private tryPebblePickup(px: number, py: number): boolean {
    if (this.floorOfCheckpoint() !== 1 || this.state.pebbles > 0) {
      return false;
    }
    if (Math.abs(px - 1450) < 80 && Math.abs(py - (Tower.TOPS[1] + 42)) < 90) {
      this.state.pebbles = 3;
      this.logCause("拾起石子·三枚");
      sfx("click", 0.9);
      this.state.objective = "拾起 3 枚石子——Q 丢向前方，引开守卫视线";
      return true;
    }
    return false;
  }

  // 整改一：推倒酒桶——震晕附近守卫并掩盖一瞬（隐秘通过的机会）
  private tryBarrel(px: number, py: number): boolean {
    if (this.floorOfCheckpoint() !== 1 || this.state.flags.barrelDown === true) {
      return false;
    }
    if (Math.abs(px - 1900) < 90 && Math.abs(py - (Tower.TOPS[1] + 42)) < 90) {
      const left = this.player.facing < 0;
      this.state.flags.barrelDown = true;
      this.state.flags.barrelLeft = left;
      const fallX = left ? 1760 : 2040;
      this.enemies.stunNear(fallX, 1, 180, 3.5);
      this.stealth.emitNoise(fallX, 1, 340);
      this.shake(0.35, 8);
      sfx("enemyHurt", 0.8);
      this.logCause("酒桶砸落·震慑一时");
      this.state.objective = "酒桶轰然砸落——附近守卫被震晕了（趁现在！）";
      return true;
    }
    return false;
  }

  // 整改一：救出被绑的店小二（剑意上限+1）
  private tryWaiter(px: number, py: number): boolean {
    if (this.floorOfCheckpoint() !== 1 || this.state.flags.waiterFreed === true) {
      return false;
    }
    if (Math.abs(px - 1985) < 80 && Math.abs(py - (Tower.TOPS[1] + 42)) < 90) {
      this.state.flags.waiterFreed = true;
      addTrust(this.state, 1);
      if (this.tree !== undefined) {
        this.tree.addChoice("救出店小二");
      }
      this.logCause("割绳救人·剑意上限+1");
      this.state.maxSwordIntent += 1;
      this.state.swordIntent = this.state.maxSwordIntent;
      this.causFx.play("rescue", "救人·剑意上限 +1");
      sfx("click", 1.0);
      this.state.objective = "店小二低声道：别走大道……酒桶后面能蹲人。";
      return true;
    }
    return false;
  }

  // 整改一：古镇（第2层）过层结算——无杀无警：剑意上限+1（潜行奖励）；杀敌/遇警记入因果
  private settleFloorSneak(arrivedFloor: number): void {
    if (arrivedFloor !== 2 || this.state.flags.floor1Settled === true) {
      return;
    }
    this.state.flags.floor1Settled = true;
    if (!this.floor1Kill && !this.floor1Alert) {
      this.state.sneakBonus = true;
      this.state.maxSwordIntent += 1;
      this.state.swordIntent = this.state.maxSwordIntent;
      if (this.tree !== undefined) {
        this.tree.addChoice("古镇不杀");
      }
      this.logCause("古镇不杀·剑意上限+1");
      this.fx.spawnRing(this.player.body.x, this.player.body.y + 40, GOLD, 12, 110, 0.8);
      this.state.objective = "潜行奖励：全程不杀而穿过古镇——剑意上限 +1";
    } else if (this.floor1Kill) {
      if (this.tree !== undefined) {
        this.tree.addChoice("杀出古镇");
      }
      this.logCause("杀出古镇·血染街巷");
    } else {
      this.logCause("古镇遇警·惊动街巷");
    }
    this.floor1Kill = false;
    this.floor1Alert = false;
  }

  // 整改一：酒馆店小二（被绑/获救）与石子堆（程序绘制，无新素材依赖）
  private drawFloor1Npcs(d: DrawNode.Type, p: { x: number; y: number }): void {
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    const floor = cp ? cp.floor : 0;
    const wy = Tower.TOPS[1];
    if (Math.abs(p.x - 1985) < 1100 && Math.abs(p.y - (wy + 60)) < 700) {
      const freed = this.state.flags.waiterFreed === true;
      d.drawPolygon([Vec2(1975, wy), Vec2(1995, wy), Vec2(1993, wy - 44), Vec2(1977, wy - 44)], Color(74, 62, 56, 255));
      d.drawDot(Vec2(1985, wy - 54), 9, Color(216, 192, 162, 255));
      if (freed) {
        d.drawSegment(Vec2(1995, wy - 40), Vec2(2007, wy - 60), 3, Color(216, 192, 162, 255));
      } else {
        d.drawSegment(Vec2(1971, wy - 30), Vec2(1999, wy - 30), 3, Color(126, 94, 60, 255));
      }
    }
    if (this.state.pebbles === 0 && floor === 1 && Math.abs(p.x - 1450) < 900 && Math.abs(p.y - (wy + 60)) < 500) {
      d.drawPolygon([Vec2(1430, wy), Vec2(1472, wy), Vec2(1462, wy - 16), Vec2(1440, wy - 16)], Color(120, 118, 112, 255));
      d.drawDot(Vec2(1450, wy - 22), 6, Color(150, 148, 140, 255));
    }
  }

  private loopAdvance(): void {
    this.state.loopIndex += 1;
    this.state.shenyanTrust = 0;
    this.state.memories.length = 0;
    // 时空树：夜轮小结枝（第 N 夜·重溯河滩），进层去重随夜重置
    this.growNight();
    this.treeFloorSeen = {};
    this.treeDeathSeen = false;
    this.applyLoopVariants();
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
    this.stealth.resetRuntime();
    this.state.currentCheckpointId = "cp_riverbank";
    this.respawnAt(this.state.currentCheckpointId);
    this.mode = "rewind";
    this.rewindT = 0;
  }

  private applyLoopVariants(): void {
    this.state.cutRopes = {};
    this.state.rungBells = {};
    this.state.platesActive = {};
    this.state.lanternsLit = {};
    this.state.lanternSequence = 0;
    this.state.lanternFailed = false;
    this.state.openedGates = {};
    this.state.swordIntent = this.state.maxSwordIntent;
    this.state.flags.confront = false;
    this.state.flags.bladeClash = false;
    this.state.flags.putDownSword = false;
    this.state.flags.floor1Settled = false;
    // 传送门 gating：新循环 openedGates 已清空，F0 种树谜题必须可重做，
    // 否则 gate_ferry 二周目无法再开、渡口传送门永久隐藏（死锁）。
    this.state.flags.treePlanted = false;
    this.state.flags.saplingTaken = false;
    this.state.flags.treeCut = false;
    this.state.flags.bucketFull = false;
    this.mech.syncStones(Tower.pushStones);
  }

  private endGame(id: string): void {
    this.endingId = id;
    this.hud.setRewind(-1);
    this.mode = "ending";
    this.hud.showEnding(id);
    this.archiveRun(id);
    playBgm("calm", 2.0);
  }

  /** 通关入仓：玩家名 + 本局独一无二的时空树快照 */
  private archiveRun(endingId: string): void {
    if (this.treeArchived) {
      return;
    }
    this.treeArchived = true;
    const e = ENDINGS[endingId];
    const name = this.playerName !== "" ? this.playerName : (loadPlayerName() !== "" ? loadPlayerName() : DEFAULT_NAME);
    const entry: ArchiveEntry = {
      name: name,
      endingTitle: e !== undefined ? e.title : endingId,
      rewindCount: this.tree !== undefined ? this.tree.rewindCount : 0,
      currentId: this.tree !== undefined ? this.tree.currentId : "",
      nodes: this.tree !== undefined ? this.tree.nodes : [],
    };
    appendArchive(entry);
  }

  private toTitle(): void {
    this.hud.hideEnding();
    this.paused = false;
    this.hud.setPauseVisible(false);
    this.resetRun();
    this.sheetFx.clear();
    this.renderer.setPrompt(0, 0, undefined);
    playBgm("cover", 1.0); // playStream 交叉淡出旧曲，无缝回到封面配乐
    this.mode = "title";
    this.hud.setTitleVisible(true);
  }

  private hintText(): string {
    if (this.mode === "confront") {
      return "走近沈砚：E 放下剑 · Q 以命换命 · J 剑锋相向 · Tab 手札";
    }
    // 传送/对话提示已改为门旁/NPC 头顶浮动气泡（syncInteractPrompt），底部不再重复
    if (this.mode === "play" && (this.nearPortal(this.player.body.x, this.player.body.y) !== undefined || this.nearStoryId !== undefined)) {
      return "";
    }
    if (this.player.onLadder) {
      return "W/S 攀爬 · 到顶后按 Space 跳向右侧平台";
    }
    return ""; // 常驻键位教学行已按需求删除
  }

  // 男主立绘 Sprite：按纹理高归一化到 90px、锚底中心；按序尝试候选路径，全失败返回 undefined（回退水墨小人）
  private makeNpcSprite(paths: string[], parent: Node.Type, tag: string): Sprite.Type | undefined {
    let tex: Texture2D.Type | undefined;
    let used = "";
    for (const p of paths) {
      tex = Texture2D(p);
      if (tex !== undefined) {
        used = p;
        break;
      }
    }
    if (tex === undefined || used === "") {
      print("[" + tag + "] texture load failed: " + paths.join(" | "));
      return undefined;
    }
    print("[" + tag + "] loaded " + used + " (" + tex.width + "x" + tex.height + ")");
    const sp = Sprite(tex);
    if (sp === undefined) {
      return undefined;
    }
    const s = 90 / tex.height;
    sp.scaleX = s;
    sp.scaleY = s;
    sp.anchor = Vec2(0.5, 0);
    sp.visible = false;
    sp.addTo(parent);
    return sp;
  }

  private drawNpcs(): void {
    const p = this.player.body;
    const d = this.npcDraw;
    this.drawFloor1Npcs(d, p);
    this.shenRenderOk = false;
    this.obsNode.position = this.npcDraw.position; // 观测者立绘层随相机偏移（同男主层机制，缺失会导致立绘飞出屏幕）
    // 观测者贴地：makeNpcSprite 锚点=底部中心（position.y=脚底），旧 -40 使立绘陷入地面半身
    const obsY = Tower.TOPS[3];
    const obsNear = Math.abs(p.x - 800) < 1300 && Math.abs(p.y - obsY) < 900;
    if (this.obsSp !== undefined) {
      // 观测者立绘（用户素材，90px 贴地）：面向玩家；缺图回退程序水墨小人
      this.obsSp.visible = obsNear;
      if (obsNear) {
        this.obsSp.position = Vec2(800, obsY);
        this.obsSp.scaleX = Math.abs(this.obsSp.scaleX) * (p.x > 800 ? 1 : -1);
      }
    } else if (obsNear) {
      drawObserver(d, 800, obsY, this.time);
    }
    // 显示站位滞后：对话推进后不瞬移（用户反馈「对话完消失/只在一楼可见」），
    // 直到玩家接近新站位（水平 1200 / 垂直 900 内）才把立绘挪过去，换位发生在屏幕外。
    let sx: number;
    let sy: number;
    let hideShen = false; // 用户需求②：塔外环廊（F3）不渲染男主立绘
    if (this.state.flags.confront) {
      sx = 2200;
      sy = this.shenY();
    } else {
      // 用户需求⑤：F4 槽位改机关层挡箭剧情点（st7 x1900，沈砚在此中箭）；F5 观星者之间不再布置立绘
      const xs = [560, 500, 650, 480, 1900, 460];
      const tops = Tower.TOPS;
      const target = Math.min(this.shenProgress(), xs.length - 1);
      if (target < this.shenShownIdx) {
        this.shenShownIdx = target; // 回溯/重置后自动复位
      } else if (target > this.shenShownIdx) {
        const nx = xs[target];
        const ny = tops[Math.min(target, tops.length - 2)];
        // F3 站位已隐藏（用户需求②）：进度可无声推进，无需靠近
        if (Math.min(target, tops.length - 2) === 3 || (Math.abs(p.x - nx) < 1200 && Math.abs(p.y - ny) < 900)) {
          this.shenShownIdx = target;
        }
      }
      const idx = Math.min(this.shenShownIdx, target);
      sx = xs[idx];
      sy = tops[Math.min(idx, tops.length - 2)];
      // 用户需求②/⑤：塔外环廊（3 层）与观星者之间（5 层）不放男主立绘，剧情提示回落到触发带中心
      hideShen = Math.min(idx, tops.length - 2) === 3 || Math.min(idx, tops.length - 2) === 5;
    }
    if (this.mode !== "ending" && !hideShen && Math.abs(p.x - sx) < 1400) {
      this.shenRenderX = sx;
      this.shenRenderY = sy;
      this.shenRenderOk = true;
      const dark = this.state.flags.confront && this.shenSpDark !== undefined ? this.shenSpDark : this.shenSpNormal;
      if (this.shenSpNormal !== undefined) {
        this.shenSpNormal.visible = dark === this.shenSpNormal;
      }
      if (this.shenSpDark !== undefined) {
        this.shenSpDark.visible = dark === this.shenSpDark;
      }
      if (dark !== undefined) {
        // 男主立绘：贴地站桩、面向玩家；敌对(confront)切黑化版
        this.shenNode.position = this.npcDraw.position; // 跳随相机偏移，与 npcDraw 同步
        dark.position = Vec2(sx, sy);
        dark.scaleX = Math.abs(dark.scaleX) * (p.x > sx ? 1 : -1);
      } else {
        drawShenYan(d, sx, sy, p.x > sx ? -1 : 1, this.time, this.state.flags.confront);
      }
    } else {
      if (this.shenSpNormal !== undefined) {
        this.shenSpNormal.visible = false;
      }
      if (this.shenSpDark !== undefined) {
        this.shenSpDark.visible = false;
      }
    }
    const blueTexReady = this.slashFx.hasBlueTex();
    const shots: ShotSync[] = [];
    for (let i = 0; i < this.qiShots.length; i++) {
      const q = this.qiShots[i];
      if (!q.alive) {
        continue;
      }
      const wob = Math.sin(this.time * 22 + q.phase) * 4;
      // 蓝色剑气贴图可用时，弹体由 SlashFx 精灵渲染；缺图回退程序化月牙
      if (blueTexReady) {
        shots.push({ x: q.x, y: q.y + wob, dir: q.dir });
        continue;
      }
      const buildCres = (scale: number, ox: number): Vec2.Type[] => {
        const pts: Vec2.Type[] = [];
        const R = 46 * scale;
        const aOut = 1.45;
        for (let k = 0; k <= 10; k++) {
          const t = aOut - (2 * aOut * k) / 10;
          pts.push(Vec2(q.x + q.dir * (ox + R * Math.cos(t)), q.y + wob + R * Math.sin(t)));
        }
        const c2 = -0.6 * R;
        const ri = 1.2266 * R;
        const aIn = 0.9425;
        for (let k = 0; k <= 10; k++) {
          const t = -aIn + (2 * aIn * k) / 10;
          pts.push(Vec2(q.x + q.dir * (ox + c2 + ri * Math.cos(t)), q.y + wob + ri * Math.sin(t)));
        }
        return pts;
      };
      d.drawPolygon(buildCres(0.72, -38), Color(CYAN.r, CYAN.g, CYAN.b, 42));
      d.drawPolygon(buildCres(0.86, -18), Color(CYAN.r, CYAN.g, CYAN.b, 82));
      d.drawPolygon(buildCres(1.0, 0), Color(CYAN.r, CYAN.g, CYAN.b, 150));
      d.drawPolygon(buildCres(0.6, 7), Color(255, 255, 255, 215));
    }
    if (blueTexReady) {
      this.slashFx.syncShots(shots);
    }
  }

  private updateVisuals(dt: number, shakeX: number, shakeY: number): void {
    const view = View.size;
    const active = this.mode === "play" || this.mode === "confront" || this.mode === "dialog" || this.mode === "rewind" || this.mode === "dead" || this.mode === "ending";
    if (active) {
      const tx = clamp(this.player.body.x, view.width / 2, Tower.WORLD_W - view.width / 2);
      // 相机最低高度锚定 0 层地面：地面顶边几乎贴住屏幕底缘（距底 8px，会话框式贴底）
      const ty = clamp(this.player.body.y + 70, Tower.TOPS[0] + view.height / 2 - 56, Tower.WORLD_H - view.height / 2);
      const k = Math.min(1, dt * 6);
      // 用户要求：人物始终水平居中——X 即时跟随，相机同步平移（无追赶延迟）；Y 保留平滑防跳跃抖动。
      this.camX = tx;
      this.camY += (ty - this.camY) * k;
    } else {
      this.camX = 800;
      this.camY = 400;
    }
    // 与 worldRoot 同步（屏幕中心原点）：fx/npc/立绘均按世界坐标绘制，直接取负相机
    this.fxDraw.position = Vec2(-this.camX + shakeX, -this.camY + shakeY);
    this.npcDraw.position = this.fxDraw.position;
    this.sheetNode.position = this.fxDraw.position;
    this.fx.update(dt);
    this.sheetFx.update(dt);
    this.boomFx.update(dt);
    this.slashFx.update(dt);
    this.fxDraw.clear();
    this.fx.draw(this.fxDraw);
    this.npcDraw.clear();
    if (this.mode !== "title" && this.mode !== "prologue") {
      this.drawNpcs();
    }
    this.renderer.setWorldVisible(this.mode !== "title" && this.mode !== "prologue");
    this.renderer.setCamera(this.camX, this.camY, shakeX, shakeY);
    // 整改一/二：树谜题阶段与酒桶倒伏同步到场景引用
    this.renderer.syncTreePuzzle(this.state.flags);
    this.renderer.syncBarrel(dt, this.state.flags.barrelDown === true, this.state.flags.barrelLeft === true);
    this.renderer.update(dt, this.state, this.player, this.enemies, this.mech, this.time);
    this.syncInteractPrompt();
    const cpNow = this.findCheckpoint(this.state.currentCheckpointId);
    const floorNow = Math.max(0, Math.min(cpNow ? cpNow.floor : 0, Tower.FLOORS.length - 1));
    this.hud.update(dt, {
      state: this.state,
      player: this.player,
      boss: this.nearBoss() ? this.enemies.boss() : undefined,
      objective: this.state.objective,
      mission: Tower.FLOOR_MISSIONS[Math.min(floorNow, Tower.FLOOR_MISSIONS.length - 1)],
      floorName: Tower.FLOORS[floorNow],
      guideLight: floorNow === 6 || floorNow === 4, // 观星台月夜 + 机关层暗背景：指引面板文字切白（用户要求 F4 白色）
      hint: this.hintText(),
      time: this.time,
      fade: this.teleportFade(),
    });
    this.notebook.update(dt, this.state);
  }
}
