-- [ts]: physics.ts
local ____exports = {} -- 1
function ____exports.rectOverlap(a, b) -- 25
	return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y -- 26
end -- 25
function ____exports.bodyRect(body) -- 29
	return {x = body.x - body.w / 2, y = body.y - body.h / 2, w = body.w, h = body.h} -- 30
end -- 29
local function overlapX(a, b) -- 33
	return a.x < b.x + b.w and a.x + a.w > b.x -- 34
end -- 33
local function overlapY(a, b) -- 37
	return a.y < b.y + b.h and a.y + a.h > b.y -- 38
end -- 37
function ____exports.activePlatforms(all, openedGates) -- 42
	local list = {} -- 43
	do -- 43
		local i = 0 -- 44
		while i < #all do -- 44
			do -- 44
				local p = all[i + 1] -- 45
				if p.kind == "gate" and p.gateId ~= nil and openedGates[p.gateId] then -- 45
					goto __continue8 -- 47
				end -- 47
				list[#list + 1] = p -- 49
			end -- 49
			::__continue8:: -- 49
			i = i + 1 -- 44
		end -- 44
	end -- 44
	return list -- 51
end -- 42
local function moveX(body, platforms, dx) -- 55
	local result = { -- 56
		hitWall = false, -- 56
		wallDir = 0, -- 56
		landed = false, -- 56
		hitCeiling = false, -- 56
		groundId = "" -- 56
	} -- 56
	body.x = body.x + dx -- 57
	local r = ____exports.bodyRect(body) -- 58
	do -- 58
		local i = 0 -- 59
		while i < #platforms do -- 59
			do -- 59
				local p = platforms[i + 1] -- 60
				if p.kind == "one-way" then -- 60
					goto __continue12 -- 62
				end -- 62
				local pr = {x = p.x, y = p.y, w = p.w, h = p.h} -- 64
				if not overlapX(r, pr) or not overlapY(r, pr) then -- 64
					goto __continue12 -- 66
				end -- 66
				if dx > 0 then -- 66
					body.x = pr.x - body.w / 2 - 0.01 -- 69
					result.hitWall = true -- 70
					result.wallDir = 1 -- 71
				elseif dx < 0 then -- 71
					body.x = pr.x + pr.w + body.w / 2 + 0.01 -- 73
					result.hitWall = true -- 74
					result.wallDir = -1 -- 75
				end -- 75
				body.vx = 0 -- 77
				r.x = body.x - body.w / 2 -- 78
			end -- 78
			::__continue12:: -- 78
			i = i + 1 -- 59
		end -- 59
	end -- 59
	return result -- 80
end -- 55
local function moveY(body, platforms, dy, dropThrough) -- 84
	local result = { -- 85
		hitWall = false, -- 85
		wallDir = 0, -- 85
		landed = false, -- 85
		hitCeiling = false, -- 85
		groundId = "" -- 85
	} -- 85
	local prevBottom = body.y - body.h / 2 -- 86
	body.y = body.y + dy -- 87
	local r = ____exports.bodyRect(body) -- 88
	local bestTop = -1000000000 -- 89
	local bestId = "" -- 90
	do -- 90
		local i = 0 -- 91
		while i < #platforms do -- 91
			do -- 91
				local p = platforms[i + 1] -- 92
				local pr = {x = p.x, y = p.y, w = p.w, h = p.h} -- 93
				if not overlapX(r, pr) or not overlapY(r, pr) then -- 93
					goto __continue19 -- 95
				end -- 95
				if dy <= 0 then -- 95
					if p.kind == "one-way" then -- 95
						if dropThrough then -- 95
							goto __continue19 -- 101
						end -- 101
						if prevBottom < pr.y + pr.h - 4 then -- 101
							goto __continue19 -- 104
						end -- 104
					end -- 104
					if pr.y + pr.h > bestTop then -- 104
						bestTop = pr.y + pr.h -- 108
						bestId = p.id -- 109
					end -- 109
				else -- 109
					if p.kind == "one-way" then -- 109
						goto __continue19 -- 114
					end -- 114
					body.y = pr.y - body.h / 2 - 0.01 -- 116
					body.vy = 0 -- 117
					result.hitCeiling = true -- 118
					r.y = body.y - body.h / 2 -- 119
				end -- 119
			end -- 119
			::__continue19:: -- 119
			i = i + 1 -- 91
		end -- 91
	end -- 91
	if dy <= 0 and bestTop > -100000000 then -- 91
		local wasAir = not body.onGround -- 123
		body.y = bestTop + body.h / 2 -- 124
		if body.vy < -1 then -- 124
			result.landed = wasAir -- 126
		end -- 126
		body.vy = 0 -- 128
		body.onGround = true -- 129
		body.groundId = bestId -- 130
		result.groundId = bestId -- 131
		r.y = body.y - body.h / 2 -- 132
	end -- 132
	return result -- 134
end -- 84
function ____exports.moveAndCollide(body, platforms, dx, dy, dropThrough) -- 138
	local rx = moveX(body, platforms, dx) -- 145
	local ry = moveY(body, platforms, dy, dropThrough) -- 146
	return { -- 147
		hitWall = rx.hitWall, -- 148
		wallDir = rx.wallDir, -- 149
		landed = ry.landed, -- 150
		hitCeiling = ry.hitCeiling, -- 151
		groundId = ry.groundId -- 152
	} -- 152
end -- 138
function ____exports.updateGroundState(body, platforms) -- 156
	local probe = {x = body.x - body.w / 2 + 2, y = body.y - body.h / 2 - 3, w = body.w - 4, h = 4} -- 158
	do -- 158
		local i = 0 -- 159
		while i < #platforms do -- 159
			local p = platforms[i + 1] -- 160
			local pr = {x = p.x, y = p.y, w = p.w, h = p.h} -- 161
			if ____exports.rectOverlap(probe, pr) then -- 161
				if p.kind == "one-way" then -- 161
					if body.y - body.h / 2 >= pr.y + pr.h - 6 then -- 161
						body.onGround = true -- 166
						body.groundId = p.id -- 167
						return true -- 168
					end -- 168
				else -- 168
					body.onGround = true -- 171
					body.groundId = p.id -- 172
					return true -- 173
				end -- 173
			end -- 173
			i = i + 1 -- 159
		end -- 159
	end -- 159
	body.onGround = false -- 177
	body.groundId = "" -- 178
	return false -- 179
end -- 156
function ____exports.ladderAt(body, ladders) -- 182
	local r = ____exports.bodyRect(body) -- 183
	do -- 183
		local i = 0 -- 184
		while i < #ladders do -- 184
			if ____exports.rectOverlap(r, ladders[i + 1]) then -- 184
				return ladders[i + 1] -- 186
			end -- 186
			i = i + 1 -- 184
		end -- 184
	end -- 184
	return nil -- 189
end -- 182
function ____exports.climbWallAt(body, wallDir, walls) -- 192
	if wallDir == 0 then -- 192
		return nil -- 198
	end -- 198
	local r = ____exports.bodyRect(body) -- 200
	local probe = {x = wallDir > 0 and r.x + r.w - 2 or r.x - 6, y = r.y + 6, w = 8, h = r.h - 12} -- 201
	do -- 201
		local i = 0 -- 207
		while i < #walls do -- 207
			if ____exports.rectOverlap(probe, walls[i + 1]) then -- 207
				return walls[i + 1] -- 209
			end -- 209
			i = i + 1 -- 207
		end -- 207
	end -- 207
	return nil -- 212
end -- 192
function ____exports.clamp(v, lo, hi) -- 215
	if v < lo then -- 215
		return lo -- 217
	end -- 217
	if v > hi then -- 217
		return hi -- 220
	end -- 220
	return v -- 222
end -- 215
function ____exports.lerp(a, b, t) -- 225
	return a + (b - a) * t -- 226
end -- 225
return ____exports -- 225