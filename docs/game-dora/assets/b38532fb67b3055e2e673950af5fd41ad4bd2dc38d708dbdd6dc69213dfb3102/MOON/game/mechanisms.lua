-- [ts]: mechanisms.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____physics = require("game.physics") -- 17
local rectOverlap = ____physics.rectOverlap -- 17
local moveAndCollide = ____physics.moveAndCollide -- 17
local clamp = ____physics.clamp -- 17
local ____player = require("game.player") -- 19
local PlayerTuning = ____player.PlayerTuning -- 19
local STONE_W = 56 -- 54
local STONE_H = 44 -- 55
local GRAV = 2300 -- 56
____exports.MechanismSystem = __TS__Class() -- 58
local MechanismSystem = ____exports.MechanismSystem -- 58
MechanismSystem.name = "MechanismSystem" -- 58
function MechanismSystem.prototype.____constructor(self, state, fx, events) -- 64
	self.fxGold = {r = 155, g = 113, b = 56, a = 255} -- 273
	self.fxCyan = {r = 168, g = 197, b = 188, a = 255} -- 274
	self.ropesList = {} -- 275
	self.bellsList = {} -- 276
	self.platesList = {} -- 277
	self.swordSlotsList = {} -- 278
	self.lampStoneCount = 0 -- 280
	self.gateReqs = {} -- 282
	self.windSigils = {} -- 300
	self.starNodes = {} -- 301
	self.state = state -- 65
	self.fx = fx -- 66
	self.events = events -- 67
	self.stones = {} -- 68
end -- 64
function MechanismSystem.prototype.syncStones(self, defs) -- 71
	__TS__ArraySetLength(self.stones, 0) -- 71
	do -- 71
		local i = 0 -- 73
		while i < #defs do -- 73
			local d = defs[i + 1] -- 74
			local ____self_stones_0 = self.stones -- 74
			____self_stones_0[#____self_stones_0 + 1] = { -- 75
				x = d.x, -- 75
				y = d.y + STONE_H / 2, -- 75
				vx = 0, -- 75
				vy = 0, -- 75
				w = STONE_W, -- 75
				h = STONE_H, -- 75
				onGround = false -- 75
			} -- 75
			i = i + 1 -- 73
		end -- 73
	end -- 73
end -- 71
function MechanismSystem.prototype.applyLoopVariants(self, ropes) -- 80
	do -- 80
		local i = 0 -- 81
		while i < #ropes do -- 81
			local r = ropes[i + 1] -- 82
			if r.loopState == "precut" and self.state.loopIndex >= 1 then -- 82
				self.state.cutRopes[r.id] = true -- 84
				self:openGateSilent(r.gateId) -- 85
			end -- 85
			i = i + 1 -- 81
		end -- 81
	end -- 81
end -- 80
function MechanismSystem.prototype.isGateOpen(self, gateId) -- 90
	return self.state.openedGates[gateId] == true -- 91
end -- 90
function MechanismSystem.prototype.openGate(self, gateId) -- 94
	if self.state.openedGates[gateId] then -- 94
		return -- 96
	end -- 96
	self.state.openedGates[gateId] = true -- 98
	self.events:onGateOpen(gateId) -- 99
end -- 94
function MechanismSystem.prototype.openGateSilent(self, gateId) -- 102
	self.state.openedGates[gateId] = true -- 103
end -- 102
function MechanismSystem.prototype.ropeRect(self, r) -- 106
	return {x = r.x - 6, y = r.y - r.length, w = 12, h = r.length} -- 107
end -- 106
function MechanismSystem.prototype.bellRect(self, b) -- 110
	return {x = b.x - 26, y = b.y - 20, w = 52, h = 46} -- 111
end -- 110
function MechanismSystem.prototype.stoneRect(self, s) -- 114
	return {x = s.x - s.w / 2, y = s.y - s.h / 2, w = s.w, h = s.h} -- 115
