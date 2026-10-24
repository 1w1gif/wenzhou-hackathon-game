-- [ts]: enemies.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____physics = require("game.physics") -- 2
local moveAndCollide = ____physics.moveAndCollide -- 2
local rectOverlap = ____physics.rectOverlap -- 2
local clamp = ____physics.clamp -- 2
local ____tower = require("data.tower") -- 5
local TOPS = ____tower.TOPS -- 5
local WORLD_W = ____tower.WORLD_W -- 5
local GRAV = 2300 -- 107
____exports.EnemySystem = __TS__Class() -- 109
local EnemySystem = ____exports.EnemySystem -- 109
EnemySystem.name = "EnemySystem" -- 109
function EnemySystem.prototype.____constructor(self, fx, events) -- 123
	self.stealthDriven = false -- 120
	self.backstabEnabled = false -- 121
	self.enemies = {} -- 124
	self.pots = {} -- 125
	self.waves = {} -- 126
	self.arrows = {} -- 127
	self.hits = {} -- 128
	self.fx = fx -- 129
	self.events = events -- 130
end -- 123
function EnemySystem.prototype.spawnAll(self, defs, loopIndex) -- 133
	__TS__ArraySetLength(self.enemies, 0) -- 133
	__TS__ArraySetLength(self.pots, 0) -- 133
	__TS__ArraySetLength(self.waves, 0) -- 133
	__TS__ArraySetLength(self.arrows, 0) -- 133
	do -- 133
		local i = 0 -- 138
		while i < #defs do -- 138
			do -- 138
				local d = defs[i + 1] -- 139
				if d.loops ~= nil and __TS__ArrayIndexOf(d.loops, loopIndex) < 0 then -- 139
					goto __continue5 -- 141
				end -- 141
				local w = 36 -- 143
				local h = 76 -- 144
				local hp = 3 -- 145
				if d.kind == "thrower" then -- 145
					w = 34 -- 147
					h = 82 -- 148
					hp = 2 -- 149
				elseif d.kind == "archer" then -- 149
					w = 34 -- 152
					h = 82 -- 153
					hp = 2 -- 154
				elseif d.kind == "boss" then -- 154
					w = 52 -- 156
					h = 112 -- 157
					hp = 16 -- 158
				end -- 158
				local ____self_enemies_0 = self.enemies -- 158
				____self_enemies_0[#____self_enemies_0 + 1] = { -- 160
					def = d, -- 161
					body = { -- 162
						x = d.x, -- 163
						y = d.kind == "archer" and d.y or TOPS[d.floor + 1] + h / 2, -- 168
						vx = 0, -- 169
						vy = 0, -- 170
						w = w, -- 171
						h = h, -- 172
						onGround = false, -- 173
						groundId = "", -- 174
						onLadder = false -- 175
					}, -- 175
					hp = hp, -- 177
					maxHp = hp, -- 178
					facing = d.face ~= nil and d.face or -1, -- 179
					state = "patrol", -- 180
					timer = 0, -- 181
					atkCd = 0, -- 182
					throwCd = 1.2, -- 183
					animTime = math.random() * 6, -- 184
					invuln = 0, -- 185
					phase2 = false, -- 186
					dead = false, -- 187
					deathTimer = 0, -- 188
					hitThisSwing = false, -- 189
					patrolMinCur = d.patrolMin, -- 190
					patrolMaxCur = d.patrolMax, -- 191
					stuckT = 0, -- 192
					stuckX = d.x -- 193
				} -- 193
			end -- 193
			::__continue5:: -- 193
			i = i + 1 -- 138
		end -- 138
	end -- 138
end -- 133
function EnemySystem.prototype.setStealthWired(self, on) -- 200
	self.stealthDriven = on -- 201
	self.backstabEnabled = on -- 202
end -- 200
function EnemySystem.prototype.aliveCount(self) -- 205
	local n = 0 -- 206
	do -- 206
		local i = 0 -- 207
		while i < #self.enemies do -- 207
			if not self.enemies[i + 1].dead then -- 207
				n = n + 1 -- 209
			end -- 209
			i = i + 1 -- 207
		end -- 207
	end -- 207
	return n -- 212
