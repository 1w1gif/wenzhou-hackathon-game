local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 17,["12"] = 18,["13"] = 18,["14"] = 18,["15"] = 18,["16"] = 18,["17"] = 18,["18"] = 17,["19"] = 19,["20"] = 19,["21"] = 19,["22"] = 19,["23"] = 19,["24"] = 19,["25"] = 17,["26"] = 29,["27"] = 29,["28"] = 29,["29"] = 34,["30"] = 35,["31"] = 36,["32"] = 37,["33"] = 34,["34"] = 40,["35"] = 41,["36"] = 42,["37"] = 43,["39"] = 45,["40"] = 46,["41"] = 47,["42"] = 40,["43"] = 51,["44"] = 52,["47"] = 55,["48"] = 56,["49"] = 57,["52"] = 60,["53"] = 60,["54"] = 60,["55"] = 60,["56"] = 61,["57"] = 62,["58"] = 63,["59"] = 64,["60"] = 65,["61"] = 66,["62"] = 51,["63"] = 69,["64"] = 70,["65"] = 71,["66"] = 72,["67"] = 73,["68"] = 74,["69"] = 75,["70"] = 76,["72"] = 78,["73"] = 79,["74"] = 80,["76"] = 82,["78"] = 84,["80"] = 69,["81"] = 88,["83"] = 89,["84"] = 89,["85"] = 90,["86"] = 89,["89"] = 92,["90"] = 88});
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
    self.actives:push({sprite = sp, def = def, t = 0, dur = def.frames / def.fps})
end
function SheetFxSystem.prototype.update(self, dt)
    local i = #self.actives - 1
    while i >= 0 do
        local a = self.actives[i + 1]
        a.t = a.t + dt
        if a.t >= a.dur then
            a.sprite:removeFromParent()
            self.actives:splice(i, 1)
        else
            local idx = Math:floor(a.t * a.def.fps)
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
