"use client";

/**
 * 水墨夜空（全屏背景）：程序化生成，与角色 SVG 同画风。
 * 层次：天穹渐变 → 月晕 → 星子 → 远山两层（视差漂移）→ 流雾 → 高层塔影。
 * phase 决定月色（残月血色、望金辉），floor 决定是否画观星塔剪影。
 */
import { useMemo } from "react";

function mulberry32(seed: number) {
  let a = seed >>> 0;
  return () => {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** 八相月色：0 新月(暗) → 4 望(金满) → 7 残月(血) */
const MOON_COLORS = [
  { core: "#3a4152", halo: "rgba(120,140,170,0.20)" },
  { core: "#e8e4d8", halo: "rgba(220,225,235,0.28)" },
  { core: "#ece8da", halo: "rgba(225,230,235,0.30)" },
  { core: "#f2ecd4", halo: "rgba(240,230,190,0.32)" },
  { core: "#f7f0d2", halo: "rgba(248,235,180,0.38)" },
  { core: "#efe8d0", halo: "rgba(235,225,185,0.30)" },
  { core: "#e2ddca", halo: "rgba(200,200,190,0.26)" },
  { core: "#c96a5a", halo: "rgba(210,90,70,0.30)" },
];

/** 生成一条山脊 SVG path：seed 控制形状，h 控制高度比例 */
function ridge(seed: number, w: number, h: number, baseY: number, peaks: number): string {
  const rng = mulberry32(seed);
  const pts: string[] = [`M 0 ${baseY}`];
  const step = w / peaks;
  for (let i = 0; i <= peaks; i++) {
    const px = i * step + (rng() - 0.5) * step * 0.55;
    const py = baseY - (0.35 + rng() * 0.65) * h;
    const cx = px - step / 2;
    pts.push(`Q ${cx.toFixed(0)} ${py.toFixed(0)} ${px.toFixed(0)} ${(baseY - rng() * h * 0.18).toFixed(0)}`);
  }
  pts.push(`L ${w} ${baseY + 4} L 0 ${baseY + 4} Z`);
  return pts.join(" ");
}

export function NightSky({ phase = 4, floor = 0, dim = false }: { phase?: number; floor?: number; dim?: boolean }) {
  const moon = MOON_COLORS[phase] ?? MOON_PHASE_DEFAULT(phase);

  const stars = useMemo(() => {
    const rng = mulberry32(20261020 + floor * 97);
    return Array.from({ length: 46 }, (_, i) => ({
      x: rng() * 100,
      y: rng() * 55,
      r: 0.6 + rng() * 1.4,
      dur: 2.4 + rng() * 4,
      delay: rng() * 5,
      key: i,
    }));
  }, [floor]);

  const far = useMemo(() => ridge(floor * 13 + 7, 1600, 150, 620, 9), [floor]);
  const near = useMemo(() => ridge(floor * 29 + 101, 1600, 220, 700, 7), [floor]);
  const far2 = useMemo(() => ridge(floor * 53 + 31, 1600, 100, 560, 12), [floor]);

  return (
    <div style={{ position: "absolute", inset: 0, overflow: "hidden", zIndex: 0, background: "linear-gradient(180deg, #0a0d18 0%, #121828 46%, #1b2436 78%, #232c40 100%)" }}>
      {/* 月晕天光（跟随月色） */}
      <div style={{
        position: "absolute", right: "16%", top: "9%", width: "34vw", height: "34vw",
        background: `radial-gradient(circle, ${moon.halo} 0%, rgba(20,26,40,0) 62%)`,
      }} />
      {/* 月 */}
      <div className="nk-float" style={{ position: "absolute", right: "20%", top: "12%" }}>
        <svg width="120" height="120" viewBox="0 0 120 120">
          <circle cx="60" cy="60" r="34" fill={moon.core} />
          <circle cx="60" cy="60" r="34" fill="none" stroke="rgba(255,255,255,0.25)" strokeWidth="1" />
          <circle cx="47" cy="50" r="6" fill="rgba(0,0,0,0.07)" />
          <circle cx="70" cy="70" r="4.5" fill="rgba(0,0,0,0.06)" />
          <circle cx="72" cy="46" r="3" fill="rgba(0,0,0,0.05)" />
        </svg>
      </div>
      {/* 星子 */}
      {stars.map(s => (
        <div key={s.key} className="nk-star" style={{
          left: `${s.x}%`, top: `${s.y}%`, width: s.r * 2, height: s.r * 2,
          animationDuration: `${s.dur}s`, animationDelay: `${s.delay}s`,
        }} />
      ))}
      {/* 远山三层（水墨浓淡） */}
      <svg viewBox="0 0 1600 720" preserveAspectRatio="xMidYMax slice" style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }}>
        <path d={far2} fill="#1c2536" opacity="0.55" />
        <path d={far} fill="#161e2e" opacity="0.8" />
        {/* 高层画观星塔剪影（立于远山之巅） */}
        {floor >= 3 && (
          <g transform="translate(1080 300)" opacity="0.85">
            {[0, 1, 2, 3, 4].map(i => (
              <g key={i} transform={`translate(0 ${i * -34})`}>
                <rect x={-26 + i * 4} y={-26} width={52 - i * 8} height={30} fill="#0d1220" />
                <path d={`M ${-32 + i * 4} -26 L 0 -44 L ${32 - i * 4} -26 Z`} fill="#0d1220" />
              </g>
            ))}
            <rect x="-3" y="-160" width="6" height="30" fill="#0d1220" />
            <circle cx="0" cy="-166" r="5" fill="#c9a05c" opacity="0.9" />
          </g>
        )}
        <path d={near} fill="#101625" opacity="0.95" />
      </svg>
      {/* 流雾两道 */}
      <div className="nk-mist" style={{ bottom: "16%", animationDuration: "26s" }} />
      <div className="nk-mist" style={{ bottom: "34%", animationDuration: "38s", animationDelay: "-14s", opacity: 0.5 }} />
      {/* 压暗层 */}
      {dim && <div style={{ position: "absolute", inset: 0, background: "rgba(8,10,18,0.35)" }} />}
    </div>
  );
}

function MOON_PHASE_DEFAULT(i: number) { return MOON_COLORS[i % 8]; }