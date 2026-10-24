local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 17,["9"] = 17,["10"] = 17,["11"] = 17,["12"] = 19,["13"] = 19,["14"] = 54,["15"] = 55,["16"] = 56,["17"] = 58,["18"] = 58,["19"] = 58,["20"] = 64,["21"] = 273,["22"] = 274,["23"] = 275,["24"] = 276,["25"] = 277,["26"] = 278,["27"] = 280,["28"] = 282,["29"] = 300,["30"] = 301,["31"] = 65,["32"] = 66,["33"] = 67,["34"] = 68,["35"] = 64,["36"] = 71,["37"] = 72,["39"] = 73,["40"] = 73,["41"] = 74,["42"] = 75,["43"] = 75,["44"] = 75,["45"] = 75,["46"] = 75,["47"] = 75,["48"] = 75,["49"] = 75,["50"] = 75,["51"] = 73,["54"] = 71,["55"] = 80,["57"] = 81,["58"] = 81,["59"] = 82,["60"] = 83,["61"] = 84,["62"] = 85,["64"] = 81,["67"] = 80,["68"] = 90,["69"] = 91,["70"] = 90,["71"] = 94,["72"] = 95,["75"] = 98,["76"] = 99,["77"] = 94,["78"] = 102,["79"] = 103,["80"] = 102,["81"] = 106,["82"] = 107,["83"] = 106,["84"] = 110,["85"] = 111,["86"] = 110,["87"] = 114,["88"] = 115,["89"] = 114,["90"] = 118,["91"] = 128,["93"] = 129,["94"] = 129,["95"] = 130,["96"] = 129,["100"] = 133,["101"] = 133,["102"] = 134,["103"] = 135,["104"] = 137,["105"] = 142,["106"] = 145,["107"] = 146,["108"] = 147,["109"] = 148,["111"] = 150,["114"] = 153,["116"] = 155,["117"] = 156,["118"] = 156,["119"] = 156,["120"] = 156,["121"] = 156,["122"] = 156,["123"] = 156,["124"] = 156,["125"] = 156,["126"] = 156,["127"] = 156,["128"] = 167,["129"] = 167,["130"] = 167,["131"] = 167,["132"] = 167,["133"] = 167,["134"] = 167,["135"] = 168,["136"] = 169,["137"] = 170,["138"] = 171,["139"] = 172,["140"] = 133,["144"] = 176,["145"] = 176,["147"] = 177,["148"] = 178,["149"] = 179,["151"] = 181,["152"] = 182,["153"] = 183,["154"] = 184,["157"] = 186,["158"] = 186,["159"] = 187,["160"] = 188,["162"] = 186,["165"] = 191,["166"] = 192,["167"] = 193,["168"] = 194,["169"] = 194,["170"] = 194,["171"] = 194,["172"] = 194,["173"] = 194,["174"] = 194,["175"] = 194,["176"] = 195,["180"] = 176,["184"] = 200,["185"] = 200,["187"] = 201,["188"] = 202,["189"] = 203,["190"] = 204,["192"] = 206,["193"] = 207,["194"] = 208,["195"] = 209,["197"] = 211,["199"] = 212,["200"] = 212,["201"] = 213,["202"] = 214,["205"] = 212,["209"] = 219,["210"] = 221,["211"] = 222,["212"] = 222,["213"] = 222,["214"] = 222,["215"] = 222,["216"] = 222,["217"] = 222,["218"] = 222,["219"] = 223,["220"] = 224,["221"] = 225,["226"] = 200,["230"] = 231,["231"] = 231,["233"] = 232,["234"] = 233,["235"] = 234,["237"] = 236,["239"] = 237,["240"] = 237,["241"] = 238,["242"] = 239,["243"] = 240,["244"] = 240,["245"] = 240,["246"] = 240,["247"] = 240,["248"] = 240,["249"] = 240,["250"] = 240,["252"] = 241,["253"] = 241,["254"] = 242,["255"] = 241,["258"] = 244,["259"] = 245,["262"] = 237,["267"] = 231,["271"] = 252,["272"] = 252,["274"] = 253,["275"] = 254,["276"] = 255,["279"] = 257,["280"] = 257,["281"] = 258,["282"] = 259,["283"] = 260,["284"] = 262,["285"] = 263,["286"] = 264,["287"] = 265,["288"] = 265,["289"] = 265,["290"] = 265,["291"] = 265,["292"] = 265,["293"] = 265,["294"] = 265,["295"] = 266,["298"] = 257,["303"] = 252,["306"] = 118,["307"] = 284,["308"] = 285,["309"] = 286,["310"] = 287,["311"] = 284,["312"] = 290,["313"] = 291,["314"] = 290,["315"] = 295,["316"] = 296,["317"] = 295,["318"] = 303,["319"] = 304,["320"] = 303,["321"] = 307,["322"] = 308,["323"] = 307,["324"] = 312,["325"] = 313,["326"] = 314,["328"] = 316,["329"] = 317,["331"] = 319,["332"] = 320,["334"] = 322,["335"] = 323,["337"] = 325,["338"] = 326,["340"] = 328,["341"] = 329,["343"] = 331,["344"] = 312,["345"] = 335,["346"] = 336,["347"] = 337,["348"] = 338,["350"] = 340,["351"] = 341,["352"] = 342,["353"] = 343,["354"] = 344,["355"] = 345,["357"] = 347,["358"] = 347,["359"] = 347,["360"] = 347,["361"] = 348,["363"] = 350,["364"] = 335,["365"] = 354,["366"] = 355,["367"] = 356,["368"] = 357,["371"] = 359,["372"] = 359,["373"] = 360,["374"] = 361,["376"] = 359,["379"] = 364,["380"] = 354,["381"] = 368,["382"] = 369,["383"] = 370,["386"] = 373,["389"] = 376,["390"] = 377,["392"] = 368,["393"] = 382,["394"] = 383,["395"] = 382,["396"] = 388,["398"] = 389,["399"] = 389,["401"] = 390,["402"] = 391,["403"] = 392,["405"] = 394,["406"] = 395,["407"] = 396,["408"] = 396,["409"] = 396,["410"] = 396,["411"] = 396,["412"] = 396,["413"] = 396,["414"] = 396,["415"] = 397,["417"] = 399,["420"] = 389,["423"] = 388,["424"] = 405,["425"] = 406,["426"] = 407,["428"] = 408,["429"] = 408,["430"] = 409,["431"] = 410,["432"] = 411,["433"] = 412,["434"] = 413,["436"] = 408,["439"] = 416,["440"] = 417,["442"] = 420,["443"] = 421,["444"] = 422,["446"] = 424,["447"] = 425,["448"] = 426,["449"] = 427,["450"] = 427,["451"] = 427,["452"] = 427,["453"] = 427,["454"] = 427,["455"] = 427,["456"] = 427,["457"] = 428,["458"] = 429,["459"] = 430,["461"] = 433,["463"] = 434,["464"] = 434,["465"] = 435,["466"] = 436,["468"] = 434,["471"] = 439,["472"] = 440,["473"] = 405,["474"] = 444,["475"] = 445,["476"] = 446,["478"] = 447,["479"] = 447,["480"] = 448,["481"] = 449,["483"] = 447,["486"] = 452,["487"] = 444,["488"] = 456,["489"] = 457,["490"] = 458,["492"] = 459,["493"] = 459,["494"] = 460,["495"] = 461,["496"] = 462,["497"] = 463,["498"] = 464,["500"] = 459,["503"] = 467,["504"] = 468,["506"] = 470,["507"] = 471,["509"] = 474,["510"] = 475,["511"] = 476,["513"] = 478,["515"] = 480,["516"] = 481,["517"] = 482,["518"] = 483,["519"] = 484,["520"] = 485,["521"] = 486,["522"] = 486,["523"] = 486,["524"] = 486,["525"] = 486,["526"] = 486,["527"] = 486,["528"] = 486,["529"] = 487,["530"] = 488,["531"] = 489,["533"] = 491,["535"] = 495,["536"] = 496,["537"] = 497,["538"] = 456,["539"] = 501,["541"] = 502,["542"] = 502,["544"] = 503,["545"] = 504,["546"] = 505,["548"] = 507,["549"] = 508,["550"] = 509,["551"] = 510,["552"] = 511,["553"] = 512,["554"] = 512,["555"] = 512,["556"] = 512,["557"] = 512,["558"] = 512,["559"] = 512,["560"] = 512,["561"] = 513,["565"] = 502,["568"] = 501,["569"] = 519,["571"] = 520,["572"] = 520,["574"] = 521,["575"] = 522,["576"] = 523,["578"] = 525,["579"] = 526,["581"] = 528,["582"] = 529,["583"] = 530,["584"] = 531,["585"] = 532,["586"] = 533,["587"] = 534,["588"] = 535,["589"] = 536,["590"] = 537,["591"] = 540,["592"] = 541,["593"] = 542,["595"] = 544,["596"] = 545,["597"] = 545,["598"] = 545,["599"] = 545,["600"] = 545,["601"] = 545,["602"] = 545,["603"] = 545,["604"] = 546,["608"] = 520,["611"] = 519});
local ____exports = {}
local ____physics = require("game.physics")
local rectOverlap = ____physics.rectOverlap
local moveAndCollide = ____physics.moveAndCollide
local clamp = ____physics.clamp
local ____player = require("game.player")
local PlayerTuning = ____player.PlayerTuning
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
    self.swordSlotsList = {}
    self.lampStoneCount = 0
    self.gateReqs = {}
    self.windSigils = {}
    self.starNodes = {}
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
            self.stones:push({
                x = d.x,
                y = d.y + STONE_H / 2,
                vx = 0,
                vy = 0,
                w = STONE_W,
                h = STONE_H,
                onGround = false
            })
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
    local reqGates = __TS__ObjectKeys(self.gateReqs)
    do
        local i = 0
        while i < #reqGates do
            self:refreshGate(reqGates[i + 1])
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.stones do
            local s = self.stones[i + 1]
            local sr = self:stoneRect(s)
            local adjacent = playerRect.x < sr.x + sr.w + 4 and playerRect.x + playerRect.w > sr.x - 4 and playerRect.y < sr.y + sr.h and playerRect.y + playerRect.h > sr.y
            if adjacent and playerPushDir ~= 0 and s.onGround then
                local pushRight = playerRect.x + playerRect.w / 2 < s.x
                if pushRight and playerPushDir > 0 or not pushRight and playerPushDir < 0 then
                    local targetVx = playerPushDir * PlayerTuning.runSpeed
                    s.vx = s.vx + clamp(targetVx - s.vx, -PlayerTuning.accel * dt, PlayerTuning.accel * dt)
                else
                    s.vx = s.vx + clamp(0 - s.vx, -PlayerTuning.decel * dt, PlayerTuning.decel * dt)
                end
            else
                s.vx = s.vx + clamp(0 - s.vx, -PlayerTuning.decel * dt, PlayerTuning.decel * dt)
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
                    goto __continue27
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
                    self:refreshGate(r.gateId)
                end
            end
            ::__continue27::
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.swordSlotsList do
            do
                local slot = self.swordSlotsList[i + 1]
                local key = "swordslot_" .. slot.id
                if self.state.flags[key] == true then
                    goto __continue35
                end
                local sr = {x = slot.x - 26, y = slot.y, w = 52, h = 56}
                local hit = false
                if attackRect ~= nil and rectOverlap(attackRect, sr) then
                    hit = true
                end
                if not hit then
                    do
                        local k = 0
                        while k < #qiRects do
                            if rectOverlap(qiRects[k + 1], sr) then
                                hit = true
                                break
                            end
                            k = k + 1
                        end
                    end
                end
                if hit then
                    self.state.flags[key] = true
                    self.fx:spawnRing(
                        slot.x,
                        slot.y + 30,
                        self.fxGold,
                        12,
                        80,
                        0.7
                    )
                    self:refreshGate(slot.gateId)
                    if self.events.onSwordInserted ~= nil then
                        self.events:onSwordInserted()
                    end
                end
            end
            ::__continue35::
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.bellsList do
            do
                local b = self.bellsList[i + 1]
                if self.state.rungBells[b.id] then
                    goto __continue45
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
                            self:refreshGate(b.gateId)
                            break
                        end
                        k = k + 1
                    end
                end
            end
            ::__continue45::
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.platesList do
            do
                local p = self.platesList[i + 1]
                if self.state.platesActive[p.id] then
                    goto __continue53
                end
                do
                    local k = 0
                    while k < #self.stones do
                        local s = self.stones[k + 1]
                        local sr = self:stoneRect(s)
                        local nearX = Math:abs(s.x - p.x) < 40
                        local onTop = Math:abs(sr.y - p.y) < 8
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
                            self:refreshGate(p.gateId)
                            break
                        end
                        k = k + 1
                    end
                end
            end
            ::__continue53::
            i = i + 1
        end
    end
