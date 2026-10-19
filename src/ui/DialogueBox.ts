import Phaser from 'phaser';

export interface DialogueLine { speaker: string; text: string }
export interface DialogueChoice { id: string; label: string }

export class DialogueBox {
  private scene: Phaser.Scene;
  private panel: Phaser.GameObjects.Container;
  private speaker: Phaser.GameObjects.Text;
  private body: Phaser.GameObjects.Text;
  private lines: DialogueLine[] = [];
  private index = 0;
  private done: (() => void) | null = null;
  private key?: Phaser.Input.Keyboard.Key;
  private choiceKeys: Phaser.Input.Keyboard.Key[] = [];
  private pendingChoices: DialogueChoice[] | null = null;
  private onChoice: ((id: string) => void) | null = null;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    const bg = scene.add.rectangle(240, 220, 430, 72, 0x11131d, .96).setStrokeStyle(2, 0x75cbd1, .9);
    this.speaker = scene.add.text(22, 190, '', this.style('#d6a85d', 12));
    this.body = scene.add.text(22, 207, '', this.style('#f2e7c8', 11)).setWordWrapWidth(400);
    this.panel = scene.add.container(0, 0, [bg, this.speaker, this.body]).setScrollFactor(0).setDepth(250).setVisible(false);
    const kb = scene.input.keyboard!;
    const K = Phaser.Input.Keyboard.KeyCodes;
    this.key = kb.addKey(K.E);
    this.choiceKeys = [kb.addKey(K.ONE), kb.addKey(K.TWO), kb.addKey(K.THREE)];
  }
  private style(color: string, size: number): Phaser.Types.GameObjects.Text.TextStyle { return { fontFamily: 'serif', fontSize: `${size}px`, color, stroke: '#11131d', strokeThickness: 2 }; }
  show(lines: DialogueLine[], onDone?: () => void): void { this.lines = lines; this.index = 0; this.done = onDone ?? null; this.pendingChoices = null; this.onChoice = null; this.panel.setVisible(true); this.render(); }
  private render(): void { const line = this.lines[this.index]; if (!line) { this.close(); return; } this.speaker.setText(line.speaker); this.body.setText(`${line.text}\n\n[ E / 点击继续 ]`); }

  /** 对峙三选一：按 1 / 2 / 3 选择 */
  showChoices(prompt: string, choices: DialogueChoice[], onPick: (id: string) => void): void {
    this.pendingChoices = choices;
    this.onChoice = onPick;
    this.panel.setVisible(true);
    this.speaker.setText(prompt);
    this.body.setText(
      choices.map((c, i) => `「${i + 1}」 ${c.label}`).join('\n') + '\n\n[ 按 1 / 2 / 3 选择 ]'
    );
  }

  update(): void {
    if (!this.panel.visible) return;
    if (this.pendingChoices && this.onChoice) {
      for (let i = 0; i < this.choiceKeys.length && i < this.pendingChoices.length; i++) {
        if (Phaser.Input.Keyboard.JustDown(this.choiceKeys[i])) {
          const id = this.pendingChoices[i].id;
          const cb = this.onChoice;
          this.pendingChoices = null;
          this.onChoice = null;
          this.panel.setVisible(false);
          cb(id);
          return;
        }
      }
      return;
    }
    if (this.key && Phaser.Input.Keyboard.JustDown(this.key)) this.advance();
  }
  advance(): void { if (!this.panel.visible) return; this.index += 1; this.render(); }
  close(): void { this.panel.setVisible(false); const cb = this.done; this.done = null; cb?.(); }
  get visible(): boolean { return this.panel.visible; }
  destroy(): void { this.panel.destroy(true); }
}