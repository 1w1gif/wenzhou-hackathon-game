import Phaser from 'phaser';
import { store } from './core/GameStore';
import type { EndingId } from './core/GameStore';
import { tree } from './core/TimeTree';
import { createPixelTextures, drawPixelBackground, PIXEL } from './media/pixel';
import { PlayerController } from './systems/PlayerController';
import { CombatSystem } from './systems/CombatSystem';
import { Bandit, Thrower, BanditBoss, ShenYan } from './entities/Enemies';
import { Hud } from './ui/Hud';
import { DialogueBox } from './ui/DialogueBox';
import { NotebookPanel } from './ui/NotebookPanel';
import { FLOORS, WORLD, SPAWN } from './level/map';
import { DIALOGUES, ENDINGS_TEXT } from './data/story';
import { TimeTreeScene } from './scenes/TimeTreeScene';

const W = 480, H = 270;

class BootScene extends Phaser.Scene {
  constructor() { super('Boot'); }
  preload(): void {
    const barBg = this.add.rectangle(240, 142, 204, 10, 0x282b39);
    const bar = this.add.rectangle(140, 142, 0, 6, 0x75cbd1).setOrigin(0, .5);
    this.add.text(240, 118, '月相轮转动中…', { fontFamily: 'serif', fontSize: '11px', color: '#f2e7c8' }).setOrigin(.5);
    this.load.on('progress', (v: number) => { bar.width = 200 * v; });
    this.load.once('complete', () => { barBg.destroy(); bar.destroy(); });

    // 夜景视差背景（按楼层高度切换，血月留给回溯）
    this.load.image('night_forest_gold', 'assets/bg/night_forest_gold.png');
    this.load.image('night_clouds_blue', 'assets/bg/night_clouds_blue.png');
    this.load.image('night_pale', 'assets/bg/night_pale.png');
    this.load.image('night_blood', 'assets/bg/night_blood.png');
    // 天空遗迹瓦片
    this.load.image('ground_top', 'assets/tiles/ground_top.png');
    this.load.image('ground_fill', 'assets/tiles/ground_fill.png');
    this.load.image('bridge', 'assets/tiles/bridge.png');
    this.load.image('brick', 'assets/tiles/brick.png');
    // 打击特效序列帧
    this.load.spritesheet('slash_sheet', 'assets/fx/slash_sheet.png', { frameWidth: 160, frameHeight: 120 });
    this.load.spritesheet('hit_sheet', 'assets/fx/hit_sheet.png', { frameWidth: 128, frameHeight: 128 });
    // 音频
    this.load.audio('bgm_explore', 'assets/audio/bgm_explore.mp3');
    this.load.audio('bgm_battle', 'assets/audio/bgm_battle.mp3');
    this.load.audio('bgm_ending', 'assets/audio/bgm_ending.wav');
    this.load.audio('sfx_sword', 'assets/audio/sfx_sword.mp3');
  }
  create(): void {
    createPixelTextures(this);
    this.anims.create({ key: 'fx_slash', frames: this.anims.generateFrameNumbers('slash_sheet', { start: 0, end: 9 }), frameRate: 24, repeat: 0 });
    this.anims.create({ key: 'fx_hit', frames: this.anims.generateFrameNumbers('hit_sheet', { start: 0, end: 5 }), frameRate: 20, repeat: 0 });
    this.scene.start('Intro');
  }
}

/** 楼层 → 夜景背景（0-1 古镇金月山林，2-3 塔中云海，4+ 高空淡月星空） */
const FLOOR_BG: string[] = [
  'night_forest_gold', 'night_forest_gold',
  'night_clouds_blue', 'night_clouds_blue',
  'night_pale', 'night_pale', 'night_pale',
];

