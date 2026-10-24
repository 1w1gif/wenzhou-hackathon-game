-- [ts]: run_frames_probe.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local Texture2D = ____Dora.Texture2D -- 1
local resultDir = Path(Content.searchPaths[1], ".agent", "test-results") -- 4
if not Content:exist(resultDir) then -- 4
	Content:mkdir(resultDir) -- 5
end -- 5
local marker = Path(resultDir, "run_frames_probe.txt") -- 6
if Content:exist(marker) then -- 6
	Content:remove(marker) -- 7
end -- 7
local node = Node() -- 9
node:addTo(Director.entry) -- 10
node:schedule(function() -- 11
	local parts = {} -- 12
	local ok = true -- 13
	do -- 13
		local i = 0 -- 14
		while i < 5 do -- 14
			local tex = Texture2D(("assets/characters/hero_v2/run_" .. tostring(i)) .. ".png") -- 15
			if tex == nil then -- 15
				parts[#parts + 1] = ("run_" .. tostring(i)) .. "=FAIL" -- 17
				ok = false -- 18
			else -- 18
				parts[#parts + 1] = (((("run_" .. tostring(i)) .. "=") .. tostring(tex.width)) .. "x") .. tostring(tex.height) -- 20
			end -- 20
			i = i + 1 -- 14
		end -- 14
	end -- 14
	Content:save( -- 23
		marker, -- 23
		(ok and "passed|" or "failed|") .. table.concat(parts, "|") -- 23
	) -- 23
	return true -- 24
end) -- 11
return ____exports -- 11