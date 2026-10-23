"use client";

import { useEffect } from "react";
import { useGame } from "@yanyue/game-core";
import { yanyueSVG, shenyanSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";
import { NightSky } from "./NightSky";

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
      <NightSky phase={4} floor={5} dim />
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
        <div className="title-tip" style={{ marginTop: 14, opacity: 0.7 }}><span className="lbl-full">Enter / 空格 开始</span><span className="lbl-short">轻触「开始游戏」</span></div>
      </div>
    </div>
  );
}