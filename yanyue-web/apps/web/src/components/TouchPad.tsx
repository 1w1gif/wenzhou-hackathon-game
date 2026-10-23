"use client";

/**
 * 触屏虚拟按键：左手方向，右手跳跃 + 功能键。
 * 只在粗指针设备（手机/平板）或窄窗口显示，桌面键盘操作不受影响。
 * 按住用 pointer capture 锁定，手指滑出按钮也不会丢释放事件。
 */
import { useEffect, useRef, useState } from "react";
import type { MouseEvent as ReactMouseEvent, PointerEvent as ReactPointerEvent } from "react";

export type HoldKey = "left" | "right" | "jump";

interface Props {
  onHold: (key: HoldKey, down: boolean) => void;
  onRewind: () => void;
  onJournal: () => void;
  onTree: () => void;
}

export default function TouchPad({ onHold, onRewind, onJournal, onTree }: Props) {
  const [on, setOn] = useState<Record<string, boolean>>({});
  const held = useRef(new Set<HoldKey>());

  const release = (key: HoldKey) => {
    if (!held.current.has(key)) return;
    held.current.delete(key);
    setOn((s) => ({ ...s, [key]: false }));
    onHold(key, false);
  };

  const press = (key: HoldKey) => (e: ReactPointerEvent<HTMLButtonElement>) => {
    e.preventDefault();
    e.currentTarget.setPointerCapture?.(e.pointerId);
    if (held.current.has(key)) return;
    held.current.add(key);
    setOn((s) => ({ ...s, [key]: true }));
    onHold(key, true);
  };

  const lift = (key: HoldKey) => (e: ReactPointerEvent<HTMLButtonElement>) => {
    e.preventDefault();
    release(key);
  };

  // 卸载或切屏时兜底释放，避免“一直在走”
  useEffect(() => {
    const keys = held.current;
    const clear = () => { for (const k of [...keys]) release(k); };
    window.addEventListener("blur", clear);
    return () => { window.removeEventListener("blur", clear); clear(); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const stop = (e: ReactMouseEvent) => e.preventDefault();

  return (
    <div className="touch-pad">
      <div className="touch-cluster left">
        <button
          type="button"
          aria-label="向左"
          className={`pad-btn dir ${on.left ? "on" : ""}`}
          onPointerDown={press("left")}
          onPointerUp={lift("left")}
          onPointerCancel={lift("left")}
          onContextMenu={stop}
        >
          <svg viewBox="0 0 24 24" width="26" height="26" aria-hidden="true">
            <path d="M15 4 L7 12 L15 20" fill="none" stroke="currentColor" strokeWidth="2.4"
              strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <button
          type="button"
          aria-label="向右"
          className={`pad-btn dir ${on.right ? "on" : ""}`}
          onPointerDown={press("right")}
          onPointerUp={lift("right")}
          onPointerCancel={lift("right")}
          onContextMenu={stop}
        >
          <svg viewBox="0 0 24 24" width="26" height="26" aria-hidden="true">
            <path d="M9 4 L17 12 L9 20" fill="none" stroke="currentColor" strokeWidth="2.4"
              strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
      </div>

      <div className="touch-cluster right">
        <div className="touch-utils">
          <button type="button" className="pad-btn mini" aria-label="引月札" onClick={onJournal}>
            <span>札</span>
          </button>
          <button type="button" className="pad-btn mini" aria-label="时空树" onClick={onTree}>
            <span>树</span>
          </button>
          <button type="button" className="pad-btn mini" aria-label="回溯" onClick={onRewind}>
            <span>↺</span>
          </button>
        </div>
        <button
          type="button"
          aria-label="跳跃"
          className={`pad-btn jump ${on.jump ? "on" : ""}`}
          onPointerDown={press("jump")}
          onPointerUp={lift("jump")}
          onPointerCancel={lift("jump")}
          onContextMenu={stop}
        >
          <span className="glyph">跃</span>
          <span className="sub">二段</span>
        </button>
      </div>
    </div>
  );
}