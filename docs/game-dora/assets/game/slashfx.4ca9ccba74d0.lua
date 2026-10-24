local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 5,["8"] = 5,["9"] = 5,["10"] = 5,["11"] = 5,["12"] = 5,["13"] = 5,["14"] = 33,["15"] = 34,["16"] = 35,["17"] = 36,["18"] = 38,["19"] = 38,["20"] = 38,["21"] = 49,["22"] = 50,["23"] = 51,["24"] = 52,["25"] = 53,["26"] = 54,["27"] = 55,["28"] = 56,["29"] = 57,["30"] = 58,["31"] = 49,["32"] = 61,["33"] = 62,["36"] = 65,["37"] = 67,["38"] = 68,["39"] = 69,["40"] = 70,["41"] = 70,["42"] = 70,["43"] = 70,["45"] = 72,["46"] = 73,["47"] = 74,["48"] = 75,["49"] = 75,["50"] = 75,["51"] = 75,["53"] = 61,["54"] = 80,["55"] = 81,["56"] = 82,["57"] = 80,["58"] = 86,["59"] = 87,["60"] = 88,["61"] = 88,["62"] = 88,["64"] = 88,["66"] = 88,["67"] = 89,["68"] = 90,["69"] = 91,["72"] = 94,["73"] = 94,["74"] = 94,["75"] = 94,["76"] = 95,["79"] = 98,["80"] = 99,["81"] = 100,["82"] = 101,["83"] = 102,["84"] = 103,["85"] = 104,["86"] = 105,["87"] = 105,["88"] = 105,["89"] = 105,["90"] = 105,["91"] = 105,["92"] = 105,["93"] = 105,["94"] = 105,["97"] = 108,["100"] = 111,["101"] = 112,["102"] = 113,["103"] = 113,["104"] = 113,["105"] = 113,["106"] = 113,["107"] = 113,["108"] = 113,["109"] = 113,["110"] = 114,["111"] = 114,["112"] = 114,["113"] = 114,["114"] = 114,["115"] = 114,["116"] = 114,["117"] = 114,["118"] = 114,["119"] = 86,["120"] = 118,["121"] = 119,["122"] = 120,["123"] = 121,["126"] = 124,["127"] = 125,["128"] = 126,["129"] = 127,["130"] = 128,["133"] = 131,["134"] = 132,["135"] = 132,["136"] = 132,["137"] = 132,["138"] = 132,["139"] = 132,["140"] = 132,["141"] = 132,["142"] = 132,["143"] = 133,["146"] = 136,["147"] = 137,["148"] = 138,["150"] = 140,["152"] = 141,["153"] = 141,["154"] = 142,["155"] = 143,["156"] = 144,["157"] = 145,["158"] = 146,["159"] = 141,["162"] = 118,["163"] = 151,["164"] = 152,["165"] = 151,["166"] = 155,["168"] = 156,["169"] = 156,["170"] = 157,["171"] = 156,["174"] = 159,["175"] = 155,["176"] = 162,["177"] = 163,["178"] = 164,["179"] = 165,["180"] = 166,["181"] = 167,["182"] = 168,["183"] = 169,["185"] = 171,["186"] = 172,["187"] = 173,["188"] = 174,["190"] = 176,["191"] = 177,["192"] = 178,["194"] = 180,["196"] = 182,["197"] = 183,["198"] = 184,["199"] = 185,["200"] = 186,["201"] = 187,["202"] = 188,["204"] = 190,["205"] = 191,["206"] = 191,["207"] = 191,["208"] = 191,["209"] = 191,["210"] = 191,["211"] = 191,["212"] = 191,["214"] = 193,["216"] = 162,["217"] = 197,["219"] = 198,["220"] = 198,["221"] = 199,["222"] = 198,["225"] = 201,["227"] = 202,["228"] = 202,["229"] = 203,["230"] = 202,["233"] = 205,["234"] = 206,["235"] = 197,["236"] = 210,["237"] = 211,["238"] = 212,["240"] = 217,["241"] = 217,["242"] = 218,["243"] = 219,["244"] = 219,["245"] = 219,["246"] = 219,["247"] = 219,["248"] = 219,["249"] = 219,["250"] = 219,["251"] = 219,["252"] = 219,["253"] = 219,["254"] = 219,["255"] = 219,["256"] = 219,["257"] = 219,["258"] = 217,["261"] = 221,["262"] = 221,["263"] = 221,["264"] = 221,["265"] = 221,["266"] = 221,["267"] = 221,["268"] = 221,["269"] = 221,["270"] = 221,["271"] = 221,["272"] = 221,["273"] = 221,["274"] = 221,["275"] = 221,["276"] = 210,["277"] = 224,["278"] = 225,["279"] = 226,["280"] = 227,["282"] = 228,["283"] = 228,["284"] = 229,["285"] = 230,["286"] = 230,["287"] = 230,["288"] = 230,["289"] = 228,["292"] = 232,["293"] = 233,["294"] = 234,["296"] = 235,["297"] = 235,["298"] = 236,["299"] = 237,["300"] = 237,["301"] = 237,["302"] = 237,["303"] = 235,["306"] = 239,["307"] = 224});
local ____exports = {}
local ____Dora = require("Dora")
local Color = ____Dora.Color
local DrawNode = ____Dora.DrawNode
local Rect = ____Dora.Rect
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local Vec2 = ____Dora.Vec2
local SWING_DUR = 0.16
local ARC_DUR = 0.18
local SWING_H = 96
local SHOT_H = 66
____exports.SlashFxSystem = __TS__Class()
local SlashFxSystem = ____exports.SlashFxSystem
SlashFxSystem.name = "SlashFxSystem"
function SlashFxSystem.prototype.____constructor(self, parent)
    self.parent = parent
    self.whiteTex = nil
    self.blueTex = nil
    self.whiteFrames = 0
    self.blueFrames = 0
    self.checked = false
    self.swings = {}
    self.arcs = {}
    self.shotSprites = {}
