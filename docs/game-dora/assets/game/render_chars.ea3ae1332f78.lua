-- [ts]: render_chars.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 4
local Color = ____Dora.Color -- 4
local Vec2 = ____Dora.Vec2 -- 4
local ____palette = require("core.palette") -- 5
local Palette = ____palette.Palette -- 5
local ink = ____palette.ink -- 5
____exports.EnemyGold = ink(155, 113, 56, 220) -- 23
____exports.EnemyRed = ink(140, 59, 59, 235) -- 24
____exports.SteelGray = ink(150, 150, 146, 235) -- 25
____exports.HeroScarf = ink(168, 197, 188, 235) -- 26
____exports.ATTACK_TIME = {0.3, 0.3, 0.34, 0.42} -- 29
function ____exports.clamp01(v) -- 31
	return math.max( -- 32
		0, -- 32
		math.min(1, v) -- 32
	) -- 32
end -- 31
function ____exports.col(c, mul) -- 35
	if mul == nil then -- 35
		return Color(c.r, c.g, c.b, c.a) -- 37
	end -- 37
	return Color( -- 39
		c.r, -- 39
		c.g, -- 39
		c.b, -- 39
		math.floor(c.a * ____exports.clamp01(mul)) -- 39
	) -- 39
end -- 35
function ____exports.dot(d, x, y, r, c, mul) -- 42
	d:drawDot( -- 50
		Vec2(x, y), -- 50
		r, -- 50
		____exports.col(c, mul) -- 50
	) -- 50
end -- 42
function ____exports.seg(d, x0, y0, x1, y1, r, c, mul) -- 53
	d:drawSegment( -- 63
		Vec2(x0, y0), -- 63
		Vec2(x1, y1), -- 63
		r, -- 63
		____exports.col(c, mul) -- 63
	) -- 63
end -- 53
function ____exports.circle(d, cx, cy, r, c, segments, mul) -- 67
	local n = segments == nil and 16 or segments -- 76
	do -- 76
		local i = 0 -- 77
		while i < n do -- 77
			local a0 = i / n * math.pi * 2 -- 78
			local a1 = (i + 1) / n * math.pi * 2 -- 79
			____exports.seg( -- 80
				d, -- 81
				cx + math.cos(a0) * r, -- 82
				cy + math.sin(a0) * r, -- 83
				cx + math.cos(a1) * r, -- 84
				cy + math.sin(a1) * r, -- 85
				2, -- 86
				c, -- 87
				mul -- 88
			) -- 88
			i = i + 1 -- 77
		end -- 77
	end -- 77
end -- 67
function ____exports.arc(d, cx, cy, r, a0, a1, segments, radius, c, mul) -- 94
	do -- 94
		local i = 0 -- 106
		while i < segments do -- 106
			local t0 = i / segments -- 107
			local t1 = (i + 1) / segments -- 108
			local ang0 = a0 + (a1 - a0) * t0 -- 109
			local ang1 = a0 + (a1 - a0) * t1 -- 110
			____exports.seg( -- 111
				d, -- 112
				cx + math.cos(ang0) * r, -- 113
				cy + math.sin(ang0) * r, -- 114
				cx + math.cos(ang1) * r, -- 115
				cy + math.sin(ang1) * r, -- 116
				radius, -- 117
				c, -- 118
				mul -- 119
			) -- 119
			i = i + 1 -- 106
		end -- 106
	end -- 106
end -- 94
function ____exports.torso(d, xL, xR, yTop, yBot, c, mul) -- 125
	d:drawPolygon( -- 134
		{ -- 135
			Vec2(xL, yTop), -- 135
			Vec2(xR, yTop), -- 135
			Vec2(xR + 2, yBot), -- 135
			Vec2(xL - 2, yBot) -- 135
		}, -- 135
		____exports.col(c, mul), -- 136
		0, -- 137
		Color(0, 0, 0, 0) -- 138
	) -- 138
end -- 125
local function drawPonytail(d, hx, hy, facing, t) -- 143
	local sway = math.sin(t * 2.6) * 0.28 -- 144
	local sway2 = math.sin(t * 3.4 + 1.2) * 0.22 -- 145
	local px = hx - facing * 5 -- 146
	local py = hy + 3 -- 147
	local ang = math.pi - facing * (0.5 + sway) -- 148
	local lens = {11, 9, 7} -- 149
	local rads = {3, 2.3, 1.6} -- 150
	do -- 150
		local i = 0 -- 151
		while i < 3 do -- 151
			ang = ang + (i == 0 and sway * 0.6 or sway2 * 0.8) - 0.12 -- 152
			local nx = px + math.cos(ang) * lens[i + 1] -- 153
			local ny = py + math.sin(ang) * lens[i + 1] -- 154
			____exports.seg( -- 155
				d, -- 155
				px, -- 155
				py, -- 155
				nx, -- 155
				ny, -- 155
				rads[i + 1], -- 155
				Palette.inkDark -- 155
			) -- 155
			px = nx -- 156
			py = ny -- 157
			i = i + 1 -- 151
		end -- 151
	end -- 151
	local ra = math.pi + facing * (0.2 + sway2) -- 160
	____exports.seg( -- 161
		d, -- 162
		hx - facing * 3, -- 163
		hy + 6, -- 164
		hx - facing * 3 + math.cos(ra) * 13, -- 165
		hy + 6 + math.sin(ra) * 13, -- 166
		1.4, -- 167
		____exports.HeroScarf, -- 167
		0.9 -- 169
	) -- 169
