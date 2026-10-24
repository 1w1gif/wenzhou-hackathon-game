// data/tower.ts — 七层塔关卡数据（世界坐标：左下原点，Y 向上）
import { BellDef, CheckpointDef, ClimbWall, CollectibleDef, EnemySpawn, GateDef, Hazard, Ladder, LanternDef, Platform, PlateDef, PortalDef, PushStoneDef, RopeDef, StarNodeDef, StoryTriggerDef, SwordSlotDef, WindSigilDef } from "core/types";

// 空间压缩版（小而满）：每层净宽 2480（≈2 屏），传送门=右边界、检查点=左边界。
export const WORLD_W = 2560;
export const WORLD_H = 8600;

// 七层可行走地面高度（= 各层地面顶边 y）。层间距 1280px，远超单跳高度 ≈170px：
// 层与层在空间上彻底隔离——既不可跳越/攀爬到达相邻层，站在一层也看不见另一层，
// 换层只能走每层尽头的传送门。
export const TOPS = [220, 1500, 2800, 4100, 5400, 6700, 8000];
// 各层整体平移增量（下标=层号）：旧数据 y + DELTA[floor] = 新 y。
export const DELTA = [0, 800, 1620, 2420, 3220, 4020, 4710];

export const FLOORS: string[] = [
  "河滩 · 渡口",
  "古镇街巷",
  "悬空工坊",
  "塔外环廊",
  "机关层",
  "观星者之间",
  "观星台",
];

// 每层任务指引（右上角「月相轮的指引」面板任务行，含按键提示；下标=层号）
export const FLOOR_MISSIONS: string[] = [
  "走近树苗按 E 拾取，种入东侧枯坑，唤醒渡口传送门",
  "以剑气 K 敲钟，或跳劈斩断酒馆吊绳，开启街门",
  "拾取五枚点灯石，走近悬灯按 E 依序点亮",
  "化作疾风：冲刺穿过五枚风息符文，唤醒廊门",
  "推石上压板，并以剑气 K 插入剑槽，开启机门",
  "按 E 依序点亮六座星位连成星图（错序熄灭重来），开启星门",
  "直面申言，了结八相循环",
];

function plat(id: string, kind: Platform["kind"], floor: number, x: number, y: number, w: number, h: number, gateId?: string): Platform {
  return { id, kind, floor, x, y, w, h, gateId };
}