class IntroScene extends Phaser.Scene {
  private timer = 0; private skip!: Phaser.Input.Keyboard.Key; private enter!: Phaser.Input.Keyboard.Key;
  constructor() { super('Intro'); }
  create(): void {
    this.timer = 0;
    this.skip = this.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
    this.enter = this.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.ENTER);
    const bg = this.add.graphics(); drawPixelBackground(bg, W, H);
    this.add.image(388, 62, 'moon').setScale(.55).setAlpha(.85);
    this.add.text(240, 28, '衍月·八相', { fontFamily: 'serif', fontSize: '26px', color: '#f2e7c8', stroke: '#11131d', strokeThickness: 5 }).setOrigin(.5);
    this.add.text(240, 58, 'PIXEL INK / MOON TOWER', { fontFamily: 'monospace', fontSize: '7px', color: '#75cbd1' }).setOrigin(.5);
    this.add.image(145, 168, 'yanyue').setScale(.8); this.add.image(210, 168, 'shenyan').setScale(.8);
    this.add.text(240, 226, '那一夜，满月如盘，他死在我面前。', { fontFamily: 'serif', fontSize: '12px', color: '#f2e7c8' }).setOrigin(.5);
    this.add.text(240, 252, '[ SPACE / ENTER ] 跳过序章', { fontFamily: 'monospace', fontSize: '8px', color: '#75cbd1' }).setOrigin(.5);
  }
  update(_: number, delta: number): void {
    this.timer += delta;
    if (this.timer > 3800 || Phaser.Input.Keyboard.JustDown(this.skip) || Phaser.Input.Keyboard.JustDown(this.enter)) this.scene.start('Game');
  }
}

class GameScene extends Phaser.Scene {
  private player!: PlayerController; private combat!: CombatSystem; private hud!: Hud; private dialogue!: DialogueBox; private notebook!: NotebookPanel;
  private platforms!: Phaser.Physics.Arcade.StaticGroup;
  private enemies: Array<Bandit | Thrower | BanditBoss | ShenYan> = [];
  private bgFar!: Phaser.GameObjects.Image; private bgGlow!: Phaser.GameObjects.Rectangle;
  private keys!: { q: Phaser.Input.Keyboard.Key; n: Phaser.Input.Keyboard.Key; e: Phaser.Input.Keyboard.Key; k: Phaser.Input.Keyboard.Key; t: Phaser.Input.Keyboard.Key; esc: Phaser.Input.Keyboard.Key };
  private hasMet = false; private bossSpawned = false; private bossRef: BanditBoss | null = null; private bossDone = false;
  private confronted = false; private trustRecorded = false; private lastFloor = ''; private lastBgKey = '';
  private rewindFlash = 0;

  constructor() { super('Game'); }

  create(data?: { fromTree?: boolean }): void {
    // 场景实例会被复用，每次进入世界线都要重置运行态
    this.enemies = [];
    this.hasMet = false; this.bossSpawned = false; this.bossRef = null; this.bossDone = false;
    this.confronted = false; this.trustRecorded = false; this.lastFloor = ''; this.lastBgKey = '';

    store.attach(this); store.load();
    this.physics.world.setBounds(0, 0, WORLD.width, WORLD.height); this.cameras.main.setBounds(0, 0, WORLD.width, WORLD.height);

    // 夜景视差背景：图略大于视口，低 scrollFactor 模拟远景，整幅画随镜头缓慢移动
    this.bgFar = this.add.image(0, 0, FLOOR_BG[0])
      .setOrigin(0).setDisplaySize(WORLD.width * .06 + W + 40, WORLD.height * .06 + H + 40)
      .setScrollFactor(.06).setDepth(-10);
    this.bgGlow = this.add.rectangle(0, 0, WORLD.width * .06 + W + 40, WORLD.height * .06 + H + 40, 0x11131d, 0)
      .setOrigin(0).setScrollFactor(.06).setDepth(-9);

    this.platforms = this.physics.add.staticGroup();
    for (const f of FLOORS) for (const p of f.platforms) {
      const block = this.platforms.create(p.x + p.w / 2, p.y + p.h / 2, undefined) as Phaser.Physics.Arcade.Sprite;
      block.setSize(p.w, p.h).setDisplaySize(p.w, p.h).setVisible(false);
      this.drawPlatform(p);
    }

    // 时空树跳回落在当时的位置，否则用最近检查点
    const pending = store.takePendingSpawn();
    const cp = store.get().checkpoint;
    const sx = pending?.x ?? cp?.x ?? SPAWN.x;
    const sy = pending?.y ?? cp?.y ?? SPAWN.y;
    this.player = new PlayerController(this, sx, sy);
    this.physics.add.collider(this.player.sprite, this.platforms);
    this.combat = new CombatSystem(this);
    this.spawnEnemies();

    this.hud = new Hud(this); this.dialogue = new DialogueBox(this); this.notebook = new NotebookPanel(this);

    const kb = this.input.keyboard!;
    const K = Phaser.Input.Keyboard.KeyCodes;
    this.keys = { q: kb.addKey(K.Q), n: kb.addKey(K.N), e: kb.addKey(K.E), k: kb.addKey(K.K), t: kb.addKey(K.T), esc: kb.addKey(K.ESC) };

    this.player.setAttackListener((combo, dir) => this.combat.attack(this.player.sprite, combo, dir));
    this.cameras.main.startFollow(this.player.sprite, true, .08, .08);
    this.cameras.main.setDeadzone(100, 55);
    this.events.on(Phaser.Scenes.Events.RESUME, () => this.input.keyboard?.resetKeys());

    // 时空树的第一颗种子
    if (tree.nodes.length === 0) tree.record('origin', '起点 · 满月之夜', store.get(), sx, sy);

    this.hud.showToast(
      data?.fromTree
        ? `已回到 第 ${store.get().loopIndex + 1} 夜 · ${store.currentPhase()}`
        : '满月未升的黄昏 · 强盗还没来',
      2400
    );
    this.startBgm();
  }