end -- 143
local function drawScarf(d, nx, ny, facing, t, pose) -- 174
	local stretch = 0 -- 182
	local lift = 0 -- 183
	if pose == "dash" then -- 183
		stretch = 1.5 -- 185
		lift = 0.1 -- 186
	elseif pose == "run" then -- 186
		stretch = 0.9 -- 188
		lift = -0.15 -- 189
	elseif pose == "fall" or pose == "jump" then -- 189
		stretch = 0.8 -- 191
		lift = 0.5 -- 192
	end -- 192
	local w1 = math.sin(t * 4.2) * 3.5 -- 194
	local w2 = math.sin(t * 5.1 + 0.8) * 4.5 -- 195
	local x1 = nx - facing * (12 + stretch * 8) -- 196
	local y1 = ny + lift * 10 + w1 -- 197
	local x2 = nx - facing * (20 + stretch * 16) -- 198
	local y2 = ny + lift * 14 + w2 -- 199
	____exports.seg( -- 200
		d, -- 200
		nx, -- 200
		ny, -- 200
		x1, -- 200
		y1, -- 200
		3.4, -- 200
		____exports.HeroScarf -- 200
	) -- 200
	____exports.seg( -- 201
		d, -- 201
		x1, -- 201
		y1, -- 201
		x2, -- 201
		y2, -- 201
		2.2, -- 201
		____exports.HeroScarf, -- 201
		0.75 -- 201
	) -- 201
end -- 174
local function drawLeg(d, hx, hy, facing, phase, lift, bend) -- 205
	local kx = hx + facing * (4 + phase * 9 + bend * 4) -- 214
	local ky = hy - 19 -- 215
	local fx = hx + facing * (4 + phase * 17 + bend * 8) -- 216
	local fy = hy - 36 + lift -- 217
	____exports.seg( -- 218
		d, -- 218
		hx, -- 218
		hy, -- 218
		kx, -- 218
		ky, -- 218
		5, -- 218
		Palette.inkDark -- 218
	) -- 218
	____exports.seg( -- 219
		d, -- 219
		kx, -- 219
		ky, -- 219
		fx, -- 219
		fy, -- 219
		4, -- 219
		Palette.inkDark -- 219
	) -- 219
