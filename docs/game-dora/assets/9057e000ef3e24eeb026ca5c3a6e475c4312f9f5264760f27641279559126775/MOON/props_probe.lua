-- [ts]: props_probe.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local Node = ____Dora.Node -- 2
local Path = ____Dora.Path -- 2
local Texture2D = ____Dora.Texture2D -- 2
local names = { -- 4
	"a1_pit.png", -- 5
	"a2_sapling.png", -- 6
	"a3_tree.png", -- 7
	"a4_stump.png", -- 8
	"a5_well.png", -- 9
	"a6_bucket.png", -- 10
	"b1_bush.png", -- 11
	"b5_counter.png", -- 12
	"b6_barrel.png", -- 13
	"b7_table.png", -- 14
	"e2_dice.png", -- 15
	"e3_lingzhi.png", -- 16
	"e4_ginseng.png", -- 17
	"e5_herb.png", -- 18
	"e6_offering.png", -- 19
	"e7_shard.png", -- 20
	"withered_reed.png" -- 21
} -- 21
local resultDir = Path(Content.searchPaths[1], ".agent", "test-results") -- 24
if not Content:exist(resultDir) then -- 24
	Content:mkdir(resultDir) -- 26
end -- 26
local marker = Path(resultDir, "props_probe.txt") -- 28
local node = Node() -- 30
node:addTo(Director.entry) -- 31
node:schedule(function() -- 32
	local lines = {} -- 33
	for ____, n in ipairs(names) do -- 34
		local tex = Texture2D("assets/props/" .. n) -- 35
		if tex == nil then -- 35
			lines[#lines + 1] = n .. " FAIL" -- 37
		else -- 37
			lines[#lines + 1] = (((n .. " ") .. tostring(tex.width)) .. "x") .. tostring(tex.height) -- 39
		end -- 39
	end -- 39
	Content:save( -- 42
		marker, -- 42
		table.concat(lines, "\n") -- 42
	) -- 42
	return true -- 43
end) -- 32
return ____exports -- 32