-- [ts]: test_ninja.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 4
local Color = ____Dora.Color -- 4
local Content = ____Dora.Content -- 4
local Director = ____Dora.Director -- 4
local DrawNode = ____Dora.DrawNode -- 4
local Node = ____Dora.Node -- 4
local Path = ____Dora.Path -- 4
local Vec2 = ____Dora.Vec2 -- 4
local ____enemies = require("game.enemies") -- 5
local EnemySystem = ____enemies.EnemySystem -- 5
local ____effects = require("game.effects") -- 6
local EffectSystem = ____effects.EffectSystem -- 6
local ____ninja_render = require("game.ninja_render") -- 7
local NinjaLayer = ____ninja_render.NinjaLayer -- 7
local Tower = require("data.tower") -- 8
local root = Node() -- 10
root:addTo(Director.entry) -- 11
local bg = DrawNode() -- 13
bg:addTo(root) -- 14
bg:drawPolygon( -- 16
	{ -- 16
		Vec2(-640, -360), -- 16
		Vec2(640, -360), -- 16
		Vec2(640, 360), -- 16
		Vec2(-640, 360) -- 16
	}, -- 16
	Color(24, 28, 40, 255) -- 16
) -- 16
bg:drawPolygon( -- 17
	{ -- 17
		Vec2(-640, -80), -- 17
		Vec2(640, -80), -- 17
		Vec2(640, -92), -- 17
		Vec2(-640, -92) -- 17
	}, -- 17
	Color(96, 84, 120, 255) -- 17
) -- 17
local fx = __TS__New(EffectSystem) -- 19
local ninjaLayer = __TS__New(NinjaLayer, root) -- 20
local poofCount = 0 -- 22
local enemies = __TS__New( -- 23
	EnemySystem, -- 23
	fx, -- 23
	{ -- 23
		onPlayerHit = function(____, _dmg, _fromX) -- 24
		end, -- 24
		onDeath = function() -- 25
		end, -- 25
		onPoof = function(____, _x, _y) -- 26
			poofCount = poofCount + 1 -- 27
		end -- 26
	} -- 26
) -- 26
local e02 = Tower.enemies[3] -- 30
enemies:spawnAll({e02}, 0) -- 31
local ctx = {platforms = Tower.platforms} -- 33
local prect = {x = 784, y = 220, w = 32, h = 82} -- 34
local t = 0 -- 36
local drawOkCount = 0 -- 37
local xs = {} -- 38
local states = {} -- 39
root:schedule(function(dt) -- 41
	enemies:update( -- 42
		dt, -- 42
		800, -- 42
		261, -- 42
		prect, -- 42
		false, -- 42
		ctx -- 42
	) -- 42
	ninjaLayer:beginFrame(dt) -- 43
	do -- 43
		local i = 0 -- 44
		while i < #enemies.enemies do -- 44
			if ninjaLayer:drawEnemy(enemies.enemies[i + 1]) then -- 44
				drawOkCount = drawOkCount + 1 -- 46
			end -- 46
			i = i + 1 -- 44
		end -- 44
	end -- 44
	ninjaLayer:endFrame() -- 49
	t = t + dt -- 50
	local step = math.floor(t / 0.5) -- 51
	if #xs < step and #enemies.enemies > 0 then -- 51
		local e = enemies.enemies[1] -- 53
		xs[#xs + 1] = math.floor(e.body.x) -- 54
		states[#states + 1] = e.state -- 55
	end -- 55
	if t >= 1.5 then -- 55
		local e = enemies.enemies[1] -- 58
		local moved = #xs >= 2 and xs[#xs] ~= xs[1] -- 59
		local drewEveryFrame = drawOkCount >= math.floor(t * 60) * 0.9 -- 60
		local verdict = moved and ninjaLayer.ok and drewEveryFrame and "passed: enemy moves + sprite renders every frame" or (((("failed: moved=" .. tostring(moved)) .. " ninjaOk=") .. tostring(ninjaLayer.ok)) .. " drewEveryFrame=") .. tostring(drewEveryFrame) -- 61
		local report = (((((((verdict .. " | x=") .. table.concat(xs, ",")) .. " | state=") .. table.concat(states, ">")) .. " | drawOk=") .. tostring(drawOkCount)) .. " | finalState=") .. e.state -- 64
		Content:save( -- 65
			Path(Content.searchPaths[1], ".agent", "test-results", "ninja_case.txt"), -- 65
			report -- 65
		) -- 65
		return true -- 66
	end -- 66
	return false -- 68
end) -- 41
return ____exports -- 41