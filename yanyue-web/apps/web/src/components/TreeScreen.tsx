"use client";

/**
 * 时空树：玩家的每一次选择都让树长出一条新枝。
 * 做法 = 旧原型 Tree.ts：竖直为列（第 N 夜从左往右），折线枝条 + 枝上选择注记，
 * 节点是月相圆盘，当前世界线高亮，点击跳回那条世界线。
 */
import { useMemo, useRef, useState } from "react";
import { useGame, MOON_PHASES, ancestorIds } from "@yanyue/game-core";
import type { TreeNode } from "@yanyue/game-core";
import { moonSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";

const COL_W = 200; // 每夜一列
const ROW_H = 96;
const DOT = 40;

export default function TreeScreen({ inGame = false }: { inGame?: boolean }) {
  const nodes = useGame((s) => s.nodes);
  const activeId = useGame((s) => s.activeId);
  const jumpTo = useGame((s) => s.jumpTo);
  const resetAll = useGame((s) => s.resetAll);
  const goto = useGame((s) => s.goto);
  const toggleTree = useGame((s) => s.toggleTree);

  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [tip, setTip] = useState<{ n: TreeNode; cx: number; cy: number } | null>(null);
  const drag = useRef<{ sx: number; sy: number; ox: number; oy: number; moved: boolean } | null>(null);

  // 布局：night 为列，同列内按创建顺序排
  const laid = useMemo(() => {
    const byNight = new Map<number, TreeNode[]>();
    for (const n of nodes) {
      const arr = byNight.get(n.night) ?? [];
      arr.push(n);
      byNight.set(n.night, arr);
    }
    const out = new Map<string, { x: number; y: number }>();
    for (const [night, arr] of [...byNight.entries()].sort((a, b) => a[0] - b[0])) {
      arr.forEach((n, i) => {
        out.set(n.id, { x: (night - 1) * COL_W, y: i * ROW_H });
      });
    }
    return out;
  }, [nodes]);

  const maxNight = nodes.reduce((m, n) => Math.max(m, n.night), 1);
  const W = maxNight * COL_W + 80;
  const H = Math.max(2, ...[...laid.values()].map(p => p.y)) + ROW_H + 80;
  const chain = useMemo(() => ancestorIds(nodes, activeId), [nodes, activeId]);

  const onPointerDown = (e: React.PointerEvent) => {
    drag.current = { sx: e.clientX, sy: e.clientY, ox: pan.x, oy: pan.y, moved: false };
  };
  const onPointerMove = (e: React.PointerEvent) => {
    if (!drag.current) return;
    const dx = e.clientX - drag.current.sx;
    const dy = e.clientY - drag.current.sy;
    if (Math.abs(dx) + Math.abs(dy) > 4) drag.current.moved = true;
    setPan({ x: drag.current.ox + dx, y: drag.current.oy + dy });
  };
  const onPointerUp = () => { drag.current = null; };

  const openNode = (n: TreeNode) => {
    if (drag.current?.moved) return;
    if (n.id === activeId) return;
    jumpTo(n.id);
    if (!inGame) goto("world");
  };

  return (
    <div className="screen tree-screen">
      <div className="tree-header">
        <h1>时 空 树</h1>
        <p>{inGame ? "你走过的每一条世界线 · 点击节点跳回" : "这条世界线，是你亲手种出来的"}　·　{nodes.length} 条世界线 · 最深 第 {maxNight} 夜</p>
      </div>

      <div className="tree-canvas-wrap"
        onPointerDown={onPointerDown} onPointerMove={onPointerMove} onPointerUp={onPointerUp}
        onWheel={(e) => setZoom(z => Math.min(1.6, Math.max(0.4, z * (e.deltaY > 0 ? 0.92 : 1.08))))}
      >
        <div className="tree-canvas" style={{ width: W, height: H, transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})` }}>
          {/* 夜层列 */}
          {Array.from({ length: maxNight }, (_, i) => (
            <div key={i} className="tree-night-label" style={{ left: i * COL_W + DOT / 2 + 40, top: -18 }}>
              第 {i + 1} 夜
            </div>
          ))}

          {/* 枝条（SVG 折线） */}
          <svg className="tree-edges" width={W} height={H}>
            {nodes.map(n => {
              if (!n.parentId) return null;
              const p = laid.get(n.parentId);
              const c = laid.get(n.id);
              if (!p || !c) return null;
              const hot = chain.has(n.id) && chain.has(n.parentId);
              const midX = p.x + (c.x - p.x) / 2;
              return (
                <g key={n.id}>
                  <path d={`M ${p.x + DOT / 2 + 40} ${p.y + DOT / 2 + 30} L ${midX + DOT / 2 + 40} ${p.y + DOT / 2 + 30} L ${midX + DOT / 2 + 40} ${c.y + DOT / 2 + 30} L ${c.x + 40} ${c.y + DOT / 2 + 30}`}
                    fill="none" stroke={hot ? "#c9a05c" : "#3d4658"} strokeWidth={hot ? 3 : 1.6} />
                  <text x={midX + DOT / 2 + 40} y={(c.y + p.y) / 2 + 26} textAnchor="middle"
                    fill={hot ? "#d8cfa8" : "#5a6478"} fontSize="11">{n.label.length > 10 ? n.label.slice(0, 9) + "…" : n.label}</text>
                </g>
              );
            })}
          </svg>

          {/* 节点 */}
          {nodes.map(n => {
            const p = laid.get(n.id)!;
            const isCur = n.id === activeId;
            const phaseIdx = n.snap.moonPhaseIndex;
            return (
              <div key={n.id}
                className={`tree-node ${isCur ? "current" : ""} ${n.kind === "ending" ? "ending" : ""}`}
                style={{ left: p.x + DOT / 2 + 40, top: p.y + DOT / 2 + 30 }}
                onPointerUp={() => openNode(n)}
                onPointerEnter={(e) => setTip({ n, cx: p.x + DOT / 2 + 40, cy: p.y })}
                onPointerLeave={() => setTip(null)}
              >
                <div className="dot" style={{ width: DOT, height: DOT }}>
                  {n.kind === "ending"
                    ? <span style={{ fontSize: 18 }}>终</span>
                    : isCur
                      ? <span style={{ fontSize: 15, color: "#f7f3e4" }}>{MOON_PHASES[phaseIdx][0]}</span>
                      : <span style={{ fontSize: 15, color: "#9ec8c9" }}>{MOON_PHASES[phaseIdx][0]}</span>}
                </div>
                <div className="tag">{n.kind === "origin" ? "起点" : n.kind === "ending" ? "结局" : `第 ${n.night} 夜`}</div>
              </div>
            );
          })}

          {tip && (
            <div className="tree-tip" style={{ left: tip.cx + DOT / 2 + 40, top: tip.cy + 24 }}>
              <div>第 {tip.n.night} 夜 · {MOON_PHASES[tip.n.snap.moonPhaseIndex]}</div>
              <div className="sub">{tip.n.label}{tip.n.id === activeId ? " · 当前世界线" : ""}</div>
            </div>
          )}
        </div>
      </div>

      <div className="tree-footer">
        {inGame ? (
          <button className="btn btn-ghost" onClick={() => toggleTree(false)}>返回游戏（T）</button>
        ) : (
          <>
            <button className="btn btn-ghost" onClick={() => { toggleTree(false); goto("title"); }}>回到标题</button>
            <button className="btn btn-gold" onClick={() => { resetAll(); }}>再来一轮 · 种下新的树</button>
          </>
        )}
        <span><span className="lbl-full">拖动平移 · 滚轮缩放 · 点击节点跳回那条世界线</span><span className="lbl-short">拖动平移 · 点击节点跳回</span></span>
      </div>
    </div>
  );
}