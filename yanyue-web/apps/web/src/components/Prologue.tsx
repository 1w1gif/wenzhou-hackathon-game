"use client";

import { useEffect, useMemo, useState } from "react";
import { useGame } from "@yanyue/game-core";
import { moonSVG, yanyueSVG, shenyanSVG, lanternSVG, banditSVG, moonWheelSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";

const CAPTIONS = [
  "那一夜，满月如盘，他死在我面前。",
  "我这一剑，斩得断强盗，斩不断天意。",
  "月亮把时间还给了我。代价是，我的生命。",
  "而他忘记了我。",
  "这一次，换我用剑，护你周全。",
];

type Shot = "moon" | "couple" | "raid" | "death" | "wheel" | "stranger";

const SHOTS: Shot[] = ["moon", "couple", "raid", "death", "wheel", "stranger"];

export default function Prologue() {
  const goto = useGame((s) => s.goto);
  const seedOrigin = useGame((s) => s.seedOrigin);
  const [step, setStep] = useState(0);
  const [shake, setShake] = useState(false);
  const [flash, setFlash] = useState(false);

  const advance = useMemo(() => () => {
    setStep((s) => {
      if (s >= SHOTS.length - 1) {
        seedOrigin();
        goto("world");
        return s;
      }
      if (SHOTS[s + 1] === "raid") setShake(true);
      if (SHOTS[s + 1] === "wheel") { setFlash(true); setTimeout(() => setFlash(false), 520); }
      return s + 1;
    });
  }, [goto, seedOrigin]);

  useEffect(() => {
    const t = setTimeout(advance, 3600);
    return () => clearTimeout(t);
  }, [step, advance]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => { if (e.key === "Enter" || e.key === " ") advance(); };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [advance]);

  const shot = SHOTS[step];

  return (
    <div className={`screen prologue-screen ${shake ? "shake" : ""} ${flash ? "flash-white" : ""}`}>
      <div className="prologue-shot fade-in" key={step}>
        {shot === "moon" && (
          <div style={{ position: "absolute", right: "14%", top: "-6%", width: 170, height: 170 }} className="float">
            <Sprite svg={moonSVG()} />
          </div>
        )}
        {shot === "couple" && (
          <div style={{ position: "absolute", inset: 0, display: "flex", justifyContent: "center", alignItems: "flex-end", gap: 10 }}>
            <div style={{ width: 160, height: 210 }}><Sprite svg={yanyueSVG("stand")} /></div>
            <div style={{ width: 160, height: 210 }}><Sprite svg={shenyanSVG()} /></div>
          </div>
        )}
        {shot === "raid" && (
          <div style={{ position: "absolute", inset: 0 }}>
            {[12, 30, 52, 74, 88].map((x, i) => (
              <div key={i} className="bob" style={{ position: "absolute", left: `${x}%`, bottom: 10, width: 74, height: 50 }}>
                <Sprite svg={lanternSVG()} />
              </div>
            ))}
            <div style={{ position: "absolute", left: "40%", bottom: 60, width: 120, height: 160 }}><Sprite svg={banditSVG("torch")} /></div>
            <div style={{ position: "absolute", left: "58%", bottom: 55, width: 120, height: 160 }}><Sprite svg={banditSVG("blade")} /></div>
          </div>
        )}
        {shot === "death" && (
          <div style={{ position: "absolute", inset: 0, display: "flex", justifyContent: "center", alignItems: "flex-end", gap: 6 }}>
            <div style={{ width: 170, height: 220, filter: "drop-shadow(0 0 24px rgba(247,243,228,0.25))" }} className="pulse">
              <Sprite svg={yanyueSVG("stand")} />
            </div>
            <div style={{ width: 150, height: 120, transform: "rotate(72deg) translateY(-30px)", opacity: 0.9 }}>
              <Sprite svg={shenyanSVG()} />
            </div>
          </div>
        )}
        {shot === "wheel" && (
          <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <div style={{ width: 210, height: 210 }} className="float">
              <Sprite svg={moonWheelSVG(1)} />
            </div>
          </div>
        )}
        {shot === "stranger" && (
          <div style={{ position: "absolute", inset: 0, display: "flex", justifyContent: "center", alignItems: "flex-end", gap: 10 }}>
            <div style={{ width: 160, height: 210 }}><Sprite svg={yanyueSVG("stand")} /></div>
            <div style={{ width: 160, height: 210, filter: "grayscale(0.4) brightness(0.8)" }}><Sprite svg={shenyanSVG()} /></div>
          </div>
        )}
      </div>
      <div className="prologue-caption fade-in" key={`c${step}`}>{CAPTIONS[step] ?? ""}</div>
      <div className="prologue-skip">Enter / 空格 · 下一步{step < SHOTS.length - 1 ? "" : " · 进入游戏"}</div>
    </div>
  );
}