end
function MechanismSystem.prototype.bindLists(self, ropes, bells, plates)
    self.ropesList = ropes
    self.bellsList = bells
    self.platesList = plates
end
function MechanismSystem.prototype.bindSwordSlots(self, slots)
    self.swordSlotsList = slots
end
function MechanismSystem.prototype.bindGateRequirements(self, reqs)
    self.gateReqs = reqs
end
function MechanismSystem.prototype.bindWindSigils(self, list)
    self.windSigils = list
end
function MechanismSystem.prototype.bindStarNodes(self, list)
    self.starNodes = list
end
function MechanismSystem.prototype.kindFlag(self, kind, id)
    if kind == "bell" then
        return self.state.rungBells[id] == true
    end
    if kind == "rope" then
        return self.state.cutRopes[id] == true
    end
    if kind == "plate" then
        return self.state.platesActive[id] == true
    end
    if kind == "slot" then
        return self.state.flags["swordslot_" .. id] == true
    end
    if kind == "wind" then
        return self.state.flags["wind_" .. id] == true
    end
    if kind == "star" then
        return self.state.flags["star_" .. id] == true
    end
    return false
end
function MechanismSystem.prototype.requirementMet(self, req)
    local sep = req:indexOf(":")
    if sep < 0 then
        return false
    end
    local kind = req:substring(0, sep)
    local ids = req:substring(sep + 1)
    local plus = ids:indexOf("+")
    local head = plus >= 0 and ids:substring(0, plus) or ids
    if self:kindFlag(kind, head) then
        return true
    end
    if plus >= 0 and self:kindFlag(
        kind,
        ids:substring(plus + 1)
    ) then
        return true
    end
    return false
