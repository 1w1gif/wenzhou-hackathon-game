local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 2,["8"] = 2,["9"] = 2,["10"] = 3,["11"] = 3,["12"] = 22,["13"] = 24,["14"] = 24,["15"] = 24,["17"] = 30,["18"] = 31,["19"] = 29,["20"] = 34,["21"] = 35,["22"] = 36,["24"] = 34,["25"] = 41,["27"] = 42,["28"] = 42,["29"] = 43,["30"] = 44,["31"] = 45,["32"] = 45,["33"] = 45,["34"] = 45,["35"] = 45,["36"] = 45,["37"] = 45,["38"] = 45,["39"] = 45,["40"] = 45,["41"] = 45,["42"] = 45,["43"] = 45,["44"] = 45,["45"] = 42,["48"] = 61,["49"] = 62,["51"] = 41,["52"] = 67,["54"] = 68,["55"] = 68,["56"] = 69,["57"] = 69,["58"] = 69,["59"] = 69,["60"] = 69,["61"] = 69,["62"] = 69,["63"] = 69,["64"] = 69,["65"] = 69,["66"] = 69,["67"] = 69,["68"] = 69,["69"] = 69,["70"] = 68,["73"] = 67,["74"] = 87,["75"] = 88,["76"] = 88,["77"] = 88,["78"] = 88,["79"] = 88,["80"] = 88,["81"] = 88,["82"] = 88,["83"] = 88,["84"] = 88,["85"] = 88,["86"] = 88,["87"] = 88,["88"] = 88,["89"] = 87,["90"] = 104,["92"] = 105,["93"] = 105,["94"] = 106,["95"] = 106,["96"] = 106,["97"] = 106,["98"] = 106,["99"] = 106,["100"] = 106,["101"] = 106,["102"] = 106,["103"] = 106,["104"] = 106,["105"] = 106,["106"] = 106,["107"] = 106,["108"] = 105,["111"] = 104,["112"] = 123,["114"] = 124,["115"] = 124,["116"] = 125,["117"] = 125,["118"] = 125,["119"] = 125,["120"] = 125,["121"] = 125,["122"] = 125,["123"] = 125,["124"] = 125,["125"] = 125,["126"] = 125,["127"] = 125,["128"] = 125,["129"] = 125,["130"] = 124,["133"] = 140,["134"] = 141,["136"] = 123,["137"] = 145,["139"] = 146,["140"] = 146,["141"] = 147,["142"] = 148,["143"] = 149,["144"] = 149,["145"] = 149,["146"] = 149,["147"] = 149,["148"] = 149,["149"] = 149,["150"] = 149,["151"] = 149,["152"] = 149,["153"] = 149,["154"] = 149,["155"] = 149,["156"] = 149,["157"] = 146,["160"] = 145,["161"] = 167,["162"] = 168,["163"] = 168,["164"] = 168,["165"] = 168,["166"] = 168,["167"] = 168,["168"] = 168,["169"] = 168,["170"] = 168,["171"] = 168,["172"] = 168,["173"] = 168,["174"] = 168,["175"] = 168,["176"] = 167,["177"] = 185,["179"] = 186,["180"] = 186,["181"] = 187,["182"] = 187,["183"] = 187,["184"] = 187,["185"] = 187,["186"] = 187,["187"] = 187,["188"] = 187,["189"] = 187,["190"] = 187,["191"] = 187,["192"] = 187,["193"] = 187,["194"] = 187,["195"] = 186,["198"] = 185,["199"] = 204,["200"] = 205,["202"] = 206,["203"] = 206,["205"] = 207,["206"] = 208,["207"] = 209,["208"] = 210,["210"] = 212,["211"] = 213,["212"] = 214,["213"] = 215,["214"] = 216,["215"] = 217,["218"] = 206,["221"] = 219,["222"] = 204,["223"] = 222,["225"] = 223,["226"] = 223,["227"] = 224,["228"] = 225,["229"] = 226,["230"] = 226,["231"] = 226,["232"] = 226,["233"] = 227,["234"] = 227,["235"] = 227,["236"] = 227,["237"] = 227,["238"] = 227,["239"] = 228,["240"] = 229,["241"] = 230,["243"] = 231,["244"] = 231,["245"] = 232,["246"] = 233,["247"] = 234,["248"] = 235,["249"] = 235,["250"] = 235,["251"] = 234,["252"] = 236,["253"] = 236,["254"] = 236,["255"] = 234,["256"] = 234,["257"] = 234,["258"] = 234,["259"] = 231,["262"] = 241,["263"] = 242,["264"] = 242,["265"] = 242,["266"] = 242,["267"] = 242,["268"] = 242,["269"] = 243,["270"] = 245,["271"] = 246,["272"] = 246,["273"] = 246,["274"] = 246,["275"] = 246,["276"] = 246,["277"] = 247,["278"] = 247,["279"] = 247,["280"] = 247,["281"] = 247,["282"] = 247,["284"] = 249,["285"] = 249,["286"] = 249,["287"] = 249,["288"] = 249,["290"] = 223,["293"] = 222,["294"] = 254,["295"] = 255,["296"] = 254,["297"] = 258,["298"] = 259,["299"] = 258});
local ____exports = {}
local ____Dora = require("Dora")
local Vec2 = ____Dora.Vec2
local Color = ____Dora.Color
local ____palette = require("core.palette")
local Palette = ____palette.Palette
local RING_SEGS = 18
____exports.EffectSystem = __TS__Class()
local EffectSystem = ____exports.EffectSystem
EffectSystem.name = "EffectSystem"
function EffectSystem.prototype.____constructor(self)
    self.parts = {}
    self.sheetHook = nil
