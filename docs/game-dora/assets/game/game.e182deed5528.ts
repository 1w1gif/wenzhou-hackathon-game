// game/game.ts — 《衍月·八相》主状态机与游戏主循环
import { Color, print, Director, DrawNode, KeyName, Keyboard, Node, Vec2, View } from "Dora";
import { EnemySpawn, LoopState, Platform, Rect, StoryNode } from "core/types";
import { activePlatforms, bodyRect, clamp, lerp, rectOverlap } from "game/physics";
import { createLoopState } from "game/world";
import { Player, PlayerCtx, PlayerInput } from "game/player";
import { EffectSystem } from "game/effects";
import { EnemySystem } from "game/enemies";
import { MechanismSystem } from "game/mechanisms";
import { WorldRenderer } from "game/render_world";
import { HUD } from "ui/hud";
import { DialogUI } from "ui/dialog";
import { NotebookUI } from "ui/notebook";
import { STORY_NODES } from "data/story";
import * as Tower from "data/tower";
import { createIntro } from "scenes/intro";
import { drawShenYan, drawObserver } from "game/render_chars";
import { playBgm, stopBgm, sfx } from "game/audio";
import { SheetFxSystem } from "game/sheetfx";
import { TouchPad } from "ui/touch";

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

const GOLD = { r: 155, g: 113, b: 56, a: 255 };
const CYAN = { r: 168, g: 197, b: 188, a: 255 };

export class Game {
  private root: Node.Type;
  private uiRoot: Node.Type;
  private renderer: WorldRenderer;
  private fxDraw: DrawNode.Type;
  private npcDraw: DrawNode.Type;
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
  private triggerCd: Record<string, number>;
  private intro: { update(dt: number): void; skip(): void; done(): boolean } | undefined;
  private endingId: string;
  private sheetNode: Node.Type;
  private sheetFx: SheetFxSystem;
  private touchPad: TouchPad;

  constructor() {
    this.root = Node();
    this.root.addTo(Director.entry);
    this.renderer = new WorldRenderer(this.root, Tower);
    this.fxDraw = DrawNode();
    this.fxDraw.addTo(this.root);
    this.npcDraw = DrawNode();
    this.npcDraw.addTo(this.root);
    this.sheetNode = Node();
    this.sheetNode.addTo(this.root);
    this.uiRoot = Node();
    this.uiRoot.addTo(this.root);
    this.fx = new EffectSystem();
    this.sheetFx = new SheetFxSystem(this.sheetNode);
    this.fx.sheetHook = (x, y, dir, big) => this.sheetFx.spawn(x, y, dir, big);
    this.state = createLoopState();
    this.player = new Player(800, 410);
    this.enemies = new EnemySystem(this.fx, {
      onPlayerHit: (dmg, fromX) => this.onPlayerHit(dmg, fromX),
      onDeath: (def) => this.onEnemyDeath(def),
      onPoof: (x, y) => this.fx.spawnDust(x, y, 0),
    });
    this.mech = new MechanismSystem(this.state, this.fx, {
      onGateOpen: () => this.fx.spawnRing(this.player.body.x, this.player.body.y + 20, GOLD, 16, 170, 0.7),
      onBell: () => this.shake(0.25, 5),
      onLanternLit: () => this.fx.spawnStars(this.player.body.x, this.player.body.y + 40, 6),
      onLanternFail: () => this.shake(0.15, 3),
      onCheckpoint: () => undefined,
      onCollect: () => undefined,
    });
    this.mech.bindLists(Tower.ropes, Tower.bells, Tower.plates);
    this.hud = new HUD(this.uiRoot);
    this.dialog = new DialogUI(this.uiRoot);
    this.notebook = new NotebookUI(this.uiRoot);
    this.touchPad = new TouchPad(this.uiRoot);
    this.touchPad.onInteract = () => this.onKey(KeyName.E);
    this.touchPad.onRewind = () => this.onKey(KeyName.Q);
    this.touchPad.onNote = () => this.onKey(KeyName.N);
    this.touchPad.onRevive = () => this.onKey(KeyName.R);
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
    this.triggerCd = {};
    this.endingId = "";
    this.hud.setTitleVisible(true);
  }

