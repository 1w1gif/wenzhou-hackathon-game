-- [ts]: boomfx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local KINDS = {big = {base = "exp", count = 10, fps = 15, scale = 1}, ring = {base = "cir", count = 10, fps = 15, scale = 0.9}} -- 12
____exports.BoomFxSystem = __TS__Class() -- 24
local BoomFxSystem = ____exports.BoomFxSystem -- 24
BoomFxSystem.name = "BoomFxSystem" -- 24
function BoomFxSystem.prototype.____constructor(self, parent) -- 30
	self.tex = {} -- 26
	self.actives = {} -- 27
	self.ok = false -- 28
	self.parent = parent -- 31
	local ok = true -- 32
	for k in pairs(KINDS) do -- 33
		local kd = KINDS[k] -- 34
		do -- 34
			local i = 0 -- 35
			while i < kd.count do -- 35
				local tex = Texture2D(((("assets/fx/boom/" .. kd.base) .. "_") .. tostring(i + 1)) .. ".png") -- 36
				if tex == nil then -- 36
					ok = false -- 38
				else -- 38
					self.tex[(k .. "_") .. tostring(i)] = tex -- 40
				end -- 40
				i = i + 1 -- 35
			end -- 35
		end -- 35
	end -- 35
	self.ok = ok -- 44
end -- 30
function BoomFxSystem.prototype.spawn(self, x, y, big) -- 48
	if not self.ok then -- 48
		return -- 50
	end -- 50
	local k = big and "big" or "ring" -- 52
	local kd = KINDS[k] -- 53
	if kd == nil then -- 53
		return -- 55
	end -- 55
	local sprites = {} -- 57
	do -- 57
		local i = 0 -- 58
		while i < kd.count do -- 58
			do -- 58
				local tex = self.tex[(k .. "_") .. tostring(i)] -- 59
				if tex == nil then -- 59
					goto __continue13 -- 61
				end -- 61
				local sp = Sprite(tex) -- 63
				sp.filter = "Point" -- 64
				sp.anchor = Vec2(0.5, 0.5) -- 65
				sp.position = Vec2(x, y) -- 66
				sp.scaleX = kd.scale -- 67
				sp.scaleY = kd.scale -- 68
				sp.visible = false -- 69
				sp:addTo(self.parent) -- 70
				sprites[#sprites + 1] = sp -- 71
			end -- 71
			::__continue13:: -- 71
			i = i + 1 -- 58
		end -- 58
	end -- 58
	if #sprites > 0 then -- 58
		local ____self_actives_0 = self.actives -- 58
		____self_actives_0[#____self_actives_0 + 1] = {sprites = sprites, count = #sprites, fps = kd.fps, t = 0} -- 74
	end -- 74
end -- 48
function BoomFxSystem.prototype.update(self, dt) -- 78
	local keep = {} -- 79
	for ____, fx in ipairs(self.actives) do -- 80
		do -- 80
			fx.t = fx.t + dt -- 81
			local idx = math.floor(fx.t * fx.fps) -- 82
			if idx >= fx.count then -- 82
				for ____, sp in ipairs(fx.sprites) do -- 84
					sp:removeFromParent() -- 85
				end -- 85
				goto __continue17 -- 87
			end -- 87
			do -- 87
				local j = 0 -- 89
				while j < #fx.sprites do -- 89
					fx.sprites[j + 1].visible = j == idx -- 90
					j = j + 1 -- 89
				end -- 89
			end -- 89
			keep[#keep + 1] = fx -- 92
		end -- 92
		::__continue17:: -- 92
	end -- 92
	self.actives = keep -- 94
end -- 78
function BoomFxSystem.prototype.clear(self) -- 97
	for ____, fx in ipairs(self.actives) do -- 98
		for ____, sp in ipairs(fx.sprites) do -- 99
			sp:removeFromParent() -- 100
		end -- 100
	end -- 100
	self.actives = {} -- 103
end -- 97
return ____exports -- 97