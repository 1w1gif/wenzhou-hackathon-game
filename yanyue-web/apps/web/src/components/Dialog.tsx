"use client";

import { useEffect, useState } from "react";
import { useGame, DIALOGS, CONFRONTATION_CHOICES } from "@yanyue/game-core";
import type { DialogLine } from "@yanyue/game-core";

export interface DialogState {
  lines: DialogLine[];
  onDone?: () => void;
}

/** 对话浮层：E/空格推进；对峙时转三选一（1/2/3） */
export default function Dialog() {
  // dialogState 由 WorldScreen 通过 window 事件传递（避免把回调解进 store）
  const [state, setState] = useState<DialogState | null>(null);
  const [idx, setIdx] = useState(0);
  const [choosing, setChoosing] = useState(false);

  useEffect(() => {
    const open = (e: Event) => {
      const d = (e as CustomEvent<DialogState>).detail;
      setState(d);
      setIdx(0);
      setChoosing(false);
    };
    const close = () => setState(null);
    window.addEventListener("yanyue-dialog", open);
    window.addEventListener("yanyue-dialog-close", close);
    return () => {
      window.removeEventListener("yanyue-dialog", open);
      window.removeEventListener("yanyue-dialog-close", close);
    };
  }, []);

  if (!state) return null;

  const line = state.lines[idx];
  const isLast = idx >= state.lines.length - 1;

  const advance = () => {
    if (choosing) return;
    if (isLast) {
      if (state.onDone) { setChoosing(true); return; }
      window.dispatchEvent(new Event("yanyue-dialog-close"));
      setState(null);
    } else {
      setIdx(idx + 1);
    }
  };

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "e" || e.key === "E" || e.key === " " || e.key === "Enter") advance();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  });

  return (
    <div className="dialog" onClick={advance}>
      <div className="speaker">{line.speaker}</div>
      <div className="text">{line.text}</div>
      {choosing && state.onDone ? (
        <div className="choices">
          {CONFRONTATION_CHOICES.map((c, i) => (
            <button key={c.id} className="btn" onClick={(ev) => {
              ev.stopPropagation();
              window.dispatchEvent(new CustomEvent("yanyue-confront", { detail: c.id }));
              window.dispatchEvent(new Event("yanyue-dialog-close"));
              setState(null);
            }}>
              <span className="kbd">{i + 1}</span>　{c.label}
            </button>
          ))}
        </div>
      ) : (
        <div className="next">E / 空格 继续</div>
      )}
    </div>
  );
}