end
function EffectSystem.prototype.push(self, p)
    if #self.parts < 600 then
        self.parts:push(p)
    end
end
function EffectSystem.prototype.spawnMist(self, x, y, count, scale)
    do
        local i = 0
        while i < count do
            local a = Math:random() * Math.PI * 2
            local sp = 30 + Math:random() * 90 * scale
            self:push({
                kind = "mist",
                x = x + (Math:random() - 0.5) * 30 * scale,
                y = y + Math:random() * 40 * scale,
                vx = Math:cos(a) * sp,
                vy = Math:sin(a) * sp * 0.6 + 40,
                life = 0.9 + Math:random() * 0.8,
                maxLife = 1.7,
                size = (10 + Math:random() * 16) * scale,
                grow = 26 * scale,
                gravity = -30,
                color = i % 3 == 0 and Palette.mistLight or Palette.mist,
                phase = Math:random() * 6.28
            })
            i = i + 1
        end
    end
    if self.sheetHook ~= nil then
        self.sheetHook(x, y + 26, 1, true)
    end
end
function EffectSystem.prototype.spawnInkBurst(self, x, y, dir)
    do
        local i = 0
        while i < 8 do
            self:push({
                kind = "drop",
                x = x,
                y = y + (Math:random() - 0.5) * 20,
                vx = dir * (60 + Math:random() * 220) + (Math:random() - 0.5) * 80,
                vy = 60 + Math:random() * 220,
                life = 0.4 + Math:random() * 0.3,
                maxLife = 0.7,
                size = 2 + Math:random() * 3.5,
                grow = 0,
                gravity = 900,
                color = Palette.inkDark,
                phase = 0
            })
            i = i + 1
        end
    end
end
function EffectSystem.prototype.spawnRing(self, x, y, color, size, grow, life)
    self:push({
        kind = "ring",
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        life = life,
        maxLife = life,
        size = size,
        grow = grow,
        gravity = 0,
        color = color,
        phase = 0
    })
end
function EffectSystem.prototype.spawnDust(self, x, y, dir)
    do
        local i = 0
        while i < 6 do
            self:push({
                kind = "dust",
                x = x + (Math:random() - 0.5) * 16,
                y = y,
                vx = dir * (30 + Math:random() * 90) + (Math:random() - 0.5) * 60,
                vy = 20 + Math:random() * 70,
                life = 0.35 + Math:random() * 0.25,
                maxLife = 0.6,
                size = 3 + Math:random() * 4,
                grow = 8,
                gravity = 60,
                color = Palette.paleInk,
                phase = 0
            })
            i = i + 1
        end
    end
end
function EffectSystem.prototype.spawnSpark(self, x, y, dir)
    do
        local i = 0
        while i < 5 do
            self:push({
                kind = "spark",
                x = x,
                y = y + (Math:random() - 0.5) * 24,
                vx = dir * (200 + Math:random() * 320),
                vy = (Math:random() - 0.5) * 260,
                life = 0.12 + Math:random() * 0.12,
                maxLife = 0.24,
                size = 2,
                grow = 0,
                gravity = 0,
                color = Palette.moonCyan,
                phase = 0
            })
            i = i + 1
        end
    end
    if self.sheetHook ~= nil then
        self.sheetHook(x, y, dir, false)
    end
