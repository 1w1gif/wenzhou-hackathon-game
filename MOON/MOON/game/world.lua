local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 4,["6"] = 5,["7"] = 5,["8"] = 5,["9"] = 5,["10"] = 5,["11"] = 5,["12"] = 5,["13"] = 5,["14"] = 5,["15"] = 5,["16"] = 5,["17"] = 5,["18"] = 5,["19"] = 5,["20"] = 5,["21"] = 5,["22"] = 5,["23"] = 5,["24"] = 5,["25"] = 5,["26"] = 5,["27"] = 5,["28"] = 5,["29"] = 5,["30"] = 5,["31"] = 5,["32"] = 5,["33"] = 5,["34"] = 5,["35"] = 5,["36"] = 4,["37"] = 38,["38"] = 39,["39"] = 38,["40"] = 42,["42"] = 43,["43"] = 43,["44"] = 44,["47"] = 43,["50"] = 48,["51"] = 48,["52"] = 42,["53"] = 51,["54"] = 52,["55"] = 51,["56"] = 55,["57"] = 56,["58"] = 55});
local ____exports = {}
function ____exports.createLoopState(self)
    return {
        loopIndex = 0,
        phaseIndex = 4,
        heroineLife = 3,
        maxLife = 3,
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
        objective = "目标：向东探索河滩渡口（A/D 移动 · J 挥剑）",
        stealthAlert = false,
        sneakBonus = false
    }
end
function ____exports.addTrust(self, state, amount)
    state.shenyanTrust = math.max(0, state.shenyanTrust + amount)
end
function ____exports.recordMemory(self, state, text)
    do
        local i = 0
        while i < #state.memories do
            if state.memories[i + 1] == text then
                return
            end
            i = i + 1
        end
    end
    local ____state_memories_0 = state.memories
    ____state_memories_0[#____state_memories_0 + 1] = text
end
function ____exports.lifeFraction(self, state)
    return state.heroineLife / state.maxLife
end
function ____exports.intentFraction(self, state)
    return state.swordIntent / state.maxSwordIntent
end
return ____exports
