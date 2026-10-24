-- [ts]: hero_dims.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local Node = ____Dora.Node -- 2
local Path = ____Dora.Path -- 2
local Texture2D = ____Dora.Texture2D -- 2
local FRAMES = { -- 4
	"run_0", -- 4
	"run_1", -- 4
	"run_2", -- 4
	"run_3", -- 4
	"jump_0", -- 4
	"jump_1", -- 4
	"fall_0", -- 4
	"cling_0", -- 4
	"dash_0", -- 4
	"dash_1", -- 4
	"atk_0", -- 4
	"atk_1", -- 4
	"atk_2", -- 4
	"atk_3", -- 4
	"atk_4", -- 4
	"hurt_0" -- 4
} -- 4
local HERO_DIR = "assets/characters/hero_v2/" -- 5
local node = Node() -- 7
node:addTo(Director.entry) -- 8
node:schedule(function() -- 9
	local resultDir = Path(Content.searchPaths[1], ".agent", "test-results") -- 10
	if not Content:exist(resultDir) then -- 10
		Content:mkdir(resultDir) -- 12
	end -- 12
	local lines = {} -- 14
	for ____, f in ipairs(FRAMES) do -- 15
		local tex = Texture2D((HERO_DIR .. f) .. ".png") -- 16
		if tex == nil then -- 16
			lines[#lines + 1] = f .. " LOAD-FAIL" -- 18
		else -- 18
			lines[#lines + 1] = (((f .. " ") .. tostring(tex.width)) .. "x") .. tostring(tex.height) -- 20
		end -- 20
	end -- 20
	local ptex = Texture2D("assets/characters/衍月.png") -- 23
	if ptex == nil then -- 23
		lines[#lines + 1] = "portrait LOAD-FAIL" -- 25
	else -- 25
		lines[#lines + 1] = (("portrait " .. tostring(ptex.width)) .. "x") .. tostring(ptex.height) -- 27
	end -- 27
	for ____, l in ipairs(lines) do -- 29
		print(l) -- 30
	end -- 30
	Content:save( -- 32
		Path(resultDir, "hero_dims.txt"), -- 32
		"done" -- 32
	) -- 32
	return true -- 33
end) -- 9
return ____exports -- 9