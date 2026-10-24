// hero_dims.ts — 量 16 帧 + 立绘的画布尺寸（Texture2D 元数据）
import { Content, Director, Node, Path, Texture2D } from "Dora";

const FRAMES = ["run_0", "run_1", "run_2", "run_3", "jump_0", "jump_1", "fall_0", "cling_0", "dash_0", "dash_1", "atk_0", "atk_1", "atk_2", "atk_3", "atk_4", "hurt_0"];
const HERO_DIR = "assets/characters/hero_v2/";

const node = Node();
node.addTo(Director.entry);
node.schedule(() => {
  const resultDir = Path(Content.searchPaths[0], ".agent", "test-results");
  if (!Content.exist(resultDir)) {
    Content.mkdir(resultDir);
  }
  const lines: string[] = [];
  for (const f of FRAMES) {
    const tex = Texture2D(HERO_DIR + f + ".png");
    if (tex === undefined) {
      lines.push(f + " LOAD-FAIL");
    } else {
      lines.push(f + " " + tex.width + "x" + tex.height);
    }
  }
  const ptex = Texture2D("assets/characters/衍月.png");
  if (ptex === undefined) {
    lines.push("portrait LOAD-FAIL");
  } else {
    lines.push("portrait " + ptex.width + "x" + ptex.height);
  }
  for (const l of lines) {
    print(l);
  }
  Content.save(Path(resultDir, "hero_dims.txt"), "done");
  return true;
});