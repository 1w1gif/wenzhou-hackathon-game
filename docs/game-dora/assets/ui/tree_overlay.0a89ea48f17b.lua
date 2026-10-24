-- [ts]: tree_overlay.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
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
local ____tech_ui = require("ui.tech_ui") -- 6
local makeTechPanel = ____tech_ui.makeTechPanel -- 6
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
local PANEL_DARK = {r = 14, g = 17, b = 22, a = 255} -- 20
local function col(c) -- 43
	return Color(c.r, c.g, c.b, c.a) -- 44
end -- 43
--- 圆弧折线点集（角度制，y 向上）
local function circlePts(cx, cy, r, a0, a1, steps) -- 54
	local pts = {} -- 55
	do -- 55
		local i = 0 -- 56
		while i <= steps do -- 56
			local a = (a0 + (a1 - a0) * i / steps) * math.pi / 180 -- 57
			pts[#pts + 1] = Vec2( -- 58
				cx + math.cos(a) * r, -- 58
				cy + math.sin(a) * r -- 58
			) -- 58
			i = i + 1 -- 56
		end -- 56
	end -- 56
	return pts -- 60
end -- 54
local function phaseName(phase) -- 63
	return phase >= 0 and phase < #PHASE_NAMES and PHASE_NAMES[phase + 1] or "" -- 64
end -- 63
____exports.TreeOverlay = __TS__Class() -- 67
local TreeOverlay = ____exports.TreeOverlay -- 67
TreeOverlay.name = "TreeOverlay" -- 67
function TreeOverlay.prototype.____constructor(self, parent) -- 82
	self.layout = {} -- 83
	self.viaLbs = {} -- 84
	self.source = nil -- 85
	self.openFlag = false -- 86
	self.w = View.size.width -- 87
	self.h = View.size.height -- 88
	self.root = Node() -- 89
	self.root:addTo(parent) -- 90
	self.root.visible = false -- 91
	local hw = self.w / 2 -- 92
	local hh = self.h / 2 -- 93
	self.bgDraw = DrawNode() -- 95
	self.bgDraw:addTo(self.root) -- 96
	self.bgDraw:drawPolygon( -- 97
		{ -- 97
			Vec2(-hw, -hh), -- 97
			Vec2(hw, -hh), -- 97
			Vec2(hw, hh), -- 97
			Vec2(-hw, hh) -- 97
		}, -- 97
		Color(0, 0, 0, 205) -- 97
	) -- 97
	makeTechPanel(self.root, self.w - 36, self.h - 36) -- 98
	self.treeDraw = DrawNode() -- 100
	self.treeDraw:addTo(self.root) -- 101
	local note = makeText(14) -- 103
	if note ~= nil then -- 103
		note.text = "按第 N 夜分层 · 描金为当前世界线 · 点击节点跳回" -- 105
		note.anchor = Vec2(0.5, 0.5) -- 106
		note.position = Vec2(0, hh - 78) -- 107
		note.color = col(Palette.paleInk) -- 108
		note:addTo(self.root) -- 109
		self.noteLb = note -- 110
	end -- 110
	local stats = makeText(17) -- 113
	if stats ~= nil then -- 113
		stats.anchor = Vec2(0.5, 0.5) -- 115
		stats.position = Vec2(0, -hh + 82) -- 116
		stats.color = col(Palette.inkSoft) -- 117
		stats:addTo(self.root) -- 118
		self.statsLb = stats -- 119
	end -- 119
	local hint = makeText(14) -- 121
	if hint ~= nil then -- 121
		hint.text = "T 关闭 · 点击节点＝跳回该世界线（灰枝已放弃，永远保留可再跳回）" -- 123
		hint.anchor = Vec2(0.5, 0.5) -- 124
		hint.position = Vec2(0, -hh + 46) -- 125
		hint.color = col(Palette.paleInk) -- 126
		hint:addTo(self.root) -- 127
		self.hintLb = hint -- 128
	end -- 128
	self.hit = Node() -- 131
	self.hit.size = Size(self.w, self.h) -- 132
	self.hit.position = Vec2(0, 0) -- 133
	self.hit.touchEnabled = false -- 134
	self.hit:addTo(self.root) -- 135
	self.hit:onTapBegan(function(touch) -- 136
		if not self.openFlag or self.source == nil then -- 136
			return -- 138
		end -- 138
		local ____local = touch.location -- 140
		local px = ____local.x - self.w * 0.5 -- 141
		local py = ____local.y - self.h * 0.5 -- 142
		do -- 142
			local i = #self.layout - 1 -- 143
			while i >= 0 do -- 143
				local p = self.layout[i + 1] -- 144
				local dx = px - p.x -- 145
				local dy = py - p.y -- 146
				if dx * dx + dy * dy <= 784 then -- 146
					self:jumpToNode(self.source, p.id) -- 148
					return -- 149
				end -- 149
				i = i - 1 -- 143
			end -- 143
		end -- 143
	end) -- 136
