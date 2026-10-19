/**
 * 关卡数据：七层「古镇 + 观星塔」连续地图。
 * 世界坐标：y 向下递增，第 0 层在底部（y 最大），观星台在顶部。
 * 地图总尺寸：宽 5600，高 4200（每层高约 600）。
 */

export const WORLD = {
  width: 5600,
  height: 4200,
};

export interface PlatformDef {
  x: number;
  y: number;
  w: number;
  h: number;
  /** solid 四面碰撞 | one-way 仅从上方可站 | wall 可吸附墙面（竖墙） */
  type: 'solid' | 'one-way' | 'wall';
}

export interface FloorDef {
  id: string;
  name: string;
  /** 该层地面主 y 坐标 */
  groundY: number;
  platforms: PlatformDef[];
  /** 教学提示文案（进入该层时显示） */
  hint?: string;
}

/* ---------- 楼层 y 轴规划（层高约 600） ----------
 * 第 6 层 观星台      groundY ≈ 300
 * 第 5 层 观测者居所  groundY ≈ 900
 * 第 4 层 星盘机关层  groundY ≈ 1500
 * 第 3 层 塔外环廊    groundY ≈ 2100
 * 第 2 层 悬空工坊    groundY ≈ 2700
 * 第 1 层 古镇街巷    groundY ≈ 3300
 * 第 0 层 古镇河岸    groundY ≈ 3900
 */

