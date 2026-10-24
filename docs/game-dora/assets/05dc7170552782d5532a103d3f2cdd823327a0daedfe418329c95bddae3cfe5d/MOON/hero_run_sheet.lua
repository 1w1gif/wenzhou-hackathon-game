-- [ts]: hero_run_sheet.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Sprite = ____Dora.Sprite -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local HERO_DIR = "assets/characters/hero_v2/" -- 4
local ITEMS = {{name = "run_0", src = "跑步1", file = "run_0.png"}, {name = "run_1", src = "跑步2", file = "run_1.png"}, {name = "run_2", src = "跑步3", file = "run_2.png"}, {name = "run_3", src = "跑步4", file = "run_3.png"}} -- 5
local UNI_SCALE = 0.16 -- 12
local ROW_A_Y = -40 -- 13
local ROW_B_Y = -330 -- 14
local MIN_CELL = 180 -- 15
local root = Node() -- 17
root:addTo(Director.entry) -- 18
local ____View_size_0 = View.size -- 20
local width = ____View_size_0.width -- 20
local height = ____View_size_0.height -- 20
local bg = DrawNode() -- 22
bg:addTo(root) -- 23
bg:drawPolygon( -- 24
	{ -- 25
		Vec2(-width / 2, -height / 2), -- 25
		Vec2(width / 2, -height / 2), -- 25
		Vec2(width / 2, height / 2), -- 25
		Vec2(-width / 2, height / 2) -- 25
	}, -- 25
	Color(24, 26, 34, 255) -- 26
) -- 26
local function addText(x, y, text, size, anchorX, anchorY, r, g, b) -- 29
	local l = Label("sarasa-mono-sc-regular", size) -- 30
	if l == nil then -- 30
		return -- 32
	end -- 32
	l.text = text -- 34
	l.anchor = Vec2(anchorX, anchorY) -- 35
	l.color = Color(r, g, b, 255) -- 36
	l.position = Vec2(x, y) -- 37
	l:addTo(root) -- 38
end -- 29
local cells = {} -- 47
local total = 0 -- 48
for ____, it in ipairs(ITEMS) do -- 49
	do -- 49
		local tex = Texture2D(HERO_DIR .. it.file) -- 50
		if tex == nil then -- 50
			cells[#cells + 1] = {tex = nil, x = 0, adv = MIN_CELL} -- 52
			total = total + MIN_CELL -- 53
			goto __continue4 -- 54
		end -- 54
		local uniW = tex.width * UNI_SCALE -- 56
		local adv = math.max(MIN_CELL, uniW + 28) -- 57
		cells[#cells + 1] = {tex = tex, x = 0, adv = adv} -- 58
		total = total + adv -- 59
	end -- 59
	::__continue4:: -- 59
end -- 59
local startX = -total / 2 -- 61
local cx = startX -- 62
for ____, c in ipairs(cells) do -- 63
	c.x = cx + c.adv / 2 -- 64
	cx = cx + c.adv -- 65
end -- 65
local grid = DrawNode() -- 69
grid:addTo(root) -- 70
grid:drawSegment( -- 71
	Vec2(-width / 2, ROW_A_Y), -- 71
	Vec2(width / 2, ROW_A_Y), -- 71
	2, -- 71
	Color(240, 244, 252, 230) -- 71
) -- 71
grid:drawSegment( -- 72
	Vec2(-width / 2, ROW_B_Y), -- 72
	Vec2(width / 2, ROW_B_Y), -- 72
	2, -- 72
	Color(240, 244, 252, 230) -- 72
) -- 72
for ____, c in ipairs(cells) do -- 75
	grid:drawSegment( -- 76
		Vec2(c.x, ROW_B_Y + 4), -- 76
		Vec2(c.x, ROW_A_Y - 4), -- 76
		0.8, -- 76
		Color(90, 96, 116, 90) -- 76
	) -- 76
end -- 76
local loaded = 0 -- 79
do -- 79
	local i = 0 -- 80
	while i < #ITEMS do -- 80
		do -- 80
			local it = ITEMS[i + 1] -- 81
			local c = cells[i + 1] -- 82
			if c.tex == nil then -- 82
				addText( -- 84
					c.x, -- 84
					ROW_A_Y + 30, -- 84
					it.name .. " FAIL", -- 84
					14, -- 84
					0.5, -- 84
					0.5, -- 84
					255, -- 84
					90, -- 84
					90 -- 84
				) -- 84
				goto __continue12 -- 85
			end -- 85
			loaded = loaded + 1 -- 87
			local spA = Sprite(c.tex) -- 89
			if spA ~= nil then -- 89
				spA.anchor = Vec2(0.5, 0) -- 91
				spA.position = Vec2(c.x, ROW_A_Y) -- 92
				spA.scaleX = UNI_SCALE -- 93
				spA.scaleY = UNI_SCALE -- 94
				spA:addTo(root) -- 95
			end -- 95
			addText( -- 97
				c.x, -- 97
				ROW_A_Y - 14, -- 97
				(((((it.name .. " = ") .. it.src) .. "  ") .. tostring(c.tex.width)) .. "x") .. tostring(c.tex.height), -- 97
				13, -- 97
				0.5, -- 97
				1, -- 97
				220, -- 97
				228, -- 97
				240 -- 97
			) -- 97
			local spB = Sprite(c.tex) -- 99
			if spB ~= nil then -- 99
				spB.anchor = Vec2(0.5, 0) -- 101
				spB.position = Vec2(c.x, ROW_B_Y) -- 102
				local s = 2 * 96 / c.tex.height -- 103
				spB.scaleX = s -- 104
				spB.scaleY = s -- 105
				spB:addTo(root) -- 106
			end -- 106
			addText( -- 108
				c.x, -- 108
				ROW_B_Y - 14, -- 108
				it.name .. "  (game x2)", -- 108
				13, -- 108
				0.5, -- 108
				1, -- 108
				170, -- 108
				200, -- 108
				230 -- 108
			) -- 108
		end -- 108
		::__continue12:: -- 108
		i = i + 1 -- 80
	end -- 80
end -- 80
addText( -- 111
	-width / 2 + 12, -- 111
	height / 2 - 16, -- 111
	((("RUN FRAMES loaded " .. tostring(loaded)) .. "/4  |  TOP: uniform texel x") .. tostring(UNI_SCALE)) .. "  BOTTOM: current in-game scale x2", -- 111
	15, -- 111
	0, -- 111
	1, -- 111
	255, -- 111
	244, -- 111
	214 -- 111
) -- 111
addText( -- 112
	width / 2 - 12, -- 112
	height / 2 - 40, -- 112
	"4 poses expected", -- 112
	13, -- 112
	1, -- 112
	1, -- 112
	160, -- 112
	220, -- 112
	170 -- 112
) -- 112
return ____exports -- 112