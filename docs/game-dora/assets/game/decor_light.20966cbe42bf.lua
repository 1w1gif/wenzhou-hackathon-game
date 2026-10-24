-- [ts]: decor_light.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Node = ____Dora.Node -- 3
local Rect = ____Dora.Rect -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____palette = require("core.palette") -- 4
local ink = ____palette.ink -- 4
local ____render_chars = require("game.render_chars") -- 5
local dot = ____render_chars.dot -- 5
local LANTERN_COUNT = 5 -- 21
local LANTERN_FPS = 5 -- 22
local LANTERN_SCALE = 0.42 -- 23
local TORCH_FRAMES = 30 -- 24
local TORCH_FPS = 14 -- 25
local TORCH_SCALE = 1.15 -- 26
____exports.LightDecor = __TS__Class() -- 28
local LightDecor = ____exports.LightDecor -- 28
LightDecor.name = "LightDecor" -- 28
function LightDecor.prototype.____constructor(self, parent) -- 38
	self.lanternTex = {} -- 31
	self.lanterns = {} -- 33
	self.torches = {} -- 34
	self.t = 0 -- 35
	self.ok = false -- 36
	self.root = Node() -- 39
	self.root:addTo(parent) -- 40
	local anyTex = false -- 41
	do -- 41
		local i = 1 -- 42
		while i <= LANTERN_COUNT do -- 42
			do -- 42
				local tex = Texture2D(("assets/decor/lantern_" .. tostring(i)) .. ".png") -- 43
				if tex == nil then -- 43
					goto __continue4 -- 45
				end -- 45
				self.lanternTex[i - 1] = tex -- 47
				anyTex = true -- 48
			end -- 48
			::__continue4:: -- 48
			i = i + 1 -- 42
		end -- 42
	end -- 42
	if anyTex then -- 42
		self.ok = true -- 51
	end -- 51
	self.torchTex = Texture2D("assets/decor/torch.png") -- 53
	if self.torchTex ~= nil then -- 53
		self.ok = true -- 55
	end -- 55
	self.glow = DrawNode() -- 57
	self.glow:addTo(self.root) -- 58
end -- 38
function LightDecor.prototype.addLanterns(self, spots) -- 62
	if not self.ok then -- 62
		return -- 64
	end -- 64
	for ____, s in ipairs(spots) do -- 66
		local sprites = {} -- 67
		do -- 67
			local i = 0 -- 68
			while i < LANTERN_COUNT do -- 68
				do -- 68
					local tex = self.lanternTex[i] -- 69
					if tex == nil then -- 69
						goto __continue12 -- 71
					end -- 71
					local sp = Sprite(tex) -- 73
					sp.filter = "Point" -- 74
					sp.anchor = Vec2(0.5, 1) -- 75
					sp.scaleX = LANTERN_SCALE -- 76
					sp.scaleY = LANTERN_SCALE -- 77
					sp.position = Vec2(s.x, s.y) -- 78
					sp.visible = false -- 79
					sp:addTo(self.root) -- 80
					sprites[#sprites + 1] = sp -- 81
				end -- 81
				::__continue12:: -- 81
				i = i + 1 -- 68
			end -- 68
		end -- 68
		if #sprites > 0 then -- 68
			local ____self_lanterns_0 = self.lanterns -- 68
			____self_lanterns_0[#____self_lanterns_0 + 1] = {x = s.x, y = s.y, phase = s.x * 0.013 % 6.28, sprites = sprites} -- 84
		end -- 84
	end -- 84
end -- 62
function LightDecor.prototype.addTorches(self, spots) -- 90
	if self.torchTex == nil then -- 90
		return -- 92
	end -- 92
	for ____, s in ipairs(spots) do -- 94
		local sp = Sprite( -- 95
			self.torchTex, -- 95
			Rect(0, 0, 64, 64) -- 95
		) -- 95
		sp.filter = "Point" -- 96
		sp.anchor = Vec2(0.5, 0) -- 97
		sp.scaleX = TORCH_SCALE -- 98
		sp.scaleY = TORCH_SCALE -- 99
		sp.position = Vec2(s.x, s.y) -- 100
		sp:addTo(self.root) -- 101
		local ____self_torches_1 = self.torches -- 101
		____self_torches_1[#____self_torches_1 + 1] = {x = s.x, y = s.y, sp = sp, phase = s.x * 0.017 % 6.28} -- 102
	end -- 102
end -- 90
function LightDecor.prototype.update(self, time, dt) -- 106
	self.t = self.t + dt -- 107
	for ____, ln in ipairs(self.lanterns) do -- 108
		local idx = math.floor(self.t * LANTERN_FPS + ln.phase) % #ln.sprites -- 109
		do -- 109
			local j = 0 -- 110
			while j < #ln.sprites do -- 110
				ln.sprites[j + 1].visible = j == idx -- 111
				j = j + 1 -- 110
			end -- 110
		end -- 110
	end -- 110
	for ____, tc in ipairs(self.torches) do -- 114
		local idx = math.floor(self.t * TORCH_FPS + tc.phase * 2) % TORCH_FRAMES -- 115
		tc.sp.textureRect = Rect(idx * 64, 0, 64, 64) -- 116
	end -- 116
	self.glow:clear() -- 118
	for ____, ln in ipairs(self.lanterns) do -- 119
		dot( -- 120
			self.glow, -- 120
			ln.x, -- 120
			ln.y - 50, -- 120
			52, -- 120
			ink(255, 186, 96, 90), -- 120
			0.1 + 0.05 * math.sin(time * 3 + ln.phase) -- 120
		) -- 120
	end -- 120
	for ____, tc in ipairs(self.torches) do -- 122
		dot( -- 123
			self.glow, -- 123
			tc.x, -- 123
			tc.y + 40, -- 123
			40, -- 123
			ink(255, 150, 60, 110), -- 123
			0.12 + 0.06 * math.sin(time * 9 + tc.phase) -- 123
		) -- 123
	end -- 123
end -- 106
return ____exports -- 106