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
function TreeGallery.prototype.____constructor(self, parent) -- 81
	self.entries = {} -- 82
	self.sel = 0 -- 83
	self.scroll = 0 -- 84
	self.openFlag = false -- 85
	self.rowLbs = {} -- 86
	self.subLbs = {} -- 87
	self.w = View.size.width -- 88
	self.h = View.size.height -- 89
	self.rowH = 52 -- 90
	self.listTop = self.h / 2 - 170 -- 91
	self.visibleRows = math.floor((self.h - 320) / self.rowH) -- 92
	self.root = Node() -- 93
	self.root:addTo(parent) -- 94
	self.root.visible = false -- 95
	local hw = self.w / 2 -- 96
	local hh = self.h / 2 -- 97
	local bg = DrawNode() -- 98
	bg:addTo(self.root) -- 99
	bg:drawPolygon( -- 100
		{ -- 100
			Vec2(-hw, -hh), -- 100
			Vec2(hw, -hh), -- 100
			Vec2(hw, hh), -- 100
			Vec2(-hw, hh) -- 100
		}, -- 100
		Color(0, 0, 0, 212) -- 100
	) -- 100
	local divX = -110 -- 102
	bg:drawSegment( -- 103
		Vec2(divX, -hh + 70), -- 103
		Vec2(divX, hh - 110), -- 103
		1, -- 103
		Color(96, 200, 255, 80) -- 103
	) -- 103
	makeTechPanel(self.root, self.w - 36, self.h - 36) -- 105
	self.listDraw = DrawNode() -- 106
	self.listDraw:addTo(self.root) -- 107
	self.treeDraw = DrawNode() -- 108
	self.treeDraw:addTo(self.root) -- 109
	local title = makeText(30) -- 111
	if title ~= nil then -- 111
		title.text = "时空树仓库" -- 113
		title.anchor = Vec2(0.5, 0.5) -- 114
		title.position = Vec2(0, hh - 66) -- 115
		title.color = col(ink(255, 255, 255, 255)) -- 116
		title:addTo(self.root) -- 117
		self.titleLb = title -- 118
	end -- 118
	local infoCx = 250 -- 120
	local info = makeText(18) -- 121
	if info ~= nil then -- 121
		info.anchor = Vec2(0.5, 0.5) -- 123
		info.position = Vec2(infoCx, -hh + 106) -- 124
		info.color = col(ink(255, 255, 255, 255)) -- 125
		info:addTo(self.root) -- 126
		self.infoLb = info -- 127
	end -- 127
	local info2 = makeText(15) -- 129
	if info2 ~= nil then -- 129
		info2.anchor = Vec2(0.5, 0.5) -- 131
		info2.position = Vec2(infoCx, -hh + 78) -- 132
		info2.color = col(ink(168, 197, 188, 200)) -- 133
		info2:addTo(self.root) -- 134
		self.info2Lb = info2 -- 135
	end -- 135
	local hint = makeText(14) -- 137
	if hint ~= nil then -- 137
		hint.text = "W / S  选择旅人 · Esc 返回 · 每通过一局，这里便多一棵独一无二的时空树" -- 139
		hint.anchor = Vec2(0.5, 0.5) -- 140
		hint.position = Vec2(0, -hh + 44) -- 141
		hint.color = col(ink(255, 255, 255, 255)) -- 142
		hint:addTo(self.root) -- 143
		self.hintLb = hint -- 144
	end -- 144
	local headY = self.listTop + 44 -- 147
	local headList = makeText(16) -- 148
	if headList ~= nil then -- 148
		headList.text = "—— 通关名录 ——" -- 150
		headList.anchor = Vec2(0.5, 0.5) -- 151
		headList.position = Vec2(-self.w / 2 + 266, headY) -- 152
		headList.color = col(ink(168, 197, 188, 220)) -- 153
		headList:addTo(self.root) -- 154
		self.headListLb = headList -- 155
	end -- 155
	local headTree = makeText(16) -- 157
	if headTree ~= nil then -- 157
		headTree.text = "—— 时空树 ——" -- 159
		headTree.anchor = Vec2(0.5, 0.5) -- 160
		headTree.position = Vec2(250, headY) -- 161
		headTree.color = col(ink(168, 197, 188, 220)) -- 162
		headTree:addTo(self.root) -- 163
		self.headTreeLb = headTree -- 164
	end -- 164
	local legend = makeText(13) -- 167
	if legend ~= nil then -- 167
		legend.text = "图例：● 朔=起点（黑月）　○ 白月=普通节点　暗点=弃线　金圈=当前进度　金线=当前存档链" -- 169
		legend.anchor = Vec2(0.5, 0.5) -- 170
		legend.position = Vec2(250, -hh + 114) -- 171
		legend.color = col(ink(168, 197, 188, 190)) -- 172
		legend:addTo(self.root) -- 173
		self.legendLb = legend -- 174
	end -- 174
	local empty = makeText(26) -- 177
	if empty ~= nil then -- 177
		empty.text = "仓库空空如也 —— 通关一局，时空树便会留存于此" -- 179
		empty.anchor = Vec2(0.5, 0.5) -- 180
		empty.position = Vec2(0, 20) -- 181
		empty.color = col(ink(255, 255, 255, 255)) -- 182
		empty:addTo(self.root) -- 183
		self.emptyLb = empty -- 184
		empty.visible = false -- 185
	end -- 185
	do -- 185
		local i = 0 -- 188
		while i < self.visibleRows do -- 188
			local y = self.listTop - i * self.rowH -- 189
			local lb = makeText(18) -- 190
			if lb == nil then -- 190
				break -- 192
			end -- 192
			lb.anchor = Vec2(0, 0.5) -- 194
			lb.position = Vec2(-self.w / 2 + 58, y + 9) -- 195
			lb:addTo(self.root) -- 196
			local ____self_rowLbs_0 = self.rowLbs -- 196
			____self_rowLbs_0[#____self_rowLbs_0 + 1] = lb -- 197
			local sub = makeText(13) -- 198
			if sub ~= nil then -- 198
				sub.anchor = Vec2(0, 0.5) -- 200
				sub.position = Vec2(-self.w / 2 + 58, y - 12) -- 201
				sub.color = col(ink(168, 197, 188, 170)) -- 202
				sub:addTo(self.root) -- 203
				local ____self_subLbs_1 = self.subLbs -- 203
				____self_subLbs_1[#____self_subLbs_1 + 1] = sub -- 204
			end -- 204
			i = i + 1 -- 188
		end -- 188
	end -- 188
	self.hit = Node() -- 207
	self.hit.size = Size(self.w, self.h) -- 208
	self.hit.position = Vec2(0, 0) -- 209
	self.hit.touchEnabled = false -- 210
	self.hit:addTo(self.root) -- 211
	self.hit:onTapBegan(function(touch) -- 212
		if not self.openFlag then -- 212
			return -- 214
		end -- 214
		local ____local = touch.location -- 216
		local px = ____local.x - self.w * 0.5 -- 217
		local py = ____local.y - self.h * 0.5 -- 218
		do -- 218
			local i = 0 -- 219
			while i < self.visibleRows do -- 219
				local idx = self.scroll + i -- 220
				if idx >= #self.entries then -- 220
					break -- 222
				end -- 222
				local rowY = self.listTop - i * self.rowH -- 224
				if px >= -self.w / 2 + 30 and px <= -self.w / 2 + 506 and math.abs(py - rowY) <= self.rowH / 2 then -- 224
					self.sel = idx -- 226
					self:render() -- 227
					return -- 228
				end -- 228
				i = i + 1 -- 219
			end -- 219
		end -- 219
	end) -- 212
end -- 81
function TreeGallery.prototype.open(self, entries) -- 234
	self.entries = entries -- 235
	self.sel = math.max( -- 236
		0, -- 236
		math.min(self.sel, #entries - 1) -- 236
	) -- 236
	self.scroll = 0 -- 237
	self.openFlag = true -- 238
	self.root.visible = true -- 239
	self.hit.touchEnabled = true -- 240
	self:render() -- 241
end -- 234
function TreeGallery.prototype.close(self) -- 244
	self.openFlag = false -- 245
	self.root.visible = false -- 246
	self.hit.touchEnabled = false -- 247
end -- 244
function TreeGallery.prototype.isOpen(self) -- 250
	return self.openFlag -- 251
end -- 250
function TreeGallery.prototype.handleKey(self, key) -- 255
	if not self.openFlag then -- 255
		return -- 257
	end -- 257
	if key == "Escape" or key == "Q" then -- 257
		self:close() -- 260
	elseif key == "W" or key == "Up" then -- 260
		self:moveSel(-1) -- 262
	elseif key == "S" or key == "Down" then -- 262
		self:moveSel(1) -- 264
	elseif key == "A" or key == "Left" then -- 264
		self:moveSel(-self.visibleRows) -- 266
	elseif key == "D" or key == "Right" then -- 266
		self:moveSel(self.visibleRows) -- 268
	end -- 268
end -- 255
function TreeGallery.prototype.moveSel(self, delta) -- 272
	if #self.entries == 0 then -- 272
		return -- 274
	end -- 274
	local s = self.sel + delta -- 276
	if s < 0 then -- 276
		s = 0 -- 278
	end -- 278
	if s > #self.entries - 1 then -- 278
		s = #self.entries - 1 -- 281
	end -- 281
	if s ~= self.sel then -- 281
		self.sel = s -- 284
		self:render() -- 285
	end -- 285
end -- 272
function TreeGallery.prototype.render(self) -- 289
	self:renderList() -- 290
	self:renderTree() -- 291
end -- 289
function TreeGallery.prototype.renderList(self) -- 294
	if self.sel < self.scroll then -- 294
		self.scroll = self.sel -- 297
	end -- 297
	if self.sel > self.scroll + self.visibleRows - 1 then -- 297
		self.scroll = self.sel - self.visibleRows + 1 -- 300
	end -- 300
	self.listDraw:clear() -- 302
	do -- 302
		local i = 0 -- 303
		while i < #self.rowLbs do -- 303
			self.rowLbs[i + 1].visible = false -- 304
			i = i + 1 -- 303
		end -- 303
	end -- 303
	do -- 303
		local i = 0 -- 306
		while i < #self.subLbs do -- 306
			self.subLbs[i + 1].visible = false -- 307
			i = i + 1 -- 306
		end -- 306
	end -- 306
	if self.legendLb ~= nil then -- 306
		self.legendLb.visible = #self.entries > 0 -- 310
	end -- 310
	if #self.entries == 0 then -- 310
		if self.emptyLb ~= nil then -- 310
			self.emptyLb.visible = true -- 314
		end -- 314
		if self.infoLb ~= nil then -- 314
			self.infoLb.text = "" -- 317
		end -- 317
		if self.info2Lb ~= nil then -- 317
			self.info2Lb.text = "" -- 320
		end -- 320
		return -- 322
	end -- 322
	if self.emptyLb ~= nil then -- 322
		self.emptyLb.visible = false -- 325
	end -- 325
	local selIdx = self.sel - self.scroll -- 327
	do -- 327
		local i = 0 -- 328
		while i < self.visibleRows do -- 328
			local idx = self.scroll + i -- 329
			if idx >= #self.entries or i >= #self.rowLbs then -- 329
				break -- 331
			end -- 331
			local e = self.entries[idx + 1] -- 333
			local lb = self.rowLbs[i + 1] -- 334
			lb.visible = true -- 335
			lb.text = (tostring(idx + 1) .. ". ") .. e.name -- 336
			if i < #self.subLbs then -- 336
				local sub = self.subLbs[i + 1] -- 338
				sub.visible = true -- 339
				sub.text = ((e.endingTitle .. " · 回溯") .. tostring(e.rewindCount)) .. "次" -- 340
			end -- 340
			local selected = idx == self.sel -- 342
			lb.color = col(ink(255, 255, 255, 255)) -- 343
			if selected then -- 343
				local y = self.listTop - i * self.rowH -- 345
				self.listDraw:drawPolygon( -- 346
					{ -- 347
						Vec2(-self.w / 2 + 36, y - 24), -- 347
						Vec2(-self.w / 2 + 496, y - 24), -- 347
						Vec2(-self.w / 2 + 496, y + 24), -- 347
						Vec2(-self.w / 2 + 36, y + 24) -- 347
					}, -- 347
					Color(96, 200, 255, 30), -- 348
					1, -- 348
					Color(96, 200, 255, 150) -- 348
				) -- 348
			end -- 348
			i = i + 1 -- 328
		end -- 328
	end -- 328
end -- 294
function TreeGallery.prototype.renderTree(self) -- 354
	self.treeDraw:clear() -- 355
	if #self.entries == 0 or self.sel >= #self.entries then -- 355
		return -- 357
	end -- 357
	local e = self.entries[self.sel + 1] -- 359
	if self.infoLb ~= nil then -- 359
		self.infoLb.text = ("「" .. e.name) .. "」的时空树" -- 361
	end -- 361
	if self.info2Lb ~= nil then -- 361
		self.info2Lb.text = ((((e.endingTitle .. " · ") .. tostring(#e.nodes)) .. " 条枝 · 回溯") .. tostring(e.rewindCount)) .. "次" -- 364
	end -- 364
	local nodes = e.nodes -- 367
	local maxDepth = 0 -- 368
	do -- 368
		local i = 0 -- 369
		while i < #nodes do -- 369
			if nodes[i + 1].depth > maxDepth then -- 369
				maxDepth = nodes[i + 1].depth -- 371
			end -- 371
			i = i + 1 -- 369
		end -- 369
	end -- 369
	local cx = 330 -- 374
	local yBot = -self.h / 2 + 140 -- 375
	local yTop = self.h / 2 - 190 -- 376
	local rows = maxDepth + 1 -- 377
	local rowH = rows <= 1 and 0 or math.min(96, (yTop - yBot) / (rows - 1)) -- 378
	local groups = {} -- 379
	do -- 379
		local d = 0 -- 380
		while d <= maxDepth do -- 380
			groups[#groups + 1] = {} -- 381
			d = d + 1 -- 380
		end -- 380
	end -- 380
	do -- 380
		local i = 0 -- 383
		while i < #nodes do -- 383
			local d = math.max( -- 384
				0, -- 384
				math.min(maxDepth, nodes[i + 1].depth) -- 384
			) -- 384
			local ____groups_index_2 = groups[d + 1] -- 384
			____groups_index_2[#____groups_index_2 + 1] = nodes[i + 1] -- 385
			i = i + 1 -- 383
		end -- 383
	end -- 383
	local pts = {} -- 387
	do -- 387
		local d = 0 -- 388
		while d < #groups do -- 388
			local g = groups[d + 1] -- 389
			local spacing = math.min( -- 390
				72, -- 390
				560 / math.max(1, #g) -- 390
			) -- 390
			do -- 390
				local i = 0 -- 391
				while i < #g do -- 391
					pts[#pts + 1] = {id = g[i + 1].id, x = cx + (i - (#g - 1) / 2) * spacing, y = yBot + d * rowH} -- 392
					i = i + 1 -- 391
				end -- 391
			end -- 391
			d = d + 1 -- 388
		end -- 388
	end -- 388
	local chain = chainOf(nodes, e.currentId) -- 395
	do -- 395
		local i = 0 -- 397
		while i < #nodes do -- 397
			do -- 397
				local n = nodes[i + 1] -- 398
				if n.parent == "" then -- 398
					goto __continue83 -- 400
				end -- 400
				local from = self:findPos(pts, n.parent) -- 402
				local to = self:findPos(pts, n.id) -- 403
				if from == nil or to == nil then -- 403
					goto __continue83 -- 405
				end -- 405
				local onChain = __TS__ArrayIndexOf(chain, n.id) >= 0 and __TS__ArrayIndexOf(chain, n.parent) >= 0 -- 407
				local lineColor = onChain and col(Palette.gold) or (n.abandoned and col(Palette.paleInkFar) or col(Palette.inkWash)) -- 408
				self.treeDraw:drawSegment( -- 409
					Vec2(from.x, from.y), -- 409
					Vec2(to.x, to.y), -- 409
					onChain and 3 or 2, -- 409
					lineColor -- 409
				) -- 409
			end -- 409
			::__continue83:: -- 409
			i = i + 1 -- 397
		end -- 397
	end -- 397
	do -- 397
		local i = 0 -- 412
		while i < #nodes do -- 412
			do -- 412
				local n = nodes[i + 1] -- 413
				local p = self:findPos(pts, n.id) -- 414
				if p == nil then -- 414
					goto __continue87 -- 416
				end -- 416
				local r = 10 -- 418
				local onChain = __TS__ArrayIndexOf(chain, n.id) >= 0 -- 419
				if n.id == e.currentId then -- 419
					self.treeDraw:drawDot( -- 422
						Vec2(p.x, p.y), -- 422
						r + 11, -- 422
						Color(Palette.gold.r, Palette.gold.g, Palette.gold.b, 80) -- 422
					) -- 422
					self.treeDraw:drawDot( -- 423
						Vec2(p.x, p.y), -- 423
						r + 5, -- 423
						col(Palette.gold) -- 423
					) -- 423
				elseif onChain then -- 423
					self.treeDraw:drawDot( -- 426
						Vec2(p.x, p.y), -- 426
						r + 3, -- 426
						col(Palette.goldSoft) -- 426
					) -- 426
				end -- 426
				local lit = n.abandoned and col(Palette.paleInkFar) or (onChain and col(Palette.moonWhite) or col(Palette.moonCyanSoft)) -- 428
				local rim = n.abandoned and col(Palette.paleInkFar) or col(Palette.moonCyanSoft) -- 429
				self.treeDraw:drawDot( -- 430
					Vec2(p.x, p.y), -- 430
					r, -- 430
					lit -- 430
				) -- 430
				self.treeDraw:drawDot( -- 431
					Vec2(p.x, p.y - r * 0.3), -- 431
					r * 0.55, -- 431
					col(ink(14, 17, 22, 255)) -- 431
				) -- 431
				if n.phase == 0 then -- 431
					self.treeDraw:drawDot( -- 433
						Vec2(p.x, p.y), -- 433
						r, -- 433
						col(ink(14, 17, 22, 255)) -- 433
					) -- 433
				end -- 433
			end -- 433
			::__continue87:: -- 433
			i = i + 1 -- 412
		end -- 412
	end -- 412
end -- 354
function TreeGallery.prototype.findPos(self, pts, id) -- 438
	do -- 438
		local i = 0 -- 439
		while i < #pts do -- 439
			if pts[i + 1].id == id then -- 439
				return pts[i + 1] -- 441
			end -- 441
			i = i + 1 -- 439
		end -- 439
	end -- 439
	return nil -- 444
end -- 438
return ____exports -- 438