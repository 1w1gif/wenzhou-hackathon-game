-- [ts]: archive.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsNaN = ____lualib.__TS__NumberIsNaN -- 1
local ____exports = {} -- 1
local root, ensureDir, saveText, toInt, SAVE_DIR, ARCHIVE_FILE -- 1
local ____Dora = require("Dora") -- 4
local Content = ____Dora.Content -- 4
local Path = ____Dora.Path -- 4
function root() -- 35
	return Content.searchPaths[1] -- 36
end -- 36
--- 名字与取舍文字进档前清洗：去掉分隔符与换行，限长
function ____exports.sanitizeName(raw, maxLen) -- 40
	local s = "" -- 41
	do -- 41
		local i = 0 -- 42
		while i < #raw do -- 42
			local c = __TS__StringCharAt(raw, i) -- 43
			if c ~= "|" and c ~= "," and c ~= "\n" and c ~= "\r" then -- 43
				s = s .. c -- 45
			end -- 45
			i = i + 1 -- 42
		end -- 42
	end -- 42
	s = __TS__StringTrim(s) -- 48
	if #s > maxLen then -- 48
		s = __TS__StringSubstring(s, 0, maxLen) -- 50
	end -- 50
	return s -- 52
end -- 40
function ensureDir() -- 55
	local dir = Path( -- 56
		root(), -- 56
		SAVE_DIR -- 56
	) -- 56
	if not Content:exist(dir) then -- 56
		Content:mkdir(dir) -- 58
	end -- 58
end -- 58
function saveText(file, data) -- 70
	ensureDir() -- 71
	return Content:save( -- 72
		Path( -- 72
			root(), -- 72
			file -- 72
		), -- 72
		data -- 72
	) -- 72
end -- 72
function toInt(s) -- 128
	local n = __TS__ParseInt(s, 10) -- 129
	return __TS__NumberIsNaN(__TS__Number(n)) and 0 or n -- 130
end -- 130
function ____exports.saveArchive(list) -- 143
	local parts = {} -- 144
	do -- 144
		local i = 0 -- 145
		while i < #list do -- 145
			local e = list[i + 1] -- 146
			parts[#parts + 1] = (((((((("E," .. e.name) .. ",") .. e.endingTitle) .. ",") .. tostring(e.rewindCount)) .. ",") .. e.currentId) .. ",") .. tostring(#e.nodes) -- 147
			do -- 147
				local j = 0 -- 150
				while j < #e.nodes do -- 150
					local n = e.nodes[j + 1] -- 151
					parts[#parts + 1] = (((((((((("N," .. n.id) .. ",") .. n.parent) .. ",") .. ____exports.sanitizeName(n.via, 16)) .. ",") .. tostring(n.phase)) .. ",") .. tostring(n.depth)) .. ",") .. (n.abandoned and "1" or "0") -- 152
					j = j + 1 -- 150
				end -- 150
			end -- 150
			i = i + 1 -- 145
		end -- 145
	end -- 145
	return saveText( -- 157
		ARCHIVE_FILE, -- 157
		table.concat(parts, "\n") -- 157
	) -- 157
end -- 143
--- 仓库展示条目数上限（超出移除最旧的）
____exports.ARCHIVE_MAX = 30 -- 28
____exports.DEFAULT_NAME = "无名旅人" -- 29
SAVE_DIR = "saves" -- 31
ARCHIVE_FILE = "saves/archive.txt" -- 32
local PROFILE_FILE = "saves/profile.txt" -- 33
local function loadText(file) -- 62
	local p = Path( -- 63
		root(), -- 63
		file -- 63
	) -- 63
	if not Content:exist(p) then -- 63
		return nil -- 65
	end -- 65
	return Content:load(p) -- 67
end -- 62
function ____exports.loadPlayerName() -- 77
	local t = loadText(PROFILE_FILE) -- 78
	if t == nil then -- 78
		return "" -- 80
	end -- 80
	return ____exports.sanitizeName(t, 12) -- 82
end -- 77
function ____exports.savePlayerName(name) -- 85
	saveText( -- 86
		PROFILE_FILE, -- 86
		____exports.sanitizeName(name, 12) -- 86
	) -- 86
end -- 85
function ____exports.loadArchive() -- 91
	local text = loadText(ARCHIVE_FILE) -- 92
	local list = {} -- 93
	if text == nil then -- 93
		return list -- 95
	end -- 95
	local lines = __TS__StringSplit(text, "\n") -- 97
	local cur = nil -- 98
	do -- 98
		local i = 0 -- 99
		while i < #lines do -- 99
			do -- 99
				local line = __TS__StringTrim(lines[i + 1]) -- 100
				if line == "" then -- 100
					goto __continue19 -- 102
				end -- 102
				local f = __TS__StringSplit(line, ",") -- 104
				if f[1] == "E" and #f >= 6 then -- 104
					cur = { -- 106
						name = f[2], -- 107
						endingTitle = f[3], -- 108
						rewindCount = toInt(f[4]), -- 109
						currentId = f[5], -- 110
						nodes = {} -- 111
					} -- 111
					list[#list + 1] = cur -- 113
				elseif f[1] == "N" and #f >= 7 and cur ~= nil then -- 113
					local ____cur_nodes_0 = cur.nodes -- 113
					____cur_nodes_0[#____cur_nodes_0 + 1] = { -- 115
						id = f[2], -- 116
						parent = f[3], -- 117
						via = f[4], -- 118
						phase = toInt(f[5]), -- 119
						depth = toInt(f[6]), -- 120
						abandoned = f[7] == "1" -- 121
					} -- 121
				end -- 121
			end -- 121
			::__continue19:: -- 121
			i = i + 1 -- 99
		end -- 99
	end -- 99
	return list -- 125
end -- 91
--- 追加一条通关记录；超出上限移除最旧的
function ____exports.appendArchive(entry) -- 134
	local list = ____exports.loadArchive() -- 135
	list[#list + 1] = entry -- 136
	while #list > ____exports.ARCHIVE_MAX do -- 136
		table.remove(list, 1) -- 138
	end -- 138
	return ____exports.saveArchive(list) -- 140
end -- 134
return ____exports -- 134