  private spawnEnemies(): void {
    const spots = [[650, 3800], [1250, 3200], [1850, 3200], [2500, 2600], [3300, 2600], [4500, 1400]];
    spots.forEach((p, i) => {
      const e = i % 3 === 0 ? new Thrower(this, p[0], p[1]) : new Bandit(this, p[0], p[1]);
      this.physics.add.collider(e, this.platforms);
      this.combat.add(e);
      this.enemies.push(e);
    });
  }

  /** 用瓦片铺平台：顶面一行草皮（128x64 压到 48x24），下面平铺土层；墙用砖墙 */
  private drawPlatform(p: { x: number; y: number; w: number; h: number; type: string }): void {
    if (p.type === 'wall') {
      this.add.tileSprite(p.x + p.w / 2, p.y + p.h / 2, p.w, p.h, 'brick').setDepth(5).setAlpha(.96);
      return;
    }
    if (p.type === 'one-way') {
      // 细平台直接画草皮顶条
      this.add.tileSprite(p.x + p.w / 2, p.y + p.h / 2, p.w, p.h, 'ground_top').setDepth(4);
      return;
    }
    const TOP = 24;
    const count = Math.max(1, Math.round(p.w / 48));
    const tw = p.w / count;
    for (let i = 0; i < count; i++) {
      this.add.image(p.x + tw / 2 + i * tw, p.y + TOP / 2, 'ground_top').setDisplaySize(tw + 1, TOP).setDepth(4);
    }
    const fillH = p.h - TOP;
    if (fillH > 8) this.add.tileSprite(p.x + p.w / 2, p.y + TOP + fillH / 2, p.w, fillH, 'ground_fill').setDepth(4);
  }

  /** 依据玩家高度与回溯状态切换夜景：正常按楼层，回溯期间转为血月 */
  private updateBackdrop(rewinding: boolean): void {
    const level = Math.max(0, Math.min(6, Math.floor((WORLD.height - this.player.sprite.y) / 600)));
    const key = rewinding ? 'night_blood' : FLOOR_BG[level];
    if (key === this.lastBgKey) return;
    this.lastBgKey = key;
    this.tweens.add({ targets: this.bgFar, alpha: 0, duration: 160, onComplete: () => {
      this.bgFar.setTexture(key);
      this.tweens.add({ targets: this.bgFar, alpha: 1, duration: 220 });
    }});
    // 血月泛红，正常天空透出深蓝
    const tint = rewinding ? 0x58181c : 0x000000;
    this.bgGlow.fillColor = tint;
    this.bgGlow.fillAlpha = rewinding ? .28 : 0;
  }

