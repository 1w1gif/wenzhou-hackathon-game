-- [ts]: world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local ____tower = require("data.tower") -- 3
local bells = ____tower.bells -- 3
local checkpoints = ____tower.checkpoints -- 3
local lanterns = ____tower.lanterns -- 3
local plates = ____tower.plates -- 3
local ropes = ____tower.ropes -- 3
function ____exports.resetFloorMechanisms(state) -- 95
	local floor = -1 -- 96
	do -- 96
		local i = 0 -- 97
		while i < #checkpoints do -- 97
			if checkpoints[i + 1].id == state.currentCheckpointId then -- 97
				floor = checkpoints[i + 1].floor -- 99
				break -- 100
			end -- 100
			i = i + 1 -- 97
		end -- 97
	end -- 97
	do -- 97
		local i = 0 -- 103
		while i < #ropes do -- 103
			if ropes[i + 1].floor == floor then -- 103
				__TS__Delete(state.cutRopes, ropes[i + 1].id) -- 105
			end -- 105
			i = i + 1 -- 103
		end -- 103
	end -- 103
	do -- 103
		local i = 0 -- 108
		while i < #bells do -- 108
			if bells[i + 1].floor == floor then -- 108
				__TS__Delete(state.rungBells, bells[i + 1].id) -- 110
			end -- 110
			i = i + 1 -- 108
		end -- 108
	end -- 108
	do -- 108
		local i = 0 -- 113
		while i < #plates do -- 113
			if plates[i + 1].floor == floor then -- 113
				__TS__Delete(state.platesActive, plates[i + 1].id) -- 115
			end -- 115
			i = i + 1 -- 113
		end -- 113
	end -- 113
	do -- 113
		local i = 0 -- 118
		while i < #lanterns do -- 118
			if lanterns[i + 1].floor == floor then -- 118
				__TS__Delete(state.lanternsLit, lanterns[i + 1].id) -- 120
			end -- 120
			i = i + 1 -- 118
		end -- 118
	end -- 118
	state.lanternSequence = 0 -- 123
	state.lanternFailed = false -- 124
end -- 95
____exports.LIFE_CAP = 8 -- 6
function ____exports.createLoopState() -- 8
	return { -- 9
		loopIndex = 0, -- 10
		phaseIndex = 4, -- 12
		heroineLife = ____exports.LIFE_CAP, -- 13
		maxLife = ____exports.LIFE_CAP, -- 14
		swordIntent = 3, -- 15
		maxSwordIntent = 3, -- 16
		shenyanTrust = 0, -- 17
		drawnBladeAgainst = false, -- 18
		rewindCount = 0, -- 19
		moonstones = 0, -- 20
		mechanismParts = 0, -- 21
		tokens = 0, -- 22
		memories = {}, -- 23
		flags = {}, -- 24
		cutRopes = {}, -- 25
		rungBells = {}, -- 26
		platesActive = {}, -- 27
		lanternsLit = {}, -- 28
		lanternSequence = 0, -- 29
		lanternFailed = false, -- 30
		openedGates = {}, -- 31
		collectedIds = {}, -- 32
		checkpointsActivated = {}, -- 33
		currentCheckpointId = "cp_riverbank", -- 34
		storySeen = {}, -- 35
		askedChoices = {}, -- 36
		objective = "走近树苗按 E 拾起；种入东侧枯坑，渡口传送门自会亮起", -- 37
		stealthAlert = false, -- 38
		sneakBonus = false, -- 39
		rewindPenalty = 0, -- 40
		pebbles = 0, -- 41
		causalityLog = {} -- 42
	} -- 42
end -- 8
function ____exports.addTrust(state, amount) -- 46
	state.shenyanTrust = math.max(0, state.shenyanTrust + amount) -- 47
end -- 46
function ____exports.recordMemory(state, text) -- 50
	do -- 50
		local i = 0 -- 51
		while i < #state.memories do -- 51
			if state.memories[i + 1] == text then -- 51
				return -- 53
			end -- 53
			i = i + 1 -- 51
		end -- 51
	end -- 51
	local ____state_memories_0 = state.memories -- 51
	____state_memories_0[#____state_memories_0 + 1] = text -- 56
end -- 50
function ____exports.rewindTimeline(state) -- 61
	state.loopIndex = state.loopIndex + 1 -- 62
	state.phaseIndex = (state.phaseIndex + 1) % 8 -- 63
	state.rewindCount = state.rewindCount + 1 -- 64
	state.shenyanTrust = 0 -- 65
	state.cutRopes = {} -- 66
	state.rungBells = {} -- 67
	state.platesActive = {} -- 68
	state.lanternsLit = {} -- 69
	state.lanternSequence = 0 -- 70
	state.lanternFailed = false -- 71
	state.openedGates = {} -- 72
	state.storySeen = {} -- 73
	state.stealthAlert = false -- 74
	state.sneakBonus = false -- 75
end -- 61
function ____exports.rewindFloor(state) -- 80
	state.rewindCount = state.rewindCount + 1 -- 81
	state.phaseIndex = (state.phaseIndex + 1) % 8 -- 82
	state.rewindPenalty = state.rewindPenalty + 1 -- 83
	state.maxLife = math.max(1, state.maxLife - 1) -- 84
	if state.heroineLife > state.maxLife then -- 84
		state.heroineLife = state.maxLife -- 86
	end -- 86
	____exports.resetFloorMechanisms(state) -- 88
	state.stealthAlert = false -- 89
	state.swordIntent = state.maxSwordIntent -- 90
end -- 80
function ____exports.restoreFloorCap(state) -- 128
	state.rewindPenalty = 0 -- 129
	state.maxLife = ____exports.LIFE_CAP -- 130
	if state.heroineLife > state.maxLife then -- 130
		state.heroineLife = state.maxLife -- 132
	end -- 132
end -- 128
function ____exports.lifeFraction(state) -- 136
	return state.heroineLife / state.maxLife -- 137
end -- 136
function ____exports.intentFraction(state) -- 140
	return state.swordIntent / state.maxSwordIntent -- 141
end -- 140
return ____exports -- 140