end -- 205
function ____exports.drawHero(d, x, y, facing, pose, t, _phaseIndex) -- 222
	local bob = pose == "idle" and math.sin(t * 2) * 1.4 or 0 -- 232
	local lean = 0 -- 233
	if pose == "run" then -- 233
		lean = 0.18 -- 235
	elseif pose == "dash" then -- 235
		lean = 0.55 -- 237
	elseif pose == "attack1" or pose == "attack2" then -- 237
		lean = 0.3 -- 239
	elseif pose == "attack3" then -- 239
		lean = 0.42 -- 241
	elseif pose == "hurt" then -- 241
		lean = -0.35 -- 243
	elseif pose == "jump" or pose == "cling" then -- 243
		lean = 0.1 -- 245
	end -- 245
	local crouch = pose == "hurt" and -5 or (pose == "cling" and -3 or (pose == "ladder" and -2 or 0)) -- 247
	local hipY = y + 36 + bob + crouch -- 249
	local shX = x + facing * math.sin(lean) * 16 -- 250
	local shY = y + 60 + bob + crouch -- 251
	local hx = x + facing * math.sin(lean) * 24 -- 252
	local hy = y + 72 + bob + crouch -- 253
	if pose == "run" then -- 253
		local sw = math.sin(t * 12) -- 257
		drawLeg( -- 258
			d, -- 258
			x, -- 258
			hipY, -- 258
			facing, -- 258
			sw, -- 258
			math.max( -- 258
				0, -- 258
				math.cos(t * 12) -- 258
			) * 5, -- 258
			0 -- 258
		) -- 258
		drawLeg( -- 259
			d, -- 259
			x, -- 259
			hipY, -- 259
			facing, -- 259
			-sw, -- 259
			math.max( -- 259
				0, -- 259
				-math.cos(t * 12) -- 259
			) * 5, -- 259
			0 -- 259
		) -- 259
	elseif pose == "jump" then -- 259
		drawLeg( -- 261
			d, -- 261
			x, -- 261
			hipY, -- 261
			facing, -- 261
			0.7, -- 261
			14, -- 261
			-1 -- 261
		) -- 261
		drawLeg( -- 262
			d, -- 262
			x, -- 262
			hipY, -- 262
			facing, -- 262
			-0.3, -- 262
			8, -- 262
			-1 -- 262
		) -- 262
	elseif pose == "fall" then -- 262
		drawLeg( -- 264
			d, -- 264
			x, -- 264
			hipY, -- 264
			facing, -- 264
			0.45, -- 264
			-2, -- 264
			1 -- 264
		) -- 264
		drawLeg( -- 265
			d, -- 265
			x, -- 265
			hipY, -- 265
			facing, -- 265
			-0.45, -- 265
			-4, -- 265
			1 -- 265
		) -- 265
	elseif pose == "cling" then -- 265
		drawLeg( -- 267
			d, -- 267
			x, -- 267
			hipY, -- 267
			facing, -- 267
			0.5, -- 267
			6, -- 267
			-1.4 -- 267
		) -- 267
		drawLeg( -- 268
			d, -- 268
			x, -- 268
			hipY, -- 268
			facing, -- 268
			0.15, -- 268
			2, -- 268
			-1.2 -- 268
		) -- 268
	elseif pose == "dash" then -- 268
		drawLeg( -- 270
			d, -- 270
			x, -- 270
			hipY, -- 270
			facing, -- 270
			1.5, -- 270
			4, -- 270
			0 -- 270
		) -- 270
		drawLeg( -- 271
			d, -- 271
			x, -- 271
			hipY, -- 271
			facing, -- 271
			-0.9, -- 271
			2, -- 271
			0 -- 271
		) -- 271
	elseif pose == "ladder" then -- 271
		local sw = math.sin(t * 6) -- 273
		drawLeg( -- 274
			d, -- 274
			x, -- 274
			hipY, -- 274
			1, -- 274
			sw * 0.4, -- 274
			6 + sw * 4, -- 274
			0 -- 274
		) -- 274
		drawLeg( -- 275
			d, -- 275
			x, -- 275
			hipY, -- 275
			1, -- 275
			-sw * 0.4, -- 275
			6 - sw * 4, -- 275
			0 -- 275
		) -- 275
	else -- 275
		drawLeg( -- 277
			d, -- 277
			x, -- 277
			hipY, -- 277
			facing, -- 277
			0.35, -- 277
			0, -- 277
			0 -- 277
		) -- 277
		drawLeg( -- 278
			d, -- 278
			x, -- 278
			hipY, -- 278
			facing, -- 278
			-0.3, -- 278
			0, -- 278
			0 -- 278
		) -- 278
	end -- 278
	____exports.torso( -- 282
		d, -- 282
		shX - 6.5, -- 282
		shX + 6.5, -- 282
		shY, -- 282
		hipY + 2, -- 282
		Palette.inkSoft -- 282
	) -- 282
	____exports.seg( -- 283
		d, -- 283
		shX, -- 283
		shY + 2, -- 283
		x, -- 283
		hipY, -- 283
		8, -- 283
		Palette.inkSoft -- 283
	) -- 283
	local swordOut = pose == "attack1" or pose == "attack2" or pose == "attack3" or pose == "heavy" -- 286
	if swordOut then -- 286
		local idx = pose == "attack1" and 0 or (pose == "attack2" and 1 or (pose == "heavy" and 3 or 2)) -- 288
		local dur = ____exports.ATTACK_TIME[idx + 1] -- 289
		local p = ____exports.clamp01(t / dur) -- 290
		local handX = shX + facing * (16 + p * 8) -- 291
		local handY = shY - 4 + (idx == 2 and 12 - p * 26 or -p * 2) -- 292
		local bladeLen = idx == 2 and 40 or 32 -- 293
		local ang = idx == 2 and 2.1 - p * 3.8 or -0.5 + p * 1.5 -- 294
		____exports.seg( -- 295
			d, -- 295
			handX, -- 295
			handY, -- 295
			handX + math.cos(ang) * bladeLen * facing, -- 295
			handY + math.sin(ang) * bladeLen, -- 295
			2.6, -- 295
			Palette.white, -- 295
			0.95 -- 295
		) -- 295
		local a0 = facing > 0 and -0.7 or math.pi + 0.7 -- 297
		local a1 = a0 + facing * (0.6 + p * 1.9) -- 298
		____exports.arc( -- 299
			d, -- 299
			shX, -- 299
			shY - 4, -- 299
			bladeLen + 8, -- 299
			a0, -- 299
			a1, -- 299
			10, -- 299
			2, -- 299
			Palette.white, -- 299
			0.5 * (1 - p * 0.35) -- 299
		) -- 299
		local bx = shX - facing * 8 -- 301
		____exports.seg( -- 302
			d, -- 302
			shX, -- 302
			shY - 4, -- 302
			bx, -- 302
			shY - 16, -- 302
			3.6, -- 302
			Palette.inkDark -- 302
		) -- 302
		____exports.seg( -- 303
			d, -- 303
			bx, -- 303
			shY - 16, -- 303
			bx - facing * 6, -- 303
			shY - 22, -- 303
			3, -- 303
			Palette.inkDark -- 303
		) -- 303
	elseif pose == "ladder" then -- 303
		local sw = math.sin(t * 6) -- 305
		____exports.seg( -- 306
			d, -- 306
			shX, -- 306
			shY, -- 306
			shX + 5, -- 306
			shY + 20 + sw * 5, -- 306
			3.6, -- 306
			Palette.inkDark -- 306
		) -- 306
		____exports.seg( -- 307
			d, -- 307
			shX, -- 307
			shY, -- 307
			shX - 5, -- 307
			shY + 20 - sw * 5, -- 307
			3.6, -- 307
			Palette.inkDark -- 307
		) -- 307
	elseif pose == "dash" then -- 307
		____exports.seg( -- 309
			d, -- 309
			shX, -- 309
			shY, -- 309
			shX + facing * 16, -- 309
			shY - 6, -- 309
			3.6, -- 309
			Palette.inkDark -- 309
		) -- 309
		____exports.seg( -- 310
			d, -- 310
			shX, -- 310
			shY, -- 310
			shX - facing * 14, -- 310
			shY + 6, -- 310
			3.6, -- 310
			Palette.inkDark -- 310
		) -- 310
	else -- 310
		local armSw = pose == "run" and math.sin(t * 12) * 0.5 or 0 -- 312
		____exports.seg( -- 313
			d, -- 313
			shX + facing * 4, -- 313
			shY - 2, -- 313
			shX + facing * (8 + armSw * 8), -- 313
			shY - 16, -- 313
			3.8, -- 313
			Palette.inkDark -- 313
		) -- 313
		____exports.seg( -- 314
			d, -- 314
			shX - facing * 4, -- 314
			shY - 2, -- 314
			shX - facing * (8 - armSw * 8), -- 314
			shY - 16, -- 314
			3.8, -- 314
			Palette.inkDark -- 314
		) -- 314
		____exports.seg( -- 316
			d, -- 316
			x - facing * 6, -- 316
			hipY + 2, -- 316
			x - facing * 14, -- 316
			hipY - 12, -- 316
			2.4, -- 316
			____exports.SteelGray, -- 316
			0.8 -- 316
		) -- 316
	end -- 316
	____exports.dot( -- 320
		d, -- 320
		hx, -- 320
		hy, -- 320
		7, -- 320
		Palette.inkDark -- 320
	) -- 320
	____exports.dot( -- 321
		d, -- 321
		hx + facing * 3.4, -- 321
		hy - 1, -- 321
		2.6, -- 321
		Palette.paper -- 321
	) -- 321
	____exports.dot( -- 322
		d, -- 322
		hx + facing * 4.2, -- 322
		hy, -- 322
		1, -- 322
		Palette.inkDark -- 322
	) -- 322
	drawPonytail( -- 324
		d, -- 324
		hx, -- 324
		hy, -- 324
		facing, -- 324
		t -- 324
	) -- 324
	drawScarf( -- 325
		d, -- 325
		shX, -- 325
		shY + 4, -- 325
		facing, -- 325
		t, -- 325
		pose -- 325
	) -- 325