export const platforms: Platform[] = [
  // 每层一条全宽实心地面板（板顶 = TOPS[floor]）：层内任何位置都不会坠落虚空
  plat("g00", "solid", 0, 0, 140, 2480, 80),
  // ---- f1 古镇街巷（跑酷简化版 2026-11，实机反馈整改·第二轮）----
  // 引擎坐标 Y 向上：街道顶 = TOPS[1] = 1500。地面整条全宽实心（g10），原中段塔陷缺口永久填平：
  // 陷阱回归为贴街面尖刺带 hz_street(1100-1400)，底部由实心 g10 封死，无洞无隙、不可钻越；
  // 墙缝井 t_well1/t_well2、瞪墙攀爬 cw_t1/cw_t2、最高檐回折线 t_r16/t_rest4/t_r17/t_r18
  // 均按「障碍过多」验收意见删除；破洞遮棚木板 t_canopy 按验收意见删除；
  // 屋顶线保留一条自西向东缓升的选做高路线：矮檐→中檐→喘息台①（弓手+晨露）→密集连跳（碎片+割绳位）；
  // 最高檐 t_top 从矮檐段二段跳上翻（其上碎片发光）。
  plat("g10", "solid", 1, 0, 1420, 2480, 80), // 整条街道 0~2480（原塌陷坑已填平）
  plat("t_aw1", "one-way", 1, 400, 1564, 70, 16), // 矮檐段①（入口右上，碎片在檐上）
  plat("t_aw2", "one-way", 1, 600, 1688, 70, 16),
  plat("t_bw1", "one-way", 1, 800, 1828, 70, 16), // 中檐段
  plat("t_bw2", "one-way", 1, 1000, 1948, 80, 16),
  plat("t_rest1", "solid", 1, 1200, 2036, 150, 24), // 喘息台①（晨露+弓手C 站位）
  plat("t_c1", "one-way", 1, 1500, 2088, 70, 16), // 密集连跳段（屋顶线纵向折叠，层叠在西段上空）
  plat("t_c2", "one-way", 1, 1700, 2128, 70, 16),
  plat("t_c3", "one-way", 1, 1900, 2148, 80, 16),
  plat("t_c4", "one-way", 1, 2100, 2128, 70, 16), // 断桥段（碎片在上方）
  plat("t_c5", "one-way", 1, 2250, 2108, 70, 16),
  plat("t_top", "solid", 1, 450, 1744, 180, 36), // 最高檐（矮檐段 aw2 二段跳上翻可达，其上碎片发光）
  plat("g20", "solid", 2, 0, 2720, 2480, 80),
  plat("g30", "solid", 3, 0, 4020, 2480, 80),
  plat("g40", "solid", 4, 0, 5320, 2480, 80),
  plat("g50", "solid", 5, 0, 6620, 2480, 80),
  plat("g60", "solid", 6, 0, 7920, 2480, 80),
  // 层内 one-way 平台（y = 旧值 + DELTA[floor]）
  plat("p00", "one-way", 0, 1250, 380, 180, 18),
  plat("p01", "one-way", 0, 1600, 390, 160, 18),
  plat("p02", "one-way", 0, 950, 310, 180, 18),
  plat("p03", "one-way", 0, 320, 370, 180, 18),
  plat("p04", "one-way", 0, 620, 340, 160, 18),
  plat("p20", "one-way", 2, 400, 2960, 180, 18),
  plat("p21", "one-way", 2, 900, 2970, 160, 18),
  plat("p23", "one-way", 2, 700, 2970, 200, 18), // 与 p21 顶面平齐（2988）且右缘相接，消除并置板高低差卡脚（实机反馈 2026-10-26）
  plat("p22", "one-way", 2, 1400, 2970, 180, 18),
  // 整改①·2F 点灯垂直化：三盏悬灯散在三个高度（地面→吊板→高台），点亮顺序=爬升路线
  plat("p24", "one-way", 2, 1180, 3110, 120, 18), // 吊板：p21 顶 2988 跳 140，lt1 挂其上
  plat("p25", "one-way", 2, 1520, 3270, 120, 18), // 高台：p24 顶 3128 跳 160/横 220，lt2 挂其上
  plat("mv30", "solid", 3, 1000, 4060, 170, 20, undefined),
  plat("p30", "one-way", 3, 400, 4260, 180, 18),
  plat("p31", "one-way", 3, 1600, 4270, 160, 18),
  plat("p32", "one-way", 3, 1000, 4190, 160, 18),
  // 3F 环廊东段踏板（顶 4248：风息符文 ws2 与廊门之间的瞭望小台）
  plat("p33", "one-way", 3, 1950, 4230, 120, 18),
  plat("p40", "one-way", 4, 500, 5560, 180, 18),
  plat("p41", "one-way", 4, 1300, 5570, 170, 18),
  plat("p42", "one-way", 4, 900, 5490, 160, 18),
  plat("p50", "one-way", 5, 1200, 6860, 170, 18),
  // 5F 东侧登高链 地面→p51→p52→p53：星位 sn1/sn2/sn3 与 tk0 全在动线上
  plat("p51", "one-way", 5, 1750, 6820, 120, 18), // 顶 6838，星位 sn3 站位
  plat("p52", "one-way", 5, 1450, 6900, 110, 18), // p51 左跳 190/升 80
  plat("p53", "one-way", 5, 1150, 6980, 110, 18), // p52 左跳 190/升 80；右缘贴边站立即拾 tk0(1285,7012)
  plat("p60", "one-way", 6, 1000, 8160, 170, 18),
  // 整改①·6F：Boss 战场左右高台（走位纵深；p62 1550-1690 在 Boss 巡逻 1700 左缘外）
  plat("p61", "one-way", 6, 400, 8180, 140, 18),
  plat("p62", "one-way", 6, 1550, 8180, 140, 18),
  // 2026-10-26 玩法扩充：各层补登高台阶链（one-way，级差≤160 均可单/双跳登顶），顶上放旧物收集；
  // 坐标避开尖刺带/巡逻带/剧情触发带/传送门位，层间 1280 净空绝不触上层（y 为板底、板顶 = y+18）。
  plat("p05", "one-way", 0, 1900, 350, 150, 18), // 0F 东段台阶①（渡口地面 220 单跳升 148）
  plat("p06", "one-way", 0, 2080, 470, 150, 18), // 0F 台阶②（升 120）
  plat("p07", "one-way", 0, 1900, 590, 150, 18), // 0F 台阶③（升 120），tk2 在其上
  plat("p13", "one-way", 1, 160, 1630, 140, 18), // 1F 西端台阶①（街面 1500 单跳升 148）
  plat("p14", "one-way", 1, 320, 1760, 120, 18), // 1F 台阶②（升 130，东缘避开最高檐 t_top x450）
  plat("p15", "one-way", 1, 160, 1890, 120, 18), // 1F 台阶③（升 130），tk3 在其上
  plat("p26", "one-way", 2, 300, 3120, 140, 18), // 2F 西段高阶①（双跳升 338），lt3 挂其上
  plat("p27", "one-way", 2, 100, 3280, 140, 18), // 2F 西段高阶②（升 160），lt4 挂其上
  plat("p34", "one-way", 3, 1750, 4380, 130, 18), // 3F 东段高台（p33 顶 4248 升 150），tk4 在其上
  plat("p43", "one-way", 4, 250, 5720, 140, 18), // 4F 西段高阶（p40 顶 5578 升 160），tk5 在其上
  plat("p54", "one-way", 5, 880, 7060, 120, 18), // 5F 登高链延伸①（p53 顶 6998 升 80），sn4 站位
  plat("p55", "one-way", 5, 560, 7150, 110, 18), // 5F 登高链延伸②（升 90），sn5 站位
  // 机关门（闭合时阻挡、开门后通行；碰撞与渲染同用此数组）
  // 酒馆大门（gate_town）移到广场西口：敲钟 bell0 + 割绳 rope0 开门，门后是酒馆内堂与 2F 传送门
  plat("gp_town", "gate", 1, 2050, 1500, 40, 220, "gate_town"),
  // gp_workshop 已删：原为无任何机关挂接的死门（gate_workshop 永不开启），会把玩家永久挡在 2F 传送门前；
  // 2F 通关条件由顺序点灯（lanternGate）唯一承担。
  plat("gp_corridor", "gate", 3, 2150, 4100, 40, 240, "gate_corridor"),
  plat("gp_mech", "gate", 4, 2150, 5400, 40, 240, "gate_mech"),
  plat("gp_lantern", "gate", 2, 1900, 2800, 40, 230, "lanternGate"),
  plat("gp_star", "gate", 5, 2150, 6700, 40, 240, "gate_star"), // 观星者之间：四座星位按序点亮开门
  // 世界边界墙：左右封死，高度覆盖全塔（8600），防止走出世界
  plat("wallL", "solid", 0, -80, 0, 80, 8600),
  plat("wallR", "solid", 0, 2480, 0, 80, 8600),
];
// 层间垫底平台 pt0~pt5 已删除：各层地面全宽实心后不存在缺口，且它们原本构成跨层路径。

