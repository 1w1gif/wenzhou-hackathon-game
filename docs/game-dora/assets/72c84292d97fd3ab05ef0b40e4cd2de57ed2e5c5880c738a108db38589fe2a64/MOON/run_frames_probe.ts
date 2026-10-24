import { Content, Director, Node, Path, Texture2D } from "Dora";

// run_frames_probe.ts — 验证新跑步 5 帧已入 assets 且可加载，输出各帧画布尺寸（marker: .agent/test-results/run_frames_probe.txt）
const resultDir = Path(Content.searchPaths[0], ".agent", "test-results");
if (!Content.exist(resultDir)) Content.mkdir(resultDir);
const marker = Path(resultDir, "run_frames_probe.txt");
if (Content.exist(marker)) Content.remove(marker);

const node = Node();
node.addTo(Director.entry);
node.schedule(() => {
  const parts: string[] = [];
  let ok = true;
  for (let i = 0; i < 5; i++) {
    const tex = Texture2D("assets/characters/hero_v2/run_" + i + ".png");
    if (tex === undefined) {
      parts.push("run_" + i + "=FAIL");
      ok = false;
    } else {
      parts.push("run_" + i + "=" + tex.width + "x" + tex.height);
    }
  }
  Content.save(marker, (ok ? "passed|" : "failed|") + parts.join("|"));
  return true;
});