end -- 222
function ____exports.drawEnemy(d, e, t) -- 330
	local x = e.body.x -- 331
	local feetY = e.body.y - e.body.h / 2 -- 332
	local kind = e.def.kind -- 333
	local dying = e.dead and e.deathTimer > 0 -- 334
	local aMul = dying and ____exports.clamp01(e.deathTimer / 0.55) or 1 -- 335
	local squash = dying and 0.35 + 0.65 * aMul or 1 -- 336
	local wide = 1 + (1 - squash) * 0.6 -- 337
	local bodyH = e.body.h * squash -- 338
	local face = e.facing -- 339
	if e.state == "swing" or e.state == "charge" then -- 339
		do -- 339
			local g = 1 -- 343
			while g <= 2 do -- 343
				local gx = x - face * g * 16 -- 344
				local ga = 0.3 / g -- 345
				____exports.torso( -- 346
					d, -- 346
					gx - e.body.w * 0.28, -- 346
					gx + e.body.w * 0.28, -- 346
					feetY + bodyH * 0.52, -- 346
					feetY + bodyH * 0.9, -- 346
					Palette.inkSoft, -- 346
					ga -- 346
				) -- 346
				____exports.dot( -- 347
					d, -- 347
					gx, -- 347
					feetY + bodyH * 0.94, -- 347
					kind == "boss" and 9 or 6.5, -- 347
					Palette.inkSoft, -- 347
					ga -- 347
				) -- 347
				g = g + 1 -- 343
			end -- 343
		end -- 343
	end -- 343
	local hipY = feetY + bodyH * 0.42 -- 351
	local shY = feetY + bodyH * 0.78 -- 352
	local headY = feetY + bodyH * 0.92 -- 353
	local headR = kind == "boss" and 9 or 6.5 -- 354
	local jit = 0 -- 355
	if e.state == "windup" or e.state == "telegraph" then -- 355
		jit = math.sin(t * 45) * 1.5 -- 357
	end -- 357
	local lean = 0 -- 359
	if e.state == "windup" then -- 359
		lean = -0.15 -- 361
	elseif e.state == "swing" or e.state == "charge" then -- 361
		lean = 0.4 -- 363
	elseif e.state == "hurt" then -- 363
		lean = -0.4 -- 365
	elseif e.state == "patrol" then -- 365
		lean = 0.06 * math.sin(t * 3) -- 367
	end -- 367
	local shX = x + face * math.sin(lean) * 14 + jit -- 369
	local legLift = dying and -bodyH * 0.1 or (e.state == "charge" and 3 or 0) -- 372
	if kind == "boss" then -- 372
		____exports.seg( -- 374
			d, -- 374
			x - 10, -- 374
			hipY, -- 374
			x - 15, -- 374
			feetY + legLift, -- 374
			7, -- 374
			Palette.inkDark -- 374
		) -- 374
		____exports.seg( -- 375
			d, -- 375
			x + 10, -- 375
			hipY, -- 375
			x + 16, -- 375
			feetY + legLift, -- 375
			7, -- 375
			Palette.inkDark -- 375
		) -- 375
	else -- 375
		local legSw = (e.state == "patrol" or e.state == "chase") and math.sin(t * 10) or 0 -- 377
		____exports.seg( -- 378
			d, -- 378
			x - 3, -- 378
			hipY, -- 378
			x - 6 - legSw * 6, -- 378
			feetY + legLift, -- 378
			4.5, -- 378
			Palette.inkDark -- 378
		) -- 378
		____exports.seg( -- 379
			d, -- 379
			x + 3, -- 379
			hipY, -- 379
			x + 6 + legSw * 6, -- 379
			feetY + legLift, -- 379
			4.5, -- 379
			Palette.inkDark -- 379
		) -- 379
	end -- 379
	local torsoW = kind == "boss" and e.body.w * 0.42 or e.body.w * 0.3 -- 383
	____exports.torso( -- 384
		d, -- 384
		shX - torsoW, -- 384
		shX + torsoW, -- 384
		shY, -- 384
		hipY + 2, -- 384
		Palette.inkSoft -- 384
	) -- 384
	____exports.seg( -- 385
		d, -- 385
		shX, -- 385
		shY - 4, -- 385
		x, -- 385
		hipY, -- 385
		torsoW * 1.5, -- 385
		Palette.inkSoft -- 385
	) -- 385
	if kind == "bandit" then -- 385
		____exports.seg( -- 389
			d, -- 389
			shX - torsoW, -- 389
			shY - 8, -- 389
			shX + torsoW, -- 389
			shY - 10, -- 389
			2.6, -- 389
			____exports.EnemyGold, -- 389
			0.9 -- 389
		) -- 389
		____exports.dot( -- 390
			d, -- 390
			shX + face * 2 + jit, -- 390
			headY, -- 390
			headR, -- 390
			Palette.inkDark -- 390
		) -- 390
		____exports.seg( -- 391
			d, -- 391
			shX + face * 2 + jit, -- 391
			headY + headR * 0.6, -- 391
			shX + face * 8 + jit, -- 391
			headY + headR + 4, -- 391
			3.4, -- 391
			Palette.inkDark -- 391
		) -- 391
		____exports.dot( -- 392
			d, -- 392
			shX + face * 4.4 + jit, -- 392
			headY + 1, -- 392
			1.8, -- 392
			Palette.paper -- 392
		) -- 392
		local armUp = e.state == "windup" and 18 or (e.state == "swing" and -6 or 4) -- 393
		local hx = shX + face * (torsoW + 4) -- 394
		local hy = shY - 6 + armUp -- 395
		____exports.seg( -- 396
			d, -- 396
			shX, -- 396
			shY - 6, -- 396
			hx, -- 396
			hy, -- 396
			4, -- 396
			Palette.inkDark -- 396
		) -- 396
		local a0 = face > 0 and -0.9 or math.pi + 0.9 -- 398
		local a1 = a0 + face * 1.7 -- 399
		____exports.arc( -- 400
			d, -- 400
			hx, -- 400
			hy, -- 400
			15, -- 400
			a0, -- 400
			a1, -- 400
			6, -- 400
			2.4, -- 400
			____exports.SteelGray, -- 400
			aMul -- 400
		) -- 400
		____exports.seg( -- 401
			d, -- 401
			hx, -- 401
			hy, -- 401
			hx + face * 14, -- 401
			hy + (e.state == "swing" and -4 or 9), -- 401
			1.6, -- 401
			____exports.SteelGray, -- 401
			0.8 * aMul -- 401
		) -- 401
	elseif kind == "thrower" then -- 401
		local hunchX = shX + face * 6 -- 404
		____exports.dot( -- 405
			d, -- 405
			hunchX + face * 3 + jit, -- 405
			headY + 2, -- 405
			headR, -- 405
			Palette.inkDark -- 405
		) -- 405
		____exports.dot( -- 406
			d, -- 406
			hunchX + face * 6 + jit, -- 406
			headY + 2, -- 406
			1.8, -- 406
			Palette.paper -- 406
		) -- 406
		____exports.seg( -- 407
			d, -- 407
			shX, -- 407
			shY - 4, -- 407
			hunchX + face * 12, -- 407
			shY - 12, -- 407
			3.4, -- 407
			Palette.inkDark -- 407
		) -- 407
		local potX = hunchX + face * 13 -- 408
		local potY = shY - 12 -- 409
		____exports.dot( -- 410
			d, -- 410
			potX, -- 410
			potY, -- 410
			6.5, -- 410
			Palette.inkWash -- 410
		) -- 410
		____exports.seg( -- 411
			d, -- 411
			potX - 5, -- 411
			potY + 5, -- 411
			potX + 5, -- 411
			potY + 5, -- 411
			2, -- 411
			Palette.inkDark -- 411
		) -- 411
		____exports.seg( -- 412
			d, -- 412
			shX, -- 412
			hipY + 4, -- 412
			shX + face * 2, -- 412
			hipY - 4, -- 412
			1.6, -- 412
			____exports.EnemyGold, -- 412
			0.8 -- 412
		) -- 412
	else -- 412
		____exports.dot( -- 415
			d, -- 415
			shX + face * 2 + jit, -- 415
			headY, -- 415
			headR, -- 415
			Palette.inkDark -- 415
		) -- 415
		____exports.seg( -- 416
			d, -- 416
			shX - 4 + jit, -- 416
			headY + headR * 0.7, -- 416
			shX - 9 + jit, -- 416
			headY + headR + 8, -- 416
			3, -- 416
			Palette.inkDark -- 416
		) -- 416
		____exports.seg( -- 417
			d, -- 417
			shX + 6 + jit, -- 417
			headY + headR * 0.7, -- 417
			shX + 11 + jit, -- 417
			headY + headR + 8, -- 417
			3, -- 417
			Palette.inkDark -- 417
		) -- 417
		____exports.dot( -- 418
			d, -- 418
			shX + face * 5 + jit, -- 418
			headY + 1, -- 418
			2.2, -- 418
			____exports.EnemyRed -- 418
		) -- 418
		local swingK = e.state == "swing" and 1 or (e.state == "windup" and 0.2 or 0.5) -- 419
		local ang = face > 0 and -0.4 + swingK * 1.8 or math.pi + 0.4 - swingK * 1.8 -- 420
		local bx = shX + face * 12 -- 421
		local by = shY - 8 -- 422
		local tipX = bx + math.cos(ang) * 52 -- 423
		local tipY = by + math.sin(ang) * 52 -- 424
		local nx = math.cos(ang + math.pi / 2) * 4 -- 425
		local ny = math.sin(ang + math.pi / 2) * 4 -- 426
		d:drawPolygon( -- 427
			{ -- 428
				Vec2(bx + nx, by + ny), -- 429
				Vec2(tipX + nx * 0.4, tipY + ny * 0.4), -- 430
				Vec2(tipX - nx * 0.4, tipY - ny * 0.4), -- 431
				Vec2(bx - nx, by - ny) -- 432
			}, -- 432
			____exports.col(____exports.SteelGray, 0.85 * aMul), -- 434
			0, -- 435
			Color(0, 0, 0, 0) -- 436
		) -- 436
		____exports.seg( -- 438
			d, -- 438
			bx, -- 438
			by, -- 438
			bx + math.cos(ang) * 46, -- 438
			by + math.sin(ang) * 46, -- 438
			3, -- 438
			Palette.inkDark, -- 438
			aMul -- 438
		) -- 438
		if e.phase2 then -- 438
			local pulse = 0.6 + 0.4 * math.sin(t * 5) -- 440
			____exports.seg( -- 441
				d, -- 441
				shX - torsoW + 3, -- 441
				shY - 10, -- 441
				shX + torsoW - 3, -- 441
				shY - 16, -- 441
				2.2, -- 441
				____exports.EnemyRed, -- 441
				pulse * aMul -- 441
			) -- 441
			____exports.seg( -- 442
				d, -- 442
				shX - torsoW + 5, -- 442
				hipY + 12, -- 442
				shX + torsoW - 5, -- 442
				hipY + 18, -- 442
				2, -- 442
				____exports.EnemyRed, -- 442
				pulse * aMul -- 442
			) -- 442
			____exports.dot( -- 443
				d, -- 443
				shX, -- 443
				hipY + 6, -- 443
				3, -- 443
				____exports.EnemyRed, -- 443
				pulse * aMul -- 443
			) -- 443
		end -- 443
		____exports.seg( -- 445
			d, -- 445
			shX - torsoW, -- 445
			shY + 2, -- 445
			shX + torsoW, -- 445
			shY + 2, -- 445
			2.4, -- 445
			____exports.EnemyGold, -- 445
			0.7 -- 445
		) -- 445
	end -- 445
