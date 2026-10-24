// game/hero_frames.ts — 衍月动作帧集：女主动作包 16 帧 PNG 按姿势表驱动 Sprite 显隐
// 立绘兜底：任一姿势缺帧时由 render_world 回退到单张立绘（idle/land 始终走立绘；ladder 用用户提供的两张攀爬帧）
import { Node, Sprite, Texture2D, Vec2 } from "Dora";
import type { HeroPose } from "game/render_chars";

interface PoseDef {
  files: string[];
  fps: number; // >0 帧动画帧率（非循环播到尾帧停住）；0 静态单帧
  height: number; // 目标画布高（世界像素），scale = height / tex.height
  loop: boolean;
}

// 实机验收后可在此微调各姿势高度/帧率（帧画布含透明边距，高度≠人物实际身高）
const POSE_DEFS: { [pose: string]: PoseDef } = {
  run: { files: ["run_0", "run_1", "run_2", "run_3", "run_4"], fps: 7, height: 96, loop: true }, // 2026-10-22 换用户重导 5 帧（跑步1-5 按编号顺序，修复旧包 02/03 疑似重复）；帧率 10→7：用户反馈太快看不清
  jump: { files: ["jump_0", "jump_1"], fps: 6, height: 100, loop: false },
  fall: { files: ["fall_0"], fps: 0, height: 100, loop: true }, // 新包仅单帧下落
  cling: { files: ["cling_0"], fps: 0, height: 100, loop: false },
  // 爬梯帧：2026-10-26 用户澄清真正两帧=微信同批保存图（19:30:47/49）：cling_1=微信图片_20261023193047_137_33(1540x2423)、
  // cling_2=微信图片_20261023193049_138_33(1624x2407，=曾误传的「新攀爬2」本体，本就正确)；「新攀爬1」「爬梯子1/2」作废不采。
  // 两帧 3.3fps 循环（2026-10-26 用户需求③：帧速 ×1.1，3→3.3）；相位用 player.climbT（只在梯上移动时推进），静止扒梯定格当前帧
  ladder: { files: ["cling_1", "cling_2"], fps: 3.3, height: 100, loop: true },
  dash: { files: ["dash_0", "dash_1"], fps: 14, height: 100, loop: false },
  // 2026-10-24 用户反馈：普攻每按一下要完整播挥刀1~5 五帧、如剑气般流畅——
  // 三连击三段均整套装连播（5 帧 @20fps = 0.25s，都在 attackTime 0.3/0.3/0.34 窗口内播完收尾），
  // 命中判定/连击窗口等战斗数值不变；重击(K 剑气)维持挥刀4-5 两帧不变
  attack1: { files: ["atk_0", "atk_1", "atk_2", "atk_3", "atk_4"], fps: 20, height: 104, loop: false },
  attack2: { files: ["atk_0", "atk_1", "atk_2", "atk_3", "atk_4"], fps: 20, height: 104, loop: false },
  attack3: { files: ["atk_0", "atk_1", "atk_2", "atk_3", "atk_4"], fps: 20, height: 104, loop: false },
  heavy: { files: ["atk_3", "atk_4"], fps: 12, height: 104, loop: false },
  hurt: { files: ["hurt_0"], fps: 0, height: 100, loop: false },
};

// 逐帧高度校准表：帧画布含透明边距且尺寸不齐（实测 836x1231 ~ 1664x2322），
// 人物实际占画比例逐帧不同时按文件名覆盖乘数（乘在 scale 上；缺省 1 = 不调整）。
// 标定方法：对比图 .agent/vision/梯子三张截图读数 → 某帧偏高填 <1，偏矮填 >1。
const FRAME_MUL: { [file: string]: number } = {
  // 2026-10-22 实机校准第一轮：用户反馈除站立（立绘 90px）外所有动作偏高
  // → 全部动作统一缩到画布高 90px（mul = 90/def.height），与站立同基准；某帧仍偏差时单独改该行
  run_0: 0.9375,
  run_1: 0.9375,
  run_2: 0.9375,
  run_3: 0.9375,
  run_4: 0.9375, // 新增第 5 帧，与旧帧同基准（96×0.9375≈90px）
  jump_0: 0.9,
  jump_1: 0.9,
  // fall 画布特别高(1360x2559)、人物占画比例小：0.9 偏小 → 1.1（2026-10-22 用户实机反馈下落偏小）
  fall_0: 1.1,
  cling_0: 0.9,
  // 爬梯两帧：2026-10-26 换微信137/138 后实机校准 1.05→1.4 偏大，用户定稿 1.12（还要调就只动这两行）
  cling_1: 1.12,
  cling_2: 1.12,
  dash_0: 0.9,
  dash_1: 0.9,
  // 2026-10-22 第二轮换装（.agent/挥刀/ 挥刀1..5 -> atk_0..4，服装修正）：
  // 新画布 1820x2306/1588x2640/1910x2048/2126x1974/1704x2460，与旧画布逐帧比对人物实占比例后校准；
  // 旧值统一 0.93，新包后三帧画布留白更大，下调以保持人物尺寸不变（实机若仍有偏差可单独微调某行）
  atk_0: 0.92,
  atk_1: 0.95,
  atk_2: 0.95,
  atk_3: 0.88,
  atk_4: 0.87,
  hurt_0: 0.9,
};

// 素材目录：女主动作包最终版 16 帧（源 .agent/女主.zip，2026-10-21 接入；攻击 5 帧按标注顺序完整播一套）
const HERO_DIR = "assets/characters/hero_v2/";

// 素材朝向开关：true = 素材面向右（实机发现反了改此常量即可）
export const HERO_FRAMES_FACE_RIGHT = true;

export interface HeroFrame {
  sp: Sprite.Type;
  scale: number;
}

export class HeroFrameSet {
  frames: { [pose: string]: HeroFrame[] } = {};
  loadedCount = 0;

  constructor(parent: Node.Type) {
    for (const pose in POSE_DEFS) {
      const def = POSE_DEFS[pose];
      const list: HeroFrame[] = [];
      for (const f of def.files) {
        const tex = Texture2D(HERO_DIR + f + ".png");
        if (tex === undefined) {
          continue;
        }
        const sp = Sprite(tex);
        sp.anchor = Vec2(0.5, 0);
        sp.visible = false;
        const mul = FRAME_MUL[f] !== undefined ? FRAME_MUL[f] : 1;
        const scale = (def.height / tex.height) * mul;
        sp.scaleX = scale;
        sp.scaleY = scale;
        sp.addTo(parent);
        list.push({ sp: sp, scale: scale });
        this.loadedCount = this.loadedCount + 1;
      }
      if (list.length > 0) {
        this.frames[pose] = list;
      }
    }
  }

  has(pose: string): boolean {
    return this.frames[pose] !== undefined;
  }

  // 选当前应显示帧；调用方负责隐藏其余帧
  pick(pose: HeroPose, animTime: number): HeroFrame | undefined {
    const list = this.frames[pose];
    if (list === undefined) {
      return undefined;
    }
    const def = POSE_DEFS[pose];
    let idx = 0;
    if (def.fps > 0) {
      if (def.loop) {
        idx = Math.floor(animTime * def.fps) % list.length;
      } else {
        idx = Math.floor(animTime * def.fps);
        if (idx > list.length - 1) {
          idx = list.length - 1;
        }
      }
    }
    return list[idx];
  }

  hideAll(): void {
    for (const pose in this.frames) {
      const list = this.frames[pose];
      for (const fr of list) {
        fr.sp.visible = false;
      }
    }
  }
}