export const FLOORS: FloorDef[] = [
  {
    id: 'floor6',
    name: '观星台',
    groundY: 300,
    hint: '满月即将升顶——古仪正在苏醒。',
    platforms: [
      { x: 0, y: 420, w: 5600, h: 120, type: 'solid' },
      { x: 600, y: 300, w: 300, h: 24, type: 'one-way' },
      { x: 1300, y: 240, w: 260, h: 24, type: 'one-way' },
      { x: 2200, y: 280, w: 280, h: 24, type: 'one-way' },
      { x: 3100, y: 240, w: 240, h: 24, type: 'one-way' },
      // 古仪基座
      { x: 4200, y: 120, w: 500, h: 300, type: 'solid' },
      { x: 5000, y: 0, w: 60, h: 420, type: 'wall' },
    ],
  },
  {
    id: 'floor5',
    name: '观测者居所',
    groundY: 900,
    hint: '狭窄的居所，有人在这里等了你很久。',
    platforms: [
      { x: 0, y: 1020, w: 5600, h: 120, type: 'solid' },
      { x: 480, y: 880, w: 280, h: 24, type: 'one-way' },
      { x: 1050, y: 800, w: 240, h: 24, type: 'one-way' },
      { x: 1600, y: 880, w: 300, h: 24, type: 'one-way' },
      { x: 2300, y: 780, w: 260, h: 24, type: 'one-way' },
      { x: 2950, y: 860, w: 280, h: 24, type: 'one-way' },
      { x: 3600, y: 780, w: 300, h: 24, type: 'one-way' },
      // 楼层间隔墙（带通道缺口）
      { x: 2680, y: 640, w: 60, h: 260, type: 'wall' },
      { x: 2680, y: 380, w: 60, h: 260, type: 'wall' },
    ],
  },
  {
    id: 'floor4',
    name: '星盘机关层',
    groundY: 1500,
    hint: '巨大的齿轮仍在转动——劫匪头目守在古仪零件前。',
    platforms: [
      { x: 0, y: 1620, w: 5600, h: 120, type: 'solid' },
      { x: 700, y: 1480, w: 260, h: 24, type: 'one-way' },
      { x: 1400, y: 1400, w: 280, h: 24, type: 'one-way' },
      { x: 2100, y: 1480, w: 260, h: 24, type: 'one-way' },
      { x: 2800, y: 1380, w: 300, h: 24, type: 'one-way' },
      { x: 3500, y: 1460, w: 280, h: 24, type: 'one-way' },
      { x: 4200, y: 1380, w: 300, h: 24, type: 'one-way' },
      // 机关层竖墙（需要墙跳上升）
      { x: 1180, y: 1180, w: 60, h: 300, type: 'wall' },
      { x: 1500, y: 1180, w: 60, h: 300, type: 'wall' },
      { x: 3900, y: 1240, w: 60, h: 300, type: 'wall' },
    ],
  },
  {
    id: 'floor3',
    name: '塔外环廊',
    groundY: 2100,
    hint: '高空的风很大。灯笼接力——点亮它们！',
    platforms: [
      { x: 0, y: 2220, w: 5600, h: 120, type: 'solid' },
      { x: 600, y: 2080, w: 240, h: 24, type: 'one-way' },
      { x: 1150, y: 2000, w: 220, h: 24, type: 'one-way' },
      { x: 1700, y: 2080, w: 240, h: 24, type: 'one-way' },
      { x: 2250, y: 1980, w: 220, h: 24, type: 'one-way' },
      { x: 2800, y: 2060, w: 240, h: 24, type: 'one-way' },
      { x: 3350, y: 1960, w: 220, h: 24, type: 'one-way' },
      { x: 3900, y: 2040, w: 260, h: 24, type: 'one-way' },
      // 环廊外墙（攀墙路线）
      { x: 1000, y: 1700, w: 60, h: 380, type: 'wall' },
      { x: 2600, y: 1700, w: 60, h: 380, type: 'wall' },
    ],
  },
  {
    id: 'floor2',
    name: '悬空工坊',
    groundY: 2700,
    hint: '强盗正在搬空工坊。潜行，或战斗。',
    platforms: [
      { x: 0, y: 2820, w: 5600, h: 120, type: 'solid' },
      { x: 550, y: 2680, w: 260, h: 24, type: 'one-way' },
      { x: 1100, y: 2600, w: 240, h: 24, type: 'one-way' },
      { x: 1700, y: 2680, w: 260, h: 24, type: 'one-way' },
      { x: 2300, y: 2580, w: 240, h: 24, type: 'one-way' },
      { x: 2900, y: 2660, w: 280, h: 24, type: 'one-way' },
      { x: 3500, y: 2560, w: 260, h: 24, type: 'one-way' },
      { x: 4100, y: 2640, w: 280, h: 24, type: 'one-way' },
      { x: 4700, y: 2560, w: 260, h: 24, type: 'one-way' },
      // 工坊内隔墙
      { x: 1500, y: 2380, w: 60, h: 300, type: 'wall' },
      { x: 3200, y: 2380, w: 60, h: 300, type: 'wall' },
    ],
  },
  {
    id: 'floor1',
    name: '古镇街巷',
    groundY: 3300,
    hint: '半毁的街巷。强盗的火把已经进了镇子。',
    platforms: [
      { x: 0, y: 3420, w: 5600, h: 120, type: 'solid' },
      { x: 500, y: 3280, w: 280, h: 24, type: 'one-way' },
      { x: 1050, y: 3200, w: 260, h: 24, type: 'one-way' },
      { x: 1650, y: 3280, w: 280, h: 24, type: 'one-way' },
      { x: 2250, y: 3180, w: 260, h: 24, type: 'one-way' },
      { x: 2850, y: 3260, w: 280, h: 24, type: 'one-way' },
      { x: 3450, y: 3160, w: 260, h: 24, type: 'one-way' },
      { x: 4050, y: 3240, w: 280, h: 24, type: 'one-way' },
      { x: 4650, y: 3160, w: 260, h: 24, type: 'one-way' },
      // 街巷跨街铁门（斩绳机关）
      { x: 2450, y: 2980, w: 40, h: 200, type: 'solid' },
      // 上层入口墙体
      { x: 5150, y: 2980, w: 60, h: 300, type: 'wall' },
      { x: 5480, y: 2980, w: 60, h: 300, type: 'wall' },
    ],
  },
  {
    id: 'floor0',
    name: '古镇河岸',
    groundY: 3900,
    hint: '回溯后的落点。A/D 移动，Space 跳跃（空中可再跳一次）。',
    platforms: [
      { x: 0, y: 4020, w: 5600, h: 180, type: 'solid' },
      { x: 800, y: 3880, w: 260, h: 24, type: 'one-way' },
      { x: 1500, y: 3800, w: 240, h: 24, type: 'one-way' },
      { x: 2200, y: 3880, w: 260, h: 24, type: 'one-way' },
      { x: 2900, y: 3800, w: 240, h: 24, type: 'one-way' },
      { x: 3600, y: 3880, w: 260, h: 24, type: 'one-way' },
      { x: 4300, y: 3800, w: 240, h: 24, type: 'one-way' },
      // 河岸通往街巷的墙（自动吸附教学）
      { x: 5150, y: 3560, w: 60, h: 340, type: 'wall' },
      { x: 5480, y: 3560, w: 60, h: 340, type: 'wall' },
    ],
  },
];

/** 世界生成点（回溯后落点） */
export const SPAWN = { x: 200, y: 3860 };

/** 关键 NPC / 物件位置 */
export const PLACEMENTS = {
  shenyanFirst: { x: 900, y: 3860 },
  shenyanTower: { x: 3100, y: 760 },
  observer: { x: 4200, y: 760 },
  boss: { x: 4600, y: 1360 },
  confrontation: { x: 4400, y: 260 },
  bellMechanism: { x: 2900, y: 2540 },
  ropeBridge: { x: 2450, y: 3000 },
  lanterns: [
    { x: 600, y: 2020 },
    { x: 1700, y: 2020 },
    { x: 2800, y: 2000 },
    { x: 3900, y: 1980 },
  ],
};
