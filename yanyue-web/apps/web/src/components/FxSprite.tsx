"use client";

/**
 * FX 序列帧动画：剑光（8 帧 ×200px）、受击（6 帧 ×128px）。
 * 用 <div> 背景位移播放，component 播完自动卸载。
 */
import { useEffect, useState } from "react";
import { asset } from "@/lib/base";

const SLASH = { src: "/assets/fx/slash_sheet.png", frames: 8, fw: 200, fh: 120 };
const HIT = { src: "/assets/fx/hit_sheet.png", frames: 6, fw: 128, fh: 128 };

type Kind = "slash" | "hit";

const CFG = { slash: SLASH, hit: HIT };

export function FxSprite({ kind, x, y, flip, scale = 1, onDone, fps = 22 }: {
  kind: Kind; x: number; y: number; flip?: boolean; scale?: number; onDone?: () => void; fps?: number;
}) {
  const cfg = CFG[kind];
  const [frame, setFrame] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setFrame(f => {
        if (f + 1 >= cfg.frames) { clearInterval(id); onDone?.(); return f; }
        return f + 1;
      });
    }, 1000 / fps);
    return () => clearInterval(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (frame >= cfg.frames) return null;

  return (
    <div style={{
      position: "absolute",
      left: x - (cfg.fw * scale) / 2,
      top: y - (cfg.fh * scale) / 2,
      width: cfg.fw * scale,
      height: cfg.fh * scale,
      transform: flip ? "scaleX(-1)" : undefined,
      backgroundImage: `url(${asset(cfg.src)})`,
      backgroundPosition: `-${frame * cfg.fw * scale}px 0`,
      backgroundSize: `${cfg.fw * cfg.frames * scale}px ${cfg.fh * scale}px`,
      imageRendering: "auto",
      pointerEvents: "none",
      zIndex: 30,
    }} />
  );
}