// 移动平台（game.ts 用 lerp pingpong 驱动 mover）——按 id 查找，避免数组顺序变化导致索引错位（曾把 mover 错挂到 p22 上）
const mv30 = platforms.find((p) => p.id === "mv30");
if (mv30 !== undefined) {
  mv30.mover = { ax: 1000, ay: 4060, bx: 1100, by: 4520, period: 7.5, phase: 0 };
}

export const movers: Platform[] = platforms.filter((p) => p.mover !== undefined);

// 层间彻底隔离：跨层梯（原 l0~l5）全部移除，禁止攀爬换层（攀爬与渲染逻辑均兼容空数组）
export const ladders: Ladder[] = [];

// 攀爬墙布局（2026-10-27 用户裁定）：只保留各层传送门前一面攀爬墙，其余层不放——
// 西端/中段的装饰性短墙（渡口井边 940/1800、工坊 1700、环廊 300、机关层 250、星野 350、绝顶 2300）
// 会挡住背景的树与建筑，全部撤除。每面墙 h=200 远低于 1280px 层间距，绝不触上层；
// 立于门(gp_* 右缘 2190/1940)与传送门(2340)之间做终点小挑战：贴墙爬上翻顶即到门前。
// 10-27 二次裁定：六墙再左移 40px 至 x=2200（墙右缘 2260 与门 2340 拉开 80px），避免挡住时空门贴图。
export const climbWalls: ClimbWall[] = [
  { id: "cwpt0", floor: 0, x: 2200, y: 220, w: 60, h: 200 }, // 渡口：门前柱（墙顶可跳上 p06 东端 2230）
  { id: "cwpt1", floor: 1, x: 2200, y: 1500, w: 60, h: 200 }, // 街巷：门前柱（断桥 t_c5 悬空 y2108 不相触）
  { id: "cwpt2", floor: 2, x: 2200, y: 2800, w: 60, h: 200 }, // 工坊：门前柱
  { id: "cwpt3", floor: 3, x: 2200, y: 4100, w: 60, h: 200 }, // 环廊：门前柱（ms19 挪到墙顶上方作翻越奖励）
  { id: "cwpt4", floor: 4, x: 2200, y: 5400, w: 60, h: 200 }, // 机关层：门前柱（贴墙左站即入 st7 触发带，提示更就近）
  { id: "cwpt5", floor: 5, x: 2200, y: 6700, w: 60, h: 200 }, // 星野：门前柱（ms16 移至 2160 保持墙左侧独立拾取）
];
// 观星台（6 层）为终点 Boss 层、无传送门——按裁定不放墙；ms18(2350,8080) 站地即可拾（站立位差 2px）。
// 实心墙身配对：与攀爬标记同矩形（solid）。缺此循环则 moveX 撞不到实心侧面、wallDir 恒 0，蹬墙哑火（幽灵墙）。
for (const cw of climbWalls) {
  platforms.push({
    id: cw.id + "_body",
    kind: "solid",
    floor: cw.floor,
    x: cw.x,
    y: cw.y,
    w: cw.w,
    h: cw.h,
  });
}

