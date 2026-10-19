import Phaser from 'phaser';
import { store, MOON_PHASES } from '../core/GameStore';

export class NotebookPanel {
  private panel: Phaser.GameObjects.Container;
  private body: Phaser.GameObjects.Text;
  private key: Phaser.Input.Keyboard.Key;
  constructor(scene: Phaser.Scene) {
    const bg = scene.add.rectangle(240, 135, 410, 230, 0x171923, .98).setStrokeStyle(2, 0xd6a85d, .9);
    const title = scene.add.text(48, 26, '引月札  ·  N 关闭', { fontFamily: 'serif', fontSize: '16px', color: '#d6a85d' });
    this.body = scene.add.text(48, 58, '', { fontFamily: 'serif', fontSize: '11px', color: '#f2e7c8', lineSpacing: 7, wordWrap: { width: 370 } });
    this.panel = scene.add.container(0, 0, [bg, title, this.body]).setScrollFactor(0).setDepth(240).setVisible(false);
    this.key = scene.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.N);
  }
  update(): void { if (Phaser.Input.Keyboard.JustDown(this.key)) this.toggle(); }
  toggle(): void {
    const open = !this.panel.visible; this.panel.setVisible(open); if (!open) return;
    const s = store.get();
    this.body.setText(`月相：${MOON_PHASES[s.moonPhaseIndex]}（第 ${s.loopIndex + 1} 夜）\n\n信任值：${s.shenyanTrust}\n旧信物：${s.relics.length} / 3\n线索：${s.clues.length} / 4\n月石碎片：${s.moonStones}\n机关零件：${s.parts}\n\nA / D 移动    Space 跳跃\nJ 斩击    K 剑气    Shift 闪身\nE 调查 / 对话    Q 转动月相轮\nN 引月札    T 时空树`);
  }
  get visible(): boolean { return this.panel.visible; }
  destroy(): void { this.panel.destroy(true); }
}
