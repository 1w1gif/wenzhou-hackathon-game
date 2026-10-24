// core/archive.ts — 通关时空树仓库存档：玩家名 + 该局时空树快照（行格式，无 JSON 依赖）
// 文件：saves/profile.txt（玩家名）、saves/archive.txt（仓库，追加式）
// 数据与 game/timeline_tree.TreeNode、ui/tree_overlay.OverlayNode 结构兼容（只描述形状，不引依赖）
import { Content, Path } from "Dora";

/** 时空树节点快照（与 TreeSystem.nodes 元素同构） */
export interface ArchiveNode {
  id: string;
  parent: string;
  via: string;
  phase: number;
  depth: number;
  abandoned: boolean;
}

/** 一条通关记录：一位旅人的名字与其独一无二的世界线之树 */
export interface ArchiveEntry {
  name: string;
  endingTitle: string;
  /** 回溯次数（月相轮转动次数） */
  rewindCount: number;
  /** 该局树的当前世界线 id */
  currentId: string;
  nodes: ArchiveNode[];
}

/** 仓库展示条目数上限（超出移除最旧的） */
export const ARCHIVE_MAX = 30;
export const DEFAULT_NAME = "无名旅人";

const SAVE_DIR = "saves";
const ARCHIVE_FILE = "saves/archive.txt";
const PROFILE_FILE = "saves/profile.txt";

function root(): string {
  return Content.searchPaths[0];
}

/** 名字与取舍文字进档前清洗：去掉分隔符与换行，限长 */
export function sanitizeName(raw: string, maxLen: number): string {
  let s = "";
  for (let i = 0; i < raw.length; i++) {
    const c = raw.charAt(i);
    if (c !== "|" && c !== "," && c !== "\n" && c !== "\r") {
      s = s + c;
    }
  }
  s = s.trim();
  if (s.length > maxLen) {
    s = s.substring(0, maxLen);
  }
  return s;
}

function ensureDir(): void {
  const dir = Path(root(), SAVE_DIR);
  if (!Content.exist(dir)) {
    Content.mkdir(dir);
  }
}

function loadText(file: string): string | undefined {
  const p = Path(root(), file);
  if (!Content.exist(p)) {
    return undefined;
  }
  return Content.load(p);
}

function saveText(file: string, data: string): boolean {
  ensureDir();
  return Content.save(Path(root(), file), data);
}

// —— 玩家名 ——

export function loadPlayerName(): string {
  const t = loadText(PROFILE_FILE);
  if (t === undefined) {
    return "";
  }
  return sanitizeName(t, 12);
}

export function savePlayerName(name: string): void {
  saveText(PROFILE_FILE, sanitizeName(name, 12));
}

// —— 仓库 ——

export function loadArchive(): ArchiveEntry[] {
  const text = loadText(ARCHIVE_FILE);
  const list: ArchiveEntry[] = [];
  if (text === undefined) {
    return list;
  }
  const lines = text.split("\n");
  let cur: ArchiveEntry | undefined = undefined;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line === "") {
      continue;
    }
    const f = line.split(",");
    if (f[0] === "E" && f.length >= 6) {
      cur = {
        name: f[1],
        endingTitle: f[2],
        rewindCount: toInt(f[3]),
        currentId: f[4],
        nodes: [],
      };
      list.push(cur);
    } else if (f[0] === "N" && f.length >= 7 && cur !== undefined) {
      cur.nodes.push({
        id: f[1],
        parent: f[2],
        via: f[3],
        phase: toInt(f[4]),
        depth: toInt(f[5]),
        abandoned: f[6] === "1",
      });
    }
  }
  return list;
}

function toInt(s: string): number {
  const n = parseInt(s, 10);
  return isNaN(n) ? 0 : n;
}

/** 追加一条通关记录；超出上限移除最旧的 */
export function appendArchive(entry: ArchiveEntry): boolean {
  const list = loadArchive();
  list.push(entry);
  while (list.length > ARCHIVE_MAX) {
    list.shift();
  }
  return saveArchive(list);
}

export function saveArchive(list: ArchiveEntry[]): boolean {
  const parts: string[] = [];
  for (let i = 0; i < list.length; i++) {
    const e = list[i];
    parts.push(
      "E," + e.name + "," + e.endingTitle + "," + e.rewindCount + "," + e.currentId + "," + e.nodes.length,
    );
    for (let j = 0; j < e.nodes.length; j++) {
      const n = e.nodes[j];
      parts.push(
        "N," + n.id + "," + n.parent + "," + sanitizeName(n.via, 16) + "," + n.phase + "," + n.depth + "," + (n.abandoned ? "1" : "0"),
      );
    }
  }
  return saveText(ARCHIVE_FILE, parts.join("\n"));
}
