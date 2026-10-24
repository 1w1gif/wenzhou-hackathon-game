local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 14,["11"] = 15,["12"] = 15,["13"] = 15,["14"] = 15,["15"] = 15,["16"] = 15,["17"] = 14,["18"] = 14,["19"] = 14,["20"] = 14,["21"] = 14,["22"] = 14,["23"] = 27,["24"] = 27,["25"] = 27,["26"] = 27,["27"] = 27,["28"] = 27,["29"] = 14,["30"] = 28,["31"] = 28,["32"] = 28,["33"] = 28,["34"] = 28,["35"] = 28,["36"] = 14,["37"] = 29,["38"] = 29,["39"] = 29,["40"] = 29,["41"] = 29,["42"] = 29,["43"] = 14,["44"] = 14,["45"] = 14,["46"] = 14,["47"] = 37,["48"] = 37,["49"] = 37,["50"] = 37,["51"] = 37,["52"] = 37,["53"] = 37,["54"] = 37,["55"] = 37,["56"] = 37,["57"] = 37,["58"] = 37,["59"] = 37,["60"] = 37,["61"] = 37,["62"] = 37,["63"] = 37,["64"] = 37,["65"] = 37,["66"] = 37,["67"] = 37,["68"] = 67,["69"] = 70,["70"] = 77,["71"] = 77,["72"] = 77,["73"] = 81,["74"] = 78,["75"] = 79,["76"] = 82,["77"] = 83,["78"] = 84,["79"] = 85,["81"] = 86,["82"] = 87,["83"] = 88,["85"] = 90,["86"] = 91,["87"] = 92,["88"] = 93,["89"] = 94,["90"] = 95,["91"] = 96,["92"] = 97,["93"] = 98,["94"] = 99,["98"] = 101,["99"] = 102,["102"] = 81,["103"] = 107,["104"] = 108,["105"] = 107,["106"] = 112,["107"] = 113,["108"] = 114,["109"] = 115,["111"] = 117,["112"] = 118,["113"] = 119,["114"] = 120,["115"] = 121,["117"] = 123,["118"] = 124,["119"] = 125,["123"] = 129,["124"] = 112,["125"] = 132,["126"] = 133,["127"] = 134,["128"] = 135,["129"] = 136,["132"] = 132});
local ____exports = {}
local ____Dora = require("Dora")
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local Vec2 = ____Dora.Vec2
local POSE_DEFS = {
    run = {files = {
        "run_0",
        "run_1",
        "run_2",
        "run_3",
        "run_4"
    }, fps = 7, height = 96, loop = true},
    jump = {files = {"jump_0", "jump_1"}, fps = 6, height = 100, loop = false},
    fall = {files = {"fall_0"}, fps = 0, height = 100, loop = true},
    cling = {files = {"cling_0"}, fps = 0, height = 100, loop = false},
    ladder = {files = {"cling_1", "cling_2"}, fps = 3.3, height = 100, loop = true},
    dash = {files = {"dash_0", "dash_1"}, fps = 14, height = 100, loop = false},
    attack1 = {files = {
        "atk_0",
        "atk_1",
        "atk_2",
        "atk_3",
        "atk_4"
    }, fps = 20, height = 104, loop = false},
    attack2 = {files = {
        "atk_0",
        "atk_1",
        "atk_2",
        "atk_3",
        "atk_4"
    }, fps = 20, height = 104, loop = false},
    attack3 = {files = {
        "atk_0",
        "atk_1",
        "atk_2",
        "atk_3",
        "atk_4"
    }, fps = 20, height = 104, loop = false},
    heavy = {files = {"atk_3", "atk_4"}, fps = 12, height = 104, loop = false},
    hurt = {files = {"hurt_0"}, fps = 0, height = 100, loop = false}
}
local FRAME_MUL = {
    run_0 = 0.9375,
    run_1 = 0.9375,
    run_2 = 0.9375,
    run_3 = 0.9375,
    run_4 = 0.9375,
    jump_0 = 0.9,
    jump_1 = 0.9,
    fall_0 = 1.1,
    cling_0 = 0.9,
    cling_1 = 1.12,
    cling_2 = 1.12,
    dash_0 = 0.9,
    dash_1 = 0.9,
    atk_0 = 0.92,
    atk_1 = 0.95,
    atk_2 = 0.95,
    atk_3 = 0.88,
    atk_4 = 0.87,
    hurt_0 = 0.9
}
local HERO_DIR = "assets/characters/hero_v2/"
____exports.HERO_FRAMES_FACE_RIGHT = true
____exports.HeroFrameSet = __TS__Class()
local HeroFrameSet = ____exports.HeroFrameSet
HeroFrameSet.name = "HeroFrameSet"
function HeroFrameSet.prototype.____constructor(self, parent)
    self.frames = {}
    self.loadedCount = 0
    for pose in pairs(POSE_DEFS) do
        local def = POSE_DEFS[pose]
        local list = {}
        for ____, f in ipairs(def.files) do
            do
                local tex = Texture2D((HERO_DIR .. f) .. ".png")
                if tex == nil then
                    goto __continue4
                end
                local sp = Sprite(tex)
                sp.anchor = Vec2(0.5, 0)
                sp.visible = false
                local mul = FRAME_MUL[f] ~= nil and FRAME_MUL[f] or 1
                local scale = def.height / tex.height * mul
                sp.scaleX = scale
                sp.scaleY = scale
                sp:addTo(parent)
                list:push({sp = sp, scale = scale})
                self.loadedCount = self.loadedCount + 1
            end
            ::__continue4::
        end
        if #list > 0 then
            self.frames[pose] = list
        end
    end
end
function HeroFrameSet.prototype.has(self, pose)
    return self.frames[pose] ~= nil
end
function HeroFrameSet.prototype.pick(self, pose, animTime)
    local list = self.frames[pose]
    if list == nil then
        return nil
    end
    local def = POSE_DEFS[pose]
    local idx = 0
    if def.fps > 0 then
        if def.loop then
            idx = Math:floor(animTime * def.fps) % #list
        else
            idx = Math:floor(animTime * def.fps)
            if idx > #list - 1 then
                idx = #list - 1
            end
        end
    end
    return list[idx + 1]
end
function HeroFrameSet.prototype.hideAll(self)
    for pose in pairs(self.frames) do
        local list = self.frames[pose]
        for ____, fr in ipairs(list) do
            fr.sp.visible = false
        end
    end
end
return ____exports
