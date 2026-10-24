-- [ts]: name_entry.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local ____tech_ui = require("ui.tech_ui") -- 4
local makeTechPanel = ____tech_ui.makeTechPanel -- 4
local ____archive = require("core.archive") -- 5
local DEFAULT_NAME = ____archive.DEFAULT_NAME -- 5
local sanitizeName = ____archive.sanitizeName -- 5
local FONT = "assets/font/DialogFont.ttf" -- 7
local function makeText(size) -- 10
	local lb = Label(FONT, size) -- 11
	if lb == nil then -- 11
		lb = Label("sarasa-mono-sc-regular", size) -- 13
	end -- 13
	return lb -- 15
end -- 10
local NAME_MAX = 12 -- 17
--- 删去字符串最后一个 UTF-8 字符（Lua 字符串按字节处理）
local function deleteLastChar(s) -- 20
	local i = #s - 1 -- 21
	while i > 0 and __TS__StringCharCodeAt(s, i) & 192 == 128 do -- 21
		i = i - 1 -- 23
	end -- 23
	return i <= 0 and "" or __TS__StringSubstring(s, 0, i) -- 25
end -- 20
--- 统计 UTF-8 字符数
local function charCount(s) -- 29
	local n = 0 -- 30
	do -- 30
		local i = 0 -- 31
		while i < #s do -- 31
			if __TS__StringCharCodeAt(s, i) & 192 ~= 128 then -- 31
				n = n + 1 -- 33
			end -- 33
			i = i + 1 -- 31
		end -- 31
	end -- 31
	return n -- 36
end -- 29
____exports.NameEntry = __TS__Class() -- 39
local NameEntry = ____exports.NameEntry -- 39
NameEntry.name = "NameEntry" -- 39
function NameEntry.prototype.____constructor(self, parent) -- 51
	self.openFlag = false -- 52
	self.buf = "" -- 53
	self.caretT = 0 -- 54
	self.caretVisible = true -- 55
	self.onConfirm = nil -- 56
	self.onCancel = nil -- 57
	self.root = Node() -- 58
	self.root:addTo(parent) -- 59
	self.root.visible = false -- 60
	local w = View.size.width -- 61
	local h = View.size.height -- 62
	local hw = w / 2 -- 63
	local hh = h / 2 -- 64
	local bg = DrawNode() -- 65
	bg:addTo(self.root) -- 66
	bg:drawPolygon( -- 67
		{ -- 67
			Vec2(-hw, -hh), -- 67
			Vec2(hw, -hh), -- 67
			Vec2(hw, hh), -- 67
			Vec2(-hw, hh) -- 67
		}, -- 67
		Color(0, 0, 0, 200) -- 67
	) -- 67
	local pw = 560 -- 69
	local ph = 300 -- 70
	makeTechPanel(self.root, pw, ph) -- 71
	local title = makeText(26) -- 72
	if title ~= nil then -- 72
		title.text = "刻下旅人之名" -- 74
		title.anchor = Vec2(0.5, 0.5) -- 75
		title.position = Vec2(0, 84) -- 76
		title.color = Color(255, 255, 255, 255) -- 77
		title:addTo(self.root) -- 78
	end -- 78
	self.bufDraw = DrawNode() -- 80
	self.bufDraw:addTo(self.root) -- 81
	self.bufLb = makeText(34) -- 82
	if self.bufLb ~= nil then -- 82
		self.bufLb.anchor = Vec2(0.5, 0.5) -- 84
		self.bufLb.position = Vec2(0, 12) -- 85
		self.bufLb.color = Color(255, 255, 255, 255) -- 86
		self.bufLb:addTo(self.root) -- 87
	end -- 87
	local hint2 = makeText(15) -- 90
	if hint2 ~= nil then -- 90
		hint2.text = ("名字将随你的时空树一起留入仓库（留空则名为「" .. DEFAULT_NAME) .. "」）" -- 92
		hint2.anchor = Vec2(0.5, 0.5) -- 93
		hint2.position = Vec2(0, -66) -- 94
		hint2.color = Color(255, 255, 255, 255) -- 95
		hint2:addTo(self.root) -- 96
	end -- 96
	self.inputNode = Node() -- 99
	self.inputNode:addTo(self.root) -- 100
	self.inputNode:onTextInput(function(text) -- 101
		if not self.openFlag or text == nil then -- 101
			return -- 103
		end -- 103
		if charCount(self.buf .. text) <= NAME_MAX then -- 103
			self.buf = self.buf .. text -- 106
			self:renderBuf() -- 107
		end -- 107
	end) -- 101
	self.inputNode:schedule(function(dt) -- 111
		if not self.openFlag then -- 111
			return false -- 113
		end -- 113
		self.caretT = self.caretT + dt -- 115
		if self.caretT >= 0.5 then -- 115
			self.caretT = 0 -- 117
			self.caretVisible = not self.caretVisible -- 118
			self:drawCaret() -- 119
		end -- 119
		return false -- 121
	end) -- 111
end -- 51
function NameEntry.prototype.open(self, prefill, onConfirm, onCancel) -- 125
	self.openFlag = true -- 126
	self.buf = sanitizeName(prefill, NAME_MAX) -- 127
	self.onConfirm = onConfirm -- 128
	self.onCancel = onCancel -- 129
	self.root.visible = true -- 130
	self.inputNode:attachIME() -- 131
	self:renderBuf() -- 132
end -- 125
function NameEntry.prototype.close(self) -- 135
	self.openFlag = false -- 136
	self.root.visible = false -- 137
	self.inputNode:detachIME() -- 138
	self.onConfirm = nil -- 139
	self.onCancel = nil -- 140
end -- 135
function NameEntry.prototype.isOpen(self) -- 143
	return self.openFlag -- 144
end -- 143
function NameEntry.prototype.handleKey(self, key) -- 148
	if not self.openFlag then -- 148
		return -- 150
	end -- 150
	if key == "Return" then -- 150
		local name = sanitizeName(self.buf, NAME_MAX) -- 153
		local finalName = name == "" and DEFAULT_NAME or name -- 154
		local cb = self.onConfirm -- 155
		self:close() -- 156
		if cb ~= nil then -- 156
			cb(finalName) -- 158
		end -- 158
	elseif key == "Escape" then -- 158
		local cb = self.onCancel -- 161
		self:close() -- 162
		if cb ~= nil then -- 162
			cb() -- 164
		end -- 164
	elseif key == "BackSpace" then -- 164
		self.buf = deleteLastChar(self.buf) -- 167
		self:renderBuf() -- 168
	end -- 168
end -- 148
function NameEntry.prototype.renderBuf(self) -- 172
	if self.bufLb ~= nil then -- 172
		self.bufLb.text = self.buf -- 174
	end -- 174
	self:drawCaret() -- 176
end -- 172
function NameEntry.prototype.drawCaret(self) -- 180
	self.bufDraw:clear() -- 181
	if not self.openFlag or not self.caretVisible or self.bufLb == nil then -- 181
		return -- 183
	end -- 183
	local x = self.bufLb.width * 0.5 + 6 -- 185
	self.bufDraw:drawSegment( -- 186
		Vec2(x, -6), -- 186
		Vec2(x, 30), -- 186
		1.5, -- 186
		Color(255, 255, 255, 220) -- 186
	) -- 186
end -- 180
return ____exports -- 180