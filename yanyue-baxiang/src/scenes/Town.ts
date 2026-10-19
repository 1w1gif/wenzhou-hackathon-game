/** 世界探索场景:2.5D 枕水镇,行走、NPC、谜题、分歧选择 */
import Phaser from 'phaser';
import { VIEW_W, VIEW_H, PHASES, WORLD_THEMES } from '../constants';
import { getState, currentNode, addClue, hasClue, markEvent } from '../state';
import { WORLDS, PUZZLES, CLUES, WorldId } from '../data/script';
import { drawWorldBackground } from '../ui/backdrop';
import { drawYanyueWalker } from '../ui/yanyue';
import { makeText, makePanel, typewrite, addAmbient, TyperHandle } from '../ui/widget';

export class TownScene extends Phaser.Scene {
  private hero!: Phaser.GameObjects.Container;
  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private wasd!: Record<'W' | 'A' | 'S' | 'D', Phaser.Input.Keyboard.Key>;
  private speed = 260;
  private interacting = false;
  private puzzleDone = false;
  private interactHint?: Phaser.GameObjects.Text;
  private near: 'puzzle' | 'npc' | null = null;

  constructor() {
    super('Town');
  }

  create(): void {
    this.interacting = false;
    this.puzzleDone = false;
    if (!this.scene.isActive('Hud')) this.scene.launch('Hud');
    const node = currentNode();
    const world = WORLDS[node.phase as WorldId];
    const theme = WORLD_THEMES[node.phase];
    const phaseIdx = PHASES.indexOf(node.phase);

    const { groundY } = drawWorldBackground(this, theme, phaseIdx);
    addAmbient(this, theme.accent, 26);

    // 世界名幕
    const titleBanner = makeText(this, VIEW_W / 2, 90, world.title, {
      size: 40,
      align: 'center',
      color: '#f2ecda',
    });
    makeText(this, VIEW_W / 2, 132, world.tagline, {
      size: 18,
      align: 'center',
      color: '#a89cc8',
    });
    this.tweens.add({
      targets: [titleBanner],
      y: 64,
      duration: 2600,
      ease: 'Sine.easeInOut',
    });
    this.time.delayedCall(3600, () => {
      this.tweens.add({ targets: titleBanner, alpha: 0.35, duration: 800 });
    });

    // --- 谜题点(祭月台/灯楼等,依世界而定) ---
    const puzzleX = VIEW_W * 0.72;
    this.drawPuzzleSpot(puzzleX, groundY, world.puzzle, theme.accent);

    // --- NPC:本世界的谢郎 ---
    const npcX = VIEW_W * 0.3;
    this.drawNpc(npcX, groundY, world);

    // --- 衍月 ---
    this.hero = drawYanyueWalker(this, VIEW_W * 0.18, groundY + 34);
    this.hero.setDepth(10);

    // 操作提示
    makeText(this, 24, VIEW_H - 30, '←→/AD 移动 · 靠近后按 E 互动 · 右下:月相轮 · 左下:引月札', {
      size: 14,
      color: '#7a7298',
      font: 'ui',
    });
    this.interactHint = makeText(this, VIEW_W / 2, VIEW_H - 90, '', { size: 17, color: '#f2e2cf', align: 'center' });

    this.cursors = this.input.keyboard!.createCursorKeys();
    this.wasd = {
      W: this.input.keyboard!.addKey('W'),
      A: this.input.keyboard!.addKey('A'),
      S: this.input.keyboard!.addKey('S'),
      D: this.input.keyboard!.addKey('D'),
    };

    // 开场独白
    if (!node.events.includes('entered')) {
      markEvent('entered');
      this.time.delayedCall(600, () => {
        this.say(`「${world.title}」。`, `谢郎在这里,是${world.xieRole}。`, '去找此界的异样之处吧。');
      });
    }

    // 谜题已完成过(该线事件快照):标记
    if (node.events.includes(`puzzle_${node.phase}`)) this.puzzleDone = true;
  }

  // ---------- 绘制 ----------

