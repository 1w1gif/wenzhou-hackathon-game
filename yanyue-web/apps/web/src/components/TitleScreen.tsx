"use client";

import { useEffect } from "react";
import { useGame } from "@yanyue/game-core";
import { yanyueSVG, shenyanSVG, moonSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";

export default function TitleScreen() {
  const goto = useGame((s) => s.goto);
  const hasSave = useGame((s) => s.nodes.length > 0);

  const enter = () => goto("prologue");

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Enter" || e.key === " ") enter();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="screen title-screen">
      <div className="title-moon"><Sprite svg={moonSVG()} /></div>
      <svg className="title-hills" viewBox="0 0 100 40" preserveAspectRatio="none">
        <path d="M0 40 L0 26 Q18 12 34 24 Q50 34 66 20 Q82 8 100 22 L100 40 Z" fill="#1c2330" />
        <path d="M0 40 L0 32 Q22 22 42 30 Q62 38 84 28 Q92 24 100 30 L100 40 Z" fill="#232c3c" />
      </svg>
      <div className="title-card">
        <h1 className="title-name">衍月·八相</h1>
        <div className="title-sub">满 月 之 夜 的 时 间 回 溯</div>
        <div className="title-actors">
          <Sprite svg={yanyueSVG("stand")} />
          <Sprite svg={shenyanSVG()} />
        </div>
        <div className="title-tip">那一夜，满月如盘，他死在我面前。</div>
        <div className="title-btns">
          <button className="btn btn-gold" onClick={enter}>开始游戏</button>
          {hasSave && (
            <button className="btn" onClick={() => useGame.setState({ phase: "world", showTree: false, showJournal: false })}>
              继续时空树
            </button>
          )}
        </div>
        <div className="title-tip" style={{ marginTop: 14, opacity: 0.7 }}>Enter / 空格 开始</div>
      </div>
    </div>
  );
}