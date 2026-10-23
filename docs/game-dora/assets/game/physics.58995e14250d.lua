local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 25,["6"] = 26,["7"] = 25,["8"] = 29,["9"] = 30,["10"] = 29,["11"] = 33,["12"] = 34,["13"] = 33,["14"] = 37,["15"] = 38,["16"] = 37,["17"] = 42,["18"] = 43,["20"] = 44,["21"] = 44,["23"] = 45,["24"] = 46,["25"] = 47,["27"] = 49,["30"] = 44,["33"] = 51,["34"] = 42,["35"] = 55,["36"] = 56,["37"] = 56,["38"] = 56,["39"] = 56,["40"] = 56,["41"] = 56,["42"] = 56,["43"] = 57,["44"] = 58,["46"] = 59,["47"] = 59,["49"] = 60,["50"] = 61,["51"] = 62,["53"] = 64,["54"] = 65,["55"] = 66,["57"] = 68,["58"] = 69,["59"] = 70,["60"] = 71,["61"] = 72,["62"] = 73,["63"] = 74,["64"] = 75,["66"] = 77,["67"] = 78,["70"] = 59,["73"] = 80,["74"] = 55,["75"] = 84,["76"] = 85,["77"] = 85,["78"] = 85,["79"] = 85,["80"] = 85,["81"] = 85,["82"] = 85,["83"] = 86,["84"] = 87,["85"] = 88,["86"] = 89,["87"] = 90,["89"] = 91,["90"] = 91,["92"] = 92,["93"] = 93,["94"] = 94,["95"] = 95,["97"] = 97,["98"] = 99,["99"] = 100,["100"] = 101,["102"] = 103,["103"] = 104,["106"] = 107,["107"] = 108,["108"] = 109,["111"] = 113,["112"] = 114,["114"] = 116,["115"] = 117,["116"] = 118,["117"] = 119,["121"] = 91,["124"] = 122,["125"] = 123,["126"] = 124,["127"] = 125,["128"] = 126,["130"] = 128,["131"] = 129,["132"] = 130,["133"] = 131,["134"] = 132,["136"] = 134,["137"] = 84,["138"] = 138,["139"] = 145,["140"] = 146,["141"] = 146,["142"] = 146,["143"] = 146,["144"] = 146,["145"] = 146,["146"] = 146,["147"] = 147,["148"] = 147,["149"] = 147,["150"] = 147,["151"] = 147,["152"] = 147,["153"] = 147,["154"] = 138,["155"] = 156,["156"] = 158,["158"] = 159,["159"] = 159,["160"] = 160,["161"] = 161,["162"] = 162,["163"] = 163,["164"] = 165,["165"] = 166,["166"] = 167,["167"] = 168,["170"] = 171,["171"] = 172,["172"] = 173,["175"] = 159,["178"] = 177,["179"] = 178,["180"] = 179,["181"] = 156,["182"] = 182,["183"] = 183,["185"] = 184,["186"] = 184,["187"] = 185,["188"] = 186,["190"] = 184,["193"] = 189,["194"] = 182,["195"] = 192,["196"] = 197,["197"] = 198,["199"] = 200,["200"] = 201,["202"] = 207,["203"] = 207,["204"] = 208,["205"] = 209,["207"] = 207,["210"] = 212,["211"] = 192,["212"] = 215,["213"] = 216,["214"] = 217,["216"] = 219,["217"] = 220,["219"] = 222,["220"] = 215,["221"] = 225,["222"] = 226,["223"] = 225});
local ____exports = {}
function ____exports.rectOverlap(self, a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end
function ____exports.bodyRect(self, body)
    return {x = body.x - body.w / 2, y = body.y - body.h / 2, w = body.w, h = body.h}
end
local function overlapX(self, a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
end
local function overlapY(self, a, b)
    return a.y < b.y + b.h and a.y + a.h > b.y
end
function ____exports.activePlatforms(self, all, openedGates)
    local list = {}
    do
        local i = 0
        while i < #all do
            do
                local p = all[i + 1]
                if p.kind == "gate" and p.gateId ~= nil and openedGates[p.gateId] then
                    goto __continue8
                end
                list[#list + 1] = p
            end
            ::__continue8::
            i = i + 1
        end
    end
    return list
end
local function moveX(self, body, platforms, dx)
    local result = {
        hitWall = false,
        wallDir = 0,
        landed = false,
        hitCeiling = false,
        groundId = ""
    }
    body.x = body.x + dx
    local r = ____exports.bodyRect(nil, body)
    do
        local i = 0
        while i < #platforms do
            do
                local p = platforms[i + 1]
                if p.kind == "one-way" then
                    goto __continue12
                end
                local pr = {x = p.x, y = p.y, w = p.w, h = p.h}
                if not overlapX(nil, r, pr) or not overlapY(nil, r, pr) then
                    goto __continue12
                end
                if dx > 0 then
                    body.x = pr.x - body.w / 2 - 0.01
                    result.hitWall = true
                    result.wallDir = 1
                elseif dx < 0 then
                    body.x = pr.x + pr.w + body.w / 2 + 0.01
                    result.hitWall = true
                    result.wallDir = -1
                end
                body.vx = 0
                r.x = body.x - body.w / 2
            end
            ::__continue12::
            i = i + 1
        end
    end
    return result
end
local function moveY(self, body, platforms, dy, dropThrough)
    local result = {
        hitWall = false,
        wallDir = 0,
        landed = false,
        hitCeiling = false,
        groundId = ""
    }
    local prevBottom = body.y - body.h / 2
    body.y = body.y + dy
    local r = ____exports.bodyRect(nil, body)
    local bestTop = -1000000000
    local bestId = ""
    do
        local i = 0
        while i < #platforms do
            do
                local p = platforms[i + 1]
                local pr = {x = p.x, y = p.y, w = p.w, h = p.h}
                if not overlapX(nil, r, pr) or not overlapY(nil, r, pr) then
                    goto __continue19
                end
                if dy <= 0 then
                    if p.kind == "one-way" then
                        if dropThrough then
                            goto __continue19
                        end
                        if prevBottom < pr.y + pr.h - 4 then
                            goto __continue19
                        end
                    end
                    if pr.y + pr.h > bestTop then
                        bestTop = pr.y + pr.h
                        bestId = p.id
                    end
                else
                    if p.kind == "one-way" then
                        goto __continue19
                    end
                    body.y = pr.y - body.h / 2 - 0.01
                    body.vy = 0
                    result.hitCeiling = true
                    r.y = body.y - body.h / 2
                end
            end
            ::__continue19::
            i = i + 1
        end
    end
    if dy <= 0 and bestTop > -100000000 then
        local wasAir = not body.onGround
        body.y = bestTop + body.h / 2
        if body.vy < -1 then
            result.landed = wasAir
        end
        body.vy = 0
        body.onGround = true
        body.groundId = bestId
        result.groundId = bestId
        r.y = body.y - body.h / 2
    end
    return result
end
function ____exports.moveAndCollide(self, body, platforms, dx, dy, dropThrough)
    local rx = moveX(nil, body, platforms, dx)
    local ry = moveY(
        nil,
        body,
        platforms,
        dy,
        dropThrough
    )
    return {
        hitWall = rx.hitWall,
        wallDir = rx.wallDir,
        landed = ry.landed,
        hitCeiling = ry.hitCeiling,
        groundId = ry.groundId
    }
end
function ____exports.updateGroundState(self, body, platforms)
    local probe = {x = body.x - body.w / 2 + 2, y = body.y - body.h / 2 - 3, w = body.w - 4, h = 4}
    do
        local i = 0
        while i < #platforms do
            local p = platforms[i + 1]
            local pr = {x = p.x, y = p.y, w = p.w, h = p.h}
            if ____exports.rectOverlap(nil, probe, pr) then
                if p.kind == "one-way" then
                    if body.y - body.h / 2 >= pr.y + pr.h - 6 then
                        body.onGround = true
                        body.groundId = p.id
                        return true
                    end
                else
                    body.onGround = true
                    body.groundId = p.id
                    return true
                end
            end
            i = i + 1
        end
    end
    body.onGround = false
    body.groundId = ""
    return false
end
function ____exports.ladderAt(self, body, ladders)
    local r = ____exports.bodyRect(nil, body)
    do
        local i = 0
        while i < #ladders do
            if ____exports.rectOverlap(nil, r, ladders[i + 1]) then
                return ladders[i + 1]
            end
            i = i + 1
        end
    end
    return nil
end
function ____exports.climbWallAt(self, body, wallDir, walls)
    if wallDir == 0 then
        return nil
    end
    local r = ____exports.bodyRect(nil, body)
    local probe = {x = wallDir > 0 and r.x + r.w - 2 or r.x - 6, y = r.y + 6, w = 8, h = r.h - 12}
    do
        local i = 0
        while i < #walls do
            if ____exports.rectOverlap(nil, probe, walls[i + 1]) then
                return walls[i + 1]
            end
            i = i + 1
        end
    end
    return nil
end
function ____exports.clamp(self, v, lo, hi)
    if v < lo then
        return lo
    end
    if v > hi then
        return hi
    end
    return v
end
function ____exports.lerp(self, a, b, t)
    return a + (b - a) * t
end
return ____exports