  /** 场景 BGM：入场起探索曲，遇 boss 切战斗，结局另起 */
  private startBgm(): void {
    const music = this.sound.getAll('bgm');
    music.forEach(m => m.stop());
    if (!this.sound.locked) this.playLoop('bgm_explore', .35);
    this.input.once(Phaser.Input.Events.POINTER_DOWN, () => { if (!this.sound.get('bgm_explore')?.isPlaying) this.playLoop('bgm_explore', .35); });
  }

  private playLoop(key: string, vol: number): void {
    const old = this.sound.getAll('bgm'); old.forEach(m => m.stop());
    const m = this.sound.add(key, { loop: true, volume: vol });
    m.play();
  }

  update(time: number, delta: number): void {
    if (this.dialogue.visible || this.notebook.visible) { this.dialogue.update(); this.notebook.update(); return; }
    if (Phaser.Input.Keyboard.JustDown(this.keys.n)) this.notebook.toggle();
    if (Phaser.Input.Keyboard.JustDown(this.keys.esc)) this.notebook.toggle();
    if (Phaser.Input.Keyboard.JustDown(this.keys.t)) { this.scene.pause(); this.scene.launch('TimeTree', { showcase: false }); return; }

    this.player.update(time, delta); this.combat.update(this.player.sprite); this.hud.update();
    if (Phaser.Input.Keyboard.JustDown(this.keys.e)) this.interact();
    if (Phaser.Input.Keyboard.JustDown(this.keys.q)) this.tryRewind();
    if (Phaser.Input.Keyboard.JustDown(this.keys.k) && store.get().swordIntent > 0) { store.get().swordIntent--; this.combat.swordQi(this.player.sprite, this.player.facingDir); }

    this.trackFloor();
    this.updateBackdrop(store.get().moonPhaseIndex > 0 && this.rewindFlash > 0);
    if (this.rewindFlash > 0) this.rewindFlash -= delta;

    if (!this.hasMet && this.player.sprite.x > 820 && this.player.sprite.y > 3600) {
      this.hasMet = true; store.markMetShenyan(); store.addTrust(1);
      this.dialogue.show(DIALOGUES.firstMeeting);
    }
    if (!this.bossSpawned && this.player.sprite.y < 1600) {
      this.bossSpawned = true;
      const boss = new BanditBoss(this, 4600, 1320);
      this.physics.add.collider(boss, this.platforms);
      this.combat.add(boss); this.enemies.push(boss); this.bossRef = boss;
      this.hud.showObjective('击败守在星盘前的劫匪头目');
      this.playLoop('bgm_battle', .4);
    }
    if (this.bossRef && this.bossRef.dead && !this.bossDone) {
      this.bossDone = true; store.markBossKilled();
      this.hud.showObjective('塔顶的满月即将升顶');
      this.hud.showToast('劫匪头目被击退');
      this.playLoop('bgm_explore', .35);
    }

    // 最终对峙：三选一
    if (!this.confronted && this.player.sprite.y < 520 && this.player.sprite.x > 3900) {
      this.confronted = true;
      this.dialogue.show(DIALOGUES.confrontation, () =>
        this.dialogue.showChoices('满月升顶。你的选择是——', DIALOGUES.confrontationChoices, id => this.resolveConfrontation(id))
      );
    }

    if (this.player.sprite.y > WORLD.height - 80) {
      const c = store.get().checkpoint;
      this.player.sprite.setPosition(c?.x ?? SPAWN.x, c?.y ?? SPAWN.y);
    }
  }

  /** 回溯：消耗生命，时空树长出新枝 */
  private tryRewind(): void {
    if (!store.rewind()) { this.hud.showToast('月相轮已无法再次转动'); return; }
    const n = tree.record('rewind', `回溯 · ${store.currentPhase()}`, store.get(), this.player.sprite.x, this.player.sprite.y);
    this.hud.showToast(`月相轮转动 · 生命 -1\n时空树长出新枝（第 ${n.night} 夜）`, 2400);
    this.cameras.main.flash(260, 197, 238, 240);
    this.rewindFlash = 1600;
    this.updateBackdrop(true);
  }