end -- 114
function MechanismSystem.prototype.update(self, dt, playerRect, playerPushDir, attackRect, qiRects, ctx) -- 118
	local reqGates = __TS__ObjectKeys(self.gateReqs) -- 128
	do -- 128
		local i = 0 -- 129
		while i < #reqGates do -- 129
			self:refreshGate(reqGates[i + 1]) -- 130
			i = i + 1 -- 129
		end -- 129
	end -- 129
	do -- 129
		local i = 0 -- 133
		while i < #self.stones do -- 133
			local s = self.stones[i + 1] -- 134
			local sr = self:stoneRect(s) -- 135
			local adjacent = playerRect.x < sr.x + sr.w + 4 and playerRect.x + playerRect.w > sr.x - 4 and playerRect.y < sr.y + sr.h and playerRect.y + playerRect.h > sr.y -- 137
			if adjacent and playerPushDir ~= 0 and s.onGround then -- 137
				local pushRight = playerRect.x + playerRect.w / 2 < s.x -- 145
				if pushRight and playerPushDir > 0 or not pushRight and playerPushDir < 0 then -- 145
					local targetVx = playerPushDir * PlayerTuning.runSpeed -- 147
					s.vx = s.vx + clamp(targetVx - s.vx, -PlayerTuning.accel * dt, PlayerTuning.accel * dt) -- 148
				else -- 148
					s.vx = s.vx + clamp(0 - s.vx, -PlayerTuning.decel * dt, PlayerTuning.decel * dt) -- 150
				end -- 150
			else -- 150
				s.vx = s.vx + clamp(0 - s.vx, -PlayerTuning.decel * dt, PlayerTuning.decel * dt) -- 153
			end -- 153
			s.vy = clamp(s.vy - GRAV * dt, -1150, 1150) -- 155
			local body = { -- 156
				x = s.x, -- 157
				y = s.y, -- 158
				vx = s.vx, -- 159
				vy = s.vy, -- 160
				w = s.w, -- 161
				h = s.h, -- 162
				onGround = s.onGround, -- 163
				groundId = "", -- 164
				onLadder = false -- 165
			} -- 165
			moveAndCollide( -- 167
				body, -- 167
				ctx.platforms, -- 167
				s.vx * dt, -- 167
				s.vy * dt, -- 167
				false -- 167
			) -- 167
			s.x = body.x -- 168
			s.y = body.y -- 169
			s.vx = body.vx -- 170
			s.vy = body.vy -- 171
			s.onGround = body.onGround -- 172
			i = i + 1 -- 133
		end -- 133
	end -- 133
	do -- 133
		local i = 0 -- 176
		while i < #self.ropesList do -- 176
			do -- 176
				local r = self.ropesList[i + 1] -- 177
				if self.state.cutRopes[r.id] then -- 177
					goto __continue27 -- 179
				end -- 179
				local rr = self:ropeRect(r) -- 181
				local cut = false -- 182
				if attackRect ~= nil and rectOverlap(attackRect, rr) then -- 182
					cut = true -- 184
				end -- 184
				do -- 184
					local k = 0 -- 186
					while k < #qiRects do -- 186
						if rectOverlap(qiRects[k + 1], rr) then -- 186
							cut = true -- 188
						end -- 188
						k = k + 1 -- 186
					end -- 186
				end -- 186
				if cut then -- 186
					self.state.cutRopes[r.id] = true -- 192
					self.fx:spawnRopeCut(r.x, r.y - r.length / 2) -- 193
					self.fx:spawnRing( -- 194
						r.x, -- 194
						r.y - r.length / 2, -- 194
						self.fxGold, -- 194
						10, -- 194
						90, -- 194
						0.5 -- 194
					) -- 194
					self:refreshGate(r.gateId) -- 195
				end -- 195
			end -- 195
			::__continue27:: -- 195
			i = i + 1 -- 176
		end -- 176
	end -- 176
	do -- 176
		local i = 0 -- 200
		while i < #self.swordSlotsList do -- 200
			do -- 200
				local slot = self.swordSlotsList[i + 1] -- 201
				local key = "swordslot_" .. slot.id -- 202
				if self.state.flags[key] == true then -- 202
					goto __continue35 -- 204
				end -- 204
				local sr = {x = slot.x - 26, y = slot.y, w = 52, h = 56} -- 206
				local hit = false -- 207
				if attackRect ~= nil and rectOverlap(attackRect, sr) then -- 207
					hit = true -- 209
				end -- 209
				if not hit then -- 209
					do -- 209
						local k = 0 -- 212
						while k < #qiRects do -- 212
							if rectOverlap(qiRects[k + 1], sr) then -- 212
								hit = true -- 214
								break -- 215
							end -- 215
							k = k + 1 -- 212
						end -- 212
					end -- 212
				end -- 212
				if hit then -- 212
					self.state.flags[key] = true -- 221
					self.fx:spawnRing( -- 222
						slot.x, -- 222
						slot.y + 30, -- 222
						self.fxGold, -- 222
						12, -- 222
						80, -- 222
						0.7 -- 222
					) -- 222
					self:refreshGate(slot.gateId) -- 223
					if self.events.onSwordInserted ~= nil then -- 223
						self.events:onSwordInserted() -- 225
					end -- 225
				end -- 225
			end -- 225
			::__continue35:: -- 225
			i = i + 1 -- 200
		end -- 200
	end -- 200
	do -- 200
		local i = 0 -- 231
		while i < #self.bellsList do -- 231
			do -- 231
				local b = self.bellsList[i + 1] -- 232
				if self.state.rungBells[b.id] then -- 232
					goto __continue45 -- 234
				end -- 234
				local br = self:bellRect(b) -- 236
				do -- 236
					local k = 0 -- 237
					while k < #qiRects do -- 237
						if rectOverlap(qiRects[k + 1], br) then -- 237
							self.state.rungBells[b.id] = true -- 239
							self.fx:spawnRing( -- 240
								b.x, -- 240
								b.y, -- 240
								self.fxCyan, -- 240
								14, -- 240
								130, -- 240
								0.8 -- 240
							) -- 240
							do -- 240
								local s = 0 -- 241
								while s < 10 do -- 241
									self.fx:spawnStars(b.x, b.y, 2) -- 242
									s = s + 1 -- 241
								end -- 241
							end -- 241
							self.events:onBell(b.x, b.y) -- 244
							self:refreshGate(b.gateId) -- 245
							break -- 246
						end -- 246
						k = k + 1 -- 237
					end -- 237
				end -- 237
			end -- 237
			::__continue45:: -- 237
			i = i + 1 -- 231
		end -- 231
	end -- 231
	do -- 231
		local i = 0 -- 252
		while i < #self.platesList do -- 252
			do -- 252
				local p = self.platesList[i + 1] -- 253
				if self.state.platesActive[p.id] then -- 253
					goto __continue53 -- 255
				end -- 255
				do -- 255
					local k = 0 -- 257
					while k < #self.stones do -- 257
						local s = self.stones[k + 1] -- 258
						local sr = self:stoneRect(s) -- 259
						local nearX = math.abs(s.x - p.x) < 40 -- 260
						local onTop = math.abs(sr.y - p.y) < 8 -- 262
						if nearX and onTop and s.onGround then -- 262
							self.state.platesActive[p.id] = true -- 264
							self.fx:spawnRing( -- 265
								p.x, -- 265
								p.y + 4, -- 265
								self.fxGold, -- 265
								12, -- 265
								70, -- 265
								0.6 -- 265
							) -- 265
							self:refreshGate(p.gateId) -- 266
							break -- 267
						end -- 267
						k = k + 1 -- 257
					end -- 257
				end -- 257
			end -- 257
			::__continue53:: -- 257
			i = i + 1 -- 252
		end -- 252
	end -- 252
