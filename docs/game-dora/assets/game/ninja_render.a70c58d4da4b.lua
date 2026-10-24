-- [ts]: ninja_render.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Rect = ____Dora.Rect -- 8
local Sprite = ____Dora.Sprite -- 8
local Texture2D = ____Dora.Texture2D -- 8
local Vec2 = ____Dora.Vec2 -- 8
local KINDS = {bandit = { -- 27
	char = "peasant", -- 30
	cell = 96, -- 30
	scale = 1.3, -- 30
	faceRight = true, -- 30
	anims = { -- 31
		idle = {frames = 6, fps = 6, loop = true}, -- 32
		run = {frames = 6, fps = 10, loop = true}, -- 33
		walk = {frames = 8, fps = 8, loop = true}, -- 34
		jump = {frames = 8, fps = 8, loop = false}, -- 35
		attack_1 = {frames = 6, fps = 14, loop = false}, -- 36
		attack_2 = {frames = 4, fps = 14, loop = false}, -- 37
		hurt = {frames = 2, fps = 10, loop = false}, -- 38
		dead = {frames = 4, fps = 10, loop = false} -- 39
	} -- 39
}, thrower = { -- 39
	char = "kunoichi", -- 44
	cell = 128, -- 44
	scale = 1.38, -- 44
	faceRight = true, -- 44
	anims = { -- 45
		idle = {frames = 9, fps = 6, loop = true}, -- 46
		run = {frames = 8, fps = 10, loop = true}, -- 47
		walk = {frames = 8, fps = 8, loop = true}, -- 48
		jump = {frames = 10, fps = 8, loop = false}, -- 49
		attack_1 = {frames = 6, fps = 14, loop = false}, -- 50
		attack_2 = {frames = 8, fps = 14, loop = false}, -- 51
		hurt = {frames = 2, fps = 10, loop = false}, -- 52
		dead = {frames = 5, fps = 10, loop = false} -- 53
	} -- 53
}, boss = { -- 53
	char = "monk", -- 58
	cell = 96, -- 58
	scale = 1.43, -- 58
	faceRight = true, -- 58
	anims = { -- 59
		idle = {frames = 7, fps = 6, loop = true}, -- 60
		run = {frames = 8, fps = 10, loop = true}, -- 61
		walk = {frames = 7, fps = 8, loop = true}, -- 62
		jump = {frames = 9, fps = 8, loop = false}, -- 63
		attack_1 = {frames = 5, fps = 12, loop = false}, -- 64
		attack_2 = {frames = 5, fps = 12, loop = false}, -- 65
		hurt = {frames = 4, fps = 10, loop = false}, -- 66
		dead = {frames = 5, fps = 10, loop = false} -- 67
	} -- 67
}} -- 67
local FSM_ANIM = { -- 73
	patrol = "walk", -- 74
	chase = "run", -- 75
	windup = "idle", -- 76
	telegraph = "idle", -- 77
	swing = "attack_1", -- 78
	recover = "idle", -- 79
	hurt = "hurt", -- 80
	charge = "run", -- 81
	throw = "attack_2", -- 82
	dead = "dead" -- 83
} -- 83
local ARCHER_DIR = "assets/characters/archer" -- 92
local ARCHER_SCALE = 0.74 -- 93
local ARCHER_GROUND_OFFSET = 10 -- 96
local ARCHER_FSM = { -- 97
	patrol = "idle", -- 98
	chase = "walk", -- 99
	windup = "idle", -- 100
	telegraph = "idle", -- 101
	swing = "idle", -- 102
	recover = "idle", -- 103
	hurt = "idle", -- 104
	charge = "walk", -- 105
	throw = "idle", -- 106
	dead = "idle" -- 107
} -- 107
local ARCHER_ANIMS = {idle = {frames = 12, fps = 10, loop = true}, walk = {frames = 12, fps = 12, loop = true}} -- 114
____exports.NinjaLayer = __TS__Class() -- 134
local NinjaLayer = ____exports.NinjaLayer -- 134
NinjaLayer.name = "NinjaLayer" -- 134
function NinjaLayer.prototype.____constructor(self, root) -- 145
	self.texSets = {} -- 136
	self.kindOk = {} -- 137
	self.slots = {} -- 138
	self.frameDt = 0 -- 139
	self.archerTex = {} -- 141
	self.archerOk = false -- 142
	self.ok = false -- 143
	self.root = root -- 146
	local allOk = true -- 147
	for kind in pairs(KINDS) do -- 148
		local kd = KINDS[kind] -- 149
		local set = {} -- 150
		local kindOk = true -- 151
		for anim in pairs(kd.anims) do -- 152
			local def = kd.anims[anim] -- 153
			local tex = Texture2D(((("assets/enemies/ninja/" .. kd.char) .. "_") .. anim) .. ".png") -- 154
			if tex == nil then -- 154
				kindOk = false -- 156
				break -- 157
			end -- 157
			set[anim] = {tex = tex, def = def, fw = kd.cell, fh = kd.cell} -- 159
		end -- 159
		self.texSets[kind] = set -- 161
		self.kindOk[kind] = kindOk -- 162
		if not kindOk then -- 162
			allOk = false -- 164
		end -- 164
	end -- 164
	local archerOk = true -- 168
	for animName in pairs(ARCHER_ANIMS) do -- 169
		local adef = ARCHER_ANIMS[animName] -- 170
		for ____, dir in ipairs({"east", "west"}) do -- 171
			local key = (animName .. "_") .. dir -- 172
			local list = {} -- 173
			do -- 173
				local i = 0 -- 174
				while i < adef.frames do -- 174
					local nn = (i < 10 and "0" or "") .. tostring(i) -- 175
					local tex = Texture2D(((((ARCHER_DIR .. "/") .. key) .. "/") .. nn) .. ".png") -- 176
					if tex == nil then -- 176
						archerOk = false -- 178
						break -- 179
					end -- 179
					list[#list + 1] = tex -- 181
					i = i + 1 -- 174
				end -- 174
			end -- 174
			if not archerOk then -- 174
				break -- 184
			end -- 184
			self.archerTex[key] = list -- 186
		end -- 186
		if not archerOk then -- 186
			break -- 189
		end -- 189
	end -- 189
	self.archerOk = archerOk -- 192
	if not archerOk then -- 192
		allOk = false -- 194
	end -- 194
	self.ok = allOk -- 196
end -- 145
function NinjaLayer.prototype.beginFrame(self, dt) -- 199
	self.frameDt = dt -- 200
end -- 199
function NinjaLayer.prototype.hideSlot(self, s) -- 203
	for k in pairs(s.sprites) do -- 204
		s.sprites[k].visible = false -- 205
	end -- 205
end -- 203
function NinjaLayer.prototype.endFrame(self) -- 210
	for id in pairs(self.slots) do -- 211
		do -- 211
			local s = self.slots[id] -- 212
			if not s.used then -- 212
				self:hideSlot(s) -- 214
				__TS__Delete(self.slots, id) -- 215
				goto __continue24 -- 216
			end -- 216
			s.used = false -- 218
		end -- 218
		::__continue24:: -- 218
	end -- 218
end -- 210
function NinjaLayer.prototype.drawEnemy(self, e) -- 223
	if e.def.kind == "archer" then -- 223
		return self:drawArcher(e) -- 225
	end -- 225
	local kd = KINDS[e.def.kind] -- 227
	if kd == nil or self.kindOk[e.def.kind] ~= true then -- 227
		return false -- 229
	end -- 229
	local set = self.texSets[e.def.kind] -- 231
	local wantRaw = FSM_ANIM[e.state] -- 232
	local want = wantRaw == nil and "idle" or wantRaw -- 233
	local slot = self.slots[e.def.id] -- 234
	if slot == nil then -- 234
		slot = {anim = want, t = 0, used = true, sprites = {}} -- 236
		self.slots[e.def.id] = slot -- 237
	end -- 237
	if want ~= slot.anim then -- 237
		slot.anim = want -- 240
		slot.t = 0 -- 241
	else -- 241
		slot.t = slot.t + self.frameDt -- 243
	end -- 243
	local at = set[slot.anim] -- 245
	if at == nil then -- 245
		return false -- 247
	end -- 247
	slot.used = true -- 249
	for k in pairs(slot.sprites) do -- 250
		if k ~= slot.anim then -- 250
			slot.sprites[k].visible = false -- 252
		end -- 252
	end -- 252
	local sp = slot.sprites[slot.anim] -- 255
	if sp == nil then -- 255
		sp = Sprite( -- 257
			at.tex, -- 257
			Rect(0, 0, at.fw, at.fh) -- 257
		) -- 257
		sp.filter = "Point" -- 258
		sp.anchor = Vec2(0.5, 0) -- 259
		sp:addTo(self.root) -- 260
		slot.sprites[slot.anim] = sp -- 261
	end -- 261
	local idx = math.floor(slot.t * at.def.fps) -- 263
	if at.def.loop then -- 263
		idx = idx % at.def.frames -- 265
	elseif idx > at.def.frames - 1 then -- 265
		idx = at.def.frames - 1 -- 267
	end -- 267
	local face = e.facing * (kd.faceRight and 1 or -1) -- 269
	sp.visible = true -- 270
	sp.position = Vec2(e.body.x, e.body.y - e.body.h / 2) -- 271
	sp.scaleX = kd.scale * face -- 272
	sp.scaleY = kd.scale -- 273
	sp.textureRect = Rect(idx * at.fw, 0, at.fw, at.fh) -- 274
	if e.dead then -- 274
		local dt2 = e.deathTimer == nil and 0 or e.deathTimer -- 276
		sp.opacity = math.floor(255 * math.max( -- 277
			0, -- 277
			math.min(1, dt2 / 0.55) -- 277
		)) -- 277
	else -- 277
		sp.opacity = 255 -- 279
	end -- 279
	return true -- 281
end -- 223
function NinjaLayer.prototype.drawArcher(self, e) -- 288
	if not self.archerOk then -- 288
		return false -- 290
	end -- 290
	local wantRaw = ARCHER_FSM[e.state] -- 292
	local want = wantRaw == nil and "idle" or wantRaw -- 293
	local key = (want .. "_") .. (e.facing >= 0 and "east" or "west") -- 294
	local list = self.archerTex[key] -- 295
	local def = ARCHER_ANIMS[want] -- 296
	if list == nil or def == nil then -- 296
		return false -- 298
	end -- 298
	local slot = self.slots[e.def.id] -- 300
	if slot == nil then -- 300
		slot = {anim = key, t = 0, used = true, sprites = {}} -- 302
		self.slots[e.def.id] = slot -- 303
	end -- 303
	if slot.anim ~= key then -- 303
		slot.anim = key -- 306
		slot.t = 0 -- 307
	else -- 307
		slot.t = slot.t + self.frameDt -- 309
	end -- 309
	slot.used = true -- 311
	local idx = math.floor(slot.t * def.fps) % def.frames -- 312
	local frameKey = (key .. "_") .. tostring(idx) -- 313
	for k in pairs(slot.sprites) do -- 314
		if k ~= frameKey then -- 314
			slot.sprites[k].visible = false -- 316
		end -- 316
	end -- 316
	local sp = slot.sprites[frameKey] -- 319
	if sp == nil then -- 319
		sp = Sprite(list[idx + 1]) -- 321
		sp.filter = "Point" -- 322
		sp.anchor = Vec2(0.5, 0) -- 323
		sp:addTo(self.root) -- 324
		slot.sprites[frameKey] = sp -- 325
	end -- 325
	sp.visible = true -- 327
	sp.position = Vec2(e.body.x, e.body.y - e.body.h / 2 - ARCHER_GROUND_OFFSET) -- 328
	sp.scaleX = ARCHER_SCALE -- 329
	sp.scaleY = ARCHER_SCALE -- 330
	if e.dead then -- 330
		local dt2 = e.deathTimer == nil and 0 or e.deathTimer -- 332
		sp.opacity = math.floor(255 * math.max( -- 333
			0, -- 333
			math.min(1, dt2 / 0.55) -- 333
		)) -- 333
	else -- 333
		sp.opacity = 255 -- 335
	end -- 335
	return true -- 337
end -- 288
return ____exports -- 288