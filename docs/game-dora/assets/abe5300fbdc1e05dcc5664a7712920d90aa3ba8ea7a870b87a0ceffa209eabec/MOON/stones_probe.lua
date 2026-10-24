-- [ts]: stones_probe.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Path = ____Dora.Path -- 2
local Sprite = ____Dora.Sprite -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local resultDir = Path(Content.searchPaths[1], ".agent", "test-results") -- 4
if not Content:exist(resultDir) then -- 4
	Content:mkdir(resultDir) -- 6
end -- 6
local marker = Path(resultDir, "stones_probe.txt") -- 8
local root = Node() -- 10
root:addTo(Director.entry) -- 11
local bg = DrawNode() -- 13
bg:addTo(root) -- 14
local vw = View.size.width -- 15
local vh = View.size.height -- 16
bg:drawPolygon( -- 17
	{ -- 18
		Vec2(-vw / 2, -vh / 2), -- 18
		Vec2(vw / 2, -vh / 2), -- 18
		Vec2(vw / 2, vh / 2), -- 18
		Vec2(-vw / 2, vh / 2) -- 18
	}, -- 18
	Color(24, 26, 38, 255) -- 19
) -- 19
local items = {{path = "assets/tiles/lamp_stone.png", label = "lamp_stone", x = -220}, {path = "assets/tiles/moon_stone.png", label = "moon_stone", x = 0}, {path = "assets/tiles/push_stone.png", label = "push_stone", x = 220}} -- 22
local lines = {} -- 28
for ____, it in ipairs(items) do -- 29
	do -- 29
		local tex = Texture2D(it.path) -- 30
		if tex == nil then -- 30
			lines[#lines + 1] = it.path .. " FAIL" -- 32
			goto __continue3 -- 33
		end -- 33
		lines[#lines + 1] = (((it.path .. " ") .. tostring(tex.width)) .. "x") .. tostring(tex.height) -- 35
		local sp = Sprite(tex) -- 36
		if sp ~= nil then -- 36
			local s = 110 / tex.height -- 38
			sp.anchor = Vec2(0.5, 0.5) -- 39
			sp.scaleX = s -- 40
			sp.scaleY = s -- 41
			sp.position = Vec2(it.x, 40) -- 42
			sp:addTo(root) -- 43
		end -- 43
		local lb = Label("sarasa-mono-sc-regular", 16) -- 45
		if lb ~= nil then -- 45
			lb.text = (((it.label .. " ") .. tostring(tex.width)) .. "x") .. tostring(tex.height) -- 47
			lb.position = Vec2(it.x, -60) -- 48
			lb:addTo(root) -- 49
		end -- 49
	end -- 49
	::__continue3:: -- 49
end -- 49
Content:save( -- 53
	marker, -- 53
	table.concat(lines, "\n") -- 53
) -- 53
return ____exports -- 53