end -- 118
function MechanismSystem.prototype.bindLists(self, ropes, bells, plates) -- 284
	self.ropesList = ropes -- 285
	self.bellsList = bells -- 286
	self.platesList = plates -- 287
end -- 284
function MechanismSystem.prototype.bindSwordSlots(self, slots) -- 290
	self.swordSlotsList = slots -- 291
end -- 290
function MechanismSystem.prototype.bindGateRequirements(self, reqs) -- 295
	self.gateReqs = reqs -- 296
end -- 295
function MechanismSystem.prototype.bindWindSigils(self, list) -- 303
	self.windSigils = list -- 304
end -- 303
function MechanismSystem.prototype.bindStarNodes(self, list) -- 307
	self.starNodes = list -- 308
end -- 307
function MechanismSystem.prototype.kindFlag(self, kind, id) -- 312
	if kind == "bell" then -- 312
		return self.state.rungBells[id] == true -- 314
	end -- 314
	if kind == "rope" then -- 314
		return self.state.cutRopes[id] == true -- 317
	end -- 317
	if kind == "plate" then -- 317
		return self.state.platesActive[id] == true -- 320
	end -- 320
	if kind == "slot" then -- 320
		return self.state.flags["swordslot_" .. id] == true -- 323
	end -- 323
	if kind == "wind" then -- 323
		return self.state.flags["wind_" .. id] == true -- 326
	end -- 326
	if kind == "star" then -- 326
		return self.state.flags["star_" .. id] == true -- 329
	end -- 329
	return false -- 331
