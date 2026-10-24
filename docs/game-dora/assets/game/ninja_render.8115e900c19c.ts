// game/ninja_render.ts — 忍者敌人雪碧图渲染：bandit→peasant、thrower→kunoichi、boss→monk
// FSM→动作映射，横条带切帧（Sprite.texture 只读，故每动画懒建一张 Sprite 显隐切换）
// 帧数来自实机探测（宽/高整除）。scale 校准目标＝帧内人物实际身高：bandit=90px（=主角立绘 90px）、
// thrower=110px（实机反馈体型偏小，1.13→1.38 调大）、boss=110px。
// 换算：scale = 目标身高 / (cell × 帧内占比)。占比无像素级实测（引擎无像素读取 API，命令沙箱禁读二进制 PNG，
// 项目内无 atlas JSON），按帧格顶部留白比例估算并经两轮实机反馈校准：bandit≈0.72、thrower≈0.62（128 大格动作留白多）、
// boss≈0.80（monk 壮硕占格更满）；假设脚底贴帧格底边（无底部留白）。
import { Node, Rect, Sprite, Texture2D, TextureFilter, Vec2 } from "Dora";
import type { EnemyState } from "game/enemies";

type AnimKey = "idle" | "run" | "walk" | "jump" | "attack_1" | "attack_2" | "hurt" | "dead";

interface AnimDef {
  frames: number;
  fps: number;
  loop: boolean;
}

interface KindDef {
  char: string;
  cell: number;
  scale: number;
  faceRight: boolean;
  anims: { [k: string]: AnimDef };
}

const KINDS: { [kind: string]: KindDef } = {
  // bandit: cell=96 scale=1.30 → 画布高=124.8 人物实占≈90（占比假设 0.72：90/(96×0.72)）
  bandit: {
    char: "peasant", cell: 96, scale: 1.3, faceRight: true,
    anims: {
      idle: { frames: 6, fps: 6, loop: true },
      run: { frames: 6, fps: 10, loop: true },
      walk: { frames: 8, fps: 8, loop: true },
      jump: { frames: 8, fps: 8, loop: false },
      attack_1: { frames: 6, fps: 14, loop: false },
      attack_2: { frames: 4, fps: 14, loop: false },
      hurt: { frames: 2, fps: 10, loop: false },
      dead: { frames: 4, fps: 10, loop: false },
    },
  },
  // thrower: cell=128 scale=1.38 → 画布高=177.3 人物实占≈110（占比假设 0.62：110/(128×0.62)；实机反馈偏小，旧 1.13→90px）
  thrower: {
    char: "kunoichi", cell: 128, scale: 1.38, faceRight: true,
    anims: {
      idle: { frames: 9, fps: 6, loop: true },
      run: { frames: 8, fps: 10, loop: true },
      walk: { frames: 8, fps: 8, loop: true },
      jump: { frames: 10, fps: 8, loop: false },
      attack_1: { frames: 6, fps: 14, loop: false },
      attack_2: { frames: 8, fps: 14, loop: false },
      hurt: { frames: 2, fps: 10, loop: false },
      dead: { frames: 5, fps: 10, loop: false },
    },
  },
  // boss: cell=96 scale=1.43 → 画布高=137.3 人物实占≈110（占比假设 0.80：110/(96×0.80)；旧 1.60 偏高）
  boss: {
    char: "monk", cell: 96, scale: 1.43, faceRight: true,
    anims: {
      idle: { frames: 7, fps: 6, loop: true },
      run: { frames: 8, fps: 10, loop: true },
      walk: { frames: 7, fps: 8, loop: true },
      jump: { frames: 9, fps: 8, loop: false },
      attack_1: { frames: 5, fps: 12, loop: false },
      attack_2: { frames: 5, fps: 12, loop: false },
      hurt: { frames: 4, fps: 10, loop: false },
      dead: { frames: 5, fps: 10, loop: false },
    },
  },
};

// 敌人 FSM → 忍者动作（蓄力阶段用 idle 站姿，冲刺用 run）
const FSM_ANIM: { [s: string]: AnimKey } = {
  patrol: "walk",
  chase: "run",
  windup: "idle",
  telegraph: "idle",
  swing: "attack_1",
  recover: "idle",
  hurt: "hurt",
  charge: "run",
  throw: "attack_2",
  dead: "dead",
};

