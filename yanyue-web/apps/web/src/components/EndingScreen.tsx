"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useGame, ENDINGS } from "@yanyue/game-core";
import { moonSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";

export default function EndingScreen() {
  const endingSeen = useGame((s) => s.endingSeen);
  const goto = useGame((s) => s.goto);
  const toggleTree = useGame((s) => s.toggleTree);
  const [shown, setShown] = useState(2);

  const ending = ENDINGS[endingSeen ?? "duel"];

  useEffect(() => {
    const t = setInterval(() => setShown((n) => Math.min(n + 1, ending.lines.length)), 900);
    return () => clearInterval(t);
  }, [ending]);

  const done = shown >= ending.lines.length;

  return (
    <div className="screen ending-screen">
      <div className="ending-moon float"><Sprite svg={moonSVG()} /></div>
      <h1 className="ending-title fade-in">{ending.title}</h1>
      <div className="ending-lines">
        {ending.lines.slice(0, shown).map((l, i) => (
          <p key={i} className="fade-in" style={{ opacity: l.startsWith("「") ? 0.9 : 1, fontStyle: l.startsWith("「") ? "italic" : "normal" }}>{l}</p>
        ))}
      </div>
      {done && (
        <div className="title-btns fade-in" style={{ position: "absolute", bottom: 48 }}>
          <button className="btn btn-gold" onClick={() => { goto("world"); toggleTree(true); }}>
            观看时空树
          </button>
        </div>
      )}
    </div>
  );
}