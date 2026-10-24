// ui/tech_ui.ts — 科技风 UI 通用素材层（sci-fi-hud-ui-kit.zip，48 张全透明 PNG）
// 面板=半透明暗底 + 细青描边 + 角框贴图；按钮由各界面用 TECH_BTN_PATH 建 Sprite 按需缩放。
// 换皮旋钮：改这里两个路径常量即可整体更换框/按钮素材（源在 .temp/scifi-out）。
import { Color, DrawNode, Node, Sprite, Texture2D, Vec2 } from "Dora";

export const TECH_FRAME_PATH = "assets/ui/tech/frame_brackets.png";
export const TECH_BTN_PATH = "assets/ui/tech/button.png";

/** 科技青点缀色（回退描边/高亮可用） */
export function techAccent(): Color.Type {
  return Color(96, 200, 255, 255);
}

/**
 * 建一块科技风面板（局部坐标 (0,0)=面板中心）：
 * 半透明暗底（不挡背景）+ 细青描边 + 四角角框贴图；角框缺失时保留纯描边框。
 * 先于内容创建调用，后续 addTo 的标签/列表自然盖在面板之上。
 */
export function makeTechPanel(parent: Node.Type, w: number, h: number): Node.Type {
  const holder = Node();
  holder.addTo(parent);
  const full = [Vec2(-w / 2, -h / 2), Vec2(w / 2, -h / 2), Vec2(w / 2, h / 2), Vec2(-w / 2, h / 2)];
  const fill = DrawNode();
  fill.addTo(holder);
  fill.drawPolygon(full, Color(7, 11, 20, 150));
  fill.drawPolygon(full, Color(0, 0, 0, 0), 1.5, Color(96, 200, 255, 130));
  const tex = Texture2D(TECH_FRAME_PATH);
  if (tex !== undefined) {
    const frame = Sprite(tex);
    if (frame !== undefined) {
      frame.anchor = Vec2(0.5, 0.5);
      frame.position = Vec2(0, 0);
      frame.scaleX = w / tex.width;
      frame.scaleY = h / tex.height;
      frame.addTo(holder);
    }
  }
  return holder;
}