  start(): void {
    this.resetRun();
    this.root.schedule((dt) => {
      this.tick(dt);
      return false;
    });
    this.root.onKeyDown((key) => this.onKey(key));
    // 触屏/鼠标点击：标题屏开始、序章跳过、死亡复活、结局回标题（手机无键盘的完整路径）
    this.root.touchEnabled = true;
    this.root.slot("Tapped", () => {
      if (this.mode === "title" || this.mode === "dead" || this.mode === "ending") {
        this.onKey(KeyName.Return);
      } else if (this.mode === "prologue") {
        this.onKey(KeyName.Escape);
      }
    });
  }

  private resetRun(): void {
    this.state = createLoopState();
    this.mech.state = this.state;
    this.mech.syncStones(Tower.pushStones);
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
    const cp = this.findCheckpoint(this.state.currentCheckpointId);
    this.player.respawn(cp ? cp.x : 800, (cp ? cp.y : 320) + 90);
    this.qiShots.length = 0;
    this.attackApplied = false;
    this.intentRegenT = 0;
    this.bladeT = 0;
    this.rewindT = 0;
    this.camX = this.player.body.x;
    this.camY = this.player.body.y;
  }

  private findCheckpoint(id: string): { x: number; y: number } | undefined {
    for (let i = 0; i < Tower.checkpoints.length; i++) {
      if (Tower.checkpoints[i].id === id) {
        return Tower.checkpoints[i];
      }
    }
    return undefined;
  }

  private shake(t: number, mag: number): void {
    this.shakeT = t;
    this.shakeMag = mag;
  }

  private buildInput(active: boolean): PlayerInput {
    if (!active) {
      return { left: false, right: false, up: false, down: false, jumpPressed: false, attackPressed: false, qiPressed: false, dashPressed: false };
    }
    const pad = this.touchPad.pad;
    return {
      left: Keyboard.isKeyPressed(KeyName.A) || pad.left,
      right: Keyboard.isKeyPressed(KeyName.D) || pad.right,
      up: Keyboard.isKeyPressed(KeyName.W) || pad.up,
      down: Keyboard.isKeyPressed(KeyName.S) || pad.down,
      jumpPressed: Keyboard.isKeyDown(KeyName.Space) || this.touchPad.takeJump(),
      attackPressed: Keyboard.isKeyDown(KeyName.J) || this.touchPad.takeAttack(),
      qiPressed: Keyboard.isKeyDown(KeyName.K) || this.touchPad.takeQi(),
      dashPressed: Keyboard.isKeyDown(KeyName.LShift) || this.touchPad.takeDash(),
    };
  }

