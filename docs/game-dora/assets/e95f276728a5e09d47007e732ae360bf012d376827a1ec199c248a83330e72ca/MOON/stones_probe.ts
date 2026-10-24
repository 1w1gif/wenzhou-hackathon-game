// 临时探针（验证后删除）：点灯石/月石/机关石 新贴图加载、显示与尺寸
import { Color, Content, Director, DrawNode, Label, Node, Path, Sprite, Texture2D, Vec2, View } from "Dora";

const resultDir = Path(Content.searchPaths[0], ".agent", "test-results");
if (!Content.exist(resultDir)) {
  Content.mkdir(resultDir);
}
const marker = Path(resultDir, "stones_probe.txt");

const root = Node();
root.addTo(Director.entry);

const bg = DrawNode();
bg.addTo(root);
const vw = View.size.width;
const vh = View.size.height;
bg.drawPolygon(
  [Vec2(-vw / 2, -vh / 2), Vec2(vw / 2, -vh / 2), Vec2(vw / 2, vh / 2), Vec2(-vw / 2, vh / 2)],
  Color(24, 26, 38, 255)
);

const items: { path: string; label: string; x: number }[] = [
  { path: "assets/tiles/lamp_stone.png", label: "lamp_stone", x: -220 },
  { path: "assets/tiles/moon_stone.png", label: "moon_stone", x: 0 },
  { path: "assets/tiles/push_stone.png", label: "push_stone", x: 220 },
];

const lines: string[] = [];
for (const it of items) {
  const tex = Texture2D(it.path);
  if (tex === undefined) {
    lines.push(it.path + " FAIL");
    continue;
  }
  lines.push(it.path + " " + tex.width + "x" + tex.height);
  const sp = Sprite(tex);
  if (sp !== undefined) {
    const s = 110 / tex.height;
    sp.anchor = Vec2(0.5, 0.5);
    sp.scaleX = s;
    sp.scaleY = s;
    sp.position = Vec2(it.x, 40);
    sp.addTo(root);
  }
  const lb = Label("sarasa-mono-sc-regular", 16);
  if (lb !== undefined) {
    lb.text = it.label + " " + tex.width + "x" + tex.height;
    lb.position = Vec2(it.x, -60);
    lb.addTo(root);
  }
}

Content.save(marker, lines.join("\n"));
