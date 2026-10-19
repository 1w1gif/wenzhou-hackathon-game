/**
 * 剧本数据:八条世界线 × 一个共通分歧点 × 跨时空解谜链。
 * 世界观:「枕水镇」,八月十五夜,谢郎在祭月台上消失。
 * 衍月穿越八相寻找真相 —— 熟悉的人,陌生的命运。
 */

export type WorldId =
  | '朔' | '峨眉' | '弦' | '盈凸'
  | '望' | '亏凸' | '下弦' | '残';

export interface ClueDef {
  id: string;
  name: string;
  text: string;
}

/** 世界线基础设定 */
export interface WorldDef {
  id: WorldId;
  title: string;
  /** 一句话氛围 */
  tagline: string;
  /** 谢郎在此线的身份 */
  xieRole: string;
  /** 此线的环境谜题(见 TownScene 谜题实现) */
  puzzle: 'lantern' | 'well' | 'bridge' | 'bell' | 'shrine' | 'boat' | 'kite' | 'mirror';
}

export const WORLDS: Record<WorldId, WorldDef> = {
  '朔':   { id: '朔',   title: '朔 · 无光之夜', tagline: '月亮缺席的夜晚,镇上无人记得祭月。', xieRole: '更夫', puzzle: 'lantern' },
  '峨眉': { id: '峨眉', title: '峨眉 · 初见之宵', tagline: '一切尚未开始,戏台上的灯才刚点亮。',   xieRole: '戏班学徒', puzzle: 'well' },
  '弦':   { id: '弦',   title: '弦 · 悬而未决', tagline: '断桥横在河上,谁也没能走到对岸。',      xieRole: '摆渡人', puzzle: 'bridge' },
  '盈凸': { id: '盈凸', title: '盈凸 · 将满之市', tagline: '市集喧闹,灯火比人声更亮。',           xieRole: '灯匠', puzzle: 'bell' },
  '望':   { id: '望',   title: '望 · 团圆之夜', tagline: '满月如盘,祭月台上空无一人。',          xieRole: '祭官', puzzle: 'shrine' },
  '亏凸': { id: '亏凸', title: '亏凸 · 离别之渡', tagline: '渡口的老船夫说,有些人一去不回。',      xieRole: '行商', puzzle: 'boat' },
  '下弦': { id: '下弦', title: '下弦 · 半面之镜', tagline: '镜中只映出半张脸,另一半留在别处。',    xieRole: '画师', puzzle: 'mirror' },
  '残':   { id: '残',   title: '残 · 将尽之秋', tagline: '风很凉,雁声比人声多。',               xieRole: '教书先生', puzzle: 'kite' },
};

/** 谜题线索:跨时空引月札收集品 */
export const CLUES: Record<string, ClueDef> = {
  'clue_light': {
    id: 'clue_light',
    name: '无焰之焰',
    text: '朔世界里熄灭的灯,在别的世界仍记得燃烧的方式。你把「灯该有的样子」描进了引月札。',
  },
  'clue_name': {
    id: 'clue_name',
    name: '被遗忘的名字',
    text: '井底回声念出一个名字:「谢郎」。可此界本无此人——名字先于人存在。',
  },
  'clue_bridge': {
    id: 'clue_bridge',
    name: '未走完的桥',
    text: '断桥的第二段并不缺,它只是在另一条世界线上。桥是「同时存在于两处」的东西。',
  },
  'clue_bell': {
    id: 'clue_bell',
    name: '无人听过的钟声',
    text: '钟不敲自鸣,只对听得懂的人响。你在札上记下:声音可以跨过时空的缝。',
  },
  'clue_shrine': {
    id: 'clue_shrine',
    name: '祭文的空行',
    text: '祭文在「谢郎」二字处断了墨。祭官说:名字被写进祭文的人,会从所有世界里被同时唤走。',
  },
  'clue_boat': {
    id: 'clue_boat',
    name: '渡口的回执',
    text: '老船夫递来一张旧船票,背面写着:去程已用,回程未用。票根是月白色的。',
  },
  'clue_mirror': {
    id: 'clue_mirror',
    name: '半面之镜',
    text: '镜中的半张脸属于谢郎。他在这条线上成了画师,画里全是同一个背影:一个提灯的女子。',
  },
  'clue_kite': {
    id: 'clue_kite',
    name: '未寄出的雁书',
    text: '风筝上系着信,落款是谢郎。信只有一句:「去找满月的祭台,我在所有线的那一头等你。」',
  },
};

/** 每个世界的谜题解法(跨世界组合) */
export interface PuzzleDef {
  /** 需要哪些线索才可解 */
  needs: string[];
  /** 解开后的对话/叙述 */
  solveText: string;
  /** 奖励线索 */
  gives: string;
  /** 奖励线索的获得文案 */
  gainText: string;
}