end -- 205
function EnemySystem.prototype.boss(self) -- 215
	do -- 215
		local i = 0 -- 216
		while i < #self.enemies do -- 216
			local e = self.enemies[i + 1] -- 217
			if e.def.kind == "boss" and not e.dead then -- 217
				return e -- 219
			end -- 219
			i = i + 1 -- 216
		end -- 216
	end -- 216
	return nil -- 222
end -- 215
function EnemySystem.prototype.enemyRect(self, e) -- 225
	return {x = e.body.x - e.body.w / 2, y = e.body.y - e.body.h / 2, w = e.body.w, h = e.body.h} -- 226
end -- 225
function EnemySystem.prototype.takeHit(self, rect, damage, dir, kb, attackerX) -- 232
	local hits = 0 -- 233
	do -- 233
		local i = 0 -- 234
		while i < #self.enemies do -- 234
			do -- 234
				local e = self.enemies[i + 1] -- 235
				if e.dead or e.invuln > 0 then -- 235
					goto __continue22 -- 237
				end -- 237
				if not rectOverlap( -- 237
					self:enemyRect(e), -- 239
					rect -- 239
				) then -- 239
					goto __continue22 -- 240
				end -- 240
				hits = hits + 1 -- 242
				local dmg = damage -- 243
				if attackerX ~= nil and self.backstabEnabled and e.def.kind ~= "boss" then -- 243
					local behind = e.facing > 0 and attackerX < e.body.x or e.facing < 0 and attackerX > e.body.x -- 247
					if behind and math.abs(attackerX - e.body.x) < 55 then -- 247
						dmg = e.hp -- 249
						self.fx:spawnInkBurst(e.body.x, e.body.y + 26, dir) -- 250
					end -- 250
				end -- 250
				e.hp = e.hp - dmg -- 253
				e.invuln = 0.18 -- 254
				e.body.vx = dir * kb * (e.def.kind == "boss" and 0.3 or 1) -- 255
				self.fx:spawnInkBurst(e.body.x, e.body.y, dir) -- 256
				self.fx:spawnSpark(e.body.x + dir * -14, e.body.y + 10, dir) -- 257
				if e.hp <= 0 then -- 257
					e.dead = true -- 259
					e.state = "dead" -- 260
					e.deathTimer = 0.55 -- 261
					self.fx:spawnMist(e.body.x, e.body.y - 20, e.def.kind == "boss" and 22 or 12, e.def.kind == "boss" and 1.6 or 1) -- 262
					self.events:onDeath(e.def, e.body.x, e.body.y) -- 263
				elseif e.state ~= "charge" then -- 263
					e.state = "hurt" -- 265
					e.timer = 0.24 -- 266
				end -- 266
				if e.def.kind == "boss" then -- 266
					e.phase2 = e.hp <= e.maxHp / 2 -- 269
				end -- 269
			end -- 269
			::__continue22:: -- 269
			i = i + 1 -- 234
		end -- 234
	end -- 234
	return hits -- 272
end -- 232
function EnemySystem.prototype.consumeHits(self) -- 275
	local out = self.hits -- 276
	self.hits = {} -- 277
	return out -- 278
end -- 275
function EnemySystem.prototype.stealthInfos(self) -- 283
	local out = {} -- 284
	do -- 284
		local i = 0 -- 285
		while i < #self.enemies do -- 285
			local e = self.enemies[i + 1] -- 286
			out[#out + 1] = { -- 287
				index = i, -- 288
				id = e.def.id, -- 289
				kind = e.def.kind, -- 290
				floor = e.def.floor, -- 291
				x = e.body.x, -- 292
				y = e.body.y, -- 293
				w = e.body.w, -- 294
				h = e.body.h, -- 295
				facing = e.facing, -- 296
				state = e.state, -- 297
				patrolMin = e.patrolMinCur, -- 298
				patrolMax = e.patrolMaxCur, -- 299
				basePatrolMin = e.def.patrolMin, -- 300
				basePatrolMax = e.def.patrolMax, -- 301
				dead = e.dead -- 302
			} -- 302
			i = i + 1 -- 285
		end -- 285
	end -- 285
	return out -- 305
