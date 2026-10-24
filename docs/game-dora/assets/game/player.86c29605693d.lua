-- [ts]: player.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____physics = require("game.physics") -- 2
local moveAndCollide = ____physics.moveAndCollide -- 2
local ladderAt = ____physics.ladderAt -- 2
local climbWallAt = ____physics.climbWallAt -- 2
local clamp = ____physics.clamp -- 2
local rectOverlap = ____physics.rectOverlap -- 2
local updateGroundState = ____physics.updateGroundState -- 2
local ____audio = require("game.audio") -- 4
local sfx = ____audio.sfx -- 4
____exports.PlayerTuning = { -- 50
	runSpeed = 320, -- 51
	accel = 2800, -- 52
	decel = 2400, -- 53
	airControl = 0.7, -- 54
	gravity = 2300, -- 55
	maxFall = 1150, -- 56
	wallSlideFall = 170, -- 57
	climbSpeed = 150, -- 58
	jumpV = 900, -- 59
	doubleJumpV = 820, -- 60
	wallJumpVx = 440, -- 61
	wallJumpVy = 900, -- 62
	wallJumpLock = 0.16, -- 63
	coyote = 0.1, -- 64
	jumpBuffer = 0.12, -- 65
	dashSpeed = 870, -- 66
	dashTime = 0.15, -- 67
	dashCd = 0.55, -- 68
	dashIFrame = 0.25, -- 69
	attackTime = {0.3, 0.3, 0.34, 0.42}, -- 70
	attackActiveFrom = {0.07, 0.07, 0.08, 0.14}, -- 71
	attackActiveTo = {0.2, 0.2, 0.24, 0.34}, -- 72
	attackChainWindow = 0.34, -- 73
	hurtStun = 0.32, -- 74
	hurtInvuln = 1.1, -- 75
	hurtKb = 300, -- 76
	hurtKbUp = 380 -- 77
} -- 77
____exports.Player = __TS__Class() -- 80
local Player = ____exports.Player -- 80
Player.name = "Player" -- 80
function Player.prototype.____constructor(self, x, y) -- 111
	self.body = { -- 112
		x = x, -- 113
		y = y, -- 114
		vx = 0, -- 115
		vy = 0, -- 116
		w = 32, -- 117
		h = 82, -- 118
		onGround = true, -- 119
		groundId = "", -- 120
		onLadder = false -- 121
	} -- 121
	self.facing = 1 -- 123
	self.anim = "idle" -- 124
	self.animTime = 0 -- 125
	self.climbT = 0 -- 126
	self.attackIndex = 0 -- 127
	self.attackTimer = 0 -- 128
	self.attackQueued = false -- 129
	self.attackSeq = 0 -- 130
	self.dashTimer = 0 -- 131
	self.dashCd = 0 -- 132
	self.dashDir = 1 -- 133
	self.invuln = 0 -- 134
	self.stunTimer = 0 -- 135
	self.freezeTimer = 0 -- 136
	self.coyoteTimer = 0 -- 137
	self.jumpBufTimer = 0 -- 138
	self.lockTimer = 0 -- 139
	self.clinging = false -- 140
	self.wallDir = 0 -- 141
	self.onLadder = false -- 142
	self.ladderId = "" -- 143
	self.jumpCount = 0 -- 144
	self.detachTimer = 0 -- 145
	self.attack = nil -- 146
	self.qiReq = nil -- 147
	self.landing = false -- 148
	self.wallJustAttached = false -- 149
	self.intentCost = 1 -- 150
end -- 111
function Player.prototype.respawn(self, x, y) -- 153
	self.body.x = x -- 154
	self.body.y = y -- 155
	self.body.vx = 0 -- 156
	self.body.vy = 0 -- 157
	self.body.onGround = true -- 158
	self.body.groundId = "" -- 159
	self.onLadder = false -- 160
	self.clinging = false -- 161
	self.dashTimer = 0 -- 162
	self.attackTimer = 0 -- 163
	self.attack = nil -- 164
	self.stunTimer = 0 -- 165
	self.freezeTimer = 0 -- 166
	self.invuln = 1.2 -- 167
	self.anim = "idle" -- 168