// 尖刺陷阱（实机反馈：陷阱回归，但底部必须封死）：hz_street 贴街面（y=1500=g10 顶）铺 300px 尖刺带，
// 踩上持续掉血（player.hurt 1.1s 无敌帧）；下方是实心 g10，无洞无空隙、不能钻下去——
// 二段跳（≈365px > 300px）可整体跳过，空中顺路够到 tk1(1250,1580)；
// 渲染（render_world 主题尖刺瓦片）与伤害（game.checkHazards）共用本数组。
export const hazards: Hazard[] = [
  { id: "hz_street", floor: 1, x: 1100, y: 1500, w: 300, h: 40, damage: 1 },
  // 整改①：三层补地刺带（y=TOPS[floor] 贴地面，底=实心全宽地面封死；带宽均 < 单跳 365 可整体跳过）
  { id: "hz_ws", floor: 2, x: 1200, y: 2800, w: 140, h: 40, damage: 1 }, // 工坊：e20(止1150)/e21(起1380) 两巡逻带之间，p24 吊板正上方
  { id: "hz_gal", floor: 3, x: 1620, y: 4100, w: 140, h: 40, damage: 1 }, // 环廊：e31(止1580) 与钟区 1900 之间，p31 正上方（精确跳跃）
  { id: "hz_star", floor: 5, x: 950, y: 6700, w: 180, h: 40, damage: 1 }, // 星野：e50(止850)/e51(起1450) 之间，p50 左侧
];

export const enemies: EnemySpawn[] = [
  // 第0层·渡口：巡逻带避开触发区 st0(400-680)/st1(720-1000)；
  // e02 在出生点(cp_riverbank x=160)右侧远处：左缘 520 距重生点 360 > 索敌半径 330，
  // 开局/重生都不会被贴脸偷袭；e03 随空间压缩删除
  { id: "e00", kind: "bandit", floor: 0, x: 1450, y: 300, patrolMin: 1300, patrolMax: 1600, loops: undefined },
  { id: "e01", kind: "thrower", floor: 0, x: 1900, y: 300, patrolMin: 1750, patrolMax: 2050, loops: undefined },
  { id: "e02", kind: "bandit", floor: 0, x: 630, y: 300, patrolMin: 520, patrolMax: 740, loops: undefined },
  // 第1层·古镇街巷（教学三敌不合并）：
  // eA=e10 站桩匪兵（入口后 0.5 屏，面朝左向来路，低血直冲→教轻击三连）；
  // eB=e12 巡逻突进匪（街面中段巡逻，发现即突进→教完美闪避）；
  // eC=e14 弓手（屋顶喘息台①固定站位朝下射箭，箭有抬手前摇→教跳跃接近+空中攻击）；
  // e11/e13 保留在酒馆广场段（门西草丛潜行可选）
  { id: "e10", kind: "bandit", floor: 1, x: 700, y: 1580, patrolMin: 700, patrolMax: 700, face: -1, holdPosition: true, loops: undefined },
  { id: "e12", kind: "bandit", floor: 1, x: 950, y: 1580, patrolMin: 880, patrolMax: 1040, lunge: true, loops: undefined },
  { id: "e14", kind: "archer", floor: 1, x: 1275, y: 2060, patrolMin: 1210, patrolMax: 1340, face: -1, loops: undefined }, // 喘息台①（顶 2060）上贴地巡逻+游走放箭（可移动弓手）
  { id: "e11", kind: "bandit", floor: 1, x: 1780, y: 1580, patrolMin: 1720, patrolMax: 1840, loops: undefined },
  { id: "e13", kind: "thrower", floor: 1, x: 1930, y: 1580, patrolMin: 1880, patrolMax: 1990, loops: undefined },
  // 第2层·悬空工坊：e21 在 lt1 与 lt2 之间
  { id: "e20", kind: "thrower", floor: 2, x: 1000, y: 2880, patrolMin: 850, patrolMax: 1150, loops: undefined },
  { id: "e21", kind: "bandit", floor: 2, x: 1500, y: 2880, patrolMin: 1380, patrolMax: 1620, loops: undefined },
  // 第3层·塔外环廊：e30 收窄避开 st5(400-700)；e31 在 st5 与 st6 之间
  { id: "e30", kind: "bandit", floor: 3, x: 850, y: 4180, patrolMin: 760, patrolMax: 940, loops: undefined },
  { id: "e31", kind: "thrower", floor: 3, x: 1450, y: 4180, patrolMin: 1320, patrolMax: 1580, loops: undefined },
  // 第4层·机关层：e40 收窄避开 st7(1900-2220)
  { id: "e40", kind: "bandit", floor: 4, x: 1100, y: 5480, patrolMin: 950, patrolMax: 1250, loops: undefined },
  { id: "e41", kind: "thrower", floor: 4, x: 1800, y: 5480, patrolMin: 1650, patrolMax: 1880, loops: undefined },
  { id: "e42", kind: "bandit", floor: 4, x: 450, y: 5480, patrolMin: 350, patrolMax: 550, loops: undefined },
  // 第5层·观星者之间
  { id: "e50", kind: "thrower", floor: 5, x: 700, y: 6780, patrolMin: 550, patrolMax: 850, loops: undefined },
  { id: "e51", kind: "bandit", floor: 5, x: 1600, y: 6780, patrolMin: 1450, patrolMax: 1750, loops: undefined },
  // 第6层·观星台：头目镇场
  { id: "eboss", kind: "boss", floor: 6, x: 1900, y: 8080, patrolMin: 1700, patrolMax: 2250, loops: undefined },
];
  // 第5层·观星者之间：检查点两侧各一


