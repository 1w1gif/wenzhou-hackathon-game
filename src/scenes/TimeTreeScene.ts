/**
 * 时空树浮层：把玩家亲手种出的世界线画出来。
 * 做法沿用旧原型 Tree.ts：
 *  - 「第 N 夜」为一列，从左往右生长；同列内是这段时间线上分出的枝条
 *  - 枝条画成直角折线，折线中段标注「那一次选择」
 *  - 节点是月相圆盘（双圆相减），当前世界线高亮
 *  - 悬停显示提示，点击任意节点跳回那条世界线
 *  - 终章（结局）后以 showcase 模式展示整棵树
 */
import Phaser from 'phaser';
import { tree, layoutTree, COL_W, ROW_H } from '../core/TimeTree';
import type { TreeLayoutNode } from '../core/TimeTree';
import { store, MOON_PHASES } from '../core/GameStore';
import { makePanel, makeButton, drawMoonPhase, PHASE_STYLE, UI_ACCENT, UI_GOLD, UI_MOON, UI_TEXT } from '../ui/widget';

const NODE_R = 7;
const PANEL = { x: 14, y: 12, w: 452, h: 246 };

export class TimeTreeScene extends Phaser.Scene {
  private showcase = false;
  private dragging = false;
  private dragMoved = false;
  private lastPointer = { x: 0, y: 0 };
  private tip?: Phaser.GameObjects.Text;
  private escKey!: Phaser.Input.Keyboard.Key;
  private toggleKey!: Phaser.Input.Keyboard.Key;
  private enterKey!: Phaser.Input.Keyboard.Key;
  private leftKeys: Phaser.Input.Keyboard.Key[] = [];
  private rightKeys: Phaser.Input.Keyboard.Key[] = [];
  private upKeys: Phaser.Input.Keyboard.Key[] = [];
  private downKeys: Phaser.Input.Keyboard.Key[] = [];
  private boundsRect = { minX: -160, maxX: 160, minY: -160, maxY: 40 };

  constructor() {
    super('TimeTree');
  }