end -- 283
function EnemySystem.prototype.setAlert(self, index, lastSeenX) -- 309
	local e = self.enemies[index + 1] -- 310
	if e.dead then -- 310
		return -- 312
	end -- 312
	local min = e.def.patrolMin -- 314
	local max = e.def.patrolMax -- 315
	local width = max - min -- 316
	local center = (min + max) / 2 -- 317
	local nc = center + (lastSeenX - center) * 0.5 -- 318
	local nMin = math.max( -- 319
		min, -- 319
		math.min(nc - width / 2, max - width) -- 319
	) -- 319
	e.patrolMinCur = nMin -- 320
	e.patrolMaxCur = nMin + width -- 321
	if e.state == "patrol" then -- 321
		e.state = "chase" -- 323
	end -- 323
end -- 309
function EnemySystem.prototype.setCalm(self, index) -- 328
	local e = self.enemies[index + 1] -- 329
	if e.dead then -- 329
		return -- 331
	end -- 331
	if e.state == "chase" then -- 331
		e.state = "patrol" -- 334
		e.body.vx = 0 -- 335
	end -- 335
end -- 328
function EnemySystem.prototype.faceToward(self, index, targetX) -- 340
	local e = self.enemies[index + 1] -- 341
	if e.dead or e.state ~= "patrol" then -- 341
		return -- 343
	end -- 343
	e.facing = targetX >= e.body.x and 1 or -1 -- 345
end -- 340
function EnemySystem.prototype.stunNear(self, x, floor, radius, seconds) -- 350
	local n = 0 -- 351
	do -- 351
		local i = 0 -- 352
		while i < #self.enemies do -- 352
			do -- 352
				local e = self.enemies[i + 1] -- 353
				if e.dead or e.def.floor ~= floor or e.def.kind == "boss" then -- 353
					goto __continue44 -- 355
				end -- 355
				if math.abs(e.body.x - x) > radius then -- 355
					goto __continue44 -- 358
				end -- 358
				e.state = "hurt" -- 360
				e.timer = math.max(e.timer, seconds) -- 361
				e.body.vx = 0 -- 362
				e.atkCd = math.max(e.atkCd, 1) -- 363
				n = n + 1 -- 364
			end -- 364
			::__continue44:: -- 364
			i = i + 1 -- 352
		end -- 352
	end -- 352
	return n -- 366
end -- 350
function EnemySystem.prototype.groundAhead(self, e, ctx) -- 369
	local probe = {x = e.body.x + e.facing * (e.body.w / 2 + 4) - 6, y = e.body.y - e.body.h / 2 - 12, w = 12, h = 14} -- 370
	do -- 370
		local i = 0 -- 376
		while i < #ctx.platforms do -- 376
			do -- 376
				local p = ctx.platforms[i + 1] -- 377
				if p.kind == "one-way" then -- 377
					goto __continue49 -- 379
				end -- 379
				if rectOverlap(probe, p) then -- 379
					return true -- 382
				end -- 382
			end -- 382
			::__continue49:: -- 382
			i = i + 1 -- 376
		end -- 376
	end -- 376
	return false -- 385
end -- 369
function EnemySystem.prototype.moveEnemy(self, e, ctx, dt) -- 388
	e.body.vy = clamp(e.body.vy - GRAV * dt, -1150, 1150) -- 389
	local res = moveAndCollide( -- 390
		e.body, -- 390
		ctx.platforms, -- 390
		e.body.vx * dt, -- 390
		e.body.vy * dt, -- 390
		false -- 390
	) -- 390
	local half = e.body.w / 2 + 4 -- 392
	if e.body.x < half then -- 392
		e.body.x = half -- 394
	elseif e.body.x > WORLD_W - half then -- 394
		e.body.x = WORLD_W - half -- 396
	end -- 396
	if e.def.kind ~= "archer" and e.body.y - e.body.h / 2 < TOPS[e.def.floor + 1] - 300 then -- 396
		e.body.x = e.def.x -- 402
		e.body.y = TOPS[e.def.floor + 1] + e.body.h / 2 -- 403
		e.body.vx = 0 -- 404
		e.body.vy = 0 -- 405
		e.body.onGround = true -- 406
		e.state = "patrol" -- 407
	end -- 407
	return res.hitWall -- 409
