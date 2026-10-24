export const ENDING_IMAGES: Record<string, string[]> = {
  // 只列真实存在的档（.agent 下仅有两字简称版）；全名/中名档不存在，
  // 每次结局对不存在路径做 Texture2D 尝试会造成卡顿甚至卡死
  reunion: ["assets/art/ending_reunion.png"],
  sacrifice: ["assets/art/ending_sacrifice.png"],
  blade: ["assets/art/ending_blade.png"],
  exhausted: ["assets/art/ending_exhausted.png"],
};
