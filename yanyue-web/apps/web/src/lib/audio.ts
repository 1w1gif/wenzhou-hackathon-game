"use client";

/**
 * 音频管理：BGM 分场景切换（探索/结局），剑 SFX。
 * 素材：public/assets/audio/（队友提供）。首次用户交互后才播放（浏览器自动播放策略）。
 */
import { asset } from "./base";

const BGM = {
  explore: "/assets/audio/bgm_explore.mp3",
  battle: "/assets/audio/bgm_battle.mp3",
  ending: "/assets/audio/bgm_ending.wav",
} as const;

export type BgmName = keyof typeof BGM;

class AudioManager {
  private bgm: HTMLAudioElement | null = null;
  private current: BgmName | null = null;
  private sfxPool = new Map<string, HTMLAudioElement>();
  muted = false;

  play(name: BgmName, loop = true): void {
    if (this.current === name && this.bgm) return;
    this.stopBgm();
    if (this.muted) { this.current = name; return; }
    const el = new Audio(asset(BGM[name]));
    el.loop = loop;
    el.volume = name === "ending" ? 0.7 : 0.5;
    el.play().catch(() => { /* 未交互时静默，等下次调用 */ });
    this.bgm = el;
    this.current = name;
  }

  stopBgm(): void {
    if (this.bgm) { this.bgm.pause(); this.bgm.currentTime = 0; this.bgm = null; }
    this.current = null;
  }

  sfx(name: "sword", volume = 0.5): void {
    if (this.muted) return;
    let el = this.sfxPool.get(name);
    if (!el) {
      el = new Audio(asset(`/assets/audio/sfx_${name}.mp3`));
      el.volume = volume;
      this.sfxPool.set(name, el);
    }
    el.currentTime = 0;
    el.play().catch(() => {});
  }

  toggleMute(): boolean {
    this.muted = !this.muted;
    if (this.muted) this.bgm?.pause();
    else if (this.current) this.play(this.current);
    return this.muted;
  }
}

export const audio = new AudioManager();