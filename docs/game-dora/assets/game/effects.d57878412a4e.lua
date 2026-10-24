-- [ts]: effects.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Vec2 = ____Dora.Vec2 -- 2
local Color = ____Dora.Color -- 2
local ____palette = require("core.palette") -- 3
local Palette = ____palette.Palette -- 3
local RING_SEGS = 18 -- 22
____exports.EffectSystem = __TS__Class() -- 24
local EffectSystem = ____exports.EffectSystem -- 24
EffectSystem.name = "EffectSystem" -- 24
function EffectSystem.prototype.____constructor(self) -- 29
	self.parts = {} -- 30
	self.sheetHook = nil -- 31
end -- 29
function EffectSystem.prototype.push(self, p) -- 34
	if #self.parts < 600 then -- 34
		local ____self_parts_0 = self.parts -- 34
		____self_parts_0[#____self_parts_0 + 1] = p -- 36
	end -- 36
end -- 34
function EffectSystem.prototype.spawnMist(self, x, y, count, scale) -- 41
	do -- 41
		local i = 0 -- 42
		while i < count do -- 42
			local a = math.random() * math.pi * 2 -- 43
			local sp = 30 + math.random() * 90 * scale -- 44
			self:push({ -- 45
				kind = "mist", -- 46
				x = x + (math.random() - 0.5) * 30 * scale, -- 47
				y = y + math.random() * 40 * scale, -- 48
				vx = math.cos(a) * sp, -- 49
				vy = math.sin(a) * sp * 0.6 + 40, -- 50
				life = 0.9 + math.random() * 0.8, -- 51
				maxLife = 1.7, -- 52
				size = (10 + math.random() * 16) * scale, -- 53
				grow = 26 * scale, -- 54
				gravity = -30, -- 55
				color = i % 3 == 0 and Palette.mistLight or Palette.mist, -- 56
				phase = math.random() * 6.28 -- 57
			}) -- 57
			i = i + 1 -- 42
		end -- 42
	end -- 42
	if self.sheetHook ~= nil then -- 42
		self.sheetHook(x, y + 26, 1, true) -- 62
	end -- 62
end -- 41
function EffectSystem.prototype.spawnInkBurst(self, x, y, dir) -- 67
	do -- 67
		local i = 0 -- 68
		while i < 8 do -- 68
			self:push({ -- 69
				kind = "drop", -- 70
				x = x, -- 71
				y = y + (math.random() - 0.5) * 20, -- 72
				vx = dir * (60 + math.random() * 220) + (math.random() - 0.5) * 80, -- 73
				vy = 60 + math.random() * 220, -- 74
				life = 0.4 + math.random() * 0.3, -- 75
				maxLife = 0.7, -- 76
				size = 2 + math.random() * 3.5, -- 77
				grow = 0, -- 78
				gravity = 900, -- 79
				color = Palette.inkDark, -- 80
				phase = 0 -- 81
			}) -- 81
			i = i + 1 -- 68
		end -- 68
	end -- 68
end -- 67
function EffectSystem.prototype.spawnRing(self, x, y, color, size, grow, life) -- 87
	self:push({ -- 88
		kind = "ring", -- 89
		x = x, -- 90
		y = y, -- 91
		vx = 0, -- 92
		vy = 0, -- 93
		life = life, -- 94
		maxLife = life, -- 95
		size = size, -- 96
		grow = grow, -- 97
		gravity = 0, -- 98
		color = color, -- 99
		phase = 0 -- 100
	}) -- 100
end -- 87
function EffectSystem.prototype.spawnDust(self, x, y, dir) -- 104
	do -- 104
		local i = 0 -- 105
		while i < 6 do -- 105
			self:push({ -- 106
				kind = "dust", -- 107
				x = x + (math.random() - 0.5) * 16, -- 108
				y = y, -- 109
				vx = dir * (30 + math.random() * 90) + (math.random() - 0.5) * 60, -- 110
				vy = 20 + math.random() * 70, -- 111
				life = 0.35 + math.random() * 0.25, -- 112
				maxLife = 0.6, -- 113
				size = 3 + math.random() * 4, -- 114
				grow = 8, -- 115
				gravity = 60, -- 116
				color = Palette.paleInk, -- 117
				phase = 0 -- 118
			}) -- 118
			i = i + 1 -- 105
		end -- 105
	end -- 105
end -- 104
function EffectSystem.prototype.spawnSpark(self, x, y, dir) -- 123
	do -- 123
		local i = 0 -- 124
		while i < 5 do -- 124
			self:push({ -- 125
				kind = "spark", -- 126
				x = x, -- 127
				y = y + (math.random() - 0.5) * 24, -- 128
				vx = dir * (200 + math.random() * 320), -- 129
				vy = (math.random() - 0.5) * 260, -- 130
				life = 0.12 + math.random() * 0.12, -- 131
				maxLife = 0.24, -- 132
				size = 2, -- 133
				grow = 0, -- 134
				gravity = 0, -- 135
				color = Palette.moonCyan, -- 136
				phase = 0 -- 137
			}) -- 137
			i = i + 1 -- 124
		end -- 124
	end -- 124
	if self.sheetHook ~= nil then -- 124
		self.sheetHook(x, y, dir, false) -- 141
	end -- 141
end -- 123
function EffectSystem.prototype.spawnStars(self, x, y, n) -- 145
	do -- 145
		local i = 0 -- 146
		while i < n do -- 146
			local a = math.random() * math.pi * 2 -- 147
			local sp = 40 + math.random() * 120 -- 148
			self:push({ -- 149
				kind = "star", -- 150
				x = x, -- 151
				y = y, -- 152
				vx = math.cos(a) * sp, -- 153
				vy = math.sin(a) * sp + 60, -- 154
				life = 0.6 + math.random() * 0.5, -- 155
				maxLife = 1.1, -- 156
				size = 2 + math.random() * 2.5, -- 157
				grow = 0, -- 158
				gravity = 140, -- 159
				color = Palette.moonCyan, -- 160
				phase = math.random() * 6.28 -- 161
			}) -- 161
			i = i + 1 -- 146
		end -- 146
	end -- 146
end -- 145
function EffectSystem.prototype.spawnEmber(self, x, y) -- 167
	self:push({ -- 168
		kind = "ember", -- 169
		x = x + (math.random() - 0.5) * 8, -- 170
		y = y, -- 171
		vx = (math.random() - 0.5) * 20, -- 172
		vy = 30 + math.random() * 50, -- 173
		life = 0.5 + math.random() * 0.4, -- 174
		maxLife = 0.9, -- 175
		size = 2 + math.random() * 2, -- 176
		grow = 0, -- 177
		gravity = -40, -- 178
		color = Palette.vermilion, -- 179
		phase = 0 -- 180
	}) -- 180
end -- 167
function EffectSystem.prototype.spawnRopeCut(self, x, y) -- 185
	do -- 185
		local i = 0 -- 186
		while i < 10 do -- 186
			self:push({ -- 187
				kind = "drop", -- 188
				x = x + (math.random() - 0.5) * 8, -- 189
				y = y + (math.random() - 0.5) * 20, -- 190
				vx = (math.random() - 0.5) * 180, -- 191
				vy = -40 + math.random() * 160, -- 192
				life = 0.5 + math.random() * 0.3, -- 193
				maxLife = 0.8, -- 194
				size = 1.5 + math.random() * 2, -- 195
				grow = 0, -- 196
				gravity = 700, -- 197
				color = Palette.gold, -- 198
				phase = 0 -- 199
			}) -- 199
			i = i + 1 -- 186
		end -- 186
	end -- 186
end -- 185
function EffectSystem.prototype.update(self, dt) -- 204
	local w = 0 -- 205
	do -- 205
		local i = 0 -- 206
		while i < #self.parts do -- 206
			do -- 206
				local p = self.parts[i + 1] -- 207
				p.life = p.life - dt -- 208
				if p.life <= 0 then -- 208
					goto __continue29 -- 210
				end -- 210
				p.vy = p.vy + p.gravity * dt -- 212
				p.x = p.x + p.vx * dt -- 213
				p.y = p.y + p.vy * dt -- 214
				p.size = p.size + p.grow * dt -- 215
				self.parts[w + 1] = p -- 216
				w = w + 1 -- 217
			end -- 217
			::__continue29:: -- 217
			i = i + 1 -- 206
		end -- 206
	end -- 206
	__TS__ArraySetLength(self.parts, w) -- 206
end -- 204
function EffectSystem.prototype.draw(self, draw) -- 222
	do -- 222
		local i = 0 -- 223
		while i < #self.parts do -- 223
			local p = self.parts[i + 1] -- 224
			local t = p.life / p.maxLife -- 225
			local alpha = math.max( -- 226
				0, -- 226
				math.min(1, t) -- 226
			) -- 226
			local c = Color( -- 227
				p.color.r, -- 227
				p.color.g, -- 227
				p.color.b, -- 227
				math.floor(p.color.a * alpha) -- 227
			) -- 227
			if p.kind == "ring" then -- 227
				local r = p.size -- 229
				local segs = RING_SEGS -- 230
				do -- 230
					local s = 0 -- 231
					while s < segs do -- 231
						local a0 = s / segs * math.pi * 2 + p.phase -- 232
						local a1 = (s + 1) / segs * math.pi * 2 + p.phase -- 233
						draw:drawSegment( -- 234
							Vec2( -- 235
								p.x + math.cos(a0) * r, -- 235
								p.y + math.sin(a0) * r -- 235
							), -- 235
							Vec2( -- 236
								p.x + math.cos(a1) * r, -- 236
								p.y + math.sin(a1) * r -- 236
							), -- 236
							2.5, -- 237
							c -- 238
						) -- 238
						s = s + 1 -- 231
					end -- 231
				end -- 231
			elseif p.kind == "spark" then -- 231
				draw:drawSegment( -- 242
					Vec2(p.x, p.y), -- 242
					Vec2(p.x - p.vx * 0.03, p.y - p.vy * 0.03), -- 242
					p.size, -- 242
					c -- 242
				) -- 242
			elseif p.kind == "star" then -- 242
				local s = p.size * (0.6 + 0.4 * math.sin(p.phase + p.life * 10)) -- 245
				draw:drawSegment( -- 246
					Vec2(p.x - s, p.y), -- 246
					Vec2(p.x + s, p.y), -- 246
					1.5, -- 246
					c -- 246
				) -- 246
				draw:drawSegment( -- 247
					Vec2(p.x, p.y - s), -- 247
					Vec2(p.x, p.y + s), -- 247
					1.5, -- 247
					c -- 247
				) -- 247
			else -- 247
				draw:drawDot( -- 249
					Vec2(p.x, p.y), -- 249
					p.size * (0.5 + 0.5 * alpha), -- 249
					c -- 249
				) -- 249
			end -- 249
			i = i + 1 -- 223
		end -- 223
	end -- 223
end -- 222
function EffectSystem.prototype.count(self) -- 254
	return #self.parts -- 255
end -- 254
function EffectSystem.prototype.clearAll(self) -- 258
	__TS__ArraySetLength(self.parts, 0) -- 258
end -- 258
return ____exports -- 258