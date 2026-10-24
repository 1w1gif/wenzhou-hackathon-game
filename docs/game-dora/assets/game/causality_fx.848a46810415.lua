-- [ts]: causality_fx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local DUR = 1.1 -- 7
local FONT = "sarasa-mono-sc-regular" -- 8
local TINT = { -- 11
	rewind = {r = 214, g = 226, b = 235}, -- 12
	grow = {r = 168, g = 214, b = 156}, -- 13
	cut = {r = 196, g = 116, b = 104}, -- 14
	rescue = {r = 232, g = 202, b = 138}, -- 15
	fill = {r = 150, g = 190, b = 216} -- 16
} -- 16
____exports.CausalityFx = __TS__Class() -- 19
local CausalityFx = ____exports.CausalityFx -- 19
CausalityFx.name = "CausalityFx" -- 19
function CausalityFx.prototype.____constructor(self, parent) -- 26
	self.t = -1 -- 27
	self.kind = "rewind" -- 28
	self.root = Node() -- 29
	self.root:addTo(parent) -- 30
	self.root.visible = false -- 31
	self.draw = DrawNode() -- 32
	self.draw:addTo(self.root) -- 33
	local lb = Label(FONT, 30) -- 34
	if lb ~= nil then -- 34
		lb.anchor = Vec2(0.5, 0.5) -- 36
		lb.position = Vec2(0, -View.size.height / 2 + 130) -- 37
		lb.color = Color(255, 255, 255, 0) -- 38
		lb:addTo(self.root) -- 39
		self.caption = lb -- 40
	end -- 40
end -- 26
function CausalityFx.prototype.play(self, kind, caption) -- 44
	self.kind = kind -- 45
	self.t = 0 -- 46
	self.root.visible = true -- 47
	if self.caption ~= nil then -- 47
		self.caption.text = caption -- 49
	end -- 49
end -- 44
function CausalityFx.prototype.clear(self) -- 53
	self.t = -1 -- 54
	self.root.visible = false -- 55
	self.draw:clear() -- 56
end -- 53
function CausalityFx.prototype.isBusy(self) -- 59
	return self.t >= 0 -- 60
end -- 59
function CausalityFx.prototype.update(self, dt) -- 63
	if self.t < 0 then -- 63
		return -- 65
	end -- 65
	self.t = self.t + dt -- 67
	if self.t >= DUR then -- 67
		self:clear() -- 69
		return -- 70
	end -- 70
	local p = self.t / DUR -- 72
	local env = math.sin(p * math.pi) -- 73
	local w = View.size.width -- 74
	local h = View.size.height -- 75
	local c = TINT[self.kind] -- 76
	self.draw:clear() -- 77
	self.draw:drawPolygon( -- 79
		{ -- 80
			Vec2(-w / 2, -h / 2), -- 80
			Vec2(w / 2, -h / 2), -- 80
			Vec2(w / 2, h / 2), -- 80
			Vec2(-w / 2, h / 2) -- 80
		}, -- 80
		Color( -- 81
			c.r, -- 81
			c.g, -- 81
			c.b, -- 81
			math.floor(120 * env) -- 81
		) -- 81
	) -- 81
	local cy = h * 0.12 -- 84
	do -- 84
		local i = 0 -- 85
		while i < 3 do -- 85
			local pr = (p + i * 0.18) % 1 -- 86
			local r = 60 + pr * math.max(w, h) * 0.5 -- 87
			local pts = {} -- 88
			do -- 88
				local k = 0 -- 89
				while k <= 26 do -- 89
					local a = k / 26 * math.pi * 2 -- 90
					pts[#pts + 1] = Vec2( -- 91
						math.cos(a) * r, -- 91
						math.sin(a) * r + cy -- 91
					) -- 91
					k = k + 1 -- 89
				end -- 89
			end -- 89
			self.draw:drawPolygon( -- 93
				pts, -- 93
				Color( -- 93
					c.r, -- 93
					c.g, -- 93
					c.b, -- 93
					math.floor(60 * env) -- 93
				), -- 93
				2, -- 93
				Color( -- 93
					255, -- 93
					255, -- 93
					255, -- 93
					math.floor(210 * env) -- 93
				) -- 93
			) -- 93
			i = i + 1 -- 85
		end -- 85
	end -- 85
	if self.caption ~= nil then -- 85
		self.caption.color = Color( -- 96
			255, -- 96
			255, -- 96
			255, -- 96
			math.floor(255 * env) -- 96
		) -- 96
	end -- 96
end -- 63
return ____exports -- 63