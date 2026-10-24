-- [ts]: notebook.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Sprite = ____Dora.Sprite -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local ____palette = require("core.palette") -- 3
local Palette = ____palette.Palette -- 3
local ink = ____palette.ink -- 3
local ____story = require("data.story") -- 5
local MEMORIES_LIST = ____story.MEMORIES_LIST -- 5
local PHASE_NAMES = ____story.PHASE_NAMES -- 5
local Tower = require("data.tower") -- 6
local FONT = "sarasa-mono-sc-regular" -- 8
local function col(c) -- 10
	return Color(c.r, c.g, c.b, c.a) -- 10
end -- 10
local function makeLabel(parent, size, x, y, ax, ay, color) -- 12
	local lb = Label(FONT, size) -- 13
	if lb == nil then -- 13
		return nil -- 15
	end -- 15
	lb.anchor = Vec2(ax, ay) -- 17
	lb.position = Vec2(x, y) -- 18
	lb.color = Color(color.r, color.g, color.b, color.a) -- 19
	lb:addTo(parent) -- 20
	return lb -- 21
end -- 12
local function setText(lb, text) -- 24
	if lb ~= nil and lb.text ~= text then -- 24
		lb.text = text -- 26
	end -- 26
end -- 24
____exports.NotebookUI = __TS__Class() -- 30
local NotebookUI = ____exports.NotebookUI -- 30
NotebookUI.name = "NotebookUI" -- 30
function NotebookUI.prototype.____constructor(self, parent) -- 45
	self.memoryLbs = {} -- 46
	self.causeLbs = {} -- 47
	self.openFlag = false -- 48
	self.root = Node() -- 49
	self.root:addTo(parent) -- 50
	self.root.visible = false -- 51
	self.draw = DrawNode() -- 52
	self.draw:addTo(self.root) -- 53
	local title = makeLabel( -- 55
		self.root, -- 55
		34, -- 55
		0, -- 55
		186, -- 55
		0.5, -- 55
		0.5, -- 55
		Palette.inkDark -- 55
	) -- 55
	setText(title, "引月札") -- 56
	local h1 = makeLabel( -- 57
		self.root, -- 57
		20, -- 57
		-392, -- 57
		138, -- 57
		0, -- 57
		0.5, -- 57
		Palette.gold -- 57
	) -- 57
	setText(h1, "周目") -- 58
	local h2 = makeLabel( -- 59
		self.root, -- 59
		20, -- 59
		-132, -- 59
		138, -- 59
		0, -- 59
		0.5, -- 59
		Palette.gold -- 59
	) -- 59
	setText(h2, "收藏") -- 60
	local h3 = makeLabel( -- 61
		self.root, -- 61
		20, -- 61
		88, -- 61
		138, -- 61
		0, -- 61
		0.5, -- 61
		Palette.gold -- 61
	) -- 61
	setText(h3, "记忆") -- 62
	self.loopLb = makeLabel( -- 64
		self.root, -- 64
		19, -- 64
		-392, -- 64
		92, -- 64
		0, -- 64
		0.5, -- 64
		Palette.inkSoft -- 64
	) -- 64
	self.phaseLb = makeLabel( -- 65
		self.root, -- 65
		19, -- 65
		-392, -- 65
		56, -- 65
		0, -- 65
		0.5, -- 65
		Palette.inkSoft -- 65
	) -- 65
	self.checkLb = makeLabel( -- 66
		self.root, -- 66
		19, -- 66
		-392, -- 66
		20, -- 66
		0, -- 66
		0.5, -- 66
		Palette.inkSoft -- 66
	) -- 66
	self.stoneLb = makeLabel( -- 67
		self.root, -- 67
		19, -- 67
		-96, -- 67
		92, -- 67
		0, -- 67
		0.5, -- 67
		Palette.inkSoft -- 67
	) -- 67
	self.tokenLb = makeLabel( -- 68
		self.root, -- 68
		19, -- 68
		-96, -- 68
		56, -- 68
		0, -- 68
		0.5, -- 68
		Palette.inkSoft -- 68
	) -- 68
	local h4 = makeLabel( -- 70
		self.root, -- 70
		20, -- 70
		-392, -- 70
		-16, -- 70
		0, -- 70
		0.5, -- 70
		Palette.gold -- 70
	) -- 70
	setText(h4, "因果") -- 71
	do -- 71
		local i = 0 -- 72
		while i < 4 do -- 72
			local lb = makeLabel( -- 73
				self.root, -- 73
				16, -- 73
				-392, -- 73
				-48 - i * 28, -- 73
				0, -- 73
				0.5, -- 73
				Palette.inkSoft -- 73
			) -- 73
			if lb ~= nil then -- 73
				local ____self_causeLbs_0 = self.causeLbs -- 73
				____self_causeLbs_0[#____self_causeLbs_0 + 1] = lb -- 75
			end -- 75
			i = i + 1 -- 72
		end -- 72
	end -- 72
	do -- 72
		local i = 0 -- 78
		while i < #MEMORIES_LIST do -- 78
			local lb = makeLabel( -- 79
				self.root, -- 79
				19, -- 79
				118, -- 79
				92 - i * 36, -- 79
				0, -- 79
				0.5, -- 79
				Palette.inkSoft -- 79
			) -- 79
			if lb ~= nil then -- 79
				local ____self_memoryLbs_1 = self.memoryLbs -- 79
				____self_memoryLbs_1[#____self_memoryLbs_1 + 1] = lb -- 81
			end -- 81
			i = i + 1 -- 78
		end -- 78
	end -- 78
	local footer = makeLabel( -- 84
		self.root, -- 84
		16, -- 84
		0, -- 84
		-224, -- 84
		0.5, -- 84
		0.5, -- 84
		Palette.paleInk -- 84
	) -- 84
	setText(footer, "Tab 关闭") -- 85
	self.iconMoon = self:makeIcon("assets/tiles/moon_stone.png", -116, 92, 26) -- 87
	self.iconToken = self:makeIcon("assets/props/e7_shard.png", -116, 56, 26) -- 88
end -- 45
function NotebookUI.prototype.makeIcon(self, path, x, y, h) -- 92
	local tex = Texture2D(path) -- 93
	if tex == nil then -- 93
		return nil -- 95
	end -- 95
	local sp = Sprite(tex) -- 97
	if sp == nil then -- 97
		return nil -- 99
	end -- 99
	sp.scaleX = h / tex.height -- 101
	sp.scaleY = h / tex.height -- 102
	sp.position = Vec2(x, y) -- 103
	sp:addTo(self.root) -- 104
	return sp -- 105
end -- 92
function NotebookUI.prototype.debugIconCount(self) -- 109
	local n = 0 -- 110
	if self.iconMoon ~= nil then -- 110
		n = n + 1 -- 112
	end -- 112
	if self.iconToken ~= nil then -- 112
		n = n + 1 -- 115
	end -- 115
	return n -- 117
end -- 109
function NotebookUI.prototype.toggle(self) -- 120
	self.openFlag = not self.openFlag -- 121
	self.root.visible = self.openFlag -- 122
end -- 120
function NotebookUI.prototype.isOpen(self) -- 125
	return self.openFlag -- 126
end -- 125
function NotebookUI.prototype.update(self, _dt, state) -- 129
	if not self.openFlag then -- 129
		return -- 131
	end -- 131
	local w = View.size.width -- 133
	local h = View.size.height -- 134
	self.draw:clear() -- 135
	self.draw:drawPolygon( -- 137
		{ -- 138
			Vec2(-440, -250), -- 138
			Vec2(440, -250), -- 138
			Vec2(440, 250), -- 138
			Vec2(-440, 250) -- 138
		}, -- 138
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), -- 139
		2, -- 139
		col(Palette.inkDark) -- 139
	) -- 139
	self.draw:drawPolygon( -- 141
		{ -- 142
			Vec2(-428, -238), -- 142
			Vec2(428, -238), -- 142
			Vec2(428, 238), -- 142
			Vec2(-428, 238) -- 142
		}, -- 142
		col(ink(0, 0, 0, 0)), -- 143
		1, -- 143
		col(Palette.goldSoft) -- 143
	) -- 143
	self.draw:drawSegment( -- 145
		Vec2(-172, -210), -- 145
		Vec2(-172, 190), -- 145
		1, -- 145
		col(Palette.inkFaint) -- 145
	) -- 145
	self.draw:drawSegment( -- 146
		Vec2(48, -210), -- 146
		Vec2(48, 190), -- 146
		1, -- 146
		col(Palette.inkFaint) -- 146
	) -- 146
	local phaseName = state.phaseIndex >= 0 and state.phaseIndex < #PHASE_NAMES and PHASE_NAMES[state.phaseIndex + 1] or "" -- 148
	setText( -- 149
		self.loopLb, -- 149
		("第" .. tostring(state.loopIndex + 1)) .. "周目" -- 149
	) -- 149
	setText(self.phaseLb, "当前月相：" .. phaseName) -- 150
	local checkpointName = "未记录" -- 152
	do -- 152
		local i = 0 -- 153
		while i < #Tower.checkpoints do -- 153
			if Tower.checkpoints[i + 1].id == state.currentCheckpointId then -- 153
				checkpointName = Tower.checkpoints[i + 1].label -- 155
				break -- 156
			end -- 156
			i = i + 1 -- 153
		end -- 153
	end -- 153
	setText(self.checkLb, "检查点：" .. checkpointName) -- 159
	setText( -- 161
		self.stoneLb, -- 161
		"月石　x " .. tostring(state.moonstones) -- 161
	) -- 161
	setText( -- 162
		self.tokenLb, -- 162
		"旧物　x " .. tostring(state.tokens) -- 162
	) -- 162
	local total = #state.causalityLog -- 164
	local start = math.max(0, total - #self.causeLbs) -- 165
	do -- 165
		local i = 0 -- 166
		while i < #self.causeLbs do -- 166
			local idx = start + i -- 167
			if idx < total then -- 167
				setText( -- 169
					self.causeLbs[i + 1], -- 169
					(tostring(idx + 1) .. ". ") .. state.causalityLog[idx + 1] -- 169
				) -- 169
				self.causeLbs[i + 1].color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, Palette.inkSoft.a) -- 170
			else -- 170
				setText(self.causeLbs[i + 1], "") -- 172
			end -- 172
			i = i + 1 -- 166
		end -- 166
	end -- 166
	if self.iconMoon == nil then -- 166
		self.draw:drawDot( -- 177
			Vec2(-116, 92), -- 177
			7, -- 177
			col(Palette.moonCyan) -- 177
		) -- 177
		self.draw:drawDot( -- 178
			Vec2(-116, 92), -- 178
			10, -- 178
			col(Palette.moonCyanFaint) -- 178
		) -- 178
	end -- 178
	if self.iconToken == nil then -- 178
		self.draw:drawPolygon( -- 181
			{ -- 181
				Vec2(-116, 62), -- 181
				Vec2(-108, 56), -- 181
				Vec2(-116, 50), -- 181
				Vec2(-124, 56) -- 181
			}, -- 181
			col(Palette.vermilion) -- 181
		) -- 181
	end -- 181
	do -- 181
		local i = 0 -- 184
		while i < #self.memoryLbs do -- 184
			local known = i < #MEMORIES_LIST and __TS__ArrayIndexOf(state.memories, MEMORIES_LIST[i + 1]) >= 0 -- 185
			local y = 92 - i * 36 -- 186
			if known then -- 186
				self.draw:drawDot( -- 188
					Vec2(102, y), -- 188
					5, -- 188
					col(Palette.inkDark) -- 188
				) -- 188
				setText(self.memoryLbs[i + 1], MEMORIES_LIST[i + 1]) -- 189
				self.memoryLbs[i + 1].color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, Palette.inkSoft.a) -- 190
			else -- 190
				self.draw:drawPolygon( -- 192
					{ -- 192
						Vec2(102, y + 6), -- 192
						Vec2(108, y), -- 192
						Vec2(102, y - 6), -- 192
						Vec2(96, y) -- 192
					}, -- 192
					col(ink(0, 0, 0, 0)), -- 192
					1, -- 192
					col(Palette.inkFaint) -- 192
				) -- 192
				setText(self.memoryLbs[i + 1], "？") -- 193
				self.memoryLbs[i + 1].color = Color(Palette.paleInkFar.r, Palette.paleInkFar.g, Palette.paleInkFar.b, Palette.paleInkFar.a) -- 194
			end -- 194
			i = i + 1 -- 184
		end -- 184
	end -- 184
end -- 129
return ____exports -- 129