end -- 153
function Player.prototype.hurt(self, damage, fromX) -- 172
	if self.invuln > 0 or self.dashTimer > 0 or self.stunTimer > 0 then -- 172
		return false -- 174
	end -- 174
	local dir = self.body.x >= fromX and 1 or -1 -- 176
	self.body.vx = dir * ____exports.PlayerTuning.hurtKb -- 177
	self.body.vy = ____exports.PlayerTuning.hurtKbUp -- 178
	self.stunTimer = ____exports.PlayerTuning.hurtStun -- 179
	self.invuln = ____exports.PlayerTuning.hurtInvuln -- 180
	self.clinging = false -- 181
	self.onLadder = false -- 182
	self.attackTimer = 0 -- 183
	self.attack = nil -- 184
	self.anim = "hurt" -- 185
	self.animTime = 0 -- 186
	return damage > 0 -- 187
end -- 172
function Player.prototype.isInvulnerable(self) -- 191
	return self.invuln > 0 or self.dashTimer > 0 -- 192
end -- 191
function Player.prototype.center(self) -- 195
	return {x = self.body.x, y = self.body.y} -- 196
end -- 195
function Player.prototype.feetY(self) -- 199
	return self.body.y - self.body.h / 2 -- 200
end -- 199
function Player.prototype.update(self, dt, input, ctx) -- 203
	if self.freezeTimer > 0 then -- 203
		self.freezeTimer = self.freezeTimer - dt -- 206
		self.attack = nil -- 207
		self.qiReq = nil -- 208
		return -- 209
	end -- 209
	self.animTime = self.animTime + dt -- 211
	if self.invuln > 0 then -- 211
		self.invuln = self.invuln - dt -- 213
	end -- 213
	if self.dashCd > 0 then -- 213
		self.dashCd = self.dashCd - dt -- 216
	end -- 216
	if self.lockTimer > 0 then -- 216
		self.lockTimer = self.lockTimer - dt -- 219
	end -- 219
	if self.detachTimer > 0 then -- 219
		self.detachTimer = self.detachTimer - dt -- 222
	end -- 222
	self.attack = nil -- 224
	self.qiReq = nil -- 225
	self.landing = false -- 226
	self.wallJustAttached = false -- 227
	local b = self.body -- 229
	if self.stunTimer > 0 then -- 229
		self.stunTimer = self.stunTimer - dt -- 233
		b.vy = clamp(b.vy - ____exports.PlayerTuning.gravity * dt, -____exports.PlayerTuning.maxFall, ____exports.PlayerTuning.maxFall) -- 234
		moveAndCollide( -- 235
			b, -- 235
			ctx.platforms, -- 235
			b.vx * dt, -- 235
			b.vy * dt, -- 235
			false -- 235
		) -- 235
		return -- 236
	end -- 236
	if self.attackTimer > 0 then -- 236
		self:updateAttack(dt, ctx) -- 241
	end -- 241
	local ladder = ladderAt(b, ctx.ladders) -- 245
	local wantLadder = input.up or input.down -- 246
	if self.onLadder then -- 246
		if ladder == nil then -- 246
			self.onLadder = false -- 251
		else -- 251
			b.vx = 0 -- 253
			b.vy = 0 -- 254
			local vy = 0 -- 255
			if input.up then -- 255
				vy = ____exports.PlayerTuning.climbSpeed -- 257
			elseif input.down then -- 257
				vy = -____exports.PlayerTuning.climbSpeed -- 259
			end -- 259
			b.vy = vy -- 261
			local vx = 0 -- 262
			if input.left then -- 262
				vx = -90 -- 264
			elseif input.right then -- 264
				vx = 90 -- 266
			end -- 266
			b.vx = vx -- 268
			local res = moveAndCollide( -- 269
				b, -- 269
				ctx.platforms, -- 269
				vx * dt, -- 269
				vy * dt, -- 269
				false -- 269
			) -- 269
			if vy ~= 0 or vx ~= 0 then -- 269
				self.climbT = self.climbT + dt -- 271
			end -- 271
			self.anim = "climb" -- 273
			self.ladderId = ladder.id -- 274
			if input.jumpPressed or res.landed and vy < 0 then -- 274
				self.onLadder = false -- 276
				if input.jumpPressed then -- 276
					b.vy = ____exports.PlayerTuning.jumpV * 0.85 -- 278
					self.jumpCount = 1 -- 279
					sfx("jump1", 0.7) -- 280
				end -- 280
			end -- 280
			if self.attackTimer > 0 then -- 280
				self.onLadder = false -- 284
			end -- 284
			if input.dashPressed and self.dashCd <= 0 then -- 284
				self.onLadder = false -- 287
				self:startDash() -- 288
			end -- 288
			return -- 290
		end -- 290
	end -- 290
	if not self.onLadder and ladder ~= nil and wantLadder and not self.clinging and self.dashTimer <= 0 then -- 290
		self.onLadder = true -- 296
		b.vx = 0 -- 297
		b.vy = 0 -- 298
		self.ladderId = ladder.id -- 299
		self.jumpCount = 0 -- 300
		return -- 301
	end -- 301
	if input.dashPressed and self.dashCd <= 0 and self.dashTimer <= 0 then -- 301
		self:startDash() -- 306
	end -- 306
	if input.jumpPressed then -- 306
		self.jumpBufTimer = ____exports.PlayerTuning.jumpBuffer -- 311
	end -- 311
	if self.jumpBufTimer > 0 then -- 311
		self.jumpBufTimer = self.jumpBufTimer - dt -- 314
	end -- 314
	if b.onGround then -- 314
		self.coyoteTimer = ____exports.PlayerTuning.coyote -- 317
		self.jumpCount = 0 -- 318
	elseif self.coyoteTimer > 0 then -- 318
		self.coyoteTimer = self.coyoteTimer - dt -- 320
	end -- 320
	local dirInput = (input.left and -1 or 0) + (input.right and 1 or 0) -- 324
	local awayFromWall = self.clinging and self.wallDir ~= 0 and dirInput == -self.wallDir or self.clinging and self.wallDir == 0 -- 325
	if awayFromWall then -- 325
		self.detachTimer = 0.12 -- 329
		self.clinging = false -- 330
	end -- 330
	if self.detachTimer <= 0 and self.dashTimer <= 0 and self.attackTimer <= 0 then -- 330
		if not b.onGround and b.vy < 260 and not self.clinging and self.wallDir ~= 0 and self.lockTimer <= 0 then -- 330
			local marker = climbWallAt(b, self.wallDir, ctx.climbWalls) -- 334
			if marker ~= nil then -- 334
				self.clinging = true -- 336
				self.wallJustAttached = true -- 337
				self.jumpCount = 0 -- 338
				b.vy = math.min(b.vy, 0) -- 339
			end -- 339
		end -- 339
	end -- 339
	if self.clinging and b.onGround then -- 339
		self.clinging = false -- 344
	end -- 344
	if self.clinging and self.wallDir ~= 0 then -- 344
		self.facing = self.wallDir -- 348
	end -- 348
	local targetVx = 0 -- 352
	if self.lockTimer <= 0 and self.dashTimer <= 0 and self.attackTimer <= 0 then -- 352
		targetVx = dirInput * ____exports.PlayerTuning.runSpeed -- 354
		if dirInput ~= 0 and self.attackTimer <= 0 and not self.clinging then -- 354
			self.facing = dirInput -- 356
		end -- 356
	end -- 356
	if self.dashTimer > 0 then -- 356
		targetVx = self.dashDir * ____exports.PlayerTuning.dashSpeed -- 360
	end -- 360
	local control = (b.onGround or self.clinging) and 1 or ____exports.PlayerTuning.airControl -- 362
	if targetVx > b.vx then -- 362
		b.vx = math.min(targetVx, b.vx + ____exports.PlayerTuning.accel * control * dt) -- 364
	elseif targetVx < b.vx then -- 364
		b.vx = math.max(targetVx, b.vx - ____exports.PlayerTuning.decel * control * dt) -- 366
	end -- 366
	if self.dashTimer > 0 then -- 366
		self.dashTimer = self.dashTimer - dt -- 371
		b.vy = 0 -- 372
	elseif self.clinging then -- 372
		local slide = true -- 374
		if input.up then -- 374
			b.vy = ____exports.PlayerTuning.climbSpeed -- 377
			slide = false -- 378
		elseif input.down then -- 378
			b.vy = -____exports.PlayerTuning.climbSpeed * 1.4 -- 380
			slide = false -- 381
		else -- 381
			b.vy = math.max(b.vy - ____exports.PlayerTuning.gravity * dt * 0.25, -____exports.PlayerTuning.wallSlideFall) -- 383
		end -- 383
		local marker = climbWallAt(b, self.wallDir, ctx.climbWalls) -- 386
		if marker == nil and b.vy > 0 then -- 386
			self.clinging = false -- 388
		end -- 388
		local ____ = slide -- 388
	else -- 388
		b.vy = clamp(b.vy - ____exports.PlayerTuning.gravity * dt, -____exports.PlayerTuning.maxFall, ____exports.PlayerTuning.maxFall) -- 392
	end -- 392
	if self.jumpBufTimer > 0 and self.dashTimer <= 0 and self.attackTimer <= 0 then -- 392
		if self.clinging and self.wallDir ~= 0 then -- 392
			local away = -self.wallDir -- 399
			b.vx = away * ____exports.PlayerTuning.wallJumpVx -- 400
			b.vy = ____exports.PlayerTuning.wallJumpVy -- 401
			self.facing = away -- 402
			self.lockTimer = ____exports.PlayerTuning.wallJumpLock -- 403
			self.clinging = false -- 404
			self.jumpBufTimer = 0 -- 405
			self.jumpCount = 1 -- 406
			self.wallJustAttached = false -- 407
			sfx("jump1", 0.6) -- 408
		elseif b.onGround or self.coyoteTimer > 0 then -- 408
			b.vy = ____exports.PlayerTuning.jumpV -- 410
			b.onGround = false -- 411
			self.coyoteTimer = 0 -- 412
			self.jumpBufTimer = 0 -- 413
			self.jumpCount = 1 -- 414
			sfx("jump1", 0.7) -- 415
		elseif self.jumpCount < 2 then -- 415
			b.vy = ____exports.PlayerTuning.doubleJumpV -- 417
			self.jumpCount = 2 -- 418
			self.jumpBufTimer = 0 -- 419
			sfx("jump2", 0.7) -- 420
		end -- 420
	end -- 420
	local dropThrough = input.down and input.jumpPressed -- 425
	local wasAir = not b.onGround -- 427
	local res = moveAndCollide( -- 428
		b, -- 428
		ctx.platforms, -- 428
		b.vx * dt, -- 428
		b.vy * dt, -- 428
		dropThrough -- 428
	) -- 428
	updateGroundState(b, ctx.platforms) -- 430
	if res.hitWall then -- 430
		self.wallDir = res.wallDir -- 432
	elseif b.onGround or self.clinging == false then -- 432
		self.wallDir = 0 -- 435
	end -- 435
	if res.landed then -- 435
		self.landing = true -- 438
		if self.anim ~= "land" then -- 438
			self.anim = "land" -- 440
			self.animTime = 0 -- 441
		end -- 441
	end -- 441
	if input.attackPressed and self.dashTimer <= 0 then -- 441
		if self.attackTimer <= 0 then -- 441
			if self:attackChainCd() <= 0 or true then -- 441
				self:startAttack(0, false) -- 449
			end -- 449
		else -- 449
			self.attackQueued = true -- 452
		end -- 452
		if self.clinging then -- 452
			self.clinging = false -- 455
		end -- 455
		self.onLadder = false -- 457
	end -- 457
	if input.qiPressed and self.dashTimer <= 0 and self.attackTimer <= 0 then -- 457
		self.qiReq = {x = b.x + self.facing * 20, y = b.y + 18, dir = self.facing} -- 462
		self:startAttack(3, true) -- 464
	end -- 464
	if self.attackTimer > 0 then -- 464
		self.anim = "attack" -- 469
	elseif self.dashTimer > 0 then -- 469
		self.anim = "dash" -- 471
	elseif self.clinging then -- 471
		self.anim = "wallslide" -- 473
	elseif not b.onGround then -- 473
		self.anim = b.vy > 40 and "jump" or "fall" -- 475
	elseif self.stunTimer > 0 then -- 475
		self.anim = "hurt" -- 477
	elseif self.anim == "land" and self.animTime < 0.14 then -- 477
	elseif math.abs(b.vx) > 30 then -- 477
		self.anim = "run" -- 481
	else -- 481
		self.anim = "idle" -- 483
	end -- 483
	local ____ = wasAir -- 483
