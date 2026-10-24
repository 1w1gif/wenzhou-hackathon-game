// game/audio.ts — 像素版音频：BGM 流播放（Audio.playStream，支持 MP3/交叉淡入淡出）+ 一次性音效（AudioSource）
import { Audio, AudioSource, Director, Node } from "Dora";

export type BgmName = "tension" | "wuxia" | "calm" | "conflict" | "dusk" | "main" | "cover" | "start" | "floor1" | "floor4" | "floor7";

const BGM_FILES: Record<BgmName, string> = {
  main: "assets/audio/bgm-main.mp3",
  tension: "assets/audio/bgm-tension.mp3",
  conflict: "assets/audio/bgm-conflict.mp3",
  wuxia: "assets/audio/bgm-wuxia.mp3",
  // 结局曲：原 bgm-calm.wav（11MB WAV）实测会让 Audio.playStream 直接卡死（探针复现，每次结局必卡）。
  // 改用现成 MP3（playStream 明确支持 MP3）；后续用户可换专用结局曲 MP3 放入 assets/audio 并改此路径
  calm: "assets/audio/bgm-floor4.mp3",
  dusk: "assets/audio/summer_nights.ogg",
  cover: "assets/audio/bgm-cover.mp3", // 封面配乐（用户新增）
  start: "assets/audio/bgm-start.mp3", // 点击「开始游戏」后的播放音乐（用户新增）
  floor1: "assets/audio/bgm-floor1.mp3", // 1 层（用户曲 1f，10-22）
  floor4: "assets/audio/bgm-floor4.mp3", // 4 层 安静治愈（用户曲，10-22）
  floor7: "assets/audio/bgm-floor7.mp3", // 7 层 高燃战斗曲（用户曲，10-22）
};

export type SfxName = "sword" | "dash" | "click" | "heroHit" | "enemyHurt" | "jump1" | "jump2";

const SFX_FILES: Record<SfxName, string> = {
  sword: "assets/audio/sfx-sword-draw.mp3",
  dash: "assets/audio/sfx-dash.mp3", // 闪身音效（用户 10-22 新增，源 .agent/闪身shift.mp3）
  click: "assets/audio/sfx-ui-click.wav",
  heroHit: "assets/audio/sfx-hero-hit.mp3",
  enemyHurt: "assets/audio/sfx-enemy-hurt.mp3",
  jump1: "assets/audio/sfx-jump1.mp3",
  jump2: "assets/audio/sfx-jump2.mp3",
};

let host: Node.Type | undefined;

function hostNode(): Node.Type {
  if (host === undefined) {
    host = Node();
    host.addTo(Director.entry);
  }
  return host;
}

let currentBgm = "";

// 切换 BGM：playStream 自带交叉淡入淡出，loop=true 循环；同曲不重启（同层重生/激活检查点不打断音乐）
export function playBgm(name: BgmName, fade = 1.0): void {
  const file = BGM_FILES[name];
  if (file === currentBgm) {
    return;
  }
  currentBgm = file;
  try {
    Audio.playStream(file, true, fade);
  } catch (e) {
    void e; // 无音频设备时静默降级
  }
}

export function stopBgm(fade = 1.0): void {
  currentBgm = "";
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
