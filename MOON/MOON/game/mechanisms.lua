local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 14,["10"] = 14,["11"] = 14,["12"] = 14,["13"] = 40,["14"] = 41,["15"] = 42,["16"] = 44,["17"] = 44,["18"] = 44,["19"] = 50,["20"] = 219,["21"] = 220,["22"] = 221,["23"] = 222,["24"] = 223,["25"] = 51,["26"] = 52,["27"] = 53,["28"] = 54,["29"] = 50,["30"] = 57,["31"] = 58,["33"] = 59,["34"] = 59,["35"] = 60,["36"] = 61,["37"] = 61,["38"] = 61,["39"] = 61,["40"] = 61,["41"] = 61,["42"] = 61,["43"] = 61,["44"] = 61,["45"] = 61,["46"] = 59,["49"] = 57,["50"] = 66,["52"] = 67,["53"] = 67,["54"] = 68,["55"] = 69,["56"] = 70,["57"] = 71,["59"] = 67,["62"] = 66,["63"] = 76,["64"] = 77,["65"] = 76,["66"] = 80,["67"] = 81,["70"] = 84,["71"] = 85,["72"] = 80,["73"] = 88,["74"] = 89,["75"] = 88,["76"] = 92,["77"] = 93,["78"] = 92,["79"] = 96,["80"] = 97,["81"] = 96,["82"] = 100,["83"] = 101,["84"] = 100,["85"] = 104,["87"] = 113,["88"] = 113,["89"] = 114,["90"] = 115,["91"] = 117,["92"] = 122,["93"] = 124,["94"] = 125,["95"] = 126,["97"] = 128,["100"] = 131,["102"] = 133,["103"] = 134,["104"] = 134,["105"] = 134,["106"] = 134,["107"] = 134,["108"] = 134,["109"] = 134,["110"] = 134,["111"] = 134,["112"] = 134,["113"] = 134,["114"] = 145,["115"] = 145,["116"] = 145,["117"] = 145,["118"] = 145,["119"] = 145,["120"] = 145,["121"] = 146,["122"] = 147,["123"] = 148,["124"] = 149,["125"] = 150,["126"] = 113,["130"] = 154,["131"] = 154,["133"] = 155,["134"] = 156,["135"] = 157,["137"] = 159,["138"] = 160,["139"] = 161,["140"] = 162,["143"] = 164,["144"] = 164,["145"] = 165,["146"] = 166,["148"] = 164,["151"] = 169,["152"] = 170,["153"] = 171,["154"] = 172,["155"] = 172,["156"] = 172,["157"] = 172,["158"] = 172,["159"] = 172,["160"] = 172,["161"] = 172,["162"] = 173,["166"] = 154,["170"] = 178,["171"] = 178,["173"] = 179,["174"] = 180,["175"] = 181,["177"] = 183,["179"] = 184,["180"] = 184,["181"] = 185,["182"] = 186,["183"] = 187,["184"] = 187,["185"] = 187,["186"] = 187,["187"] = 187,["188"] = 187,["189"] = 187,["190"] = 187,["192"] = 188,["193"] = 188,["194"] = 189,["195"] = 188,["198"] = 191,["199"] = 192,["202"] = 184,["207"] = 178,["211"] = 199,["212"] = 199,["214"] = 200,["215"] = 201,["216"] = 202,["219"] = 204,["220"] = 204,["221"] = 205,["222"] = 206,["223"] = 207,["224"] = 208,["225"] = 209,["226"] = 210,["227"] = 211,["228"] = 211,["229"] = 211,["230"] = 211,["231"] = 211,["232"] = 211,["233"] = 211,["234"] = 211,["235"] = 212,["238"] = 204,["243"] = 199,["246"] = 104,["247"] = 225,["248"] = 226,["249"] = 227,["250"] = 228,["251"] = 225,["252"] = 232,["253"] = 233,["254"] = 234,["256"] = 235,["257"] = 235,["258"] = 236,["259"] = 237,["260"] = 238,["261"] = 239,["262"] = 240,["264"] = 235,["267"] = 243,["268"] = 244,["270"] = 246,["271"] = 247,["273"] = 249,["274"] = 250,["275"] = 251,["276"] = 252,["277"] = 253,["278"] = 254,["279"] = 254,["280"] = 254,["281"] = 254,["282"] = 254,["283"] = 254,["284"] = 254,["285"] = 254,["286"] = 255,["287"] = 256,["288"] = 258,["289"] = 259,["291"] = 261,["293"] = 264,["295"] = 265,["296"] = 265,["297"] = 266,["298"] = 265,["301"] = 268,["302"] = 269,["303"] = 270,["304"] = 271,["305"] = 232,["306"] = 275,["308"] = 276,["309"] = 276,["311"] = 277,["312"] = 278,["313"] = 279,["315"] = 281,["316"] = 282,["317"] = 283,["318"] = 284,["319"] = 285,["320"] = 286,["321"] = 286,["322"] = 286,["323"] = 286,["324"] = 286,["325"] = 286,["326"] = 286,["327"] = 286,["328"] = 287,["332"] = 276,["335"] = 275,["336"] = 293,["338"] = 294,["339"] = 294,["341"] = 295,["342"] = 296,["343"] = 297,["345"] = 299,["346"] = 300,["348"] = 302,["349"] = 303,["350"] = 304,["351"] = 305,["352"] = 306,["353"] = 307,["354"] = 308,["355"] = 309,["356"] = 310,["357"] = 311,["358"] = 312,["359"] = 313,["360"] = 314,["362"] = 316,["363"] = 317,["364"] = 317,["365"] = 317,["366"] = 317,["367"] = 317,["368"] = 317,["369"] = 317,["370"] = 317,["371"] = 318,["375"] = 294,["378"] = 293});
local ____exports = {}
local ____physics = require("game.physics")
local rectOverlap = ____physics.rectOverlap
local moveAndCollide = ____physics.moveAndCollide
local clamp = ____physics.clamp
local STONE_W = 56
local STONE_H = 44
local GRAV = 2300
____exports.MechanismSystem = __TS__Class()
local MechanismSystem = ____exports.MechanismSystem
MechanismSystem.name = "MechanismSystem"
function MechanismSystem.prototype.____constructor(self, state, fx, events)
    self.fxGold = {r = 155, g = 113, b = 56, a = 255}
    self.fxCyan = {r = 168, g = 197, b = 188, a = 255}
    self.ropesList = {}
    self.bellsList = {}
    self.platesList = {}
    self.state = state
    self.fx = fx
    self.events = events
    self.stones = {}
