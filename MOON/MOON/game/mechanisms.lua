local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 14,["10"] = 14,["11"] = 14,["12"] = 14,["13"] = 40,["14"] = 41,["15"] = 42,["16"] = 44,["17"] = 44,["18"] = 44,["19"] = 50,["20"] = 219,["21"] = 220,["22"] = 221,["23"] = 222,["24"] = 223,["25"] = 51,["26"] = 52,["27"] = 53,["28"] = 54,["29"] = 50,["30"] = 57,["31"] = 58,["33"] = 59,["34"] = 59,["35"] = 60,["36"] = 61,["37"] = 61,["38"] = 61,["39"] = 61,["40"] = 61,["41"] = 61,["42"] = 61,["43"] = 61,["44"] = 61,["45"] = 61,["46"] = 59,["49"] = 57,["50"] = 66,["52"] = 67,["53"] = 67,["54"] = 68,["55"] = 69,["56"] = 70,["57"] = 71,["59"] = 67,["62"] = 66,["63"] = 76,["64"] = 77,["65"] = 76,["66"] = 80,["67"] = 81,["70"] = 84,["71"] = 85,["72"] = 80,["73"] = 88,["74"] = 89,["75"] = 88,["76"] = 92,["77"] = 93,["78"] = 92,["79"] = 96,["80"] = 97,["81"] = 96,["82"] = 100,["83"] = 101,["84"] = 100,["85"] = 104,["87"] = 113,["88"] = 113,["89"] = 114,["90"] = 115,["91"] = 117,["92"] = 122,["93"] = 124,["94"] = 125,["95"] = 126,["97"] = 128,["100"] = 131,["102"] = 133,["103"] = 134,["104"] = 134,["105"] = 134,["106"] = 134,["107"] = 134,["108"] = 134,["109"] = 134,["110"] = 134,["111"] = 134,["112"] = 134,["113"] = 134,["114"] = 145,["115"] = 145,["116"] = 145,["117"] = 145,["118"] = 145,["119"] = 145,["120"] = 145,["121"] = 145,["122"] = 146,["123"] = 147,["124"] = 148,["125"] = 149,["126"] = 150,["127"] = 113,["131"] = 154,["132"] = 154,["134"] = 155,["135"] = 156,["136"] = 157,["138"] = 159,["139"] = 160,["140"] = 161,["141"] = 162,["144"] = 164,["145"] = 164,["146"] = 165,["147"] = 166,["149"] = 164,["152"] = 169,["153"] = 170,["154"] = 171,["155"] = 172,["156"] = 172,["157"] = 172,["158"] = 172,["159"] = 172,["160"] = 172,["161"] = 172,["162"] = 172,["163"] = 173,["167"] = 154,["171"] = 178,["172"] = 178,["174"] = 179,["175"] = 180,["176"] = 181,["178"] = 183,["180"] = 184,["181"] = 184,["182"] = 185,["183"] = 186,["184"] = 187,["185"] = 187,["186"] = 187,["187"] = 187,["188"] = 187,["189"] = 187,["190"] = 187,["191"] = 187,["193"] = 188,["194"] = 188,["195"] = 189,["196"] = 188,["199"] = 191,["200"] = 192,["203"] = 184,["208"] = 178,["212"] = 199,["213"] = 199,["215"] = 200,["216"] = 201,["217"] = 202,["220"] = 204,["221"] = 204,["222"] = 205,["223"] = 206,["224"] = 207,["225"] = 208,["226"] = 209,["227"] = 210,["228"] = 211,["229"] = 211,["230"] = 211,["231"] = 211,["232"] = 211,["233"] = 211,["234"] = 211,["235"] = 211,["236"] = 212,["239"] = 204,["244"] = 199,["247"] = 104,["248"] = 225,["249"] = 226,["250"] = 227,["251"] = 228,["252"] = 225,["253"] = 232,["254"] = 233,["255"] = 234,["257"] = 235,["258"] = 235,["259"] = 236,["260"] = 237,["261"] = 238,["262"] = 239,["263"] = 240,["265"] = 235,["268"] = 243,["269"] = 244,["271"] = 246,["272"] = 247,["274"] = 249,["275"] = 250,["276"] = 251,["277"] = 252,["278"] = 253,["279"] = 254,["280"] = 254,["281"] = 254,["282"] = 254,["283"] = 254,["284"] = 254,["285"] = 254,["286"] = 254,["287"] = 255,["288"] = 256,["289"] = 258,["290"] = 259,["292"] = 261,["294"] = 264,["296"] = 265,["297"] = 265,["298"] = 266,["299"] = 265,["302"] = 268,["303"] = 269,["304"] = 270,["305"] = 271,["306"] = 232,["307"] = 275,["309"] = 276,["310"] = 276,["312"] = 277,["313"] = 278,["314"] = 279,["316"] = 281,["317"] = 282,["318"] = 283,["319"] = 284,["320"] = 285,["321"] = 286,["322"] = 286,["323"] = 286,["324"] = 286,["325"] = 286,["326"] = 286,["327"] = 286,["328"] = 286,["329"] = 287,["333"] = 276,["336"] = 275,["337"] = 293,["339"] = 294,["340"] = 294,["342"] = 295,["343"] = 296,["344"] = 297,["346"] = 299,["347"] = 300,["349"] = 302,["350"] = 303,["351"] = 304,["352"] = 305,["353"] = 306,["354"] = 307,["355"] = 308,["356"] = 309,["357"] = 310,["358"] = 311,["359"] = 312,["360"] = 313,["361"] = 314,["363"] = 316,["364"] = 317,["365"] = 317,["366"] = 317,["367"] = 317,["368"] = 317,["369"] = 317,["370"] = 317,["371"] = 317,["372"] = 318,["376"] = 294,["379"] = 293});
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
            s.vy = clamp(nil, s.vy - GRAV * dt, -1150, 1150)
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
                nil,
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
                if attackRect ~= nil and rectOverlap(nil, attackRect, rr) then
                    cut = true
                end
                do
                    local k = 0
                    while k < #qiRects do
                        if rectOverlap(nil, qiRects[k + 1], rr) then
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
                        if rectOverlap(nil, qiRects[k + 1], br) then
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