end -- 82
function TreeOverlay.prototype.open(self, system) -- 154
	self.source = system -- 155
	self.openFlag = true -- 156
	self.root.visible = true -- 157
	self.hit.touchEnabled = true -- 158
	self:render(system) -- 159
end -- 154
function TreeOverlay.prototype.close(self) -- 162
	self.openFlag = false -- 163
	self.root.visible = false -- 164
	self.hit.touchEnabled = false -- 165
end -- 162
function TreeOverlay.prototype.toggle(self, system) -- 168
	if self.openFlag then -- 168
		self:close() -- 170
	else -- 170
		self:open(system) -- 172
	end -- 172
end -- 168
function TreeOverlay.prototype.isOpen(self) -- 176
	return self.openFlag -- 177
end -- 176
function TreeOverlay.prototype.render(self, system) -- 180
	self:computeLayout(system) -- 181
	self.treeDraw:clear() -- 182
	self:drawBranches(system) -- 183
	self:drawMoons(system) -- 184
	self:updateLabels(system) -- 185
	if self.statsLb ~= nil then -- 185
		self.statsLb.text = system:getStats() .. "　·　本树只增不减" -- 187
	end -- 187
end -- 180
function TreeOverlay.prototype.computeLayout(self, system) -- 192
	local pts = {} -- 193
	local maxDepth = 0 -- 194
	do -- 194
		local i = 0 -- 195
		while i < #system.nodes do -- 195
			if system.nodes[i + 1].depth > maxDepth then -- 195
				maxDepth = system.nodes[i + 1].depth -- 197
			end -- 197
			i = i + 1 -- 195
		end -- 195
	end -- 195
	local yBot = -self.h / 2 + 120 -- 200
	local yTop = self.h / 2 - 150 -- 201
	local rows = maxDepth + 1 -- 202
	local rowH = rows <= 1 and 0 or math.min(120, (yTop - yBot) / (rows - 1)) -- 203
	local groups = {} -- 204
	do -- 204
		local d = 0 -- 205
		while d <= maxDepth do -- 205
			groups[#groups + 1] = {} -- 206
			d = d + 1 -- 205
		end -- 205
	end -- 205
	do -- 205
		local i = 0 -- 208
		while i < #system.nodes do -- 208
			local n = system.nodes[i + 1] -- 209
			local d = math.max( -- 210
				0, -- 210
				math.min(maxDepth, n.depth) -- 210
			) -- 210
			local ____groups_index_0 = groups[d + 1] -- 210
			____groups_index_0[#____groups_index_0 + 1] = n -- 211
			i = i + 1 -- 208
		end -- 208
	end -- 208
	do -- 208
		local d = 0 -- 213
		while d < #groups do -- 213
			local g = groups[d + 1] -- 214
			local n = #g -- 215
			local spacing = math.min( -- 216
				150, -- 216
				(self.w - 220) / math.max(1, n) -- 216
			) -- 216
			do -- 216
				local i = 0 -- 217
				while i < n do -- 217
					pts[#pts + 1] = {id = g[i + 1].id, x = (i - (n - 1) / 2) * spacing, y = yBot + d * rowH} -- 218
					i = i + 1 -- 217
				end -- 217
			end -- 217
			d = d + 1 -- 213
		end -- 213
	end -- 213
	self.layout = pts -- 221
end -- 192
function TreeOverlay.prototype.findPos(self, id) -- 224
	do -- 224
		local i = 0 -- 225
		while i < #self.layout do -- 225
			if self.layout[i + 1].id == id then -- 225
				return self.layout[i + 1] -- 227
			end -- 227
			i = i + 1 -- 225
		end -- 225
	end -- 225
	return nil -- 230
end -- 224
function TreeOverlay.prototype.drawBranches(self, system) -- 234
	local chain = system:currentChain() -- 235
	do -- 235
		local i = 0 -- 236
		while i < #system.nodes do -- 236
			do -- 236
				local n = system.nodes[i + 1] -- 237
				if n.parent == "" then -- 237
					goto __continue44 -- 239
				end -- 239
				local from = self:findPos(n.parent) -- 241
				local to = self:findPos(n.id) -- 242
				if from == nil or to == nil then -- 242
					goto __continue44 -- 244
				end -- 244
				local onChain = __TS__ArrayIndexOf(chain, n.id) >= 0 and __TS__ArrayIndexOf(chain, n.parent) >= 0 -- 246
				local lineColor = onChain and col(Palette.gold) or (n.abandoned and col(Palette.paleInkFar) or col(Palette.inkWash)) -- 247
				local lineW = onChain and 3 or 2 -- 248
				self.treeDraw:drawSegment( -- 249
					Vec2(from.x, from.y), -- 249
					Vec2(to.x, to.y), -- 249
					lineW, -- 249
					lineColor -- 249
				) -- 249
			end -- 249
			::__continue44:: -- 249
			i = i + 1 -- 236
		end -- 236
	end -- 236
end -- 234
function TreeOverlay.prototype.drawMoons(self, system) -- 254
	do -- 254
		local i = 0 -- 255
		while i < #system.nodes do -- 255
			do -- 255
				local n = system.nodes[i + 1] -- 256
				local p = self:findPos(n.id) -- 257
				if p == nil then -- 257
					goto __continue49 -- 259
				end -- 259
				local r = 13 -- 261
				if n.id == system.currentId then -- 261
					self.treeDraw:drawDot( -- 263
						Vec2(p.x, p.y), -- 263
						r + 9, -- 263
						Color(Palette.gold.r, Palette.gold.g, Palette.gold.b, 70) -- 263
					) -- 263
					self.treeDraw:drawPolygon( -- 264
						circlePts( -- 264
							p.x, -- 264
							p.y, -- 264
							r + 5, -- 264
							0, -- 264
							360, -- 264
							24 -- 264
						), -- 264
						ink(0, 0, 0, 0), -- 264
						2, -- 264
						col(Palette.gold) -- 264
					) -- 264
				end -- 264
				self:drawMoonShape( -- 266
					p.x, -- 266
					p.y, -- 266
					r, -- 266
					n.phase, -- 266
					n.abandoned -- 266
				) -- 266
			end -- 266
			::__continue49:: -- 266
			i = i + 1 -- 255
		end -- 255
	end -- 255
end -- 254
function TreeOverlay.prototype.drawMoonShape(self, x, y, r, phase, abandoned) -- 270
	local lit = abandoned and col(Palette.paleInkFar) or col(Palette.moonWhite) -- 271
	local rim = abandoned and col(Palette.paleInkFar) or col(Palette.moonCyanSoft) -- 272
	local dark = col(PANEL_DARK) -- 273
	if phase == 0 then -- 273
		self.treeDraw:drawPolygon( -- 276
			circlePts( -- 276
				x, -- 276
				y, -- 276
				r, -- 276
				0, -- 276
				360, -- 276
				24 -- 276
			), -- 276
			ink(0, 0, 0, 0), -- 276
			2, -- 276
			rim -- 276
		) -- 276
		return -- 277
	end -- 277
	if phase == 1 or phase == 7 then -- 277
		local s = phase == 1 and 1 or -1 -- 281
		local pts = __TS__ArrayConcat( -- 282
			circlePts( -- 282
				x, -- 282
				y, -- 282
				r, -- 282
				s == 1 and -75 or 105, -- 282
				s == 1 and 75 or 255, -- 282
				12 -- 282
			), -- 282
			circlePts( -- 283
				x - s * r * 0.5, -- 283
				y, -- 283
				r * 0.9, -- 283
				s == 1 and 75 or 255, -- 283
				s == 1 and -75 or 105, -- 283
				12 -- 283
			) -- 283
		) -- 283
		self.treeDraw:drawPolygon(pts, lit, 1, rim) -- 284
		return -- 285
	end -- 285
	if phase == 2 or phase == 6 then -- 285
		local pts = __TS__ArrayConcat( -- 289
			circlePts( -- 289
				x, -- 289
				y, -- 289
				r, -- 289
				phase == 2 and -90 or 90, -- 289
				phase == 2 and 90 or 270, -- 289
				12 -- 289
			), -- 289
			{Vec2(x, y)} -- 289
		) -- 289
		self.treeDraw:drawPolygon(pts, lit, 1, rim) -- 290
		return -- 291
	end -- 291
	if phase == 3 or phase == 5 then -- 291
		self.treeDraw:drawPolygon( -- 295
			circlePts( -- 295
				x, -- 295
				y, -- 295
				r, -- 295
				0, -- 295
				360, -- 295
				24 -- 295
			), -- 295
			lit, -- 295
			1, -- 295
			rim -- 295
		) -- 295
		self.treeDraw:drawDot( -- 296
			Vec2(x + (phase == 3 and -r * 0.8 or r * 0.8), y), -- 296
			r * 0.62, -- 296
			dark -- 296
		) -- 296
		return -- 297
	end -- 297
	self.treeDraw:drawPolygon( -- 300
		circlePts( -- 300
			x, -- 300
			y, -- 300
			r, -- 300
			0, -- 300
			360, -- 300
			24 -- 300
		), -- 300
		lit, -- 300
		1, -- 300
		rim -- 300
	) -- 300
end -- 270
function TreeOverlay.prototype.updateLabels(self, system) -- 304
	local count = #system.nodes -- 305
	while #self.viaLbs < count do -- 305
		local lb = makeText(14) -- 307
		if lb == nil then -- 307
			break -- 309
		end -- 309
		lb.anchor = Vec2(0.5, 1) -- 311
		lb:addTo(self.root) -- 312
		local ____self_viaLbs_1 = self.viaLbs -- 312
		____self_viaLbs_1[#____self_viaLbs_1 + 1] = lb -- 313
	end -- 313
	do -- 313
		local i = 0 -- 315
		while i < #self.viaLbs do -- 315
			self.viaLbs[i + 1].visible = false -- 316
			i = i + 1 -- 315
		end -- 315
	end -- 315
	do -- 315
		local i = 0 -- 318
		while i < count do -- 318
			do -- 318
				local n = system.nodes[i + 1] -- 319
				local p = self:findPos(n.id) -- 320
				if p == nil or i >= #self.viaLbs then -- 320
					goto __continue63 -- 322
				end -- 322
				local lb = self.viaLbs[i + 1] -- 324
				lb.visible = true -- 325
				lb.text = (phaseName(n.phase) .. " · ") .. n.via -- 326
				lb.position = Vec2(p.x, p.y - 20) -- 327
				lb.color = n.id == system.currentId and col(Palette.gold) or (n.abandoned and col(Palette.paleInkFar) or col(Palette.paleInk)) -- 328
			end -- 328
			::__continue63:: -- 328
			i = i + 1 -- 318
		end -- 318
	end -- 318
end -- 304
function TreeOverlay.prototype.jumpToNode(self, system, id) -- 334
	if id == system.currentId then -- 334
		return -- 336
	end -- 336
	if system.onJumpTo ~= nil then -- 336
		system:onJumpTo(id) -- 339
	end -- 339
	system:jumpTo(id) -- 341
	self:render(system) -- 342
end -- 334
return ____exports -- 334