end
function MechanismSystem.prototype.syncStones(self, defs)
    __TS__ArraySetLength(self.stones, 0)
    do
        local i = 0
        while i < #defs do
            local d = defs[i + 1]
            local ____self_stones_0 = self.stones
            ____self_stones_0[#____self_stones_0 + 1] = {
                x = d.x,
                y = d.y + STONE_H / 2,
                vx = 0,
                vy = 0,
                w = STONE_W,
                h = STONE_H,
                onGround = false
            }
            i = i + 1
        end
    end
end
function MechanismSystem.prototype.applyLoopVariants(self, ropes)
    do
        local i = 0
        while i < #ropes do
            local r = ropes[i + 1]
            if r.loopState == "precut" and self.state.loopIndex >= 1 then
                self.state.cutRopes[r.id] = true
                self:openGateSilent(r.gateId)
            end
            i = i + 1
        end
    end
end
function MechanismSystem.prototype.isGateOpen(self, gateId)
    return self.state.openedGates[gateId] == true
end
function MechanismSystem.prototype.openGate(self, gateId)
    if self.state.openedGates[gateId] then
        return
    end
    self.state.openedGates[gateId] = true
    self.events:onGateOpen(gateId)
end
function MechanismSystem.prototype.openGateSilent(self, gateId)
    self.state.openedGates[gateId] = true
end
function MechanismSystem.prototype.ropeRect(self, r)
    return {x = r.x - 6, y = r.y - r.length, w = 12, h = r.length}
