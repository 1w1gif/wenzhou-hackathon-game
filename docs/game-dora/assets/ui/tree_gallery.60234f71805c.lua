-- [ts]: tree_gallery.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____tech_ui = require("ui.tech_ui") -- 3
local makeTechPanel = ____tech_ui.makeTechPanel -- 3
local ____Dora = require("Dora") -- 4
local Color = ____Dora.Color -- 4
local DrawNode = ____Dora.DrawNode -- 4
local Label = ____Dora.Label -- 4
local Node = ____Dora.Node -- 4
local Size = ____Dora.Size -- 4
local Vec2 = ____Dora.Vec2 -- 4
local View = ____Dora.View -- 4
local ____palette = require("core.palette") -- 5
local Palette = ____palette.Palette -- 5
local ink = ____palette.ink -- 5
local FONT = "assets/font/DialogFont.ttf" -- 8
local function makeText(size) -- 11
	local lb = Label(FONT, size) -- 12
	if lb == nil then -- 12
		lb = Label("sarasa-mono-sc-regular", size) -- 14
	end -- 14
	return lb -- 16
end -- 11
local PHASE_NAMES = { -- 18
	"朔", -- 18
	"眉月", -- 18
	"上弦", -- 18
	"盈凸", -- 18
	"望", -- 18
	"亏凸", -- 18
	"下弦", -- 18
	"残月" -- 18
} -- 18
local function col(c) -- 20
	return Color(c.r, c.g, c.b, c.a) -- 21
end -- 20
--- 由 currentId 沿 parent 回溯得到根→当前的 id 链（存档里无链表，按需重建）
local function chainOf(nodes, currentId) -- 31
	local chain = {} -- 32
	local cur = nil -- 33
	do -- 33
		local i = 0 -- 34
		while i < #nodes do -- 34
			if nodes[i + 1].id == currentId then -- 34
				cur = nodes[i + 1] -- 36
				break -- 37
			end -- 37
			i = i + 1 -- 34
		end -- 34
	end -- 34
	while cur ~= nil do -- 34
		__TS__ArrayUnshift(chain, cur.id) -- 41
		local next = nil -- 42
		if cur.parent ~= "" then -- 42
			do -- 42
				local i = 0 -- 44
				while i < #nodes do -- 44
					if nodes[i + 1].id == cur.parent then -- 44
						next = nodes[i + 1] -- 46
						break -- 47
					end -- 47
					i = i + 1 -- 44
				end -- 44
			end -- 44
		end -- 44
		cur = next -- 51
	end -- 51
	return chain -- 53
