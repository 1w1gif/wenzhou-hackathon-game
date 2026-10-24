// test_ninja.ts — 需求⑤「忍者一动不动」实机验证入口（临时，验收后删除）
// 场景：0 层 e02（bandit→peasant）真实 AI + 真实雪碧图渲染，玩家假立于出生点 x=800。
// 判定：敌人 x 随时间变化 = AI 正常；两帧截图姿态不同 = 帧动画正常。
import { Color, Content, Director, DrawNode, Node, Path, Vec2 } from "Dora";
import { EnemySystem, EnemyCtx } from "game/enemies";
import { EffectSystem } from "game/effects";
import { NinjaLayer } from "game/ninja_render";
import * as Tower from "data/tower";

const root = Node();
root.addTo(Director.entry);

const bg = DrawNode();
bg.addTo(root);
// 背板 + 地面示意线（屏幕中心原点，y 向上）
bg.drawPolygon([Vec2(-640, -360), Vec2(640, -360), Vec2(640, 360), Vec2(-640, 360)], Color(24, 28, 40, 255));
bg.drawPolygon([Vec2(-640, -80), Vec2(640, -80), Vec2(640, -92), Vec2(-640, -92)], Color(96, 84, 120, 255));

const fx = new EffectSystem();
const ninjaLayer = new NinjaLayer(root);

let poofCount = 0;
const enemies = new EnemySystem(fx, {
  onPlayerHit: (_dmg: number, _fromX: number) => {},
  onDeath: () => {},
  onPoof: (_x: number, _y: number) => {
    poofCount = poofCount + 1;
  },
});
const e02 = Tower.enemies[2];
enemies.spawnAll([e02], 0);

const ctx: EnemyCtx = { platforms: Tower.platforms };
const prect = { x: 784, y: 220, w: 32, h: 82 };

let t = 0;
let drawOkCount = 0;
const xs: number[] = [];
const states: string[] = [];

root.schedule((dt) => {
  enemies.update(dt, 800, 261, prect, false, ctx);
  ninjaLayer.beginFrame(dt);
  for (let i = 0; i < enemies.enemies.length; i++) {
    if (ninjaLayer.drawEnemy(enemies.enemies[i])) {
      drawOkCount = drawOkCount + 1;
    }
  }
  ninjaLayer.endFrame();
  t = t + dt;
  const step = Math.floor(t / 0.5);
  if (xs.length < step && enemies.enemies.length > 0) {
    const e = enemies.enemies[0];
    xs.push(Math.floor(e.body.x));
    states.push(e.state);
  }
  if (t >= 1.5) {
    const e = enemies.enemies[0];
    const moved = xs.length >= 2 && xs[xs.length - 1] !== xs[0];
    const drewEveryFrame = drawOkCount >= Math.floor(t * 60) * 0.9;
    const verdict = moved && ninjaLayer.ok && drewEveryFrame
      ? "passed: enemy moves + sprite renders every frame"
      : "failed: moved=" + moved + " ninjaOk=" + ninjaLayer.ok + " drewEveryFrame=" + drewEveryFrame;
    const report = verdict + " | x=" + xs.join(",") + " | state=" + states.join(">") + " | drawOk=" + drawOkCount + " | finalState=" + e.state;
    Content.save(Path(Content.searchPaths[0], ".agent", "test-results", "ninja_case.txt"), report);
    return true;
  }
  return false;
});