end
function MechanismSystem.prototype.bellRect(self, b)
    return {x = b.x - 26, y = b.y - 20, w = 52, h = 46}
end
function MechanismSystem.prototype.stoneRect(self, s)
    return {x = s.x - s.w / 2, y = s.y - s.h / 2, w = s.w, h = s.h}
end
function MechanismSystem.prototype.update(self, dt, playerRect, playerPushDir, attackRect, qiRects, ctx)
    do
        local i = 0
        while i < #self.stones do
            local s = self.stones[i + 1]
            local sr = self:stoneRect(s)
            local adjacent = playerRect.x < sr.x + sr.w + 4 and playerRect.x + playerRect.w > sr.x - 4 and playerRect.y < sr.y + sr.h and playerRect.y + playerRect.h > sr.y
            if adjacent and playerPushDir ~= 0 and s.onGround then
                local pushRight = playerRect.x + playerRect.w / 2 < s.x
                if pushRight and playerPushDir > 0 or not pushRight and playerPushDir < 0 then
                    s.vx = playerPushDir * 70
                else
                    s.vx = s.vx * 0.6
                end
            else
                s.vx = s.vx * 0.6
            end
            s.vy = clamp(s.vy - GRAV * dt, -1150, 1150)
            local body = {
                x = s.x,
                y = s.y,
                vx = s.vx,
                vy = s.vy,
                w = s.w,
                h = s.h,
                onGround = s.onGround,
                groundId = "",
                onLadder = false
            }
            moveAndCollide(
                body,
                ctx.platforms,
                s.vx * dt,
                s.vy * dt,
                false
            )
            s.x = body.x
            s.y = body.y
            s.vx = body.vx
            s.vy = body.vy
            s.onGround = body.onGround
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.ropesList do
            do
                local r = self.ropesList[i + 1]
                if self.state.cutRopes[r.id] then
                    goto __continue25
                end
                local rr = self:ropeRect(r)
                local cut = false
                if attackRect ~= nil and rectOverlap(attackRect, rr) then
                    cut = true
                end
                do
                    local k = 0
                    while k < #qiRects do
                        if rectOverlap(qiRects[k + 1], rr) then
                            cut = true
                        end
                        k = k + 1
                    end
                end
                if cut then
                    self.state.cutRopes[r.id] = true
                    self.fx:spawnRopeCut(r.x, r.y - r.length / 2)
                    self.fx:spawnRing(
                        r.x,
                        r.y - r.length / 2,
                        self.fxGold,
                        10,
                        90,
                        0.5
                    )
                    self:openGate(r.gateId)
                end
            end
            ::__continue25::
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.bellsList do
            do
                local b = self.bellsList[i + 1]
                if self.state.rungBells[b.id] then
                    goto __continue33
                end
                local br = self:bellRect(b)
                do
                    local k = 0
                    while k < #qiRects do
                        if rectOverlap(qiRects[k + 1], br) then
                            self.state.rungBells[b.id] = true
                            self.fx:spawnRing(
                                b.x,
                                b.y,
                                self.fxCyan,
                                14,
                                130,
                                0.8
                            )
                            do
                                local s = 0
                                while s < 10 do
                                    self.fx:spawnStars(b.x, b.y, 2)
                                    s = s + 1
                                end
                            end
                            self.events:onBell(b.x, b.y)
                            self:openGate(b.gateId)
                            break
                        end
                        k = k + 1
                    end
                end
            end
            ::__continue33::
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.platesList do
            do
                local p = self.platesList[i + 1]
                if self.state.platesActive[p.id] then
                    goto __continue41
                end
                do
                    local k = 0
                    while k < #self.stones do
                        local s = self.stones[k + 1]
                        local sr = self:stoneRect(s)
                        local nearX = math.abs(s.x - p.x) < 40
                        local onTop = math.abs(sr.y - sr.h / 2 - p.y) < 8
                        if nearX and onTop and s.onGround then
                            self.state.platesActive[p.id] = true
                            self.fx:spawnRing(
                                p.x,
                                p.y + 4,
                                self.fxGold,
                                12,
                                70,
                                0.6
                            )
                            self:openGate(p.gateId)
                            break
                        end
                        k = k + 1
                    end
                end
            end
            ::__continue41::
            i = i + 1
        end
    end
