/**
 * 部署在 GitHub Pages 子路径下（/wenzhou-hackathon-game/game/）时，
 * 静态资源必须带上前缀；本地开发与根路径部署时前缀为空。
 */
export const BASE = process.env.NEXT_PUBLIC_BASE_PATH ?? "";

/** 把 /assets/... 之类的绝对路径转成带部署前缀的路径 */
export const asset = (path: string) => `${BASE}${path}`;