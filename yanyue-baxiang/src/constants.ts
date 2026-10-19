/** 全局常量:视口尺寸、八个月相、世界色彩主题 */

export const VIEW_W = 1280;
export const VIEW_H = 720;

/** 八个月相:穿越轮盘的刻度,也是八条时空线的编号 */
export const PHASES = [
  '朔',   // 新月
  '峨眉', // 眉月
  '弦',   // 上弦
  '盈凸', // 盈凸月
  '望',   // 满月
  '亏凸', // 亏凸月
  '下弦', // 下弦
  '残',   // 残月
] as const;

export type PhaseName = (typeof PHASES)[number];

export interface WorldTheme {
  /** 天空与地面主色 */
  sky: number;
  ground: number;
  /** 山峦剪影(远→近) */
  hills: number[];
  /** 环境点缀色(灯火/萤光) */
  accent: number;
  /** 月亮颜色 */
  moon: number;
}

/** 八条世界线的美术主题:从冷寂到丰盈再归于萧瑟,色相随月相推移 */
export const WORLD_THEMES: Record<string, WorldTheme> = {
  '朔':   { sky: 0x05050c, ground: 0x0a0a16, hills: [0x0b0b1a, 0x090914], accent: 0x3a3a6e, moon: 0x1c1c2e },
  '峨眉': { sky: 0x0a0a1c, ground: 0x10101f, hills: [0x131330, 0x0e0e24], accent: 0x6f5fa8, moon: 0xc8c2da },
  '弦':   { sky: 0x0f1226, ground: 0x151a30, hills: [0x1a2040, 0x141830], accent: 0x8f7fc0, moon: 0xd8d2e6 },
  '盈凸': { sky: 0x141a33, ground: 0x1a2038, hills: [0x20284a, 0x181f3a], accent: 0xa8a0d8, moon: 0xe6e0f0 },
  '望':   { sky: 0x1a2140, ground: 0x202848, hills: [0x272f56, 0x1e2648], accent: 0xd8cfa8, moon: 0xfff6d8 },
  '亏凸': { sky: 0x181d36, ground: 0x1d2340, hills: [0x232a4e, 0x1b2140], accent: 0xb0a8d0, moon: 0xeae2f2 },
  '下弦': { sky: 0x101226, ground: 0x151833, hills: [0x1a1e40, 0x131633], accent: 0x8a84b8, moon: 0xd6d0e0 },
  '残':   { sky: 0x080814, ground: 0x0c0c1c, hills: [0x10101f, 0x0a0a18], accent: 0x5a4a80, moon: 0xb8b2c8 },
};

export const FONT = '"Noto Serif SC", "Source Han Serif SC", "SimSun", serif';
export const FONT_UI = '"Noto Sans SC", "Microsoft YaHei", "PingFang SC", sans-serif';
