/**
 * 角色部件拼装（水墨古风）。
 * 每个角色 = 部件函数（发/头/身/袍/武器/标志物）按层叠出的完整 SVG 字符串。
 * 一眼可辨：衍月(高马尾+星光+背剑)、沈砚(交领袍+玉佩)、强盗(朱红头巾+环首刀)、
 * 投掷手(火把)、头目(披风+大刀)。
 */
import { PALETTE as P, STROKE, STROKE_THIN, S, wrap, shadow, INK } from './palette';

/* ---------------- 通用部件 ---------------- */

/** 高马尾（衍月标志）：发束 + 发梢星光点 */
function ponytail(back = true): string {
  const star = back
    ? `<circle cx="99" cy="72" r="2.2" fill="${P.moon}"/><circle cx="103" cy="63" r="1.6" fill="${P.cyan}"/><circle cx="97" cy="80" r="1.4" fill="${P.moon}"/>`
    : '';
  return `<path d="M72 30 Q92 26 96 46 Q100 62 92 74 Q88 60 78 50 Q70 42 68 34 Z" fill="${P.hair}" ${STROKE}/>${star}`;
}

/** 发髻（沈砚）：束发 + 简簪 */
function topknot(): string {
  return `<circle cx="60" cy="14" r="8" fill="${P.hair}" ${STROKE}/><rect x="57" y="4" width="3" height="10" rx="1.5" fill="${P.gold}" ${STROKE_THIN}/>`;
}

function face(skin = P.skin): string {
  return `<circle cx="60" cy="46" r="20" fill="${skin}" ${STROKE}/>`;
}

/** 眼睛：细长丹凤（古风感） */
function eyes(closed = false): string {
  if (closed) {
    return `<path d="M48 46 Q52 50 56 46" fill="none" stroke="${INK}" stroke-width="2.5" ${S}/><path d="M64 46 Q68 50 72 46" fill="none" stroke="${INK}" stroke-width="2.5" ${S}/>`;
  }
  return `<path d="M47 44 Q51 41 55 44" fill="none" stroke="${INK}" stroke-width="2" ${S}/><path d="M65 44 Q69 41 73 44" fill="none" stroke="${INK}" stroke-width="2" ${S}/><circle cx="52" cy="47" r="2.6" fill="${INK}"/><circle cx="68" cy="47" r="2.6" fill="${INK}"/>`;
}

/* ---------------- 衍月 ---------------- */
/** 束袖劲装 + 朱砂腰带 + 背剑 + 发梢星光 */
export function yanyueSVG(pose: 'stand' | 'run' | 'jump' = 'stand'): string {
  const legSwing = pose === 'run' ? 8 : 0;
  const bob = pose === 'jump' ? -4 : 0;
  const legs =
    pose === 'jump'
      ? `<path d="M52 118 Q46 128 40 130" fill="none" stroke="${P.inkMid}" stroke-width="9" ${S}/><path d="M68 118 Q74 126 78 128" fill="none" stroke="${P.inkMid}" stroke-width="9" ${S}/>`
      : `<path d="M53 116 L${51 - legSwing} 140" fill="none" stroke="${P.inkMid}" stroke-width="9" ${S}/><path d="M67 116 L${69 + legSwing} 140" fill="none" stroke="${P.inkMid}" stroke-width="9" ${S}/>`;

  const armSwing = pose === 'run' ? 6 : 0;
  return wrap(
    shadow(60, 148, 24) +
    // 背剑（斜负，剑柄在左肩上）
    `<path d="M40 52 L84 24" stroke="${P.inkMid}" stroke-width="4" ${S}/><path d="M80 20 L92 16" stroke="${P.gold}" stroke-width="5" ${S}/><circle cx="94" cy="15" r="3" fill="${P.gold}" ${STROKE_THIN}/>` +
    // 马尾（后层）
    ponytail() +
    // 广袖袍（淡墨渐变衣摆）
    `<path d="M46 ${64 + bob} Q42 ${92 + bob} 40 ${112 + bob} L80 ${112 + bob} Q78 ${92 + bob} 74 ${64 + bob} Z" fill="${P.paper2}" ${STROKE}/>` +
    `<path d="M40 ${112 + bob} L80 ${112 + bob} Q79 ${118 + bob} 76 ${120 + bob} L44 ${120 + bob} Q41 ${118 + bob} 40 ${112 + bob} Z" fill="${P.wash}" ${STROKE_THIN}/>` +
    // 朱砂腰带
    `<rect x="46" y="${84 + bob}" width="28" height="6" rx="3" fill="${P.cinnabar}" ${STROKE_THIN}/>` +
    // 束袖手臂
    `<path d="M48 ${70 + bob} Q${40 - armSwing} ${84 + bob} ${38 - armSwing} ${98 + bob}" fill="none" stroke="${P.paper2}" stroke-width="8" ${S}/><path d="M48 ${70 + bob} Q${40 - armSwing} ${84 + bob} ${38 - armSwing} ${98 + bob}" fill="none" stroke="${INK}" stroke-width="2.2" ${S} opacity="0.35"/>` +
    `<path d="M72 ${70 + bob} Q${80 + armSwing} ${84 + bob} ${82 + armSwing} ${98 + bob}" fill="none" stroke="${P.paper2}" stroke-width="8" ${S}/><path d="M72 ${70 + bob} Q${80 + armSwing} ${84 + bob} ${82 + armSwing} ${98 + bob}" fill="none" stroke="${INK}" stroke-width="2.2" ${S} opacity="0.35"/>` +
    legs +
    face() +
    eyes() +
    // 刘海
    `<path d="M42 38 Q46 26 60 26 Q74 26 78 38 Q70 32 60 34 Q50 32 42 38 Z" fill="${P.hair}" ${STROKE_THIN}/>` +
    // 发饰（月白珠）
    `<circle cx="46" cy="30" r="2.5" fill="${P.moon}" ${STROKE_THIN}/>`
  );
}

