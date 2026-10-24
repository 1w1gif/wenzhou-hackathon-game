-- [ts]: intro.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Keyboard = ____Dora.Keyboard -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Sprite = ____Dora.Sprite -- 3
local Texture2D = ____Dora.Texture2D -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local ____palette = require("core.palette") -- 4
local Palette = ____palette.Palette -- 4
local ____audio = require("game.audio") -- 5
local playBgm = ____audio.playBgm -- 5
local function clamp(v, lo, hi) -- 14
	return math.min( -- 14
		hi, -- 14
		math.max(lo, v) -- 14
	) -- 14
end -- 14
local function lerp(a, b, u) -- 15
	return a + (b - a) * u -- 15
end -- 15
local function smooth(a, b, t) -- 16
	local u = clamp((t - a) / (b - a), 0, 1) -- 17
	return u * u * (3 - 2 * u) -- 18
end -- 16
local function hash(n) -- 21
	local s = math.sin(n * 127.1 + 311.7) * 43758.5453 -- 22
	return s - math.floor(s) -- 23
end -- 21
local function col(c, alphaMul) -- 27
	return Color( -- 28
		c.r, -- 28
		c.g, -- 28
		c.b, -- 28
		math.floor(c.a * (alphaMul == nil and 1 or clamp(alphaMul, 0, 1)) + 0.5) -- 28
	) -- 28
end -- 27
local function circlePts(cx, cy, r, seg) -- 31
	local pts = {} -- 32
	do -- 32
		local i = 0 -- 33
		while i < seg do -- 33
			local a = i / seg * math.pi * 2 -- 34
			pts[#pts + 1] = Vec2( -- 35
				cx + math.cos(a) * r, -- 35
				cy + math.sin(a) * r -- 35
			) -- 35
			i = i + 1 -- 33
		end -- 33
	end -- 33
	return pts -- 37
end -- 31
local function ring(d, cx, cy, r, seg, w, c, a0, a1) -- 41
	local from = a0 == nil and 0 or a0 -- 43
	local to = a1 == nil and math.pi * 2 or a1 -- 44
	local px = cx + math.cos(from) * r -- 45
	local py = cy + math.sin(from) * r -- 46
	do -- 46
		local i = 1 -- 47
		while i <= seg do -- 47
			local ang = from + (to - from) * i / seg -- 48
			local nx = cx + math.cos(ang) * r -- 49
			local ny = cy + math.sin(ang) * r -- 50
			d:drawSegment( -- 51
				Vec2(px, py), -- 51
				Vec2(nx, ny), -- 51
				w, -- 51
				c -- 51
			) -- 51
			px = nx -- 52
			py = ny -- 53
			i = i + 1 -- 47
		end -- 47
	end -- 47
end -- 41
local function rectPts(x, y, w, h) -- 58
	return { -- 58
		Vec2(x, y), -- 59
		Vec2(x + w, y), -- 59
		Vec2(x + w, y + h), -- 59
		Vec2(x, y + h) -- 59
	} -- 59
end -- 58
local function sectorPts(cx, cy, r, a0, a1, seg) -- 63
	local pts = {Vec2(cx, cy)} -- 64
	do -- 64
		local i = 0 -- 65
		while i <= seg do -- 65
			local a = a0 + (a1 - a0) * i / seg -- 66
			pts[#pts + 1] = Vec2( -- 67
				cx + math.cos(a) * r, -- 67
				cy + math.sin(a) * r -- 67
			) -- 67
			i = i + 1 -- 65
		end -- 65
	end -- 65
	return pts -- 69
