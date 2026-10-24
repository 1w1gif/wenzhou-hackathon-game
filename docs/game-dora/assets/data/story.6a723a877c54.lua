-- [ts]: story.ts
local ____exports = {} -- 1
--- 序章字幕：依次显示，hold 为停留秒数（总长约 24s，与 scenes/intro.ts 时间轴同步）
____exports.PROLOGUE_SUBTITLES = { -- 8
	{text = "那一夜，满月如盘。他死在我面前。", hold = 4}, -- 9
	{text = "我这一剑，斩得断强盗，斩不断天意。", hold = 4}, -- 10
	{text = "月亮把时间还给了我——以八相为约，满月为限。", hold = 4.2}, -- 11
	{text = "代价是，我的性命。每回溯一次，折损一分。", hold = 4.2}, -- 12
	{text = "而他忘记了我。连那枚糖人的约定，也一并忘了。", hold = 3.8}, -- 13
	{text = "没关系。这一次，换我用剑，护你周全。", hold = 3.8} -- 14
} -- 14
--- 周目之问：结局判定用的关键台词
____exports.WHO_ARE_YOU_LINE = "你是谁？" -- 18
local RIVERSIDE_CHOICES = {{text = "路过。看看月亮。", trust = 1, replies = {{speaker = "沈砚", text = "月亮天天有，有什么可看的。"}, {speaker = "沈砚", text = "……也罢。夜里路杂，姑娘保重。"}}}, {text = "旧年中秋，有人在塔上欠我一枚糖人。", trust = 2, memory = "我提起了幼时的约定", replies = {{speaker = "沈砚", text = "塔上……你怎么知道此事？"}, {speaker = "沈砚", text = "那年我确实在观星台放过一只纸鸢，糖人……是给一个总爱哭鼻子的小姑娘买的。"}, {speaker = "衍月（内心）", text = "是我。小姑娘没有哭鼻子，她只是舍不得你走。"}, {speaker = "沈砚", text = "可惜，想不起来了。近年旧事，像隔着一层水。"}}}} -- 20
local OBSERVER1_CHOICES = {{text = ____exports.WHO_ARE_YOU_LINE, trust = 0, replies = {{speaker = "观测者", text = "一个看月亮的人。月亮转，我看；月亮停——"}, {speaker = "观测者", text = "我也该走了。"}}}, {text = "我能救他吗？", trust = 1, memory = "观测者承认了循环", replies = {{speaker = "观测者", text = "救，这个字，你用了{loops}次。"}, {speaker = "观测者", text = "第七次你也是这么问的。我的回答没变——"}, {speaker = "观测者", text = "别用剑问他『你是谁』。用他记得的东西。"}}}} -- 42
local ARROW_CHOICES = {{text = "（挡下）小心！", trust = 2, memory = "我替他挡下了那支箭", replies = {{speaker = "（旁白）", text = "箭矢擦过你的小臂，钉进廊柱。"}, {speaker = "沈砚", text = "……多谢。你到底是——罢了。"}, {speaker = "沈砚", text = "（他看着你臂上的血，欲言又止）你的伤……自己当心。"}, {speaker = "衍月（内心）", text = "这一箭，上一世我没能挡下。他替我挡的。"}}}, {text = "（不挡）", trust = 0, replies = {{speaker = "（旁白）", text = "箭矢钉在他身侧的廊柱上，去势犹自颤动。"}, {speaker = "沈砚", text = "……哼，不必假惺惺。"}, {speaker = "沈砚", text = "（他却退了半步，站到了你侧前方。）"}, {speaker = "衍月（内心）", text = "嘴上这么说，身体倒诚实。"}}}} -- 63
--- 剧情节点：storyId → 节点。选项分支应答写在所选 DialogChoice.replies，确认后插入队列播放。
____exports.STORY_NODES = { -- 88
	story_check_intro = {id = "story_check_intro", lines = {{speaker = "衍月（内心）", text = "潮声还是旧时的潮声。"}, {speaker = "衍月（内心）", text = "我回来了——比那夜早了三个时辰。"}, {speaker = "衍月（内心）", text = "这一次，我不会让你死在我面前。"}}, objective = "目标：向东寻找沈砚（J 斩击 · K 月刃）"}, -- 89
	story_riverside = {id = "story_riverside", lines = {{speaker = "沈砚", text = "这位女侠，一路跟着我做什么？"}, {speaker = "衍月（内心）", text = "他看我的眼神……和那夜一样干净。只是不再认得我。"}, {speaker = "沈砚", text = "月亮有什么好看。罢了，姑娘请便。"}, {speaker = "沈砚", text = "……等等。你方才说，糖人？"}}, choices = RIVERSIDE_CHOICES, objective = "目标：击退前方强盗，再经传送门进入古镇街巷"}, -- 99
	story_town = {id = "story_town", lines = {{speaker = "衍月（内心）", text = "山道上已有火光……比上一世更早。"}, {speaker = "衍月（内心）", text = "他们在抢的不是粮。是沈家守的那台『古仪』。"}, {speaker = "沈砚（远处喊）", text = "塔上传讯！让开粮道！"}}, objective = "目标：穿过街巷，抵达悬空工坊"}, -- 111
	story_sneak_hint = {id = "story_sneak_hint", lines = {{speaker = "衍月（内心）", text = "工坊的方向有脚印，很乱。强盗在搬空这里。"}, {speaker = "衍月（内心）", text = "从上方木板绕过去，或正面斩过去——剑快，还是人静，总得选一样。"}}, objective = "目标：通过工坊区（潜行或战斗）"}, -- 121
	story_workshop = {id = "story_workshop", lines = {{speaker = "衍月（内心）", text = "工坊散落着残页……『月相轮』，沈家世代守护的观星古仪。"}, {speaker = "衍月（内心）", text = "上面说：八相轮转，可借月力回溯一时。它在『等』一个满月之夜。"}, {speaker = "衍月（内心）", text = "等到了，它还会『选』一个人。"}, {speaker = "衍月（内心）", text = "上一世，它选中的，是冲进来救我的沈砚。"}}, objective = "目标：经由传送门登上塔外环廊", setFlag = "lore_device"}, -- 130
	story_boss_intro = {id = "story_boss_intro", lines = { -- 142
		{speaker = "劫匪头目", text = "沈家的小郎君，把宝贝看得比命重。"}, -- 145
		{speaker = "劫匪头目", text = "姑娘，识相的把月相轮交出来。主上要的是『相』，不是你们的命。"}, -- 146
		{speaker = "衍月", text = "好啊。拿命来换。"}, -- 147
		{speaker = "沈砚（远处）", text = "休想碰它——！"}, -- 148
		{speaker = "劫匪头目", text = "先砍了这对痴男怨女！"} -- 149
	}, objective = "目标：击败劫匪头目"}, -- 149
	story_observer_1 = { -- 154
		id = "story_observer_1", -- 155
		lines = { -- 156
			{speaker = "观测者", text = "女侠的鞋，磨穿了三双。"}, -- 157
			{speaker = "观测者", text = "路只有一条，你却走了很多遍。我说得可对？"}, -- 158
			{speaker = "衍月（内心）", text = "这个人……身上没有月光的味道。"}, -- 159
			{speaker = "观测者", text = "你不是第一次来这里。只是每一次，只有你记得。"}, -- 160
			{speaker = "观测者", text = "一个记得所有循环的人。剑救不了他。心，未必。"} -- 161
		}, -- 161
		choices = OBSERVER1_CHOICES, -- 163
		objective = "目标：登上观星台", -- 164
		setFlag = "lore_loop" -- 165
	}, -- 165
	story_observer_2 = {id = "story_observer_2", lines = { -- 168
		{speaker = "观测者", text = "残卷翻到第三页了？『装置择人』那一段，读了吗。"}, -- 171
		{speaker = "观测者", text = "它选中的从来不是最强的人，是最执的人。"}, -- 172
		{speaker = "观测者", text = "他如今半人半仪，你每回溯一次，他和装置就缠得越深。"}, -- 173
		{speaker = "观测者", text = "总有一天，塔里走出来的那个，你要认不出才行——认不出，才下得去手。"}, -- 174
		{speaker = "衍月（内心）", text = "下不去手。所以，别走到那一步。"} -- 175
	}, setFlag = "lore_choose"}, -- 175
	story_arrow = {id = "story_arrow", lines = {{speaker = "沈砚", text = "又是你。为何总阴魂不散——"}, {speaker = "！！", text = "一支冷箭破空而来！（按 E 替他挡下）"}}, choices = ARROW_CHOICES}, -- 180
	story_final = {id = "story_final", lines = { -- 189
		{speaker = "沈砚", text = "站住。今夜的月，轮不到你染指。"}, -- 192
		{speaker = "衍月", text = "砚哥哥。是我。"}, -- 193
		{speaker = "沈砚", text = "衍月？……不。衍月早死在三个月前的山道上了。"}, -- 194
		{speaker = "沈砚", text = "她死的时候，手里还攀着我给的糖人。"}, -- 195
		{speaker = "沈砚", text = "你这妖女，休想再骗我。"}, -- 196
		{speaker = "衍月（内心）", text = "他的眼睛里……只剩装置的反光。金色的，一圈一圈，像走马灯。"}, -- 197
		{speaker = "沈砚", text = "装置是沈家的使命。要关它——先从我尸体上踏过去。"}, -- 198
		{speaker = "衍月（内心）", text = "剑，放还是不放。这一相，由我写。"} -- 199
	}, objective = ""} -- 199
} -- 199
--- 结局文案：键为结局 id
____exports.ENDINGS = {reunion = {id = "reunion", title = "终之相·望", lines = { -- 206
	"她卸了剑。任他的刀落在肩头，也不还手。", -- 211
	"旧信物散落一地——糖人的油纸、断掉的纸鸢线、一枚褪色的平安结。", -- 212
	"沈砚的执念在旧物面前碎裂。装置的封印，随他的迟疑松开了。", -- 213
	"她抓住空隙，合上了月相轮。", -- 214
	"沈砚：「……小姑娘，没哭鼻子。」", -- 215
	"沈砚：「是我。这一次，换我记住了。」", -- 216
	"（塔底深处，星盘上有一枚本不该存在的刻度，正缓缓亮起。）" -- 217
}}, sacrifice = {id = "sacrifice", title = "终之相·晦", lines = { -- 217
	"她转动月相轮，把最后一缕生命投入装置。", -- 224
	"月光漫过她的身影，像墨迹没入水中。", -- 225
	"装置停了。沈砚活了下来，手中只留下一枚刻着八相的暗金圆盘。", -- 226
	"沈砚：「姑娘……你是谁。」", -- 227
	"他活下来了。只是这一次，换我没有留下。", -- 228
	"（月亮异常明亮。塔中深处，传来一声轻轻的转动声。）" -- 229
}}, blade = {id = "blade", title = "终之相·残", lines = { -- 229
	"剑赢了。", -- 236
	"他倒下时，喃喃的还是那三个字——你是谁。", -- 237
	"装置关上了。他活了下来，只是永远不会再想起她。", -- 238
	"我的剑赢得了对峙，却输掉了他。", -- 239
	"（她收剑入鞘，独自走下塔去。身后再没有钟声。）" -- 240
}}, exhausted = {id = "exhausted", title = "月相停转", lines = {"月相轮再也转不动了。", "时间停在满月升顶的一瞬。", "塔顶传来第二声钟鸣。", "月亮再也不会把时间还给你了。"}}} -- 240
--- 界面文案
____exports.UI_TEXT = { -- 256
	title = "衍月·八相", -- 257
	subtitle = "第八相之前，把她救回来", -- 258
	moveHint = "移动 A/D　跳跃 Space（二段跳）", -- 259
	attackHint = "攻击 J　剑气 K　闪身 Shift　碰墙自动吸附", -- 260
	wheelHint = "月相轮 Q（检查点处使用）", -- 261
	notebookHint = "引月札 N　调查 E　暂停 Esc", -- 262
	objectivePrefix = "目标", -- 263
	lifeLabel = "生命", -- 264
	intentLabel = "剑意", -- 265
	trustLabel = "沈砚信任", -- 266
	phaseLabel = "当前月相", -- 267
	loopLabel = "回溯次数", -- 268
	continueHint = "按任意键继续", -- 269
	skipHint = "按 J 跳过序章", -- 270
	retryHint = "按 R 从检查点重来" -- 271
} -- 271
--- 八相月名
____exports.PHASE_NAMES = { -- 275
	"新月", -- 276
	"蛾眉月", -- 277
	"上弦月", -- 278
	"盈凸月", -- 279
	"满月", -- 280
	"亏凸月", -- 281
	"下弦月", -- 282
	"残月" -- 283
} -- 283
--- 引月札可记录的记忆条目（与各 StoryNode 的 memory 一致）
____exports.MEMORIES_LIST = {"我提起了幼时的约定", "观测者承认了循环", "我替他挡下了那支箭"} -- 287
return ____exports -- 287