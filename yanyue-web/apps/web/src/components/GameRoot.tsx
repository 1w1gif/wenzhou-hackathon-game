"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useGame, MOON_PHASES, ZONES, PORTALS, DIALOGS, CONFRONTATION_CHOICES, CLUE_INFO, RELIC_INFO, ENDINGS } from "@yanyue/game-core";
import type { DialogLine } from "@yanyue/game-core";
import { yanyueSVG, shenyanSVG, banditSVG, observerSVG, lanternSVG, starSVG, moonSVG, moonWheelSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";
import TitleScreen from "./TitleScreen";
import Prologue from "./Prologue";
import WorldScreen from "./WorldScreen";
import EndingScreen from "./EndingScreen";
import TreeScreen from "./TreeScreen";
import Journal from "./Journal";
import Dialog from "./Dialog";

export default function GameRoot() {
  const phase = useGame((s) => s.phase);
  const showTree = useGame((s) => s.showTree);
  const showJournal = useGame((s) => s.showJournal);

  const screen = (() => {
    switch (phase) {
      case "prologue": return <Prologue />;
      case "world": return <WorldScreen />;
      case "ending": return <EndingScreen />;
      case "tree": return <TreeScreen />;
      default: return <TitleScreen />;
    }
  })();

  return (
    <>
      {screen}
      {phase === "world" && <Dialog />}
      {showJournal && phase === "world" && <Journal />}
      {showTree && phase === "world" && <TreeOverlay />}
    </>
  );
}

/** 游戏内时空树浮层（世界屏中按 T 打开） */
function TreeOverlay() {
  const toggleTree = useGame((s) => s.toggleTree);
  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 70 }}>
      <TreeScreen inGame />
      <button className="btn btn-ghost" style={{ position: "absolute", right: 18, top: 16, color: "#c9d4e2", borderColor: "#4a5468" }}
        onClick={() => toggleTree(false)}>
        返回 ✕
      </button>
    </div>
  );
}

export { useGame, MOON_PHASES, ZONES, PORTALS, DIALOGS, CONFRONTATION_CHOICES, CLUE_INFO, RELIC_INFO, ENDINGS, yanyueSVG, shenyanSVG, banditSVG, observerSVG, lanternSVG, starSVG, moonSVG, moonWheelSVG, Sprite };
export type { DialogLine };
export { useCallback, useEffect, useMemo, useRef, useState };