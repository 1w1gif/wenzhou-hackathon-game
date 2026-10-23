local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 3,["12"] = 3,["13"] = 17,["14"] = 18,["15"] = 18,["16"] = 18,["17"] = 18,["18"] = 18,["19"] = 18,["20"] = 17,["21"] = 19,["22"] = 19,["23"] = 19,["24"] = 19,["25"] = 19,["26"] = 19,["27"] = 17,["28"] = 29,["29"] = 29,["30"] = 29,["31"] = 34,["32"] = 35,["33"] = 36,["34"] = 37,["35"] = 34,["36"] = 40,["37"] = 41,["38"] = 42,["39"] = 43,["41"] = 45,["42"] = 46,["43"] = 47,["44"] = 40,["45"] = 51,["46"] = 52,["49"] = 55,["50"] = 56,["51"] = 57,["54"] = 60,["55"] = 60,["56"] = 60,["57"] = 60,["58"] = 60,["59"] = 60,["60"] = 60,["61"] = 60,["62"] = 60,["63"] = 60,["64"] = 60,["65"] = 61,["66"] = 62,["67"] = 63,["68"] = 64,["69"] = 65,["70"] = 66,["71"] = 66,["72"] = 51,["73"] = 69,["74"] = 70,["75"] = 71,["76"] = 72,["77"] = 73,["78"] = 74,["79"] = 75,["80"] = 76,["82"] = 78,["83"] = 79,["84"] = 80,["86"] = 82,["87"] = 82,["88"] = 82,["89"] = 82,["90"] = 82,["91"] = 82,["92"] = 82,["94"] = 84,["96"] = 69,["97"] = 88,["99"] = 89,["100"] = 89,["101"] = 90,["102"] = 89,["105"] = 92,["106"] = 88});
local ____exports = {}
local ____Dora = require("Dora")
local Rect = ____Dora.Rect
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local TextureFilter = ____Dora.TextureFilter
local Vec2 = ____Dora.Vec2
local SHEETS = {big = {
    file = "assets/effects/hit-effect-1.png",
    frameW = 128,
    frameH = 128,
    frames = 6,
    fps = 20,
    scale = 1.4
}, hit = {
    file = "assets/effects/hit-effect-2.png",
    frameW = 64,
    frameH = 64,
    frames = 5,
    fps = 22,
    scale = 1.6
}}
____exports.SheetFxSystem = __TS__Class()
local SheetFxSystem = ____exports.SheetFxSystem
SheetFxSystem.name = "SheetFxSystem"
function SheetFxSystem.prototype.____constructor(self, parent)
    self.parent = parent
    self.actives = {}
    self.tex = {}
end
function SheetFxSystem.prototype.texture(self, file)
    local cached = self.tex[file]
    if cached ~= nil then
        return cached
    end
    local loaded = Texture2D(nil, file)
    self.tex[file] = loaded
    return loaded
end
function SheetFxSystem.prototype.spawn(self, x, y, dir, big)
    if #self.actives > 24 then
        return
    end
    local def = big and SHEETS.big or SHEETS.hit
    local tex = self:texture(def.file)
    if tex == nil then
        return
    end
    local sp = Sprite(
        nil,
        tex,
        Rect(
            nil,
            0,
            0,
            def.frameW,
            def.frameH
        )
    )
    sp.filter = TextureFilter.Point
    sp.position = Vec2(nil, x, y)
    sp.scaleX = (dir >= 0 and 1 or -1) * def.scale
    sp.scaleY = def.scale
    sp:addTo(self.parent)
    local ____self_actives_0 = self.actives
    ____self_actives_0[#____self_actives_0 + 1] = {sprite = sp, def = def, t = 0, dur = def.frames / def.fps}
end
function SheetFxSystem.prototype.update(self, dt)
    local i = #self.actives - 1
    while i >= 0 do
        local a = self.actives[i + 1]
        a.t = a.t + dt
        if a.t >= a.dur then
            a.sprite:removeFromParent()
            __TS__ArraySplice(self.actives, i, 1)
        else
            local idx = math.floor(a.t * a.def.fps)
            if idx >= a.def.frames then
                idx = a.def.frames - 1
            end
            a.sprite.textureRect = Rect(
                nil,
                idx * a.def.frameW,
                0,
                a.def.frameW,
                a.def.frameH
            )
        end
        i = i - 1
    end
end
function SheetFxSystem.prototype.clear(self)
    do
        local i = 0
        while i < #self.actives do
            self.actives[i + 1].sprite:removeFromParent()
            i = i + 1
        end
    end
    self.actives = {}
end
return ____exports
