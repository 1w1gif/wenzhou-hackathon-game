/**
 * 水墨调色板 + 公共 SVG 工具。
 * 做法沿用 love-4201 的 art-engine：全局统一描边、集中调色板、部件函数拼装。
 * 画风：宣纸底 + 浓墨描边 + 月白/淡青/朱砂点缀。
 */

export const INK = '#3a3630'; // 统一描边：暖墨色（比纯黑柔和，像浓墨）
export const INK_SOFT = 'rgba(58,54,48,0.35)';

export const PALETTE = {
  paper: '#f2ecd9', // 宣纸
  paper2: '#e9e1c8',
  wash: '#dfe4d9', // 淡青灰晕染
  ink: INK,
  inkMid: '#6a6357', // 中墨
  inkLight: '#a89f8c', // 淡墨
  moon: '#f7f3e4', // 月白
  cyan: '#9ec8c9', // 淡青月光
  cyanDeep: '#6fa3a6',
  cinnabar: '#b4483f', // 朱砂
  gold: '#c9a05c', // 暗金
  robe: '#4a4658', // 沈砚袍色（浓墨紫）
  robeDark: '#37344a',
  hair: '#2e2b33',
  skin: '#f5dcc2',
  skinShadow: '#e5c4a4',
} as const;

export const S = 'stroke-linejoin="round" stroke-linecap="round"';
export const STROKE = `stroke="${INK}" stroke-width="3" ${S}`;
export const STROKE_THIN = `stroke="${INK}" stroke-width="2" ${S}`;

/** 包一层 SVG */
export function wrap(inner: string, viewBox = '0 0 120 160'): string {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" class="art-svg">${inner}</svg>`;
}

/** 地面阴影椭圆 */
export function shadow(cx: number, cy: number, rx: number): string {
  return `<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${rx * 0.2}" fill="${INK_SOFT}"/>`;
}