  private drawPuzzleSpot(x: number, groundY: number, puzzle: string, accent: number): void {
    const g = this.add.graphics();
    g.setDepth(3);
    switch (puzzle) {
      case 'lantern': {
        g.fillStyle(0x1a1626, 1);
        g.fillRect(x - 8, groundY - 110, 16, 110);
        g.fillStyle(accent, 0.25);
        g.fillCircle(x, groundY - 126, 26);
        g.fillStyle(0x2a2440, 1);
        g.fillRoundedRect(x - 20, groundY - 150, 40, 44, 8);
        break;
      }
      case 'well': {
        g.fillStyle(0x1a1626, 1);
        g.fillEllipse(x, groundY - 6, 66, 26);
        g.fillStyle(0x05050c, 1);
        g.fillEllipse(x, groundY - 8, 46, 16);
        g.fillStyle(0x2a2440, 1);
        g.fillRect(x - 30, groundY - 46, 8, 42);
        g.fillRect(x + 22, groundY - 46, 8, 42);
        g.fillRect(x - 30, groundY - 52, 60, 8);
        break;
      }
      case 'bridge': {
        g.fillStyle(0x2a2440, 1);
        g.fillRect(x - 90, groundY - 30, 80, 10);
        g.fillRect(x + 10, groundY - 22, 80, 10);
        g.lineStyle(3, 0x2a2440, 1);
        g.lineBetween(x - 86, groundY - 30, x - 86, groundY + 6);
        g.lineBetween(x - 18, groundY - 30, x - 18, groundY + 6);
        // 断口发光
        g.fillStyle(0x8f7fc0, 0.5);
        g.fillCircle(x, groundY - 24, 6);
        break;
      }
      case 'bell': {
        g.fillStyle(0x1a1626, 1);
        g.fillRect(x - 6, groundY - 96, 12, 96);
        g.fillStyle(0x8a7440, 1);
        g.fillEllipse(x, groundY - 108, 44, 52);
        g.fillStyle(0x6a5a30, 1);
        g.fillEllipse(x, groundY - 120, 20, 18);
        break;
      }
      case 'shrine': {
        g.fillStyle(0x2a2440, 1);
        g.fillRect(x - 60, groundY - 14, 120, 14);
        g.fillRect(x - 48, groundY - 80, 14, 70);
        g.fillRect(x + 34, groundY - 80, 14, 70);
        g.fillStyle(0x37305a, 1);
        g.fillRoundedRect(x - 58, groundY - 104, 116, 28, 8);
        g.fillStyle(0xd8cfa8, 0.9);
        g.fillCircle(x, groundY - 90, 7);
        break;
      }
      case 'boat': {
        g.fillStyle(0x2a2440, 1);
        g.beginPath();
        g.moveTo(x - 70, groundY + 6);
        g.lineTo(x + 70, groundY + 6);
        g.lineTo(x + 44, groundY + 26);
        g.lineTo(x - 44, groundY + 26);
        g.closePath();
        g.fillPath();
        g.fillStyle(0x1a1626, 1);
        g.fillRect(x - 3, groundY - 66, 6, 72);
        g.fillStyle(0xd8d2e6, 0.85);
        g.fillTriangle(x + 3, groundY - 62, x + 3, groundY - 6, x + 44, groundY - 6);
        break;
      }
      case 'mirror': {
        g.fillStyle(0x1a1626, 1);
        g.fillRoundedRect(x - 34, groundY - 130, 68, 118, 8);
        g.fillStyle(0xb8b2c8, 0.35);
        g.fillRoundedRect(x - 26, groundY - 122, 52, 100, 6);
        g.fillStyle(0xf2e2cf, 0.5);
        g.fillEllipse(x, groundY - 84, 18, 30);
        break;
      }
      case 'kite': {
        g.lineStyle(2, 0x5a5478, 1);
        g.lineBetween(x + 40, groundY + 4, x - 10, groundY - 110);
        g.fillStyle(0x8f7fc0, 0.9);
        g.fillTriangle(x - 10, groundY - 110, x - 34, groundY - 136, x + 14, groundY - 142);
        g.fillStyle(0xd8d2e6, 0.8);
        g.fillTriangle(x - 10, groundY - 110, x + 14, groundY - 142, x + 22, groundY - 122);
        break;
      }
    }
    // 地面光点标记
    const glow = this.add.circle(x, groundY + 30, 20, accent, 0.35);
    glow.setDepth(1);
    this.tweens.add({ targets: glow, alpha: 0.15, scale: 1.25, duration: 1400, yoyo: true, repeat: -1 });
  }

  private drawNpc(x: number, groundY: number, world: (typeof WORLDS)[WorldId]): void {
    const g = this.add.graphics();
    g.setDepth(4);
    // 身形
    g.fillStyle(0x3a3428, 1);
    g.fillRoundedRect(x - 9, groundY - 24, 18, 26, 5);
    g.fillStyle(0xe8d4bc, 1);
    g.fillCircle(x, groundY - 32, 8);
    g.fillStyle(0x241f18, 1);
    g.fillCircle(x, groundY - 35, 8.4);
    g.slice(x, groundY - 35, 8.4, Phaser.Math.DegToRad(190), Phaser.Math.DegToRad(350), false);
    // 身份小标
    const tag = makeText(this, x, groundY - 58, `谢郎 · ${world.xieRole}`, {
      size: 13,
      color: '#d8cfa8',
      align: 'center',
      font: 'ui',
    });
    tag.setDepth(4);
    this.tweens.add({ targets: [g, tag], y: '+3', duration: 1600, yoyo: true, repeat: -1 });
  }

  // ---------- 更新 ----------

  private eKey?: Phaser.Input.Keyboard.Key;