  create(data: { showcase?: boolean }): void {
    this.showcase = !!data?.showcase;
    this.dragging = false;
    this.dragMoved = false;
    this.tip = undefined;

    const nodes = layoutTree();
    const pad = 34;
    const minX = Math.min(...nodes.map(n => n.lx), 0) - pad;
    const maxX = Math.max(...nodes.map(n => n.lx), 0) + pad + 40;
    const minY = Math.min(...nodes.map(n => n.ly), 0) - pad;
    const maxY = Math.max(...nodes.map(n => n.ly), 0) + pad + 22;
    this.boundsRect = { minX, maxX, minY, maxY };

    /* ---------- 底：压暗游戏画面 + 面板 ---------- */
    this.add.rectangle(240, 135, 480, 270, 0x05040c, 0.86).setScrollFactor(0).setDepth(-40).setInteractive();
    makePanel(this, PANEL.x, PANEL.y, PANEL.w, PANEL.h).setScrollFactor(0).setDepth(-39);

    const stars = this.add.graphics().setScrollFactor(0).setDepth(-38);
    for (let i = 0; i < 40; i++) {
      stars.fillStyle(0xffffff, Phaser.Math.FloatBetween(0.06, 0.3));
      stars.fillCircle(Phaser.Math.Between(PANEL.x + 4, PANEL.x + PANEL.w - 4), Phaser.Math.Between(PANEL.y + 4, PANEL.y + PANEL.h - 4), 0.6);
    }

    /* ---------- 固定 UI ---------- */
    this.add.text(240, PANEL.y + 10, '时 空 树', {
      fontFamily: 'serif', fontSize: '15px', color: '#f2ecda',
    }).setOrigin(0.5).setScrollFactor(0).setDepth(50);
    this.add.text(240, PANEL.y + 24, this.showcase
      ? '这条世界线，是你亲手种出来的'
      : '你走过的每一条世界线 · 点击节点跳转', {
      fontFamily: 'serif', fontSize: '8px', color: '#8f7fc0',
    }).setOrigin(0.5).setScrollFactor(0).setDepth(50);

    this.tip = this.add.text(240, PANEL.y + 2, '', {
      fontFamily: 'serif', fontSize: '8px', color: '#f2e2cf',
      backgroundColor: '#0a0918dd', padding: { x: 4, y: 2 },
    }).setOrigin(0.5, 1).setScrollFactor(0).setDepth(60).setVisible(false);

    /* ---------- 夜层列 ---------- */
    for (let night = 1; night <= tree.maxNight; night++) {
      const x = (night - 1) * COL_W;
      this.add.text(x, minY + 12, `第 ${night} 夜`, {
        fontFamily: 'serif', fontSize: '8px', color: '#5a5478',
      }).setOrigin(0.5).setDepth(2);
      const line = this.add.graphics().setDepth(1);
      line.lineStyle(1, 0x2a2740, 0.9);
      line.lineBetween(x, minY + 22, x, maxY - 4);
    }

    /* ---------- 当前世界线的祖先链 ---------- */
    const chain = tree.ancestorIds();

    /* ---------- 枝条（直角折线 + 选择注记） ---------- */
    const edges = this.add.graphics().setDepth(3);
    for (const n of nodes) {
      if (!n.parentId) continue;
      const p = nodes.find(m => m.id === n.parentId);
      if (!p) continue;
      const hot = chain.has(n.id) && chain.has(p.id);
      edges.lineStyle(hot ? 2 : 1, hot ? UI_GOLD : 0x5a5478, hot ? 0.95 : 0.6);
      const midX = (p.lx + n.lx) / 2;
      edges.beginPath();
      edges.moveTo(p.lx + NODE_R, p.ly);
      edges.lineTo(midX, p.ly);
      edges.lineTo(midX, n.ly);
      edges.lineTo(n.lx - NODE_R, n.ly);
      edges.strokePath();

      const via = n.label.length > 9 ? `${n.label.slice(0, 8)}…` : n.label;
      this.add.text(midX, n.ly - 8, via, {
        fontFamily: 'serif', fontSize: '7px', color: hot ? '#d8cfa8' : '#6a6288',
      }).setOrigin(0.5).setDepth(4);
    }

    /* ---------- 节点 ---------- */
    nodes.forEach((n, order) => this.makeNode(n, chain.has(n.id), order));

    /* ---------- 按钮 ---------- */
    makeButton(this, PANEL.x + 44, PANEL.y + PANEL.h - 16, this.showcase ? '返回' : '返回游戏', () => {
      if (this.showcase) this.newRound();
      else this.resumeGame();
    }, { w: 76, h: 18, ghost: true }).setScrollFactor(0).setDepth(52);

    if (this.showcase) {
      makeButton(this, PANEL.x + PANEL.w - 60, PANEL.y + PANEL.h - 16, '再来一轮', () => this.newRound(), {
        w: 92, h: 18, accent: UI_GOLD, size: 9,
      }).setScrollFactor(0).setDepth(52);
    } else {
      this.add.text(PANEL.x + PANEL.w - 12, PANEL.y + PANEL.h - 16, `${tree.nodes.length} 条世界线 · 最深 第 ${tree.maxNight} 夜`, {
        fontFamily: 'serif', fontSize: '8px', color: '#5a5478',
      }).setOrigin(1, 0.5).setScrollFactor(0).setDepth(52);
    }

    /* ---------- 输入 ---------- */
    const kb = this.input.keyboard!;
    const K = Phaser.Input.Keyboard.KeyCodes;
    this.escKey = kb.addKey(K.ESC);
    this.toggleKey = kb.addKey(K.T);
    this.enterKey = kb.addKey(K.ENTER);
    const cursors = kb.createCursorKeys();
    this.leftKeys = [cursors.left!, kb.addKey(K.A)];
    this.rightKeys = [cursors.right!, kb.addKey(K.D)];
    this.upKeys = [cursors.up!, kb.addKey(K.W)];
    this.downKeys = [cursors.down!, kb.addKey(K.S)];

    this.input.on('pointerdown', (p: Phaser.Input.Pointer) => {
      this.dragging = true;
      this.dragMoved = false;
      this.lastPointer = { x: p.x, y: p.y };
    });
    this.input.on('pointermove', (p: Phaser.Input.Pointer) => {
      if (!this.dragging || !p.isDown) return;
      const dx = p.x - this.lastPointer.x;
      const dy = p.y - this.lastPointer.y;
      if (Math.abs(dx) + Math.abs(dy) > 2) this.dragMoved = true;
      this.lastPointer = { x: p.x, y: p.y };
      const cam = this.cameras.main;
      cam.scrollX -= dx / cam.zoom;
      cam.scrollY -= dy / cam.zoom;
      this.clampPan();
    });
    this.input.on('pointerup', () => { this.dragging = false; });
    this.input.on('wheel', (_p: Phaser.Input.Pointer, _o: Phaser.GameObjects.GameObject[], _dx: number, dy: number) => {
      const cam = this.cameras.main;
      cam.setZoom(Phaser.Math.Clamp(cam.zoom * (1 - dy * 0.0012), 0.3, 2));
      this.clampPan();
    });

    this.fitCamera();
  }

  /* ---------- 节点：月相圆盘 ---------- */

