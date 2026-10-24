-- [ts]: stealth.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 5
local DrawNode = ____Dora.DrawNode -- 5
local Label = ____Dora.Label -- 5
local Node = ____Dora.Node -- 5
local Sprite = ____Dora.Sprite -- 5
local Texture2D = ____Dora.Texture2D -- 5
local Vec2 = ____Dora.Vec2 -- 5
local ____palette = require("core.palette") -- 6
local ink = ____palette.ink -- 6
local Palette = ____palette.Palette -- 6
local ____tower = require("data.tower") -- 8
local TOPS = ____tower.TOPS -- 8
local CONE_RADIUS = 272 -- 12
local CONE_HALF_DEG = 33 -- 13
local CONE_HALF_RAD = CONE_HALF_DEG * math.pi / 180 -- 14
local CONE_HALF_COS = math.cos(CONE_HALF_RAD) -- 15
local CONE_SEGMENTS = 12 -- 16
local DETECT_CLOSE_RATE = 2.6 -- 17
local DETECT_DECAY = 0.8 -- 18
local LOSE_SIGHT_TIME = 5 -- 19
local HEAR_RADIUS = 240 -- 20
local NOISE_LANDING_SPEED = 420 -- 21
local PROX_SENSE = 90 -- 22
local HIDE_RADIUS = 40 -- 23
local HIDE_SAFE_DIST = 200 -- 24
local MARK_LIFE = 2 -- 25
local MARK_FADE = 0.6 -- 26
local MARK_TEX_Q = "assets/ui/stealth/mark_q.png" -- 27
local MARK_TEX_ALERT = "assets/ui/stealth/mark_alert.png" -- 28
local MARK_H = 42 -- 29
local MARK_RISE = 40 -- 30
local SEARCH_MARK_TIME = 1.4 -- 31
local STAND_Y = 34 -- 32
____exports.HIDE_SPOTS = { -- 47
	{ -- 49
		id = "hs_town0", -- 49
		x = 700, -- 49
		y = TOPS[2] + STAND_Y, -- 49
		r = HIDE_RADIUS, -- 49
		floor = 1, -- 49
		kind = "grass" -- 49
	}, -- 49
	{ -- 50
		id = "hs_town1", -- 50
		x = 1430, -- 50
		y = TOPS[2] + STAND_Y, -- 50
		r = HIDE_RADIUS, -- 50
		floor = 1, -- 50
		kind = "grass" -- 50
	}, -- 50
	{ -- 52
		id = "hs_table0", -- 52
		x = 550, -- 52
		y = TOPS[2] + 30, -- 52
		r = HIDE_RADIUS, -- 52
		floor = 1, -- 52
		kind = "table" -- 52
	}, -- 52
	{ -- 55
		id = "hs_river0", -- 55
		x = 2010, -- 55
		y = TOPS[1] + STAND_Y, -- 55
		r = HIDE_RADIUS, -- 55
		floor = 0, -- 55
		kind = "grass" -- 55
	}, -- 55
	{ -- 56
		id = "hs_star0", -- 56
		x = 1250, -- 56
		y = TOPS[6] + STAND_Y, -- 56
		r = HIDE_RADIUS, -- 56
		floor = 5, -- 56
		kind = "grass" -- 56
	} -- 56
} -- 56
local function segHitsRect(x0, y0, x1, y1, r) -- 82
	local tmin = 0 -- 83
	local tmax = 1 -- 84
	local dx = x1 - x0 -- 85
	local dy = y1 - y0 -- 86
	if dx > -0.000001 and dx < 0.000001 then -- 86
		if x0 < r.x or x0 > r.x + r.w then -- 86
			return false -- 89
		end -- 89
	else -- 89
		local t1 = (r.x - x0) / dx -- 92
		local t2 = (r.x + r.w - x0) / dx -- 93
		if t1 > t2 then -- 93
			local tt = t1 -- 95
			t1 = t2 -- 96
			t2 = tt -- 97
		end -- 97
		if t1 > tmin then -- 97
			tmin = t1 -- 100
		end -- 100
		if t2 < tmax then -- 100
			tmax = t2 -- 103
		end -- 103
		if tmin > tmax then -- 103
			return false -- 106
		end -- 106
	end -- 106
	if dy > -0.000001 and dy < 0.000001 then -- 106
		if y0 < r.y or y0 > r.y + r.h then -- 106
			return false -- 111
		end -- 111
	else -- 111
		local t1 = (r.y - y0) / dy -- 114
		local t2 = (r.y + r.h - y0) / dy -- 115
		if t1 > t2 then -- 115
			local tt = t1 -- 117
			t1 = t2 -- 118
			t2 = tt -- 119
		end -- 119
		if t1 > tmin then -- 119
			tmin = t1 -- 122
		end -- 122
		if t2 < tmax then -- 122
			tmax = t2 -- 125
		end -- 125
		if tmin > tmax then -- 125
			return false -- 128
		end -- 128
	end -- 128
	return true -- 131