  private interact(): void {
    const p = this.player.sprite;
    if (p.x > 2800 && p.y < 2900) {
      if (store.addClue('workshop_note')) {
        tree.record('choice', '寻得工坊残记', store.get(), p.x, p.y);
        this.hud.showToast('获得线索：工坊残记');
      }
      this.dialogue.show(DIALOGUES.workshopRecord);
    } else if (p.y < 1100 && !this.trustRecorded) {
      this.trustRecorded = true;
      store.addTrust(1);
      tree.record('trust', '塔中偶遇 · 信任 +1', store.get(), p.x, p.y);
      this.dialogue.show(DIALOGUES.towerMeeting);
    }
  }

  private resolveConfrontation(id: string): void {
    let eid: EndingId;
    if (id === 'sacrifice') eid = store.judgeEnding(true, false);
    else if (id === 'fight') { store.markBladeDrawn(); eid = store.judgeEnding(false, true); }
    else eid = store.judgeEnding(false, false);
    store.setEnding(eid);
    const label = DIALOGUES.confrontationChoices.find(c => c.id === id)?.label ?? id;
    tree.record('ending', `${label} · ${ENDINGS_TEXT[eid].title}`, store.get(), this.player.sprite.x, this.player.sprite.y, eid);
    this.scene.start('Ending', { id: eid });
  }

  /** 按高度分层：进入新楼层时记录检查点并提示 */
  private trackFloor(): void {
    const y = this.player.sprite.y;
    const level = Math.max(0, Math.min(6, Math.floor((WORLD.height - y) / 600)));
    const f = FLOORS.find(x => x.id === `floor${level}`);
    if (!f || f.id === this.lastFloor) return;
    this.lastFloor = f.id;
    store.visitFloor(f.id);
    store.setCheckpoint({ x: this.player.sprite.x, y: this.player.sprite.y, floorId: f.id });
    this.hud.showToast(`第 ${level} 层 · ${f.name}`);
    if (f.hint) this.hud.showObjective(f.hint);
  }
}

class EndingScene extends Phaser.Scene {
  private index = 0; private lines: string[] = []; private key!: Phaser.Input.Keyboard.Key;
  constructor() { super('Ending'); }
  create(data: { id: keyof typeof ENDINGS_TEXT }): void {
    this.index = 0;
    const ending = ENDINGS_TEXT[data.id] ?? ENDINGS_TEXT.duel;
    this.lines = [ending.title, '', ...ending.lines];
    this.key = this.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
    this.sound.getAll('bgm').forEach(m => m.stop());
    if (!this.sound.locked) this.sound.play('bgm_ending', { loop: true, volume: .4 });
    this.show();
  }
  show(): void {
    this.children.removeAll();
    this.add.rectangle(240, 135, 480, 270, 0x10121b);
    this.add.image(380, 72, 'moon').setScale(.7).setAlpha(.65);
    this.add.text(38, 38, this.lines[this.index] ?? '', { fontFamily: 'serif', fontSize: '18px', color: '#f2e7c8', wordWrap: { width: 400 } });
    this.add.text(38, 104, this.lines.slice(this.index + 1, this.index + 5).join('\n'), { fontFamily: 'serif', fontSize: '12px', color: '#c5eef0', lineSpacing: 8, wordWrap: { width: 390 } });
    const last = this.index + 4 >= this.lines.length;
    this.add.text(240, 245, last ? '[ SPACE ] 观看时空树' : '[ SPACE ] 继续', { fontFamily: 'monospace', fontSize: '8px', color: '#75cbd1' }).setOrigin(.5);
  }
  update(): void {
    if (!Phaser.Input.Keyboard.JustDown(this.key)) return;
    this.index += 4;
    if (this.index >= this.lines.length) this.scene.start('TimeTree', { showcase: true });
    else this.show();
  }
}

const game = new Phaser.Game({ type: Phaser.CANVAS, parent: 'game', width: W, height: H, backgroundColor: '#11131d', pixelArt: true, antialias: false, roundPixels: true, physics: { default: 'arcade', arcade: { gravity: { x: 0, y: 0 }, debug: false } }, scene: [BootScene, IntroScene, GameScene, EndingScene, TimeTreeScene], scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH } });

// 调试出口（浏览器控制台可查看世界线状态）
(window as unknown as Record<string, unknown>).__yanyue = { game, store, tree };