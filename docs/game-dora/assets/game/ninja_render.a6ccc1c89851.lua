local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__Delete = ____lualib.__TS__Delete
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 8,["8"] = 8,["9"] = 8,["10"] = 8,["11"] = 8,["12"] = 27,["13"] = 29,["14"] = 29,["15"] = 29,["16"] = 29,["17"] = 31,["18"] = 31,["19"] = 31,["20"] = 31,["21"] = 31,["22"] = 31,["23"] = 31,["24"] = 31,["25"] = 31,["26"] = 29,["27"] = 27,["28"] = 43,["29"] = 43,["30"] = 43,["31"] = 43,["32"] = 45,["33"] = 45,["34"] = 45,["35"] = 45,["36"] = 45,["37"] = 45,["38"] = 45,["39"] = 45,["40"] = 45,["41"] = 43,["42"] = 27,["43"] = 57,["44"] = 57,["45"] = 57,["46"] = 57,["47"] = 59,["48"] = 59,["49"] = 59,["50"] = 59,["51"] = 59,["52"] = 59,["53"] = 59,["54"] = 59,["55"] = 59,["56"] = 57,["57"] = 27,["58"] = 73,["59"] = 73,["60"] = 73,["61"] = 73,["62"] = 73,["63"] = 73,["64"] = 73,["65"] = 73,["66"] = 73,["67"] = 73,["68"] = 73,["69"] = 73,["70"] = 92,["71"] = 93,["72"] = 96,["73"] = 97,["74"] = 97,["75"] = 97,["76"] = 97,["77"] = 97,["78"] = 97,["79"] = 97,["80"] = 97,["81"] = 97,["82"] = 97,["83"] = 97,["84"] = 97,["85"] = 114,["86"] = 134,["87"] = 134,["88"] = 134,["89"] = 145,["90"] = 136,["91"] = 137,["92"] = 138,["93"] = 139,["94"] = 141,["95"] = 142,["96"] = 143,["97"] = 146,["98"] = 147,["99"] = 148,["100"] = 149,["101"] = 150,["102"] = 151,["103"] = 152,["104"] = 153,["105"] = 154,["106"] = 155,["107"] = 156,["110"] = 159,["112"] = 161,["113"] = 162,["114"] = 163,["115"] = 164,["118"] = 168,["119"] = 169,["120"] = 170,["121"] = 171,["122"] = 172,["123"] = 173,["125"] = 174,["126"] = 174,["127"] = 175,["128"] = 176,["129"] = 177,["130"] = 178,["133"] = 181,["134"] = 174,["137"] = 183,["140"] = 186,["142"] = 188,["146"] = 192,["147"] = 193,["148"] = 194,["150"] = 196,["151"] = 145,["152"] = 199,["153"] = 200,["154"] = 199,["155"] = 203,["156"] = 204,["157"] = 205,["159"] = 203,["160"] = 210,["161"] = 211,["163"] = 212,["164"] = 213,["165"] = 214,["166"] = 215,["167"] = 216,["169"] = 218,["173"] = 210,["174"] = 223,["175"] = 224,["176"] = 225,["178"] = 227,["179"] = 228,["180"] = 229,["182"] = 231,["183"] = 232,["184"] = 233,["185"] = 234,["186"] = 235,["187"] = 236,["188"] = 237,["190"] = 239,["191"] = 240,["192"] = 241,["194"] = 243,["196"] = 245,["197"] = 246,["198"] = 247,["200"] = 249,["201"] = 250,["202"] = 251,["203"] = 252,["206"] = 255,["207"] = 256,["208"] = 257,["209"] = 257,["210"] = 257,["211"] = 257,["212"] = 258,["213"] = 259,["214"] = 260,["215"] = 261,["217"] = 263,["218"] = 264,["219"] = 265,["220"] = 266,["221"] = 267,["223"] = 269,["224"] = 270,["225"] = 271,["226"] = 272,["227"] = 273,["228"] = 274,["229"] = 275,["230"] = 276,["231"] = 277,["232"] = 277,["233"] = 277,["234"] = 277,["236"] = 279,["238"] = 281,["239"] = 223,["240"] = 288,["241"] = 289,["242"] = 290,["244"] = 292,["245"] = 293,["246"] = 294,["247"] = 295,["248"] = 296,["249"] = 297,["250"] = 298,["252"] = 300,["253"] = 301,["254"] = 302,["255"] = 303,["257"] = 305,["258"] = 306,["259"] = 307,["261"] = 309,["263"] = 311,["264"] = 312,["265"] = 313,["266"] = 314,["267"] = 315,["268"] = 316,["271"] = 319,["272"] = 320,["273"] = 321,["274"] = 322,["275"] = 323,["276"] = 324,["277"] = 325,["279"] = 327,["280"] = 328,["281"] = 329,["282"] = 330,["283"] = 331,["284"] = 332,["285"] = 333,["286"] = 333,["287"] = 333,["288"] = 333,["290"] = 335,["292"] = 337,["293"] = 288});
local ____exports = {}
local ____Dora = require("Dora")
local Rect = ____Dora.Rect
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local Vec2 = ____Dora.Vec2
local KINDS = {bandit = {
    char = "peasant",
    cell = 96,
    scale = 1.3,
    faceRight = true,
    anims = {
        idle = {frames = 6, fps = 6, loop = true},
        run = {frames = 6, fps = 10, loop = true},
        walk = {frames = 8, fps = 8, loop = true},
        jump = {frames = 8, fps = 8, loop = false},
        attack_1 = {frames = 6, fps = 14, loop = false},
        attack_2 = {frames = 4, fps = 14, loop = false},
        hurt = {frames = 2, fps = 10, loop = false},
        dead = {frames = 4, fps = 10, loop = false}
    }
}, thrower = {
    char = "kunoichi",
    cell = 128,
    scale = 1.38,
    faceRight = true,
    anims = {
        idle = {frames = 9, fps = 6, loop = true},
        run = {frames = 8, fps = 10, loop = true},
        walk = {frames = 8, fps = 8, loop = true},
        jump = {frames = 10, fps = 8, loop = false},
        attack_1 = {frames = 6, fps = 14, loop = false},
        attack_2 = {frames = 8, fps = 14, loop = false},
        hurt = {frames = 2, fps = 10, loop = false},
        dead = {frames = 5, fps = 10, loop = false}
    }
}, boss = {
    char = "monk",
    cell = 96,
    scale = 1.43,
    faceRight = true,
    anims = {
        idle = {frames = 7, fps = 6, loop = true},
        run = {frames = 8, fps = 10, loop = true},
        walk = {frames = 7, fps = 8, loop = true},
        jump = {frames = 9, fps = 8, loop = false},
        attack_1 = {frames = 5, fps = 12, loop = false},
        attack_2 = {frames = 5, fps = 12, loop = false},
        hurt = {frames = 4, fps = 10, loop = false},
        dead = {frames = 5, fps = 10, loop = false}
    }
}}
local FSM_ANIM = {
    patrol = "walk",
    chase = "run",
    windup = "idle",
    telegraph = "idle",
    swing = "attack_1",
    recover = "idle",
    hurt = "hurt",
    charge = "run",
    throw = "attack_2",
    dead = "dead"
}
local ARCHER_DIR = "assets/characters/archer"
local ARCHER_SCALE = 0.74
local ARCHER_GROUND_OFFSET = 10
local ARCHER_FSM = {
    patrol = "idle",
    chase = "walk",
    windup = "idle",
    telegraph = "idle",
    swing = "idle",
    recover = "idle",
    hurt = "idle",
    charge = "walk",
    throw = "idle",
    dead = "idle"
}
local ARCHER_ANIMS = {idle = {frames = 12, fps = 10, loop = true}, walk = {frames = 12, fps = 12, loop = true}}
____exports.NinjaLayer = __TS__Class()
local NinjaLayer = ____exports.NinjaLayer
NinjaLayer.name = "NinjaLayer"
function NinjaLayer.prototype.____constructor(self, root)
    self.texSets = {}
    self.kindOk = {}
    self.slots = {}
    self.frameDt = 0
    self.archerTex = {}
    self.archerOk = false
    self.ok = false
    self.root = root
    local allOk = true
    for kind in pairs(KINDS) do
        local kd = KINDS[kind]
        local set = {}
        local kindOk = true
        for anim in pairs(kd.anims) do
            local def = kd.anims[anim]
            local tex = Texture2D(((("assets/enemies/ninja/" .. kd.char) .. "_") .. anim) .. ".png")
            if tex == nil then
                kindOk = false
                break
            end
            set[anim] = {tex = tex, def = def, fw = kd.cell, fh = kd.cell}
        end
        self.texSets[kind] = set
        self.kindOk[kind] = kindOk
        if not kindOk then
            allOk = false
        end
    end
    local archerOk = true
    for animName in pairs(ARCHER_ANIMS) do
        local adef = ARCHER_ANIMS[animName]
        for ____, dir in ipairs({"east", "west"}) do
            local key = (animName .. "_") .. dir
            local list = {}
            do
                local i = 0
                while i < adef.frames do
                    local nn = (i < 10 and "0" or "") .. tostring(i)
                    local tex = Texture2D(((((ARCHER_DIR .. "/") .. key) .. "/") .. nn) .. ".png")
                    if tex == nil then
                        archerOk = false
                        break
                    end
                    list:push(tex)
                    i = i + 1
                end
            end
            if not archerOk then
                break
            end
            self.archerTex[key] = list
        end
        if not archerOk then
            break
        end
    end
    self.archerOk = archerOk
    if not archerOk then
        allOk = false
    end
    self.ok = allOk
