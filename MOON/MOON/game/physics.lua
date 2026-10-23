local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 25,["6"] = 26,["7"] = 25,["8"] = 29,["9"] = 30,["10"] = 29,["11"] = 33,["12"] = 34,["13"] = 33,["14"] = 37,["15"] = 38,["16"] = 37,["17"] = 42,["18"] = 43,["20"] = 44,["21"] = 44,["23"] = 45,["24"] = 46,["25"] = 47,["27"] = 49,["30"] = 44,["33"] = 51,["34"] = 42,["35"] = 55,["36"] = 56,["37"] = 56,["38"] = 56,["39"] = 56,["40"] = 56,["41"] = 56,["42"] = 56,["43"] = 57,["44"] = 58,["46"] = 59,["47"] = 59,["49"] = 60,["50"] = 61,["51"] = 62,["53"] = 64,["54"] = 65,["55"] = 66,["57"] = 68,["58"] = 69,["59"] = 70,["60"] = 71,["61"] = 72,["62"] = 73,["63"] = 74,["64"] = 75,["66"] = 77,["67"] = 78,["70"] = 59,["73"] = 80,["74"] = 55,["75"] = 84,["76"] = 85,["77"] = 85,["78"] = 85,["79"] = 85,["80"] = 85,["81"] = 85,["82"] = 85,["83"] = 86,["84"] = 87,["85"] = 88,["86"] = 89,["87"] = 90,["89"] = 91,["90"] = 91,["92"] = 92,["93"] = 93,["94"] = 94,["95"] = 95,["97"] = 97,["98"] = 99,["99"] = 100,["100"] = 101,["102"] = 103,["103"] = 104,["106"] = 107,["107"] = 108,["108"] = 109,["111"] = 113,["112"] = 114,["114"] = 116,["115"] = 117,["116"] = 118,["117"] = 119,["121"] = 91,["124"] = 122,["125"] = 123,["126"] = 124,["127"] = 125,["128"] = 126,["130"] = 128,["131"] = 129,["132"] = 130,["133"] = 131,["134"] = 132,["136"] = 134,["137"] = 84,["138"] = 138,["139"] = 145,["140"] = 146,["141"] = 147,["142"] = 147,["143"] = 147,["144"] = 147,["145"] = 147,["146"] = 147,["147"] = 147,["148"] = 138,["149"] = 156,["150"] = 158,["152"] = 159,["153"] = 159,["154"] = 160,["155"] = 161,["156"] = 162,["157"] = 163,["158"] = 165,["159"] = 166,["160"] = 167,["161"] = 168,["164"] = 171,["165"] = 172,["166"] = 173,["169"] = 159,["172"] = 177,["173"] = 178,["174"] = 179,["175"] = 156,["176"] = 182,["177"] = 183,["179"] = 184,["180"] = 184,["181"] = 185,["182"] = 186,["184"] = 184,["187"] = 189,["188"] = 182,["189"] = 192,["190"] = 197,["191"] = 198,["193"] = 200,["194"] = 201,["196"] = 207,["197"] = 207,["198"] = 208,["199"] = 209,["201"] = 207,["204"] = 212,["205"] = 192,["206"] = 215,["207"] = 216,["208"] = 217,["210"] = 219,["211"] = 220,["213"] = 222,["214"] = 215,["215"] = 225,["216"] = 226,["217"] = 225});
local ____exports = {}
function ____exports.rectOverlap(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end
function ____exports.bodyRect(body)
    return {x = body.x - body.w / 2, y = body.y - body.h / 2, w = body.w, h = body.h}
end
local function overlapX(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
end
local function overlapY(a, b)
    return a.y < b.y + b.h and a.y + a.h > b.y
end
function ____exports.activePlatforms(all, openedGates)
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
local function moveX(body, platforms, dx)
    local result = {
        hitWall = false,
        wallDir = 0,
        landed = false,
        hitCeiling = false,
        groundId = ""
    }
    body.x = body.x + dx
    local r = ____exports.bodyRect(body)
    do
        local i = 0
        while i < #platforms do
            do
                local p = platforms[i + 1]
                if p.kind == "one-way" then
                    goto __continue12
                end
                local pr = {x = p.x, y = p.y, w = p.w, h = p.h}
                if not overlapX(r, pr) or not overlapY(r, pr) then
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
local function moveY(body, platforms, dy, dropThrough)
    local result = {
        hitWall = false,
        wallDir = 0,
        landed = false,
        hitCeiling = false,
        groundId = ""
    }
    local prevBottom = body.y - body.h / 2
    body.y = body.y + dy
    local r = ____exports.bodyRect(body)
    local bestTop = -1000000000
    local bestId = ""
    do
        local i = 0
        while i < #platforms do
            do
                local p = platforms[i + 1]
                local pr = {x = p.x, y = p.y, w = p.w, h = p.h}
                if not overlapX(r, pr) or not overlapY(r, pr) then
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
function ____exports.moveAndCollide(body, platforms, dx, dy, dropThrough)
    local rx = moveX(body, platforms, dx)
    local ry = moveY(body, platforms, dy, dropThrough)
    return {
        hitWall = rx.hitWall,
        wallDir = rx.wallDir,
        landed = ry.landed,
        hitCeiling = ry.hitCeiling,
        groundId = ry.groundId
    }
end
function ____exports.updateGroundState(body, platforms)
    local probe = {x = body.x - body.w / 2 + 2, y = body.y - body.h / 2 - 3, w = body.w - 4, h = 4}
    do
        local i = 0
        while i < #platforms do
            local p = platforms[i + 1]
            local pr = {x = p.x, y = p.y, w = p.w, h = p.h}
            if ____exports.rectOverlap(probe, pr) then
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
function ____exports.ladderAt(body, ladders)
    local r = ____exports.bodyRect(body)
    do
        local i = 0
        while i < #ladders do
            if ____exports.rectOverlap(r, ladders[i + 1]) then
                return ladders[i + 1]
            end
            i = i + 1
        end
    end
    return nil
end
function ____exports.climbWallAt(body, wallDir, walls)
    if wallDir == 0 then
        return nil
    end
    local r = ____exports.bodyRect(body)
    local probe = {x = wallDir > 0 and r.x + r.w - 2 or r.x - 6, y = r.y + 6, w = 8, h = r.h - 12}
    do
        local i = 0
        while i < #walls do
            if ____exports.rectOverlap(probe, walls[i + 1]) then
                return walls[i + 1]
            end
            i = i + 1
        end
    end
    return nil
end
function ____exports.clamp(v, lo, hi)
    if v < lo then
        return lo
    end
    if v > hi then
        return hi
    end
    return v
end
function ____exports.lerp(a, b, t)
    return a + (b - a) * t
end
return ____exports
