-- [ts]: slashfx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 5
local Color = ____Dora.Color -- 5
local DrawNode = ____Dora.DrawNode -- 5
local Rect = ____Dora.Rect -- 5
local Sprite = ____Dora.Sprite -- 5
local Texture2D = ____Dora.Texture2D -- 5
local Vec2 = ____Dora.Vec2 -- 5
local SWING_DUR = 0.16 -- 33
local ARC_DUR = 0.18 -- 34
local SWING_H = 96 -- 35
local SHOT_H = 66 -- 36
____exports.SlashFxSystem = __TS__Class() -- 38
local SlashFxSystem = ____exports.SlashFxSystem -- 38
SlashFxSystem.name = "SlashFxSystem" -- 38
function SlashFxSystem.prototype.____constructor(self, parent) -- 49
	self.parent = parent -- 50
	self.whiteTex = nil -- 51
	self.blueTex = nil -- 52
	self.whiteFrames = 0 -- 53
	self.blueFrames = 0 -- 54
	self.checked = false -- 55
	self.swings = {} -- 56
	self.arcs = {} -- 57
	self.shotSprites = {} -- 58
end -- 49
function SlashFxSystem.prototype.ensureTextures(self) -- 61
	if self.checked then -- 61
		return -- 63
	end -- 63
	self.checked = true -- 65
	local white = Texture2D("assets/effects/slash_white.png") -- 67
	if white ~= nil then -- 67
		self.whiteTex = white -- 69
		self.whiteFrames = math.max( -- 70
			1, -- 70
			math.floor(white.width / 64) -- 70
		) -- 70
	end -- 70
	local blue = Texture2D("assets/effects/slash_blue.png") -- 72
	if blue ~= nil then -- 72
		self.blueTex = blue -- 74
		self.blueFrames = math.max( -- 75
			1, -- 75
			math.floor(blue.width / 64) -- 75
		) -- 75
	end -- 75
end -- 61
function SlashFxSystem.prototype.hasBlueTex(self) -- 80
	self:ensureTextures() -- 81
	return self.blueTex ~= nil -- 82
end -- 80
function SlashFxSystem.prototype.spawnSwing(self, x, y, dir, blue) -- 86
	self:ensureTextures() -- 87
	local ____blue_0 -- 88
	if blue then -- 88
		____blue_0 = self.blueTex -- 88
	else -- 88
		____blue_0 = self.whiteTex -- 88
	end -- 88
	local tex = ____blue_0 -- 88
	local frames = blue and self.blueFrames or self.whiteFrames -- 89
	if tex ~= nil and frames > 0 then -- 89
		if #self.swings > 6 then -- 89
			return -- 92
		end -- 92
		local sp = Sprite( -- 94
			tex, -- 94
			Rect(0, 0, 64, 64) -- 94
		) -- 94
		if sp == nil then -- 94
			return -- 96
		end -- 96
		sp.filter = "Point" -- 98
		local k = SWING_H / 64 -- 99
		sp.scaleX = (dir >= 0 and 1 or -1) * k -- 100
		sp.scaleY = k -- 101
		sp.opacity = 255 -- 102
		sp.position = Vec2(x + dir * 36, y + 8) -- 103
		sp:addTo(self.parent) -- 104
		local ____self_swings_1 = self.swings -- 104
		____self_swings_1[#____self_swings_1 + 1] = { -- 105
			sprite = sp, -- 105
			baseX = x + dir * 36, -- 105
			baseY = y + 8, -- 105
			dir = dir, -- 105
			t = 0, -- 105
			dur = SWING_DUR, -- 105
			frames = frames -- 105
		} -- 105
		return -- 106
	end -- 106
	if #self.arcs > 6 then -- 106
		return -- 109
	end -- 109
	local draw = DrawNode() -- 111
	draw:addTo(self.parent) -- 112
	self:drawArc( -- 113
		draw, -- 113
		x, -- 113
		y, -- 113
		dir, -- 113
		blue, -- 113
		1 -- 113
	) -- 113
	local ____self_arcs_2 = self.arcs -- 113
	____self_arcs_2[#____self_arcs_2 + 1] = { -- 114
		draw = draw, -- 114
		x = x, -- 114
		y = y, -- 114
		dir = dir, -- 114
		blue = blue, -- 114
		t = 0, -- 114
		dur = ARC_DUR -- 114
	} -- 114