end -- 330
function ____exports.drawShenYan(d, x, y, facing, t, hostile) -- 450
	local sway = math.sin(t * 1.6) * 2 -- 458
	local bob = math.sin(t * 2) * 1 -- 459
	local hipY = y + 34 + bob -- 460
	local shY = y + 58 + bob -- 461
	local shX = x + facing * (hostile and 3 or 0) -- 462
	local hx = x + facing * (hostile and 4 or 1) -- 463
	local hy = y + 70 + bob -- 464
	local accent = hostile and ____exports.EnemyRed or Palette.paleInk -- 465
	d:drawPolygon( -- 468
		{ -- 469
			Vec2(x - 8, shY), -- 470
			Vec2(x + 8, shY), -- 471
			Vec2(x + 13 + sway, y + 2), -- 472
			Vec2(x - 13 + sway, y + 2) -- 473
		}, -- 473
		____exports.col(Palette.inkSoft), -- 475
		0, -- 476
		Color(0, 0, 0, 0) -- 477
	) -- 477
	____exports.seg( -- 479
		d, -- 479
		x, -- 479
		shY, -- 479
		x, -- 479
		hipY, -- 479
		9, -- 479
		Palette.inkSoft -- 479
	) -- 479
	____exports.seg( -- 481
		d, -- 481
		x - 4 + sway, -- 481
		y + 4, -- 481
		x - 6, -- 481
		y, -- 481
		3, -- 481
		Palette.inkDark -- 481
	) -- 481
	____exports.seg( -- 482
		d, -- 482
		x + 5 + sway, -- 482
		y + 4, -- 482
		x + 7, -- 482
		y, -- 482
		3, -- 482
		Palette.inkDark -- 482
	) -- 482
	local sleeveA = hostile and -0.5 or 0.9 -- 485
	____exports.seg( -- 486
		d, -- 486
		shX + facing * 5, -- 486
		shY - 2, -- 486
		shX + facing * 14, -- 486
		shY - 2 - sleeveA * 10, -- 486
		4.4, -- 486
		Palette.inkDark -- 486
	) -- 486
	____exports.seg( -- 487
		d, -- 487
		shX - facing * 5, -- 487
		shY - 2, -- 487
		shX - facing * 12, -- 487
		shY + 4, -- 487
		4.2, -- 487
		Palette.inkDark -- 487
	) -- 487
	____exports.seg( -- 490
		d, -- 490
		x - 8, -- 490
		hipY, -- 490
		x + 8, -- 490
		hipY, -- 490
		2.6, -- 490
		accent, -- 490
		hostile and 0.95 or 0.8 -- 490
	) -- 490
	____exports.seg( -- 491
		d, -- 491
		x + facing * 6, -- 491
		hipY - 2, -- 491
		x + facing * 6, -- 491
		hipY - 9, -- 491
		1.8, -- 491
		accent, -- 491
		0.8 -- 491
	) -- 491
	____exports.dot( -- 494
		d, -- 494
		hx, -- 494
		hy, -- 494
		6.6, -- 494
		Palette.inkDark -- 494
	) -- 494
	____exports.dot( -- 495
		d, -- 495
		hx, -- 495
		hy + 7, -- 495
		3, -- 495
		Palette.inkDark -- 495
	) -- 495
	____exports.seg( -- 496
		d, -- 496
		hx - 2, -- 496
		hy + 9, -- 496
		hx + 4, -- 496
		hy + 11, -- 496
		1.4, -- 496
		accent, -- 496
		0.9 -- 496
	) -- 496
	____exports.dot( -- 497
		d, -- 497
		hx + facing * 3, -- 497
		hy - 1, -- 497
		2.4, -- 497
		Palette.paper -- 497
	) -- 497
	if hostile then -- 497
		local gx = shX + facing * 14 -- 501
		local gy = shY - 12 -- 502
		____exports.seg( -- 503
			d, -- 503
			gx, -- 503
			gy, -- 503
			gx + facing * 34, -- 503
			gy + 6, -- 503
			2.6, -- 503
			Palette.white, -- 503
			0.95 -- 503
		) -- 503
		____exports.seg( -- 504
			d, -- 504
			gx + facing * 30, -- 504
			gy + 5, -- 504
			gx + facing * 40, -- 504
			gy + 8, -- 504
			1.4, -- 504
			Palette.white, -- 504
			0.6 -- 504
		) -- 504
		____exports.seg( -- 505
			d, -- 505
			gx - facing * 4, -- 505
			gy + 2, -- 505
			gx - facing * 10, -- 505
			gy + 10, -- 505
			1.6, -- 505
			____exports.EnemyRed, -- 505
			0.9 -- 505
		) -- 505
	else -- 505
		____exports.seg( -- 508
			d, -- 508
			x - facing * 8, -- 508
			hipY + 2, -- 508
			x - facing * 20, -- 508
			hipY - 10, -- 508
			2.2, -- 508
			____exports.SteelGray, -- 508
			0.85 -- 508
		) -- 508
	end -- 508
