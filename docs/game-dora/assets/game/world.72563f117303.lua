local ____lualib = require("lualib_bundle")
local __TS__Delete = ____lualib.__TS__Delete
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 3,["12"] = 95,["13"] = 96,["15"] = 97,["16"] = 97,["17"] = 98,["18"] = 99,["21"] = 97,["25"] = 103,["26"] = 103,["27"] = 104,["28"] = 105,["30"] = 103,["34"] = 108,["35"] = 108,["36"] = 109,["37"] = 110,["39"] = 108,["43"] = 113,["44"] = 113,["45"] = 114,["46"] = 115,["48"] = 113,["52"] = 118,["53"] = 118,["54"] = 119,["55"] = 120,["57"] = 118,["60"] = 123,["61"] = 124,["62"] = 95,["63"] = 6,["64"] = 8,["65"] = 9,["66"] = 9,["67"] = 9,["68"] = 9,["69"] = 9,["70"] = 9,["71"] = 9,["72"] = 9,["73"] = 9,["74"] = 9,["75"] = 9,["76"] = 9,["77"] = 9,["78"] = 9,["79"] = 9,["80"] = 9,["81"] = 9,["82"] = 9,["83"] = 9,["84"] = 9,["85"] = 9,["86"] = 9,["87"] = 9,["88"] = 9,["89"] = 9,["90"] = 9,["91"] = 9,["92"] = 9,["93"] = 9,["94"] = 9,["95"] = 9,["96"] = 9,["97"] = 9,["98"] = 9,["99"] = 8,["100"] = 46,["101"] = 47,["102"] = 46,["103"] = 50,["105"] = 51,["106"] = 51,["107"] = 52,["110"] = 51,["113"] = 56,["114"] = 50,["115"] = 61,["116"] = 62,["117"] = 63,["118"] = 64,["119"] = 65,["120"] = 66,["121"] = 67,["122"] = 68,["123"] = 69,["124"] = 70,["125"] = 71,["126"] = 72,["127"] = 73,["128"] = 74,["129"] = 75,["130"] = 61,["131"] = 80,["132"] = 81,["133"] = 82,["134"] = 83,["135"] = 84,["136"] = 85,["137"] = 86,["139"] = 88,["140"] = 89,["141"] = 90,["142"] = 80,["143"] = 128,["144"] = 129,["145"] = 130,["146"] = 131,["147"] = 132,["149"] = 128,["150"] = 136,["151"] = 137,["152"] = 136,["153"] = 140,["154"] = 141,["155"] = 140});
local ____exports = {}
local ____tower = require("data.tower")
local bells = ____tower.bells
local checkpoints = ____tower.checkpoints
local lanterns = ____tower.lanterns
local plates = ____tower.plates
local ropes = ____tower.ropes
function ____exports.resetFloorMechanisms(state)
    local floor = -1
    do
        local i = 0
        while i < #checkpoints do
            if checkpoints[i + 1].id == state.currentCheckpointId then
                floor = checkpoints[i + 1].floor
                break
            end
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #ropes do
            if ropes[i + 1].floor == floor then
                __TS__Delete(state.cutRopes, ropes[i + 1].id)
            end
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #bells do
            if bells[i + 1].floor == floor then
                __TS__Delete(state.rungBells, bells[i + 1].id)
            end
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #plates do
            if plates[i + 1].floor == floor then
                __TS__Delete(state.platesActive, plates[i + 1].id)
            end
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #lanterns do
            if lanterns[i + 1].floor == floor then
                __TS__Delete(state.lanternsLit, lanterns[i + 1].id)
            end
            i = i + 1
        end
    end
    state.lanternSequence = 0
    state.lanternFailed = false
end
____exports.LIFE_CAP = 8
function ____exports.createLoopState()
    return {
        loopIndex = 0,
        phaseIndex = 4,
        heroineLife = ____exports.LIFE_CAP,
        maxLife = ____exports.LIFE_CAP,
        swordIntent = 3,
        maxSwordIntent = 3,
        shenyanTrust = 0,
        drawnBladeAgainst = false,
        rewindCount = 0,
        moonstones = 0,
        mechanismParts = 0,
        tokens = 0,
        memories = {},
        flags = {},
        cutRopes = {},
        rungBells = {},
        platesActive = {},
        lanternsLit = {},
        lanternSequence = 0,
        lanternFailed = false,
        openedGates = {},
        collectedIds = {},
        checkpointsActivated = {},
        currentCheckpointId = "cp_riverbank",
        storySeen = {},
        askedChoices = {},
        objective = "走近树苗按 E 拾起；种入东侧枯坑，渡口传送门自会亮起",
        stealthAlert = false,
        sneakBonus = false,
        rewindPenalty = 0,
        pebbles = 0,
        causalityLog = {}
    }
end
function ____exports.addTrust(state, amount)
    state.shenyanTrust = Math:max(0, state.shenyanTrust + amount)
end
function ____exports.recordMemory(state, text)
    do
        local i = 0
        while i < #state.memories do
            if state.memories[i + 1] == text then
                return
            end
            i = i + 1
        end
    end
    state.memories:push(text)
end
function ____exports.rewindTimeline(state)
    state.loopIndex = state.loopIndex + 1
    state.phaseIndex = (state.phaseIndex + 1) % 8
    state.rewindCount = state.rewindCount + 1
    state.shenyanTrust = 0
    state.cutRopes = {}
    state.rungBells = {}
    state.platesActive = {}
    state.lanternsLit = {}
    state.lanternSequence = 0
    state.lanternFailed = false
    state.openedGates = {}
    state.storySeen = {}
    state.stealthAlert = false
    state.sneakBonus = false
end
function ____exports.rewindFloor(state)
    state.rewindCount = state.rewindCount + 1
    state.phaseIndex = (state.phaseIndex + 1) % 8
    state.rewindPenalty = state.rewindPenalty + 1
    state.maxLife = Math:max(1, state.maxLife - 1)
    if state.heroineLife > state.maxLife then
        state.heroineLife = state.maxLife
    end
    ____exports.resetFloorMechanisms(state)
    state.stealthAlert = false
    state.swordIntent = state.maxSwordIntent
end
function ____exports.restoreFloorCap(state)
    state.rewindPenalty = 0
    state.maxLife = ____exports.LIFE_CAP
    if state.heroineLife > state.maxLife then
        state.heroineLife = state.maxLife
    end
end
function ____exports.lifeFraction(state)
    return state.heroineLife / state.maxLife
end
function ____exports.intentFraction(state)
    return state.swordIntent / state.maxSwordIntent
end
return ____exports