end -- 82
____exports.StealthSystem = __TS__Class() -- 152
local StealthSystem = ____exports.StealthSystem -- 152
StealthSystem.name = "StealthSystem" -- 152
function StealthSystem.prototype.____constructor(self, enemies, platforms) -- 167
	self.enabled = true -- 155
	self.showCones = true -- 156
	self.lastInfos = {} -- 503
	self.enemies = enemies -- 168
	self.platforms = platforms -- 169
	self.rt = {} -- 170
	self.idsKey = "" -- 171
	self.blockers = {} -- 172
	self.marks = {} -- 173
	self.spriteMarks = {} -- 174
end -- 167
function StealthSystem.prototype.attachTo(self, parent) -- 179
	if self.root ~= nil then -- 179
		return -- 181
	end -- 181
	self.root = Node() -- 183
	self.root:addTo(parent) -- 184
	local draw = DrawNode() -- 185
	draw:addTo(self.root) -- 186
	self.coneDraw = draw -- 187
	self:setEnabled(true) -- 188
	self.markTexQ = Texture2D(MARK_TEX_Q) -- 190
	self.markTexA = Texture2D(MARK_TEX_ALERT) -- 191
	if self.markTexQ == nil or self.markTexA == nil then -- 191
		self.markTexQ = nil -- 193
		self.markTexA = nil -- 194
	end -- 194
end -- 179
function StealthSystem.prototype.setEnabled(self, on) -- 199
	self.enabled = on -- 200
	self.enemies:setStealthWired(on) -- 201
end -- 199
function StealthSystem.prototype.isEnabled(self) -- 204
	return self.enabled -- 205
end -- 204
function StealthSystem.prototype.setShowCones(self, on) -- 209
	self.showCones = on -- 210
end -- 209
function StealthSystem.prototype.isShowingCones(self) -- 213
	return self.showCones -- 214
end -- 213
function StealthSystem.prototype.detectionOf(self, enemyIndex) -- 218
	local r = self.rt[enemyIndex + 1] -- 219
	if r == nil then -- 219
		return 0 -- 221
	end -- 221
	return r.detection -- 223
end -- 218
function StealthSystem.prototype.isAlerted(self, enemyIndex) -- 226
	local r = self.rt[enemyIndex + 1] -- 227
	if r == nil then -- 227
		return false -- 229
	end -- 229
	return r.alerted -- 231
end -- 226
function StealthSystem.prototype.anyAlerted(self) -- 235
	do -- 235
		local i = 0 -- 236
		while i < #self.rt do -- 236
			local r = self.rt[i + 1] -- 237
			if r ~= nil and r.alerted then -- 237
				return true -- 239
			end -- 239
			i = i + 1 -- 236
		end -- 236
	end -- 236
	return false -- 242
end -- 235
function StealthSystem.prototype.emitNoise(self, x, floor, radius, loud) -- 247
	if radius == nil then -- 247
		radius = 300 -- 247
	end -- 247
	if loud == nil then -- 247
		loud = false -- 247
	end -- 247
	if not self.enabled then -- 247
		return -- 249
	end -- 249
	local infos = self.enemies:stealthInfos() -- 251
	do -- 251
		local i = 0 -- 252
		while i < #infos do -- 252
			do -- 252
				local info = infos[i + 1] -- 253
				local r = self.rt[i + 1] -- 254
				if r == nil or info.dead or info.floor ~= floor then -- 254
					goto __continue36 -- 256
				end -- 256
				if math.abs(info.x - x) > radius then -- 256
					goto __continue36 -- 259
				end -- 259
				self.enemies:faceToward(info.index, x) -- 261
				r.searchT = math.max(r.searchT, SEARCH_MARK_TIME + 0.6) -- 262
				if loud then -- 262
					r.detection = math.min(0.85, r.detection + 0.2) -- 264
				end -- 264
				if r.markKind == 0 then -- 264
					r.markKind = 1 -- 267
					r.markT = MARK_LIFE -- 268
				end -- 268
			end -- 268
			::__continue36:: -- 268
			i = i + 1 -- 252
		end -- 252
	end -- 252