/* ---------------- 沈砚 ---------------- */
/** 交领长袍（浓墨紫）+ 玉佩 + 竹简 */
export function shenyanSVG(corrupted = false): string {
  // corrupted：被装置侵蚀——袍色更重，身上浮现青色纹路
  const robe = corrupted ? P.robeDark : P.robe;
  const runes = corrupted
    ? `<path d="M50 84 Q60 90 70 84" fill="none" stroke="${P.cyan}" stroke-width="2" ${S} opacity="0.85"/><path d="M46 100 Q60 106 74 100" fill="none" stroke="${P.cyan}" stroke-width="1.6" ${S} opacity="0.6"/><circle cx="60" cy="92" r="2" fill="${P.cyan}"/>`
    : '';
  return wrap(
    shadow(60, 148, 24) +
    topknot() +
    // 交领长袍
    `<path d="M44 66 Q38 100 36 132 L84 132 Q82 100 76 66 Z" fill="${robe}" ${STROKE}/>` +
    // 交领 V 字（月白滚边）
    `<path d="M52 66 L60 84 L68 66" fill="none" stroke="${P.moon}" stroke-width="3" ${S}/>` +
    `<path d="M60 84 L60 100" stroke="${P.moon}" stroke-width="2.4" ${S} opacity="0.7"/>` +
    // 宽袖交叠
    `<path d="M46 72 Q38 88 40 106" fill="none" stroke="${robe}" stroke-width="10" ${S}/><path d="M74 72 Q82 88 80 106" fill="none" stroke="${robe}" stroke-width="10" ${S}/>` +
    // 玉佩（淡青）
    `<rect x="64" y="96" width="7" height="10" rx="3" fill="${P.cyan}" ${STROKE_THIN}/><path d="M67 92 L67 96" stroke="${P.gold}" stroke-width="1.6" ${S}/>` +
    `<path d="M50 132 L50 144 M70 132 L70 144" stroke="${P.inkMid}" stroke-width="8" ${S}/>` +
    face() +
    eyes() +
    // 头发（帽子式覆额）
    `<path d="M40 42 Q42 24 60 24 Q78 24 80 42 Q72 34 60 35 Q48 34 40 42 Z" fill="${P.hair}" ${STROKE_THIN}/>` +
    runes
  );
}

/* ---------------- 强盗 ---------------- */
/** 朱红头巾 + 短打 + 环首刀 */
export function banditSVG(kind: 'blade' | 'torch' | 'boss' = 'blade'): string {
  const weapon =
    kind === 'blade'
      ? `<path d="M84 60 L102 44" stroke="${P.inkMid}" stroke-width="5" ${S}/><circle cx="82" cy="63" r="4" fill="none" stroke="${INK}" stroke-width="2.5" ${S}/>`
      : kind === 'torch'
        ? `<path d="M86 58 L96 40" stroke="#7a5a3a" stroke-width="5" ${S}/><circle cx="98" cy="36" r="6" fill="${P.cinnabar}"/><circle cx="98" cy="36" r="3" fill="${P.gold}"/>`
        : // boss 大刀
          `<path d="M88 64 Q104 56 108 38 Q96 44 88 52 Z" fill="${P.inkMid}" ${STROKE}/><path d="M86 66 L92 58" stroke="${P.gold}" stroke-width="5" ${S}/>`;
  const cape =
    kind === 'boss'
      ? `<path d="M42 62 Q30 96 34 128 L86 128 Q90 96 78 62 Z" fill="${P.robeDark}" ${STROKE}/>`
      : '';
  const headcloth =
    kind === 'boss'
      ? `<path d="M40 36 Q60 16 80 36 L80 44 Q60 30 40 44 Z" fill="${P.cinnabar}" ${STROKE_THIN}/><path d="M78 38 Q90 40 92 52" fill="none" stroke="${P.cinnabar}" stroke-width="4" ${S}/>`
      : `<rect x="42" y="28" width="36" height="9" rx="4" fill="${P.cinnabar}" ${STROKE_THIN}/><path d="M78 32 Q88 36 86 46" fill="none" stroke="${P.cinnabar}" stroke-width="3.5" ${S}/>`;
  return wrap(
    shadow(60, 148, 22) +
    cape +
    // 短打身体
    `<path d="M46 64 Q42 90 44 112 L76 112 Q78 90 74 64 Z" fill="${kind === 'boss' ? P.cinnabar : '#5a5348'}" ${STROKE}/>` +
    // 腰带
    `<rect x="46" y="88" width="28" height="5" rx="2.5" fill="${P.hair}" ${STROKE_THIN}/>` +
    // 手臂（持武器侧抬起）
    `<path d="M48 70 Q40 80 42 94" fill="none" stroke="#5a5348" stroke-width="8" ${S}/><path d="M72 70 Q82 68 86 62" fill="none" stroke="#5a5348" stroke-width="8" ${S}/>` +
    `<path d="M52 112 L50 140 M68 112 L70 140" stroke="${P.inkMid}" stroke-width="8" ${S}/>` +
    weapon +
    face() +
    eyes(true) +
    headcloth
  );
}

