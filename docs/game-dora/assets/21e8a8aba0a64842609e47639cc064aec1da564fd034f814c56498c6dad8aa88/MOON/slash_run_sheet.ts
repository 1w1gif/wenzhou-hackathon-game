// slash_run_sheet.ts — 剑气雪碧图逐帧 + 跑步 4 帧(01~04) 目检对比图
// 供用户确认：①剑气贴图切片效果 ②跑步 4 帧哪两帧姿势重复
import { Color, Director, Label, Rect, Sprite, Texture2D, Vec2 } from "Dora";

const root = Director.entry;

function makeLabel(text: string, size: number, x: number, y: number): void {
  const lb = Label("sarasa-mono-sc-regular", size);
  if (lb === undefined) {
    return;
  }
  lb.text = text;
  lb.color = Color(235, 235, 245, 255);
  lb.position = Vec2(x, y);
  lb.addTo(root);
}

function drawSheetRow(path: string, tag: string, y: number, captionY: number): void {
  const tex = Texture2D(path);
  if (tex === undefined) {
    makeLabel(tag + " 贴图加载失败", 20, 0, y);
    return;
  }
  const count = Math.max(1, Math.floor(tex.width / 64));
  const scale = 1.6;
  let spacing = 64 * scale + 16;
  const maxW = 1150;
  if (count * spacing > maxW) {
    spacing = maxW / count;
  }
  const x0 = (-(count - 1) * spacing) / 2;
  for (let i = 0; i < count; i++) {
    const sp = Sprite(tex, Rect(i * 64, 0, 64, 64));
    if (sp === undefined) {
      continue;
    }
    sp.position = Vec2(x0 + i * spacing, y);
    sp.scaleX = scale;
    sp.scaleY = scale;
    sp.addTo(root);
    makeLabel("" + (i + 1), 16, x0 + i * spacing, y - 64 * scale - 16);
  }
  makeLabel(tag + "  " + tex.width + "x" + tex.height + "  共" + count + "帧", 18, 0, captionY);
}

function drawRunRow(): void {
  const names = ["run_0", "run_1", "run_2", "run_3"];
  const tags = ["01", "02", "03", "04"];
  const y = -225;
  const spacing = 175;
  const x0 = (-(names.length - 1) * spacing) / 2;
  for (let i = 0; i < names.length; i++) {
    const tex = Texture2D("assets/characters/hero_v2/" + names[i] + ".png");
    if (tex === undefined) {
      makeLabel(tags[i] + " 加载失败", 20, x0 + i * spacing, y);
      continue;
    }
    const sp = Sprite(tex);
    if (sp === undefined) {
      continue;
    }
    const k = 150 / tex.height;
    sp.scaleX = k;
    sp.scaleY = k;
    sp.position = Vec2(x0 + i * spacing, y);
    sp.addTo(root);
    makeLabel(tags[i] + "  " + tex.width + "x" + tex.height, 17, x0 + i * spacing, y - 115);
  }
}

makeLabel("剑气雪碧图逐帧(上两行·游戏内顺序从左到右) + 跑步帧(下行 01→02→03→04)", 22, 0, 330);
drawSheetRow("assets/effects/slash_white.png", "白·普攻挥剑", 185, 258);
drawSheetRow("assets/effects/slash_blue.png", "蓝·剑气弹", 15, 88);
makeLabel("跑步 4 帧（统一高 150px）——若有两帧姿势几乎一样，请告诉我编号", 18, 0, -112);
drawRunRow();
