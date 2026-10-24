-- [ts]: tech_ui.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 4
local Color = ____Dora.Color -- 4
local DrawNode = ____Dora.DrawNode -- 4
local Node = ____Dora.Node -- 4
local Sprite = ____Dora.Sprite -- 4
local Texture2D = ____Dora.Texture2D -- 4
local Vec2 = ____Dora.Vec2 -- 4
____exports.TECH_FRAME_PATH = "assets/ui/tech/frame_brackets.png" -- 6
____exports.TECH_BTN_PATH = "assets/ui/tech/button.png" -- 7
--- 科技青点缀色（回退描边/高亮可用）
function ____exports.techAccent() -- 10
	return Color(96, 200, 255, 255) -- 11
end -- 10
--- 建一块科技风面板（局部坐标 (0,0)=面板中心）：
-- 半透明暗底（不挡背景）+ 细青描边 + 四角角框贴图；角框缺失时保留纯描边框。
-- 先于内容创建调用，后续 addTo 的标签/列表自然盖在面板之上。
function ____exports.makeTechPanel(parent, w, h) -- 19
	local holder = Node() -- 20
	holder:addTo(parent) -- 21
	local full = { -- 22
		Vec2(-w / 2, -h / 2), -- 22
		Vec2(w / 2, -h / 2), -- 22
		Vec2(w / 2, h / 2), -- 22
		Vec2(-w / 2, h / 2) -- 22
	} -- 22
	local fill = DrawNode() -- 23
	fill:addTo(holder) -- 24
	fill:drawPolygon( -- 25
		full, -- 25
		Color(7, 11, 20, 150) -- 25
	) -- 25
	fill:drawPolygon( -- 26
		full, -- 26
		Color(0, 0, 0, 0), -- 26
		1.5, -- 26
		Color(96, 200, 255, 130) -- 26
	) -- 26
	local tex = Texture2D(____exports.TECH_FRAME_PATH) -- 27
	if tex ~= nil then -- 27
		local frame = Sprite(tex) -- 29
		if frame ~= nil then -- 29
			frame.anchor = Vec2(0.5, 0.5) -- 31
			frame.position = Vec2(0, 0) -- 32
			frame.scaleX = w / tex.width -- 33
			frame.scaleY = h / tex.height -- 34
			frame:addTo(holder) -- 35
		end -- 35
	end -- 35
	return holder -- 38
end -- 19
return ____exports -- 19