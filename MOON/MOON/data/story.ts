// data/story.ts — 《衍月·八相》剧情文案数据
// 纯数据模块：不 import "Dora"，无任何副作用。
// 台词风格：文言白话相杂，简短克制，情绪重于解释。

import { DialogChoice, EndingDef, StoryNode } from "core/types";

/** 序章字幕：依次显示，hold 为停留秒数 */
export const PROLOGUE_SUBTITLES: { text: string; hold: number }[] = [
  { text: "那一夜，满月如盘，他死在我面前。", hold: 3.2 },
  { text: "我这一剑，斩得断强盗，斩不断天意。", hold: 3.0 },
  { text: "月亮把时间还给了我。", hold: 2.8 },
  { text: "代价是，我的生命。", hold: 2.8 },
  { text: "而他忘记了我。", hold: 2.6 },
  { text: "这一次，换我用剑，护你周全。", hold: 3.0 },
];

/** 周目之问：结局判定用的关键台词 */
export const WHO_ARE_YOU_LINE: string = "你是谁？";

const RIVERSIDE_CHOICES: DialogChoice[] = [
  { text: "路过。看看月亮。", trust: 1 },
  {
    text: "旧年中秋，有人在塔上欠我一枚糖人。",
    trust: 2,
    memory: "我提起了幼时的约定",
  },
];

const OBSERVER1_CHOICES: DialogChoice[] = [
  { text: WHO_ARE_YOU_LINE, trust: 0 },
  {
    text: "我能救他吗？",
    trust: 1,
    memory: "观测者承认了循环",
  },
];

const ARROW_CHOICES: DialogChoice[] = [
  {
    text: "（挡下）小心！",
    trust: 2,
    memory: "我替他挡下了那支箭",
  },
  { text: "（不挡）", trust: 0 },
];

/** 剧情节点：storyId → 节点。选项后的应答行依序附在 lines 尾部。 */
export const STORY_NODES: Record<string, StoryNode> = {
  story_check_intro: {
    id: "story_check_intro",
    lines: [
      { speaker: "衍月（内心）", text: "我回来了。" },
      { speaker: "衍月（内心）", text: "这一次，我不会让你死在我面前。" },
    ],
    objective: "目标：向东击退码头强盗（J 斩击 · K 月刃）",
  },

  story_riverside: {
    id: "story_riverside",
    lines: [
      { speaker: "沈砚", text: "这位女侠，一直跟着我做什么？" },
      { speaker: "衍月（内心）", text: "他看我的眼神……和那夜一样干净。" },
      { speaker: "衍月（内心）", text: "只是不再认得我。" },
      { speaker: "沈砚", text: "月亮有什么好看……罢了，姑娘请便。" },
      { speaker: "沈砚", text: "……糖人？你怎会知道此事？" },
    ],
    choices: RIVERSIDE_CHOICES,
    objective: "目标：击退前方强盗，再登上东边木梯进入古镇街巷（W 攀爬）",
  },

  story_town: {
    id: "story_town",
    lines: [
      { speaker: "衍月（内心）", text: "山道上已有火光……比上一世更早。" },
      { speaker: "衍月（内心）", text: "强盗提前来了。" },
      { speaker: "沈砚（远处喊）", text: "塔上传讯！让开粮道！" },
    ],
    objective: "目标：穿过街巷，抵达悬空工坊",
  },

  story_sneak_hint: {
    id: "story_sneak_hint",
    lines: [
      { speaker: "衍月（内心）", text: "强盗在搬空工坊……" },
      { speaker: "衍月（内心）", text: "从上方木板绕过去，或者，正面斩过去。" },
    ],
    objective: "目标：通过工坊区（潜行或战斗）",
  },

  story_workshop: {
    id: "story_workshop",
    lines: [
      { speaker: "衍月（内心）", text: "工坊的残页……月相装置是沈家世代守护的古仪。" },
      { speaker: "衍月（内心）", text: "上面说，它在『等待』满月之夜。" },
    ],
    objective: "目标：登上塔外环廊",
    setFlag: "lore_device",
  },

  story_boss_intro: {
    id: "story_boss_intro",
    lines: [
      { speaker: "劫匪头目", text: "沈家的小郎君把宝贝看得比命重。" },
      { speaker: "劫匪头目", text: "姑娘，识相的把月相轮交出来。" },
      { speaker: "衍月", text: "好啊。拿命来换。" },
    ],
    objective: "目标：击败劫匪头目",
  },

  story_observer_1: {
    id: "story_observer_1",
    lines: [
      { speaker: "观测者（斗笠旅人）", text: "你不是第一次来这里。" },
      { speaker: "观测者", text: "只是每一次，只有你记得。" },
      { speaker: "观测者", text: "一个记得所有循环的人。" },
      { speaker: "观测者", text: "剑救不了。心未必。" },
    ],
    choices: OBSERVER1_CHOICES,
    objective: "目标：登上观星台",
    setFlag: "lore_loop",
  },

  story_observer_2: {
    id: "story_observer_2",
    lines: [
      { speaker: "衍月（内心）", text: "残卷上说，装置会在满月之夜『选择』一个人。" },
      { speaker: "衍月（内心）", text: "上一世它选中的……是冲进去的沈砚。" },
      { speaker: "衍月（内心）", text: "每回溯一次，他和装置就缠得越深。" },
    ],
    setFlag: "lore_choose",
  },

  story_arrow: {
    id: "story_arrow",
    lines: [
      { speaker: "沈砚", text: "又是你。为何总阴魂不散——" },
      { speaker: "！！", text: "一支冷箭破空而来！（按 E 替他挡下）" },
      { speaker: "沈砚", text: "……多谢。你到底是——罢了。" },
      { speaker: "沈砚", text: "（箭擦过肩，他冷冷看你）不必假惺惺。" },
    ],
    choices: ARROW_CHOICES,
  },

  story_final: {
    id: "story_final",
    lines: [
      { speaker: "沈砚", text: "站住。今夜的月，轮不到你染指。" },
      { speaker: "衍月", text: "砚哥哥，是我。" },
      { speaker: "沈砚", text: "衍月？……不。衍月早死在三个月前的山道上了。" },
      { speaker: "沈砚", text: "你这妖女，休想再骗我。" },
      { speaker: "衍月（内心）", text: "他的眼睛里……只有装置的反光。" },
      { speaker: "沈砚", text: "装置是沈家的使命。要关它——先从我尸体上踏过去。" },
    ],
    objective: "",
  },
};