end
function MechanismSystem.prototype.gateSatisfied(self, gateId)
    local reqs = self.gateReqs[gateId]
    if reqs == nil then
        return true
    end
    do
        local i = 0
        while i < #reqs do
            if not self:requirementMet(reqs[i + 1]) then
                return false
            end
            i = i + 1
        end
    end
    return true
end
function MechanismSystem.prototype.refreshGate(self, gateId)
    if self.gateReqs[gateId] == nil then
        self:openGate(gateId)
        return
    end
    if self.state.openedGates[gateId] == true then
        return
    end
    if self:gateSatisfied(gateId) then
        self:openGate(gateId)
    end
end
function MechanismSystem.prototype.addLampStone(self)
    self.lampStoneCount = self.lampStoneCount + 1
end
function MechanismSystem.prototype.tryDashWindSigils(self, px, py)
    do
        local i = 0
        while i < #self.windSigils do
            do
                local s = self.windSigils[i + 1]
                if Math:abs(s.x - px) >= 46 or Math:abs(s.y - py) >= 90 then
                    goto __continue86
                end
                if self.state.flags["wind_" .. s.id] ~= true then
                    self.state.flags["wind_" .. s.id] = true
                    self.fx:spawnRing(
                        s.x,
                        s.y + 40,
                        self.fxCyan,
                        12,
                        78,
                        0.6
                    )
                    self.events:onWindSigil(s.id)
                end
                self:refreshGate(s.gateId)
            end
            ::__continue86::
            i = i + 1
        end
    end
