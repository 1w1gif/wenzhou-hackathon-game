-- [ts]: probe_prompt.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Director = ____Dora.Director -- 3
local Node = ____Dora.Node -- 3
local Tower = require("data.tower") -- 4
local ____render_world = require("game.render_world") -- 5
local WorldRenderer = ____render_world.WorldRenderer -- 5
local root = Node() -- 7
root:addTo(Director.entry) -- 8
local renderer = __TS__New(WorldRenderer, root, Tower) -- 10
renderer:setPrompt(0, 60, "按 E 传送") -- 11
local t = 0 -- 13
local probe = Node() -- 14
probe:addTo(Director.entry) -- 15
probe:schedule(function(dt) -- 16
	local prev = t -- 17
	t = t + dt -- 18
	if prev <= 1.2 and t > 1.2 then -- 18
		renderer:setPrompt(-280, 60, "石头沉睡著，需要祠堂的月相正确才会苏醒，先去调整月轮") -- 20
	end -- 20
	if prev <= 2.6 and t > 2.6 then -- 20
		renderer:setPrompt(0, 60, nil) -- 23
	end -- 23
	if prev <= 2.9 and t > 2.9 then -- 23
		renderer:setPrompt(0, 60, "按 E 对话") -- 26
	end -- 26
	return t < 3.6 -- 28
end) -- 16
return ____exports -- 16