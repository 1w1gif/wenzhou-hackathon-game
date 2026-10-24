// core/palette.ts — 《衍月·八相》水墨色板（来源：.agent/art-bible.md）
import { Color } from "Dora";

export interface InkColor {
  r: number;
  g: number;
  b: number;
  a: number;
}

// 直接返回 Dora Color 实例：可直传 DrawNode 各 API，也可当 InkColor 结构使用
export function ink(r: number, g: number, b: number, a?: number): Color.Type {
  return Color(r, g, b, a === undefined ? 255 : a);
}

export const Palette = {
  // 宣纸底色
  paper: ink(232, 223, 199, 255),
  paperDim: ink(219, 208, 184, 255),
  // 浓墨：轮廓、头发、近景
  inkDark: ink(30, 37, 36, 255),
  inkSoft: ink(30, 37, 36, 210),
  inkWash: ink(30, 37, 36, 150),
  inkFaint: ink(30, 37, 36, 90),
  // 淡墨：远景中景
  paleInk: ink(101, 112, 107, 255),
  paleInkFar: ink(101, 112, 107, 70),
  paleInkMid: ink(101, 112, 107, 130),
  // 月光青：剑气、星光、可攀爬标记
  moonCyan: ink(168, 197, 188, 255),
  moonCyanSoft: ink(168, 197, 188, 160),
  moonCyanFaint: ink(168, 197, 188, 90),
  // 暗金：月相轮、月石、重要机关
  gold: ink(155, 113, 56, 255),
  goldSoft: ink(155, 113, 56, 170),
  // 朱砂红：印章、危险、强盗头巾、灯火
  vermilion: ink(163, 60, 47, 255),
  vermilionSoft: ink(163, 60, 47, 170),
  // 月亮留白
  moonWhite: ink(246, 241, 226, 255),
  moonHalo: ink(246, 241, 226, 36),
  // 墨雾
  mist: ink(46, 52, 50, 120),
  mistLight: ink(60, 68, 66, 70),
  white: ink(255, 255, 255, 255),
} as const;