end -- 450
function ____exports.drawObserver(d, x, y, t) -- 513
	local pale = ink(196, 192, 182, 225) -- 514
	local bob = math.sin(t * 1.2) * 2 -- 515
	local topY = y + 104 + bob -- 516
	local headY = y + 96 + bob -- 517
	d:drawPolygon( -- 519
		{ -- 520
			Vec2(x - 9, topY - 8), -- 520
			Vec2(x + 9, topY - 8), -- 520
			Vec2(x + 4, y + 26), -- 520
			Vec2(x - 4, y + 26) -- 520
		}, -- 520
		____exports.col(pale, 0.95), -- 521
		0, -- 522
		Color(0, 0, 0, 0) -- 523
	) -- 523
	____exports.seg( -- 526
		d, -- 526
		x - 4, -- 526
		y + 26, -- 526
		x - 3, -- 526
		y + 12, -- 526
		5, -- 526
		pale, -- 526
		0.35 -- 526
	) -- 526
	____exports.seg( -- 527
		d, -- 527
		x + 4, -- 527
		y + 26, -- 527
		x + 3, -- 527
		y + 12, -- 527
		5, -- 527
		pale, -- 527
		0.35 -- 527
	) -- 527
	____exports.seg( -- 528
		d, -- 528
		x - 3, -- 528
		y + 12, -- 528
		x - 2, -- 528
		y + 2, -- 528
		4, -- 528
		pale, -- 528
		0.14 -- 528
	) -- 528
	____exports.seg( -- 529
		d, -- 529
		x + 3, -- 529
		y + 12, -- 529
		x + 2, -- 529
		y + 2, -- 529
		4, -- 529
		pale, -- 529
		0.14 -- 529
	) -- 529
	____exports.seg( -- 531
		d, -- 531
		x - 8, -- 531
		topY - 14, -- 531
		x + 8, -- 531
		topY - 16, -- 531
		3.2, -- 531
		pale, -- 531
		0.8 -- 531
	) -- 531
	____exports.dot( -- 533
		d, -- 533
		x, -- 533
		headY, -- 533
		7, -- 533
		pale -- 533
	) -- 533
	d:drawPolygon( -- 534
		{ -- 535
			Vec2(x - 6, headY + 4), -- 535
			Vec2(x + 6, headY + 4), -- 535
			Vec2(x, headY + 15) -- 535
		}, -- 535
		____exports.col(pale, 0.9), -- 536
		0, -- 537
		Color(0, 0, 0, 0) -- 538
	) -- 538
	____exports.dot( -- 540
		d, -- 540
		x, -- 540
		headY - 1, -- 540
		3, -- 540
		Palette.paper, -- 540
		0.9 -- 540
	) -- 540
	____exports.dot( -- 541
		d, -- 541
		x - 1.2, -- 541
		headY - 1, -- 541
		1, -- 541
		Palette.inkFaint -- 541
	) -- 541
	____exports.dot( -- 542
		d, -- 542
		x + 1.2, -- 542
		headY - 1, -- 542
		1, -- 542
		Palette.inkFaint -- 542
	) -- 542
	local rot = t * 1.2 -- 544
	local r = 16 -- 545
	local nSeg = 10 -- 546
	do -- 546
		local i = 0 -- 547
		while i < nSeg do -- 547
			do -- 547
				if i % 2 == 0 then -- 547
					goto __continue60 -- 549
				end -- 549
				local a0 = rot + i / nSeg * math.pi * 2 -- 551
				local a1 = rot + (i + 1) / nSeg * math.pi * 2 -- 552
				____exports.seg( -- 553
					d, -- 554
					x + math.cos(a0) * r, -- 555
					headY + 22 + math.sin(a0) * r * 0.45, -- 556
					x + math.cos(a1) * r, -- 557
					headY + 22 + math.sin(a1) * r * 0.45, -- 558
					1.8, -- 559
					Palette.moonCyanSoft, -- 560
					0.7 -- 561
				) -- 561
			end -- 561
			::__continue60:: -- 561
			i = i + 1 -- 547
		end -- 547
	end -- 547