  private makeNode(n: TreeLayoutNode, onPath: boolean, order: number): void {
    const phaseIdx = n.state.moonPhaseIndex;
    const style = PHASE_STYLE[phaseIdx] ?? PHASE_STYLE[0];
    const isCurrent = n.id === tree.activeId;
    const isEnding = n.kind === 'ending';
    const r = isCurrent ? NODE_R + 3 : NODE_R;

    const g = this.add.graphics().setDepth(6);
    if (isCurrent) {
      g.fillStyle(UI_MOON, 1);
      g.fillCircle(n.lx, n.ly, r + 3);
    }
    drawMoonPhase(g, n.lx, n.ly, r, isEnding ? UI_GOLD : style.moon, isEnding ? 4 : phaseIdx);
    g.lineStyle(isCurrent ? 2 : 1, isEnding ? 0xc9504c : onPath ? UI_GOLD : style.accent, 0.95);
    g.strokeCircle(n.lx, n.ly, isCurrent ? r + 3 : r + 1);

    if (isCurrent) {
      const ring = this.add.circle(n.lx, n.ly, r + 6).setStrokeStyle(1, UI_GOLD, 0.8).setDepth(5);
      this.tweens.add({ targets: ring, scale: 1.7, alpha: 0, duration: 1400, repeat: -1 });
    }
    if (isEnding) {
      // 结局枝条：外圈朱砂细环
      const er = this.add.circle(n.lx, n.ly, r + 4).setStrokeStyle(1, 0xc9504c, 0.75).setDepth(5);
      er.setAlpha(0);
      this.tweens.add({ targets: er, alpha: 0.9, delay: order * 24, duration: 260 });
    }

    g.setInteractive(new Phaser.Geom.Circle(n.lx, n.ly, Math.max(r + 8, 13)), Phaser.Geom.Circle.Contains);
    g.input!.cursor = 'pointer';
    g.on('pointerover', () => {
      this.showTip(n, isCurrent);
      g.setScale(1.15);
    });
    g.on('pointerout', () => {
      this.tip?.setVisible(false);
      g.setScale(1);
    });
    g.on('pointerup', () => {
      if (this.dragMoved) return;
      if (isCurrent) {
        this.showTip(n, true);
        return;
      }
      this.jumpTo(n);
    });
  }

  private showTip(n: TreeLayoutNode, isCurrent: boolean): void {
    const phase = MOON_PHASES[n.state.moonPhaseIndex];
    const who = n.kind === 'ending' ? '结局' : n.kind === 'origin' ? '起点' : n.kind === 'trust' ? '信任' : '回溯';
    this.tip
      ?.setText(`第 ${n.night} 夜 · ${phase} · ${who}${isCurrent ? ' · 当前世界线' : ''}\n${n.label}${isCurrent ? '' : '（点击跳回）'}`)
      .setVisible(true);
  }

  /* ---------- 跳回那条世界线 ---------- */

  private jumpTo(n: TreeLayoutNode): void {
    const node = tree.jumpTo(n.id);
    if (!node) return;
    store.restoreState(node.state);
    store.setPendingSpawn({ x: node.x, y: node.y });
    this.cameras.main.flash(300, 197, 238, 240);
    this.scene.start('Game', { fromTree: true });
  }

  /** 终章后的「再来一轮」：回到满月之夜的起点，树继续往上长 */
  private newRound(): void {
    store.reset();
    this.scene.start('Game');
  }

  /* ---------- 镜头 ---------- */

  private fitCamera(): void {
    const cam = this.cameras.main;
    const { minX, maxX, minY, maxY } = this.boundsRect;
    const w = maxX - minX;
    const h = maxY - minY;
    const zoom = Phaser.Math.Clamp(Math.min(404 / w, 186 / h), 0.34, 1.15);
    cam.setZoom(zoom);
    cam.centerOn((minX + maxX) / 2, (minY + maxY) / 2 + 12);
  }

  private clampPan(): void {
    const cam = this.cameras.main;
    const halfW = cam.width / 2 / cam.zoom;
    const halfH = cam.height / 2 / cam.zoom;
    const { minX, maxX, minY, maxY } = this.boundsRect;
    const loX = minX - 30 - halfW;
    const hiX = maxX + 30 - halfW;
    cam.scrollX = hiX < loX ? (loX + hiX) / 2 : Phaser.Math.Clamp(cam.scrollX, loX, hiX);
    const loY = minY - 20 - halfH;
    const hiY = maxY + 20 - halfH;
    cam.scrollY = hiY < loY ? (loY + hiY) / 2 : Phaser.Math.Clamp(cam.scrollY, loY, hiY);
  }

  update(_time: number, delta: number): void {
    const cam = this.cameras.main;
    const sp = (delta / 1000) * 220 / cam.zoom;
    let dx = 0;
    let dy = 0;
    if (this.leftKeys.some(k => k.isDown)) dx -= sp;
    if (this.rightKeys.some(k => k.isDown)) dx += sp;
    if (this.upKeys.some(k => k.isDown)) dy -= sp;
    if (this.downKeys.some(k => k.isDown)) dy += sp;
    if (dx !== 0 || dy !== 0) {
      cam.scrollX += dx;
      cam.scrollY += dy;
      this.clampPan();
    }

    if (Phaser.Input.Keyboard.JustDown(this.escKey)) {
      if (this.showcase) this.newRound();
      else this.resumeGame();
    }
    if (!this.showcase && Phaser.Input.Keyboard.JustDown(this.toggleKey)) this.resumeGame();
    if (this.showcase && Phaser.Input.Keyboard.JustDown(this.enterKey)) this.newRound();
  }

  private resumeGame(): void {
    this.scene.stop();
    this.scene.resume('Game');
  }
}