end
function EffectSystem.prototype.spawnStars(self, x, y, n)
    do
        local i = 0
        while i < n do
            local a = Math:random() * Math.PI * 2
            local sp = 40 + Math:random() * 120
            self:push({
                kind = "star",
                x = x,
                y = y,
                vx = Math:cos(a) * sp,
                vy = Math:sin(a) * sp + 60,
                life = 0.6 + Math:random() * 0.5,
                maxLife = 1.1,
                size = 2 + Math:random() * 2.5,
                grow = 0,
                gravity = 140,
                color = Palette.moonCyan,
                phase = Math:random() * 6.28
            })
            i = i + 1
        end
    end
end
function EffectSystem.prototype.spawnEmber(self, x, y)
    self:push({
        kind = "ember",
        x = x + (Math:random() - 0.5) * 8,
        y = y,
        vx = (Math:random() - 0.5) * 20,
        vy = 30 + Math:random() * 50,
        life = 0.5 + Math:random() * 0.4,
        maxLife = 0.9,
        size = 2 + Math:random() * 2,
        grow = 0,
        gravity = -40,
        color = Palette.vermilion,
        phase = 0
    })
end
function EffectSystem.prototype.spawnRopeCut(self, x, y)
    do
        local i = 0
        while i < 10 do
            self:push({
                kind = "drop",
                x = x + (Math:random() - 0.5) * 8,
                y = y + (Math:random() - 0.5) * 20,
                vx = (Math:random() - 0.5) * 180,
                vy = -40 + Math:random() * 160,
                life = 0.5 + Math:random() * 0.3,
                maxLife = 0.8,
                size = 1.5 + Math:random() * 2,
                grow = 0,
                gravity = 700,
                color = Palette.gold,
                phase = 0
            })
            i = i + 1
        end
    end
end
function EffectSystem.prototype.update(self, dt)
    local w = 0
    do
        local i = 0
        while i < #self.parts do
            do
                local p = self.parts[i + 1]
                p.life = p.life - dt
                if p.life <= 0 then
                    goto __continue29
                end
                p.vy = p.vy + p.gravity * dt
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                p.size = p.size + p.grow * dt
                self.parts[w + 1] = p
                w = w + 1
            end
            ::__continue29::
            i = i + 1
        end
    end
    __TS__ArraySetLength(self.parts, w)
end
function EffectSystem.prototype.draw(self, draw)
    do
        local i = 0
        while i < #self.parts do
            local p = self.parts[i + 1]
            local t = p.life / p.maxLife
            local alpha = Math:max(
                0,
                Math:min(1, t)
            )
            local c = Color(
                p.color.r,
                p.color.g,
                p.color.b,
                Math:floor(p.color.a * alpha)
            )
            if p.kind == "ring" then
                local r = p.size
                local segs = RING_SEGS
                do
                    local s = 0
                    while s < segs do
                        local a0 = s / segs * Math.PI * 2 + p.phase
                        local a1 = (s + 1) / segs * Math.PI * 2 + p.phase
                        draw:drawSegment(
                            Vec2(
                                p.x + Math:cos(a0) * r,
                                p.y + Math:sin(a0) * r
                            ),
                            Vec2(
                                p.x + Math:cos(a1) * r,
                                p.y + Math:sin(a1) * r
                            ),
                            2.5,
                            c
                        )
                        s = s + 1
                    end
                end
            elseif p.kind == "spark" then
                draw:drawSegment(
                    Vec2(p.x, p.y),
                    Vec2(p.x - p.vx * 0.03, p.y - p.vy * 0.03),
                    p.size,
                    c
                )
            elseif p.kind == "star" then
                local s = p.size * (0.6 + 0.4 * Math:sin(p.phase + p.life * 10))
                draw:drawSegment(
                    Vec2(p.x - s, p.y),
                    Vec2(p.x + s, p.y),
                    1.5,
                    c
                )
                draw:drawSegment(
                    Vec2(p.x, p.y - s),
                    Vec2(p.x, p.y + s),
                    1.5,
                    c
                )
            else
                draw:drawDot(
                    Vec2(p.x, p.y),
                    p.size * (0.5 + 0.5 * alpha),
                    c
                )
            end
            i = i + 1
        end
    end
end
function EffectSystem.prototype.count(self)
    return #self.parts
end
function EffectSystem.prototype.clearAll(self)
    __TS__ArraySetLength(self.parts, 0)
end
return ____exports
