-- [ts]: atk_run_sheet.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local Label = ____Dora.Label -- 2
local Sprite = ____Dora.Sprite -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Vec2 = ____Dora.Vec2 -- 2
local root = Director.entry -- 4
local function makeLabel(text, size, x, y) -- 6
	local lb = Label("sarasa-mono-sc-regular", size) -- 7
	if lb == nil then -- 7
		return -- 9
	end -- 9
	lb.text = text -- 11
	lb.color = Color(235, 235, 245, 255) -- 12
	lb.position = Vec2(x, y) -- 13
	lb:addTo(root) -- 14
end -- 6
makeLabel("攻击新 5 帧（按你标的 01→05 顺序，游戏内比例：统一画布高 97px、脚底对齐）", 22, 0, 300) -- 17
local names = { -- 19
	"atk_0", -- 19
	"atk_1", -- 19
	"atk_2", -- 19
	"atk_3", -- 19
	"atk_4" -- 19
} -- 19
local tags = { -- 20
	"01", -- 20
	"02", -- 20
	"03", -- 20
	"04", -- 20
	"05" -- 20
} -- 20
local y = 20 -- 21
local spacing = 230 -- 22
local x0 = -(#names - 1) * spacing / 2 -- 23
local ground = Label("sarasa-mono-sc-regular", 18) -- 26
if ground ~= nil then -- 26
	ground.text = "------------------------------ 脚底基准线 ------------------------------"
	ground.color = Color(120, 130, 160, 255) -- 29
	ground.position = Vec2(0, y - 14) -- 30
	ground:addTo(root) -- 31
end -- 31
do -- 31
	local i = 0 -- 34
	while i < #names do -- 34
		do -- 34
			local tex = Texture2D(("assets/characters/hero_v2/" .. names[i + 1]) .. ".png") -- 35
			if tex == nil then -- 35
				makeLabel(tags[i + 1] .. " 加载失败", 20, x0 + i * spacing, y) -- 37
				goto __continue6 -- 38
			end -- 38
			local sp = Sprite(tex) -- 40
			if sp == nil then -- 40
				goto __continue6 -- 42
			end -- 42
			local k = 96.72 / tex.height -- 44
			sp.scaleX = k -- 45
			sp.scaleY = k -- 46
			sp.anchor = Vec2(0.5, 0) -- 47
			sp.position = Vec2(x0 + i * spacing, y) -- 48
			sp:addTo(root) -- 49
			makeLabel(tags[i + 1], 22, x0 + i * spacing, y - 44) -- 50
			makeLabel( -- 51
				(tostring(tex.width) .. "x") .. tostring(tex.height), -- 51
				15, -- 51
				x0 + i * spacing, -- 51
				y - 74 -- 51
			) -- 51
		end -- 51
		::__continue6:: -- 51
		i = i + 1 -- 34
	end -- 34
end -- 34
makeLabel("attack1/2 = 01→05 全套 17fps   attack3 = 01→05 15fps（单点即完整连招）", 18, 0, -230) -- 54
return ____exports -- 54