end -- 513
function ____exports.drawPot(d, x, y, t) -- 567
	____exports.dot( -- 568
		d, -- 568
		x, -- 568
		y, -- 568
		9, -- 568
		Palette.inkWash -- 568
	) -- 568
	____exports.circle( -- 569
		d, -- 569
		x, -- 569
		y, -- 569
		9, -- 569
		Palette.inkDark, -- 569
		12, -- 569
		0.85 -- 569
	) -- 569
	____exports.seg( -- 570
		d, -- 570
		x - 6, -- 570
		y + 7, -- 570
		x + 6, -- 570
		y + 7, -- 570
		2.2, -- 570
		Palette.inkDark -- 570
	) -- 570
	local a = t * 6 -- 571
	____exports.seg( -- 572
		d, -- 572
		x - math.cos(a) * 5, -- 572
		y - math.sin(a) * 5, -- 572
		x + math.cos(a) * 5, -- 572
		y + math.sin(a) * 5, -- 572
		1.2, -- 572
		Palette.inkDark, -- 572
		0.6 -- 572
	) -- 572
	____exports.dot( -- 573
		d, -- 573
		x - 3 + math.sin(a) * 1.5, -- 573
		y + 2, -- 573
		1.6, -- 573
		Palette.paper, -- 573
		0.8 -- 573
	) -- 573
