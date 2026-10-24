local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 31,["6"] = 4,["7"] = 4,["8"] = 4,["9"] = 35,["10"] = 36,["13"] = 40,["14"] = 41,["16"] = 42,["17"] = 42,["18"] = 43,["19"] = 44,["20"] = 45,["22"] = 42,["25"] = 48,["26"] = 49,["27"] = 50,["29"] = 52,["30"] = 40,["31"] = 55,["32"] = 56,["33"] = 56,["34"] = 56,["35"] = 56,["36"] = 57,["37"] = 58,["40"] = 70,["41"] = 71,["42"] = 72,["43"] = 72,["44"] = 72,["45"] = 72,["46"] = 72,["47"] = 72,["48"] = 72,["50"] = 128,["51"] = 129,["52"] = 130,["54"] = 143,["55"] = 144,["57"] = 145,["58"] = 145,["59"] = 146,["60"] = 147,["62"] = 150,["63"] = 150,["64"] = 151,["65"] = 152,["66"] = 150,["69"] = 145,["72"] = 157,["73"] = 157,["74"] = 157,["75"] = 157,["76"] = 143,["78"] = 28,["79"] = 29,["80"] = 31,["81"] = 32,["82"] = 33,["83"] = 62,["84"] = 63,["85"] = 63,["86"] = 63,["87"] = 63,["88"] = 64,["89"] = 65,["91"] = 67,["92"] = 62,["93"] = 77,["94"] = 78,["95"] = 79,["96"] = 80,["98"] = 82,["99"] = 77,["100"] = 85,["101"] = 86,["102"] = 86,["103"] = 86,["104"] = 86,["105"] = 85,["106"] = 91,["107"] = 92,["108"] = 93,["109"] = 94,["110"] = 95,["112"] = 97,["113"] = 98,["115"] = 99,["116"] = 99,["118"] = 100,["119"] = 101,["120"] = 102,["122"] = 104,["123"] = 105,["124"] = 106,["125"] = 106,["126"] = 106,["127"] = 106,["128"] = 106,["129"] = 106,["130"] = 106,["131"] = 113,["132"] = 114,["133"] = 115,["134"] = 115,["135"] = 115,["136"] = 115,["137"] = 115,["138"] = 115,["139"] = 115,["140"] = 115,["144"] = 99,["147"] = 125,["148"] = 91,["150"] = 134,["151"] = 135,["152"] = 136,["153"] = 137,["154"] = 138,["156"] = 140,["157"] = 134});
local ____exports = {}
local root, ensureDir, saveText, toInt, SAVE_DIR, ARCHIVE_FILE
local ____Dora = require("Dora")
local Content = ____Dora.Content
local Path = ____Dora.Path
function root()
    return Content.searchPaths[1]
end
--- 名字与取舍文字进档前清洗：去掉分隔符与换行，限长
function ____exports.sanitizeName(raw, maxLen)
    local s = ""
    do
        local i = 0
        while i < #raw do
            local c = raw:charAt(i)
            if c ~= "|" and c ~= "," and c ~= "\n" and c ~= "\r" then
                s = s .. c
            end
            i = i + 1
        end
    end
    s = s:trim()
    if #s > maxLen then
        s = s:substring(0, maxLen)
    end
    return s
end
function ensureDir()
    local dir = Path(
        root(),
        SAVE_DIR
    )
    if not Content:exist(dir) then
        Content:mkdir(dir)
    end
end
function saveText(file, data)
    ensureDir()
    return Content:save(
        Path(
            root(),
            file
        ),
        data
    )
end
function toInt(s)
    local n = parseInt(s, 10)
    return isNaN(n) and 0 or n
end
function ____exports.saveArchive(list)
    local parts = {}
    do
        local i = 0
        while i < #list do
            local e = list[i + 1]
            parts:push((((((((("E," .. e.name) .. ",") .. e.endingTitle) .. ",") .. tostring(e.rewindCount)) .. ",") .. e.currentId) .. ",") .. tostring(#e.nodes))
            do
                local j = 0
                while j < #e.nodes do
                    local n = e.nodes[j + 1]
                    parts:push((((((((((("N," .. n.id) .. ",") .. n.parent) .. ",") .. ____exports.sanitizeName(n.via, 16)) .. ",") .. tostring(n.phase)) .. ",") .. tostring(n.depth)) .. ",") .. (n.abandoned and "1" or "0"))
                    j = j + 1
                end
            end
            i = i + 1
        end
    end
    return saveText(
        ARCHIVE_FILE,
        parts:join("\n")
    )
end
--- 仓库展示条目数上限（超出移除最旧的）
____exports.ARCHIVE_MAX = 30
____exports.DEFAULT_NAME = "无名旅人"
SAVE_DIR = "saves"
ARCHIVE_FILE = "saves/archive.txt"
local PROFILE_FILE = "saves/profile.txt"
local function loadText(file)
    local p = Path(
        root(),
        file
    )
    if not Content:exist(p) then
        return nil
    end
    return Content:load(p)
end
function ____exports.loadPlayerName()
    local t = loadText(PROFILE_FILE)
    if t == nil then
        return ""
    end
    return ____exports.sanitizeName(t, 12)
end
function ____exports.savePlayerName(name)
    saveText(
        PROFILE_FILE,
        ____exports.sanitizeName(name, 12)
    )
end
function ____exports.loadArchive()
    local text = loadText(ARCHIVE_FILE)
    local list = {}
    if text == nil then
        return list
    end
    local lines = text:split("\n")
    local cur = nil
    do
        local i = 0
        while i < #lines do
            do
                local line = lines[i + 1]:trim()
                if line == "" then
                    goto __continue19
                end
                local f = line:split(",")
                if f[1] == "E" and #f >= 6 then
                    cur = {
                        name = f[2],
                        endingTitle = f[3],
                        rewindCount = toInt(f[4]),
                        currentId = f[5],
                        nodes = {}
                    }
                    list:push(cur)
                elseif f[1] == "N" and #f >= 7 and cur ~= nil then
                    cur.nodes:push({
                        id = f[2],
                        parent = f[3],
                        via = f[4],
                        phase = toInt(f[5]),
                        depth = toInt(f[6]),
                        abandoned = f[7] == "1"
                    })
                end
            end
            ::__continue19::
            i = i + 1
        end
    end
    return list
end
--- 追加一条通关记录；超出上限移除最旧的
function ____exports.appendArchive(entry)
    local list = ____exports.loadArchive()
    list:push(entry)
    while #list > ____exports.ARCHIVE_MAX do
        list:shift()
    end
    return ____exports.saveArchive(list)
end
return ____exports
