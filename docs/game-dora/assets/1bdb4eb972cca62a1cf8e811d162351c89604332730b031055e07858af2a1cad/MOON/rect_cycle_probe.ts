// 轻量验收探针：整改一/二/三 UI 切片——因果全屏转场 + 引月札（石子/因果栏）
import { Content, Director, Node, Path } from "Dora";
import { createLoopState } from "game/world";
import { NotebookUI } from "ui/notebook";
import { CausalityFx } from "game/causality_fx";

const resultDir = Path(Content.searchPaths[0], ".agent", "test-results");
if (!Content.exist(resultDir)) {
  Content.mkdir(resultDir);
}

const root = Node();
root.addTo(Director.entry);

const state = createLoopState();
state.maxLife = 8;
state.heroineLife = 8;
state.pebbles = 3;
state.causalityLog.push("渡口移苗·根带旧土", "井水打满·一桶月色", "枯坑种树·因果成立", "拾起石子·三枚", "古镇不杀·剑意上限+1");

const nb = new NotebookUI(root);
nb.toggle();
const fx = new CausalityFx(root);

let t = 0;
let played = false;
root.schedule((dt) => {
  t += dt;
  if (!played && t >= 1.2) {
    played = true;
    fx.play("rewind", "月相逆卷·本层回溯");
  }
  nb.update(dt, state);
  fx.update(dt);
  return false;
});
