-- [ts]: slash_run_sheet.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Director = ____Dora.Director -- 3
local Label = ____Dora.Label -- 3
local Rect = ____Dora.Rect -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local root = Director.entry -- 5
local function makeLabel(text, size, x, y) -- 7
	local lb = Label("sarasa-mono-sc-regular", size) -- 8
	if lb == nil then -- 8
		return -- 10
	end -- 10
	lb.text = text -- 12
	lb.color = Color(235, 235, 245, 255) -- 13
	lb.position = Vec2(x, y) -- 14
	lb:addTo(root) -- 15
end -- 7
local function drawSheetRow(path, tag, y, captionY) -- 18
	local tex = Texture2D(path) -- 19
	if tex == nil then -- 19
		makeLabel(tag .. " 贴图加载失败", 20, 0, y) -- 21
		return -- 22
	end -- 22
	local count = math.max( -- 24
		1, -- 24
		math.floor(tex.width / 64) -- 24
	) -- 24
	local scale = 1.6 -- 25
	local spacing = 64 * scale + 16 -- 26
	local maxW = 1150 -- 27
	if count * spacing > maxW then -- 27
		spacing = maxW / count -- 29
	end -- 29
	local x0 = -(count - 1) * spacing / 2 -- 31
	do -- 31
		local i = 0 -- 32
		while i < count do -- 32
			do -- 32
				local sp = Sprite( -- 33
					tex, -- 33
					Rect(i * 64, 0, 64, 64) -- 33
				) -- 33
				if sp == nil then -- 33
					goto __continue8 -- 35
				end -- 35
				sp.position = Vec2(x0 + i * spacing, y) -- 37
				sp.scaleX = scale -- 38
				sp.scaleY = scale -- 39
				sp:addTo(root) -- 40
				makeLabel( -- 41
					"" .. tostring(i + 1), -- 41
					16, -- 41
					x0 + i * spacing, -- 41
					y - 64 * scale - 16 -- 41
				) -- 41
			end -- 41
			::__continue8:: -- 41
			i = i + 1 -- 32
		end -- 32
	end -- 32
	makeLabel( -- 43
		((((((tag .. "  ") .. tostring(tex.width)) .. "x") .. tostring(tex.height)) .. "  共") .. tostring(count)) .. "帧", -- 43
		18, -- 43
		0, -- 43
		captionY -- 43
	) -- 43
end -- 18
local function drawRunRow() -- 46
	local names = {"run_0", "run_1", "run_2", "run_3"} -- 47
	local tags = {"01", "02", "03", "04"} -- 48
	local y = -225 -- 49
	local spacing = 175 -- 50
	local x0 = -(#names - 1) * spacing / 2 -- 51
	do -- 51
		local i = 0 -- 52
		while i < #names do -- 52
			do -- 52
				local tex = Texture2D(("assets/characters/hero_v2/" .. names[i + 1]) .. ".png") -- 53
				if tex == nil then -- 53
					makeLabel(tags[i + 1] .. " 加载失败", 20, x0 + i * spacing, y) -- 55
					goto __continue12 -- 56
				end -- 56
				local sp = Sprite(tex) -- 58
				if sp == nil then -- 58
					goto __continue12 -- 60
				end -- 60
				local k = 150 / tex.height -- 62
				sp.scaleX = k -- 63
				sp.scaleY = k -- 64
				sp.position = Vec2(x0 + i * spacing, y) -- 65
				sp:addTo(root) -- 66
				makeLabel( -- 67
					(((tags[i + 1] .. "  ") .. tostring(tex.width)) .. "x") .. tostring(tex.height), -- 67
					17, -- 67
					x0 + i * spacing, -- 67
					y - 115 -- 67
				) -- 67
			end -- 67
			::__continue12:: -- 67
			i = i + 1 -- 52
		end -- 52
	end -- 52
end -- 46
makeLabel("剑气雪碧图逐帧(上两行·游戏内顺序从左到右) + 跑步帧(下行 01→02→03→04)", 22, 0, 330) -- 71
drawSheetRow("assets/effects/slash_white.png", "白·普攻挥剑", 185, 258) -- 72
drawSheetRow("assets/effects/slash_blue.png", "蓝·剑气弹", 15, 88) -- 73
makeLabel("跑步 4 帧（统一高 150px）——若有两帧姿势几乎一样，请告诉我编号", 18, 0, -112) -- 74
drawRunRow() -- 75
return ____exports -- 75