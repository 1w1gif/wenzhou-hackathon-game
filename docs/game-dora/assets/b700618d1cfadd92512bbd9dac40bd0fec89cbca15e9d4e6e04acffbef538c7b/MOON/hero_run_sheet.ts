// hero_run_sheet.ts — 跑步 4 帧专项对比：上排=统一 texel 比例（数帧数/查重复），下排=当前游戏内比例x2（看高度差）
import { Color, Director, DrawNode, Label, Node, Sprite, Texture2D, Vec2, View } from "Dora";

const HERO_DIR = "assets/characters/hero_v2/";
const ITEMS = [
  { name: "run_0", src: "跑步1", file: "run_0.png" },
  { name: "run_1", src: "跑步2", file: "run_1.png" },
  { name: "run_2", src: "跑步3", file: "run_2.png" },
  { name: "run_3", src: "跑步4", file: "run_3.png" }
];

const UNI_SCALE = 0.16; // 上排统一比例：屏上高 = 源像素高 x 0.16
const ROW_A_Y = -40; // 上排脚底基线（屏幕坐标，y 向上）
const ROW_B_Y = -330; // 下排脚底基线（游戏内比例 x2，画布高统一 96x2=192）
const MIN_CELL = 180;

const root = Node();
root.addTo(Director.entry);

const { width, height } = View.size;

const bg = DrawNode();
bg.addTo(root);
bg.drawPolygon(
  [Vec2(-width / 2, -height / 2), Vec2(width / 2, -height / 2), Vec2(width / 2, height / 2), Vec2(-width / 2, height / 2)],
  Color(24, 26, 34, 255)
);

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

// 先装载并计算列宽（列宽由上排统一比例的帧宽决定）
interface Cell {
  tex: Texture2D.Type;
  x: number;
  adv: number;
}
const cells: Cell[] = [];
let total = 0;
for (const it of ITEMS) {
  const tex = Texture2D(HERO_DIR + it.file);
  if (tex === undefined) {
    cells.push({ tex: undefined as unknown as Texture2D.Type, x: 0, adv: MIN_CELL });
    total = total + MIN_CELL;
    continue;
  }
  const uniW = tex.width * UNI_SCALE;
  const adv = Math.max(MIN_CELL, uniW + 28);
  cells.push({ tex: tex, x: 0, adv: adv });
  total = total + adv;
}
const startX = -total / 2;
let cx = startX;
for (const c of cells) {
  c.x = cx + c.adv / 2;
  cx = cx + c.adv;
}

// 两条基线
const grid = DrawNode();
grid.addTo(root);
grid.drawSegment(Vec2(-width / 2, ROW_A_Y), Vec2(width / 2, ROW_A_Y), 2, Color(240, 244, 252, 230));
grid.drawSegment(Vec2(-width / 2, ROW_B_Y), Vec2(width / 2, ROW_B_Y), 2, Color(240, 244, 252, 230));

// 列分隔虚线（上下排之间用浅色竖线）
for (const c of cells) {
  grid.drawSegment(Vec2(c.x, ROW_B_Y + 4), Vec2(c.x, ROW_A_Y - 4), 0.8, Color(90, 96, 116, 90));
}

let loaded = 0;
for (let i = 0; i < ITEMS.length; i++) {
  const it = ITEMS[i];
  const c = cells[i];
  if (c.tex === undefined) {
    addText(c.x, ROW_A_Y + 30, it.name + " FAIL", 14, 0.5, 0.5, 255, 90, 90);
    continue;
  }
  loaded = loaded + 1;
  // 上排：统一 texel 比例
  const spA = Sprite(c.tex);
  if (spA !== undefined) {
    spA.anchor = Vec2(0.5, 0);
    spA.position = Vec2(c.x, ROW_A_Y);
    spA.scaleX = UNI_SCALE;
    spA.scaleY = UNI_SCALE;
    spA.addTo(root);
  }
  addText(c.x, ROW_A_Y - 14, it.name + " = " + it.src + "  " + c.tex.width + "x" + c.tex.height, 13, 0.5, 1, 220, 228, 240);
  // 下排：当前游戏内比例 x2（96/texH x2）
  const spB = Sprite(c.tex);
  if (spB !== undefined) {
    spB.anchor = Vec2(0.5, 0);
    spB.position = Vec2(c.x, ROW_B_Y);
    const s = (2 * 96) / c.tex.height;
    spB.scaleX = s;
    spB.scaleY = s;
    spB.addTo(root);
  }
  addText(c.x, ROW_B_Y - 14, it.name + "  (game x2)", 13, 0.5, 1, 170, 200, 230);
}

addText(-width / 2 + 12, height / 2 - 16, "RUN FRAMES loaded " + loaded + "/4  |  TOP: uniform texel x" + UNI_SCALE + "  BOTTOM: current in-game scale x2", 15, 0, 1, 255, 244, 214);
addText(width / 2 - 12, height / 2 - 40, "4 poses expected", 13, 1, 1, 160, 220, 170);
