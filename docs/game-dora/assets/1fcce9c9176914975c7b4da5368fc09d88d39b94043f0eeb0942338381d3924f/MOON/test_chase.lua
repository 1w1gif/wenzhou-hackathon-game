-- [ts]: test_chase.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 6
local Content = ____Dora.Content -- 6
local Director = ____Dora.Director -- 6
local Node = ____Dora.Node -- 6
local Path = ____Dora.Path -- 6
local ____enemies = require("game.enemies") -- 7
local EnemySystem = ____enemies.EnemySystem -- 7
local ____effects = require("game.effects") -- 8
local EffectSystem = ____effects.EffectSystem -- 8
local Tower = require("data.tower") -- 9
local root = Node() -- 11
root:addTo(Director.entry) -- 12
local fx = __TS__New(EffectSystem) -- 14
local enemies = __TS__New( -- 15
	EnemySystem, -- 15
	fx, -- 15
	{ -- 15
		onPlayerHit = function(____, _dmg, _fromX) -- 16
		end, -- 16
		onDeath = function() -- 17
		end, -- 17
		onPoof = function(____, _x, _y) -- 18
		end -- 18
	} -- 18
) -- 18
local def = { -- 20
	id = "tx", -- 21
	kind = "bandit", -- 22
	x = 990, -- 23
	y = 220, -- 24
	patrolMin = 880, -- 25
	patrolMax = 1150, -- 26
	floor = 0 -- 27
} -- 27
enemies:spawnAll({def}, 0) -- 29
local ctx = {platforms = Tower.platforms} -- 31
local GROUND_FEET = 220 -- 34
local PLAT_FEET = 398 -- 35
local phases = { -- 46
	{ -- 47
		["until"] = 0.5, -- 47
		px = 1130, -- 47
		feet = GROUND_FEET, -- 47
		vy = 0, -- 47
		label = "A地面贴近触发追击", -- 47
		check = function(____, s) return s == "chase" or s == "windup" end -- 48
	}, -- 48
	{ -- 49
		["until"] = 1.5, -- 49
		px = 990, -- 49
		feet = PLAT_FEET, -- 49
		vy = 0, -- 49
		label = "B站上高台丢失目标", -- 49
		check = function(____, s, x0, x1) return s == "patrol" and math.abs(x1 - x0) > 30 end -- 50
	}, -- 50
	{ -- 51
		["until"] = 2, -- 51
		px = 1130, -- 51
		feet = GROUND_FEET, -- 51
		vy = 0, -- 51
		label = "C回到地面重新索敌", -- 51
		check = function(____, s) return s == "chase" or s == "windup" end -- 52
	}, -- 52
	{ -- 53
		["until"] = 2.4, -- 53
		px = 990, -- 53
		feet = PLAT_FEET, -- 53
		vy = 300, -- 53
		label = "D跳跃途中不脱战", -- 53
		check = function(____, s) return s ~= "patrol" end -- 54
	}, -- 54
	{ -- 55
		["until"] = 3, -- 55
		px = 990, -- 55
		feet = PLAT_FEET, -- 55
		vy = 0, -- 55
		label = "E高台落地立即脱战", -- 55
		check = function(____, s) return s == "patrol" end -- 56
	} -- 56
} -- 56
local t = 0 -- 59
local phaseIdx = 0 -- 60
local phaseStartX = #enemies.enemies > 0 and enemies.enemies[1].body.x or 0 -- 61
local failures = {} -- 62
root:schedule(function(dt) -- 64
	local ph = phases[phaseIdx + 1] -- 65
	local e = enemies.enemies[1] -- 66
	enemies:update( -- 67
		dt, -- 68
		ph.px, -- 69
		ph.feet + 41, -- 70
		{x = ph.px - 16, y = ph.feet, w = 32, h = 82}, -- 71
		false, -- 72
		ctx, -- 73
		ph.vy -- 74
	) -- 74
	t = t + dt -- 76
	if t >= ph["until"] then -- 76
		local ok = ph:check(e.state, phaseStartX, e.body.x) -- 78
		if not ok then -- 78
			failures[#failures + 1] = ((((ph.label .. " [state=") .. e.state) .. " dx=") .. tostring(math.floor(e.body.x - phaseStartX))) .. "]" -- 80
		end -- 80
		phaseIdx = phaseIdx + 1 -- 82
		if phaseIdx >= #phases then -- 82
			local report = #failures == 0 and "passed | A追击/B高台丢失走开/C落地重追/D跳跃不脱战/E落地脱战 全部通过 | x=" .. tostring(math.floor(e.body.x)) or "failed | " .. table.concat(failures, " ; ") -- 84
			Content:save( -- 87
				Path(Content.searchPaths[1], ".agent", "test-results", "chase_case.txt"), -- 87
				report -- 87
			) -- 87
			return true -- 88
		end -- 88
		phaseStartX = enemies.enemies[1].body.x -- 90
	end -- 90
	return false -- 92
end) -- 64
return ____exports -- 64