/* ---------------- 观测者 ---------------- */
/** 斗笠 + 蓑衣，枯笔飞白 */
export function observerSVG(): string {
  return wrap(
    shadow(60, 148, 24) +
    // 蓑衣（三角，枯笔质感用短线）
    `<path d="M60 56 L92 132 L28 132 Z" fill="#8a8272" ${STROKE}/>` +
    `<path d="M46 92 L58 92 M64 108 L78 108 M42 116 L52 116" stroke="${INK}" stroke-width="1.5" ${S} opacity="0.4"/>` +
    // 斗笠
    `<path d="M26 44 L94 44 L60 20 Z" fill="#c9bfa4" ${STROKE}/>` +
    `<path d="M34 40 Q60 34 86 40" fill="none" stroke="${INK}" stroke-width="1.5" ${S} opacity="0.4"/>` +
    // 下巴阴影里的眼睛
    `<path d="M52 52 L52 58 M68 52 L68 58" stroke="${INK}" stroke-width="2" ${S}/>`,
    '0 0 120 160'
  );
}

/* ---------------- 灯笼 / 星 / 月 ---------------- */

export function lanternSVG(): string {
  return wrap(
    `<rect x="52" y="8" width="16" height="5" rx="2" fill="${P.gold}" ${STROKE_THIN}/>` +
    `<path d="M48 16 Q40 30 44 44 Q50 54 60 54 Q70 54 76 44 Q80 30 72 16 Q60 10 48 16 Z" fill="${P.cinnabar}" ${STROKE}/>` +
    `<path d="M52 20 Q48 32 52 44 M60 16 L60 50 M68 20 Q72 32 68 44" fill="none" stroke="${P.gold}" stroke-width="2" ${S} opacity="0.8"/>` +
    `<rect x="53" y="52" width="14" height="4" rx="2" fill="${P.gold}" ${STROKE_THIN}/>` +
    `<path d="M60 56 L60 64" stroke="${P.cinnabar}" stroke-width="2" ${S}/>`,
    '0 0 120 80'
  );
}

export function starSVG(): string {
  return wrap(
    `<path d="M60 16 L66 52 L102 60 L66 68 L60 104 L54 68 L18 60 L54 52 Z" fill="${P.moon}" stroke="${P.cyanDeep}" stroke-width="2.5" ${S}/><circle cx="60" cy="60" r="7" fill="#fff" opacity="0.9"/>`,
    '0 0 120 120'
  );
}

export function moonSVG(): string {
  return wrap(
    `<circle cx="60" cy="60" r="42" fill="${P.moon}" stroke="${P.cyan}" stroke-width="3"/>` +
    `<circle cx="46" cy="48" r="7" fill="${P.paper2}" opacity="0.7"/><circle cx="70" cy="72" r="5" fill="${P.paper2}" opacity="0.6"/><circle cx="72" cy="42" r="3.5" fill="${P.paper2}" opacity="0.5"/>`,
    '0 0 120 120'
  );
}

/** 月相轮：暗金圆盘 + 八相刻度 */
export function moonWheelSVG(activeIndex = 4): string {
  let ticks = '';
  for (let i = 0; i < 8; i++) {
    const a = (i / 8) * Math.PI * 2 - Math.PI / 2;
    const x1 = 60 + Math.cos(a) * 34;
    const y1 = 60 + Math.sin(a) * 34;
    const x2 = 60 + Math.cos(a) * 44;
    const y2 = 60 + Math.sin(a) * 44;
    const active = i === activeIndex;
    ticks += `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${active ? P.cinnabar : i % 2 ? P.cyanDeep : P.inkMid}" stroke-width="${active ? 5 : 3}" ${S}/>`;
  }
  return wrap(
    `<circle cx="60" cy="60" r="52" fill="#2c2822" stroke="${P.gold}" stroke-width="4"/>` +
    `<circle cx="60" cy="60" r="46" fill="none" stroke="${P.gold}" stroke-width="1.5" opacity="0.5"/>` +
    ticks +
    `<circle cx="60" cy="60" r="12" fill="${P.moon}" stroke="${P.gold}" stroke-width="2.5"/>`,
    '0 0 120 120'
  );
}