end -- 247
function StealthSystem.prototype.resetRuntime(self) -- 274
	do -- 274
		local i = 0 -- 275
		while i < #self.rt do -- 275
			do -- 275
				local r = self.rt[i + 1] -- 276
				if r == nil then -- 276
					goto __continue43 -- 278
				end -- 278
				r.detection = 0 -- 280
				r.alerted = false -- 281
				r.lostT = 0 -- 282
				r.searchT = 0 -- 283
				r.markKind = 0 -- 284
				r.markT = 0 -- 285
			end -- 285
			::__continue43:: -- 285
			i = i + 1 -- 275
		end -- 275
	end -- 275
	self:hideAllMarks() -- 287
	local infos = self.enemies:stealthInfos() -- 288
	do -- 288
		local i = 0 -- 289
		while i < #infos do -- 289
			if not infos[i + 1].dead then -- 289
				self.enemies:setCalm(infos[i + 1].index) -- 291
			end -- 291
			i = i + 1 -- 289
		end -- 289
	end -- 289
end -- 274
function StealthSystem.prototype.views(self) -- 296
	local out = {} -- 297
	do -- 297
		local i = 0 -- 298
		while i < #self.lastInfos and i < #self.rt do -- 298
			do -- 298
				local info = self.lastInfos[i + 1] -- 299
				local r = self.rt[i + 1] -- 300
				if r == nil then -- 300
					goto __continue50 -- 302
				end -- 302
				out[#out + 1] = { -- 304
					index = info.index, -- 305
					id = info.id, -- 306
					kind = info.kind, -- 307
					floor = info.floor, -- 308
					x = info.x, -- 309
					y = info.y, -- 310
					facing = info.facing, -- 311
					state = info.state, -- 312
					detection = r.detection, -- 313
					alerted = r.alerted, -- 314
					searching = r.searchT > 0 -- 315
				} -- 315
			end -- 315
			::__continue50:: -- 315
			i = i + 1 -- 298
		end -- 298
	end -- 298
	return out -- 318
end -- 296
function StealthSystem.prototype.syncRuntime(self, infos) -- 322
	local key = "" -- 323
	do -- 323
		local i = 0 -- 324
		while i < #infos do -- 324
			key = (key .. infos[i + 1].id) .. ";" -- 325
			i = i + 1 -- 324
		end -- 324
	end -- 324
	if key == self.idsKey then -- 324
		return -- 328
	end -- 328
	self.idsKey = key -- 330
	self.rt = {} -- 331
	do -- 331
		local i = 0 -- 332
		while i < #infos do -- 332
			local ____self_rt_0 = self.rt -- 332
			____self_rt_0[#____self_rt_0 + 1] = { -- 333
				detection = 0, -- 334
				alerted = false, -- 335
				lostT = 0, -- 336
				searchT = 0, -- 337
				lastSeenX = infos[i + 1].x, -- 338
				markKind = 0, -- 339
				markT = 0 -- 340
			} -- 340
			i = i + 1 -- 332
		end -- 332
	end -- 332
	self:hideAllMarks() -- 343
