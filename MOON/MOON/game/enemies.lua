local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 2,["9"] = 2,["10"] = 2,["11"] = 2,["12"] = 71,["13"] = 73,["14"] = 73,["15"] = 73,["16"] = 81,["17"] = 82,["18"] = 83,["19"] = 84,["20"] = 85,["21"] = 86,["22"] = 87,["23"] = 81,["24"] = 90,["25"] = 91,["26"] = 92,["27"] = 93,["29"] = 94,["30"] = 94,["32"] = 95,["33"] = 96,["34"] = 97,["36"] = 99,["37"] = 100,["38"] = 101,["39"] = 102,["40"] = 103,["41"] = 104,["42"] = 105,["43"] = 106,["44"] = 107,["45"] = 108,["46"] = 109,["48"] = 111,["49"] = 111,["50"] = 111,["51"] = 113,["52"] = 113,["53"] = 113,["54"] = 113,["55"] = 113,["56"] = 113,["57"] = 113,["58"] = 113,["59"] = 113,["60"] = 113,["61"] = 111,["62"] = 111,["63"] = 111,["64"] = 111,["65"] = 111,["66"] = 111,["67"] = 111,["68"] = 111,["69"] = 111,["70"] = 111,["71"] = 111,["72"] = 111,["73"] = 111,["74"] = 111,["75"] = 111,["78"] = 94,["81"] = 90,["82"] = 141,["83"] = 142,["85"] = 143,["86"] = 143,["87"] = 144,["88"] = 145,["90"] = 143,["93"] = 148,["94"] = 141,["95"] = 151,["97"] = 152,["98"] = 152,["99"] = 153,["100"] = 154,["101"] = 155,["103"] = 152,["106"] = 158,["107"] = 151,["108"] = 161,["109"] = 162,["110"] = 161,["111"] = 166,["112"] = 167,["114"] = 168,["115"] = 168,["117"] = 169,["118"] = 170,["119"] = 171,["121"] = 173,["122"] = 173,["123"] = 173,["124"] = 173,["125"] = 173,["126"] = 174,["128"] = 176,["129"] = 177,["130"] = 178,["131"] = 179,["132"] = 180,["133"] = 181,["134"] = 182,["135"] = 183,["136"] = 184,["137"] = 185,["138"] = 186,["139"] = 187,["140"] = 188,["141"] = 189,["142"] = 190,["144"] = 192,["145"] = 193,["149"] = 168,["152"] = 196,["153"] = 166,["154"] = 199,["155"] = 200,["156"] = 201,["157"] = 202,["158"] = 199,["159"] = 205,["160"] = 206,["162"] = 212,["163"] = 212,["165"] = 213,["166"] = 214,["167"] = 215,["169"] = 217,["170"] = 218,["174"] = 212,["177"] = 221,["178"] = 205,["179"] = 224,["180"] = 225,["181"] = 226,["182"] = 226,["183"] = 226,["184"] = 226,["185"] = 226,["186"] = 226,["187"] = 226,["188"] = 226,["189"] = 227,["190"] = 224,["191"] = 230,["192"] = 232,["194"] = 233,["195"] = 233,["197"] = 234,["198"] = 235,["199"] = 236,["200"] = 237,["202"] = 239,["203"] = 240,["204"] = 241,["206"] = 243,["207"] = 244,["209"] = 246,["210"] = 247,["211"] = 248,["213"] = 250,["214"] = 251,["217"] = 252,["218"] = 253,["219"] = 254,["220"] = 255,["222"] = 257,["223"] = 258,["228"] = 262,["231"] = 263,["232"] = 264,["233"] = 265,["234"] = 267,["235"] = 268,["237"] = 270,["239"] = 272,["240"] = 273,["241"] = 274,["242"] = 275,["245"] = 278,["246"] = 279,["247"] = 280,["249"] = 282,["250"] = 283,["251"] = 284,["252"] = 285,["253"] = 286,["255"] = 288,["256"] = 289,["257"] = 290,["260"] = 293,["261"] = 294,["263"] = 296,["267"] = 299,["270"] = 300,["271"] = 301,["272"] = 302,["273"] = 303,["274"] = 304,["275"] = 305,["276"] = 306,["277"] = 307,["278"] = 308,["279"] = 309,["280"] = 309,["281"] = 309,["282"] = 309,["283"] = 309,["284"] = 309,["285"] = 309,["286"] = 309,["287"] = 309,["288"] = 317,["293"] = 321,["296"] = 322,["297"] = 323,["298"] = 324,["299"] = 325,["300"] = 326,["301"] = 328,["302"] = 328,["303"] = 329,["305"] = 331,["307"] = 333,["308"] = 334,["313"] = 338,["316"] = 339,["317"] = 340,["318"] = 341,["319"] = 342,["320"] = 343,["325"] = 347,["328"] = 348,["329"] = 349,["330"] = 350,["331"] = 351,["332"] = 352,["333"] = 353,["334"] = 354,["335"] = 355,["340"] = 359,["343"] = 360,["344"] = 361,["345"] = 362,["346"] = 363,["347"] = 364,["348"] = 365,["350"] = 367,["351"] = 367,["352"] = 367,["353"] = 367,["354"] = 367,["355"] = 368,["356"] = 369,["357"] = 370,["360"] = 373,["361"] = 374,["362"] = 375,["363"] = 376,["364"] = 377,["369"] = 381,["372"] = 382,["373"] = 383,["374"] = 384,["375"] = 385,["376"] = 386,["377"] = 387,["378"] = 388,["379"] = 389,["380"] = 390,["381"] = 390,["382"] = 390,["383"] = 390,["384"] = 390,["385"] = 390,["386"] = 390,["387"] = 390,["388"] = 390,["389"] = 391,["390"] = 392,["391"] = 393,["396"] = 397,["399"] = 398,["400"] = 399,["401"] = 400,["402"] = 401,["413"] = 233,["417"] = 411,["418"] = 411,["420"] = 412,["421"] = 413,["422"] = 414,["424"] = 416,["425"] = 417,["426"] = 418,["427"] = 419,["428"] = 420,["429"] = 421,["431"] = 422,["432"] = 422,["434"] = 423,["435"] = 424,["436"] = 425,["438"] = 427,["439"] = 428,["444"] = 422,["447"] = 432,["448"] = 433,["449"] = 434,["450"] = 435,["451"] = 436,["453"] = 438,["454"] = 439,["455"] = 440,["459"] = 411,["462"] = 444,["464"] = 445,["465"] = 445,["466"] = 446,["467"] = 447,["468"] = 448,["470"] = 445,["473"] = 451,["475"] = 454,["476"] = 454,["477"] = 455,["478"] = 456,["479"] = 457,["480"] = 458,["481"] = 459,["482"] = 460,["483"] = 461,["485"] = 454,["488"] = 464,["490"] = 465,["491"] = 465,["492"] = 466,["493"] = 467,["494"] = 468,["496"] = 465,["499"] = 471,["501"] = 474,["502"] = 474,["503"] = 475,["504"] = 476,["505"] = 477,["507"] = 474,["510"] = 230});
local ____exports = {}
local ____physics = require("game.physics")
local moveAndCollide = ____physics.moveAndCollide
local rectOverlap = ____physics.rectOverlap
local clamp = ____physics.clamp
local GRAV = 2300
____exports.EnemySystem = __TS__Class()
local EnemySystem = ____exports.EnemySystem
EnemySystem.name = "EnemySystem"
function EnemySystem.prototype.____constructor(self, fx, events)
    self.enemies = {}
    self.pots = {}
    self.waves = {}
    self.hits = {}
    self.fx = fx
    self.events = events
