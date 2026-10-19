"use client";

import { useState } from "react";
import { useGame, CLUE_INFO, RELIC_INFO, MOON_PHASES } from "@yanyue/game-core";

export default function Journal() {
  const toggleJournal = useGame((s) => s.toggleJournal);
  const cur = useGame((s) => s.cur);
  const nodes = useGame((s) => s.nodes);

  return (
    <div className="journal" onClick={() => toggleJournal(false)}>
      <div className="book" onClick={(e) => e.stopPropagation()}>
        <h2>引 月 札</h2>
        <section>
          <b>当前世界线</b><br />
          第 {cur.loopIndex + 1} 夜 · {MOON_PHASES[cur.moonPhaseIndex]} · 共 {nodes.length} 条世界线<br />
          生命 {cur.life}/{cur.maxLife} · 剑意 {cur.swordIntent}/{cur.maxSwordIntent}
        </section>
        <section>
          <b>沈砚</b><br />
          信任 {cur.trust} · {cur.metShenyan ? "已相遇（他不记得你）" : "尚未相遇"} · {cur.drawnBlade ? "曾拔剑相向" : "剑未指向他"}
        </section>
        <section>
          <b>线索 {cur.clues.length}/4</b><br />
          {cur.clues.length === 0 ? "（尚未寻得）" : cur.clues.map(id => `「${CLUE_INFO[id]?.name ?? id}」`).join(" ")}
          {cur.clues.map(id => (
            <div key={id} style={{ fontSize: 12, color: "var(--ink-mid)" }}>{CLUE_INFO[id]?.text}</div>
          ))}
        </section>
        <section>
          <b>旧信物 {cur.relics.length}/3</b><br />
          {cur.relics.length === 0 ? "（尚未寻得）" : cur.relics.map(id => `「${RELIC_INFO[id]?.name ?? id}」`).join(" ")}
        </section>
        <section>
          <b>月石碎片</b>　{cur.moonStones} 枚
        </section>
        <div className="keys">
          A / D · 方向键 移动　E 调查 / 对话　Q 转动月相轮回溯<br />
          N 引月札　T 时空树
        </div>
        <div style={{ textAlign: "right", marginTop: 10 }}>
          <button className="btn btn-ghost" onClick={() => toggleJournal(false)}>合上（N）</button>
        </div>
      </div>
    </div>
  );
}