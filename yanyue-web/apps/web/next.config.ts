import type { NextConfig } from "next";

/**
 * 静态导出，部署到 GitHub Pages 的 /<repo>/game/ 子路径。
 * 开发模式不加前缀（本地 npm run dev 直接访问根路径）。
 */
const PAGES_BASE_PATH = "/wenzhou-hackathon-game/game";
const basePath =
  process.env.NEXT_PUBLIC_BASE_PATH ??
  (process.env.NODE_ENV === "production" ? PAGES_BASE_PATH : "");

const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  basePath: basePath || undefined,
  assetPrefix: basePath || undefined,
  images: { unoptimized: true },
  // 让客户端代码能读到同一份前缀（asset() 用）
  env: { NEXT_PUBLIC_BASE_PATH: basePath },
  transpilePackages: ["@yanyue/art-engine", "@yanyue/game-core"],
};

export default nextConfig;