end -- 312
function MechanismSystem.prototype.requirementMet(self, req) -- 335
	local sep = (string.find(req, ":", nil, true) or 0) - 1 -- 336
	if sep < 0 then -- 336
		return false -- 338
	end -- 338
	local kind = __TS__StringSubstring(req, 0, sep) -- 340
	local ids = __TS__StringSubstring(req, sep + 1) -- 341
	local plus = (string.find(ids, "+", nil, true) or 0) - 1 -- 342
	local head = plus >= 0 and __TS__StringSubstring(ids, 0, plus) or ids -- 343
	if self:kindFlag(kind, head) then -- 343
		return true -- 345
	end -- 345
	if plus >= 0 and self:kindFlag( -- 345
		kind, -- 347
		__TS__StringSubstring(ids, plus + 1) -- 347
	) then -- 347
		return true -- 348
	end -- 348
	return false -- 350
end -- 335
function MechanismSystem.prototype.gateSatisfied(self, gateId) -- 354
	local reqs = self.gateReqs[gateId] -- 355
	if reqs == nil then -- 355
		return true -- 357
	end -- 357
	do -- 357
		local i = 0 -- 359
		while i < #reqs do -- 359
			if not self:requirementMet(reqs[i + 1]) then -- 359
				return false -- 361
			end -- 361
			i = i + 1 -- 359
		end -- 359
	end -- 359
	return true -- 364
end -- 354
function MechanismSystem.prototype.refreshGate(self, gateId) -- 368
	if self.gateReqs[gateId] == nil then -- 368
		self:openGate(gateId) -- 370
		return -- 371
	end -- 371
	if self.state.openedGates[gateId] == true then -- 371
		return -- 374
	end -- 374
	if self:gateSatisfied(gateId) then -- 374
		self:openGate(gateId) -- 377
	end -- 377
end -- 368
function MechanismSystem.prototype.addLampStone(self) -- 382
	self.lampStoneCount = self.lampStoneCount + 1 -- 383
end -- 382
function MechanismSystem.prototype.tryDashWindSigils(self, px, py) -- 388
	do -- 388
		local i = 0 -- 389
		while i < #self.windSigils do -- 389
			do -- 389
				local s = self.windSigils[i + 1] -- 390
				if math.abs(s.x - px) >= 46 or math.abs(s.y - py) >= 90 then -- 390
					goto __continue86 -- 392
				end -- 392
				if self.state.flags["wind_" .. s.id] ~= true then -- 392
					self.state.flags["wind_" .. s.id] = true -- 395
					self.fx:spawnRing( -- 396
						s.x, -- 396
						s.y + 40, -- 396
						self.fxCyan, -- 396
						12, -- 396
						78, -- 396
						0.6 -- 396
					) -- 396
					self.events:onWindSigil(s.id) -- 397
				end -- 397
				self:refreshGate(s.gateId) -- 399
			end -- 399
			::__continue86:: -- 399
			i = i + 1 -- 389
		end -- 389
	end -- 389