end
function SlashFxSystem.prototype.ensureTextures(self)
    if self.checked then
        return
    end
    self.checked = true
    local white = Texture2D("assets/effects/slash_white.png")
    if white ~= nil then
        self.whiteTex = white
        self.whiteFrames = Math:max(
            1,
            Math:floor(white.width / 64)
        )
    end
    local blue = Texture2D("assets/effects/slash_blue.png")
    if blue ~= nil then
        self.blueTex = blue
        self.blueFrames = Math:max(
            1,
            Math:floor(blue.width / 64)
        )
    end
end
function SlashFxSystem.prototype.hasBlueTex(self)
    self:ensureTextures()
    return self.blueTex ~= nil
end
function SlashFxSystem.prototype.spawnSwing(self, x, y, dir, blue)
    self:ensureTextures()
    local ____blue_0
    if blue then
        ____blue_0 = self.blueTex
    else
        ____blue_0 = self.whiteTex
    end
    local tex = ____blue_0
    local frames = blue and self.blueFrames or self.whiteFrames
    if tex ~= nil and frames > 0 then
        if #self.swings > 6 then
            return
        end
        local sp = Sprite(
            tex,
            Rect(0, 0, 64, 64)
        )
        if sp == nil then
            return
        end
        sp.filter = "Point"
        local k = SWING_H / 64
        sp.scaleX = (dir >= 0 and 1 or -1) * k
        sp.scaleY = k
        sp.opacity = 255
        sp.position = Vec2(x + dir * 36, y + 8)
        sp:addTo(self.parent)
        self.swings:push({
            sprite = sp,
            baseX = x + dir * 36,
            baseY = y + 8,
            dir = dir,
            t = 0,
            dur = SWING_DUR,
            frames = frames
        })
        return
    end
    if #self.arcs > 6 then
        return
    end
    local draw = DrawNode()
    draw:addTo(self.parent)
    self:drawArc(
        draw,
        x,
        y,
        dir,
        blue,
        1
    )
    self.arcs:push({
        draw = draw,
        x = x,
        y = y,
        dir = dir,
        blue = blue,
        t = 0,
        dur = ARC_DUR
    })
end
function SlashFxSystem.prototype.syncShots(self, items)
    self:ensureTextures()
    if self.blueTex == nil or self.blueFrames <= 0 then
        self:clearShots()
        return
    end
    local tex = self.blueTex
    while #self.shotSprites > #items do
        local sp = self.shotSprites:pop()
        if sp ~= nil then
            sp:removeFromParent()
        end
    end
    while #self.shotSprites < #items do
        local created = Sprite(
            tex,
            Rect(
                self:shotFrame() * 64,
                0,
                64,
                64
            )
        )
        if created == nil then
            return
        end
        created.filter = "Point"
        created:addTo(self.parent)
        self.shotSprites:push(created)
    end
    local k = SHOT_H / 64
    do
        local i = 0
        while i < #self.shotSprites do
            local sp = self.shotSprites[i + 1]
            local it = items[i + 1]
            sp.position = Vec2(it.x, it.y)
            sp.scaleX = (it.dir >= 0 and 1 or -1) * k
            sp.scaleY = k
            i = i + 1
        end
    end
