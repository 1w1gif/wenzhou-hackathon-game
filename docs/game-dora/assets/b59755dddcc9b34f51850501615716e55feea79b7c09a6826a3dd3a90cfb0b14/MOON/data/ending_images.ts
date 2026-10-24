export const ENDING_IMAGES: Record<string, string[]> = {
  // 只列真实存在的档（.agent 下仅有两字简称版）；全名/中名档不存在，
  // 每次结局对不存在路径做 Texture2D 尝试会造成卡顿甚至卡死
  reunion: [".agent/结局-望.png"],
  sacrifice: [".agent/结局-晦.png"],
  blade: [".agent/结局-残.png"],
  exhausted: [".agent/结局-停转.png"],
};