end -- 388
function EnemySystem.prototype.update(self, dt, px, py, playerRect, playerInvuln, ctx, playerVy) -- 412
	__TS__ArraySetLength(self.hits, 0) -- 412
	do -- 412
		local i = 0 -- 415
		while i < #self.enemies do -- 415
			do -- 415
				local e = self.enemies[i + 1] -- 416
				e.animTime = e.animTime + dt -- 417
				if e.invuln > 0 then -- 417
					e.invuln = e.invuln - dt -- 419
				end -- 419
				if e.dead then -- 419
					e.deathTimer = e.deathTimer - dt -- 422
					goto __continue58 -- 423
				end -- 423
				if e.atkCd > 0 then -- 423
					e.atkCd = e.atkCd - dt -- 426
				end -- 426
				if e.state ~= "patrol" then -- 426
					e.stuckT = 0 -- 430
					e.stuckX = e.body.x -- 431
				end -- 431
				local dx = px - e.body.x -- 433
				local dy = py - e.body.y -- 434
				local adx = math.abs(dx) -- 435
				local elevatedGround = playerVy ~= nil and math.abs(playerVy) < 25 and playerRect.y - (e.body.y - e.body.h / 2) > 110 -- 440
				repeat -- 440
					local ____switch63 = e.state -- 440
					local ____cond63 = ____switch63 == "patrol" -- 440
					if ____cond63 then -- 440
						do -- 440
							if e.def.kind == "archer" then -- 440
								local inSight = not elevatedGround and adx < 460 and math.abs(dy) < 620 -- 450
								local pspd = 62 -- 451
								local vx = 0 -- 452
								if inSight then -- 452
									e.facing = dx > 0 and 1 or -1 -- 454
									if adx > 380 then -- 454
										vx = e.facing * pspd -- 456
									elseif adx < 150 then -- 456
										vx = -e.facing * pspd -- 458
									end -- 458
								elseif e.patrolMaxCur > e.patrolMinCur then -- 458
									if e.body.x < e.patrolMinCur then -- 458
										e.facing = 1 -- 462
									elseif e.body.x > e.patrolMaxCur then -- 462
										e.facing = -1 -- 464
									end -- 464
									vx = e.facing * pspd -- 466
								end -- 466
								e.body.vx = vx -- 468
								local blocked = self:moveEnemy(e, ctx, dt) -- 469
								if vx ~= 0 and e.body.vy > -0.5 and (not self:groundAhead(e, ctx) or blocked) then -- 469
									e.facing = -e.facing -- 471
									e.body.vx = e.facing * pspd -- 472
								end -- 472
								if inSight and e.atkCd <= 0 and adx >= 150 and adx <= 420 then -- 472
									e.state = "telegraph" -- 475
									e.timer = 0.6 -- 476
								end -- 476
								break -- 478
							end -- 478
							if e.def.holdPosition == true then -- 478
								e.body.vx = 0 -- 483
								self:moveEnemy(e, ctx, dt) -- 484
								if not elevatedGround and not self.stealthDriven and adx < 330 and math.abs(dy) < 150 then -- 484
									e.state = "chase" -- 486
								end -- 486
								break -- 488
							end -- 488
							local pspd = e.def.kind == "thrower" and 62 or 88 -- 490
							if e.body.x < e.patrolMinCur then -- 490
								e.facing = 1 -- 494
							elseif e.body.x > e.patrolMaxCur then -- 494
								e.facing = -1 -- 496
							end -- 496
							e.body.vx = e.facing * pspd -- 498
							local blocked = self:moveEnemy(e, ctx, dt) -- 500
							if e.body.vy > -0.5 and (not self:groundAhead(e, ctx) or blocked) then -- 500
								e.facing = -e.facing -- 503
								e.body.vx = e.facing * pspd -- 504
							end -- 504
							if not elevatedGround and (not self.stealthDriven or e.def.kind == "boss") and adx < 330 and math.abs(dy) < 150 then -- 504
								e.state = "chase" -- 511
							end -- 511
							e.stuckT = e.stuckT + dt -- 514
							if e.stuckT > 1.2 then -- 514
								if math.abs(e.body.x - e.stuckX) < 10 then -- 514
									e.facing = -e.facing -- 517
								end -- 517
								e.stuckT = 0 -- 519
								e.stuckX = e.body.x -- 520
							end -- 520
							break -- 522
						end -- 522
					end -- 522
					____cond63 = ____cond63 or ____switch63 == "chase" -- 522
					if ____cond63 then -- 522
						do -- 522
							e.facing = dx > 0 and 1 or -1 -- 525
							if e.def.kind == "archer" then -- 525
								e.body.vx = 0 -- 528
								if not elevatedGround and e.atkCd <= 0 and adx < 460 and math.abs(dy) < 620 then -- 528
									e.state = "telegraph" -- 530
									e.timer = 0.6 -- 531
								end -- 531
								if adx > 560 or math.abs(dy) > 620 or elevatedGround then -- 531
									e.state = "patrol" -- 534
								end -- 534
								self:moveEnemy(e, ctx, dt) -- 536
								break -- 537
							end -- 537
							local spd = e.def.kind == "boss" and 150 or 148 -- 539
							if e.def.kind == "thrower" then -- 539
								if adx < 190 then -- 539
									e.body.vx = -e.facing * 110 -- 543
								else -- 543
									e.body.vx = 0 -- 545
								end -- 545
								e.throwCd = e.throwCd - dt -- 547
								if e.throwCd <= 0 and adx < 430 and math.abs(dy) < 190 then -- 547
									e.state = "throw" -- 549
									e.timer = 0.4 -- 550
								end -- 550
							else -- 550
								if adx < 14 then -- 550
									e.body.vx = 0 -- 555
								else -- 555
									e.body.vx = e.facing * spd -- 557
								end -- 557
								if not self:groundAhead(e, ctx) and e.body.onGround then -- 557
									e.body.vx = 0 -- 560
								end -- 560
								if e.def.lunge == true and e.atkCd <= 0 and adx > 120 and adx < 420 and math.abs(dy) < 120 then -- 560
									e.state = "telegraph" -- 570
									e.timer = 0.42 -- 571
									e.hitThisSwing = false -- 572
									e.body.vx = 0 -- 573
								end -- 573
								local range = e.def.kind == "boss" and 96 or 58 -- 575
								if adx < range and math.abs(dy) < 90 and e.atkCd <= 0 then -- 575
									e.state = "windup" -- 577
									e.timer = e.def.kind == "boss" and (e.phase2 and 0.42 or 0.55) or 0.45 -- 578
									e.hitThisSwing = false -- 579
								end -- 579
								if e.def.kind == "boss" and e.atkCd <= 0 and adx > 280 and adx < 620 then -- 579
									e.state = "telegraph" -- 582
									e.timer = e.phase2 and 0.38 or 0.5 -- 583
								end -- 583
							end -- 583
							if adx > 560 or math.abs(dy) > 260 or elevatedGround then -- 583
								e.state = "patrol" -- 587
							end -- 587
							self:moveEnemy(e, ctx, dt) -- 589
							break -- 590
						end -- 590
					end -- 590
					____cond63 = ____cond63 or ____switch63 == "windup" -- 590
					if ____cond63 then -- 590
						do -- 590
							e.body.vx = 0 -- 593
							e.facing = dx > 0 and 1 or -1 -- 594
							e.timer = e.timer - dt -- 595
							self:moveEnemy(e, ctx, dt) -- 596
							if e.timer <= 0 then -- 596
								e.state = "swing" -- 598
								e.timer = 0.16 -- 599
								local reach = e.def.kind == "boss" and 92 or 56 -- 600
								local hh = e.def.kind == "boss" and 78 or 50 -- 601
								local ____self_hits_1 = self.hits -- 601
								____self_hits_1[#____self_hits_1 + 1] = { -- 602
									x = e.facing > 0 and e.body.x or e.body.x - reach, -- 603
									y = e.body.y - hh / 2, -- 604
									w = reach, -- 605
									h = hh, -- 606
									damage = e.def.kind == "boss" and 1.5 or 1, -- 607
									kind = "slash" -- 608
								} -- 608
								self.fx:spawnInkBurst(e.body.x + e.facing * reach * 0.6, e.body.y + 6, e.facing) -- 610
							end -- 610
							break -- 612
						end -- 612
					end -- 612
					____cond63 = ____cond63 or ____switch63 == "swing" -- 612
					if ____cond63 then -- 612
						do -- 612
							e.body.vx = e.facing * 40 -- 615
							e.timer = e.timer - dt -- 616
							self:moveEnemy(e, ctx, dt) -- 617
							if e.timer <= 0 then -- 617
								if e.def.kind == "boss" then -- 617
									local ____self_waves_2 = self.waves -- 617
									____self_waves_2[#____self_waves_2 + 1] = {x = e.body.x + e.facing * 50, y = e.body.y - e.body.h / 2 + 20, dir = e.facing, life = 1.5} -- 621
									e.atkCd = e.phase2 and 0.9 or 1.4 -- 622
								else -- 622
									e.atkCd = 0.85 -- 624
								end -- 624
								e.state = "recover" -- 626
								e.timer = e.def.kind == "boss" and 0.3 or 0.42 -- 627
							end -- 627
							break -- 629
						end -- 629
					end -- 629
					____cond63 = ____cond63 or ____switch63 == "recover" -- 629
					if ____cond63 then -- 629
						do -- 629
							e.body.vx = 0 -- 632
							e.timer = e.timer - dt -- 633
							self:moveEnemy(e, ctx, dt) -- 634
							if e.timer <= 0 then -- 634
								e.state = "chase" -- 636
							end -- 636
							break -- 638
						end -- 638
					end -- 638
					____cond63 = ____cond63 or ____switch63 == "telegraph" -- 638
					if ____cond63 then -- 638
						do -- 638
							e.body.vx = 0 -- 641
							e.facing = dx > 0 and 1 or -1 -- 642
							e.timer = e.timer - dt -- 643
							self:moveEnemy(e, ctx, dt) -- 644
							if e.timer <= 0 then -- 644
								if e.def.kind == "archer" then -- 644
									local sp = 520 -- 648
									local tx = px - e.body.x -- 649
									local ty = py + 12 - e.body.y -- 650
									local lenRaw = math.sqrt(tx * tx + ty * ty) -- 651
									local len = lenRaw > 0.0001 and lenRaw or 1 -- 652
									local ____self_arrows_3 = self.arrows -- 652
									____self_arrows_3[#____self_arrows_3 + 1] = { -- 653
										x = e.body.x + e.facing * 18, -- 654
										y = e.body.y + 26, -- 655
										vx = tx / len * sp, -- 656
										vy = ty / len * sp, -- 657
										alive = true, -- 658
										life = 2.2 -- 659
									} -- 659
									e.atkCd = 1.7 -- 661
									e.state = "recover" -- 662
									e.timer = 0.36 -- 663
								else -- 663
									e.state = "charge" -- 665
									e.timer = 0.7 -- 666
									e.hitThisSwing = false -- 667
								end -- 667
							end -- 667
							break -- 670
						end -- 670
					end -- 670
					____cond63 = ____cond63 or ____switch63 == "charge" -- 670
					if ____cond63 then -- 670
						do -- 670
							e.body.vx = e.facing * (e.phase2 and 520 or 460) -- 673
							e.timer = e.timer - dt -- 674
							local blocked = self:moveEnemy(e, ctx, dt) -- 675
							if blocked then -- 675
								e.timer = 0 -- 677
								self.fx:spawnDust(e.body.x, e.body.y - e.body.h / 2, -e.facing) -- 678
							end -- 678
							if not e.hitThisSwing and rectOverlap( -- 678
								self:enemyRect(e), -- 680
								playerRect -- 680
							) then -- 680
								e.hitThisSwing = true -- 681
								if not playerInvuln then -- 681
									self.events:onPlayerHit(1, e.body.x) -- 683
								end -- 683
							end -- 683
							if e.timer <= 0 then -- 683
								e.body.vx = 0 -- 687
								e.atkCd = e.phase2 and 1.1 or 1.8 -- 688
								e.state = "recover" -- 689
								e.timer = 0.4 -- 690
							end -- 690
							break -- 692
						end -- 692
					end -- 692
					____cond63 = ____cond63 or ____switch63 == "throw" -- 692
					if ____cond63 then -- 692
						do -- 692
							e.body.vx = 0 -- 695
							e.facing = dx > 0 and 1 or -1 -- 696
							e.timer = e.timer - dt -- 697
							self:moveEnemy(e, ctx, dt) -- 698
							if e.timer <= 0 then -- 698
								local t = 0.85 -- 700
								local vx = (px - e.body.x) / t -- 701
								local vy = (py - e.body.y + 0.5 * 1400 * t * t) / t -- 702
								local ____self_pots_4 = self.pots -- 702
								____self_pots_4[#____self_pots_4 + 1] = { -- 703
									x = e.body.x + e.facing * 18, -- 703
									y = e.body.y + 20, -- 703
									vx = vx, -- 703
									vy = vy, -- 703
									alive = true, -- 703
									life = 3 -- 703
								} -- 703
								e.throwCd = 2.1 + math.random() * 0.8 -- 704
								e.state = "recover" -- 705
								e.timer = 0.5 -- 706
							end -- 706
							break -- 708
						end -- 708
					end -- 708
					____cond63 = ____cond63 or ____switch63 == "hurt" -- 708
					if ____cond63 then -- 708
						do -- 708
							e.timer = e.timer - dt -- 711
							self:moveEnemy(e, ctx, dt) -- 712
							if e.timer <= 0 then -- 712
								e.state = self.stealthDriven and "patrol" or "chase" -- 716
							end -- 716
							break -- 718
						end -- 718
					end -- 718
					do -- 718
						break -- 721
					end -- 721
				until true -- 721
			end -- 721
			::__continue58:: -- 721
			i = i + 1 -- 415
		end -- 415
	end -- 415
	do -- 415
		local i = 0 -- 726
		while i < #self.pots do -- 726
			do -- 726
				local p = self.pots[i + 1] -- 727
				if not p.alive then -- 727
					goto __continue120 -- 729
				end -- 729
				p.life = p.life - dt -- 731
				p.vy = p.vy - 1400 * dt -- 732
				p.x = p.x + p.vx * dt -- 733
				p.y = p.y + p.vy * dt -- 734
				local pr = {x = p.x - 8, y = p.y - 8, w = 16, h = 16} -- 735
				local hitPlat = false -- 736
				do -- 736
					local k = 0 -- 737
					while k < #ctx.platforms do -- 737
						do -- 737
							local plat = ctx.platforms[k + 1] -- 738
							if plat.kind == "one-way" then -- 738
								goto __continue123 -- 740
							end -- 740
							if rectOverlap(pr, plat) then -- 740
								hitPlat = true -- 743
								break -- 744
							end -- 744
						end -- 744
						::__continue123:: -- 744
						k = k + 1 -- 737
					end -- 737
				end -- 737
				if hitPlat or p.life <= 0 then -- 737
					p.alive = false -- 748
					self.fx:spawnInkBurst(p.x, p.y, p.vx > 0 and 1 or -1) -- 749
					self.events:onPoof(p.x, p.y) -- 750
					goto __continue120 -- 751
				end -- 751
				if rectOverlap(pr, playerRect) and not playerInvuln then -- 751
					p.alive = false -- 754
					self.events:onPlayerHit(1, p.x) -- 755
				end -- 755
			end -- 755
			::__continue120:: -- 755
			i = i + 1 -- 726
		end -- 726
	end -- 726
	local w = 0 -- 759
	do -- 759
		local i = 0 -- 760
		while i < #self.pots do -- 760
			if self.pots[i + 1].alive then -- 760
				self.pots[w + 1] = self.pots[i + 1] -- 762
				w = w + 1 -- 763
			end -- 763
			i = i + 1 -- 760
		end -- 760
	end -- 760
	__TS__ArraySetLength(self.pots, w) -- 760
	do -- 760
		local i = 0 -- 769
		while i < #self.arrows do -- 769
			do -- 769
				local ar = self.arrows[i + 1] -- 770
				if not ar.alive then -- 770
					goto __continue132 -- 772
				end -- 772
				ar.life = ar.life - dt -- 774
				ar.x = ar.x + ar.vx * dt -- 775
				ar.y = ar.y + ar.vy * dt -- 776
				local arr = {x = ar.x - 10, y = ar.y - 3, w = 20, h = 6} -- 777
				local hitPlat2 = false -- 778
				do -- 778
					local k = 0 -- 779
					while k < #ctx.platforms do -- 779
						do -- 779
							local plat2 = ctx.platforms[k + 1] -- 780
							if plat2.kind == "one-way" then -- 780
								goto __continue135 -- 782
							end -- 782
							if rectOverlap(arr, plat2) then -- 782
								hitPlat2 = true -- 785
								break -- 786
							end -- 786
						end -- 786
						::__continue135:: -- 786
						k = k + 1 -- 779
					end -- 779
				end -- 779
				if hitPlat2 or ar.life <= 0 then -- 779
					ar.alive = false -- 790
					self.fx:spawnSpark(ar.x, ar.y, ar.vx > 0 and 1 or -1) -- 791
					goto __continue132 -- 792
				end -- 792
				if rectOverlap(arr, playerRect) and not playerInvuln then -- 792
					ar.alive = false -- 795
					self.events:onPlayerHit(1, ar.x) -- 796
				end -- 796
			end -- 796
			::__continue132:: -- 796
			i = i + 1 -- 769
		end -- 769
	end -- 769
	local an = 0 -- 799
	do -- 799
		local i = 0 -- 800
		while i < #self.arrows do -- 800
			if self.arrows[i + 1].alive then -- 800
				self.arrows[an + 1] = self.arrows[i + 1] -- 802
				an = an + 1 -- 803
			end -- 803
			i = i + 1 -- 800
		end -- 800
	end -- 800
	__TS__ArraySetLength(self.arrows, an) -- 800
	do -- 800
		local i = 0 -- 809
		while i < #self.waves do -- 809
			local wv = self.waves[i + 1] -- 810
			wv.life = wv.life - dt -- 811
			wv.x = wv.x + wv.dir * 270 * dt -- 812
			local wr = {x = wv.x - 14, y = wv.y - 18, w = 28, h = 40} -- 813
			if rectOverlap(wr, playerRect) and not playerInvuln then -- 813
				self.events:onPlayerHit(1, wv.x) -- 815
				wv.life = 0 -- 816
			end -- 816
			i = i + 1 -- 809
		end -- 809
	end -- 809
	local wv2 = 0 -- 819
	do -- 819
		local i = 0 -- 820
		while i < #self.waves do -- 820
			if self.waves[i + 1].life > 0 then -- 820
				self.waves[wv2 + 1] = self.waves[i + 1] -- 822
				wv2 = wv2 + 1 -- 823
			end -- 823
			i = i + 1 -- 820
		end -- 820
	end -- 820
	__TS__ArraySetLength(self.waves, wv2) -- 820
	do -- 820
		local i = 0 -- 829
		while i < #self.hits do -- 829
			local h = self.hits[i + 1] -- 830
			if rectOverlap(h, playerRect) and not playerInvuln then -- 830
				self.events:onPlayerHit(h.damage, h.x + h.w / 2) -- 832
			end -- 832
			i = i + 1 -- 829
		end -- 829
	end -- 829
end -- 412
return ____exports -- 412