end -- 31
____exports.TreeGallery = __TS__Class() -- 56
local TreeGallery = ____exports.TreeGallery -- 56
TreeGallery.name = "TreeGallery" -- 56
function TreeGallery.prototype.____constructor(self, parent) -- 75
	self.entries = {} -- 76
	self.sel = 0 -- 77
	self.scroll = 0 -- 78
	self.openFlag = false -- 79
	self.rowLbs = {} -- 80
	self.w = View.size.width -- 81
	self.h = View.size.height -- 82
	self.rowH = 44 -- 83
	self.listTop = self.h / 2 - 170 -- 84
	self.visibleRows = math.floor((self.h - 320) / self.rowH) -- 85
	self.root = Node() -- 86
	self.root:addTo(parent) -- 87
	self.root.visible = false -- 88
	local hw = self.w / 2 -- 89
	local hh = self.h / 2 -- 90
	local bg = DrawNode() -- 91
	bg:addTo(self.root) -- 92
	bg:drawPolygon( -- 93
		{ -- 93
			Vec2(-hw, -hh), -- 93
			Vec2(hw, -hh), -- 93
			Vec2(hw, hh), -- 93
			Vec2(-hw, hh) -- 93
		}, -- 93
		Color(0, 0, 0, 212) -- 93
	) -- 93
	makeTechPanel(self.root, self.w - 36, self.h - 36) -- 95
	self.listDraw = DrawNode() -- 96
	self.listDraw:addTo(self.root) -- 97
	self.treeDraw = DrawNode() -- 98
	self.treeDraw:addTo(self.root) -- 99
	local title = makeText(30) -- 101
	if title ~= nil then -- 101
		title.text = "时空树仓库" -- 103
		title.anchor = Vec2(0.5, 0.5) -- 104
		title.position = Vec2(0, hh - 66) -- 105
		title.color = col(ink(255, 255, 255, 255)) -- 106
		title:addTo(self.root) -- 107
		self.titleLb = title -- 108
	end -- 108
	local info = makeText(17) -- 110
	if info ~= nil then -- 110
		info.anchor = Vec2(0.5, 0.5) -- 112
		info.position = Vec2(self.w / 2 - 380, -hh + 92) -- 113
		info.color = col(ink(255, 255, 255, 255)) -- 114
		info:addTo(self.root) -- 115
		self.infoLb = info -- 116
	end -- 116
	local hint = makeText(14) -- 118
	if hint ~= nil then -- 118
		hint.text = "W / S  选择旅人 · Esc 返回 · 每通过一局，这里便多一棵独一无二的时空树" -- 120
		hint.anchor = Vec2(0.5, 0.5) -- 121
		hint.position = Vec2(0, -hh + 44) -- 122
		hint.color = col(ink(255, 255, 255, 255)) -- 123
		hint:addTo(self.root) -- 124
		self.hintLb = hint -- 125
	end -- 125
	do -- 125
		local i = 0 -- 128
		while i < self.visibleRows do -- 128
			local lb = makeText(18) -- 129
			if lb == nil then -- 129
				break -- 131
			end -- 131
			lb.anchor = Vec2(0, 0.5) -- 133
			lb.position = Vec2(-self.w / 2 + 58, self.listTop - i * self.rowH) -- 134
			lb:addTo(self.root) -- 135
			local ____self_rowLbs_0 = self.rowLbs -- 135
			____self_rowLbs_0[#____self_rowLbs_0 + 1] = lb -- 136
			i = i + 1 -- 128
		end -- 128
	end -- 128
	self.hit = Node() -- 138
	self.hit.size = Size(self.w, self.h) -- 139
	self.hit.position = Vec2(0, 0) -- 140
	self.hit.touchEnabled = false -- 141
	self.hit:addTo(self.root) -- 142
	self.hit:onTapBegan(function(touch) -- 143
		if not self.openFlag then -- 143
			return -- 145
		end -- 145
		local ____local = touch.location -- 147
		local px = ____local.x - self.w * 0.5 -- 148
		local py = ____local.y - self.h * 0.5 -- 149
		do -- 149
			local i = 0 -- 150
			while i < self.visibleRows do -- 150
				local idx = self.scroll + i -- 151
				if idx >= #self.entries then -- 151
					break -- 153
				end -- 153
				local rowY = self.listTop - i * self.rowH -- 155
				if px >= -self.w / 2 + 30 and px <= 120 and math.abs(py - rowY) <= self.rowH / 2 then -- 155
					self.sel = idx -- 157
					self:render() -- 158
					return -- 159
				end -- 159
				i = i + 1 -- 150
			end -- 150
		end -- 150
	end) -- 143
end -- 75
function TreeGallery.prototype.open(self, entries) -- 165
	self.entries = entries -- 166
	self.sel = math.max( -- 167
		0, -- 167
		math.min(self.sel, #entries - 1) -- 167
	) -- 167
	self.scroll = 0 -- 168
	self.openFlag = true -- 169
	self.root.visible = true -- 170
	self.hit.touchEnabled = true -- 171
	self:render() -- 172
end -- 165
function TreeGallery.prototype.close(self) -- 175
	self.openFlag = false -- 176
	self.root.visible = false -- 177
	self.hit.touchEnabled = false -- 178
end -- 175
function TreeGallery.prototype.isOpen(self) -- 181
	return self.openFlag -- 182
end -- 181
function TreeGallery.prototype.handleKey(self, key) -- 186
	if not self.openFlag then -- 186
		return -- 188
	end -- 188
	if key == "Escape" or key == "Q" then -- 188
		self:close() -- 191
	elseif key == "W" or key == "Up" then -- 191
		self:moveSel(-1) -- 193
	elseif key == "S" or key == "Down" then -- 193
		self:moveSel(1) -- 195
	elseif key == "A" or key == "Left" then -- 195
		self:moveSel(-self.visibleRows) -- 197
	elseif key == "D" or key == "Right" then -- 197
		self:moveSel(self.visibleRows) -- 199
	end -- 199
end -- 186
function TreeGallery.prototype.moveSel(self, delta) -- 203
	if #self.entries == 0 then -- 203
		return -- 205
	end -- 205
	local s = self.sel + delta -- 207
	if s < 0 then -- 207
		s = 0 -- 209
	end -- 209
	if s > #self.entries - 1 then -- 209
		s = #self.entries - 1 -- 212
	end -- 212
	if s ~= self.sel then -- 212
		self.sel = s -- 215
		self:render() -- 216
	end -- 216
end -- 203
function TreeGallery.prototype.render(self) -- 220
	self:renderList() -- 221
	self:renderTree() -- 222
end -- 220
function TreeGallery.prototype.renderList(self) -- 225
	if self.sel < self.scroll then -- 225
		self.scroll = self.sel -- 228
	end -- 228
	if self.sel > self.scroll + self.visibleRows - 1 then -- 228
		self.scroll = self.sel - self.visibleRows + 1 -- 231
	end -- 231
	self.listDraw:clear() -- 233
	do -- 233
		local i = 0 -- 234
		while i < #self.rowLbs do -- 234
			self.rowLbs[i + 1].visible = false -- 235
			i = i + 1 -- 234
		end -- 234
	end -- 234
	if #self.entries == 0 then -- 234
		if self.infoLb ~= nil then -- 234
			self.infoLb.text = "仓库空空如也 —— 通关一局，时空树便会留存于此" -- 239
		end -- 239
		return -- 241
	end -- 241
	local selIdx = self.sel - self.scroll -- 243
	do -- 243
		local i = 0 -- 244
		while i < self.visibleRows do -- 244
			local idx = self.scroll + i -- 245
			if idx >= #self.entries or i >= #self.rowLbs then -- 245
				break -- 247
			end -- 247
			local e = self.entries[idx + 1] -- 249
			local lb = self.rowLbs[i + 1] -- 250
			lb.visible = true -- 251
			lb.text = (tostring(idx + 1) .. ". ") .. e.name -- 252
			local selected = idx == self.sel -- 253
			lb.color = col(ink(255, 255, 255, 255)) -- 254
			if selected then -- 254
				local y = self.listTop - i * self.rowH -- 256
				self.listDraw:drawPolygon( -- 257
					{ -- 258
						Vec2(-self.w / 2 + 36, y - 16), -- 258
						Vec2(-self.w / 2 + 496, y - 16), -- 258
						Vec2(-self.w / 2 + 496, y + 16), -- 258
						Vec2(-self.w / 2 + 36, y + 16) -- 258
					}, -- 258
					Color(96, 200, 255, 30), -- 259
					1, -- 259
					Color(96, 200, 255, 150) -- 259
				) -- 259
			end -- 259
			i = i + 1 -- 244
		end -- 244
	end -- 244
end -- 225
function TreeGallery.prototype.renderTree(self) -- 265
	self.treeDraw:clear() -- 266
	if #self.entries == 0 or self.sel >= #self.entries then -- 266
		return -- 268
	end -- 268
	local e = self.entries[self.sel + 1] -- 270
	if self.infoLb ~= nil then -- 270
		self.infoLb.text = (((((("「" .. e.name) .. "」的时空树 · ") .. tostring(#e.nodes)) .. " 条枝 · 回溯 ") .. tostring(e.rewindCount)) .. " 次 · ") .. e.endingTitle -- 272
	end -- 272
	local nodes = e.nodes -- 275
	local maxDepth = 0 -- 276
	do -- 276
		local i = 0 -- 277
		while i < #nodes do -- 277
			if nodes[i + 1].depth > maxDepth then -- 277
				maxDepth = nodes[i + 1].depth -- 279
			end -- 279
			i = i + 1 -- 277
		end -- 277
	end -- 277
	local cx = 330 -- 282
	local yBot = -self.h / 2 + 140 -- 283
	local yTop = self.h / 2 - 190 -- 284
	local rows = maxDepth + 1 -- 285
	local rowH = rows <= 1 and 0 or math.min(96, (yTop - yBot) / (rows - 1)) -- 286
	local groups = {} -- 287
	do -- 287
		local d = 0 -- 288
		while d <= maxDepth do -- 288
			groups[#groups + 1] = {} -- 289
			d = d + 1 -- 288
		end -- 288
	end -- 288
	do -- 288
		local i = 0 -- 291
		while i < #nodes do -- 291
			local d = math.max( -- 292
				0, -- 292
				math.min(maxDepth, nodes[i + 1].depth) -- 292
			) -- 292
			local ____groups_index_1 = groups[d + 1] -- 292
			____groups_index_1[#____groups_index_1 + 1] = nodes[i + 1] -- 293
			i = i + 1 -- 291
		end -- 291
	end -- 291
	local pts = {} -- 295
	do -- 295
		local d = 0 -- 296
		while d < #groups do -- 296
			local g = groups[d + 1] -- 297
			local spacing = math.min( -- 298
				72, -- 298
				560 / math.max(1, #g) -- 298
			) -- 298
			do -- 298
				local i = 0 -- 299
				while i < #g do -- 299
					pts[#pts + 1] = {id = g[i + 1].id, x = cx + (i - (#g - 1) / 2) * spacing, y = yBot + d * rowH} -- 300
					i = i + 1 -- 299
				end -- 299
			end -- 299
			d = d + 1 -- 296
		end -- 296
	end -- 296
	local chain = chainOf(nodes, e.currentId) -- 303
	do -- 303
		local i = 0 -- 305
		while i < #nodes do -- 305
			do -- 305
				local n = nodes[i + 1] -- 306
				if n.parent == "" then -- 306
					goto __continue69 -- 308
				end -- 308
				local from = self:findPos(pts, n.parent) -- 310
				local to = self:findPos(pts, n.id) -- 311
				if from == nil or to == nil then -- 311
					goto __continue69 -- 313
				end -- 313
				local onChain = __TS__ArrayIndexOf(chain, n.id) >= 0 and __TS__ArrayIndexOf(chain, n.parent) >= 0 -- 315
				local lineColor = onChain and col(Palette.gold) or (n.abandoned and col(Palette.paleInkFar) or col(Palette.inkWash)) -- 316
				self.treeDraw:drawSegment( -- 317
					Vec2(from.x, from.y), -- 317
					Vec2(to.x, to.y), -- 317
					onChain and 3 or 2, -- 317
					lineColor -- 317
				) -- 317
			end -- 317
			::__continue69:: -- 317
			i = i + 1 -- 305
		end -- 305
	end -- 305
	do -- 305
		local i = 0 -- 320
		while i < #nodes do -- 320
			do -- 320
				local n = nodes[i + 1] -- 321
				local p = self:findPos(pts, n.id) -- 322
				if p == nil then -- 322
					goto __continue73 -- 324
				end -- 324
				local r = 10 -- 326
				if n.id == e.currentId then -- 326
					self.treeDraw:drawDot( -- 328
						Vec2(p.x, p.y), -- 328
						r + 7, -- 328
						Color(Palette.gold.r, Palette.gold.g, Palette.gold.b, 70) -- 328
					) -- 328
					self.treeDraw:drawDot( -- 329
						Vec2(p.x, p.y), -- 329
						r + 3, -- 329
						col(Palette.gold) -- 329
					) -- 329
				end -- 329
				local lit = n.abandoned and col(Palette.paleInkFar) or col(Palette.moonWhite) -- 331
				local rim = n.abandoned and col(Palette.paleInkFar) or col(Palette.moonCyanSoft) -- 332
				self.treeDraw:drawDot( -- 333
					Vec2(p.x, p.y), -- 333
					r, -- 333
					lit -- 333
				) -- 333
				self.treeDraw:drawDot( -- 334
					Vec2(p.x, p.y - r * 0.3), -- 334
					r * 0.55, -- 334
					col(ink(14, 17, 22, 255)) -- 334
				) -- 334
				if n.phase == 0 then -- 334
					self.treeDraw:drawDot( -- 336
						Vec2(p.x, p.y), -- 336
						r, -- 336
						col(ink(14, 17, 22, 255)) -- 336
					) -- 336
				end -- 336
			end -- 336
			::__continue73:: -- 336
			i = i + 1 -- 320
		end -- 320
	end -- 320
end -- 265
function TreeGallery.prototype.findPos(self, pts, id) -- 341
	do -- 341
		local i = 0 -- 342
		while i < #pts do -- 342
			if pts[i + 1].id == id then -- 342
				return pts[i + 1] -- 344
			end -- 344
			i = i + 1 -- 342
		end -- 342
	end -- 342
	return nil -- 347
end -- 341
return ____exports -- 341