export const collectibles: CollectibleDef[] = [
  { id: "ms0", kind: "moonstone", floor: 0, x: 1335, y: 460, note: "月石·渡口", loops: undefined },
  { id: "ms1", kind: "moonstone", floor: 1, x: 540, y: 1840, note: "月华碎片·最高檐（矮檐段二段跳可达）", loops: undefined }, // 最高檐 t_top 顶 1780 上方
  { id: "ms2", kind: "moonstone", floor: 2, x: 1490, y: 3050, note: "月石·工坊", loops: undefined },
  { id: "mp0", kind: "mechanism", floor: 3, x: 1680, y: 4350, note: "机关部件", loops: undefined },
  { id: "mp1", kind: "mechanism", floor: 4, x: 1700, y: 5480, note: "机关部件", loops: undefined },
  { id: "tk0", kind: "token", floor: 5, x: 1285, y: 7012, note: "引月札残页", loops: undefined }, // 原 y=6940 悬在台面下 58px，松键直落才进 38px 判定圈——抬高到缘口高度，贴缘站立（距≈28px）即拾
  { id: "dw0", kind: "dew", floor: 0, x: 260, y: 320, note: "晨露", loops: undefined },
  // 1F 屋顶线中段喘息台②旁的晨露（回溯后已吃不重生）
  { id: "dw6", kind: "dew", floor: 1, x: 1275, y: 2140, note: "晨露", loops: undefined }, // 喘息台①顶 2060 上方
  // 沈砚线索第一张：原在塌陷坑底，坑已填平，移到原坑位的街面（石子堆与旧井之间）
  { id: "tk1", kind: "token", floor: 1, x: 1250, y: 1580, note: "线索·沈砚的过往其一", loops: undefined }, // 街道站立面 1500 上方
  { id: "dw1", kind: "dew", floor: 3, x: 490, y: 4340, note: "晨露", loops: undefined },
  { id: "ms7", kind: "moonstone", floor: 6, x: 1085, y: 8240, note: "月石·观星台", loops: undefined },
  // 整改六：月华碎片补齐至 21 枚（每层 3 枚）；坐标全部落在已有平台顶边 +80 或地面站立可达位，
  // 并避开既有收集品/机关件（ms4 树冠位由 0 层种树谜题动态解锁，详见 game/render_world 树冠梯）。
  { id: "ms3", kind: "moonstone", floor: 0, x: 400, y: 450, note: "月石·浅滩", loops: undefined },
  { id: "ms4", kind: "moonstone", floor: 0, x: 1200, y: 840, note: "月石·树冠", loops: undefined },
  { id: "ms5", kind: "moonstone", floor: 1, x: 435, y: 1640, note: "月华碎片·入口矮檐", loops: undefined }, // 矮檐 t_aw1 顶 1564 上方
  { id: "ms6", kind: "moonstone", floor: 1, x: 2135, y: 2200, note: "月华碎片·断桥中点", loops: undefined }, // 断桥 t_c4 顶 2128 上方
  { id: "ms8", kind: "moonstone", floor: 2, x: 980, y: 3050, note: "月石·工棚", loops: undefined },
  { id: "ms9", kind: "moonstone", floor: 2, x: 490, y: 3040, note: "月石·吊板", loops: undefined },
  { id: "ms10", kind: "moonstone", floor: 3, x: 1085, y: 4640, note: "月石·云梯", loops: undefined }, // 移动平台 mv30 顶 4540 上方
  { id: "ms11", kind: "moonstone", floor: 3, x: 1080, y: 4270, note: "月石·廊柱", loops: undefined },
  { id: "ms12", kind: "moonstone", floor: 4, x: 590, y: 5640, note: "月石·枢轮", loops: undefined },
  { id: "ms13", kind: "moonstone", floor: 4, x: 1385, y: 5650, note: "月石·暗阁", loops: undefined },
  { id: "ms14", kind: "moonstone", floor: 5, x: 400, y: 6780, note: "月石·星野", loops: undefined },
  { id: "ms15", kind: "moonstone", floor: 5, x: 1500, y: 6780, note: "月石·望台", loops: undefined },
  { id: "ms16", kind: "moonstone", floor: 5, x: 2160, y: 6780, note: "月石·天渊", loops: undefined },
  { id: "ms17", kind: "moonstone", floor: 6, x: 300, y: 8080, note: "月石·台基", loops: undefined },
  { id: "ms18", kind: "moonstone", floor: 6, x: 2350, y: 8080, note: "月石·绝顶", loops: undefined },
  { id: "ms19", kind: "moonstone", floor: 3, x: 2230, y: 4360, note: "月石·长风", loops: undefined }, // 门前攀爬墙顶(4300)上方：翻墙即拾
  { id: "ms20", kind: "moonstone", floor: 4, x: 980, y: 5570, note: "月石·沉沙", loops: undefined },
  // 整改六：晨露布点 0F/2F/4F/6F 各 1 + 6F 额外 1（dw1 为既有 3 层额外补给）；回溯后已吃的晨露不重生。
  { id: "dw2", kind: "dew", floor: 2, x: 780, y: 3050, note: "晨露", loops: undefined }, // p23 抬至顶 2988 后同步上移，维持板顶上方 62px 悬浮惯例
  { id: "dw3", kind: "dew", floor: 4, x: 800, y: 5480, note: "晨露", loops: undefined },
  { id: "dw4", kind: "dew", floor: 6, x: 600, y: 8080, note: "晨露", loops: undefined },
  { id: "dw5", kind: "dew", floor: 6, x: 1500, y: 8080, note: "晨露", loops: undefined },
  // 点灯石（第 2 层点灯解谜）：拾取后才能点亮灯笼，每点亮一盏消耗一枚。
  // 位置避让：p20 平台 x 3400-3580 / p21 3900-4060 / 传送门 pt_f1 x=3800。
  { id: "ls0", kind: "lampstone", floor: 2, x: 450, y: 2860, note: "点灯石", loops: undefined },
  { id: "ls1", kind: "lampstone", floor: 2, x: 950, y: 2860, note: "点灯石", loops: undefined },
  { id: "ls2", kind: "lampstone", floor: 2, x: 1450, y: 2860, note: "点灯石", loops: undefined },
  // 2026-10-26 玩法扩充：点灯石增至五枚（配 lt3/lt4，点亮消耗 1:1 恰好够用）；
  // 旧物 tk2-tk5 置于新台阶顶（板顶+80），引月札旧物计数动态可达。
  { id: "ls3", kind: "lampstone", floor: 2, x: 250, y: 2860, note: "点灯石", loops: undefined }, // 西端检查点旁
  { id: "ls4", kind: "lampstone", floor: 2, x: 1550, y: 2860, note: "点灯石", loops: undefined }, // 吊板 p22 下方地面，e21 巡逻带内（守卫看护）
  { id: "tk2", kind: "token", floor: 0, x: 1975, y: 688, note: "旧物·渡口的船铃", loops: undefined },
  { id: "tk3", kind: "token", floor: 1, x: 220, y: 1988, note: "旧物·檐下的风铃", loops: undefined },
  { id: "tk4", kind: "token", floor: 3, x: 1815, y: 4478, note: "旧物·环廊的星图残角", loops: undefined },
  { id: "tk5", kind: "token", floor: 4, x: 320, y: 5818, note: "旧物·机关层的齿轮挂坠", loops: undefined },
];

