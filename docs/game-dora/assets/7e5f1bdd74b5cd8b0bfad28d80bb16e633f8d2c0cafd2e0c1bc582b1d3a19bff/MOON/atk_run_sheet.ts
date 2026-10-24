// atk_run_sheet.ts — 新攻击 5 帧按 01~05 顺序目检（游戏内比例：画布高 96.72px=104×0.93，与 FRAME_MUL 一致）
import { Color, Director, Label, Sprite, Texture2D, Vec2 } from "Dora";

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

makeLabel("攻击新 5 帧（按你标的 01→05 顺序，游戏内比例：统一画布高 97px、脚底对齐）", 22, 0, 300);

const names = ["atk_0", "atk_1", "atk_2", "atk_3", "atk_4"];
const tags = ["01", "02", "03", "04", "05"];
const y = 20;
const spacing = 230;
const x0 = (-(names.length - 1) * spacing) / 2;

// 地面基准线
const ground = Label("sarasa-mono-sc-regular", 18);
if (ground !== undefined) {
  ground.text = "------------------------------ 脚底基准线 ------------------------------";
  ground.color = Color(120, 130, 160, 255);
  ground.position = Vec2(0, y - 14);
  ground.addTo(root);
}

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
  const k = 96.72 / tex.height;
  sp.scaleX = k;
  sp.scaleY = k;
  sp.anchor = Vec2(0.5, 0);
  sp.position = Vec2(x0 + i * spacing, y);
  sp.addTo(root);
  makeLabel(tags[i], 22, x0 + i * spacing, y - 44);
  makeLabel(tex.width + "x" + tex.height, 15, x0 + i * spacing, y - 74);
}

makeLabel("attack1/2 = 01→05 全套 17fps   attack3 = 01→05 15fps（单点即完整连招）", 18, 0, -230);