end
function EnemySystem.prototype.spawnAll(self, defs, loopIndex)
    __TS__ArraySetLength(self.enemies, 0)
    __TS__ArraySetLength(self.pots, 0)
    __TS__ArraySetLength(self.waves, 0)
    do
        local i = 0
        while i < #defs do
            do
                local d = defs[i + 1]
                if d.loops ~= nil and __TS__ArrayIndexOf(d.loops, loopIndex) < 0 then
                    goto __continue5
                end
                local w = 36
                local h = 76
                local hp = 3
                if d.kind == "thrower" then
                    w = 34
                    h = 82
                    hp = 2
                elseif d.kind == "boss" then
                    w = 52
                    h = 112
                    hp = 16
                end
                local ____self_enemies_0 = self.enemies
                ____self_enemies_0[#____self_enemies_0 + 1] = {
                    def = d,
                    body = {
                        x = d.x,
                        y = d.y + h / 2,
                        vx = 0,
                        vy = 0,
                        w = w,
                        h = h,
                        onGround = false,
                        groundId = "",
                        onLadder = false
                    },
                    hp = hp,
                    maxHp = hp,
                    facing = -1,
                    state = "patrol",
                    timer = 0,
                    atkCd = 0,
                    throwCd = 1.2,
                    animTime = math.random() * 6,
                    invuln = 0,
                    phase2 = false,
                    dead = false,
                    deathTimer = 0,
                    hitThisSwing = false
                }
            end
            ::__continue5::
            i = i + 1
        end
    end