end -- 86
function SlashFxSystem.prototype.syncShots(self, items) -- 118
	self:ensureTextures() -- 119
	if self.blueTex == nil or self.blueFrames <= 0 then -- 119
		self:clearShots() -- 121
		return -- 122
	end -- 122
	local tex = self.blueTex -- 124
	while #self.shotSprites > #items do -- 124
		local sp = table.remove(self.shotSprites) -- 126
		if sp ~= nil then -- 126
			sp:removeFromParent() -- 128
		end -- 128
	end -- 128
	while #self.shotSprites < #items do -- 128
		local created = Sprite( -- 132
			tex, -- 132
			Rect( -- 132
				self:shotFrame() * 64, -- 132
				0, -- 132
				64, -- 132
				64 -- 132
			) -- 132
		) -- 132
		if created == nil then -- 132
			return -- 134
		end -- 134
		created.filter = "Point" -- 136
		created:addTo(self.parent) -- 137
		local ____self_shotSprites_3 = self.shotSprites -- 137
		____self_shotSprites_3[#____self_shotSprites_3 + 1] = created -- 138
	end -- 138
	local k = SHOT_H / 64 -- 140
	do -- 140
		local i = 0 -- 141
		while i < #self.shotSprites do -- 141
			local sp = self.shotSprites[i + 1] -- 142
			local it = items[i + 1] -- 143
			sp.position = Vec2(it.x, it.y) -- 144
			sp.scaleX = (it.dir >= 0 and 1 or -1) * k -- 145
			sp.scaleY = k -- 146
			i = i + 1 -- 141
		end -- 141
	end -- 141
end -- 118
function SlashFxSystem.prototype.shotFrame(self) -- 151
	return math.floor(self.blueFrames / 2) -- 152
end -- 151
function SlashFxSystem.prototype.clearShots(self) -- 155
	do -- 155
		local i = 0 -- 156
		while i < #self.shotSprites do -- 156
			self.shotSprites[i + 1]:removeFromParent() -- 157
			i = i + 1 -- 156
		end -- 156
	end -- 156
	__TS__ArraySetLength(self.shotSprites, 0) -- 156
end -- 155
function SlashFxSystem.prototype.update(self, dt) -- 162
	local i = #self.swings - 1 -- 163
	while i >= 0 do -- 163
		local s = self.swings[i + 1] -- 165
		s.t = s.t + dt -- 166
		if s.t >= s.dur then -- 166
			s.sprite:removeFromParent() -- 168
			__TS__ArraySplice(self.swings, i, 1) -- 169
		else -- 169
			local p = s.t / s.dur -- 171
			local idx = math.floor(p * s.frames + 0.0001) -- 172
			if idx > s.frames - 1 then -- 172
				idx = s.frames - 1 -- 174
			end -- 174
			s.sprite.textureRect = Rect(idx * 64, 0, 64, 64) -- 176
			s.sprite.opacity = math.floor(255 * (1 - p)) -- 177
			s.sprite.position = Vec2(s.baseX + s.dir * 54 * p, s.baseY) -- 178
		end -- 178
		i = i - 1 -- 180
	end -- 180
	i = #self.arcs - 1 -- 182
	while i >= 0 do -- 182
		local a = self.arcs[i + 1] -- 184
		a.t = a.t + dt -- 185
		if a.t >= a.dur then -- 185
			a.draw:removeFromParent() -- 187
			__TS__ArraySplice(self.arcs, i, 1) -- 188
		else -- 188
			a.draw:clear() -- 190
			self:drawArc( -- 191
				a.draw, -- 191
				a.x, -- 191
				a.y, -- 191
				a.dir, -- 191
				a.blue, -- 191
				1 - a.t / a.dur -- 191
			) -- 191
		end -- 191
		i = i - 1 -- 193
	end -- 193
end -- 162
function SlashFxSystem.prototype.clear(self) -- 197
	do -- 197
		local i = 0 -- 198
		while i < #self.swings do -- 198
			self.swings[i + 1].sprite:removeFromParent() -- 199
			i = i + 1 -- 198
		end -- 198
	end -- 198
	__TS__ArraySetLength(self.swings, 0) -- 198
	do -- 198
		local i = 0 -- 202
		while i < #self.arcs do -- 202
			self.arcs[i + 1].draw:removeFromParent() -- 203
			i = i + 1 -- 202
		end -- 202
	end -- 202
	__TS__ArraySetLength(self.arcs, 0) -- 202
	self:clearShots() -- 206
end -- 197
function SlashFxSystem.prototype.drawArc(self, draw, x, y, dir, blue, alpha) -- 210
	local c = blue and Color(130, 180, 255, 255) or Color(255, 255, 255, 255) -- 211
	local layers = {{s = 0.78, ox = -30, a = 70}, {s = 0.92, ox = -12, a = 120}, {s = 1, ox = 0, a = 200}} -- 212
	do -- 212
		local i = 0 -- 217
		while i < #layers do -- 217
			local L = layers[i + 1] -- 218
			draw:drawPolygon( -- 219
				self:crescent( -- 219
					x, -- 219
					y, -- 219
					dir, -- 219
					L.s, -- 219
					L.ox -- 219
				), -- 219
				Color( -- 219
					c.r, -- 219
					c.g, -- 219
					c.b, -- 219
					math.floor(L.a * alpha) -- 219
				) -- 219
			) -- 219
			i = i + 1 -- 217
		end -- 217
	end -- 217
	draw:drawPolygon( -- 221
		self:crescent( -- 221
			x, -- 221
			y, -- 221
			dir, -- 221
			0.55, -- 221
			6 -- 221
		), -- 221
		Color( -- 221
			255, -- 221
			255, -- 221
			255, -- 221
			math.floor(210 * alpha) -- 221
		) -- 221
	) -- 221
end -- 210
function SlashFxSystem.prototype.crescent(self, x, y, dir, scale, ox) -- 224
	local pts = {} -- 225
	local R = 44 * scale -- 226
	local aOut = 1.45 -- 227
	do -- 227
		local k = 0 -- 228
		while k <= 10 do -- 228
			local t = aOut - 2 * aOut * k / 10 -- 229
			pts[#pts + 1] = Vec2( -- 230
				x + dir * (ox + R * math.cos(t)), -- 230
				y + R * math.sin(t) -- 230
			) -- 230
			k = k + 1 -- 228
		end -- 228
	end -- 228
	local c2 = -0.6 * R -- 232
	local ri = 1.2266 * R -- 233
	local aIn = 0.9425 -- 234
	do -- 234
		local k = 0 -- 235
		while k <= 10 do -- 235
			local t = -aIn + 2 * aIn * k / 10 -- 236
			pts[#pts + 1] = Vec2( -- 237
				x + dir * (ox + c2 + ri * math.cos(t)), -- 237
				y + ri * math.sin(t) -- 237
			) -- 237
			k = k + 1 -- 235
		end -- 235
	end -- 235
	return pts -- 239
end -- 224
return ____exports -- 224