end -- 322
function StealthSystem.prototype.blockersOf(self, floor) -- 348
	local list = self.blockers[floor + 1] -- 349
	if list ~= nil then -- 349
		return list -- 351
	end -- 351
	list = {} -- 353
	do -- 353
		local i = 0 -- 354
		while i < #self.platforms do -- 354
			local p = self.platforms[i + 1] -- 355
			if p.floor == floor and (p.kind == "solid" or p.kind == "gate") then -- 355
				list[#list + 1] = p -- 357
			end -- 357
			i = i + 1 -- 354
		end -- 354
	end -- 354
	self.blockers[floor + 1] = list -- 360
	return list -- 361
end -- 348
function StealthSystem.prototype.nearestFloor(self, y) -- 364
	local best = 0 -- 365
	local bestD = -1 -- 366
	do -- 366
		local f = 0 -- 367
		while f < #TOPS do -- 367
			local d = math.abs(TOPS[f + 1] + STAND_Y - y) -- 368
			if bestD < 0 or d < bestD then -- 368
				bestD = d -- 370
				best = f -- 371
			end -- 371
			f = f + 1 -- 367
		end -- 367
	end -- 367
	return best -- 374
end -- 364
function StealthSystem.prototype.inHideSpot(self, px, py, floor) -- 377
	do -- 377
		local i = 0 -- 378
		while i < #____exports.HIDE_SPOTS do -- 378
			do -- 378
				local s = ____exports.HIDE_SPOTS[i + 1] -- 379
				if s.floor ~= floor then -- 379
					goto __continue69 -- 381
				end -- 381
				local dx = px - s.x -- 383
				local dy = py - s.y -- 384
				if math.sqrt(dx * dx + dy * dy) <= s.r then -- 384
					return true -- 386
				end -- 386
			end -- 386
			::__continue69:: -- 386
			i = i + 1 -- 378
		end -- 378
	end -- 378
	return false -- 389
end -- 377
function StealthSystem.prototype.segBlocked(self, info, eyeY, px, py) -- 392
	local list = self:blockersOf(info.floor) -- 393
	do -- 393
		local i = 0 -- 394
		while i < #list do -- 394
			if segHitsRect( -- 394
				info.x, -- 395
				eyeY, -- 395
				px, -- 395
				py, -- 395
				list[i + 1] -- 395
			) then -- 395
				return true -- 396
			end -- 396
			i = i + 1 -- 394
		end -- 394
	end -- 394
	return false -- 399
end -- 392
function StealthSystem.prototype.update(self, dt, playerX, playerY, playerDashing, extras) -- 404
	local infos = self.enemies:stealthInfos() -- 405
	self:syncRuntime(infos) -- 406
	self.lastInfos = infos -- 407
	if not self.enabled then -- 407
		self:drawFrame(infos, playerX, playerY) -- 409
		return -- 410
	end -- 410
	local pfloor = extras ~= nil and extras.floor ~= nil and extras.floor or self:nearestFloor(playerY) -- 412
	local landing = extras ~= nil and extras.landingSpeed ~= nil and extras.landingSpeed or 0 -- 413
	local runNoise = playerDashing or landing >= NOISE_LANDING_SPEED -- 414
	local attackX = extras ~= nil and extras.attackX ~= nil and extras.attackX or -1 -- 415
	local attackNoise = attackX >= 0 -- 416
	local hidden = self:inHideSpot(playerX, playerY, pfloor) -- 417
	do -- 417
		local i = 0 -- 418
		while i < #infos do -- 418
			do -- 418
				local info = infos[i + 1] -- 419
				local r = self.rt[i + 1] -- 420
				if r == nil or info.dead then -- 420
					goto __continue79 -- 422
				end -- 422
				if info.kind == "boss" then -- 422
					goto __continue79 -- 426
				end -- 426
				if info.floor ~= pfloor then -- 426
					r.detection = math.max(0, r.detection - DETECT_DECAY * dt) -- 430
					r.searchT = math.max(0, r.searchT - dt) -- 431
					r.markT = math.max(0, r.markT - dt) -- 432
					goto __continue79 -- 433
				end -- 433
				local eyeY = info.y + info.h * 0.3 -- 435
				local dx = playerX - info.x -- 436
				local dy = playerY - eyeY -- 437
				local dist = math.sqrt(dx * dx + dy * dy) -- 438
				local inCone = false -- 441
				if dist > 1 and dist <= CONE_RADIUS then -- 441
					if dx * info.facing >= dist * CONE_HALF_COS then -- 441
						inCone = true -- 444
					end -- 444
				end -- 444
				local visible = inCone or dist <= PROX_SENSE -- 447
				if visible and dist > PROX_SENSE and self:segBlocked(info, eyeY, playerX, playerY) then -- 447
					visible = false -- 449
				end -- 449
				if visible and hidden and dist > HIDE_SAFE_DIST then -- 449
					visible = false -- 452
				end -- 452
				if r.alerted then -- 452
					if visible then -- 452
						r.lostT = 0 -- 456
						r.lastSeenX = playerX -- 457
					else -- 457
						r.lostT = r.lostT + dt -- 459
						if r.lostT >= LOSE_SIGHT_TIME then -- 459
							self.enemies:setCalm(info.index) -- 462
							r.alerted = false -- 463
							r.lostT = 0 -- 464
							r.detection = 0.55 -- 465
							r.searchT = SEARCH_MARK_TIME -- 466
						end -- 466
					end -- 466
				elseif visible then -- 466
					local closeness = 1 - math.min(1, dist / CONE_RADIUS) -- 470
					r.detection = r.detection + DETECT_CLOSE_RATE * (0.45 + 0.55 * closeness) * dt -- 471
					r.lastSeenX = playerX -- 472
					r.searchT = math.max(r.searchT, 0.9) -- 473
					if r.detection >= 1 then -- 473
						r.detection = 1 -- 475
						r.alerted = true -- 476
						r.lostT = 0 -- 477
						r.markKind = 2 -- 478
						r.markT = MARK_LIFE -- 479
						self.enemies:setAlert(info.index, r.lastSeenX) -- 480
					end -- 480
				else -- 480
					r.detection = math.max(0, r.detection - DETECT_DECAY * dt) -- 483
					local heard = false -- 484
					if dist <= HEAR_RADIUS and (runNoise or attackNoise and dist > 0) then -- 484
						heard = true -- 486
						self.enemies:faceToward(info.index, runNoise and playerX or attackX) -- 488
						r.searchT = math.max(r.searchT, SEARCH_MARK_TIME) -- 489
						r.detection = math.min(0.85, r.detection + 0.35 * dt) -- 490
					end -- 490
					if not heard then -- 490
						r.searchT = math.max(0, r.searchT - dt) -- 493
					end -- 493
				end -- 493
				if r.markT > 0 then -- 493
					r.markT = math.max(0, r.markT - dt) -- 497
				end -- 497
			end -- 497
			::__continue79:: -- 497
			i = i + 1 -- 418
		end -- 418
	end -- 418
	self:drawFrame(infos, playerX, playerY) -- 500
end -- 404
function StealthSystem.prototype.drawFrame(self, infos, playerX, playerY) -- 506
	local draw = self.coneDraw -- 507
	if draw == nil then -- 507
		return -- 509
	end -- 509
	draw:clear() -- 511
	local pfloor = self:nearestFloor(playerY) -- 512
	do -- 512
		local i = 0 -- 513
		while i < #____exports.HIDE_SPOTS do -- 513
			do -- 513
				local s = ____exports.HIDE_SPOTS[i + 1] -- 514
				if s.floor ~= pfloor or s.kind == "table" then -- 514
					goto __continue100 -- 516
				end -- 516
				local baseY = s.y - STAND_Y -- 518
				draw:drawSegment( -- 519
					Vec2(s.x - 14, baseY), -- 519
					Vec2(s.x - 6, baseY + 26), -- 519
					3, -- 519
					Palette.moonCyanSoft -- 519
				) -- 519
				draw:drawSegment( -- 520
					Vec2(s.x, baseY), -- 520
					Vec2(s.x + 1, baseY + 34), -- 520
					3, -- 520
					Palette.moonCyanSoft -- 520
				) -- 520
				draw:drawSegment( -- 521
					Vec2(s.x + 14, baseY), -- 521
					Vec2(s.x + 8, baseY + 24), -- 521
					3, -- 521
					Palette.moonCyanSoft -- 521
				) -- 521
			end -- 521
			::__continue100:: -- 521
			i = i + 1 -- 513
		end -- 513
	end -- 513
	if not self.showCones then -- 513
		return -- 524
	end -- 524
	do -- 524
		local i = 0 -- 526
		while i < #infos do -- 526
			do -- 526
				local info = infos[i + 1] -- 527
				local r = self.rt[i + 1] -- 528
				if r == nil or info.dead or info.floor ~= pfloor or info.kind == "boss" then -- 528
					goto __continue104 -- 530
				end -- 530
				local eyeY = info.y + info.h * 0.3 -- 532
				local base = info.facing > 0 and 0 or math.pi -- 533
				local verts = {Vec2(info.x, eyeY)} -- 534
				do -- 534
					local k = 0 -- 535
					while k <= CONE_SEGMENTS do -- 535
						local ang = base - CONE_HALF_RAD + 2 * CONE_HALF_RAD * k / CONE_SEGMENTS -- 536
						verts[#verts + 1] = Vec2( -- 537
							info.x + math.cos(ang) * CONE_RADIUS, -- 537
							eyeY + math.sin(ang) * CONE_RADIUS -- 537
						) -- 537
						k = k + 1 -- 535
					end -- 535
				end -- 535
				local fill -- 539
				if r.alerted then -- 539
					fill = ink(Palette.vermilion.r, Palette.vermilion.g, Palette.vermilion.b, 70) -- 541
				else -- 541
					local t = r.detection -- 543
					fill = ink( -- 544
						math.floor(101 + 54 * t), -- 545
						math.floor(112 + 1 * t), -- 546
						math.floor(107 - 51 * t), -- 547
						math.floor(38 + 52 * t) -- 548
					) -- 548
				end -- 548
				draw:drawPolygon(verts, fill) -- 551
				if not r.alerted and r.detection > 0.02 then -- 551
					local hy = info.y + info.h / 2 + 12 -- 553
					draw:drawPolygon( -- 554
						{ -- 555
							Vec2(info.x - 19, hy), -- 555
							Vec2(info.x + 19, hy), -- 555
							Vec2(info.x + 19, hy + 6), -- 555
							Vec2(info.x - 19, hy + 6) -- 555
						}, -- 555
						ink(30, 37, 36, 90) -- 556
					) -- 556
					local w = 38 * r.detection -- 558
					draw:drawPolygon( -- 559
						{ -- 560
							Vec2(info.x - 19, hy), -- 560
							Vec2(info.x - 19 + w, hy), -- 560
							Vec2(info.x - 19 + w, hy + 6), -- 560
							Vec2(info.x - 19, hy + 6) -- 560
						}, -- 560
						Palette.gold -- 561
					) -- 561
				end -- 561
				self:updateMark(info, r) -- 564
			end -- 564
			::__continue104:: -- 564
			i = i + 1 -- 526
		end -- 526
	end -- 526
	self:hideStaleMarks() -- 566
end -- 506
function StealthSystem.prototype.updateMark(self, info, r) -- 569
	if r.markT <= 0 and r.markKind == 2 then -- 569
		r.markKind = 0 -- 571
	end -- 571
	local want = r.markKind -- 573
	if want == 0 and not r.alerted and r.searchT > 0 and r.detection > 0.04 then -- 573
		want = 1 -- 575
	end -- 575
	if want == 0 then -- 575
		return -- 578
	end -- 578
	local srec = self:markSpriteRec(info.index) -- 581
	if srec ~= nil then -- 581
		self:showSpriteMark(srec, want, info, r) -- 583
		return -- 584
	end -- 584
	local rec = self:markRec(info.index) -- 586
	if rec == nil then -- 586
		return -- 588
	end -- 588
	local lb = rec.lb -- 590
	local text = want == 2 and "!" or "?" -- 591
	if lb.text ~= text then -- 591
		lb.text = text -- 593
	end -- 593
	lb.color = want == 2 and Palette.gold or Palette.paleInk -- 595
	lb.position = Vec2(info.x, info.y + info.h / 2 + (want == 2 and 34 or 26)) -- 596
	lb.visible = true -- 597
	lb.opacity = want == 2 and math.min(1, r.markT / MARK_FADE) or 1 -- 598
	rec.shown = true -- 599
end -- 569
function StealthSystem.prototype.markRec(self, index) -- 602
	do -- 602
		local i = 0 -- 603
		while i < #self.marks do -- 603
			if self.marks[i + 1].enemyIndex == index then -- 603
				return self.marks[i + 1] -- 605
			end -- 605
			i = i + 1 -- 603
		end -- 603
	end -- 603
	if #self.marks >= 24 or self.root == nil then -- 603
		return nil -- 609
	end -- 609
	local lb = Label("sarasa-mono-sc-regular", 22) -- 611
	if lb == nil then -- 611
		return nil -- 613
	end -- 613
	lb:addTo(self.root) -- 615
	local rec = {enemyIndex = index, lb = lb, shown = false} -- 616
	local ____self_marks_1 = self.marks -- 616
	____self_marks_1[#____self_marks_1 + 1] = rec -- 617
	return rec -- 618
end -- 602
function StealthSystem.prototype.markSpriteRec(self, index) -- 622
	do -- 622
		local i = 0 -- 623
		while i < #self.spriteMarks do -- 623
			if self.spriteMarks[i + 1].enemyIndex == index then -- 623
				return self.spriteMarks[i + 1] -- 625
			end -- 625
			i = i + 1 -- 623
		end -- 623
	end -- 623
	if #self.spriteMarks >= 24 or self.root == nil then -- 623
		return nil -- 629
	end -- 629
	local qTex = self.markTexQ -- 631
	local aTex = self.markTexA -- 632
	if qTex == nil or aTex == nil then -- 632
		return nil -- 634
	end -- 634
	local q = Sprite(qTex) -- 636
	local a = Sprite(aTex) -- 637
	if q == nil or a == nil then -- 637
		return nil -- 639
	end -- 639
	q:addTo(self.root) -- 641
	a:addTo(self.root) -- 642
	q.anchor = Vec2(0.5, 0.5) -- 643
	a.anchor = Vec2(0.5, 0.5) -- 644
	q.filter = "Point" -- 645
	a.filter = "Point" -- 646
	q.visible = false -- 647
	a.visible = false -- 648
	local rec = { -- 649
		enemyIndex = index, -- 650
		q = q, -- 651
		a = a, -- 652
		qScale = qTex.height > 0 and MARK_H / qTex.height or 1, -- 653
		aScale = aTex.height > 0 and MARK_H / aTex.height or 1, -- 654
		shown = false -- 655
	} -- 655
	local ____self_spriteMarks_2 = self.spriteMarks -- 655
	____self_spriteMarks_2[#____self_spriteMarks_2 + 1] = rec -- 657
	return rec -- 658
end -- 622
function StealthSystem.prototype.showSpriteMark(self, rec, want, info, r) -- 661
	local sp = want == 2 and rec.a or rec.q -- 662
	local other = want == 2 and rec.q or rec.a -- 663
	other.visible = false -- 664
	local topY = info.y + info.h / 2 -- 665
	local rise = MARK_RISE -- 666
	local opacity = 1 -- 667
	local scale = want == 2 and rec.aScale or rec.qScale -- 668
	if want == 2 then -- 668
		local age = MARK_LIFE - r.markT -- 671
		local pop = math.min(1, age / 0.15) -- 672
		scale = scale * (0.7 + 0.3 * pop) -- 673
		rise = rise + (1 - pop) * 10 -- 674
		opacity = math.min(1, r.markT / MARK_FADE) -- 675
	end -- 675
	sp.position = Vec2(info.x, topY + rise) -- 677
	sp.scaleX = scale -- 678
	sp.scaleY = scale -- 679
	sp.opacity = opacity -- 680
	sp.visible = true -- 681
	rec.shown = true -- 682
end -- 661
function StealthSystem.prototype.hideStaleMarks(self) -- 686
	do -- 686
		local i = 0 -- 687
		while i < #self.spriteMarks do -- 687
			local rec = self.spriteMarks[i + 1] -- 688
			if rec.shown then -- 688
				rec.shown = false -- 690
			else -- 690
				rec.q.visible = false -- 692
				rec.a.visible = false -- 693
			end -- 693
			i = i + 1 -- 687
		end -- 687
	end -- 687
	do -- 687
		local i = 0 -- 696
		while i < #self.marks do -- 696
			local rec = self.marks[i + 1] -- 697
			if rec.shown then -- 697
				rec.shown = false -- 699
			else -- 699
				rec.lb.visible = false -- 701
			end -- 701
			i = i + 1 -- 696
		end -- 696
	end -- 696
end -- 686
function StealthSystem.prototype.hideAllMarks(self) -- 707
	do -- 707
		local i = 0 -- 708
		while i < #self.spriteMarks do -- 708
			self.spriteMarks[i + 1].q.visible = false -- 709
			self.spriteMarks[i + 1].a.visible = false -- 710
			self.spriteMarks[i + 1].shown = false -- 711
			i = i + 1 -- 708
		end -- 708
	end -- 708
	do -- 708
		local i = 0 -- 713
		while i < #self.marks do -- 713
			self.marks[i + 1].lb.visible = false -- 714
			self.marks[i + 1].shown = false -- 715
			i = i + 1 -- 713
		end -- 713
	end -- 713
end -- 707
return ____exports -- 707