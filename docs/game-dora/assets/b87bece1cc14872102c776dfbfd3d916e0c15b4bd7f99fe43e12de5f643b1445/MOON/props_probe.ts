// 临时探针（验证后删除）：assets/props 17 张装饰贴图运行时可加载性与实际尺寸
import { Content, Director, Node, Path, Texture2D } from "Dora";

const names = [
  "a1_pit.png",
  "a2_sapling.png",
  "a3_tree.png",
  "a4_stump.png",
  "a5_well.png",
  "a6_bucket.png",
  "b1_bush.png",
  "b5_counter.png",
  "b6_barrel.png",
  "b7_table.png",
  "e2_dice.png",
  "e3_lingzhi.png",
  "e4_ginseng.png",
  "e5_herb.png",
  "e6_offering.png",
  "e7_shard.png",
  "withered_reed.png",
];

const resultDir = Path(Content.searchPaths[0], ".agent", "test-results");
if (!Content.exist(resultDir)) {
  Content.mkdir(resultDir);
}
const marker = Path(resultDir, "props_probe.txt");

const node = Node();
node.addTo(Director.entry);
node.schedule(() => {
  const lines: string[] = [];
  for (const n of names) {
    const tex = Texture2D("assets/props/" + n);
    if (tex === undefined) {
      lines.push(n + " FAIL");
    } else {
      lines.push(n + " " + tex.width + "x" + tex.height);
    }
  }
  Content.save(marker, lines.join("\n"));
  return true;
});