end -- 203
function Player.prototype.attackChainCd(self) -- 488
	return 0 -- 489
end -- 488
function Player.prototype.startDash(self) -- 492
	sfx("dash", 0.8) -- 493
	self.dashTimer = ____exports.PlayerTuning.dashTime -- 494
	self.dashCd = ____exports.PlayerTuning.dashCd -- 495
	self.dashDir = self.facing -- 496
	self.clinging = false -- 497
	self.onLadder = false -- 498
end -- 492
function Player.prototype.startAttack(self, index, silent) -- 501
	if not silent then -- 501
		sfx("sword", 0.9) -- 503
	end -- 503
	self.attackIndex = index -- 505
	self.attackSeq = self.attackSeq + 1 -- 506
	self.attackTimer = ____exports.PlayerTuning.attackTime[index + 1] -- 507
	self.anim = "attack" -- 508
	self.animTime = 0 -- 509
end -- 501
function Player.prototype.updateAttack(self, dt, ctx) -- 512
	self.attackTimer = self.attackTimer - dt -- 513
	local idx = self.attackIndex -- 514
	local from = ____exports.PlayerTuning.attackActiveFrom[idx + 1] -- 515
	local to = ____exports.PlayerTuning.attackActiveTo[idx + 1] -- 516
	local elapsed = ____exports.PlayerTuning.attackTime[idx + 1] - self.attackTimer -- 517
	if elapsed >= from and elapsed <= to then -- 517
		local reach = idx == 3 and 84 or (idx == 2 and 70 or 60) -- 520
		local height = idx == 3 and 72 or (idx == 2 and 64 or 54) -- 521
		self.attack = { -- 522
			hitbox = {x = self.facing > 0 and self.body.x or self.body.x - reach, y = self.body.y - height / 2 + 6, w = reach, h = height}, -- 523
			index = idx, -- 529
			dir = self.facing, -- 530
			damage = idx >= 2 and 2 or 1, -- 531
			kb = idx == 3 and 430 or (idx == 2 and 380 or 240) -- 532
		} -- 532
	end -- 532
	if self.attackTimer <= 0 then -- 532
		if self.attackQueued then -- 532
			self.attackQueued = false -- 537
			local next = idx >= 3 and 0 or (idx + 1) % 3 -- 539
			self:startAttack(next, false) -- 540
		end -- 540
	end -- 540
	local ____ = ctx -- 540
end -- 512
function Player.prototype.attackJustActivated(self) -- 547
	return self.attack ~= nil and self.animTime >= ____exports.PlayerTuning.attackActiveFrom[self.attackIndex + 1] -- 548
end -- 547
function Player.prototype.overlapRect(self, r) -- 551
	return rectOverlap({x = self.body.x - self.body.w / 2, y = self.body.y - self.body.h / 2, w = self.body.w, h = self.body.h}, r) -- 552
end -- 551
return ____exports -- 551