end -- 567
function ____exports.drawWave(d, x, y, dir, t) -- 577
	local flick = 0.75 + 0.25 * math.sin(t * 20) -- 578
	do -- 578
		local g = 0 -- 579
		while g < 3 do -- 579
			local gx = x - dir * g * 11 -- 580
			local ga = flick * (1 - g * 0.32) -- 581
			local a0 = math.pi / 2 - dir * 1.25 -- 583
			local a1 = math.pi / 2 + dir * 1.25 -- 584
			____exports.arc( -- 585
				d, -- 585
				gx + dir * 8, -- 585
				y + 20, -- 585
				22, -- 585
				a0, -- 585
				a1, -- 585
				8, -- 585
				2.6, -- 585
				Palette.moonCyan, -- 585
				ga -- 585
			) -- 585
			____exports.arc( -- 586
				d, -- 586
				gx + dir * 13, -- 586
				y + 20, -- 586
				14, -- 586
				a0, -- 586
				a1, -- 586
				6, -- 586
				1.8, -- 586
				Palette.moonCyan, -- 586
				ga * 0.7 -- 586
			) -- 586
			g = g + 1 -- 579
		end -- 579
	end -- 579
	____exports.dot( -- 588
		d, -- 588
		x + dir * 8, -- 588
		y + 20, -- 588
		3, -- 588
		Palette.white, -- 588
		0.8 * flick -- 588
	) -- 588
end -- 577
return ____exports -- 577