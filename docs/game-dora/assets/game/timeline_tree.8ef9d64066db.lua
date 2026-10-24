-- [ts]: timeline_tree.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local ____exports = {} -- 1
local ____tree_overlay = require("ui.tree_overlay") -- 5
local TreeOverlay = ____tree_overlay.TreeOverlay -- 5
--- 时空树系统：纯数据 + 轻量浮层控制，读档回溯由游戏层通过 onJumpTo 对接
____exports.TreeSystem = __TS__Class() -- 24
local TreeSystem = ____exports.TreeSystem -- 24
TreeSystem.name = "TreeSystem" -- 24
function TreeSystem.prototype.____constructor(self, rootVia) -- 37
	self.seq = 1 -- 38
	self.noKill = false -- 39
	self.rewindCount = 0 -- 40
	self.nodes = {} -- 41
	local root = { -- 42
		id = "tn0", -- 43
		parent = "", -- 44
		via = rootVia, -- 45
		phase = 0, -- 46
		depth = 0, -- 47
		abandoned = false -- 48
	} -- 48
	local ____self_nodes_0 = self.nodes -- 48
	____self_nodes_0[#____self_nodes_0 + 1] = root -- 50
	self.currentId = root.id -- 51
	self.overlay = nil -- 52
end -- 37
function TreeSystem.prototype.addChoice(self, via) -- 56
	local cur = self:findById(self.currentId) -- 57
	if cur == nil then -- 57
		return -- 59
	end -- 59
	local parentId = cur.parent -- 61
	local ____temp_1 -- 62
	if parentId == "" then -- 62
		____temp_1 = nil -- 62
	else -- 62
		____temp_1 = self:findById(parentId) -- 62
	end -- 62
	local parent = ____temp_1 -- 62
	local parentDepth = parent ~= nil and parent.depth or 0 -- 63
	local node = { -- 64
		id = "tn" .. "" .. tostring(self.seq), -- 65
		parent = parentId, -- 66
		via = via, -- 67
		phase = (parentDepth + 1) % 8, -- 68
		depth = parentDepth + 1, -- 69
		abandoned = false -- 70
	} -- 70
	self.seq = self.seq + 1 -- 72
	cur.abandoned = true -- 73
	local ____self_nodes_2 = self.nodes -- 73
	____self_nodes_2[#____self_nodes_2 + 1] = node -- 74
	self.currentId = node.id -- 75
	if self.onNodeAdded ~= nil then -- 75
		self:onNodeAdded(node.id) -- 77
	end -- 77
end -- 56
function TreeSystem.prototype.extend(self, via) -- 82
	local cur = self:findById(self.currentId) -- 83
	if cur == nil then -- 83
		return -- 85
	end -- 85
	local node = { -- 87
		id = "tn" .. "" .. tostring(self.seq), -- 88
		parent = cur.id, -- 89
		via = via, -- 90
		phase = (cur.depth + 1) % 8, -- 91
		depth = cur.depth + 1, -- 92
		abandoned = false -- 93
	} -- 93
	self.seq = self.seq + 1 -- 95
	local ____self_nodes_3 = self.nodes -- 95
	____self_nodes_3[#____self_nodes_3 + 1] = node -- 96
	self.currentId = node.id -- 97
	if self.onNodeAdded ~= nil then -- 97
		self:onNodeAdded(node.id) -- 99
	end -- 99
end -- 82
function TreeSystem.prototype.jumpTo(self, id) -- 104
	local node = self:findById(id) -- 105
	if node == nil then -- 105
		return -- 107
	end -- 107
	self.currentId = id -- 109
	self.rewindCount = self.rewindCount + 1 -- 110
	if self.overlay ~= nil and self.overlay:isOpen() then -- 110
		self.overlay:close() -- 112
	end -- 112
end -- 104
function TreeSystem.prototype.handleKey(self, key) -- 117
	if self.overlay == nil then -- 117
		return -- 119
	end -- 119
	if key == "T" then -- 119
		self.overlay:toggle(self) -- 122
	elseif key == "Escape" and self.overlay:isOpen() then -- 122
		self.overlay:close() -- 124
	end -- 124
end -- 117
function TreeSystem.prototype.attachTo(self, parent) -- 129
	if self.overlay ~= nil then -- 129
		return -- 131
	end -- 131
	self.overlay = __TS__New(TreeOverlay, parent) -- 133
end -- 129
function TreeSystem.prototype.isOverlayOpen(self) -- 137
	return self.overlay ~= nil and self.overlay:isOpen() -- 138
end -- 137
function TreeSystem.prototype.setStats(self, noKill) -- 142
	self.noKill = noKill -- 143
end -- 142
function TreeSystem.prototype.getStats(self) -- 147
	local noKillText = self.noKill and "达成" or "未达成" -- 148
	return (((("共 " .. tostring(#self.nodes)) .. " 条枝 · 回溯 ") .. tostring(self.rewindCount)) .. " 次 · 不杀：") .. noKillText -- 149
end -- 147
function TreeSystem.prototype.findById(self, id) -- 152
	do -- 152
		local i = 0 -- 153
		while i < #self.nodes do -- 153
			if self.nodes[i + 1].id == id then -- 153
				return self.nodes[i + 1] -- 155
			end -- 155
			i = i + 1 -- 153
		end -- 153
	end -- 153
	return nil -- 158
end -- 152
function TreeSystem.prototype.currentChain(self) -- 162
	local chain = {} -- 163
	local cur = self:findById(self.currentId) -- 164
	while cur ~= nil do -- 164
		__TS__ArrayUnshift(chain, cur.id) -- 166
		local ____temp_4 -- 167
		if cur.parent == "" then -- 167
			____temp_4 = nil -- 167
		else -- 167
			____temp_4 = self:findById(cur.parent) -- 167
		end -- 167
		cur = ____temp_4 -- 167
	end -- 167
	return chain -- 169
end -- 162
return ____exports -- 162