export const checkpoints: CheckpointDef[] = [
  { id: "cp_riverbank", floor: 0, x: 160, y: 220, label: "渡口石阶" },
  // 1F 双存档点：入口点灯石 + 酒馆广场点灯石（点灯石＝存档+照明，旁挂灯笼）
  { id: "cp_town", floor: 1, x: 160, y: 1500, label: "古镇入口" },
  { id: "cp_tavern", floor: 1, x: 1720, y: 1500, label: "酒馆广场" },
  { id: "cp_workshop", floor: 2, x: 160, y: 2800, label: "悬空工坊" },
  { id: "cp_corridor", floor: 3, x: 160, y: 4100, label: "塔外环廊" },
  { id: "cp_mechanism", floor: 4, x: 160, y: 5400, label: "机关层枢纽" },
  { id: "cp_observer", floor: 5, x: 160, y: 6700, label: "观星者之间" },
  { id: "cp_observatory", floor: 6, x: 160, y: 8000, label: "观星台" },
];
// 传送门：本层玩法通关（gateId 对应的开门解谜完成）后才产生——解谜前不渲染、不可触发，
// 防止玩家跳过本层玩法直接传送去下一层。产生后仍是「行至门左侧 350px 内显现、按 E 传送」。
// 观星台（6 层）为终点层，不设传送门。背景只在传送时整块切换。
export const portals: PortalDef[] = [
  { id: "pt_f0", floor: 0, x: 2340, y: 220, targetFloor: 1, gateId: "gate_ferry" },
  { id: "pt_f1", floor: 1, x: 2340, y: 1500, targetFloor: 2, gateId: "gate_town" },
  { id: "pt_f2", floor: 2, x: 2340, y: 2800, targetFloor: 3, gateId: "lanternGate" },
  { id: "pt_f3", floor: 3, x: 2340, y: 4100, targetFloor: 4, gateId: "gate_corridor" },
  { id: "pt_f4", floor: 4, x: 2340, y: 5400, targetFloor: 5, gateId: "gate_mech" },
  { id: "pt_f5", floor: 5, x: 2340, y: 6700, targetFloor: 6, gateId: "gate_star" },
];