end
function EnemySystem.prototype.aliveCount(self)
    local n = 0
    do
        local i = 0
        while i < #self.enemies do
            if not self.enemies[i + 1].dead then
                n = n + 1
            end
            i = i + 1
        end
    end
    return n
end
function EnemySystem.prototype.boss(self)
    do
        local i = 0
        while i < #self.enemies do
            local e = self.enemies[i + 1]
            if e.def.kind == "boss" and not e.dead then
                return e
            end
            i = i + 1
        end
    end
    return nil
end
function EnemySystem.prototype.enemyRect(self, e)
    return {x = e.body.x - e.body.w / 2, y = e.body.y - e.body.h / 2, w = e.body.w, h = e.body.h}
end
function EnemySystem.prototype.takeHit(self, rect, damage, dir, kb)
    local hits = 0
    do
        local i = 0
        while i < #self.enemies do
            do
                local e = self.enemies[i + 1]
                if e.dead or e.invuln > 0 then
                    goto __continue20
                end
                if not rectOverlap(
                    nil,
                    self:enemyRect(e),
                    rect
                ) then
                    goto __continue20
                end
                hits = hits + 1
                e.hp = e.hp - damage
                e.invuln = 0.18
                e.body.vx = dir * kb * (e.def.kind == "boss" and 0.3 or 1)
                self.fx:spawnInkBurst(e.body.x, e.body.y, dir)
                self.fx:spawnSpark(e.body.x + dir * -14, e.body.y + 10, dir)
                if e.hp <= 0 then
                    e.dead = true
                    e.state = "dead"
                    e.deathTimer = 0.55
                    self.fx:spawnMist(e.body.x, e.body.y - 20, e.def.kind == "boss" and 22 or 12, e.def.kind == "boss" and 1.6 or 1)
                    self.events:onDeath(e.def)
                elseif e.state ~= "charge" then
                    e.state = "hurt"
                    e.timer = 0.24
                end
                if e.def.kind == "boss" then
                    e.phase2 = e.hp <= e.maxHp / 2
                end
            end
            ::__continue20::
            i = i + 1
        end
    end
    return hits
end
function EnemySystem.prototype.consumeHits(self)
    local out = self.hits
    self.hits = {}
    return out
end
function EnemySystem.prototype.groundAhead(self, e, ctx)
    local probe = {x = e.body.x + e.facing * (e.body.w / 2 + 4) - 6, y = e.body.y - e.body.h / 2 - 12, w = 12, h = 14}
    do
        local i = 0
        while i < #ctx.platforms do
            do
                local p = ctx.platforms[i + 1]
                if p.kind == "one-way" then
                    goto __continue29
                end
                if rectOverlap(nil, probe, p) then
                    return true
                end
            end
            ::__continue29::
            i = i + 1
        end
    end
    return false
end
function EnemySystem.prototype.moveEnemy(self, e, ctx, dt)
    e.body.vy = clamp(nil, e.body.vy - GRAV * dt, -1150, 1150)
    local res = moveAndCollide(
        nil,
        e.body,
        ctx.platforms,
        e.body.vx * dt,
        e.body.vy * dt,
        false
    )
    return res.hitWall