end -- 388
function MechanismSystem.prototype.tryLightStar(self, px, py) -- 406
	local nearest = nil -- 407
	local bestDist = 999999 -- 408
	do -- 408
		local i = 0 -- 409
		while i < #self.starNodes do -- 409
			do -- 409
				local s = self.starNodes[i + 1] -- 410
				local dx = math.abs(s.x - px) -- 411
				local dy = math.abs(s.y - py) -- 412
				if dx >= 110 or dy >= 150 then -- 412
					goto __continue91 -- 414
				end -- 414
				local d = dx + dy * 0.5 -- 416
				if d < bestDist then -- 416
					bestDist = d -- 418
					nearest = s -- 419
				end -- 419
			end -- 419
			::__continue91:: -- 419
			i = i + 1 -- 409
		end -- 409
	end -- 409
	if nearest == nil then -- 409
		return false -- 423
	end -- 423
	if self.state.flags["star_" .. nearest.id] == true then -- 423
		self:refreshGate(nearest.gateId) -- 427
		return false -- 428
	end -- 428
	local expected = self:countLitStars() + 1 -- 430
	if nearest.order == expected then -- 430
		self.state.flags["star_" .. nearest.id] = true -- 432
		self.fx:spawnRing( -- 433
			nearest.x, -- 433
			nearest.y + 60, -- 433
			self.fxGold, -- 433
			10, -- 433
			66, -- 433
			0.6 -- 433
		) -- 433
		self.events:onStarLit(nearest.order) -- 434
		self:refreshGate(nearest.gateId) -- 435
		return true -- 436
	end -- 436
	local ids = __TS__ObjectKeys(self.state.flags) -- 439
	do -- 439
		local i = 0 -- 440
		while i < #ids do -- 440
			if (string.find(ids[i + 1], "star_", nil, true) or 0) - 1 == 0 then -- 440
				self.state.flags[ids[i + 1]] = false -- 442
			end -- 442
			i = i + 1 -- 440
		end -- 440
	end -- 440
	self.events:onStarFail() -- 445
	return true -- 446
end -- 406
function MechanismSystem.prototype.countLitStars(self) -- 450
	local n = 0 -- 451
	local ids = __TS__ObjectKeys(self.state.flags) -- 452
	do -- 452
		local i = 0 -- 453
		while i < #ids do -- 453
			if (string.find(ids[i + 1], "star_", nil, true) or 0) - 1 == 0 and self.state.flags[ids[i + 1]] == true then -- 453
				n = n + 1 -- 455
			end -- 455
			i = i + 1 -- 453
		end -- 453
	end -- 453
	return n -- 458
end -- 450
function MechanismSystem.prototype.tryLightLantern(self, lanterns, px, py) -- 463
	local nearest = nil -- 464
	local bestDist = 999999 -- 465
	do -- 465
		local i = 0 -- 466
		while i < #lanterns do -- 466
			do -- 466
				local l = lanterns[i + 1] -- 467
				local dx = math.abs(l.x - px) -- 468
				local dy = math.abs(l.y - py) -- 469
				if dx >= 110 or dy >= 150 then -- 469
					goto __continue106 -- 471
				end -- 471
				local d = dx + dy * 0.5 -- 473
				if d < bestDist then -- 473
					bestDist = d -- 475
					nearest = l -- 476
				end -- 476
			end -- 476
			::__continue106:: -- 476
			i = i + 1 -- 466
		end -- 466
	end -- 466
	if nearest == nil then -- 466
		return false -- 480
	end -- 480
	if self.state.lanternsLit[nearest.id] then -- 480
		return false -- 483
	end -- 483
	if self.lampStoneCount <= 0 then -- 483
		if self.events.onLanternNoStone ~= nil then -- 483
			self.events:onLanternNoStone() -- 488
		end -- 488
		return false -- 490
	end -- 490
	local expected = self.state.lanternSequence + 1 -- 492
	if nearest.order == expected then -- 492
		self.state.lanternsLit[nearest.id] = true -- 494
		self.lampStoneCount = self.lampStoneCount - 1 -- 495
		self.state.lanternSequence = expected -- 496
		self.state.lanternFailed = false -- 497
		self.fx:spawnRing( -- 498
			nearest.x, -- 498
			nearest.y + 14, -- 498
			self.fxCyan, -- 498
			10, -- 498
			60, -- 498
			0.6 -- 498
		) -- 498
		self.events:onLanternLit(nearest.order) -- 499
		if expected >= #lanterns then -- 499
			self:openGate("lanternGate") -- 501
		end -- 501
		return true -- 503
	end -- 503
	self.state.lanternFailed = true -- 507
	self.events:onLanternFail() -- 508
	return false -- 509
