"use client";

/**
 * 横版平台跳跃世界屏（ requestAnimationFrame 物理循环）。
 * 手感：加速度/摩擦、土狼时间、跳跃缓冲、可变跳高、二段跳（淡墨月轮）。
 * 平台来自网格地图：'#' 实心墙，','/'.'/'^'/'*' 等为可站地面，'w' 水面也可站（河岸）。
 */
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useGame, ZONES, PORTALS, DIALOGS, MOON_PHASES } from "@yanyue/game-core";
import { yanyueSVG, shenyanSVG, banditSVG, observerSVG, lanternSVG, starSVG, moonSVG } from "@yanyue/art-engine";
import { Sprite } from "./Sprite";

const TS = 64;
const GRAVITY = 2600;
const MOVE_SPEED = 340;
const ACCEL = 2800;
const FRICTION = 2600;
const JUMP_V = 760;
const JUMP2_V = 680;
const CUT_V = 240;      // 松开跳跃截断上升
const COYOTE = 0.11;    // 土狼时间
const BUFFER = 0.14;    // 跳跃缓冲
const MAX_FALL = 1300;

interface Body { x: number; y: number; vx: number; vy: number; w: number; h: number; onGround: boolean; jumps: number }

export default function WorldScreen() {
  const cur = useGame((s) => s.cur);
  const zoneId = useGame((s) => s.zone);
  const spawnRef = useRef({ x: useGame.getState().px, y: useGame.getState().py });
  const setPos = useGame((s) => s.setPos);
  const rewind = useGame((s) => s.rewind);
  const addTrust = useGame((s) => s.addTrust);
  const addClue = useGame((s) => s.addClue);
  const addRelic = useGame((s) => s.addRelic);
  const addMoonStone = useGame((s) => s.addMoonStone);
  const markMet = useGame((s) => s.markMet);
  const markBlade = useGame((s) => s.markBlade);
  const hurt = useGame((s) => s.hurt);
  const judgeEnding = useGame((s) => s.judgeEnding);
  const record = useGame((s) => s.record);
  const goto = useGame((s) => s.goto);
  const toggleTree = useGame((s) => s.toggleTree);
  const toggleJournal = useGame((s) => s.toggleJournal);

  const zone = ZONES[zoneId] ?? ZONES.riverbank;
  const rows = zone.rows;
  const worldW = rows[0].length * TS;
  const worldH = rows.length * TS;

  const [toast, setToast] = useState<{ text: string; until: number } | null>(null);
  const [facing, setFacing] = useState<1 | -1>(1);
  const [pose, setPose] = useState<"stand" | "run" | "jump">("stand");
  const [checkpoint, setCheckpoint] = useState(spawnRef.current);
  const [, setRenderTick] = useState(0);

  const busy = useRef(false);          // 对话/过场中锁定操作
  const dialogOpen = useRef(false);
  const body = useRef<Body>({ x: (spawnRef.current.x + 0.5) * TS - 20, y: (spawnRef.current.y + 1) * TS - 84, vx: 0, vy: 0, w: 40, h: 78, onGround: false, jumps: 0 });
  const keys = useRef<Record<string, boolean>>({});
  const jumpPressedAt = useRef(-9);
  const lastGroundedAt = useRef(-9);
  const confronted = useRef(false);
  const metSet = useRef(new Set<string>());
  const gotSet = useRef(new Set<string>());
  const lastSync = useRef<{ x: number; y: number; zone: string } | null>(null);

  const say = useCallback((key: keyof typeof DIALOGS, onDone?: () => void) => {
    dialogOpen.current = true;
    window.dispatchEvent(new CustomEvent("yanyue-dialog", {
      detail: { lines: DIALOGS[key], onDone: () => { dialogOpen.current = false; onDone?.(); } },
    }));
  }, []);

  const showToast = useCallback((text: string, ms = 2400) => {
    setToast({ text, until: Date.now() + ms });
  }, []);

  useEffect(() => {
    if (toast && Date.now() > toast.until) setToast(null);
  }, [toast]);

  // 时空树跳回后：把物理体放到该世界线的落点
  const tpX = useGame((s) => s.px);
  const tpY = useGame((s) => s.py);
  const tpZone = useGame((s) => s.zone);
  const lastTp = useRef<string>(`${tpX},${tpY},${tpZone}`);
  useEffect(() => {
    const key = `${tpX},${tpY},${tpZone}`;
    if (key === lastTp.current) return;
    lastTp.current = key;
    body.current.x = (tpX + 0.5) * TS - 20;
    body.current.y = (tpY + 1) * TS - 84;
    body.current.vx = 0; body.current.vy = 0;
  }, [tpX, tpY, tpZone]);

  /* ---------------- 碰撞 ---------------- */
  const solidAt = useCallback((x: number, y: number): boolean => {
    const cx = Math.floor(x / TS), cy = Math.floor(y / TS);
    const ch = rows[cy]?.[cx] ?? "#";
    return ch === "#";
  }, [rows]);

  /* ---------------- 主循环（RAF + 定时器兜底：后台/节流环境也能跑） ---------------- */
  const tickRef = useRef<(now: number) => void>(() => {});
  const lastRafRef = useRef(0);

  useEffect(() => {
    const step = (now: number) => {
      lastRafRef.current = now;
      tickRef.current(now);
    };
    const raf = requestAnimationFrame(step);
    // 看门狗：RAF 被节流（标签后台/嵌入面板）时用定时器驱动物理
    const watchdog = setInterval(() => {
      if (performance.now() - lastRafRef.current > 450) tickRef.current(performance.now());
    }, 60);
    return () => { cancelAnimationFrame(raf); clearInterval(watchdog); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    let prev: number | undefined;
    const step = (now: number) => {
      const dt = Math.min(0.033, (now - (prev ?? now)) / 1000);
      prev = now;

      const b = body.current;
      const left = keys.current["a"] || keys.current["arrowleft"];
      const right = keys.current["d"] || keys.current["arrowright"];

      if (!dialogOpen.current && !busy.current) {
        const dir = (right ? 1 : 0) - (left ? 1 : 0);
        if (dir !== 0) {
          setFacing(dir as 1 | -1);
          b.vx += dir * ACCEL * dt;
          b.vx = Math.max(-MOVE_SPEED, Math.min(MOVE_SPEED, b.vx));
        } else {
          const sign = Math.sign(b.vx);
          b.vx -= sign * FRICTION * dt;
          if (Math.sign(b.vx) !== sign) b.vx = 0;
        }

        // 跳跃缓冲 + 土狼时间
        if (now / 1000 - jumpPressedAt.current < BUFFER && (b.onGround || now / 1000 - lastGroundedAt.current < COYOTE)) {
          b.vy = -JUMP_V; b.onGround = false; b.jumps = 1; jumpPressedAt.current = -9;
        } else if (now / 1000 - jumpPressedAt.current < BUFFER && b.jumps < 2) {
          b.vy = -JUMP2_V; b.jumps = 2; jumpPressedAt.current = -9;
        }
        // 可变跳高
        const jumpHeld = keys.current[" "] || keys.current["w"] || keys.current["arrowup"];
        if (!jumpHeld && b.vy < -CUT_V) b.vy = -CUT_V;
      } else {
        b.vx = 0;
      }

      // 重力
      b.vy = Math.min(MAX_FALL, b.vy + GRAVITY * dt);

      // X 轴移动 + 碰撞
      const nx = b.x + b.vx * dt;
      if (!solidAt(nx + (b.vx > 0 ? b.w : 0), b.y + b.h / 2) && !solidAt(nx + (b.vx > 0 ? b.w : 0), b.y + b.h - 4)) b.x = nx;
      else b.vx = 0;
      b.x = Math.max(0, Math.min(worldW - b.w, b.x));

      // Y 轴移动 + 碰撞（含单向：只有下落时才碰头）
      const ny = b.y + b.vy * dt;
      if (b.vy >= 0) {
        const footY = ny + b.h;
        if (!solidAt(b.x + 4, footY) && !solidAt(b.x + b.w - 4, footY)) {
          b.y = ny; b.onGround = false;
        } else {
          b.y = Math.floor(footY / TS) * TS - b.h;
          if (!b.onGround) { /* 落地 */ }
          b.onGround = true; b.vy = 0; b.jumps = 0;
          lastGroundedAt.current = now / 1000;
        }
      } else {
        const headY = ny;
        if (!solidAt(b.x + b.w / 2, headY)) b.y = ny;
        else { b.vy = 0; b.y = Math.floor(headY / TS) * TS + TS; }
        b.onGround = false;
      }

      // 摔出地图 → 回检查点
      if (b.y > worldH + 80) {
        b.x = (checkpoint.x + 0.5) * TS - 20;
        b.y = (checkpoint.y + 1) * TS - 84;
        b.vx = 0; b.vy = 0;
        showToast("一阵晕眩……你回到了印记处。");
      }

      // 姿态
      setPose(!b.onGround ? "jump" : Math.abs(b.vx) > 30 ? "run" : "stand");
      setRenderTick(t => t + 1);

      // 落地时把物理坐标同步回 store（供时空树记录落点/刷新恢复）
      if (b.onGround) {
        const gx = Math.floor((b.x + b.w / 2) / TS);
        const gy = Math.floor((b.y + b.h + 2) / TS);
        const last = lastSync.current;
        if (!last || last.x !== gx || last.y !== gy || last.zone !== zoneId) {
          lastSync.current = { x: gx, y: gy, zone: zoneId };
          setPos(gx, gy, zoneId);
        }
      }
      // 到达点事件
      checkTriggers(b);
    };
    tickRef.current = step;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [rows, worldW, worldH, checkpoint, showToast, say]);

  /* ---------------- 到达点触发 ---------------- */
  const checkTriggers = useCallback((b: Body) => {
    const cx = Math.floor((b.x + b.w / 2) / TS);
    const cy = Math.floor((b.y + b.h / 2) / TS);
    const ch = rows[cy]?.[cx] ?? "#";

    // 星光
    if (ch === "S" && !gotSet.current.has(`s${cx}_${cy}`)) {
      gotSet.current.add(`s${cx}_${cy}`);
      addMoonStone();
      showToast("拾得月光凝成的星石 ✦");
    }
    // 线索
    if (ch === "r" && !gotSet.current.has(`r${cx}_${cy}_${zoneId}`)) {
      gotSet.current.add(`r${cx}_${cy}_${zoneId}`);
      if (zoneId === "street" || zoneId === "workshop") {
        if (addClue("workshop_note")) { record("clue", "寻得工坊残记"); say("workshopRecord"); }
      } else if (zoneId === "gears") {
        if (addClue("bell_echo")) { showToast("获得线索：钟声之秘"); record("clue", "钟声之秘"); }
      } else {
        if (addClue("moon_mirror")) { showToast("获得线索：月光倒影"); record("clue", "月光倒影"); }
      }
    }
    // 沈砚
    if (ch === "e" && !metSet.current.has(`e${cx}_${cy}_${zoneId}`)) {
      metSet.current.add(`e${cx}_${cy}_${zoneId}`);
      if (!cur.metShenyan && zoneId === "riverbank") {
        markMet(); addTrust(1); record("trust", "初遇 · 陌生的小镇故人");
        say("firstMeeting");
      } else if (zoneId === "corridor" || zoneId === "gears") {
        addTrust(1); record("trust", "塔中偶遇 · 信任 +1");
        say("towerMeeting");
      }
    }
    // 观测者
    if (ch === "o" && !metSet.current.has(`o${cx}_${cy}_${zoneId}`)) {
      metSet.current.add(`o${cx}_${cy}_${zoneId}`);
      const isNew = !cur.clues.includes("observer_truth");
      say("observer", () => {
        if (isNew) { addClue("observer_truth"); record("clue", "观测者之言"); addRelic("star_chart"); showToast("他递给你一张双星图 ✦ 旧信物 +1"); }
      });
    }
    // 头目
    if (ch === "B" && !metSet.current.has(`B${cx}_${cy}`)) {
      metSet.current.add(`B${cx}_${cy}`);
      hurt(1);
      showToast("劫匪头目挥刀砍来！你负伤击退了他。", 2600);
    }
    // 上层入口
    if (ch === "^") {
      const up = PORTALS[zoneId]?.up;
      if (up) {
        const z = ZONES[up];
        const spawnY = z.rows.findIndex(r => r.includes("*"));
        const spawnX = z.rows[spawnY].indexOf("*");
        setCheckpoint({ x: spawnX, y: spawnY });
        setPos(spawnX, spawnY, up);
        body.current.x = (spawnX + 0.5) * TS - 20;
        body.current.y = (spawnY + 1) * TS - 84;
        body.current.vx = 0; body.current.vy = 0;
        showToast(`—— ${z.name} ——\n${z.hint ?? ""}`, 3000);
      }
    }
    // 观星台对峙
    if (zoneId === "observatory" && cy <= 2 && !confronted.current) {
      confronted.current = true;
      say("confrontation");
    }
  }, [rows, zoneId, cur, addClue, addMoonStone, addRelic, addTrust, markMet, hurt, record, say, setPos, showToast]);

  /* ---------------- 对峙选择 ---------------- */
  const confront = useCallback((choice: string) => {
    let eid;
    if (choice === "sacrifice") eid = judgeEnding(true, false);
    else if (choice === "fight") { markBlade(); eid = judgeEnding(false, true); }
    else eid = judgeEnding(false, false);
    useGame.setState({ endingSeen: eid });
    record("ending", choice === "drop" ? "放下剑，走向他" : choice === "sacrifice" ? "转动月相轮，以命换命" : "拔剑，击倒他强行关仪", undefined, eid);
    goto("ending");
  }, [judgeEnding, markBlade, record, goto]);

  useEffect(() => {
    const onConfront = (e: Event) => confront((e as CustomEvent<string>).detail);
    window.addEventListener("yanyue-confront", onConfront);
    return () => window.removeEventListener("yanyue-confront", onConfront);
  }, [confront]);

  /* ---------------- 键盘 ---------------- */
  useEffect(() => {
    const isTypingKey = (k: string) => ["a", "d", "w", "s", " ", "arrowleft", "arrowright", "arrowup", "arrowdown"].includes(k);
    const down = (e: KeyboardEvent) => {
      const k = e.key.toLowerCase();
      if (dialogOpen.current) return;
      if (k === "t") { toggleTree(); return; }
      if (k === "n") { toggleJournal(); return; }
      if (k === "q") {
        if (rewind()) showToast(`月相轮转动 · 生命 -1\n现在：第 ${useGame.getState().cur.loopIndex + 1} 夜 · ${MOON_PHASES[useGame.getState().cur.moonPhaseIndex]}`, 2600);
        else showToast("月相轮已经无法再次转动。\n「你还剩下最后一次选择。」", 3200);
        return;
      }
      if (isTypingKey(k)) {
        keys.current[k] = true;
        if (k === " " || k === "w" || k === "arrowup") jumpPressedAt.current = performance.now() / 1000;
        e.preventDefault();
      }
    };
    const up = (e: KeyboardEvent) => { keys.current[e.key.toLowerCase()] = false; };
    window.addEventListener("keydown", down);
    window.addEventListener("keyup", up);
    return () => { window.removeEventListener("keydown", down); window.removeEventListener("keyup", up); };
  }, [rewind, showToast, toggleTree, toggleJournal]);

  /* ---------------- 场景实体（静态摆放） ---------------- */
  const entities = useMemo(() => {
    const out: Array<{ key: string; x: number; y: number; svg: string; cls?: string; name?: string; w?: number; h?: number }> = [];
    rows.forEach((row, y) => {
      row.split("").forEach((ch, x) => {
        if (ch === "e") out.push({ key: `e${x}_${y}`, x, y, svg: shenyanSVG(zoneId === "observatory"), name: "沈砚", w: TS, h: TS * 1.35 });
        if (ch === "o") out.push({ key: `o${x}_${y}`, x, y, svg: observerSVG(), name: "？？？", w: TS, h: TS * 1.35 });
        if (ch === "h") out.push({ key: `h${x}_${y}`, x, y, svg: lanternSVG(), cls: "bob", w: TS * 0.6, h: TS * 0.8 });
        if (ch === "S") out.push({ key: `s${x}_${y}`, x, y, svg: starSVG(), cls: "float pulse", w: TS * 0.5, h: TS * 0.5 });
        if (ch === "B") out.push({ key: `B${x}_${y}`, x, y, svg: banditSVG("boss"), name: "劫匪头目", w: TS, h: TS * 1.35 });
      });
    });
    return out;
  }, [rows, zoneId]);

  return (
    <div className="screen world-screen">
      <div className="hud">
        <span className="brand">衍月·八相</span>
        <span className="hud-pill life">生命 {"◈".repeat(cur.life)}{"◇".repeat(Math.max(0, cur.maxLife - cur.life))}</span>
        <span className="hud-pill">剑意 {"—".repeat(cur.swordIntent)}{"·".repeat(Math.max(0, cur.maxSwordIntent - cur.swordIntent))}</span>
        <span className="hud-pill gold">☾ {MOON_PHASES[cur.moonPhaseIndex]} · 第 {cur.loopIndex + 1} 夜</span>
        <span className="hud-pill">信任 {cur.trust}</span>
        <span className="hud-spacer" />
        <button onClick={() => toggleJournal()}>引月札（N）</button>
        <button onClick={() => toggleTree()}>时空树（T）</button>
        <button onClick={() => { if (rewind()) showToast("月相轮转动 · 生命 -1"); else showToast("月相轮已无法转动"); }}>回溯（Q）</button>
      </div>

      <div className="viewport">
        <div className="world" style={{ width: worldW, height: worldH, transform: `translate(${Math.max(-(worldW - window.innerWidth), Math.min(0, -body.current.x + window.innerWidth / 2 - TS / 2))}px, ${Math.max(-(worldH - (window.innerHeight - 56)), Math.min(0, -body.current.y + (window.innerHeight - 56) / 2 - 60))}px)` }}>
          {rows.map((row, y) =>
            row.split("").map((ch, x) => <Tile key={`${x}-${y}`} ch={ch} x={x} y={y} />)
          )}
          {entities.map(en => (
            <div key={en.key} className={`entity ${en.cls ?? ""}`}
              style={{ left: en.x * TS + (TS - (en.w ?? TS)) / 2, top: en.y * TS + TS - (en.h ?? TS), width: en.w ?? TS, height: en.h ?? TS }}>
              <Sprite svg={en.svg} />
              {en.name && <div className="npc-name">{en.name}</div>}
            </div>
          ))}
          <div className="entity player" style={{ left: body.current.x, top: body.current.y, width: body.current.w, height: body.current.h * 1.15, transform: facing === -1 ? "scaleX(-1)" : undefined }}>
            <Sprite svg={yanyueSVG(pose)} />
          </div>
        </div>
        <div className="zone-label">{zone.name}</div>
        <div className="objective-tip">{zone.hint ?? "A/D 移动 · 空格跳跃（可二段跳）"}</div>
        {toast && <div className="toast">{toast.text}</div>}
      </div>
    </div>
  );
}

function Tile({ ch, x, y }: { ch: string; x: number; y: number }) {
  let cls = `tile t-ground ${(x + y) % 2 ? "alt" : ""}`;
  if (ch === ",") cls = `tile t-path ${(x + y) % 2 ? "alt" : ""}`;
  else if (ch === "#") cls = "tile t-wall";
  else if (ch === "w") cls = "tile t-water";
  else if (ch === "T") cls = "tile t-tree";
  else if (ch === "^") cls = "tile t-portal";
  else if (ch === "*") cls = `tile t-ground ${(x + y) % 2 ? "alt" : ""} t-checkpoint`;
  return (
    <div key={`${x}-${y}`} className={cls}
      style={{ left: x * TS, top: y * TS, width: TS, height: TS }} />
  );
}