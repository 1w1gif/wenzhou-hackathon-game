-- [ts]: hero_frames.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local POSE_DEFS = { -- 14
	run = {files = { -- 15
		"run_0", -- 15
		"run_1", -- 15
		"run_2", -- 15
		"run_3", -- 15
		"run_4" -- 15
	}, fps = 7, height = 96, loop = true}, -- 15
	jump = {files = {"jump_0", "jump_1"}, fps = 6, height = 100, loop = false}, -- 16
	fall = {files = {"fall_0"}, fps = 0, height = 100, loop = true}, -- 17
	cling = {files = {"cling_0"}, fps = 0, height = 100, loop = false}, -- 18
	ladder = {files = {"cling_1", "cling_2"}, fps = 3.3, height = 100, loop = true}, -- 22
	dash = {files = {"dash_0", "dash_1"}, fps = 14, height = 100, loop = false}, -- 23
	attack1 = {files = { -- 27
		"atk_0", -- 27
		"atk_1", -- 27
		"atk_2", -- 27
		"atk_3", -- 27
		"atk_4" -- 27
	}, fps = 20, height = 104, loop = false}, -- 27
	attack2 = {files = { -- 28
		"atk_0", -- 28
		"atk_1", -- 28
		"atk_2", -- 28
		"atk_3", -- 28
		"atk_4" -- 28
	}, fps = 20, height = 104, loop = false}, -- 28
	attack3 = {files = { -- 29
		"atk_0", -- 29
		"atk_1", -- 29
		"atk_2", -- 29
		"atk_3", -- 29
		"atk_4" -- 29
	}, fps = 20, height = 104, loop = false}, -- 29
	heavy = {files = {"atk_3", "atk_4"}, fps = 12, height = 104, loop = false}, -- 30
	hurt = {files = {"hurt_0"}, fps = 0, height = 100, loop = false} -- 31
} -- 31
local FRAME_MUL = { -- 37
	run_0 = 0.9375, -- 40
	run_1 = 0.9375, -- 41
	run_2 = 0.9375, -- 42
	run_3 = 0.9375, -- 43
	run_4 = 0.9375, -- 44
	jump_0 = 0.9, -- 45
	jump_1 = 0.9, -- 46
	fall_0 = 1.1, -- 48
	cling_0 = 0.9, -- 49
	cling_1 = 1.12, -- 51
	cling_2 = 1.12, -- 52
	dash_0 = 0.9, -- 53
	dash_1 = 0.9, -- 54
	atk_0 = 0.92, -- 58
	atk_1 = 0.95, -- 59
	atk_2 = 0.95, -- 60
	atk_3 = 0.88, -- 61
	atk_4 = 0.87, -- 62
	hurt_0 = 0.9 -- 63
} -- 63
local HERO_DIR = "assets/characters/hero_v2/" -- 67
____exports.HERO_FRAMES_FACE_RIGHT = true -- 70
____exports.HeroFrameSet = __TS__Class() -- 77
local HeroFrameSet = ____exports.HeroFrameSet -- 77
HeroFrameSet.name = "HeroFrameSet" -- 77
function HeroFrameSet.prototype.____constructor(self, parent) -- 81
	self.frames = {} -- 78
	self.loadedCount = 0 -- 79
	for pose in pairs(POSE_DEFS) do -- 82
		local def = POSE_DEFS[pose] -- 83
		local list = {} -- 84
		for ____, f in ipairs(def.files) do -- 85
			do -- 85
				local tex = Texture2D((HERO_DIR .. f) .. ".png") -- 86
				if tex == nil then -- 86
					goto __continue4 -- 88
				end -- 88
				local sp = Sprite(tex) -- 90
				sp.anchor = Vec2(0.5, 0) -- 91
				sp.visible = false -- 92
				local mul = FRAME_MUL[f] ~= nil and FRAME_MUL[f] or 1 -- 93
				local scale = def.height / tex.height * mul -- 94
				sp.scaleX = scale -- 95
				sp.scaleY = scale -- 96
				sp:addTo(parent) -- 97
				list[#list + 1] = {sp = sp, scale = scale} -- 98
				self.loadedCount = self.loadedCount + 1 -- 99
			end -- 99
			::__continue4:: -- 99
		end -- 99
		if #list > 0 then -- 99
			self.frames[pose] = list -- 102
		end -- 102
	end -- 102
end -- 81
function HeroFrameSet.prototype.has(self, pose) -- 107
	return self.frames[pose] ~= nil -- 108
end -- 107
function HeroFrameSet.prototype.pick(self, pose, animTime) -- 112
	local list = self.frames[pose] -- 113
	if list == nil then -- 113
		return nil -- 115
	end -- 115
	local def = POSE_DEFS[pose] -- 117
	local idx = 0 -- 118
	if def.fps > 0 then -- 118
		if def.loop then -- 118
			idx = math.floor(animTime * def.fps) % #list -- 121
		else -- 121
			idx = math.floor(animTime * def.fps) -- 123
			if idx > #list - 1 then -- 123
				idx = #list - 1 -- 125
			end -- 125
		end -- 125
	end -- 125
	return list[idx + 1] -- 129
end -- 112
function HeroFrameSet.prototype.hideAll(self) -- 132
	for pose in pairs(self.frames) do -- 133
		local list = self.frames[pose] -- 134
		for ____, fr in ipairs(list) do -- 135
			fr.sp.visible = false -- 136
		end -- 136
	end -- 136
end -- 132
return ____exports -- 132