end
function MechanismSystem.prototype.bindLists(self, ropes, bells, plates)
    self.ropesList = ropes
    self.bellsList = bells
    self.platesList = plates
end
function MechanismSystem.prototype.tryLightLantern(self, lanterns, px, py)
    local nearest = nil
    local bestDist = 60
    do
        local i = 0
        while i < #lanterns do
            local l = lanterns[i + 1]
            local d = math.abs(l.x - px) + math.abs(l.y - py) * 0.5
            if d < bestDist then
                bestDist = d
                nearest = l
            end
            i = i + 1
        end
    end
    if nearest == nil then
        return false
    end
    if self.state.lanternsLit[nearest.id] then
        return false
    end
    local expected = self.state.lanternSequence + 1
    if nearest.order == expected then
        self.state.lanternsLit[nearest.id] = true
        self.state.lanternSequence = expected
        self.state.lanternFailed = false
        self.fx:spawnRing(
            nearest.x,
            nearest.y + 14,
            self.fxCyan,
            10,
            60,
            0.6
        )
        self.events:onLanternLit(nearest.order)
        if expected >= #lanterns then
            self:openGate("lanternGate")
            self:openGate("gate_workshop")
        end
        return true
    end
    local ids = __TS__ObjectKeys(self.state.lanternsLit)
    do
        local i = 0
        while i < #ids do
            self.state.lanternsLit[ids[i + 1]] = false
            i = i + 1
        end
    end
    self.state.lanternSequence = 0
    self.state.lanternFailed = true
    self.events:onLanternFail()
    return false
end
function MechanismSystem.prototype.touchCheckpoints(self, checkpoints, px, py)
    do
        local i = 0
        while i < #checkpoints do
            do
                local c = checkpoints[i + 1]
                if self.state.checkpointsActivated[c.id] then
                    goto __continue59
                end
                local dx = math.abs(c.x - px)
                local dy = math.abs(c.y - py)
                if dx < 52 and dy < 70 then
                    self.state.checkpointsActivated[c.id] = true
                    self.state.currentCheckpointId = c.id
                    self.fx:spawnRing(
                        c.x,
                        c.y + 40,
                        self.fxCyan,
                        14,
                        110,
                        0.9
                    )
                    self.events:onCheckpoint(c.id)
                end
            end
            ::__continue59::
            i = i + 1
        end
    end
end
function MechanismSystem.prototype.touchCollectibles(self, collectibles, px, py)
    do
        local i = 0
        while i < #collectibles do
            do
                local c = collectibles[i + 1]
                if self.state.collectedIds[c.id] then
                    goto __continue64
                end
                if c.loops ~= nil and __TS__ArrayIndexOf(c.loops, self.state.loopIndex) < 0 then
                    goto __continue64
                end
                local dx = c.x - px
                local dy = c.y - py
                if dx * dx + dy * dy < 38 * 38 then
                    self.state.collectedIds[c.id] = true
                    if c.kind == "moonstone" then
                        self.state.moonstones = self.state.moonstones + 1
                    elseif c.kind == "mechanism" then
                        self.state.mechanismParts = self.state.mechanismParts + 1
                    elseif c.kind == "token" then
                        self.state.tokens = self.state.tokens + 1
                        self.state.shenyanTrust = self.state.shenyanTrust + 1
                    elseif c.kind == "dew" then
                        self.state.heroineLife = math.min(self.state.maxLife, self.state.heroineLife + 1)
                    end
                    self.fx:spawnStars(c.x, c.y, 8)
                    self.fx:spawnRing(
                        c.x,
                        c.y,
                        c.kind == "moonstone" and self.fxCyan or self.fxGold,
                        8,
                        80,
                        0.5
                    )
                    self.events:onCollect(c.kind, c.x, c.y)
                end
            end
            ::__continue64::
            i = i + 1
        end
    end
end
return ____exports