// ——— 弓手（独立素材包 archer-hero-128，per-frame PNG，非横条带）———
// idle/walk 各方向 12 帧循环，176×176 画布、bottom-center 统一地平线、无内建阴影。
// 免费部分无攻击/受击/死亡帧：蓄力与出手用 idle 站姿，射击表现由 telegraph 前摇
// + 箭矢绘制承担；死亡沿用雪碧图 0.55s 透明度淡出。east 朝右、west 朝左，按朝向
// 选向不镜像。人物实占帧高比例无像素实测（同 ninja 条带口径），按 0.75 估：
// ARCHER_SCALE = 90 / (176 × 0.75) ≈ 0.68 → 目标视觉身高 90px，与其他敌人校准一致。
const ARCHER_DIR = "assets/characters/archer";
const ARCHER_SCALE = 0.74; // 用户反馈弓手再大一点点：0.68 → 0.74（视觉身高≈98px）
// 2026-10-24 用户反馈弓手不贴地：176×176 帧底部有透明留边（包内“地平线”非帧底边），
// 锚底对齐后脚部悬浮 → 整体下沉补偿（世界像素）；实机仍浮/埋地改此常量即可
const ARCHER_GROUND_OFFSET = 10;
const ARCHER_FSM: { [s: string]: string } = {
  patrol: "idle",
  chase: "walk",
  windup: "idle",
  telegraph: "idle",
  swing: "idle",
  recover: "idle",
  hurt: "idle",
  charge: "walk",
  throw: "idle",
  dead: "idle",
};
interface ArcherAnimDef {
  frames: number;
  fps: number;
  loop: boolean;
}
const ARCHER_ANIMS: { [k: string]: ArcherAnimDef } = {
  idle: { frames: 12, fps: 10, loop: true },
  walk: { frames: 12, fps: 12, loop: true },
};

interface AnimTex {
  tex: Texture2D.Type;
  def: AnimDef;
  fw: number;
  fh: number;
}

interface Slot {
  // 当前动画键（ninja 条带为动画名；弓手为 idle_east 这类动画+方向复合键）
  anim: string;
  t: number;
  used: boolean;
  sprites: { [k: string]: Sprite.Type };
}

export class NinjaLayer {
  private root: Node.Type;
  private texSets: { [kind: string]: { [anim: string]: AnimTex } } = {};
  private kindOk: { [kind: string]: boolean } = {};
  private slots: { [id: string]: Slot } = {};
  private frameDt = 0;
  // 弓手逐帧贴图：键 = idle_east 等，值为按帧序排列的贴图数组
  private archerTex: { [k: string]: Texture2D.Type[] } = {};
  private archerOk = false;
  ok = false;

  constructor(root: Node.Type) {
    this.root = root;
    let allOk = true;
    for (const kind in KINDS) {
      const kd = KINDS[kind];
      const set: { [anim: string]: AnimTex } = {};
      let kindOk = true;
      for (const anim in kd.anims) {
        const def = kd.anims[anim];
        const tex = Texture2D("assets/enemies/ninja/" + kd.char + "_" + anim + ".png");
        if (tex === undefined) {
          kindOk = false;
          break;
        }
        set[anim] = { tex: tex, def: def, fw: kd.cell, fh: kd.cell };
      }
      this.texSets[kind] = set;
      this.kindOk[kind] = kindOk;
      if (!kindOk) {
        allOk = false;
      }
    }
    // 弓手逐帧贴图加载：4 组（idle/walk × east/west）× 12 帧，任一缺失则回退程序化
    let archerOk = true;
    for (const animName in ARCHER_ANIMS) {
      const adef = ARCHER_ANIMS[animName];
      for (const dir of ["east", "west"]) {
        const key = animName + "_" + dir;
        const list: Texture2D.Type[] = [];
        for (let i = 0; i < adef.frames; i++) {
          const nn = (i < 10 ? "0" : "") + i;
          const tex = Texture2D(ARCHER_DIR + "/" + key + "/" + nn + ".png");
          if (tex === undefined) {
            archerOk = false;
            break;
          }
          list.push(tex);
        }
        if (!archerOk) {
          break;
        }
        this.archerTex[key] = list;
      }
      if (!archerOk) {
        break;
      }
    }
    this.archerOk = archerOk;
    if (!archerOk) {
      allOk = false;
    }
    this.ok = allOk;
  }

  beginFrame(dt: number): void {
    this.frameDt = dt;
  }

  private hideSlot(s: Slot): void {
    for (const k in s.sprites) {
      s.sprites[k].visible = false;
    }
  }

  // 帧末调用：本帧未用到的槽位（尸体已回收等）隐藏并释放
  endFrame(): void {
    for (const id in this.slots) {
      const s = this.slots[id];
      if (!s.used) {
        this.hideSlot(s);
        delete this.slots[id];
        continue;
      }
      s.used = false;
    }
  }