export const ropes: RopeDef[] = [
  // rope0 移到酒馆大门上方（门顶 1720，绳底恰好门前）：割绳开门
  { id: "rope0", floor: 1, x: 2070, y: 1980, length: 260, gateId: "gate_town", loopState: "resets" },
];

export const bells: BellDef[] = [
  // bell0 移到广场西口（跳劈可及高度，与门隔一段距离，先敲钟再割绳）
  { id: "bell0", floor: 1, x: 1850, y: 1740, gateId: "gate_town" },
];

export const plates: PlateDef[] = [
  { id: "plate0", floor: 4, x: 900, y: 5400, gateId: "gate_mech" },
  { id: "plate1", floor: 4, x: 1300, y: 5400, gateId: "gate_mech" },
];

export const lanterns: LanternDef[] = [
  // 整改①·2F 点灯垂直化：order1 地面 → order2 吊板 p24 顶(3128)+80 → order3 高台 p25 顶(3288)+80，
  // 点灯判距 |dx|+|dy|*0.5<60 与原地面口径一致（玩家站台体中心 34px）。e21 巡逻带 1380-1620 仍在两灯之间。
  { id: "lt0", floor: 2, x: 600, y: 2880, order: 1 },
  { id: "lt1", floor: 2, x: 1240, y: 3208, order: 2 },
  { id: "lt2", floor: 2, x: 1580, y: 3368, order: 3 },
  // 2026-10-26 玩法扩充：增至五盏——order4/5 落西段新台阶 p26(顶 3138)/p27(顶 3298)，灯挂台顶+80；
  // 从东侧高台 lt2 横穿回西段收尾，点亮判距 |dx|+|dy|*0.5<60 不变（站台上 34px 内可及）。
  { id: "lt3", floor: 2, x: 370, y: 3218, order: 4 },
  { id: "lt4", floor: 2, x: 170, y: 3378, order: 5 },
];

export const pushStones: PushStoneDef[] = [
  { id: "stone0", floor: 4, x: 600, y: 5400 },
];

// 剑槽（第 4 层机关层）：用剑插进剑槽当钥匙开 gate_mech——与压力板（900/1300）
// + 推石 stone0(起始 600) 并列的第二解法。gp_mech 门在 x=2150。
export const swordSlots: SwordSlotDef[] = [
  { id: "slot_mech", floor: 4, x: 1500, y: 5400, gateId: "gate_mech" },
];

// 风息符文（F3 塔外环廊）：五枚风纹石环，冲刺穿过激活（走路不触发；判定 |dy|<90），
// 全亮后满足 gate_corridor 需求。ws0-ws2 地面主动线（西端入口→中段云梯区→东段瞭望台前），
// ws3/ws4 为 2026-10-26 新增高台符文（站 p30/p33 顶冲刺穿越），均避开尖刺带 hz_gal 与 st5 剧情区。
export const windSigils: WindSigilDef[] = [
  { id: "ws0", floor: 3, x: 720, y: 4100, gateId: "gate_corridor" },
  { id: "ws1", floor: 3, x: 1350, y: 4100, gateId: "gate_corridor" },
  { id: "ws2", floor: 3, x: 1830, y: 4100, gateId: "gate_corridor" },
  { id: "ws3", floor: 3, x: 450, y: 4278, gateId: "gate_corridor" }, // 高台：p30 顶 4278
  { id: "ws4", floor: 3, x: 2010, y: 4248, gateId: "gate_corridor" }, // 高台：p33 顶 4248
];

