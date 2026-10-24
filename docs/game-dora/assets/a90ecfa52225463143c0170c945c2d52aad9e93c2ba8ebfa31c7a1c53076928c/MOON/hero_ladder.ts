// hero_ladder.ts — 帧梯子：统一 texel 比例并排显示主角帧 + 网格标尺（供视觉量人物像素高）
// 页码由 .temp/ladder_page.txt 控制：1 = 前 8 帧，2 = 后 8 帧，3 = 立绘放大
import { Color, Content, Director, DrawNode, Label, Node, Sprite, Texture2D, Vec2, View } from "Dora";

interface LadderItem {
  name: string;
  file: string;
}

const PAGE1: LadderItem[] = [
  { name: "run_0", file: "run_0.png" },
  { name: "run_1", file: "run_1.png" },
  { name: "run_2", file: "run_2.png" },
  { name: "run_3", file: "run_3.png" },
  { name: "jump_0", file: "jump_0.png" },
  { name: "jump_1", file: "jump_1.png" },
  { name: "fall_0", file: "fall_0.png" },
  { name: "cling_0", file: "cling_0.png" }
];
const PAGE2: LadderItem[] = [
  { name: "dash_0", file: "dash_0.png" },
  { name: "dash_1", file: "dash_1.png" },
  { name: "atk_0", file: "atk_0.png" },
  { name: "atk_1", file: "atk_1.png" },
  { name: "atk_2", file: "atk_2.png" },
  { name: "atk_3", file: "atk_3.png" },
  { name: "atk_4", file: "atk_4.png" },
  { name: "hurt_0", file: "hurt_0.png" }
];

const HERO_DIR = "assets/characters/hero_v2/";
const SCALE = 0.2; // 统一 texel 比例：屏上高 = 源像素高 × 0.2
const BASE_Y = -330;
const CELL_W = 158;

const root = Node();
root.addTo(Director.entry);

const { width, height } = View.size;

// 背景暗化
const bg = DrawNode();
bg.addTo(root);
bg.drawPolygon(
  [Vec2(-width / 2, -height / 2), Vec2(width / 2, -height / 2), Vec2(width / 2, height / 2), Vec2(-width / 2, height / 2)],
  Color(24, 26, 34, 255)
);

const grid = DrawNode();
grid.addTo(root);
// 水平标尺线：基线向上每 20px，每 100px 亮线
for (let k = 0; k <= 26; k++) {
  const y = BASE_Y + k * 20;
  const major = k % 5 === 0;
  grid.drawSegment(
    Vec2(-width / 2, y),
    Vec2(width / 2, y),
    major ? 1.2 : 0.6,
    major ? Color(150, 168, 200, 200) : Color(70, 78, 96, 140)
  );
}

function addText(x: number, y: number, text: string, size: number, anchorX: number, anchorY: number, r: number, g: number, b: number): void {
  const l = Label("sarasa-mono-sc-regular", size);
  if (l === undefined) {
    return;
  }
  l.text = text;
  l.anchor = Vec2(anchorX, anchorY);
  l.color = Color(r, g, b, 255);
  l.position = Vec2(x, y);
  l.addTo(root);
}

// 左侧标尺数字
for (let k = 0; k <= 26; k = k + 5) {
  addText(-width / 2 + 10, BASE_Y + k * 20 + 2, "" + k * 20, 13, 0, 0.5, 190, 200, 220);
}

// 页码由 .temp/ladder_page.txt 控制
const pageFile = ".temp/ladder_page.txt";
let page = "1";
if (Content.exist(pageFile)) {
  const p = Content.load(pageFile);
  if (p !== undefined) {
    page = p;
  }
}

let items: LadderItem[];
let scale = SCALE;
let topNote = "";
if (page === "3") {
  // 第 3 页：按现行代码比例（96~104/texH，×2 放大）并排 16 帧，直接看当前游戏内的相对高度
  items = PAGE1.concat(PAGE2);
  scale = -1; // 标记：每帧单独用现行代码比例
  topNote = "PAGE 3: CURRENT IN-GAME SCALE x2  (height/texH)";
} else {
  items = page === "2" ? PAGE2 : PAGE1;
  topNote = "PAGE " + page + "  UNIFORM TEXEL SCALE x" + SCALE + "  gridline=20screen=100srcpx";
}

const cellW = page === "3" ? 80 : CELL_W;
const startX = -(items.length * cellW) / 2;
for (let i = 0; i < items.length; i++) {
  const it = items[i];
  const tex = Texture2D(HERO_DIR + it.file);
  if (tex === undefined) {
    addText(startX + cellW * i + cellW / 2, BASE_Y + 60, it.name + " FAIL", 14, 0.5, 0.5, 255, 90, 90);
    continue;
  }
  const sp = Sprite(tex);
  if (sp === undefined) {
    continue;
  }
  const useScale = scale > 0 ? scale : (2 * 96) / tex.height;
  sp.anchor = Vec2(0.5, 0);
  sp.position = Vec2(startX + cellW * i + cellW / 2, BASE_Y);
  sp.scaleX = useScale;
  sp.scaleY = useScale;
  sp.addTo(root);
  // 格分隔线
  grid.drawSegment(
    Vec2(startX + cellW * i, BASE_Y),
    Vec2(startX + cellW * i, BASE_Y + 540),
    0.8,
    Color(90, 96, 116, 150)
  );
  const label = page === "3" ? it.name : it.name + " " + tex.width + "x" + tex.height;
  addText(startX + cellW * i + cellW / 2, BASE_Y - 20, label, 12, 0.5, 1, 220, 228, 240);
}
// 基线最后加亮
grid.drawSegment(Vec2(-width / 2, BASE_Y), Vec2(width / 2, BASE_Y), 2, Color(240, 244, 252, 230));
addText(-width / 2 + 12, height / 2 - 16, topNote, 16, 0, 1, 255, 244, 214);