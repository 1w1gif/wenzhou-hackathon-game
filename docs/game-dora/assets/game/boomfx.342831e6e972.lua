local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 12,["11"] = 24,["12"] = 24,["13"] = 24,["14"] = 30,["15"] = 26,["16"] = 27,["17"] = 28,["18"] = 31,["19"] = 32,["20"] = 33,["21"] = 34,["23"] = 35,["24"] = 35,["25"] = 36,["26"] = 37,["27"] = 38,["29"] = 40,["31"] = 35,["35"] = 44,["36"] = 30,["37"] = 48,["38"] = 49,["41"] = 52,["42"] = 53,["43"] = 54,["46"] = 57,["48"] = 58,["49"] = 58,["51"] = 59,["52"] = 60,["53"] = 61,["55"] = 63,["56"] = 64,["57"] = 65,["58"] = 66,["59"] = 67,["60"] = 68,["61"] = 69,["62"] = 70,["63"] = 71,["66"] = 58,["69"] = 73,["70"] = 74,["72"] = 48,["73"] = 78,["74"] = 79,["75"] = 80,["77"] = 81,["78"] = 82,["79"] = 83,["80"] = 84,["81"] = 85,["83"] = 87,["86"] = 89,["87"] = 89,["88"] = 90,["89"] = 89,["92"] = 92,["96"] = 94,["97"] = 78,["98"] = 97,["99"] = 98,["100"] = 99,["101"] = 100,["104"] = 103,["105"] = 97});
local ____exports = {}
local ____Dora = require("Dora")
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local Vec2 = ____Dora.Vec2
local KINDS = {big = {base = "exp", count = 10, fps = 15, scale = 1}, ring = {base = "cir", count = 10, fps = 15, scale = 0.9}}
____exports.BoomFxSystem = __TS__Class()
local BoomFxSystem = ____exports.BoomFxSystem
BoomFxSystem.name = "BoomFxSystem"
function BoomFxSystem.prototype.____constructor(self, parent)
    self.tex = {}
    self.actives = {}
    self.ok = false
    self.parent = parent
    local ok = true
    for k in pairs(KINDS) do
        local kd = KINDS[k]
        do
            local i = 0
            while i < kd.count do
                local tex = Texture2D(((("assets/fx/boom/" .. kd.base) .. "_") .. tostring(i + 1)) .. ".png")
                if tex == nil then
                    ok = false
                else
                    self.tex[(k .. "_") .. tostring(i)] = tex
                end
                i = i + 1
            end
        end
    end
    self.ok = ok
end
function BoomFxSystem.prototype.spawn(self, x, y, big)
    if not self.ok then
        return
    end
    local k = big and "big" or "ring"
    local kd = KINDS[k]
    if kd == nil then
        return
    end
    local sprites = {}
    do
        local i = 0
        while i < kd.count do
            do
                local tex = self.tex[(k .. "_") .. tostring(i)]
                if tex == nil then
                    goto __continue13
                end
                local sp = Sprite(tex)
                sp.filter = "Point"
                sp.anchor = Vec2(0.5, 0.5)
                sp.position = Vec2(x, y)
                sp.scaleX = kd.scale
                sp.scaleY = kd.scale
                sp.visible = false
                sp:addTo(self.parent)
                sprites:push(sp)
            end
            ::__continue13::
            i = i + 1
        end
    end
    if #sprites > 0 then
        self.actives:push({sprites = sprites, count = #sprites, fps = kd.fps, t = 0})
    end
end
function BoomFxSystem.prototype.update(self, dt)
    local keep = {}
    for ____, fx in ipairs(self.actives) do
        do
            fx.t = fx.t + dt
            local idx = Math:floor(fx.t * fx.fps)
            if idx >= fx.count then
                for ____, sp in ipairs(fx.sprites) do
                    sp:removeFromParent()
                end
                goto __continue17
            end
            do
                local j = 0
                while j < #fx.sprites do
                    fx.sprites[j + 1].visible = j == idx
                    j = j + 1
                end
            end
            keep:push(fx)
        end
        ::__continue17::
    end
    self.actives = keep
end
function BoomFxSystem.prototype.clear(self)
    for ____, fx in ipairs(self.actives) do
        for ____, sp in ipairs(fx.sprites) do
            sp:removeFromParent()
        end
    end
    self.actives = {}
end
return ____exports
