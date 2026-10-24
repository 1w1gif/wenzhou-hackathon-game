-- [ts]: sheetfx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Rect = ____Dora.Rect -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local SHEETS = {big = { -- 17
	file = "assets/effects/hit-effect-1.png", -- 18
	frameW = 128, -- 18
	frameH = 128, -- 18
	frames = 6, -- 18
	fps = 20, -- 18
	scale = 1.4 -- 18
}, hit = { -- 18
	file = "assets/effects/hit-effect-2.png", -- 19
	frameW = 64, -- 19
	frameH = 64, -- 19
	frames = 5, -- 19
	fps = 22, -- 19
	scale = 1.6 -- 19
}} -- 19
____exports.SheetFxSystem = __TS__Class() -- 29
local SheetFxSystem = ____exports.SheetFxSystem -- 29
SheetFxSystem.name = "SheetFxSystem" -- 29
function SheetFxSystem.prototype.____constructor(self, parent) -- 34
	self.parent = parent -- 35
	self.actives = {} -- 36
	self.tex = {} -- 37
end -- 34
function SheetFxSystem.prototype.texture(self, file) -- 40
	local cached = self.tex[file] -- 41
	if cached ~= nil then -- 41
		return cached -- 43
	end -- 43
	local loaded = Texture2D(file) -- 45
	self.tex[file] = loaded -- 46
	return loaded -- 47
end -- 40
function SheetFxSystem.prototype.spawn(self, x, y, dir, big) -- 51
	if #self.actives > 24 then -- 51
		return -- 53
	end -- 53
	local def = big and SHEETS.big or SHEETS.hit -- 55
	local tex = self:texture(def.file) -- 56
	if tex == nil then -- 56
		return -- 58
	end -- 58
	local sp = Sprite( -- 60
		tex, -- 60
		Rect(0, 0, def.frameW, def.frameH) -- 60
	) -- 60
	sp.filter = "Point" -- 61
	sp.position = Vec2(x, y) -- 62
	sp.scaleX = (dir >= 0 and 1 or -1) * def.scale -- 63
	sp.scaleY = def.scale -- 64
	sp:addTo(self.parent) -- 65
	local ____self_actives_0 = self.actives -- 65
	____self_actives_0[#____self_actives_0 + 1] = {sprite = sp, def = def, t = 0, dur = def.frames / def.fps} -- 66
end -- 51
function SheetFxSystem.prototype.update(self, dt) -- 69
	local i = #self.actives - 1 -- 70
	while i >= 0 do -- 70
		local a = self.actives[i + 1] -- 72
		a.t = a.t + dt -- 73
		if a.t >= a.dur then -- 73
			a.sprite:removeFromParent() -- 75
			__TS__ArraySplice(self.actives, i, 1) -- 76
		else -- 76
			local idx = math.floor(a.t * a.def.fps) -- 78
			if idx >= a.def.frames then -- 78
				idx = a.def.frames - 1 -- 80
			end -- 80
			a.sprite.textureRect = Rect(idx * a.def.frameW, 0, a.def.frameW, a.def.frameH) -- 82
		end -- 82
		i = i - 1 -- 84
	end -- 84
end -- 69
function SheetFxSystem.prototype.clear(self) -- 88
	do -- 88
		local i = 0 -- 89
		while i < #self.actives do -- 89
			self.actives[i + 1].sprite:removeFromParent() -- 90
			i = i + 1 -- 89
		end -- 89
	end -- 89
	self.actives = {} -- 92
end -- 88
return ____exports -- 88