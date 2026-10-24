// init.ts — 《衍月·八相》运行时入口
import { App, PlatformType, View } from "Dora";
import { Game } from "game/game";

// 屏幕适配（仅手机）：安卓/iOS 上 View.size 是物理像素，不缩放时视野过大
// （整张地图全可见），按宽度比例放大内容收窄视野。
// PC 平台一律不缩放，保持桌面原视野（此前误伤 PC 导致整体画面放大 1.3 倍）。
const MOBILE_BASE_WIDTH = 960;
const isMobile = App.platform === PlatformType.Android || App.platform === PlatformType.iOS;
const vw = View.size.width;
if (isMobile && vw > MOBILE_BASE_WIDTH * 1.15) {
  View.scale = vw / MOBILE_BASE_WIDTH;
}

const game = new Game();
game.start();