export const PUZZLES: Record<WorldId, PuzzleDef> = {
  '朔': {
    needs: [],
    solveText: '灯楼的主灯熄了。守灯的更夫说:「没有火种,这夜就永远不亮。」你伸手进灯罩,以自己的影子引燃了灯芯。',
    gives: 'clue_light',
    gainText: '灯亮起的一瞬,你看见灯罩内壁刻着一行小字:八灯同燃,月路自明。',
  },
  '峨眉': {
    needs: ['clue_light'],
    solveText: '戏台后的古井回声怪异。你把引月札凑近井口,念出灯罩上的刻字——井底竟应和了一声「月路自明」。',
    gives: 'clue_name',
    gainText: '回声又低低念了个名字:「谢郎」。此界本无此人,你却心头一紧——名字先于人存在。',
  },
  '弦': {
    needs: ['clue_name'],
    solveText: '断桥无板。你对着河面念出「谢郎」,对岸竟有人影应声而立——桥的第二段在对岸的世界里,踏影而过。',
    gives: 'clue_bridge',
    gainText: '过桥时你明白了:断掉的东西没有消失,只是留在另一条线上。',
  },
  '盈凸': {
    needs: ['clue_bridge'],
    solveText: '市集尽头悬着一口哑钟。你以札为槌轻叩,钟声却不在耳边——而在很远的地方同时响起。',
    gives: 'clue_bell',
    gainText: '钟内壁有刻痕:凡钟声所及,皆是月路。声音,也能跨过时空的缝。',
  },
  '望': {
    needs: ['clue_bell', 'clue_mirror'],
    solveText: '祭月台上香火冷清。祭官展开祭文,你在「谢郎」二字处看见了断墨。钟声恰在此时自远处应和,祭文的空行里浮出字来。',
    gives: 'clue_shrine',
    gainText: '祭官低声道:「名字被写进祭文的人,会从所有世界里被同时唤走。姑娘,你要找的人不在一条线上——在所有线上。」',
  },
  '亏凸': {
    needs: ['clue_shrine'],
    solveText: '渡口老船夫看了看你,又看了看月亮,从船板下摸出一张月白色船票:「去程有人用了。回程,一直没人来取。」',
    gives: 'clue_boat',
    gainText: '票根背面写着:此票通八相。你把船票夹进引月札——回程未用,意味着他还回得来。',
  },
  '下弦': {
    needs: ['clue_light', 'clue_name'],
    solveText: '画师的画室里挂满同一幅背影:提灯的女子。你认出那是自己。画师背对着你,声音很轻:「每个世界我都在画,画里的人都去祭月台。」',
    gives: 'clue_mirror',
    gainText: '他递来半面铜镜:「镜里那半张脸,是我的。若你找到满月的祭台,替我把它拼上。」',
  },
  '残': {
    needs: ['clue_boat', 'clue_mirror'],
    solveText: '先生放下一只风筝,线轴自己转动。风筝坠地,信摊开:「去找满月的祭台,我在所有线的那一头等你。」',
    gives: 'clue_kite',
    gainText: '末尾还有一行小字,墨迹很新:「别选最多的那个世界。选你还敢回头的那个。」',
  },
};

/** 分歧点:每个世界的最终抉择(回到月相轮前必须选择) */
export interface ChoiceOption {
  id: string;
  text: string;
  /** 该选项导致穿越去的世界 */
  toPhase: WorldId;
  /** 选择叙述(用于树边) */
  summary: string;
}

export const DIVERGENCE_PROMPT = '祭月台的钟声响起。这一夜将尽,而你的选择将把世界推向另一条线——';

/**
 * 每个世界提供两个分歧选项。选项的目标世界 = 该世界月相 ±1。
 * 这样时空树自然长成一棵二叉月相链,且玩家可以用选择「移动」月相。
 */
export function choicesFor(world: WorldId): ChoiceOption[] {
  const order: WorldId[] = ['朔', '峨眉', '弦', '盈凸', '望', '亏凸', '下弦', '残'];
  const i = order.indexOf(world);
  const prev = order[(i + 7) % 8];
  const next = order[(i + 1) % 8];
  return [
    {
      id: 'waning',
      text: `让灯影淡去,往「${prev}」的世界去`,
      toPhase: prev,
      summary: `向月缺处走,离开「${world}」`,
    },
    {
      id: 'waxing',
      text: `追着光走,往「${next}」的世界去`,
      toPhase: next,
      summary: `向月盈处走,离开「${world}」`,
    },
  ];
}

/** 结局判定 */
export const FINALE_REQUIREMENT = ['clue_shrine', 'clue_boat', 'clue_kite'] as const;

export const ENDINGS = {
  union: {
    id: 'union',
    title: '终章 · 八月同天',
    text: '你把引月札摊开在满月祭台上,八条世界线的灯火自书页间亮起。钟声自八处同时响起,断墨的名字被八种笔迹一同补全。\n\n谢郎自祭文里走出来,半面铜镜在你掌心拼成了圆。他说:「我数过了,每一条线你都会来找我。」\n\n「可你只需要来一次。」你答。',
  },
  alone: {
    id: 'alone',
    title: '终章 · 一人满月',
    text: '你合上引月札。八条线的灯依次熄灭,只剩你脚下这一条亮着。\n\n祭台上空无一人,但风里有八重钟声的余韵。你终于明白:他不是不在,他是在每一条你没有选的线上,替你记着这一夜。\n\n月亮很圆。你把他的名字,写进了只属于你的祭文。',
  },
  locked: {
    id: 'locked',
    title: '线索未足',
    text: '祭台沉默着。你还缺少关键的东西——有些真相,散落在你尚未走过的世界里。(需要线索:祭文的空行、渡口的回执、未寄出的雁书)',
  },
};
