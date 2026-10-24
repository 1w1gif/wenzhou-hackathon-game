// test_chase.ts — 需求「跳上高台怪物丢失目标 + 正下方不左右抖动」行为验证入口（临时，验收后删除）
// 场景：0 层自定义 bandit 出生 x=990（其上方是 one-way 平台 p00: 900-1080，顶 y=398）。
// 玩家依次：A 地面贴近 → B 站上高台 → C 回地面 → D 高台上空跳跃上升 → E 落定高台。
// 判定：A 追击触发 / B 丢失目标回巡逻且持续走开 / C 落地重追 /
//       D 跳跃途中(|vy|大)不脱战 / E 高台落地(|vy|小)立即脱战。
import { Content, Director, Node, Path } from "Dora";
import { EnemySystem, EnemyCtx } from "game/enemies";
import { EffectSystem } from "game/effects";
import * as Tower from "data/tower";

const root = Node();
root.addTo(Director.entry);

const fx = new EffectSystem();
const enemies = new EnemySystem(fx, {
  onPlayerHit: (_dmg: number, _fromX: number) => {},
  onDeath: () => {},
  onPoof: (_x: number, _y: number) => {},
});
const def = {
  id: "tx",
  kind: "bandit" as const,
  x: 990,
  y: 220,
  patrolMin: 880,
  patrolMax: 1150,
  floor: 0,
};
enemies.spawnAll([def], 0);

const ctx: EnemyCtx = { platforms: Tower.platforms };

// p00 平台矩形 y=380 h=18，y 轴向上 → 平台顶 = 398；地面顶 = TOPS[0] = 220
const GROUND_FEET = 220;
const PLAT_FEET = 398;

interface Phase {
  until: number;
  px: number;
  feet: number;
  vy: number;
  label: string;
  check: (state: string, x0: number, x1: number) => boolean;
}

const phases: Phase[] = [
  { until: 0.5, px: 1130, feet: GROUND_FEET, vy: 0, label: "A地面贴近触发追击",
    check: (s) => s === "chase" || s === "windup" },
  { until: 1.5, px: 990, feet: PLAT_FEET, vy: 0, label: "B站上高台丢失目标",
    check: (s, x0, x1) => s === "patrol" && Math.abs(x1 - x0) > 30 },
  { until: 2.0, px: 1130, feet: GROUND_FEET, vy: 0, label: "C回到地面重新索敌",
    check: (s) => s === "chase" || s === "windup" },
  { until: 2.4, px: 990, feet: PLAT_FEET, vy: 300, label: "D跳跃途中不脱战",
    check: (s) => s !== "patrol" },
  { until: 3.0, px: 990, feet: PLAT_FEET, vy: 0, label: "E高台落地立即脱战",
    check: (s) => s === "patrol" },
];

let t = 0;
let phaseIdx = 0;
let phaseStartX = enemies.enemies.length > 0 ? enemies.enemies[0].body.x : 0;
const failures: string[] = [];

root.schedule((dt) => {
  const ph = phases[phaseIdx];
  const e = enemies.enemies[0];
  enemies.update(
    dt,
    ph.px,
    ph.feet + 41,
    { x: ph.px - 16, y: ph.feet, w: 32, h: 82 },
    false,
    ctx,
    ph.vy
  );
  t = t + dt;
  if (t >= ph.until) {
    const ok = ph.check(e.state, phaseStartX, e.body.x);
    if (!ok) {
      failures.push(ph.label + " [state=" + e.state + " dx=" + Math.floor(e.body.x - phaseStartX) + "]");
    }
    phaseIdx = phaseIdx + 1;
    if (phaseIdx >= phases.length) {
      const report = failures.length === 0
        ? "passed | A追击/B高台丢失走开/C落地重追/D跳跃不脱战/E落地脱战 全部通过 | x=" + Math.floor(e.body.x)
        : "failed | " + failures.join(" ; ");
      Content.save(Path(Content.searchPaths[0], ".agent", "test-results", "chase_case.txt"), report);
      return true;
    }
    phaseStartX = enemies.enemies[0].body.x;
  }
  return false;
});