  update(_time: number, delta: number): void {
    if (this.interacting) return;
    const hero = this.hero;
    const d = (delta / 1000) * this.speed;
    let vx = 0;
    if (this.cursors.left.isDown || this.wasd.A.isDown) vx = -d;
    if (this.cursors.right.isDown || this.wasd.D.isDown) vx = d;
    hero.x = Phaser.Math.Clamp(hero.x + vx, 40, VIEW_W - 40);

    // 行走摇摆
    if (vx !== 0) {
      hero.angle = Math.sin(this.time.now / 90) * 3;
    } else {
      hero.angle = Phaser.Math.Linear(hero.angle, 0, 0.2);
    }

    // 就近交互判定
    const puzzleX = VIEW_W * 0.72;
    const npcX = VIEW_W * 0.3;
    const nearPuzzle = Math.abs(hero.x - puzzleX) < 60;
    const nearNpc = Math.abs(hero.x - npcX) < 50;

    if (nearPuzzle) {
      this.near = 'puzzle';
      const done = this.puzzleDone;
      this.interactHint!.setText(done ? 'E · 重温此地' : 'E · 调查此处');
    } else if (nearNpc) {
      this.near = 'npc';
      this.interactHint!.setText('E · 与谢郎说话');
    } else {
      this.near = null;
      this.interactHint!.setText('');
    }

    this.eKey ??= this.input.keyboard!.addKey('E');
    if (Phaser.Input.Keyboard.JustDown(this.eKey)) {
      if (this.near === 'puzzle') this.doPuzzle();
      else if (this.near === 'npc') this.talkNpc();
    }
  }

  // ---------- 交互 ----------

  private say(...paras: string[]): void {
    this.interacting = true;
    const W = VIEW_W;
    const H = VIEW_H;
    const panel = makePanel(this, W * 0.16, H * 0.62, W * 0.68, 150, 0.9);
    panel.setDepth(50);
    const txt = makeText(this, W * 0.16 + 40, H * 0.62 + 75, '', {
      size: 21,
      wrap: W * 0.68 - 80,
    });
    txt.setDepth(51);
    const full = paras.join('\n');
    const typer: TyperHandle = typewrite(this, txt, full, 26);

    const advance = () => {
      if (!typer.done) {
        typer.skip();
        return;
      }
      this.input.keyboard!.off('keydown-SPACE', advance);
      this.input.off('pointerdown', advance);
      panel.destroy();
      txt.destroy();
      this.interacting = false;
    };
    this.input.keyboard!.on('keydown-SPACE', advance);
    this.input.on('pointerdown', advance);
  }

  private doPuzzle(): void {
    const node = currentNode();
    const phase = node.phase as WorldId;
    const def = PUZZLES[phase];
    const done = this.puzzleDone;

    if (done) {
      this.say('此地已然平静。灯影、水声、远钟——都在原处。');
      return;
    }

    // 检查线索条件
    const missing = def.needs.filter((c) => !hasClue(c));
    if (missing.length > 0) {
      const names = missing.map((c) => `「${CLUES[c].name}」`).join('、');
      this.say(
        '你靠近细看,却总觉得隔着一层——此处需要一个别的世界给你的答案。',
        `(缺少线索:${names})\n打开月相轮,去别的时间线寻找,线索会记在引月札里。`
      );
      return;
    }

    // 解开!
    this.puzzleDone = true;
    markEvent(`puzzle_${phase}`);
    addClue(def.gives);
    this.say(
      def.solveText,
      def.gainText,
      `(引月札新增线索:「${CLUES[def.gives].name}」)`
    );
  }

  private talkNpc(): void {
    const node = currentNode();
    const world = WORLDS[node.phase as WorldId];
    const s = getState();
    const knows = hasClue('clue_name');
    const lines: string[] = [];
    lines.push(`谢郎(作为${world.xieRole})抬起头。他不认得你——这一条线上,你们还未相识。`);
    if (knows) {
      lines.push('你问起祭月台。他怔了怔:「奇怪……我总梦见自己站在祭台上,听见有人在下面喊我的名字。」');
      lines.push('「那名字,是不是叫谢郎?」你问。他没有回答,但他的手,轻轻抖了一下。');
    } else {
      lines.push('你试着说起祭月与月相。他笑笑:「姑娘,月圆月缺,不过是天上事,与人无尤。」');
    }
    if (s.clues.includes('clue_mirror')) {
      lines.push('你取出半面铜镜。他望着镜中那半张脸,很久,说:「原来我把它留在了你那里。」');
    }
    this.say(...lines);
  }

  /** TownScene 供按钮调用的入口:打开月相轮 */
  openWheel(): void {
    if (this.interacting) return;
    // 分歧选择:必须先选,才能穿越
    const node = currentNode();
    if (!node.events.includes('diverged')) {
      this.scene.launch('Diverge');
      return;
    }
    this.scene.launch('Wheel');
  }
}
