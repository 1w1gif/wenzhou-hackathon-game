// game/physics.ts — 平台物理：AABD 碰撞、单向平台、梯子、攀墙标记、移动平台
// 纯逻辑模块，便于无头测试。
import { Platform, Rect, Ladder, ClimbWall } from "core/types";

export interface BodyState {
  x: number;
  y: number;
  vx: number;
  vy: number;
  w: number;
  h: number;
  onGround: boolean;
  groundId: string;
  onLadder: boolean;
}

export interface MoveResult {
  hitWall: boolean;
  wallDir: number; // -1 左墙 1 右墙 0 无
  landed: boolean;
  hitCeiling: boolean;
  groundId: string;
}

export function rectOverlap(a: Rect, b: Rect): boolean {
  return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
}

export function bodyRect(body: BodyState): Rect {
  return { x: body.x - body.w / 2, y: body.y - body.h / 2, w: body.w, h: body.h };
}

function overlapX(a: Rect, b: Rect): boolean {
  return a.x < b.x + b.w && a.x + a.w > b.x;
}

function overlapY(a: Rect, b: Rect): boolean {
  return a.y < b.y + b.h && a.y + a.h > b.y;
}

// 收集本帧参与碰撞的平台（含已开门的 gate）
export function activePlatforms(all: Platform[], openedGates: Record<string, boolean>): Platform[] {
  const list: Platform[] = [];
  for (let i = 0; i < all.length; i++) {
    const p = all[i];
    if (p.kind === "gate" && p.gateId !== undefined && openedGates[p.gateId]) {
      continue;
    }
    list.push(p);
  }
  return list;
}

// 水平位移 + 碰撞
function moveX(body: BodyState, platforms: Platform[], dx: number): MoveResult {
  const result: MoveResult = { hitWall: false, wallDir: 0, landed: false, hitCeiling: false, groundId: "" };
  body.x = body.x + dx;
  const r = bodyRect(body);
  for (let i = 0; i < platforms.length; i++) {
    const p = platforms[i];
    if (p.kind === "one-way") {
      continue;
    }
    const pr: Rect = { x: p.x, y: p.y, w: p.w, h: p.h };
    if (!overlapX(r, pr) || !overlapY(r, pr)) {
      continue;
    }
    if (dx > 0) {
      body.x = pr.x - body.w / 2 - 0.01;
      result.hitWall = true;
      result.wallDir = 1;
    } else if (dx < 0) {
      body.x = pr.x + pr.w + body.w / 2 + 0.01;
      result.hitWall = true;
      result.wallDir = -1;
    }
    body.vx = 0;
    r.x = body.x - body.w / 2;
  }
  return result;
}

// 垂直位移 + 碰撞；dropThrough 为 true 时跳过单向平台
function moveY(body: BodyState, platforms: Platform[], dy: number, dropThrough: boolean): MoveResult {
  const result: MoveResult = { hitWall: false, wallDir: 0, landed: false, hitCeiling: false, groundId: "" };
  const prevBottom = body.y - body.h / 2;
  body.y = body.y + dy;
  const r = bodyRect(body);
  let bestTop = -1e9;
  let bestId = "";
  for (let i = 0; i < platforms.length; i++) {
    const p = platforms[i];
    const pr: Rect = { x: p.x, y: p.y, w: p.w, h: p.h };
    if (!overlapX(r, pr) || !overlapY(r, pr)) {
      continue;
    }
    if (dy <= 0) {
      // 下落：实心平台总是阻挡；单向平台仅当之前脚底在平台顶之上
      if (p.kind === "one-way") {
        if (dropThrough) {
          continue;
        }
        if (prevBottom < pr.y + pr.h - 4) {
          continue;
        }
      }
      if (pr.y + pr.h > bestTop) {
        bestTop = pr.y + pr.h;
        bestId = p.id;
      }
    } else {
      // 上升：单向平台不阻挡头顶
      if (p.kind === "one-way") {
        continue;
      }
      body.y = pr.y - body.h / 2 - 0.01;
      body.vy = 0;
      result.hitCeiling = true;
      r.y = body.y - body.h / 2;
    }
  }
  if (dy <= 0 && bestTop > -1e8) {
    const wasAir = !body.onGround;
    body.y = bestTop + body.h / 2;
    if (body.vy < -1) {
      result.landed = wasAir;
    }
    body.vy = 0;
    body.onGround = true;
    body.groundId = bestId;
    result.groundId = bestId;
    r.y = body.y - body.h / 2;
  }
  return result;
}

// 完整一步：先水平后垂直。返回碰撞信息。
export function moveAndCollide(
  body: BodyState,
  platforms: Platform[],
  dx: number,
  dy: number,
  dropThrough: boolean
): MoveResult {
  const rx = moveX(body, platforms, dx);
  const ry = moveY(body, platforms, dy, dropThrough);
  return {
    hitWall: rx.hitWall,
    wallDir: rx.wallDir,
    landed: ry.landed,
    hitCeiling: ry.hitCeiling,
    groundId: ry.groundId,
  };
}

export function updateGroundState(body: BodyState, platforms: Platform[]): boolean {
  // 检查脚下是否有支撑（走出平台边缘时）
  const probe: Rect = { x: body.x - body.w / 2 + 2, y: body.y - body.h / 2 - 3, w: body.w - 4, h: 4 };
  for (let i = 0; i < platforms.length; i++) {
    const p = platforms[i];
    const pr: Rect = { x: p.x, y: p.y, w: p.w, h: p.h };
    if (rectOverlap(probe, pr)) {
      if (p.kind === "one-way") {
        // 单向平台只在从上方接触时算支撑
        if (body.y - body.h / 2 >= pr.y + pr.h - 6) {
          body.onGround = true;
          body.groundId = p.id;
          return true;
        }
      } else {
        body.onGround = true;
        body.groundId = p.id;
        return true;
      }
    }
  }
  body.onGround = false;
  body.groundId = "";
  return false;
}

export function ladderAt(body: BodyState, ladders: Ladder[]): Ladder | undefined {
  const r = bodyRect(body);
  for (let i = 0; i < ladders.length; i++) {
    if (rectOverlap(r, ladders[i])) {
      return ladders[i];
    }
  }
  return undefined;
}

export function climbWallAt(
  body: BodyState,
  wallDir: number,
  walls: ClimbWall[]
): ClimbWall | undefined {
  if (wallDir === 0) {
    return undefined;
  }
  const r = bodyRect(body);
  const probe: Rect = {
    x: wallDir > 0 ? r.x + r.w - 2 : r.x - 6,
    y: r.y + 6,
    w: 8,
    h: r.h - 12,
  };
  for (let i = 0; i < walls.length; i++) {
    if (rectOverlap(probe, walls[i])) {
      return walls[i];
    }
  }
  return undefined;
}

export function clamp(v: number, lo: number, hi: number): number {
  if (v < lo) {
    return lo;
  }
  if (v > hi) {
    return hi;
  }
  return v;
}

export function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}