end
function EnemySystem.prototype.update(self, dt, px, py, playerRect, playerInvuln, ctx)
    __TS__ArraySetLength(self.hits, 0)
    do
        local i = 0
        while i < #self.enemies do
            do
                local e = self.enemies[i + 1]
                e.animTime = e.animTime + dt
                if e.invuln > 0 then
                    e.invuln = e.invuln - dt
                end
                if e.dead then
                    e.deathTimer = e.deathTimer - dt
                    goto __continue35
                end
                if e.atkCd > 0 then
                    e.atkCd = e.atkCd - dt
                end
                local dx = px - e.body.x
                local dy = py - e.body.y
                local adx = math.abs(dx)
                repeat
                    local ____switch39 = e.state
                    local ____cond39 = ____switch39 == "patrol"
                    if ____cond39 then
                        do
                            e.body.vx = e.facing * (e.def.kind == "thrower" and 62 or 88)
                            if not self:groundAhead(e, ctx) or self:moveEnemy(e, ctx, dt) then
                                e.facing = -e.facing
                                e.body.vx = e.facing * 88
                            end
                            if adx < 330 and math.abs(dy) < 150 then
                                e.state = "chase"
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "chase"
                    if ____cond39 then
                        do
                            e.facing = dx > 0 and 1 or -1
                            local spd = e.def.kind == "boss" and 150 or 148
                            if e.def.kind == "thrower" then
                                if adx < 190 then
                                    e.body.vx = -e.facing * 110
                                else
                                    e.body.vx = 0
                                end
                                e.throwCd = e.throwCd - dt
                                if e.throwCd <= 0 and adx < 430 and math.abs(dy) < 190 then
                                    e.state = "throw"
                                    e.timer = 0.4
                                end
                            else
                                e.body.vx = e.facing * spd
                                if not self:groundAhead(e, ctx) and e.body.onGround then
                                    e.body.vx = 0
                                end
                                local range = e.def.kind == "boss" and 96 or 58
                                if adx < range and math.abs(dy) < 90 and e.atkCd <= 0 then
                                    e.state = "windup"
                                    e.timer = e.def.kind == "boss" and (e.phase2 and 0.42 or 0.55) or 0.45
                                    e.hitThisSwing = false
                                end
                                if e.def.kind == "boss" and e.atkCd <= 0 and adx > 280 and adx < 620 then
                                    e.state = "telegraph"
                                    e.timer = e.phase2 and 0.38 or 0.5
                                end
                            end
                            if adx > 560 or math.abs(dy) > 260 then
                                e.state = "patrol"
                            end
                            self:moveEnemy(e, ctx, dt)
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "windup"
                    if ____cond39 then
                        do
                            e.body.vx = 0
                            e.facing = dx > 0 and 1 or -1
                            e.timer = e.timer - dt
                            self:moveEnemy(e, ctx, dt)
                            if e.timer <= 0 then
                                e.state = "swing"
                                e.timer = 0.16
                                local reach = e.def.kind == "boss" and 92 or 56
                                local hh = e.def.kind == "boss" and 78 or 50
                                local ____self_hits_1 = self.hits
                                ____self_hits_1[#____self_hits_1 + 1] = {
                                    x = e.facing > 0 and e.body.x or e.body.x - reach,
                                    y = e.body.y - hh / 2,
                                    w = reach,
                                    h = hh,
                                    damage = e.def.kind == "boss" and 2 or 1,
                                    kind = "slash"
                                }
                                self.fx:spawnInkBurst(e.body.x + e.facing * reach * 0.6, e.body.y + 6, e.facing)
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "swing"
                    if ____cond39 then
                        do
                            e.body.vx = e.facing * 40
                            e.timer = e.timer - dt
                            self:moveEnemy(e, ctx, dt)
                            if e.timer <= 0 then
                                if e.def.kind == "boss" then
                                    local ____self_waves_2 = self.waves
                                    ____self_waves_2[#____self_waves_2 + 1] = {x = e.body.x + e.facing * 50, y = e.body.y - e.body.h / 2 + 20, dir = e.facing, life = 1.5}
                                    e.atkCd = e.phase2 and 0.9 or 1.4
                                else
                                    e.atkCd = 0.85
                                end
                                e.state = "recover"
                                e.timer = e.def.kind == "boss" and 0.3 or 0.42
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "recover"
                    if ____cond39 then
                        do
                            e.body.vx = 0
                            e.timer = e.timer - dt
                            self:moveEnemy(e, ctx, dt)
                            if e.timer <= 0 then
                                e.state = "chase"
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "telegraph"
                    if ____cond39 then
                        do
                            e.body.vx = 0
                            e.facing = dx > 0 and 1 or -1
                            e.timer = e.timer - dt
                            self:moveEnemy(e, ctx, dt)
                            if e.timer <= 0 then
                                e.state = "charge"
                                e.timer = 0.7
                                e.hitThisSwing = false
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "charge"
                    if ____cond39 then
                        do
                            e.body.vx = e.facing * (e.phase2 and 520 or 460)
                            e.timer = e.timer - dt
                            local blocked = self:moveEnemy(e, ctx, dt)
                            if blocked then
                                e.timer = 0
                                self.fx:spawnDust(e.body.x, e.body.y - e.body.h / 2, -e.facing)
                            end
                            if not e.hitThisSwing and rectOverlap(
                                nil,
                                self:enemyRect(e),
                                playerRect
                            ) then
                                e.hitThisSwing = true
                                if not playerInvuln then
                                    self.events:onPlayerHit(1, e.body.x)
                                end
                            end
                            if e.timer <= 0 then
                                e.body.vx = 0
                                e.atkCd = e.phase2 and 1.1 or 1.8
                                e.state = "recover"
                                e.timer = 0.4
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "throw"
                    if ____cond39 then
                        do
                            e.body.vx = 0
                            e.facing = dx > 0 and 1 or -1
                            e.timer = e.timer - dt
                            self:moveEnemy(e, ctx, dt)
                            if e.timer <= 0 then
                                local t = 0.85
                                local vx = (px - e.body.x) / t
                                local vy = (py - e.body.y + 0.5 * 1400 * t * t) / t
                                local ____self_pots_3 = self.pots
                                ____self_pots_3[#____self_pots_3 + 1] = {
                                    x = e.body.x + e.facing * 18,
                                    y = e.body.y + 20,
                                    vx = vx,
                                    vy = vy,
                                    alive = true,
                                    life = 3
                                }
                                e.throwCd = 2.1 + math.random() * 0.8
                                e.state = "recover"
                                e.timer = 0.5
                            end
                            break
                        end
                    end
                    ____cond39 = ____cond39 or ____switch39 == "hurt"
                    if ____cond39 then
                        do
                            e.timer = e.timer - dt
                            self:moveEnemy(e, ctx, dt)
                            if e.timer <= 0 then
                                e.state = "chase"
                            end
                            break
                        end
                    end
                    do
                        break
                    end
                until true
            end
            ::__continue35::
            i = i + 1
        end
    end
    do
        local i = 0
        while i < #self.pots do
            do
                local p = self.pots[i + 1]
                if not p.alive then
                    goto __continue73
                end
                p.life = p.life - dt
                p.vy = p.vy - 1400 * dt
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                local pr = {x = p.x - 8, y = p.y - 8, w = 16, h = 16}
                local hitPlat = false
                do
                    local k = 0
                    while k < #ctx.platforms do
                        do
                            local plat = ctx.platforms[k + 1]
                            if plat.kind == "one-way" then
                                goto __continue76
                            end
                            if rectOverlap(nil, pr, plat) then
                                hitPlat = true
                                break
                            end
                        end
                        ::__continue76::
                        k = k + 1
                    end
                end
                if hitPlat or p.life <= 0 then
                    p.alive = false
                    self.fx:spawnInkBurst(p.x, p.y, p.vx > 0 and 1 or -1)
                    self.events:onPoof(p.x, p.y)
                    goto __continue73
                end
                if rectOverlap(nil, pr, playerRect) and not playerInvuln then
                    p.alive = false
                    self.events:onPlayerHit(1, p.x)
                end
            end
            ::__continue73::
            i = i + 1
        end
    end
    local w = 0
    do
        local i = 0
        while i < #self.pots do
            if self.pots[i + 1].alive then
                self.pots[w + 1] = self.pots[i + 1]
                w = w + 1
            end
            i = i + 1
        end
    end
    __TS__ArraySetLength(self.pots, w)
    do
        local i = 0
        while i < #self.waves do
            local wv = self.waves[i + 1]
            wv.life = wv.life - dt
            wv.x = wv.x + wv.dir * 270 * dt
            local wr = {x = wv.x - 14, y = wv.y - 18, w = 28, h = 40}
            if rectOverlap(nil, wr, playerRect) and not playerInvuln then
                self.events:onPlayerHit(1, wv.x)
                wv.life = 0
            end
            i = i + 1
        end
    end
    local wv2 = 0
    do
        local i = 0
        while i < #self.waves do
            if self.waves[i + 1].life > 0 then
                self.waves[wv2 + 1] = self.waves[i + 1]
                wv2 = wv2 + 1
            end
            i = i + 1
        end
    end
    __TS__ArraySetLength(self.waves, wv2)
    do
        local i = 0
        while i < #self.hits do
            local h = self.hits[i + 1]
            if rectOverlap(nil, h, playerRect) and not playerInvuln then
                self.events:onPlayerHit(h.damage, h.x + h.w / 2)
            end
            i = i + 1
        end
    end
end
return ____exports