  // 返回 true = 已用雪碧图渲染（调用方跳过程序化 drawEnemy）
  drawEnemy(e: EnemyState): boolean {
    if (e.def.kind === "archer") {
      return this.drawArcher(e);
    }
    const kd = KINDS[e.def.kind];
    if (kd === undefined || this.kindOk[e.def.kind] !== true) {
      return false;
    }
    const set = this.texSets[e.def.kind];
    const wantRaw = FSM_ANIM[e.state];
    const want: AnimKey = wantRaw === undefined ? "idle" : wantRaw;
    let slot = this.slots[e.def.id];
    if (slot === undefined) {
      slot = { anim: want, t: 0, used: true, sprites: {} };
      this.slots[e.def.id] = slot;
    }
    if (want !== slot.anim) {
      slot.anim = want;
      slot.t = 0;
    } else {
      slot.t = slot.t + this.frameDt;
    }
    const at = set[slot.anim];
    if (at === undefined) {
      return false;
    }
    slot.used = true;
    for (const k in slot.sprites) {
      if (k !== slot.anim) {
        slot.sprites[k].visible = false;
      }
    }
    let sp = slot.sprites[slot.anim];
    if (sp === undefined) {
      sp = Sprite(at.tex, Rect(0, 0, at.fw, at.fh));
      sp.filter = TextureFilter.Point;
      sp.anchor = Vec2(0.5, 0);
      sp.addTo(this.root);
      slot.sprites[slot.anim] = sp;
    }
    let idx = Math.floor(slot.t * at.def.fps);
    if (at.def.loop) {
      idx = idx % at.def.frames;
    } else if (idx > at.def.frames - 1) {
      idx = at.def.frames - 1;
    }
    const face = e.facing * (kd.faceRight ? 1 : -1);
    sp.visible = true;
    sp.position = Vec2(e.body.x, e.body.y - e.body.h / 2);
    sp.scaleX = kd.scale * face;
    sp.scaleY = kd.scale;
    sp.textureRect = Rect(idx * at.fw, 0, at.fw, at.fh);
    if (e.dead) {
      const dt2 = e.deathTimer === undefined ? 0 : e.deathTimer;
      sp.opacity = Math.floor(255 * Math.max(0, Math.min(1, dt2 / 0.55)));
    } else {
      sp.opacity = 255;
    }
    return true;
  }

  // 弓手：per-frame 雪碧图（assets/characters/archer/）。免费包只有 idle/walk 两个循环
  // （东西向各 12 帧，176×176，bottom-center 统一地平线），蓄力/出手/受击/死亡均用 idle
  // 站姿表现，射击感由 telegraph 前摇 + 箭矢绘制承担；死亡沿用 0.55s 透明度淡出。
  // Sprite.texture 只读，故按 动画×方向×帧 懒建 Sprite 显隐切换（每弓手最多 48 张）。
  private drawArcher(e: EnemyState): boolean {
    if (!this.archerOk) {
      return false;
    }
    const wantRaw = ARCHER_FSM[e.state];
    const want = wantRaw === undefined ? "idle" : wantRaw;
    const key = want + "_" + (e.facing >= 0 ? "east" : "west");
    const list = this.archerTex[key];
    const def = ARCHER_ANIMS[want];
    if (list === undefined || def === undefined) {
      return false;
    }
    let slot = this.slots[e.def.id];
    if (slot === undefined) {
      slot = { anim: key, t: 0, used: true, sprites: {} };
      this.slots[e.def.id] = slot;
    }
    if (slot.anim !== key) {
      slot.anim = key;
      slot.t = 0;
    } else {
      slot.t = slot.t + this.frameDt;
    }
    slot.used = true;
    const idx = Math.floor(slot.t * def.fps) % def.frames;
    const frameKey = key + "_" + idx;
    for (const k in slot.sprites) {
      if (k !== frameKey) {
        slot.sprites[k].visible = false;
      }
    }
    let sp = slot.sprites[frameKey];
    if (sp === undefined) {
      sp = Sprite(list[idx]);
      sp.filter = TextureFilter.Point;
      sp.anchor = Vec2(0.5, 0);
      sp.addTo(this.root);
      slot.sprites[frameKey] = sp;
    }
    sp.visible = true;
    sp.position = Vec2(e.body.x, e.body.y - e.body.h / 2 - ARCHER_GROUND_OFFSET);
    sp.scaleX = ARCHER_SCALE;
    sp.scaleY = ARCHER_SCALE;
    if (e.dead) {
      const dt2 = e.deathTimer === undefined ? 0 : e.deathTimer;
      sp.opacity = Math.floor(255 * Math.max(0, Math.min(1, dt2 / 0.55)));
    } else {
      sp.opacity = 255;
    }
    return true;
  }
}