end
function NinjaLayer.prototype.beginFrame(self, dt)
    self.frameDt = dt
end
function NinjaLayer.prototype.hideSlot(self, s)
    for k in pairs(s.sprites) do
        s.sprites[k].visible = false
    end
end
function NinjaLayer.prototype.endFrame(self)
    for id in pairs(self.slots) do
        do
            local s = self.slots[id]
            if not s.used then
                self:hideSlot(s)
                __TS__Delete(self.slots, id)
                goto __continue24
            end
            s.used = false
        end
        ::__continue24::
    end
end
function NinjaLayer.prototype.drawEnemy(self, e)
    if e.def.kind == "archer" then
        return self:drawArcher(e)
    end
    local kd = KINDS[e.def.kind]
    if kd == nil or self.kindOk[e.def.kind] ~= true then
        return false
    end
    local set = self.texSets[e.def.kind]
    local wantRaw = FSM_ANIM[e.state]
    local want = wantRaw == nil and "idle" or wantRaw
    local slot = self.slots[e.def.id]
    if slot == nil then
        slot = {anim = want, t = 0, used = true, sprites = {}}
        self.slots[e.def.id] = slot
    end
    if want ~= slot.anim then
        slot.anim = want
        slot.t = 0
    else
        slot.t = slot.t + self.frameDt
    end
    local at = set[slot.anim]
    if at == nil then
        return false
    end
    slot.used = true
    for k in pairs(slot.sprites) do
        if k ~= slot.anim then
            slot.sprites[k].visible = false
        end
    end
    local sp = slot.sprites[slot.anim]
    if sp == nil then
        sp = Sprite(
            at.tex,
            Rect(0, 0, at.fw, at.fh)
        )
        sp.filter = "Point"
        sp.anchor = Vec2(0.5, 0)
        sp:addTo(self.root)
        slot.sprites[slot.anim] = sp
    end
    local idx = Math:floor(slot.t * at.def.fps)
    if at.def.loop then
        idx = idx % at.def.frames
    elseif idx > at.def.frames - 1 then
        idx = at.def.frames - 1
    end
    local face = e.facing * (kd.faceRight and 1 or -1)
    sp.visible = true
    sp.position = Vec2(e.body.x, e.body.y - e.body.h / 2)
    sp.scaleX = kd.scale * face
    sp.scaleY = kd.scale
    sp.textureRect = Rect(idx * at.fw, 0, at.fw, at.fh)
    if e.dead then
        local dt2 = e.deathTimer == nil and 0 or e.deathTimer
        sp.opacity = Math:floor(255 * Math:max(
            0,
            Math:min(1, dt2 / 0.55)
        ))
    else
        sp.opacity = 255
    end
    return true
