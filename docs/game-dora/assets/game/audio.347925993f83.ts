// game/audio.ts — 像素版音频：BGM 流播放（Audio.playStream，支持 MP3/交叉淡入淡出）+ 一次性音效（AudioSource）
import { Audio, AudioSource, Director, Node } from "Dora";

export type BgmName = "tension" | "wuxia" | "calm" | "conflict";

const BGM_FILES: Record<BgmName, string> = {
  tension: "assets/audio/bgm-tension.mp3",
  conflict: "assets/audio/bgm-conflict.mp3",
  wuxia: "assets/audio/bgm-wuxia.mp3",
  calm: "assets/audio/bgm-calm.wav",
};

export type SfxName = "sword" | "dash";

// 素材暂缺独立音效：挥剑/闪身共用拔剑音，dash 用更低音量近似区分（后续换素材时替换 dash 文件即可）
const SFX_FILES: Record<SfxName, string> = {
  sword: "assets/audio/sfx-sword-draw.mp3",
  dash: "assets/audio/sfx-sword-draw.mp3",
};

let host: Node.Type | undefined;

function hostNode(): Node.Type {
  if (host === undefined) {
    host = Node();
    host.addTo(Director.entry);
  }
  return host;
}

// 切换 BGM：playStream 自带交叉淡入淡出，loop=true 循环
export function playBgm(name: BgmName, fade = 1.0): void {
  try {
    Audio.playStream(BGM_FILES[name], true, fade);
  } catch (e) {
    void e; // 无音频设备时静默降级
  }
}

export function stopBgm(fade = 1.0): void {
  try {
    Audio.stopStream(fade);
  } catch (e) {
    void e;
  }
}

// 一次性音效：autoRemove=true，停止/播完自动移除节点
export function sfx(name: SfxName, volume = 0.9): void {
  try {
    const src = AudioSource(SFX_FILES[name], true);
    if (src === undefined) {
      return;
    }
    src.volume = volume;
    src.addTo(hostNode());
    if (!src.play()) {
      src.removeFromParent();
    }
  } catch (e) {
    void e;
  }
}
