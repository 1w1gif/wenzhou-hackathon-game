-- [ts]: rect_cycle_probe.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local Node = ____Dora.Node -- 2
local Path = ____Dora.Path -- 2
local ____world = require("game.world") -- 3
local createLoopState = ____world.createLoopState -- 3
local ____notebook = require("ui.notebook") -- 4
local NotebookUI = ____notebook.NotebookUI -- 4
local ____causality_fx = require("game.causality_fx") -- 5
local CausalityFx = ____causality_fx.CausalityFx -- 5
local resultDir = Path(Content.searchPaths[1], ".agent", "test-results") -- 7
if not Content:exist(resultDir) then -- 7
	Content:mkdir(resultDir) -- 9
end -- 9
local root = Node() -- 12
root:addTo(Director.entry) -- 13
local state = createLoopState() -- 15
state.maxLife = 8 -- 16
state.heroineLife = 8 -- 17
state.pebbles = 3 -- 18
__TS__ArrayPush( -- 19
	state.causalityLog, -- 19
	"渡口移苗·根带旧土", -- 19
	"井水打满·一桶月色", -- 19
	"枯坑种树·因果成立", -- 19
	"拾起石子·三枚", -- 19
	"古镇不杀·剑意上限+1" -- 19
) -- 19
local nb = __TS__New(NotebookUI, root) -- 21
nb:toggle() -- 22
local fx = __TS__New(CausalityFx, root) -- 23
local t = 0 -- 25
local played = false -- 26
root:schedule(function(dt) -- 27
	t = t + dt -- 28
	if not played and t >= 1.2 then -- 28
		played = true -- 30
		fx:play("rewind", "月相逆卷·本层回溯") -- 31
	end -- 31
	nb:update(dt, state) -- 33
	fx:update(dt) -- 34
	return false -- 35
end) -- 27
return ____exports -- 27