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
function NotebookUI.prototype.____constructor(self, parent) -- 47
	self.memoryLbs = {} -- 48
	self.causeLbs = {} -- 49
	self.openFlag = false -- 50
	self.root = Node() -- 51
	self.root:addTo(parent) -- 52
	self.root.visible = false -- 53
	self.draw = DrawNode() -- 54
	self.draw:addTo(self.root) -- 55
	local title = makeLabel( -- 57
		self.root, -- 57
		34, -- 57
		0, -- 57
		186, -- 57
		0.5, -- 57
		0.5, -- 57
		Palette.inkDark -- 57
	) -- 57
	setText(title, "引月札") -- 58
	local h1 = makeLabel( -- 59
		self.root, -- 59
		20, -- 59
		-392, -- 59
		138, -- 59
		0, -- 59
		0.5, -- 59
		Palette.gold -- 59
	) -- 59
	setText(h1, "周目") -- 60
	local h2 = makeLabel( -- 61
		self.root, -- 61
		20, -- 61
		-132, -- 61
		138, -- 61
		0, -- 61
		0.5, -- 61
		Palette.gold -- 61
	) -- 61
	setText(h2, "收藏") -- 62
	local h3 = makeLabel( -- 63
		self.root, -- 63
		20, -- 63
		88, -- 63
		138, -- 63
		0, -- 63
		0.5, -- 63
		Palette.gold -- 63
	) -- 63
	setText(h3, "记忆") -- 64
	self.loopLb = makeLabel( -- 66
		self.root, -- 66
		19, -- 66
		-392, -- 66
		92, -- 66
		0, -- 66
		0.5, -- 66
		Palette.inkSoft -- 66
	) -- 66
	self.phaseLb = makeLabel( -- 67
		self.root, -- 67
		19, -- 67
		-392, -- 67
		56, -- 67
		0, -- 67
		0.5, -- 67
		Palette.inkSoft -- 67
	) -- 67
	self.checkLb = makeLabel( -- 68
		self.root, -- 68
		19, -- 68
		-392, -- 68
		20, -- 68
		0, -- 68
		0.5, -- 68
		Palette.inkSoft -- 68
	) -- 68
	self.stoneLb = makeLabel( -- 69
		self.root, -- 69
		19, -- 69
		-96, -- 69
		92, -- 69
		0, -- 69
		0.5, -- 69
		Palette.inkSoft -- 69
	) -- 69
	self.mechLb = makeLabel( -- 70
		self.root, -- 70
		19, -- 70
		-96, -- 70
		56, -- 70
		0, -- 70
		0.5, -- 70
		Palette.inkSoft -- 70
	) -- 70
	self.tokenLb = makeLabel( -- 71
		self.root, -- 71
		19, -- 71
		-96, -- 71
		20, -- 71
		0, -- 71
		0.5, -- 71
		Palette.inkSoft -- 71
	) -- 71
	local h4 = makeLabel( -- 73
		self.root, -- 73
		20, -- 73
		-392, -- 73
		-16, -- 73
		0, -- 73
		0.5, -- 73
		Palette.gold -- 73
	) -- 73
	setText(h4, "因果") -- 74
	do -- 74
		local i = 0 -- 75
		while i < 4 do -- 75
			local lb = makeLabel( -- 76
				self.root, -- 76
				16, -- 76
				-392, -- 76
				-48 - i * 28, -- 76
				0, -- 76
				0.5, -- 76
				Palette.inkSoft -- 76
			) -- 76
			if lb ~= nil then -- 76
				local ____self_causeLbs_0 = self.causeLbs -- 76
				____self_causeLbs_0[#____self_causeLbs_0 + 1] = lb -- 78
			end -- 78
			i = i + 1 -- 75
		end -- 75
	end -- 75
	do -- 75
		local i = 0 -- 81
		while i < #MEMORIES_LIST do -- 81
			local lb = makeLabel( -- 82
				self.root, -- 82
				19, -- 82
				118, -- 82
				92 - i * 36, -- 82
				0, -- 82
				0.5, -- 82
				Palette.inkSoft -- 82
			) -- 82
			if lb ~= nil then -- 82
				local ____self_memoryLbs_1 = self.memoryLbs -- 82
				____self_memoryLbs_1[#____self_memoryLbs_1 + 1] = lb -- 84
			end -- 84
			i = i + 1 -- 81
		end -- 81
	end -- 81
	local footer = makeLabel( -- 87
		self.root, -- 87
		16, -- 87
		0, -- 87
		-224, -- 87
		0.5, -- 87
		0.5, -- 87
		Palette.paleInk -- 87
	) -- 87
	setText(footer, "Tab 关闭") -- 88
	self.iconMoon = self:makeIcon("assets/tiles/moon_stone.png", -116, 92, 26) -- 90
	self.iconMech = self:makeIcon("assets/tiles/push_stone.png", -116, 56, 26) -- 91
	self.iconToken = self:makeIcon("assets/props/e7_shard.png", -116, 20, 26) -- 92
end -- 47
function NotebookUI.prototype.makeIcon(self, path, x, y, h) -- 96
	local tex = Texture2D(path) -- 97
	if tex == nil then -- 97
		return nil -- 99
	end -- 99
	local sp = Sprite(tex) -- 101
	if sp == nil then -- 101
		return nil -- 103
	end -- 103
	sp.scaleX = h / tex.height -- 105
	sp.scaleY = h / tex.height -- 106
	sp.position = Vec2(x, y) -- 107
	sp:addTo(self.root) -- 108
	return sp -- 109
end -- 96
function NotebookUI.prototype.debugIconCount(self) -- 113
	local n = 0 -- 114
	if self.iconMoon ~= nil then -- 114
		n = n + 1 -- 116
	end -- 116
	if self.iconMech ~= nil then -- 116
		n = n + 1 -- 119
	end -- 119
	if self.iconToken ~= nil then -- 119
		n = n + 1 -- 122
	end -- 122
	return n -- 124
end -- 113
function NotebookUI.prototype.toggle(self) -- 127
	self.openFlag = not self.openFlag -- 128
	self.root.visible = self.openFlag -- 129
end -- 127
function NotebookUI.prototype.isOpen(self) -- 132
	return self.openFlag -- 133
end -- 132
function NotebookUI.prototype.update(self, _dt, state) -- 136
	if not self.openFlag then -- 136
		return -- 138
	end -- 138
	local w = View.size.width -- 140
	local h = View.size.height -- 141
	self.draw:clear() -- 142
	self.draw:drawPolygon( -- 144
		{ -- 145
			Vec2(-440, -250), -- 145
			Vec2(440, -250), -- 145
			Vec2(440, 250), -- 145
			Vec2(-440, 250) -- 145
		}, -- 145
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), -- 146
		2, -- 146
		col(Palette.inkDark) -- 146
	) -- 146
	self.draw:drawPolygon( -- 148
		{ -- 149
			Vec2(-428, -238), -- 149
			Vec2(428, -238), -- 149
			Vec2(428, 238), -- 149
			Vec2(-428, 238) -- 149
		}, -- 149
		col(ink(0, 0, 0, 0)), -- 150
		1, -- 150
		col(Palette.goldSoft) -- 150
	) -- 150
	self.draw:drawSegment( -- 152
		Vec2(-172, -210), -- 152
		Vec2(-172, 190), -- 152
		1, -- 152
		col(Palette.inkFaint) -- 152
	) -- 152
	self.draw:drawSegment( -- 153
		Vec2(48, -210), -- 153
		Vec2(48, 190), -- 153
		1, -- 153
		col(Palette.inkFaint) -- 153
	) -- 153
	local phaseName = state.phaseIndex >= 0 and state.phaseIndex < #PHASE_NAMES and PHASE_NAMES[state.phaseIndex + 1] or "" -- 155
	setText( -- 156
		self.loopLb, -- 156
		("第" .. tostring(state.loopIndex + 1)) .. "周目" -- 156
	) -- 156
	setText(self.phaseLb, "当前月相：" .. phaseName) -- 157
	local checkpointName = "未记录" -- 159
	do -- 159
		local i = 0 -- 160
		while i < #Tower.checkpoints do -- 160
			if Tower.checkpoints[i + 1].id == state.currentCheckpointId then -- 160
				checkpointName = Tower.checkpoints[i + 1].label -- 162
				break -- 163
			end -- 163
			i = i + 1 -- 160
		end -- 160
	end -- 160
	setText(self.checkLb, "检查点：" .. checkpointName) -- 166
	setText( -- 168
		self.stoneLb, -- 168
		"月石　x " .. tostring(state.moonstones) -- 168
	) -- 168
	setText( -- 169
		self.mechLb, -- 169
		"机关件　x " .. tostring(state.mechanismParts) -- 169
	) -- 169
	setText( -- 170
		self.tokenLb, -- 170
		"旧物　x " .. tostring(state.tokens) -- 170
	) -- 170
	local total = #state.causalityLog -- 172
	local start = math.max(0, total - #self.causeLbs) -- 173
	do -- 173
		local i = 0 -- 174
		while i < #self.causeLbs do -- 174
			local idx = start + i -- 175
			if idx < total then -- 175
				setText( -- 177
					self.causeLbs[i + 1], -- 177
					(tostring(idx + 1) .. ". ") .. state.causalityLog[idx + 1] -- 177
				) -- 177
				self.causeLbs[i + 1].color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, Palette.inkSoft.a) -- 178
			else -- 178
				setText(self.causeLbs[i + 1], "") -- 180
			end -- 180
			i = i + 1 -- 174
		end -- 174
	end -- 174
	if self.iconMoon == nil then -- 174
		self.draw:drawDot( -- 185
			Vec2(-116, 92), -- 185
			7, -- 185
			col(Palette.moonCyan) -- 185
		) -- 185
		self.draw:drawDot( -- 186
			Vec2(-116, 92), -- 186
			10, -- 186
			col(Palette.moonCyanFaint) -- 186
		) -- 186
	end -- 186
	if self.iconMech == nil then -- 186
		self.draw:drawPolygon( -- 189
			{ -- 189
				Vec2(-116, 62), -- 189
				Vec2(-107, 56), -- 189
				Vec2(-116, 50), -- 189
				Vec2(-125, 56) -- 189
			}, -- 189
			col(Palette.gold), -- 189
			1, -- 189
			col(Palette.inkDark) -- 189
		) -- 189
	end -- 189
	if self.iconToken == nil then -- 189
		self.draw:drawPolygon( -- 192
			{ -- 192
				Vec2(-116, 26), -- 192
				Vec2(-108, 20), -- 192
				Vec2(-116, 14), -- 192
				Vec2(-124, 20) -- 192
			}, -- 192
			col(Palette.vermilion) -- 192
		) -- 192
	end -- 192
	do -- 192
		local i = 0 -- 195
		while i < #self.memoryLbs do -- 195
			local known = i < #MEMORIES_LIST and __TS__ArrayIndexOf(state.memories, MEMORIES_LIST[i + 1]) >= 0 -- 196
			local y = 92 - i * 36 -- 197
			if known then -- 197
				self.draw:drawDot( -- 199
					Vec2(102, y), -- 199
					5, -- 199
					col(Palette.inkDark) -- 199
				) -- 199
				setText(self.memoryLbs[i + 1], MEMORIES_LIST[i + 1]) -- 200
				self.memoryLbs[i + 1].color = Color(Palette.inkSoft.r, Palette.inkSoft.g, Palette.inkSoft.b, Palette.inkSoft.a) -- 201
			else -- 201
				self.draw:drawPolygon( -- 203
					{ -- 203
						Vec2(102, y + 6), -- 203
						Vec2(108, y), -- 203
						Vec2(102, y - 6), -- 203
						Vec2(96, y) -- 203
					}, -- 203
					col(ink(0, 0, 0, 0)), -- 203
					1, -- 203
					col(Palette.inkFaint) -- 203
				) -- 203
				setText(self.memoryLbs[i + 1], "？") -- 204
				self.memoryLbs[i + 1].color = Color(Palette.paleInkFar.r, Palette.paleInkFar.g, Palette.paleInkFar.b, Palette.paleInkFar.a) -- 205
			end -- 205
			i = i + 1 -- 195
		end -- 195
	end -- 195
end -- 136
return ____exports -- 136