end
function NinjaLayer.prototype.drawArcher(self, e)
    if not self.archerOk then
        return false
    end
    local wantRaw = ARCHER_FSM[e.state]
    local want = wantRaw == nil and "idle" or wantRaw
    local key = (want .. "_") .. (e.facing >= 0 and "east" or "west")
    local list = self.archerTex[key]
    local def = ARCHER_ANIMS[want]
    if list == nil or def == nil then
        return false
    end
    local slot = self.slots[e.def.id]
    if slot == nil then
        slot = {anim = key, t = 0, used = true, sprites = {}}
        self.slots[e.def.id] = slot
    end
    if slot.anim ~= key then
        slot.anim = key
        slot.t = 0
    else
        slot.t = slot.t + self.frameDt
    end
    slot.used = true
    local idx = Math:floor(slot.t * def.fps) % def.frames
    local frameKey = (key .. "_") .. tostring(idx)
    for k in pairs(slot.sprites) do
        if k ~= frameKey then
            slot.sprites[k].visible = false
        end
    end
    local sp = slot.sprites[frameKey]
    if sp == nil then
        sp = Sprite(list[idx + 1])
        sp.filter = "Point"
        sp.anchor = Vec2(0.5, 0)
        sp:addTo(self.root)
        slot.sprites[frameKey] = sp
    end
    sp.visible = true
    sp.position = Vec2(e.body.x, e.body.y - e.body.h / 2 - ARCHER_GROUND_OFFSET)
    sp.scaleX = ARCHER_SCALE
    sp.scaleY = ARCHER_SCALE
    if e.dead then
        local dt2 = e.deathTimer == nil and 0 or e.deathTimer
        sp.opacity = Math:floor(255 * Math:max(
            0,
            Math:min(1, dt2 / 0.55)
        ))
    else
        sp.opacity = 255
    end
    return true
end
return ____exports