end
function SlashFxSystem.prototype.shotFrame(self)
    return Math:floor(self.blueFrames / 2)
end
function SlashFxSystem.prototype.clearShots(self)
    do
        local i = 0
        while i < #self.shotSprites do
            self.shotSprites[i + 1]:removeFromParent()
            i = i + 1
        end
    end
    __TS__ArraySetLength(self.shotSprites, 0)
end
function SlashFxSystem.prototype.update(self, dt)
    local i = #self.swings - 1
    while i >= 0 do
        local s = self.swings[i + 1]
        s.t = s.t + dt
        if s.t >= s.dur then
            s.sprite:removeFromParent()
            self.swings:splice(i, 1)
        else
            local p = s.t / s.dur
            local idx = Math:floor(p * s.frames + 0.0001)
            if idx > s.frames - 1 then
                idx = s.frames - 1
            end
            s.sprite.textureRect = Rect(idx * 64, 0, 64, 64)
            s.sprite.opacity = Math:floor(255 * (1 - p))
            s.sprite.position = Vec2(s.baseX + s.dir * 54 * p, s.baseY)
        end
        i = i - 1
    end
    i = #self.arcs - 1
    while i >= 0 do
        local a = self.arcs[i + 1]
        a.t = a.t + dt
        if a.t >= a.dur then
            a.draw:removeFromParent()
            self.arcs:splice(i, 1)
        else
            a.draw:clear()
            self:drawArc(
                a.draw,
                a.x,
                a.y,
                a.dir,
                a.blue,
                1 - a.t / a.dur
            )
        end
        i = i - 1
    end
end
function SlashFxSystem.prototype.clear(self)
    do
        local i = 0
        while i < #self.swings do
            self.swings[i + 1].sprite:removeFromParent()
            i = i + 1
        end
    end
    __TS__ArraySetLength(self.swings, 0)
    do
        local i = 0
        while i < #self.arcs do
            self.arcs[i + 1].draw:removeFromParent()
            i = i + 1
        end
    end
    __TS__ArraySetLength(self.arcs, 0)
    self:clearShots()
end
function SlashFxSystem.prototype.drawArc(self, draw, x, y, dir, blue, alpha)
    local c = blue and Color(130, 180, 255, 255) or Color(255, 255, 255, 255)
    local layers = {{s = 0.78, ox = -30, a = 70}, {s = 0.92, ox = -12, a = 120}, {s = 1, ox = 0, a = 200}}
    do
        local i = 0
        while i < #layers do
            local L = layers[i + 1]
            draw:drawPolygon(
                self:crescent(
                    x,
                    y,
                    dir,
                    L.s,
                    L.ox
                ),
                Color(
                    c.r,
                    c.g,
                    c.b,
                    Math:floor(L.a * alpha)
                )
            )
            i = i + 1
        end
    end
    draw:drawPolygon(
        self:crescent(
            x,
            y,
            dir,
            0.55,
            6
        ),
        Color(
            255,
            255,
            255,
            Math:floor(210 * alpha)
        )
    )
end
function SlashFxSystem.prototype.crescent(self, x, y, dir, scale, ox)
    local pts = {}
    local R = 44 * scale
    local aOut = 1.45
    do
        local k = 0
        while k <= 10 do
            local t = aOut - 2 * aOut * k / 10
            pts:push(Vec2(
                x + dir * (ox + R * Math:cos(t)),
                y + R * Math:sin(t)
            ))
            k = k + 1
        end
    end
    local c2 = -0.6 * R
    local ri = 1.2266 * R
    local aIn = 0.9425
    do
        local k = 0
        while k <= 10 do
            local t = -aIn + 2 * aIn * k / 10
            pts:push(Vec2(
                x + dir * (ox + c2 + ri * Math:cos(t)),
                y + ri * Math:sin(t)
            ))
            k = k + 1
        end
    end
    return pts
end
return ____exports
