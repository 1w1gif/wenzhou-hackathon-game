-- [ts]: hero_ladder.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Content = ____Dora.Content -- 3
local Director = ____Dora.Director -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local PAGE1 = { -- 10
	{name = "run_0", file = "run_0.png"}, -- 11
	{name = "run_1", file = "run_1.png"}, -- 12
	{name = "run_2", file = "run_2.png"}, -- 13
	{name = "run_3", file = "run_3.png"}, -- 14
	{name = "jump_0", file = "jump_0.png"}, -- 15
	{name = "jump_1", file = "jump_1.png"}, -- 16
	{name = "fall_0", file = "fall_0.png"}, -- 17
	{name = "cling_0", file = "cling_0.png"} -- 18
} -- 18
local PAGE2 = { -- 20
	{name = "dash_0", file = "dash_0.png"}, -- 21
	{name = "dash_1", file = "dash_1.png"}, -- 22
	{name = "atk_0", file = "atk_0.png"}, -- 23
	{name = "atk_1", file = "atk_1.png"}, -- 24
	{name = "atk_2", file = "atk_2.png"}, -- 25
	{name = "atk_3", file = "atk_3.png"}, -- 26
	{name = "atk_4", file = "atk_4.png"}, -- 27
	{name = "hurt_0", file = "hurt_0.png"} -- 28
} -- 28
local HERO_DIR = "assets/characters/hero_v2/" -- 31
local SCALE = 0.2 -- 32
local BASE_Y = -330 -- 33
local CELL_W = 158 -- 34
local root = Node() -- 36
root:addTo(Director.entry) -- 37
local ____View_size_0 = View.size -- 39
local width = ____View_size_0.width -- 39
local height = ____View_size_0.height -- 39
local bg = DrawNode() -- 42
bg:addTo(root) -- 43
bg:drawPolygon( -- 44
	{ -- 45
		Vec2(-width / 2, -height / 2), -- 45
		Vec2(width / 2, -height / 2), -- 45
		Vec2(width / 2, height / 2), -- 45
		Vec2(-width / 2, height / 2) -- 45
	}, -- 45
	Color(24, 26, 34, 255) -- 46
) -- 46
local grid = DrawNode() -- 49
grid:addTo(root) -- 50
do -- 50
	local k = 0 -- 52
	while k <= 26 do -- 52
		local y = BASE_Y + k * 20 -- 53
		local major = k % 5 == 0 -- 54
		grid:drawSegment( -- 55
			Vec2(-width / 2, y), -- 56
			Vec2(width / 2, y), -- 57
			major and 1.2 or 0.6, -- 58
			major and Color(150, 168, 200, 200) or Color(70, 78, 96, 140) -- 59
		) -- 59
		k = k + 1 -- 52
	end -- 52
end -- 52
local function addText(x, y, text, size, anchorX, anchorY, r, g, b) -- 63
	local l = Label("sarasa-mono-sc-regular", size) -- 64
	if l == nil then -- 64
		return -- 66
	end -- 66
	l.text = text -- 68
	l.anchor = Vec2(anchorX, anchorY) -- 69
	l.color = Color(r, g, b, 255) -- 70
	l.position = Vec2(x, y) -- 71
	l:addTo(root) -- 72
end -- 63
do -- 63
	local k = 0 -- 76
	while k <= 26 do -- 76
		addText( -- 77
			-width / 2 + 10, -- 77
			BASE_Y + k * 20 + 2, -- 77
			"" .. tostring(k * 20), -- 77
			13, -- 77
			0, -- 77
			0.5, -- 77
			190, -- 77
			200, -- 77
			220 -- 77
		) -- 77
		k = k + 5 -- 76
	end -- 76
end -- 76
local pageFile = ".temp/ladder_page.txt" -- 81
local page = "1" -- 82
if Content:exist(pageFile) then -- 82
	local p = Content:load(pageFile) -- 84
	if p ~= nil then -- 84
		page = p -- 86
	end -- 86
end -- 86
local items -- 90
local scale = SCALE -- 91
local topNote = "" -- 92
if page == "3" then -- 92
	items = __TS__ArrayConcat(PAGE1, PAGE2) -- 95
	scale = -1 -- 96
	topNote = "PAGE 3: CURRENT IN-GAME SCALE x2  (height/texH)" -- 97
else -- 97
	items = page == "2" and PAGE2 or PAGE1 -- 99
	topNote = ((("PAGE " .. page) .. "  UNIFORM TEXEL SCALE x") .. tostring(SCALE)) .. "  gridline=20screen=100srcpx" -- 100
end -- 100
local cellW = page == "3" and 80 or CELL_W -- 103
local startX = -(#items * cellW) / 2 -- 104
do -- 104
	local i = 0 -- 105
	while i < #items do -- 105
		do -- 105
			local it = items[i + 1] -- 106
			local tex = Texture2D(HERO_DIR .. it.file) -- 107
			if tex == nil then -- 107
				addText( -- 109
					startX + cellW * i + cellW / 2, -- 109
					BASE_Y + 60, -- 109
					it.name .. " FAIL", -- 109
					14, -- 109
					0.5, -- 109
					0.5, -- 109
					255, -- 109
					90, -- 109
					90 -- 109
				) -- 109
				goto __continue13 -- 110
			end -- 110
			local sp = Sprite(tex) -- 112
			if sp == nil then -- 112
				goto __continue13 -- 114
			end -- 114
			local useScale = scale > 0 and scale or 2 * 96 / tex.height -- 116
			sp.anchor = Vec2(0.5, 0) -- 117
			sp.position = Vec2(startX + cellW * i + cellW / 2, BASE_Y) -- 118
			sp.scaleX = useScale -- 119
			sp.scaleY = useScale -- 120
			sp:addTo(root) -- 121
			grid:drawSegment( -- 123
				Vec2(startX + cellW * i, BASE_Y), -- 124
				Vec2(startX + cellW * i, BASE_Y + 540), -- 125
				0.8, -- 126
				Color(90, 96, 116, 150) -- 127
			) -- 127
			local label = page == "3" and it.name or (((it.name .. " ") .. tostring(tex.width)) .. "x") .. tostring(tex.height) -- 129
			addText( -- 130
				startX + cellW * i + cellW / 2, -- 130
				BASE_Y - 20, -- 130
				label, -- 130
				12, -- 130
				0.5, -- 130
				1, -- 130
				220, -- 130
				228, -- 130
				240 -- 130
			) -- 130
		end -- 130
		::__continue13:: -- 130
		i = i + 1 -- 105
	end -- 105
end -- 105
grid:drawSegment( -- 133
	Vec2(-width / 2, BASE_Y), -- 133
	Vec2(width / 2, BASE_Y), -- 133
	2, -- 133
	Color(240, 244, 252, 230) -- 133
) -- 133
addText( -- 134
	-width / 2 + 12, -- 134
	height / 2 - 16, -- 134
	topNote, -- 134
	16, -- 134
	0, -- 134
	1, -- 134
	255, -- 134
	244, -- 134
	214 -- 134
) -- 134
return ____exports -- 134