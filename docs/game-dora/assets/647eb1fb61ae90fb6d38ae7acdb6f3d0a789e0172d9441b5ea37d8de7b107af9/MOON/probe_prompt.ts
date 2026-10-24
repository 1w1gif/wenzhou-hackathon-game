// 提示框改版视觉探针：用真实 WorldRenderer.setPrompt 展示四种状态
// 0s 键位格式（金色字母+弹入）→ 1.2s 超长文本（限宽换行）→ 2.6s 淡出 → 2.9s 再弹入
import { Director, Node } from "Dora";
import * as Tower from "data/tower";
import { WorldRenderer } from "game/render_world";

const root = Node();
root.addTo(Director.entry);

const renderer = new WorldRenderer(root, Tower);
renderer.setPrompt(0, 60, "按 E 传送");

let t = 0;
const probe = Node();
probe.addTo(Director.entry);
probe.schedule((dt: number) => {
  const prev = t;
  t += dt;
  if (prev <= 1.2 && t > 1.2) {
    renderer.setPrompt(-280, 60, "石头沉睡著，需要祠堂的月相正确才会苏醒，先去调整月轮");
  }
  if (prev <= 2.6 && t > 2.6) {
    renderer.setPrompt(0, 60, undefined);
  }
  if (prev <= 2.9 && t > 2.9) {
    renderer.setPrompt(0, 60, "按 E 对话");
  }
  return t < 3.6;
});
