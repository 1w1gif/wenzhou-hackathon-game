import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "衍月·八相",
  description: "中秋满月之夜，强盗攻塔。她可以回到过去，却无法让被救回来的人记得她。",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}
