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
function MechanismSystem.prototype.tryLightStar(self, px, py) -- 405
	local nearest = nil -- 406
	local bestDist = 60 -- 407
	do -- 407
		local i = 0 -- 408
		while i < #self.starNodes do -- 408
			local s = self.starNodes[i + 1] -- 409
			local d = math.abs(s.x - px) + math.abs(s.y - py) * 0.5 -- 410
			if d < bestDist then -- 410
				bestDist = d -- 412
				nearest = s -- 413
			end -- 413
			i = i + 1 -- 408
		end -- 408
	end -- 408
	if nearest == nil then -- 408
		return false -- 417
	end -- 417
	if self.state.flags["star_" .. nearest.id] == true then -- 417
		self:refreshGate(nearest.gateId) -- 421
		return false -- 422
	end -- 422
	local expected = self:countLitStars() + 1 -- 424
	if nearest.order == expected then -- 424
		self.state.flags["star_" .. nearest.id] = true -- 426
		self.fx:spawnRing( -- 427
			nearest.x, -- 427
			nearest.y + 60, -- 427
			self.fxGold, -- 427
			10, -- 427
			66, -- 427
			0.6 -- 427
		) -- 427
		self.events:onStarLit(nearest.order) -- 428
		self:refreshGate(nearest.gateId) -- 429
		return true -- 430
	end -- 430
	local ids = __TS__ObjectKeys(self.state.flags) -- 433
	do -- 433
		local i = 0 -- 434
		while i < #ids do -- 434
			if (string.find(ids[i + 1], "star_", nil, true) or 0) - 1 == 0 then -- 434
				self.state.flags[ids[i + 1]] = false -- 436
			end -- 436
			i = i + 1 -- 434
		end -- 434
	end -- 434
	self.events:onStarFail() -- 439
	return true -- 440
end -- 405
function MechanismSystem.prototype.countLitStars(self) -- 444
	local n = 0 -- 445
	local ids = __TS__ObjectKeys(self.state.flags) -- 446
	do -- 446
		local i = 0 -- 447
		while i < #ids do -- 447
			if (string.find(ids[i + 1], "star_", nil, true) or 0) - 1 == 0 and self.state.flags[ids[i + 1]] == true then -- 447
				n = n + 1 -- 449
			end -- 449
			i = i + 1 -- 447
		end -- 447
	end -- 447
	return n -- 452
end -- 444
function MechanismSystem.prototype.tryLightLantern(self, lanterns, px, py) -- 456
	local nearest = nil -- 457
	local bestDist = 60 -- 458
	do -- 458
		local i = 0 -- 459
		while i < #lanterns do -- 459
			local l = lanterns[i + 1] -- 460
			local d = math.abs(l.x - px) + math.abs(l.y - py) * 0.5 -- 461
			if d < bestDist then -- 461
				bestDist = d -- 463
				nearest = l -- 464
			end -- 464
			i = i + 1 -- 459
		end -- 459
	end -- 459
	if nearest == nil then -- 459
		return false -- 468
	end -- 468
	if self.state.lanternsLit[nearest.id] then -- 468
		return false -- 471
	end -- 471
	if self.lampStoneCount <= 0 then -- 471
		if self.events.onLanternNoStone ~= nil then -- 471
			self.events:onLanternNoStone() -- 476
		end -- 476
		return false -- 478
	end -- 478
	local expected = self.state.lanternSequence + 1 -- 480
	if nearest.order == expected then -- 480
		self.state.lanternsLit[nearest.id] = true -- 482
		self.lampStoneCount = self.lampStoneCount - 1 -- 483
		self.state.lanternSequence = expected -- 484
		self.state.lanternFailed = false -- 485
		self.fx:spawnRing( -- 486
			nearest.x, -- 486
			nearest.y + 14, -- 486
			self.fxCyan, -- 486
			10, -- 486
			60, -- 486
			0.6 -- 486
		) -- 486
		self.events:onLanternLit(nearest.order) -- 487
		if expected >= #lanterns then -- 487
			self:openGate("lanternGate") -- 489
		end -- 489
		return true -- 491
	end -- 491
	self.state.lanternFailed = true -- 495
	self.events:onLanternFail() -- 496
	return false -- 497
end -- 456
function MechanismSystem.prototype.touchCheckpoints(self, checkpoints, px, py) -- 501
	do -- 501
		local i = 0 -- 502
		while i < #checkpoints do -- 502
			do -- 502
				local c = checkpoints[i + 1] -- 503
				if self.state.checkpointsActivated[c.id] then -- 503
					goto __continue115 -- 505
				end -- 505
				local dx = math.abs(c.x - px) -- 507
				local dy = math.abs(c.y - py) -- 508
				if dx < 52 and dy < 70 then -- 508
					self.state.checkpointsActivated[c.id] = true -- 510
					self.state.currentCheckpointId = c.id -- 511
					self.fx:spawnRing( -- 512
						c.x, -- 512
						c.y + 40, -- 512
						self.fxCyan, -- 512
						14, -- 512
						110, -- 512
						0.9 -- 512
					) -- 512
					self.events:onCheckpoint(c.id) -- 513
				end -- 513
			end -- 513
			::__continue115:: -- 513
			i = i + 1 -- 502
		end -- 502
	end -- 502
end -- 501
function MechanismSystem.prototype.touchCollectibles(self, collectibles, px, py) -- 519
	do -- 519
		local i = 0 -- 520
		while i < #collectibles do -- 520
			do -- 520
				local c = collectibles[i + 1] -- 521
				if self.state.collectedIds[c.id] then -- 521
					goto __continue120 -- 523
				end -- 523
				if c.loops ~= nil and __TS__ArrayIndexOf(c.loops, self.state.loopIndex) < 0 then -- 523
					goto __continue120 -- 526
				end -- 526
				local dx = c.x - px -- 528
				local dy = c.y - py -- 529
				if dx * dx + dy * dy < 38 * 38 then -- 529
					self.state.collectedIds[c.id] = true -- 531
					if c.kind == "moonstone" then -- 531
						self.state.moonstones = self.state.moonstones + 1 -- 533
					elseif c.kind == "mechanism" then -- 533
						self.state.mechanismParts = self.state.mechanismParts + 1 -- 535
					elseif c.kind == "token" then -- 535
						self.state.tokens = self.state.tokens + 1 -- 537
						self.state.shenyanTrust = self.state.shenyanTrust + 2 -- 540
					elseif c.kind == "dew" then -- 540
						self.state.heroineLife = math.min(self.state.maxLife, self.state.heroineLife + 1) -- 542
					end -- 542
					self.fx:spawnStars(c.x, c.y, 8) -- 544
					self.fx:spawnRing( -- 545
						c.x, -- 545
						c.y, -- 545
						c.kind == "moonstone" and self.fxCyan or self.fxGold, -- 545
						8, -- 545
						80, -- 545
						0.5 -- 545
					) -- 545
					self.events:onCollect(c.kind, c.x, c.y) -- 546
				end -- 546
			end -- 546
			::__continue120:: -- 546
			i = i + 1 -- 520
		end -- 520
	end -- 520
end -- 519
return ____exports -- 519