end
function MechanismSystem.prototype.tryLightStar(self, px, py)
    local nearest = nil
    local bestDist = 60
    do
        local i = 0
        while i < #self.starNodes do
            local s = self.starNodes[i + 1]
            local d = Math:abs(s.x - px) + Math:abs(s.y - py) * 0.5
            if d < bestDist then
                bestDist = d
                nearest = s
            end
            i = i + 1
        end
    end
    if nearest == nil then
        return false
    end
    if self.state.flags["star_" .. nearest.id] == true then
        self:refreshGate(nearest.gateId)
        return false
    end
    local expected = self:countLitStars() + 1
    if nearest.order == expected then
        self.state.flags["star_" .. nearest.id] = true
        self.fx:spawnRing(
            nearest.x,
            nearest.y + 60,
            self.fxGold,
            10,
            66,
            0.6
        )
        self.events:onStarLit(nearest.order)
        self:refreshGate(nearest.gateId)
        return true
    end
    local ids = __TS__ObjectKeys(self.state.flags)
    do
        local i = 0
        while i < #ids do
            if ids[i + 1]:indexOf("star_") == 0 then
                self.state.flags[ids[i + 1]] = false
            end
            i = i + 1
        end
    end
    self.events:onStarFail()
    return true
end
function MechanismSystem.prototype.countLitStars(self)
    local n = 0
    local ids = __TS__ObjectKeys(self.state.flags)
    do
        local i = 0
        while i < #ids do
            if ids[i + 1]:indexOf("star_") == 0 and self.state.flags[ids[i + 1]] == true then
                n = n + 1
            end
            i = i + 1
        end
    end
    return n
end
function MechanismSystem.prototype.tryLightLantern(self, lanterns, px, py)
    local nearest = nil
    local bestDist = 60
    do
        local i = 0
        while i < #lanterns do
            local l = lanterns[i + 1]
            local d = Math:abs(l.x - px) + Math:abs(l.y - py) * 0.5
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
    if self.lampStoneCount <= 0 then
        if self.events.onLanternNoStone ~= nil then
            self.events:onLanternNoStone()
        end
        return false
    end
    local expected = self.state.lanternSequence + 1
    if nearest.order == expected then
        self.state.lanternsLit[nearest.id] = true
        self.lampStoneCount = self.lampStoneCount - 1
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
        end
        return true
    end
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
                    goto __continue115
                end
                local dx = Math:abs(c.x - px)
                local dy = Math:abs(c.y - py)
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
            ::__continue115::
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
                    goto __continue120
                end
                if c.loops ~= nil and c.loops:indexOf(self.state.loopIndex) < 0 then
                    goto __continue120
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
                        self.state.shenyanTrust = self.state.shenyanTrust + 2
                    elseif c.kind == "dew" then
                        self.state.heroineLife = Math:min(self.state.maxLife, self.state.heroineLife + 1)
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
            ::__continue120::
            i = i + 1
        end
    end
end
return ____exports