  private onKey(key: KeyName): void {
    if (key === KeyName.Escape) {
      const inPlay = this.mode === "play" || this.mode === "confront";
      if (inPlay || this.paused) {
        this.paused = !this.paused;
        this.hud.setPauseVisible(this.paused);
        return;
      }
    }
    switch (this.mode) {
      case "title":
        this.hud.setTitleVisible(false);
        this.mode = "prologue";
        playBgm("tension", 1.5);
        this.intro = createIntro(this.root, () => this.beginLoop());
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
          if (this.dialog.hasChoices()) {
            this.dialog.confirmChoice();
          } else {
            this.dialog.advance();
          }
        }
        break;
      case "dead":
        if (key === KeyName.R || key === KeyName.Return || key === KeyName.E) {
          this.revive();
        }
        break;
      case "ending":
        if (key === KeyName.R || key === KeyName.Return || key === KeyName.E) {
          this.toTitle();
        }
        break;
      default:
        break;
    }
  }

  private onPlayKey(key: KeyName): void {
    if (key === KeyName.Tab || key === KeyName.N) {
      this.notebook.toggle();
      return;
    }
    if (key === KeyName.E) {
      this.interact();
      return;
    }
    if (key === KeyName.Q) {
      this.onQ();
    }
  }

  private onQ(): void {
    const cpOk = this.state.checkpointsActivated[this.state.currentCheckpointId] === true;
    if (this.mode === "play" && cpOk && this.state.heroineLife > 1 && this.state.phaseIndex !== 7) {
      this.state.heroineLife -= 1;
      this.state.phaseIndex = (this.state.phaseIndex + 1) % 8;
      this.state.rewindCount += 1;
      this.loopAdvance();
      return;
    }
    if (this.mode === "confront" && Math.abs(this.player.body.x - 6150) < 160 && Math.abs(this.player.body.y - Tower.TOPS[6]) < 160) {
      this.endGame("sacrifice");
    }
  }

  private tick(dt: number): void {
    this.time += dt;
    // 虚拟手柄只在可操作界面显示（play/confront/dialog/dead 常开，标题/序章/结局隐藏）
    const padVisible = this.mode === "play" || this.mode === "confront" || this.mode === "dialog" || this.mode === "dead";
    if (this.touchPad.rootNode.visible !== padVisible) {
      this.touchPad.setVisible(padVisible);
    }
    let shakeX = 0;
    let shakeY = 0;
    if (this.shakeT > 0) {
      this.shakeT -= dt;
      shakeX = (Math.random() * 2 - 1) * this.shakeMag;
      shakeY = (Math.random() * 2 - 1) * this.shakeMag;
    }
    if (this.mode === "prologue" && this.intro) {
      this.intro.update(dt);
      if (this.intro.done()) {
        this.intro = undefined;
        this.beginLoop();
      }
    } else if (this.mode === "rewind") {
      this.rewindT += dt;
      this.hud.setRewind(Math.min(1, this.rewindT / 1.1));
      if (this.rewindT >= 1.1) {
        this.hud.setRewind(-1);
        this.mode = "play";
      }
    } else if (this.mode === "dialog") {
      this.dialog.update(dt);
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
        if (this.mode === "play" || this.mode === "confront") {
          this.simWorld(dt);
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
    // 序章结束可能触发两次（onFinish 回调 + tick 轮询 done()），这里兜底只执行一次
    if (this.mode !== "prologue") {
      return;
    }
    this.applyLoopVariants();
    this.mode = "play";
    playBgm("wuxia", 1.5);
  }

  private simWorld(dt: number): void {
    this.updateMovers();
    const plats = activePlatforms(Tower.platforms, this.state.openedGates);
    const ctx: PlayerCtx = { platforms: plats, ladders: Tower.ladders, climbWalls: Tower.climbWalls };
    const input = this.buildInput(true);
    this.player.update(dt, input, ctx);
    this.consumeAttack();
    this.consumeQi();
    const pbody = this.player.body;
    const prect = bodyRect(pbody);
    this.enemies.update(dt, pbody.x, pbody.y, prect, this.player.isInvulnerable(), ctx);
    // 推石方向：仅地面移动时施加
    const pushDir = pbody.onGround ? (input.left ? -1 : 0) + (input.right ? 1 : 0) : 0;
    this.mech.update(dt, prect, pushDir, this.playerAttackRect(), this.qiRects(), ctx);
    this.updateQiShots(dt, plats);
    if (pbody.y < -80 && (this.mode === "play" || this.mode === "confront")) {
      this.fallIntoVoid();
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
  }

  // 坠入虚空：无敌帧也必定扣 1 命并回检查点（之前 y<-80 走 hurt+respawn，掉命被无敌吞掉）
  private fallIntoVoid(): void {
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

  private playerAttackRect(): Rect | undefined {
    return this.player.attack ? this.player.attack.hitbox : undefined;
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
    const hits = this.enemies.takeHit(atk.hitbox, 1, atk.dir, 220);
    if (hits > 0) {
      this.hitstop = 0.06;
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

  private checkStoryTriggers(): void {
    const prect = bodyRect(this.player.body);
    const trigs = Tower.storyTriggers;
    for (let i = 0; i < trigs.length; i++) {
      const t = trigs[i];
      if (!t.once && !this.state.storySeen[t.storyId]) {
        // 从未看过的可重复剧情：正常触发
      } else if (t.once && this.state.storySeen[t.storyId]) {
        continue;
      } else if (!t.once && this.state.storySeen[t.storyId]) {
        // 已看过的可重复剧情：冷却后再触发（防止站在区域内反复连播）
        const cd = this.triggerCd[t.id] !== undefined ? this.triggerCd[t.id] : 0;
        if (this.time < cd) {
          continue;
        }
      }
      if (rectOverlap(prect, { x: t.x, y: t.y, w: t.w, h: t.h })) {
        this.triggerCd[t.id] = this.time + (t.repeatCd !== undefined ? t.repeatCd : 6);
        this.openDialog(t.storyId);
        return;
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
        this.player.body.vy = 640;
        this.player.body.y += 26;
        break;
      }
    }
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
    if (this.mech.tryLightLantern(Tower.lanterns, px, py)) {
      return;
    }
    const nearShen = Math.abs(px - this.shenX()) < 90 && Math.abs(py - this.shenY()) < 140;
    if (this.state.flags.confront && nearShen) {
      this.putDownSword();
      return;
    }
    if (!this.state.storySeen["story_check_intro"] && nearShen) {
      this.openDialog("story_check_intro");
    }
  }

  private putDownSword(): void {
    this.state.drawnBladeAgainst = false;
    this.state.flags.putDownSword = true;
    if (this.state.shenyanTrust >= 4) {
      this.endGame("reunion");
    } else {
      const lacked = 4 - this.state.shenyanTrust;
      this.state.objective =
        "他叹息离去——他还差 " + lacked + " 分信任才会认出你。（Q 回溯再试：挡箭、旧物、旧约都可积攒）";
      this.loopAdvance();
    }
  }

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
    this.dialog.onChoice = (index: number) => this.applyChoice(node, index);
    const speaker = node.lines.length > 0 ? node.lines[0].speaker : "沈砚";
    this.dialog.open(node, speaker);
  }

  private applyChoice(node: StoryNode, index: number): void {
    const choice = node.choices ? node.choices[index] : undefined;
    if (choice) {
      this.state.shenyanTrust += choice.trust;
      if (choice.memory && this.state.memories.indexOf(choice.memory) < 0) {
        this.state.memories.push(choice.memory);
      }
      this.fx.spawnRing(this.player.body.x, this.player.body.y + 30, CYAN, 10, 90, 0.5);
    }
    if (node.id === "story_final") {
      this.state.flags.confront = true;
      this.state.objective = "月相装置旁：E 放下剑 · Q 以命换命 · J……剑锋相向";
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
      return 5900;
    }
    const xs = [1450, 2950, 3350, 4450, 4950, 5450];
    return xs[Math.min(this.shenProgress(), xs.length - 1)];
  }

  private shenY(): number {
    const ys = [220, 700, 1180, 1680, 2180, 2680];
    if (this.state.flags.confront) {
      return Tower.TOPS[6];
    }
    return ys[Math.min(this.shenProgress(), ys.length - 1)];
  }

  private onEnemyDeath(def: EnemySpawn): void {
    this.fx.spawnMist(def.x, def.y, def.kind === "boss" ? 10 : 4, def.kind === "boss" ? 1.6 : 1);
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
    this.state.flags.confront = true;
    playBgm("conflict", 1.0);
    this.openDialog("story_final");
  }

  private die(): void {
    this.mode = "dead";
    this.state.objective = "月亮沉了下去……（按 R 从检查点再试一次）";
    this.hud.showEnding("exhausted");
  }

  private revive(): void {
    this.hud.hideEnding();
    this.state.heroineLife = this.state.maxLife;
    this.state.swordIntent = this.state.maxSwordIntent;
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
    this.respawnAt(this.state.currentCheckpointId);
    this.mode = "play";
  }

  private respawnAt(id: string): void {
    const cp = this.findCheckpoint(id);
    const x = cp ? cp.x : 800;
    const y = (cp ? cp.y : 320) + 90;
    this.player.respawn(x, y);
    this.camX = x;
    this.camY = y;
  }

  private loopAdvance(): void {
    this.state.loopIndex += 1;
    // 剑锋相向的裂痕会留存：信任保留（不清零），但“以剑相向”标记永久记录
    this.applyLoopVariants();
    playBgm("wuxia", 1.2);
    this.enemies.spawnAll(Tower.enemies, this.state.loopIndex);
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
    this.mech.syncStones(Tower.pushStones);
  }

  private endGame(id: string): void {
    this.endingId = id;
    this.hud.setRewind(-1);
    this.mode = "ending";
    this.hud.showEnding(id);
    playBgm("calm", 2.0);
  }

  private toTitle(): void {
    this.hud.hideEnding();
    this.resetRun();
    this.sheetFx.clear();
    stopBgm(1.0);
    this.mode = "title";
    this.hud.setTitleVisible(true);
  }

  private hintText(): string {
    if (this.mode === "confront") {
      return "E 放下剑 · Q 以命换命（月相装置旁） · N/Tab 手札";
    }
    if (this.player.onLadder) {
      return "W/S 攀爬 · 到顶后按 Space 跳向右侧平台";
    }
    const cpOk = this.state.checkpointsActivated[this.state.currentCheckpointId] === true;
    const base = "A/D 移动 · Space 跳 · J 攻击 · K 剑气 · Shift 闪身 · E 交互 · N 手札";
    return cpOk ? base + " · Q 月相轮回（耗1命）" : base;
  }

  private drawNpcs(): void {
    const p = this.player.body;
    const d = this.npcDraw;
    if (Math.abs(p.x - 5300) < 1300 && Math.abs(p.y - 2640) < 900) {
      drawObserver(d, 5300, 2640, this.time);
    }
    const sx = this.shenX();
    const sy = this.shenY();
    if (this.mode !== "ending" && Math.abs(p.x - sx) < 1400) {
      drawShenYan(d, sx, sy, p.x > sx ? -1 : 1, this.time, this.state.flags.confront);
    }
    for (let i = 0; i < this.qiShots.length; i++) {
      const q = this.qiShots[i];
      if (!q.alive) {
        continue;
      }
      const wob = Math.sin(this.time * 22 + q.phase) * 4;
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
  }

  private updateVisuals(dt: number, shakeX: number, shakeY: number): void {
    const view = View.size;
    const active = this.mode === "play" || this.mode === "confront" || this.mode === "dialog" || this.mode === "rewind" || this.mode === "dead" || this.mode === "ending";
    if (active) {
      const tx = clamp(this.player.body.x, view.width / 2, Tower.WORLD_W - view.width / 2);
      // 相机最低高度锚定 0 层地面：地面顶边几乎贴住屏幕底缘（距底 8px，会话框式贴底）
      const ty = clamp(this.player.body.y + 70, Tower.TOPS[0] + view.height / 2 - 8, Tower.WORLD_H - view.height / 2);
      const k = Math.min(1, dt * 6);
      this.camX += (tx - this.camX) * k;
      this.camY += (ty - this.camY) * k;
    } else {
      this.camX = 800;
      this.camY = 400;
    }
    this.fxDraw.position = Vec2(view.width / 2 - this.camX + shakeX, view.height / 2 - this.camY + shakeY);
    this.npcDraw.position = this.fxDraw.position;
    this.sheetNode.position = this.fxDraw.position;
    this.fx.update(dt);
    this.sheetFx.update(dt);
    this.fxDraw.clear();
    this.fx.draw(this.fxDraw);
    this.npcDraw.clear();
    if (this.mode !== "title" && this.mode !== "prologue") {
      this.drawNpcs();
    }
    this.renderer.setWorldVisible(this.mode !== "title" && this.mode !== "prologue");
    this.renderer.setCamera(this.camX, this.camY, shakeX, shakeY);
    this.renderer.update(dt, this.state, this.player, this.enemies, this.mech, this.time);
    this.hud.update(dt, {
      state: this.state,
      player: this.player,
      boss: this.enemies.boss(),
      objective: this.state.objective,
      hint: this.hintText(),
      time: this.time,
    });
    this.notebook.update(dt, this.state);
  }
}
