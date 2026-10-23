local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 3,["12"] = 17,["13"] = 18,["14"] = 18,["15"] = 18,["16"] = 18,["17"] = 18,["18"] = 18,["19"] = 17,["20"] = 19,["21"] = 19,["22"] = 19,["23"] = 19,["24"] = 19,["25"] = 19,["26"] = 17,["27"] = 29,["28"] = 29,["29"] = 29,["30"] = 34,["31"] = 35,["32"] = 36,["33"] = 37,["34"] = 34,["35"] = 40,["36"] = 41,["37"] = 42,["38"] = 43,["40"] = 45,["41"] = 46,["42"] = 47,["43"] = 40,["44"] = 51,["45"] = 52,["48"] = 55,["49"] = 56,["50"] = 57,["53"] = 60,["54"] = 60,["55"] = 60,["56"] = 60,["57"] = 61,["58"] = 62,["59"] = 63,["60"] = 64,["61"] = 65,["62"] = 66,["63"] = 66,["64"] = 51,["65"] = 69,["66"] = 70,["67"] = 71,["68"] = 72,["69"] = 73,["70"] = 74,["71"] = 75,["72"] = 76,["74"] = 78,["75"] = 79,["76"] = 80,["78"] = 82,["80"] = 84,["82"] = 69,["83"] = 88,["85"] = 89,["86"] = 89,["87"] = 90,["88"] = 89,["91"] = 92,["92"] = 88});
local ____exports = {}
local ____Dora = require("Dora")
local Rect = ____Dora.Rect
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
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
    local loaded = Texture2D(file)
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
        tex,
        Rect(0, 0, def.frameW, def.frameH)
    )
    sp.filter = "Point"
    sp.position = Vec2(x, y)
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
            a.sprite.textureRect = Rect(idx * a.def.frameW, 0, a.def.frameW, a.def.frameH)
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