end -- 63
local DURATION = 24 -- 73
local SUBS = { -- 75
	{from = 0.2, to = 4.2, text = "那一夜，满月如盘。他死在我面前。"}, -- 76
	{from = 4.4, to = 8.4, text = "我这一剑，斩得断强盗，斩不断天意。"}, -- 77
	{from = 8.6, to = 13, text = "月亮把时间还给了我——以八相为约，满月为限。"}, -- 78
	{from = 13.2, to = 17.4, text = "代价是，我的性命。每回溯一次，折损一分。"}, -- 79
	{from = 17.6, to = 21, text = "而他忘记了我。连那枚糖人的约定，也一并忘了。"}, -- 80
	{from = 21.2, to = 23.6, text = "没关系。这一次，换我用剑，护你周全。"} -- 81
} -- 81
function ____exports.createIntro(parent, onFinish) -- 84
	local WHEEL_CY -- 84
	local W = View.size.width -- 86
	local H = View.size.height -- 87
	local MX = W / 2 - 190 -- 88
	local MY = H / 2 - 150 -- 89
	local MR = 110 -- 90
	local TX = W / 2 - 250 -- 91
	local TBY = -H / 2 + 140 -- 92
	local TTH = 300 -- 93
	local TTY = TBY + TTH -- 94
	local BANK = -H / 2 + 120 -- 95
	local SUBY = -H / 2 + 90 -- 96
	local WHEEL_R = 95 -- 97
	local root = Node() -- 100
	root:addTo(parent) -- 101
	local sceneRoot = Node() -- 102
	sceneRoot:addTo(root) -- 103
	local bgDraw = DrawNode() -- 104
	bgDraw:addTo(sceneRoot) -- 105
	local sceneDraw = DrawNode() -- 106
	sceneDraw:addTo(sceneRoot) -- 107
	local fxDraw = DrawNode() -- 108
	fxDraw:addTo(root) -- 109
	local uiDraw = DrawNode() -- 110
	uiDraw:addTo(root) -- 111
	playBgm("dusk", 1.5) -- 114
	local DUSK_DEFS = { -- 123
		{file = "far_clouds.png", speed = 2}, -- 124
		{file = "far_mountains.png", speed = 1}, -- 125
		{file = "mountains.png", speed = 4}, -- 126
		{file = "near_clouds.png", speed = 7}, -- 127
		{file = "trees.png", speed = 10} -- 128
	} -- 128
	local duskRoot = Node() -- 130
	duskRoot:addTo(sceneRoot) -- 131
	local duskLayers = {} -- 132
	local moonDraw = DrawNode() -- 133
	local function loadDuskLayer(file, speed) -- 135
		local tex = Texture2D("assets/bg/dusk/" .. file) -- 136
		if tex == nil then -- 136
			return false -- 137
		end -- 137
		local sy = H / tex.height -- 138
		local tileW = tex.width * sy -- 139
		local count = math.ceil(W / tileW) + 1 -- 140
		local sprites = {} -- 141
		do -- 141
			local j = 0 -- 142
			while j < count do -- 142
				local sp = Sprite(tex) -- 143
				sp.filter = "Point" -- 144
				sp.scaleX = sy -- 145
				sp.scaleY = sy -- 146
				sp.position = Vec2(-W / 2 + tileW / 2 + j * tileW, 0) -- 147
				sp:addTo(duskRoot) -- 148
				sprites[#sprites + 1] = sp -- 149
				j = j + 1 -- 142
			end -- 142
		end -- 142
		duskLayers[#duskLayers + 1] = {sprites = sprites, tileW = tileW, speed = speed} -- 151
		return true -- 152
	end -- 135
	local duskOk = false -- 154
	do -- 154
		local skyTex = Texture2D("assets/bg/dusk/sky.png") -- 156
		if skyTex ~= nil then -- 156
			local sky = Sprite(skyTex) -- 158
			sky.filter = "Point" -- 159
			sky.scaleX = W / skyTex.width -- 160
			sky.scaleY = H / skyTex.height -- 161
			sky.position = Vec2(0, 0) -- 162
			sky:addTo(duskRoot) -- 163
			duskOk = loadDuskLayer(DUSK_DEFS[1].file, DUSK_DEFS[1].speed) and loadDuskLayer(DUSK_DEFS[2].file, DUSK_DEFS[2].speed) -- 164
			moonDraw:addTo(duskRoot) -- 166
			duskOk = duskOk and loadDuskLayer(DUSK_DEFS[3].file, DUSK_DEFS[3].speed) and loadDuskLayer(DUSK_DEFS[4].file, DUSK_DEFS[4].speed) and loadDuskLayer(DUSK_DEFS[5].file, DUSK_DEFS[5].speed) -- 167
		end -- 167
	end -- 167
	if not duskOk then -- 167
		__TS__ArraySetLength(duskLayers, 0) -- 167
		duskRoot.visible = false -- 174
	end -- 174
	local cardSp -- 180
	local cardTex = Texture2D("assets/art/yanyue-key-visual.png") -- 181
	if cardTex ~= nil then -- 181
		local s = math.max(W / cardTex.width, H / cardTex.height) -- 183
		local sp = Sprite(cardTex) -- 184
		sp.scaleX = s -- 185
		sp.scaleY = s -- 186
		sp.position = Vec2(0, 0) -- 187
		sp.opacity = 0 -- 188
		sp.visible = false -- 189
		sp:addTo(sceneRoot) -- 190
		cardSp = sp -- 191
	end -- 191
	local hintLb = Label("sarasa-mono-sc-regular", 15) -- 195
	if hintLb ~= nil then -- 195
		hintLb.text = "按 J 跳过序章" -- 197
		hintLb.color = col(Palette.paleInk) -- 198
		hintLb.anchor = Vec2(1, 0.5) -- 199
		hintLb.position = Vec2(W / 2 - 24, H / 2 - 26) -- 200
		hintLb:addTo(root) -- 201
	end -- 201
	local subLb = Label("sarasa-mono-sc-regular", 26) -- 203
	if subLb ~= nil then -- 203
		subLb.color = col(Palette.inkDark) -- 205
		subLb.anchor = Vec2(0.5, 0.5) -- 206
		subLb.position = Vec2(0, SUBY) -- 207
		subLb:addTo(root) -- 208
	end -- 208
	local BUBX = -150 -- 210
	local BUBY = BANK + 128 -- 211
	local bubLb = Label("sarasa-mono-sc-regular", 20) -- 212
	if bubLb ~= nil then -- 212
		bubLb.text = "你是谁？" -- 214
		bubLb.color = col(Palette.inkDark) -- 215
		bubLb.anchor = Vec2(0.5, 0.5) -- 216
		bubLb.position = Vec2(BUBX, BUBY) -- 217
		bubLb:addTo(root) -- 218
		bubLb.visible = false -- 219
	end -- 219
	local function ridgeY(wx, base, amp, seed) -- 223
		return base + amp * (0.55 * math.sin(wx * 0.0042 + seed) + 0.3 * math.sin(wx * 0.0113 + seed * 2.1) + 0.15 * math.sin(wx * 0.027 + seed * 0.7)) -- 224
	end -- 223
	local function drawRidge(d, base, amp, seed, drift, c) -- 227
		local pts = {} -- 229
		do -- 229
			local x = -W / 2 - 60 -- 230
			while x <= W / 2 + 60 do -- 230
				pts[#pts + 1] = Vec2( -- 231
					x, -- 231
					ridgeY(x + drift, base, amp, seed) -- 231
				) -- 231
				x = x + 48 -- 230
			end -- 230
		end -- 230
		pts[#pts + 1] = Vec2(W / 2 + 60, -H / 2 - 80) -- 233
		pts[#pts + 1] = Vec2(-W / 2 - 60, -H / 2 - 80) -- 234
		d:drawPolygon(pts, c) -- 235
	end -- 227
	local function drawTown(d, c) -- 239
		local y0 = -H / 2 + 96 -- 240
		local pts = {Vec2(-W / 2 - 40, y0)} -- 241
		local x = -W / 2 - 20 -- 242
		local i = 0 -- 243
		while x < 40 do -- 243
			local w = 64 + hash(i * 5.7) * 26 -- 245
			local hgt = 22 + hash(i * 3.1) * 18 -- 246
			pts[#pts + 1] = Vec2(x + w * 0.5, y0 + hgt) -- 247
			pts[#pts + 1] = Vec2(x + w, y0 + 6) -- 248
			x = x + w -- 249
			i = i + 1 -- 250
		end -- 250
		pts[#pts + 1] = Vec2(x, -H / 2 - 80) -- 252
		pts[#pts + 1] = Vec2(-W / 2 - 40, -H / 2 - 80) -- 253
		d:drawPolygon(pts, c) -- 254
		d:drawPolygon( -- 255
			rectPts(-W / 2 + 34, y0 + 6, 30, 74), -- 255
			c -- 255
		) -- 255
		d:drawPolygon( -- 256
			{ -- 256
				Vec2(-W / 2 + 24, y0 + 80), -- 256
				Vec2(-W / 2 + 74, y0 + 80), -- 256
				Vec2(-W / 2 + 49, y0 + 104) -- 256
			}, -- 256
			c -- 256
		) -- 256
	end -- 239
	local function drawTower(d, a) -- 260
		if a <= 0.01 then -- 260
			return -- 261
		end -- 261
		local cBody = col(Palette.paleInkMid, a) -- 262
		local cTop = col(Palette.inkSoft, a) -- 263
		do -- 263
			local i = 0 -- 264
			while i < 5 do -- 264
				local w = 150 - i * 20 -- 265
				local y = TBY + i * 56 -- 266
				local hw = w - 14 -- 267
				d:drawPolygon( -- 268
					{ -- 268
						Vec2(TX - w / 2, y), -- 269
						Vec2(TX + w / 2, y), -- 269
						Vec2(TX + hw / 2, y + 56), -- 270
						Vec2(TX - hw / 2, y + 56) -- 270
					}, -- 270
					cBody -- 271
				) -- 271
				d:drawPolygon( -- 272
					rectPts(TX - hw / 2 + 16, y + 32, hw - 32, 10), -- 272
					col(Palette.paper, a * 0.85) -- 272
				) -- 272
				i = i + 1 -- 264
			end -- 264
		end -- 264
		local py = TBY + 5 * 56 -- 274
		d:drawPolygon( -- 275
			rectPts(TX - 95, py, 190, 10), -- 275
			cTop -- 275
		) -- 275
		d:drawPolygon( -- 276
			{ -- 276
				Vec2(TX - 100, py + 10), -- 276
				Vec2(TX + 100, py + 10), -- 276
				Vec2(TX + 30, py + 46), -- 276
				Vec2(TX - 30, py + 46) -- 276
			}, -- 276
			cTop -- 276
		) -- 276
		d:drawSegment( -- 277
			Vec2(TX, py + 46), -- 277
			Vec2(TX, py + 66), -- 277
			4, -- 277
			cTop -- 277
		) -- 277
		d:drawDot( -- 278
			Vec2(TX, py + 70), -- 278
			5, -- 278
			cTop -- 278
		) -- 278
		local stC = col(Palette.inkSoft, a * 0.7) -- 279
		d:drawSegment( -- 280
			Vec2(TX - 96, TBY + 4), -- 280
			Vec2(TX - 60, TBY + 56), -- 280
			3, -- 280
			stC -- 280
		) -- 280
		d:drawSegment( -- 281
			Vec2(TX - 60, TBY + 56), -- 281
			Vec2(TX - 96, TBY + 112), -- 281
			3, -- 281
			stC -- 281
		) -- 281
		d:drawSegment( -- 282
			Vec2(TX - 96, TBY + 112), -- 282
			Vec2(TX - 60, TBY + 168), -- 282
			3, -- 282
			stC -- 282
		) -- 282
		d:drawSegment( -- 283
			Vec2(TX - 60, TBY + 168), -- 283
			Vec2(TX - 96, TBY + 224), -- 283
			3, -- 283
			stC -- 283
		) -- 283
		d:drawSegment( -- 284
			Vec2(TX - 96, TBY + 224), -- 284
			Vec2(TX - 40, py + 4), -- 284
			3, -- 284
			stC -- 284
		) -- 284
	end -- 260
	local function drawFigure(d, x, y, s, a, female, pose) -- 289
		if a <= 0.01 then -- 289
			return -- 291
		end -- 291
		local c = col(Palette.inkDark, a) -- 292
		local lw = 3 * s -- 293
		local function seg(x1, y1, x2, y2) -- 294
			d:drawSegment( -- 295
				Vec2(x + x1 * s, y + y1 * s), -- 295
				Vec2(x + x2 * s, y + y2 * s), -- 295
				lw, -- 295
				c -- 295
			) -- 295
		end -- 294
		if pose == "lie" then -- 294
			d:drawDot( -- 298
				Vec2(x - 16 * s, y + 5 * s), -- 298
				4.5 * s, -- 298
				c -- 298
			) -- 298
			seg(-10, 5, 14, 7) -- 299
			seg(14, 7, 32, 3) -- 300
			seg(-10, 6, 6, 12) -- 301
			return -- 302
		end -- 302
		if pose == "kneel" then -- 302
			d:drawDot( -- 305
				Vec2(x, y + 24 * s), -- 305
				4.5 * s, -- 305
				c -- 305
			) -- 305
			seg(0, 20, 0, 8) -- 306
			seg(0, 8, -8, 2) -- 307
			seg(0, 8, 6, 1) -- 308
			seg(0, 17, 9, 9) -- 309
			seg(0, 15, -7, 9) -- 310
			if female then -- 310
				d:drawSegment( -- 311
					Vec2(x - 3 * s, y + 26 * s), -- 311
					Vec2(x - 9 * s, y + 18 * s), -- 311
					lw * 0.9, -- 311
					c -- 311
				) -- 311
			end -- 311
			return -- 312
		end -- 312
		d:drawDot( -- 314
			Vec2(x, y + 30 * s), -- 314
			4.5 * s, -- 314
			c -- 314
		) -- 314
		seg(0, 26, 0, 12) -- 315
		if pose == "walk" then -- 315
			seg(0, 12, -7 * s, 0) -- 317
			seg(0, 12, 7 * s, 0) -- 318
			seg(0, 23, -6 * s, 16) -- 319
			seg(0, 23, 6 * s, 17) -- 320
		elseif pose == "push" then -- 320
			seg(0, 12, -6 * s, 0) -- 322
			seg(0, 12, 6 * s, 0) -- 323
			seg(0, 24, 12 * s, 22) -- 324
			seg(0, 22, 13 * s, 18) -- 325
		else -- 325
			seg(0, 12, -5 * s, 0) -- 327
			seg(0, 12, 5 * s, 0) -- 328
			seg(0, 23, -6 * s, 15) -- 329
			seg(0, 23, 6 * s, 15) -- 330
		end -- 330
		if female then -- 330
			d:drawSegment( -- 333
				Vec2(x - 3 * s, y + 32 * s), -- 333
				Vec2(x - 10 * s, y + 24 * s), -- 333
				lw * 0.9, -- 333
				c -- 333
			) -- 333
			d:drawSegment( -- 334
				Vec2(x + 7 * s, y + 16 * s), -- 334
				Vec2(x + 16 * s, y + 4 * s), -- 334
				2 * s, -- 334
				col(Palette.paleInk, a) -- 334
			) -- 334
			d:drawDot( -- 335
				Vec2(x + 8 * s, y + 17 * s), -- 335
				1.8 * s, -- 335
				c -- 335
			) -- 335
		elseif pose == "back" then -- 335
			d:drawSegment( -- 337
				Vec2(x - 6 * s, y + 8 * s), -- 337
				Vec2(x + 8 * s, y + 30 * s), -- 337
				2 * s, -- 337
				col(Palette.paleInk, a) -- 337
			) -- 337
		else -- 337
			d:drawDot( -- 339
				Vec2(x, y + 34 * s), -- 339
				2 * s, -- 339
				c -- 339
			) -- 339
		end -- 339
	end -- 289
	local function drawBandit(d, x, y, s, a) -- 344
		if a <= 0.01 then -- 344
			return -- 345
		end -- 345
		local c = col(Palette.inkDark, a) -- 346
		d:drawPolygon( -- 347
			{ -- 347
				Vec2(x - 12 * s, y), -- 348
				Vec2(x + 12 * s, y), -- 348
				Vec2(x + 6 * s, y + 26 * s), -- 349
				Vec2(x - 4 * s, y + 26 * s) -- 349
			}, -- 349
			c -- 350
		) -- 350
		d:drawDot( -- 351
			Vec2(x + 1 * s, y + 30 * s), -- 351
			4.5 * s, -- 351
			c -- 351
		) -- 351
		d:drawSegment( -- 352
			Vec2(x - 2 * s, y + 26 * s), -- 352
			Vec2(x - 9 * s, y + 13 * s), -- 352
			3 * s, -- 352
			c -- 352
		) -- 352
	end -- 344
	local climbPath = { -- 356
		Vec2(TX - 108, TBY + 6), -- 357
		Vec2(TX - 72, TBY + 56), -- 357
		Vec2(TX - 108, TBY + 112), -- 357
		Vec2(TX - 72, TBY + 168), -- 358
		Vec2(TX - 108, TBY + 224), -- 358
		Vec2(TX - 26, TTY + 6) -- 358
	} -- 358
	local function pathPos(p) -- 360
		local u = clamp(p, 0, 1) * (#climbPath - 1) -- 361
		local i = math.min( -- 362
			math.floor(u), -- 362
			#climbPath - 2 -- 362
		) -- 362
		local f = u - i -- 363
		return { -- 364
			x = lerp(climbPath[i + 1].x, climbPath[i + 1 + 1].x, f), -- 364
			y = lerp(climbPath[i + 1].y, climbPath[i + 1 + 1].y, f) -- 364
		} -- 364
	end -- 360
	local function drawPolyline(d, pts, u, c, w) -- 368
		local total = #pts - 1 -- 369
		local f = clamp(u, 0, 1) * total -- 370
		local full = math.floor(f) -- 371
		do -- 371
			local i = 0 -- 372
			while i < full do -- 372
				d:drawSegment(pts[i + 1], pts[i + 1 + 1], w, c) -- 373
				i = i + 1 -- 372
			end -- 372
		end -- 372
		if full < total and full >= 0 then -- 372
			local fr = f - full -- 376
			d:drawSegment( -- 377
				pts[full + 1], -- 377
				Vec2( -- 378
					lerp(pts[full + 1].x, pts[full + 1 + 1].x, fr), -- 378
					lerp(pts[full + 1].y, pts[full + 1 + 1].y, fr) -- 378
				), -- 378
				w, -- 378
				c -- 378
			) -- 378
		end -- 378
	end -- 368
	local crackMain = {} -- 383
	do -- 383
		local cx0 = MX + 8 -- 385
		local cy0 = MY + MR - 6 -- 386
		crackMain[#crackMain + 1] = Vec2(cx0, cy0) -- 387
		do -- 387
			local i = 0 -- 388
			while i < 6 do -- 388
				cx0 = cx0 + ((i % 2 == 0 and 14 or -18) + hash(i * 3.7) * 6) -- 389
				cy0 = cy0 - (26 + hash(i * 9.1) * 10) -- 390
				crackMain[#crackMain + 1] = Vec2(cx0, cy0) -- 391
				i = i + 1 -- 388
			end -- 388
		end -- 388
	end -- 388
	local crackBranch1 = { -- 394
		Vec2(crackMain[3].x, crackMain[3].y), -- 395
		Vec2(crackMain[3].x + 22, crackMain[3].y - 18), -- 396
		Vec2(crackMain[3].x + 38, crackMain[3].y - 40) -- 397
	} -- 397
	local crackBranch2 = { -- 399
		Vec2(crackMain[5].x, crackMain[5].y), -- 400
		Vec2(crackMain[5].x - 24, crackMain[5].y - 16), -- 401
		Vec2(crackMain[5].x - 36, crackMain[5].y - 38) -- 402
	} -- 402
	local function drawBeam(d, tx0, ty0, a) -- 406
		if a <= 0.01 then -- 406
			return -- 407
		end -- 407
		local dx = tx0 - MX -- 408
		local dy = ty0 - MY -- 409
		local len = math.sqrt(dx * dx + dy * dy) -- 410
		local ux = dx / len -- 411
		local uy = dy / len -- 412
		local px = -uy -- 413
		local py = ux -- 414
		local function quad(w0, w1, c) -- 415
			d:drawPolygon( -- 416
				{ -- 416
					Vec2(MX + px * w0, MY + py * w0), -- 417
					Vec2(tx0 + px * w1, ty0 + py * w1), -- 418
					Vec2(tx0 - px * w1, ty0 - py * w1), -- 419
					Vec2(MX - px * w0, MY - py * w0) -- 420
				}, -- 420
				c -- 421
			) -- 421
		end -- 415
		quad( -- 423
			16, -- 423
			40, -- 423
			col(Palette.goldSoft, a * 0.85) -- 423
		) -- 423
		quad( -- 424
			7, -- 424
			20, -- 424
			col(Palette.moonWhite, a) -- 424
		) -- 424
	end -- 406
	local function drawWheel(d, cx, cy, rot, a) -- 428
		if a <= 0.01 then -- 428
			return -- 429
		end -- 429
		ring( -- 430
			d, -- 430
			cx, -- 430
			cy, -- 430
			WHEEL_R, -- 430
			24, -- 430
			4, -- 430
			col(Palette.gold, a) -- 430
		) -- 430
		ring( -- 431
			d, -- 431
			cx, -- 431
			cy, -- 431
			WHEEL_R - 16, -- 431
			24, -- 431
			2, -- 431
			col(Palette.goldSoft, a) -- 431
		) -- 431
		do -- 431
			local i = 0 -- 432
			while i < 8 do -- 432
				local ang = rot + i / 8 * math.pi * 2 -- 433
				local ca = math.cos(ang) -- 434
				local sa = math.sin(ang) -- 435
				d:drawSegment( -- 436
					Vec2(cx + ca * 22, cy + sa * 22), -- 437
					Vec2(cx + ca * (WHEEL_R - 4), cy + sa * (WHEEL_R - 4)), -- 438
					3, -- 438
					col(Palette.gold, a) -- 438
				) -- 438
				local sx = cx + ca * (WHEEL_R + 20) -- 439
				local sy = cy + sa * (WHEEL_R + 20) -- 440
				local ph = i % 4 -- 441
				if ph == 0 then -- 441
					d:drawDot( -- 443
						Vec2(sx, sy), -- 443
						3.5, -- 443
						col(Palette.inkDark, a) -- 443
					) -- 443
				elseif ph == 1 then -- 443
					d:drawPolygon( -- 445
						circlePts(sx, sy, 11, 16), -- 445
						col(Palette.moonWhite, a) -- 445
					) -- 445
					ring( -- 446
						d, -- 446
						sx, -- 446
						sy, -- 446
						11, -- 446
						12, -- 446
						2, -- 446
						col(Palette.inkDark, a) -- 446
					) -- 446
				elseif ph == 2 then -- 446
					d:drawPolygon( -- 448
						sectorPts( -- 448
							sx, -- 448
							sy, -- 448
							11, -- 448
							-math.pi / 2, -- 448
							math.pi / 2, -- 448
							12 -- 448
						), -- 448
						col(Palette.inkDark, a) -- 448
					) -- 448
				else -- 448
					d:drawPolygon( -- 450
						sectorPts( -- 450
							sx, -- 450
							sy, -- 450
							12, -- 450
							-math.pi / 3, -- 450
							math.pi + math.pi / 3, -- 450
							16 -- 450
						), -- 450
						col(Palette.inkDark, a) -- 450
					) -- 450
				end -- 450
				i = i + 1 -- 432
			end -- 432
		end -- 432
		d:drawDot( -- 453
			Vec2(cx, cy), -- 453
			11, -- 453
			col(Palette.gold, a) -- 453
		) -- 453
		d:drawDot( -- 454
			Vec2(cx, cy), -- 454
			26 + 6 * math.sin(rot * 3), -- 454
			col(Palette.moonCyanSoft, a * 0.8) -- 454
		) -- 454
		d:drawDot( -- 455
			Vec2(cx, cy), -- 455
			46, -- 455
			col(Palette.moonCyanFaint, a * 0.7) -- 455
		) -- 455
	end -- 428
	local function torchPos(i, tt) -- 459
		local sx = -W / 2 + 50 + i * 26 -- 460
		local sy = BANK - 10 + i * 3 -- 461
		local ex = TX - 150 + i * 12 -- 462
		local ey = TBY + 10 -- 463
		local p = smooth(11 + i * 0.28, 13.6 + i * 0.12, tt) -- 464
		local on = smooth(11 + i * 0.28, 11.35 + i * 0.28, tt) -- 465
		local out = 1 - smooth(15, 15.8, tt) -- 466
		return { -- 467
			x = lerp(sx, ex, p), -- 467
			y = lerp(sy, ey, p) - p * 24, -- 467
			a = on * out -- 467
		} -- 467
	end -- 459
	local function drawRiverside(d, a, tt) -- 471
		if a <= 0.01 then -- 471
			return -- 472
		end -- 472
		d:drawDot( -- 473
			Vec2(MX, MY), -- 473
			MR + 55, -- 473
			col(Palette.moonHalo, a) -- 473
		) -- 473
		d:drawPolygon( -- 474
			circlePts(MX, MY, MR, 32), -- 474
			col(Palette.moonWhite, a) -- 474
		) -- 474
		d:drawDot( -- 475
			Vec2(MX - 34, MY + 12), -- 475
			MR - 6, -- 475
			col(Palette.paper) -- 475
		) -- 475
		drawRidge( -- 476
			d, -- 476
			H / 2 - 210, -- 476
			55, -- 476
			1.3, -- 476
			24 + 6 * tt, -- 476
			col(Palette.paleInkFar, a) -- 476
		) -- 476
		drawRidge( -- 477
			d, -- 477
			H / 2 - 140, -- 477
			75, -- 477
			4.2, -- 477
			40 + 11 * tt, -- 477
			col(Palette.paleInkMid, a) -- 477
		) -- 477
		d:drawPolygon( -- 478
			rectPts(-W / 2, BANK - 46, W, 46), -- 478
			col(Palette.moonCyanFaint, a * 0.9) -- 478
		) -- 478
		d:drawSegment( -- 479
			Vec2(-W / 2, BANK), -- 479
			Vec2(W / 2, BANK), -- 479
			4, -- 479
			col(Palette.inkSoft, a) -- 479
		) -- 479
		do -- 479
			local i = 0 -- 480
			while i < 5 do -- 480
				local ry = BANK - 8 - i * 9 -- 481
				local rw = 60 - i * 9 -- 482
				d:drawSegment( -- 483
					Vec2(MX - rw / 2 + i * 6, ry), -- 484
					Vec2(MX + rw / 2 + i * 6, ry), -- 484
					3, -- 485
					col(Palette.moonWhite, a * (0.75 - i * 0.12)) -- 485
				) -- 485
				i = i + 1 -- 480
			end -- 480
		end -- 480
		local reeds = { -- 487
			-W / 2 + 90, -- 487
			-W / 2 + 120, -- 487
			-W / 2 + 150, -- 487
			W / 2 - 120, -- 487
			W / 2 - 90 -- 487
		} -- 487
		do -- 487
			local i = 0 -- 488
			while i < #reeds do -- 488
				local rx = reeds[i + 1] -- 489
				d:drawSegment( -- 490
					Vec2(rx, BANK + 2), -- 491
					Vec2(rx + (i % 2 == 0 and 8 or -8), BANK + 30 + i % 3 * 8), -- 492
					2.5, -- 493
					col(Palette.inkSoft, a) -- 493
				) -- 493
				i = i + 1 -- 488
			end -- 488
		end -- 488
		drawFigure( -- 495
			d, -- 495
			-170, -- 495
			BANK + 2, -- 495
			1.15, -- 495
			a, -- 495
			false, -- 495
			"back" -- 495
		) -- 495
		drawFigure( -- 496
			d, -- 496
			150, -- 496
			BANK + 2, -- 496
			1.1, -- 496
			a, -- 496
			true, -- 496
			"stand" -- 496
		) -- 496
	end -- 471
	local function drawBubble(d, a) -- 500
		if a <= 0.01 then -- 500
			return -- 501
		end -- 501
		local bw = 170 -- 502
		local bh = 58 -- 503
		local x0 = BUBX - bw / 2 -- 504
		local y0 = BUBY - bh / 2 -- 505
		local r = 10 -- 506
		local fill = col(Palette.paper, a) -- 507
		local outline = col(Palette.inkDark, a) -- 508
		d:drawPolygon( -- 509
			rectPts(x0, y0, bw, bh), -- 509
			fill -- 509
		) -- 509
		local border = { -- 510
			Vec2(x0, y0 + r), -- 511
			Vec2(x0 + r, y0), -- 511
			Vec2(x0 + bw - r, y0), -- 511
			Vec2(x0 + bw, y0 + r), -- 511
			Vec2(x0 + bw, y0 + bh - r), -- 512
			Vec2(x0 + bw - r, y0 + bh), -- 512
			Vec2(x0 + r, y0 + bh), -- 512
			Vec2(x0, y0 + bh - r), -- 513
			Vec2(x0, y0 + r) -- 513
		} -- 513
		do -- 513
			local i = 0 -- 515
			while i < #border - 1 do -- 515
				d:drawSegment(border[i + 1], border[i + 1 + 1], 2.5, outline) -- 516
				i = i + 1 -- 515
			end -- 515
		end -- 515
		d:drawPolygon( -- 518
			{ -- 518
				Vec2(BUBX - 26, y0 + 1), -- 518
				Vec2(BUBX - 2, y0 + 1), -- 518
				Vec2(BUBX - 18, y0 - 20) -- 518
			}, -- 518
			fill -- 518
		) -- 518
		d:drawSegment( -- 519
			Vec2(BUBX - 26, y0 + 1), -- 519
			Vec2(BUBX - 18, y0 - 20), -- 519
			2.5, -- 519
			outline -- 519
		) -- 519
		d:drawSegment( -- 520
			Vec2(BUBX - 18, y0 - 20), -- 520
			Vec2(BUBX - 2, y0 + 1), -- 520
			2.5, -- 520
			outline -- 520
		) -- 520
	end -- 500
	local SCENE_B = 21.45 -- 524
	local function wipeRadius(tt) -- 525
		local maxR = math.sqrt(W / 2 * (W / 2) + H / 2 * (H / 2)) + 30 -- 526
		if tt < SCENE_B then -- 526
			return maxR * smooth(20.5, SCENE_B, tt) -- 527
		end -- 527
		return maxR * (1 - smooth(21.55, 22.4, tt)) -- 528
	end -- 525
	local t = 0 -- 531
	local finished = false -- 532
	local function finalize() -- 536
		if finished then -- 536
			return -- 537
		end -- 537
		finished = true -- 538
		root.visible = false -- 539
		onFinish() -- 540
	end -- 536
	local function subAlpha(i) -- 544
		local s = SUBS[i + 1] -- 545
		return smooth(s.from, s.from + 0.4, t) * (1 - smooth(s.to - 0.4, s.to, t)) -- 546
	end -- 544
	local function render() -- 549
		local fadeIn = smooth(0, 3.5, t) -- 550
		local sceneB = t >= SCENE_B -- 551
		if cardSp ~= nil then -- 551
			local ca = smooth(0, 0.5, t) * (1 - smooth(3.6, 5, t)) -- 554
			cardSp.opacity = ca -- 555
			cardSp.visible = ca > 0.02 -- 556
		end -- 556
		do -- 556
			local useDusk = duskOk and not sceneB -- 560
			duskRoot.visible = useDusk -- 561
			if useDusk then -- 561
				do -- 561
					local i = 0 -- 564
					while i < #duskLayers do -- 564
						local L = duskLayers[i + 1] -- 565
						local dx = L.speed * t % L.tileW -- 566
						do -- 566
							local j = 0 -- 567
							while j < #L.sprites do -- 567
								L.sprites[j + 1].position = Vec2(-W / 2 + L.tileW / 2 + j * L.tileW - dx, 0) -- 568
								j = j + 1 -- 567
							end -- 567
						end -- 567
						i = i + 1 -- 564
					end -- 564
				end -- 564
			end -- 564
			bgDraw:clear() -- 572
			moonDraw:clear() -- 573
			local skyD = useDusk and moonDraw or bgDraw -- 575
			if not useDusk then -- 575
				bgDraw:drawPolygon( -- 577
					rectPts(-W / 2, -H / 2, W, H), -- 577
					col(Palette.paper) -- 577
				) -- 577
			end -- 577
			if not sceneB then -- 577
				skyD:drawDot( -- 580
					Vec2(MX, MY), -- 580
					MR + 52, -- 580
					col(Palette.moonHalo, fadeIn) -- 580
				) -- 580
				skyD:drawPolygon( -- 581
					circlePts(MX, MY, MR, 32), -- 581
					col(Palette.moonWhite, fadeIn) -- 581
				) -- 581
				skyD:drawDot( -- 582
					Vec2(MX - 30, MY + 34), -- 582
					14, -- 582
					col(Palette.paleInkFar, fadeIn * 0.5) -- 582
				) -- 582
				skyD:drawDot( -- 583
					Vec2(MX + 24, MY - 20), -- 583
					10, -- 583
					col(Palette.paleInkFar, fadeIn * 0.4) -- 583
				) -- 583
				local cu = smooth(8, 10.6, t) -- 584
				if cu > 0.01 then -- 584
					local cc = col(Palette.moonWhite, 0.95 * cu * fadeIn) -- 586
					drawPolyline( -- 587
						skyD, -- 587
						crackMain, -- 587
						cu, -- 587
						cc, -- 587
						2 -- 587
					) -- 587
					drawPolyline( -- 588
						skyD, -- 588
						crackBranch1, -- 588
						smooth(8.9, 10.6, t), -- 588
						cc, -- 588
						1.6 -- 588
					) -- 588
					drawPolyline( -- 589
						skyD, -- 589
						crackBranch2, -- 589
						smooth(9.6, 10.6, t), -- 589
						cc, -- 589
						1.6 -- 589
					) -- 589
				end -- 589
				if not useDusk then -- 589
					drawRidge( -- 592
						bgDraw, -- 592
						H / 2 - 210, -- 592
						55, -- 592
						1.3, -- 592
						24 + 6 * t, -- 592
						col(Palette.paleInkFar, fadeIn) -- 592
					) -- 592
					drawRidge( -- 593
						bgDraw, -- 593
						H / 2 - 140, -- 593
						75, -- 593
						4.2, -- 593
						40 + 11 * t, -- 593
						col(Palette.paleInkMid, fadeIn) -- 593
					) -- 593
					drawTown( -- 594
						bgDraw, -- 594
						col(Palette.inkSoft, fadeIn * 0.95) -- 594
					) -- 594
				end -- 594
			else -- 594
				drawRiverside( -- 597
					bgDraw, -- 597
					smooth(SCENE_B, 22.4, t), -- 597
					t -- 597
				) -- 597
			end -- 597
		end -- 597
		do -- 597
			sceneDraw:clear() -- 601
			if not sceneB then -- 601
				drawTower( -- 603
					sceneDraw, -- 603
					smooth(3.5, 4.6, t) -- 603
				) -- 603
				local cp = smooth(3.7, 8, t) -- 604
				if t < 14.5 then -- 604
					local fpos = pathPos(math.min(cp / 0.92, 1)) -- 606
					local mpos = pathPos(math.max(cp / 0.92 - 0.08, 0)) -- 607
					local walkPose = cp >= 1 and "stand" or "walk" -- 608
					drawFigure( -- 609
						sceneDraw, -- 609
						fpos.x, -- 609
						fpos.y, -- 609
						0.8, -- 609
						fadeIn, -- 609
						true, -- 609
						walkPose -- 609
					) -- 609
					drawFigure( -- 610
						sceneDraw, -- 610
						mpos.x, -- 610
						mpos.y, -- 610
						0.8, -- 610
						fadeIn, -- 610
						false, -- 610
						walkPose -- 610
					) -- 610
				else -- 610
					local u5 = t - 14.5 -- 613
					local topY = TTY + 12 -- 614
					local pushU = smooth(0.55, 0.95, u5) -- 615
					local hitU = smooth(1.1, 1.5, u5) -- 616
					local wx = lerp(TX - 16, TX - 86, pushU) -- 617
					local mx2 = lerp(TX + 6, TX - 30, hitU) -- 618
					local mAlpha = 1 - smooth(1.7, 2.4, u5) -- 619
					local bxA = lerp( -- 620
						TX + 180, -- 620
						TX + 46, -- 620
						smooth(0, 0.9, u5) -- 620
					) -- 620
					drawBandit( -- 621
						sceneDraw, -- 621
						bxA, -- 621
						topY, -- 621
						1, -- 621
						smooth(0, 0.4, u5) * (1 - smooth(2.2, 2.5, u5)) -- 621
					) -- 621
					drawBeam( -- 622
						sceneDraw, -- 622
						mx2, -- 622
						topY + 16, -- 622
						smooth(1.05, 1.25, u5) * (1 - smooth(1.6, 1.95, u5)) -- 622
					) -- 622
					local fPose = u5 > 1.7 and "kneel" or (pushU > 0 and pushU < 1 and "walk" or "stand") -- 623
					drawFigure( -- 624
						sceneDraw, -- 624
						wx, -- 624
						topY, -- 624
						1, -- 624
						1, -- 624
						true, -- 624
						fPose -- 624
					) -- 624
					local mPose = hitU >= 1 and "lie" or (u5 > 0.5 and u5 < 1 and "push" or "stand") -- 625
					drawFigure( -- 626
						sceneDraw, -- 626
						mx2, -- 626
						topY, -- 626
						1, -- 626
						mAlpha, -- 626
						false, -- 626
						mPose -- 626
					) -- 626
				end -- 626
				if t >= 10.8 and t <= 15.9 then -- 626
					do -- 626
						local i = 0 -- 629
						while i < 8 do -- 629
							local tp = torchPos(i, t) -- 630
							if tp.a > 0.02 then -- 630
								sceneDraw:drawDot( -- 632
									Vec2(tp.x, tp.y), -- 632
									9, -- 632
									col(Palette.vermilion, 0.18 * tp.a) -- 632
								) -- 632
								sceneDraw:drawDot( -- 633
									Vec2(tp.x, tp.y), -- 633
									4.5, -- 633
									col(Palette.vermilion, tp.a) -- 633
								) -- 633
							end -- 633
							i = i + 1 -- 629
						end -- 629
					end -- 629
				end -- 629
				if t >= 17 and t < SCENE_B then -- 629
					local hover = t > 18.2 and 4 * math.sin((t - 18.2) * 2) or 0 -- 638
					local wy = lerp( -- 639
						H / 2 + 180, -- 639
						WHEEL_CY, -- 639
						smooth(17, 18.2, t) -- 639
					) + hover -- 639
					drawWheel( -- 640
						sceneDraw, -- 640
						0, -- 640
						wy, -- 640
						1.2 * (t - 17) * (t - 17), -- 640
						smooth(17, 17.7, t) -- 640
					) -- 640
				end -- 640
			end -- 640
		end -- 640
		do -- 640
			fxDraw:clear() -- 646
			local bubA = smooth(22.7, 23.1, t) -- 647
			if bubA > 0.02 then -- 647
				drawBubble(fxDraw, bubA) -- 648
			end -- 648
			local fl = smooth(8, 8.5, t) * (1 - smooth(10.4, 11, t)) -- 649
			if fl > 0.01 then -- 649
				fxDraw:drawPolygon( -- 651
					rectPts(-W / 2, -H / 2, W, H), -- 652
					col( -- 653
						Palette.moonHalo, -- 653
						fl * (0.45 + 0.45 * math.sin(t * 9)) -- 653
					) -- 653
				) -- 653
			end -- 653
			local wr = wipeRadius(t) -- 655
			if wr > 1 then -- 655
				fxDraw:drawPolygon( -- 657
					circlePts(0, 0, wr, 48), -- 657
					col(Palette.inkDark) -- 657
				) -- 657
			end -- 657
			local endA = smooth(23, DURATION, t) -- 659
			if endA > 0.01 then -- 659
				fxDraw:drawPolygon( -- 661
					rectPts(-W / 2, -H / 2, W, H), -- 661
					col(Palette.paper, endA) -- 661
				) -- 661
			end -- 661
		end -- 661
		local si = -1 -- 664
		local sa = 0 -- 665
		do -- 665
			local i = 0 -- 666
			while i < #SUBS do -- 666
				local a2 = subAlpha(i) -- 667
				if a2 > sa then -- 667
					sa = a2 -- 669
					si = i -- 670
				end -- 670
				i = i + 1 -- 666
			end -- 666
		end -- 666
		do -- 666
			uiDraw:clear() -- 674
			if sa > 0.01 then -- 674
				uiDraw:drawPolygon( -- 676
					rectPts(-W / 2, SUBY - 24, W, 48), -- 676
					col(Palette.paperDim, 0.55 * sa) -- 676
				) -- 676
			end -- 676
		end -- 676
		if subLb ~= nil then -- 676
			subLb.visible = si >= 0 and sa > 0.02 -- 680
			if si >= 0 then -- 680
				subLb.text = SUBS[si + 1].text -- 681
			end -- 681
			subLb.opacity = si >= 0 and sa or 0 -- 682
		end -- 682
		if hintLb ~= nil then -- 682
			hintLb.opacity = smooth(1, 2.2, t) * 0.9 -- 684
		end -- 684
		if bubLb ~= nil then -- 684
			local bubA = smooth(22.7, 23.1, t) -- 686
			bubLb.visible = bubA > 0.02 -- 687
			bubLb.opacity = bubA -- 688
		end -- 688
		if t >= 11 and t <= 14.5 then -- 688
			local k = 1 - (t - 11) / 3.5 -- 692
			local amp = 8 * k * k -- 693
			local fi = math.floor(t * 28) -- 694
			sceneRoot.position = Vec2( -- 695
				(hash(fi) * 2 - 1) * amp, -- 695
				(hash(fi + 57) * 2 - 1) * amp -- 695
			) -- 695
		else -- 695
			sceneRoot.position = Vec2(0, 0) -- 697
		end -- 697
	end -- 549
	WHEEL_CY = 40 -- 702
	local function doSkip() -- 704
		if finished then -- 704
			return -- 705
		end -- 705
		t = DURATION -- 706
		render() -- 707
		finalize() -- 708
	end -- 704
	return { -- 711
		update = function(self, dt) -- 712
			if finished then -- 712
				return -- 713
			end -- 713
			if Keyboard:isKeyDown("Space") or Keyboard:isKeyDown("J") or Keyboard:isKeyDown("E") or Keyboard:isKeyDown("Return") then -- 713
				doSkip() -- 716
				return -- 717
			end -- 717
			t = t + dt -- 719
			if t > DURATION then -- 719
				t = DURATION -- 720
			end -- 720
			render() -- 721
			if t >= DURATION then -- 721
				finalize() -- 722
			end -- 722
		end, -- 712
		skip = function(self) -- 724
			doSkip() -- 725
		end, -- 724
		done = function(self) -- 727
			return finished -- 728
		end -- 727
	} -- 727
end -- 84
return ____exports -- 84