/** 结局文案：键为结局 id */
export const ENDINGS: Record<string, EndingDef> = {
  reunion: {
    id: "reunion",
    title: "终之相·望",
    lines: [
      "她卸了剑，任他的刀落在肩头，也不还手。",
      "旧信物散落一地——那是只有他们两个才知道的东西。",
      "沈砚的执念在旧物面前碎裂，装置的封印随他的迟疑松开。",
      "她抓住空隙，关上了装置。",
      "这一次，他终于记得我。",
      "不是因为时间还给了他答案，",
      "而是因为我的剑，始终没有指向他。",
      "（塔底深处，星盘上有一枚本不该存在的刻度，正缓缓亮起。）",
    ],
  },
  sacrifice: {
    id: "sacrifice",
    title: "终之相·晦",
    lines: [
      "她转动月相轮，把最后一缕生命投入装置。",
      "月光漫过她的身影，像墨迹没入水中。",
      "沈砚活了下来。",
      "他手中只留下一枚刻着八相的暗金圆盘。",
      "他活下来了。只是这一次，",
      "换成了我没有留下。",
      "（月亮异常明亮，塔中深处传来一声轻轻的转动声。）",
    ],
  },
  blade: {
    id: "blade",
    title: "终之相·残",
    lines: [
      "剑赢了。",
      "他倒下时，喃喃的还是那三个字——你是谁。",
      "装置关上了。他活了下来。",
      "只是他永远不会再想起她。",
      "我的剑赢得了对峙，却输掉了他。",
      "（她收剑入鞘，独自走下塔去。身后再没有钟声。）",
    ],
  },
  exhausted: {
    id: "exhausted",
    title: "月相停转",
    lines: [
      "月相轮再也转不动了。",
      "时间停在满月升顶的一瞬。",
      "塔顶传来第二声钟鸣。",
      "月亮再也不会把时间还给你了。",
    ],
  },
};

/** 界面文案 */
export const UI_TEXT: Record<string, string> = {
  title: "衍月·八相",
  subtitle: "第八相之前，把他救回来",
  moveHint: "移动 A/D　跳跃 Space（二段跳）",
  attackHint: "攻击 J　剑气 K　闪身 Shift　碰墙自动吸附",
  wheelHint: "月相轮 Q（检查点处使用）",
  notebookHint: "引月札 N　调查 E　暂停 Esc",
  objectivePrefix: "目标",
  lifeLabel: "生命",
  intentLabel: "剑意",
  trustLabel: "沈砚信任",
  phaseLabel: "当前月相",
  loopLabel: "回溯次数",
  continueHint: "按任意键继续",
  skipHint: "按 J 跳过序章",
  retryHint: "按 R 从检查点重来",
};

/** 八相月名 */
export const PHASE_NAMES: string[] = [
  "新月",
  "蛾眉月",
  "上弦月",
  "盈凸月",
  "满月",
  "亏凸月",
  "下弦月",
  "残月",
];

/** 引月札可记录的记忆条目（与各 StoryNode 的 memory 一致） */
export const MEMORIES_LIST: string[] = [
  "我提起了幼时的约定",
  "观测者承认了循环",
  "我替他挡下了那支箭",
];