// 星位（F5 观星者之间）：六座石柱星芒，按 order 依序点亮（错序全部熄灭重来），
// 全亮后满足 gate_star 需求。sn0 层西入口主动线，sn1/sn2/sn3 落东侧登高链
// p50(顶 6878)/p52(顶 6918)/p51(顶 6838) 平台上；sn4/sn5 为 2026-10-26 新增延伸两级
// p54(顶 7078)/p55(顶 7168)，点亮顺序=登高路线，星间连线随数组自动延展。
export const starNodes: StarNodeDef[] = [
  { id: "sn0", floor: 5, x: 420, y: 6700, order: 1, gateId: "gate_star" },
  { id: "sn1", floor: 5, x: 1240, y: 6878, order: 2, gateId: "gate_star" },
  { id: "sn2", floor: 5, x: 1505, y: 6918, order: 3, gateId: "gate_star" },
  { id: "sn3", floor: 5, x: 1810, y: 6838, order: 4, gateId: "gate_star" },
  { id: "sn4", floor: 5, x: 940, y: 7078, order: 5, gateId: "gate_star" }, // p54 顶（2026-10-26 新增）
  { id: "sn5", floor: 5, x: 615, y: 7168, order: 6, gateId: "gate_star" }, // p55 顶（2026-10-26 新增）
];

export const gates: GateDef[] = [
  { id: "gate_town", floor: 1 },
  { id: "gate_corridor", floor: 3 },
  { id: "gate_mech", floor: 4 },
  { id: "lanternGate", floor: 2 },
  { id: "gate_star", floor: 5 },
  // gate_workshop 已删：原为无机关挂接的死门；gate_ferry（F0 种树谜题通关）由 game.ts 种树成功时开启，
  // 不需要门平台，仅作 pt_f0 的 gating 条件。
];

// 多条件门（用户需求③⑤）：条件全部齐备才开门，单条完成不开门。格式 "kind:id"，
// kind ∈ bell(敲钟)/rope(斩绳)/plate(压板)/slot(剑槽)/wind(风息符文)/star(星位)；
// id 段可用 "+" 表任一（两块压板任一被压上都算完成「推石上压板」）。未列出的门维持单条件开门。
export const gateRequirements: Record<string, string[]> = {
  gate_corridor: ["wind:ws0", "wind:ws1", "wind:ws2", "wind:ws3", "wind:ws4"], // F3 塔外环廊：五枚风息符文全部冲刺穿过
  gate_mech: ["plate:plate0+plate1", "slot:slot_mech"], // F4 机关层：推石上压板 + 剑器插入剑槽
  gate_star: ["star:sn0", "star:sn1", "star:sn2", "star:sn3", "star:sn4", "star:sn5"], // F5 观星者之间：六座星位按序点亮
};

// 门平台引用：gate 已并入 platforms（openedGates 内为 true 时通行/开启）
export const gatePlatforms: Platform[] = platforms.filter((p) => p.kind === "gate");

export const storyTriggers: StoryTriggerDef[] = [
  // 区域互不重叠；y = TOPS[floor] - 120，触发带跨层内地面高度
  { id: "st0", floor: 0, x: 400, y: 100, w: 280, h: 360, storyId: "story_check_intro", once: true },
  { id: "st1", floor: 0, x: 420, y: 100, w: 280, h: 360, storyId: "story_riverside", once: true }, // 以男主 F0 站位(x=560)为中心：靠近即亮「按 E 对话」（气泡挂男主头顶；与 st0 独白带重叠无碍——独白不占 nearStoryId）
  // ---- 1F 古镇街巷触发带（教学浮字 hint：命中即浮现提示，不弹对话框不阻断）----
  { id: "st2", floor: 1, x: 380, y: 1380, w: 260, h: 360, storyId: "story_town", once: true },
  { id: "ht_dodge", floor: 1, x: 760, y: 1380, w: 240, h: 360, storyId: "hint_dodge", once: false, hint: "攻击瞬间按 Shift 闪避＝完美闪避！" },
  { id: "ht_air", floor: 1, x: 1210, y: 1880, w: 220, h: 320, storyId: "hint_air", once: false, hint: "跳跃接近＋空中攻击！" }, // 覆盖喘息台①弓手区
  { id: "st3", floor: 1, x: 1180, y: 1380, w: 220, h: 360, storyId: "story_sneak_hint", once: true },
  { id: "st4", floor: 1, x: 2120, y: 1380, w: 220, h: 360, storyId: "story_workshop", once: true },
  { id: "st5", floor: 3, x: 650, y: 3980, w: 300, h: 360, storyId: "story_observer_1", once: true }, // 以观测者站位(x=800)为中心：靠近即亮
  { id: "st6", floor: 3, x: 680, y: 3980, w: 320, h: 360, storyId: "story_observer_2", once: true }, // 同锚观测者：observer_1 播完后原地继续给 observer_2
  { id: "st7", floor: 4, x: 1900, y: 5280, w: 320, h: 360, storyId: "story_arrow", once: false },
];

export function mapSummary(): string {
  let s = "七层·衍月塔：";
  for (let i = 0; i < FLOORS.length; i++) {
    s += FLOORS[i];
    if (i < FLOORS.length - 1) {
      s += " → ";
    }
  }
  return s;
}