end -- 463
function MechanismSystem.prototype.touchCheckpoints(self, checkpoints, px, py) -- 513
	do -- 513
		local i = 0 -- 514
		while i < #checkpoints do -- 514
			do -- 514
				local c = checkpoints[i + 1] -- 515
				if self.state.checkpointsActivated[c.id] then -- 515
					goto __continue117 -- 517
				end -- 517
				local dx = math.abs(c.x - px) -- 519
				local dy = math.abs(c.y - py) -- 520
				if dx < 52 and dy < 70 then -- 520
					self.state.checkpointsActivated[c.id] = true -- 522
					self.state.currentCheckpointId = c.id -- 523
					self.fx:spawnRing( -- 524
						c.x, -- 524
						c.y + 40, -- 524
						self.fxCyan, -- 524
						14, -- 524
						110, -- 524
						0.9 -- 524
					) -- 524
					self.events:onCheckpoint(c.id) -- 525
				end -- 525
			end -- 525
			::__continue117:: -- 525
			i = i + 1 -- 514
		end -- 514
	end -- 514
end -- 513
function MechanismSystem.prototype.touchCollectibles(self, collectibles, px, py) -- 531
	do -- 531
		local i = 0 -- 532
		while i < #collectibles do -- 532
			do -- 532
				local c = collectibles[i + 1] -- 533
				if self.state.collectedIds[c.id] then -- 533
					goto __continue122 -- 535
				end -- 535
				if c.loops ~= nil and __TS__ArrayIndexOf(c.loops, self.state.loopIndex) < 0 then -- 535
					goto __continue122 -- 538
				end -- 538
				local dx = c.x - px -- 540
				local dy = c.y - py -- 541
				if dx * dx + dy * dy < 38 * 38 then -- 541
					self.state.collectedIds[c.id] = true -- 543
					if c.kind == "moonstone" then -- 543
						self.state.moonstones = self.state.moonstones + 1 -- 545
					elseif c.kind == "mechanism" then -- 545
						self.state.mechanismParts = self.state.mechanismParts + 1 -- 547
					elseif c.kind == "token" then -- 547
						self.state.tokens = self.state.tokens + 1 -- 549
						self.state.shenyanTrust = self.state.shenyanTrust + 2 -- 552
					elseif c.kind == "dew" then -- 552
						self.state.heroineLife = math.min(self.state.maxLife, self.state.heroineLife + 1) -- 554
					end -- 554
					self.fx:spawnStars(c.x, c.y, 8) -- 556
					self.fx:spawnRing( -- 557
						c.x, -- 557
						c.y, -- 557
						c.kind == "moonstone" and self.fxCyan or self.fxGold, -- 557
						8, -- 557
						80, -- 557
						0.5 -- 557
					) -- 557
					self.events:onCollect(c.kind, c.x, c.y) -- 558
				end -- 558
			end -- 558
			::__continue122:: -- 558
			i = i + 1 -- 532
		end -- 532
	end -- 532
end -- 531
return ____exports -- 531