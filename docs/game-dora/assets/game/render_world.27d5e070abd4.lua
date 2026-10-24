-- [ts]: render_world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 4
local Color = ____Dora.Color -- 4
local DrawNode = ____Dora.DrawNode -- 4
local Label = ____Dora.Label -- 4
local Node = ____Dora.Node -- 4
local Rect = ____Dora.Rect -- 4
local Sprite = ____Dora.Sprite -- 4
local Texture2D = ____Dora.Texture2D -- 4
local Vec2 = ____Dora.Vec2 -- 4
local View = ____Dora.View -- 4
local ____palette = require("core.palette") -- 5
local Palette = ____palette.Palette -- 5
local ink = ____palette.ink -- 5
local ____render_chars = require("game.render_chars") -- 29
local arc = ____render_chars.arc -- 30
local circle = ____render_chars.circle -- 31
local col = ____render_chars.col -- 32
local dot = ____render_chars.dot -- 33
local drawEnemy = ____render_chars.drawEnemy -- 34
local drawHero = ____render_chars.drawHero -- 35
local drawObserver = ____render_chars.drawObserver -- 36
local drawPot = ____render_chars.drawPot -- 37
local drawShenYan = ____render_chars.drawShenYan -- 38
local drawWave = ____render_chars.drawWave -- 39
local seg = ____render_chars.seg -- 40
local ____hero_frames = require("game.hero_frames") -- 43
local HeroFrameSet = ____hero_frames.HeroFrameSet -- 43
local HERO_FRAMES_FACE_RIGHT = ____hero_frames.HERO_FRAMES_FACE_RIGHT -- 43
local ____ninja_render = require("game.ninja_render") -- 44
local NinjaLayer = ____ninja_render.NinjaLayer -- 44
local ____decor_light = require("game.decor_light") -- 45
local LightDecor = ____decor_light.LightDecor -- 45
local ____stealth = require("game.stealth") -- 48
local HIDE_SPOTS = ____stealth.HIDE_SPOTS -- 48
local GHOST_TINT_R = 154 -- 52
local GHOST_TINT_G = 215 -- 53
local GHOST_TINT_B = 232 -- 54
local GHOST_ALPHA = 0.7 -- 55
local GHOST_DUR = 0.3 -- 56
local GHOST_INTERVAL = 0.04 -- 57
local GHOST_OFFSET = 12 -- 58
local GHOST_MAX = 8 -- 59
local CULL = 900 -- 126
____exports.CAM_ZOOM = 1.5 -- 128
local GOLD = ink(212, 168, 84, 255) -- 129
local CYAN = ink(108, 156, 148, 255) -- 130
local PAPER_DIM = ink(219, 208, 184, 120) -- 131
local TILE = 64 -- 164
local TILE_SETS = { -- 165
	"autumn", -- 165
	"autumn", -- 165
	"skyruins", -- 165
	"skyruins", -- 165
	"skyruins", -- 165
	"skyruins", -- 165
	"skyruins" -- 165
} -- 165
local FLOOR_TOPS = { -- 169
	220, -- 169
	1500, -- 169
	2800, -- 169
	4100, -- 169
	5400, -- 169
	6700, -- 169
	8000 -- 169
} -- 169
local BG_AUTUMN = {{path = "assets/bg/autumn_layer0.png", f = 0.12, baseUp = 0}, {path = "assets/bg/autumn_layer1.png", f = 0.26, baseUp = 0}} -- 179
local BG_SKYRUINS = {{path = "assets/bg/skyruins_layer0.png", f = 0.12, baseUp = 0}, {path = "assets/bg/skyruins_layer1.png", f = 0.26, baseUp = 0}} -- 183
local BG_RIVERSIDE = { -- 188
	{path = "assets/bg/river_sky.png", f = 0.06, baseUp = 0}, -- 189
	{path = "assets/bg/river_clouds1.png", f = 0.12, baseUp = 0}, -- 190
	{path = "assets/bg/river_clouds2.png", f = 0.18, baseUp = 0}, -- 191
	{path = "assets/bg/river_rocks.png", f = 0.28, baseUp = 0}, -- 192
	{path = "assets/bg/river_ground.png", f = 0.36, baseUp = 0} -- 193
} -- 193
local BG_TOWERSIDE = { -- 196
	{path = "assets/bg/dusk/sky.png", f = 0.05, baseUp = 0}, -- 197
	{path = "assets/bg/dusk/far_clouds.png", f = 0.1, baseUp = 0}, -- 198
	{path = "assets/bg/dusk/far_mountains.png", f = 0.16, baseUp = 0}, -- 199
	{path = "assets/bg/dusk/mountains.png", f = 0.24, baseUp = 0}, -- 200
	{path = "assets/bg/dusk/near_clouds.png", f = 0.3, baseUp = 0}, -- 201
	{path = "assets/bg/dusk/trees.png", f = 0.38, baseUp = 0} -- 202
} -- 202
local BG_MOONNIGHT = {{path = "assets/bg/moon_far.png", f = 0.08, baseUp = 0}, {path = "assets/bg/moon_mid.png", f = 0.18, baseUp = 0}, {path = "assets/bg/moon_big.png", f = 0.3, baseUp = 0}} -- 205
local BG_LAYERS = { -- 210
	BG_AUTUMN, -- 211
	BG_RIVERSIDE, -- 212
	BG_SKYRUINS, -- 213
	BG_TOWERSIDE, -- 214
	{}, -- 215
	BG_SKYRUINS, -- 216
	BG_MOONNIGHT -- 217
} -- 217
local function styleAllowsDecor(style, path) -- 225
	if style == "skyruins" then -- 225
		return path == "assets/tiles/skyruins_magicstone.png" or path == "assets/tiles/skyruins_portal.png" -- 227
	end -- 227
	return false -- 229
end -- 225
local function waveY(wx, time, i) -- 232
	return math.sin(wx * 0.018 + time * 1.7 + i * 2.1) * 2.6 + math.sin(wx * 0.006 - time * 0.8 + i) * 1.6 -- 233
end -- 232
____exports.WorldRenderer = __TS__Class() -- 236
local WorldRenderer = ____exports.WorldRenderer -- 236
WorldRenderer.name = "WorldRenderer" -- 236
function WorldRenderer.prototype.____constructor(self, parent, data) -- 315
	self.bgRecs = {} -- 252
	self.activeFloor = 0 -- 256
	self.sceneFloorHolders = {} -- 257
	self.decorFloorHolders = {} -- 258
	self.propSpriteFloorHolders = {} -- 259
	self.bgBands = {} -- 260
	self.tileGroups = {} -- 261
	self.promptW = 0 -- 267
	self.promptH = 0 -- 268
	self.promptText = "" -- 269
	self.promptX = 0 -- 270
	self.promptY = 0 -- 271
	self.promptShown = false -- 273
	self.promptPopT = 0 -- 274
	self.promptHideT = 0 -- 275
	self.promptAnimT = 0 -- 276
	self.promptRelayoutT = 0 -- 277
	self.heroTexOk = false -- 282
	self.heroScale = 0.065 -- 283
	self.ghosts = {} -- 287
	self.ghostCd = 0 -- 288
	self.pixelBgOk = false -- 292
	self.activeBand = -1 -- 293
	self.sceneBand = 0 -- 294
	self.portalNodes = {} -- 295
	self.stoneSprites = {} -- 300
	self.bossWaveSprites = {} -- 303
	self.bossWaveChecked = false -- 305
	self.lampStoneSprites = {} -- 306
	self.moonStoneSprites = {} -- 307
	self.dewSprites = {} -- 308
	self.tokenSprites = {} -- 309
	self.flagSets = {} -- 310
	self.texCache = {} -- 311
	self.puzzleBuilt = false -- 833
	self.barrelT = 0 -- 834
	self.barrelLeft = false -- 835
	self.data = data -- 316
	self.parent = parent -- 317
	self.camX = 0 -- 318
	self.camY = 0 -- 319
	self.vw = View.size.width -- 320
	self.vh = View.size.height -- 321
	self.shenYan = nil -- 322
	self.observer = nil -- 323
	self.stars = {} -- 324
	do -- 324
		local i = 0 -- 325
		while i < 42 do -- 325
			local ____self_stars_0 = self.stars -- 325
			____self_stars_0[#____self_stars_0 + 1] = {x = i * 617 % 2600, y = 60 + i * 149 % 330, s = 0.5 + i * 37 % 10 / 14} -- 326
			i = i + 1 -- 325
		end -- 325
	end -- 325
	self.gateParts = {} -- 332
	local byId = {} -- 333
	for ____, p in ipairs(data.platforms) do -- 334
		if p.kind == "gate" and p.gateId ~= nil then -- 334
			local list = byId[p.gateId] -- 336
			if list == nil then -- 336
				byId[p.gateId] = {p} -- 338
			else -- 338
				list[#list + 1] = p -- 340
			end -- 340
		end -- 340
	end -- 340
	for ____, g in ipairs(data.gates) do -- 344
		local ____self_gateParts_1 = self.gateParts -- 344
		____self_gateParts_1[#____self_gateParts_1 + 1] = {gid = g.id, rects = byId[g.id] == nil and ({}) or byId[g.id]} -- 345
	end -- 345
	self.bgSpriteRoot = Node() -- 347
	self.bgSpriteRoot:addTo(parent) -- 348
	self.bgDraw = DrawNode() -- 349
	self.bgDraw:addTo(parent) -- 350
	self.worldRoot = Node() -- 351
	self.worldRoot:addTo(parent) -- 352
	self.platformDraw = DrawNode() -- 353
	self.platformDraw:addTo(self.worldRoot) -- 354
	self.propDraw = DrawNode() -- 355
	self.propDraw:addTo(self.worldRoot) -- 356
	self.scenePropsRoot = Node() -- 358
	self.scenePropsRoot:addTo(self.worldRoot) -- 359
	self.propSpriteRoot = Node() -- 361
	self.propSpriteRoot:addTo(self.worldRoot) -- 362
	self.portalLayer = Node() -- 364
	self.portalLayer:addTo(self.worldRoot) -- 365
	self.waveSpriteRoot = Node() -- 366
	self.waveSpriteRoot:addTo(self.worldRoot) -- 367
	self.charDraw = DrawNode() -- 368
	self.charDraw:addTo(self.worldRoot) -- 369
	self.ninjaRoot = Node() -- 371
	self.ninjaRoot:addTo(self.worldRoot) -- 372
	self.ninja = __TS__New(NinjaLayer, self.ninjaRoot) -- 373
	local heroTex = self:loadTex("assets/characters/衍月.png") -- 375
	if heroTex ~= nil then -- 375
		local sp = Sprite(heroTex) -- 377
		sp.anchor = Vec2(0.5, 0) -- 378
		self.heroScale = 90 / heroTex.height -- 379
		sp.scaleX = self.heroScale -- 380
		sp.scaleY = self.heroScale -- 381
		sp:addTo(self.worldRoot) -- 382
		self.heroSprite = sp -- 383
		self.heroTexOk = true -- 384
	end -- 384
	self.ghostRoot = Node() -- 387
	self.ghostRoot:addTo(self.worldRoot) -- 388
	self.heroFrames = __TS__New(HeroFrameSet, self.worldRoot) -- 389
	self.heroFxDraw = DrawNode() -- 390
	self.heroFxDraw:addTo(self.worldRoot) -- 391
	self.decorNode = Node() -- 392
	self.decorNode:addTo(self.worldRoot) -- 393
	self.lightDecor = __TS__New(LightDecor, self.decorNode) -- 394
	self.promptNode = Node() -- 396
	self.promptNode:addTo(self.worldRoot) -- 397
	self.promptNode.visible = false -- 398
	self.promptDraw = DrawNode() -- 399
	self.promptDraw:addTo(self.promptNode) -- 400
	self.promptDraw.visible = true -- 401
	self.promptNode.passOpacity = true -- 402
	self.promptNode:schedule(function(dt) -- 404
		self:updatePromptAnim(dt) -- 405
		return false -- 406
	end) -- 404
	self:buildPixelBackgrounds() -- 408
	self:buildPixelTerrain() -- 409
	self:buildPixelDecor() -- 410
	self:buildSceneProps() -- 411
	self:buildPortals() -- 412
	self:buildLightDecor() -- 413
	self:buildPropSprites() -- 414
end -- 315
function WorldRenderer.prototype.setPrompt(self, x, y, text) -- 419
	if text == nil then -- 419
		if self.promptShown then -- 419
			self.promptShown = false -- 422
			self.promptHideT = 0.1 -- 423
		end -- 423
		return -- 425
	end -- 425
	if self.promptShown and text == self.promptText and x == self.promptX and y == self.promptY then -- 425
		return -- 428
	end -- 428
	local fresh = not self.promptShown -- 430
	self.promptText = text -- 431
	self.promptX = x -- 432
	self.promptY = y -- 433
	if fresh then -- 433
		self.promptShown = true -- 435
		self.promptPopT = 0.15 -- 436
		self.promptHideT = 0 -- 437
		self.promptAnimT = 0 -- 438
		self.promptNode.visible = true -- 439
		self.promptNode.opacity = 1 -- 440
		self.promptNode.scaleX = 0.9 -- 441
		self.promptNode.scaleY = 0.9 -- 442
	end -- 442
	self:redrawPrompt() -- 444
	self:applyPromptPosition(0) -- 445
	self.promptRelayoutT = 0.12 -- 446
end -- 419
function WorldRenderer.prototype.applyPromptPosition(self, bob) -- 450
	local w = self.promptW -- 451
	local h = self.promptH -- 452
	local px = self.promptX -- 453
	local py = self.promptY + h / 2 + 14 -- 454
	local minX = self.camX - self.vw / (2 * ____exports.CAM_ZOOM) + w / 2 + 8 -- 455
	local maxX = self.camX + self.vw / (2 * ____exports.CAM_ZOOM) - w / 2 - 8 -- 456
	local minY = self.camY - self.vh / (2 * ____exports.CAM_ZOOM) + h / 2 + 8 -- 457
	local maxY = self.camY + self.vh / (2 * ____exports.CAM_ZOOM) - h / 2 - 8 -- 458
	if maxX > minX then -- 458
		px = math.max( -- 460
			minX, -- 460
			math.min(maxX, px) -- 460
		) -- 460
	end -- 460
	if maxY > minY then -- 460
		py = math.max( -- 463
			minY, -- 463
			math.min(maxY, py) -- 463
		) -- 463
	end -- 463
	self.promptNode.position = Vec2(px, py + bob) -- 465
end -- 450
function WorldRenderer.prototype.updatePromptAnim(self, dt) -- 469
	if not self.promptNode.visible then -- 469
		return -- 471
	end -- 471
	if self.promptShown then -- 471
		if self.promptRelayoutT > 0 then -- 471
			self.promptRelayoutT = self.promptRelayoutT - dt -- 475
			self:redrawPrompt() -- 476
		end -- 476
		self.promptAnimT = self.promptAnimT + dt -- 478
		if self.promptPopT > 0 then -- 478
			self.promptPopT = math.max(0, self.promptPopT - dt) -- 480
			local t = 1 - self.promptPopT / 0.15 -- 481
			local e = 1 - (1 - t) * (1 - t) -- 482
			local s = 0.9 + 0.1 * e -- 483
			self.promptNode.scaleX = s -- 484
			self.promptNode.scaleY = s -- 485
		else -- 485
			self.promptNode.scaleX = 1 -- 487
			self.promptNode.scaleY = 1 -- 488
		end -- 488
		local bob = 3 * math.sin(math.pi * self.promptAnimT) -- 490
		self:applyPromptPosition(bob) -- 491
		self.promptNode.opacity = 1 -- 492
	else -- 492
		self.promptHideT = self.promptHideT - dt -- 494
		if self.promptHideT <= 0 then -- 494
			self.promptHideT = 0 -- 496
			self.promptNode.visible = false -- 497
			self.promptNode.opacity = 1 -- 498
		else -- 498
			self.promptNode.opacity = self.promptHideT / 0.1 -- 500
		end -- 500
	end -- 500
end -- 469
function WorldRenderer.prototype.makePromptLabel(self, size) -- 505
	local lb = Label("assets/font/DialogFont.ttf", size) -- 506
	if lb ~= nil then -- 506
		return lb -- 508
	end -- 508
	return Label("sarasa-mono-sc-regular", size) -- 510
end -- 505
function WorldRenderer.prototype.redrawPrompt(self) -- 513
	local draw = self.promptDraw -- 515
	draw:clear() -- 516
	draw.visible = false -- 517
	if self.promptLbMain == nil then -- 517
		self.promptLbMain = self:makePromptLabel(21) -- 519
		if self.promptLbMain ~= nil then -- 519
			self.promptLbMain.anchor = Vec2(0.5, 0.5) -- 521
			self.promptLbMain.color = Color(255, 255, 255, 255) -- 522
			self.promptLbMain:addTo(self.promptNode) -- 523
		end -- 523
	end -- 523
	local main = self.promptLbMain -- 526
	if main == nil then -- 526
		return -- 528
	end -- 528
	main.visible = true -- 531
	main.color = Color(255, 255, 255, 255) -- 532
	main.alignment = "Center" -- 533
	main.text = self.promptText -- 534
	main.width = Label.AutomaticWidth -- 535
	main.position = Vec2(0, 0) -- 536
	local textW = main.width -- 537
	local textH = main.height > 0 and main.height or 24 -- 538
	local maxTextW = 280 -- 539
	if textW + 2 > maxTextW then -- 539
		local rows = math.ceil((textW + 2) / maxTextW) -- 541
		main.width = maxTextW -- 542
		textW = maxTextW -- 543
		textH = math.max(main.height, textH * rows) -- 544
	end -- 544
	self.promptW = textW -- 546
	self.promptH = textH -- 547
end -- 513
function WorldRenderer.prototype.buildLightDecor(self) -- 552
	local lightFloors = {3, 4, 5} -- 554
	local lanternFloors = {{top = FLOOR_TOPS[4], cx = 1000}, {top = FLOOR_TOPS[5], cx = 1200}, {top = FLOOR_TOPS[6], cx = 1700}} -- 555
	local lanternSpots = {} -- 560
	for ____, lf in ipairs(lanternFloors) do -- 561
		lanternSpots[#lanternSpots + 1] = {x = lf.cx - 350, y = lf.top + 240} -- 562
		lanternSpots[#lanternSpots + 1] = {x = lf.cx, y = lf.top + 240} -- 563
		lanternSpots[#lanternSpots + 1] = {x = lf.cx + 350, y = lf.top + 240} -- 564
	end -- 564
	self.lightDecor:addLanterns(lanternSpots) -- 566
	local torchSpots = {} -- 567
	for ____, rec in ipairs(self.portalNodes) do -- 568
		do -- 568
			local sanctioned = false -- 569
			for ____, lf in ipairs(lightFloors) do -- 570
				if lf == rec.floor then -- 570
					sanctioned = true -- 572
					break -- 573
				end -- 573
			end -- 573
			if not sanctioned then -- 573
				goto __continue44 -- 577
			end -- 577
			local top = rec.floor >= 0 and rec.floor < #FLOOR_TOPS and FLOOR_TOPS[rec.floor + 1] or 220 -- 579
			torchSpots[#torchSpots + 1] = {x = rec.x - 90, y = top} -- 580
			torchSpots[#torchSpots + 1] = {x = rec.x + 90, y = top} -- 581
		end -- 581
		::__continue44:: -- 581
	end -- 581
	self.lightDecor:addTorches(torchSpots) -- 583
end -- 552
function WorldRenderer.prototype.loadTex(self, path) -- 586
	local hit = self.texCache[path] -- 587
	if hit ~= nil then -- 587
		return hit -- 589
	end -- 589
	local tex = Texture2D(path) -- 591
	if tex == nil then -- 591
		return nil -- 593
	end -- 593
	self.texCache[path] = tex -- 595
	return tex -- 596
end -- 586
function WorldRenderer.prototype.setWorldVisible(self, v) -- 600
	self.bgSpriteRoot.visible = v -- 601
	self.worldRoot.visible = v -- 602
end -- 600
function WorldRenderer.prototype.debugPixelStats(self) -- 606
	return (((((((("bgRecs=" .. tostring(#self.bgRecs)) .. " bands=") .. tostring(#self.bgBands)) .. " tiles=") .. tostring(#self.tileGroups)) .. " pixelOk=") .. tostring(self.pixelBgOk)) .. " band=") .. tostring(self.activeBand) -- 607
end -- 606
function WorldRenderer.prototype.buildPixelBackgrounds(self) -- 610
	local vw = View.size.width -- 611
	local vh = View.size.height -- 612
	do -- 612
		local band = 0 -- 613
		while band < #BG_LAYERS do -- 613
			local bandNode = Node() -- 614
			bandNode:addTo(self.bgSpriteRoot) -- 615
			bandNode.visible = false -- 616
			local top = FLOOR_TOPS[band + 1] -- 617
			local ____self_bgBands_2 = self.bgBands -- 617
			____self_bgBands_2[#____self_bgBands_2 + 1] = {node = bandNode, floorTop = top} -- 618
			for ____, layer in ipairs(BG_LAYERS[band + 1]) do -- 619
				do -- 619
					local tex = self:loadTex(layer.path) -- 620
					if tex == nil then -- 620
						goto __continue58 -- 622
					end -- 622
					self.pixelBgOk = true -- 624
					local s = math.max(vw / tex.width, (vh + 40) / tex.height) -- 625
					local spanW = tex.width * s -- 626
					local copies = math.ceil(vw / spanW) + 2 -- 627
					do -- 627
						local j = 0 -- 628
						while j < copies do -- 628
							do -- 628
								local sp = Sprite(tex) -- 629
								if sp == nil then -- 629
									goto __continue61 -- 631
								end -- 631
								sp.anchor = Vec2(0, 0) -- 633
								sp.scaleX = s -- 634
								sp.scaleY = s -- 635
								sp.filter = "Point" -- 636
								sp:addTo(bandNode) -- 637
								local ____self_bgRecs_3 = self.bgRecs -- 637
								____self_bgRecs_3[#____self_bgRecs_3 + 1] = { -- 638
									node = sp, -- 639
									band = band, -- 640
									f = layer.f, -- 641
									spanW = spanW, -- 642
									imgH = tex.height * s, -- 643
									baseUp = layer.baseUp, -- 644
									copyIndex = j -- 645
								} -- 645
							end -- 645
							::__continue61:: -- 645
							j = j + 1 -- 628
						end -- 628
					end -- 628
				end -- 628
				::__continue58:: -- 628
			end -- 628
			band = band + 1 -- 613
		end -- 613
	end -- 613
end -- 610
function WorldRenderer.prototype.tileSprite(self, band, tex, x, y, cropW, cropH) -- 652
	local sp = Sprite( -- 653
		tex, -- 653
		Rect(0, 0, cropW, cropH) -- 653
	) -- 653
	if sp == nil then -- 653
		return -- 655
	end -- 655
	sp.anchor = Vec2(0, 0) -- 657
	sp.scaleX = 0.5 -- 658
	sp.scaleY = 0.5 -- 659
	sp.filter = "Point" -- 660
	sp.position = Vec2(x, y) -- 661
	sp:addTo(band) -- 662
end -- 652
function WorldRenderer.prototype.buildPixelTerrain(self) -- 665
	for ____, p in ipairs(self.data.platforms) do -- 666
		do -- 666
			if p.kind ~= "solid" or p.mover ~= nil or p.w < 300 then -- 666
				goto __continue67 -- 668
			end -- 668
			local key = TILE_SETS[p.floor + 1] -- 670
			local topTex = self:loadTex(("assets/tiles/" .. key) .. "_top.png") -- 671
			local fillTex = self:loadTex(("assets/tiles/" .. key) .. "_fill.png") -- 672
			if topTex == nil then -- 672
				goto __continue67 -- 674
			end -- 674
			local node = Node() -- 676
			node:addTo(self.worldRoot) -- 677
			local topY = p.y + p.h -- 678
			local cols = math.ceil(p.w / TILE) -- 679
			local rows = math.max( -- 680
				1, -- 680
				math.ceil(p.h / TILE) -- 680
			) -- 680
			local remW = p.w - (cols - 1) * TILE -- 681
			do -- 681
				local c = 0 -- 682
				while c < cols do -- 682
					local cw = c == cols - 1 and remW * 2 or 128 -- 683
					self:tileSprite( -- 684
						node, -- 684
						topTex, -- 684
						p.x + c * TILE, -- 684
						topY - TILE, -- 684
						cw, -- 684
						128 -- 684
					) -- 684
					c = c + 1 -- 682
				end -- 682
			end -- 682
			do -- 682
				local r = 1 -- 686
				while r < rows do -- 686
					if fillTex == nil then -- 686
						break -- 688
					end -- 688
					local fy = topY - TILE * (r + 1) -- 690
					local fh = r == rows - 1 and (topY - p.y - TILE * rows) * 2 or 128 -- 691
					if fh <= 0 then -- 691
						break -- 693
					end -- 693
					do -- 693
						local c = 0 -- 695
						while c < cols do -- 695
							local cw = c == cols - 1 and remW * 2 or 128 -- 696
							self:tileSprite( -- 697
								node, -- 697
								fillTex, -- 697
								p.x + c * TILE, -- 697
								fy, -- 697
								cw, -- 697
								fh -- 697
							) -- 697
							c = c + 1 -- 695
						end -- 695
					end -- 695
					r = r + 1 -- 686
				end -- 686
			end -- 686
			local ____self_tileGroups_4 = self.tileGroups -- 686
			____self_tileGroups_4[#____self_tileGroups_4 + 1] = { -- 700
				node = node, -- 700
				x0 = p.x, -- 700
				y0 = p.y, -- 700
				x1 = p.x + p.w, -- 700
				y1 = topY, -- 700
				floor = p.floor -- 700
			} -- 700
		end -- 700
		::__continue67:: -- 700
	end -- 700
	for ____, p in ipairs(self.data.platforms) do -- 704
		do -- 704
			if p.id ~= "wallL" and p.id ~= "wallR" then -- 704
				goto __continue79 -- 706
			end -- 706
			local fillTex = self:loadTex(("assets/tiles/" .. TILE_SETS[p.floor + 1]) .. "_fill.png") -- 708
			if fillTex == nil then -- 708
				goto __continue79 -- 710
			end -- 710
			local node = Node() -- 712
			node:addTo(self.worldRoot) -- 713
			local rows = math.ceil(p.h / TILE) -- 714
			do -- 714
				local r = 0 -- 715
				while r < rows do -- 715
					local rh = r == rows - 1 and (p.h - (rows - 1) * TILE) * 2 or 128 -- 716
					if rh <= 0 then -- 716
						break -- 718
					end -- 718
					self:tileSprite( -- 720
						node, -- 720
						fillTex, -- 720
						p.x, -- 720
						p.y + p.h - (r + 1) * TILE, -- 720
						160, -- 720
						rh -- 720
					) -- 720
					r = r + 1 -- 715
				end -- 715
			end -- 715
			local ____self_tileGroups_5 = self.tileGroups -- 715
			____self_tileGroups_5[#____self_tileGroups_5 + 1] = { -- 723
				node = node, -- 723
				x0 = p.x, -- 723
				y0 = p.y, -- 723
				x1 = p.x + p.w, -- 723
				y1 = p.y + p.h, -- 723
				floor = -1 -- 723
			} -- 723
		end -- 723
		::__continue79:: -- 723
	end -- 723
	for ____, hz in ipairs(self.data.hazards) do -- 726
		do -- 726
			local key = TILE_SETS[hz.floor + 1] -- 727
			local spikeTex = self:loadTex(("assets/tiles/" .. key) .. "_spike.png") -- 728
			if spikeTex == nil then -- 728
				goto __continue86 -- 730
			end -- 730
			local node = Node() -- 732
			node:addTo(self.worldRoot) -- 733
			local cols = math.ceil(hz.w / TILE) -- 734
			do -- 734
				local c = 0 -- 735
				while c < cols do -- 735
					self:tileSprite( -- 736
						node, -- 736
						spikeTex, -- 736
						hz.x + c * TILE, -- 736
						hz.y + 4, -- 736
						128, -- 736
						64 -- 736
					) -- 736
					c = c + 1 -- 735
				end -- 735
			end -- 735
			local ____self_tileGroups_6 = self.tileGroups -- 735
			____self_tileGroups_6[#____self_tileGroups_6 + 1] = { -- 738
				node = node, -- 738
				x0 = hz.x, -- 738
				y0 = hz.y, -- 738
				x1 = hz.x + hz.w, -- 738
				y1 = hz.y + hz.h, -- 738
				floor = hz.floor -- 738
			} -- 738
		end -- 738
		::__continue86:: -- 738
	end -- 738
	for ____, l in ipairs(self.data.ladders) do -- 741
		do -- 741
			local key = TILE_SETS[l.floor + 1] -- 742
			local tex = self:loadTex(("assets/tiles/" .. key) .. "_ladder.png") -- 743
			if tex == nil then -- 743
				goto __continue91 -- 745
			end -- 745
			local node = Node() -- 747
			node:addTo(self.worldRoot) -- 748
			local rows = math.ceil(l.h / TILE) -- 749
			do -- 749
				local r = 0 -- 750
				while r < rows do -- 750
					local rh = r == rows - 1 and (l.h - (rows - 1) * TILE) * 2 or 128 -- 751
					if rh <= 0 then -- 751
						break -- 753
					end -- 753
					self:tileSprite( -- 755
						node, -- 755
						tex, -- 755
						l.x, -- 755
						l.y + l.h - (r + 1) * TILE, -- 755
						92, -- 755
						rh -- 755
					) -- 755
					r = r + 1 -- 750
				end -- 750
			end -- 750
			local ____self_tileGroups_7 = self.tileGroups -- 750
			____self_tileGroups_7[#____self_tileGroups_7 + 1] = { -- 757
				node = node, -- 757
				x0 = l.x, -- 757
				y0 = l.y, -- 757
				x1 = l.x + l.w, -- 757
				y1 = l.y + l.h, -- 757
				floor = l.floor -- 757
			} -- 757
		end -- 757
		::__continue91:: -- 757
	end -- 757
	for ____, p in ipairs(self.data.platforms) do -- 760
		do -- 760
			if p.kind ~= "one-way" then -- 760
				goto __continue97 -- 762
			end -- 762
			local key = TILE_SETS[p.floor + 1] -- 764
			local tex = self:loadTex(("assets/tiles/" .. key) .. "_brick.png") -- 765
			if tex == nil then -- 765
				goto __continue97 -- 767
			end -- 767
			local node = Node() -- 769
			node:addTo(self.worldRoot) -- 770
			local cols = math.ceil(p.w / TILE) -- 771
			do -- 771
				local c = 0 -- 772
				while c < cols do -- 772
					local cw = c == cols - 1 and (p.w - (cols - 1) * TILE) * 2 or 128 -- 773
					if cw <= 0 then -- 773
						break -- 775
					end -- 775
					self:tileSprite( -- 777
						node, -- 777
						tex, -- 777
						p.x + c * TILE, -- 777
						p.y, -- 777
						cw, -- 777
						36 -- 777
					) -- 777
					c = c + 1 -- 772
				end -- 772
			end -- 772
			local ____self_tileGroups_8 = self.tileGroups -- 772
			____self_tileGroups_8[#____self_tileGroups_8 + 1] = { -- 779
				node = node, -- 779
				x0 = p.x, -- 779
				y0 = p.y, -- 779
				x1 = p.x + p.w, -- 779
				y1 = p.y + p.h, -- 779
				floor = p.floor -- 779
			} -- 779
		end -- 779
		::__continue97:: -- 779
	end -- 779
end -- 665
function WorldRenderer.prototype.buildPixelDecor(self) -- 783
	local decor = { -- 787
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 1300, y = FLOOR_TOPS[4]}, -- 789
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 600, y = FLOOR_TOPS[4]}, -- 792
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 1900, y = FLOOR_TOPS[4]}, -- 793
		{path = "assets/tiles/skyruins_magicstone.png", floor = 6, x = 700, y = FLOOR_TOPS[7]}, -- 794
		{path = "assets/tiles/skyruins_magicstone.png", floor = 6, x = 1900, y = FLOOR_TOPS[7]} -- 795
	} -- 795
	for ____, d in ipairs(decor) do -- 797
		do -- 797
			if not styleAllowsDecor(TILE_SETS[d.floor + 1], d.path) then -- 797
				goto __continue105 -- 799
			end -- 799
			local tex = self:loadTex(d.path) -- 801
			if tex == nil then -- 801
				goto __continue105 -- 803
			end -- 803
			local sp = Sprite(tex) -- 805
			if sp == nil then -- 805
				goto __continue105 -- 807
			end -- 807
			sp.anchor = Vec2(0.5, 0) -- 809
			sp.scaleX = 0.5 -- 810
			sp.scaleY = 0.5 -- 811
			sp.filter = "Point" -- 812
			sp.position = Vec2(d.x, d.y) -- 813
			sp:addTo(self:floorHolderIn(self.decorNode, self.decorFloorHolders, d.floor)) -- 814
		end -- 814
		::__continue105:: -- 814
	end -- 814
end -- 783
function WorldRenderer.prototype.makePropSprite(self, path, x, y, boxW, boxH, fit) -- 838
	local tex = self:loadTex(path) -- 839
	if tex == nil then -- 839
		return nil -- 841
	end -- 841
	local sp = Sprite(tex) -- 843
	if sp == nil then -- 843
		return nil -- 845
	end -- 845
	local sW = boxW / tex.width -- 847
	local sH = boxH / tex.height -- 848
	local s = fit == "w" and sW or (fit == "h" and sH or math.min(sW, sH)) -- 849
	sp.anchor = Vec2(0.5, 0) -- 850
	sp.scaleX = s -- 851
	sp.scaleY = s -- 852
	sp.filter = "Point" -- 853
	sp.position = Vec2(x, y) -- 854
	sp:addTo(self:floorHolderIn( -- 855
		self.scenePropsRoot, -- 855
		self.sceneFloorHolders, -- 855
		self:floorOfY(y) -- 855
	)) -- 855
	return sp -- 856
end -- 838
function WorldRenderer.prototype.ensurePuzzleProps(self) -- 859
	if self.puzzleBuilt then -- 859
		return -- 861
	end -- 861
	self.puzzleBuilt = true -- 863
	self.treeSapling = self:makePropSprite( -- 864
		"assets/props/a2_sapling.png", -- 864
		700, -- 864
		FLOOR_TOPS[1], -- 864
		150, -- 864
		120, -- 864
		"min" -- 864
	) -- 864
	self.treePit = self:makePropSprite( -- 865
		"assets/props/a1_pit.png", -- 865
		1200, -- 865
		FLOOR_TOPS[1], -- 865
		150, -- 865
		26, -- 865
		"min" -- 865
	) -- 865
	self.treeMain = self:makePropSprite( -- 867
		"assets/props/a3_tree.png", -- 867
		1200, -- 867
		FLOOR_TOPS[1], -- 867
		260, -- 867
		200, -- 867
		"min" -- 867
	) -- 867
	self.treeMirror = self:makePropSprite( -- 868
		"assets/props/a3_tree.png", -- 868
		700, -- 868
		FLOOR_TOPS[1], -- 868
		210, -- 868
		162, -- 868
		"min" -- 868
	) -- 868
	self.stumpMain = self:makePropSprite( -- 869
		"assets/props/a4_stump.png", -- 869
		1200, -- 869
		FLOOR_TOPS[1], -- 869
		110, -- 869
		80, -- 869
		"min" -- 869
	) -- 869
	self.stumpMirror = self:makePropSprite( -- 870
		"assets/props/a4_stump.png", -- 870
		700, -- 870
		FLOOR_TOPS[1], -- 870
		110, -- 870
		80, -- 870
		"min" -- 870
	) -- 870
	self.barrelSp = self:makePropSprite( -- 871
		"assets/props/b6_barrel.png", -- 871
		1900, -- 871
		FLOOR_TOPS[2], -- 871
		92, -- 871
		84, -- 871
		"min" -- 871
	) -- 871
	local ladder = DrawNode() -- 872
	ladder:addTo(self.scenePropsRoot) -- 873
	local rail = Color(122, 88, 58, 255) -- 875
	local rung = Color(150, 112, 74, 255) -- 876
	ladder:drawSegment( -- 877
		Vec2(1160, FLOOR_TOPS[1]), -- 877
		Vec2(1160, FLOOR_TOPS[1] + 560), -- 877
		4, -- 877
		rail -- 877
	) -- 877
	ladder:drawSegment( -- 878
		Vec2(1200, FLOOR_TOPS[1]), -- 878
		Vec2(1200, FLOOR_TOPS[1] + 560), -- 878
		4, -- 878
		rail -- 878
	) -- 878
	do -- 878
		local y = FLOOR_TOPS[1] + 40 -- 879
		while y <= FLOOR_TOPS[1] + 540 do -- 879
			ladder:drawSegment( -- 880
				Vec2(1160, y), -- 880
				Vec2(1200, y), -- 880
				3, -- 880
				rung -- 880
			) -- 880
			y = y + 56 -- 879
		end -- 879
	end -- 879
	ladder.visible = false -- 882
	self.treeLadderDraw = ladder -- 883
end -- 859
function WorldRenderer.prototype.setVisible(self, sp, on) -- 886
	if sp ~= nil then -- 886
		sp.visible = on -- 888
	end -- 888
end -- 886
function WorldRenderer.prototype.syncTreePuzzle(self, flags) -- 893
	self:ensurePuzzleProps() -- 894
	local planted = flags.treePlanted == true -- 895
	local cut = flags.treeCut == true -- 896
	local taken = flags.saplingTaken == true -- 897
	self:setVisible(self.treeSapling, not planted and not cut and not taken) -- 898
	self:setVisible(self.treePit, not planted) -- 899
	self:setVisible(self.treeMain, planted and not cut) -- 900
	self:setVisible(self.treeMirror, planted and not cut) -- 901
	self:setVisible(self.stumpMain, cut) -- 902
	self:setVisible(self.stumpMirror, cut) -- 903
	if self.treeLadderDraw ~= nil then -- 903
		self.treeLadderDraw.visible = planted and not cut and self.activeFloor == 0 -- 905
	end -- 905
end -- 893
function WorldRenderer.prototype.syncBarrel(self, dt, down, left) -- 910
	self:ensurePuzzleProps() -- 911
	if self.barrelSp == nil then -- 911
		return -- 913
	end -- 913
	if not down then -- 913
		self.barrelT = 0 -- 916
		self.barrelSp.angle = 0 -- 917
		self.barrelSp.position = Vec2(1900, FLOOR_TOPS[2]) -- 918
		return -- 919
	end -- 919
	if self.barrelLeft ~= left then -- 919
		self.barrelLeft = left -- 922
		self.barrelT = 0 -- 923
	end -- 923
	if self.barrelT < 1 then -- 923
		self.barrelT = math.min(1, self.barrelT + dt * 3) -- 926
		local e = 1 - (1 - self.barrelT) * (1 - self.barrelT) -- 927
		self.barrelSp.angle = (left and -1 or 1) * 90 * e -- 928
		self.barrelSp.position = Vec2(1900 + (left and -1 or 1) * 40 * e, FLOOR_TOPS[2] + 6 * e) -- 929
	end -- 929
end -- 910
function WorldRenderer.prototype.getWorldRoot(self) -- 934
	return self.worldRoot -- 935
end -- 934
function WorldRenderer.prototype.buildSceneProps(self) -- 938
	local defs = { -- 939
		{ -- 941
			path = "assets/props/a3_tree.png", -- 941
			x = 2000, -- 941
			y = FLOOR_TOPS[1], -- 941
			w = 340, -- 941
			h = 220, -- 941
			fit = "min" -- 941
		}, -- 941
		{ -- 942
			path = "assets/props/a5_well.png", -- 942
			x = 860, -- 942
			y = FLOOR_TOPS[1], -- 942
			w = 150, -- 942
			h = 110, -- 942
			fit = "min" -- 942
		}, -- 942
		{ -- 944
			path = "assets/props/a4_stump.png", -- 944
			x = 1550, -- 944
			y = FLOOR_TOPS[1], -- 944
			w = 110, -- 944
			h = 80, -- 944
			fit = "min" -- 944
		}, -- 944
		{ -- 945
			path = "assets/props/a6_bucket.png", -- 945
			x = 1650, -- 945
			y = FLOOR_TOPS[1], -- 945
			w = 56, -- 945
			h = 42, -- 945
			fit = "min" -- 945
		}, -- 945
		{ -- 949
			path = "assets/decor/lantern_1.png", -- 949
			x = 980, -- 949
			y = FLOOR_TOPS[2], -- 949
			w = 42, -- 949
			h = 74, -- 949
			fit = "h" -- 949
		}, -- 949
		{ -- 950
			path = "assets/decor/lantern_1.png", -- 950
			x = 2150, -- 950
			y = FLOOR_TOPS[2], -- 950
			w = 42, -- 950
			h = 74, -- 950
			fit = "h" -- 950
		}, -- 950
		{ -- 954
			path = "assets/props/e2_dice.png", -- 954
			x = 490, -- 954
			y = FLOOR_TOPS[2], -- 954
			w = 34, -- 954
			h = 30, -- 954
			fit = "min" -- 954
		}, -- 954
		{ -- 955
			path = "assets/props/b7_table.png", -- 955
			x = 550, -- 955
			y = FLOOR_TOPS[2], -- 955
			w = 190, -- 955
			h = 78, -- 955
			fit = "min" -- 955
		}, -- 955
		{ -- 956
			path = "assets/props/e6_offering.png", -- 956
			x = 1020, -- 956
			y = FLOOR_TOPS[2], -- 956
			w = 52, -- 956
			h = 36, -- 956
			fit = "min" -- 956
		}, -- 956
		{ -- 957
			path = "assets/props/b5_counter.png", -- 957
			x = 1755, -- 957
			y = FLOOR_TOPS[2], -- 957
			w = 160, -- 957
			h = 110, -- 957
			fit = "min" -- 957
		}, -- 957
		{ -- 960
			path = "assets/props/withered_reed.png", -- 960
			x = 1360, -- 960
			y = FLOOR_TOPS[1], -- 960
			w = 64, -- 960
			h = 78, -- 960
			fit = "w" -- 960
		}, -- 960
		{ -- 961
			path = "assets/props/withered_reed.png", -- 961
			x = 1690, -- 961
			y = FLOOR_TOPS[1], -- 961
			w = 56, -- 961
			h = 70, -- 961
			fit = "w" -- 961
		}, -- 961
		{ -- 963
			path = "assets/props/b6_barrel.png", -- 963
			x = 660, -- 963
			y = FLOOR_TOPS[3], -- 963
			w = 92, -- 963
			h = 84, -- 963
			fit = "min" -- 963
		}, -- 963
		{ -- 964
			path = "assets/props/b7_table.png", -- 964
			x = 1750, -- 964
			y = FLOOR_TOPS[3], -- 964
			w = 190, -- 964
			h = 78, -- 964
			fit = "min" -- 964
		}, -- 964
		{ -- 965
			path = "assets/props/b6_barrel.png", -- 965
			x = 1980, -- 965
			y = FLOOR_TOPS[3], -- 965
			w = 92, -- 965
			h = 84, -- 965
			fit = "min" -- 965
		}, -- 965
		{ -- 967
			path = "assets/props/withered_reed.png", -- 967
			x = 480, -- 967
			y = FLOOR_TOPS[6], -- 967
			w = 60, -- 967
			h = 74, -- 967
			fit = "w" -- 967
		}, -- 967
		{ -- 971
			path = "assets/props/e5_herb.png", -- 971
			x = 1150, -- 971
			y = FLOOR_TOPS[2], -- 971
			w = 36, -- 971
			h = 30, -- 971
			fit = "min" -- 971
		}, -- 971
		{ -- 972
			path = "assets/props/e3_lingzhi.png", -- 972
			x = 1310, -- 972
			y = FLOOR_TOPS[2], -- 972
			w = 44, -- 972
			h = 36, -- 972
			fit = "min" -- 972
		}, -- 972
		{ -- 973
			path = "assets/props/e4_ginseng.png", -- 973
			x = 1650, -- 973
			y = FLOOR_TOPS[2], -- 973
			w = 40, -- 973
			h = 34, -- 973
			fit = "min" -- 973
		}, -- 973
		{ -- 977
			path = "assets/props/e7_shard.png", -- 977
			x = 980, -- 977
			y = FLOOR_TOPS[7], -- 977
			w = 46, -- 977
			h = 40, -- 977
			fit = "min" -- 977
		} -- 977
	} -- 977
	for ____, d in ipairs(defs) do -- 979
		self:addSceneProp( -- 980
			d.path, -- 980
			d.x, -- 980
			d.y, -- 980
			d.w, -- 980
			d.h, -- 980
			d.fit -- 980
		) -- 980
	end -- 980
	for ____, hs in ipairs(HIDE_SPOTS) do -- 985
		local top = hs.floor >= 0 and hs.floor < #FLOOR_TOPS and FLOOR_TOPS[hs.floor + 1] or FLOOR_TOPS[2] -- 986
		self:addSceneProp( -- 987
			"assets/props/b1_bush.png", -- 987
			hs.x, -- 987
			top, -- 987
			104, -- 987
			64, -- 987
			"w" -- 987
		) -- 987
		self:addSceneProp( -- 988
			"assets/props/withered_reed.png", -- 988
			hs.x, -- 988
			top, -- 988
			96, -- 988
			72, -- 988
			"w" -- 988
		) -- 988
	end -- 988
end -- 938
function WorldRenderer.prototype.addSceneProp(self, path, x, y, boxW, boxH, fit) -- 993
	local tex = self:loadTex(path) -- 994
	if tex == nil then -- 994
		return -- 996
	end -- 996
	local sp = Sprite(tex) -- 998
	if sp == nil then -- 998
		return -- 1000
	end -- 1000
	local sW = boxW / tex.width -- 1002
	local sH = boxH / tex.height -- 1003
	local s = fit == "w" and sW or (fit == "h" and sH or math.min(sW, sH)) -- 1004
	sp.anchor = Vec2(0.5, 0) -- 1005
	sp.scaleX = s -- 1006
	sp.scaleY = s -- 1007
	sp.filter = "Point" -- 1008
	sp.position = Vec2(x, y) -- 1009
	sp:addTo(self:floorHolderIn( -- 1010
		self.scenePropsRoot, -- 1010
		self.sceneFloorHolders, -- 1010
		self:floorOfY(y) -- 1010
	)) -- 1010
end -- 993
function WorldRenderer.prototype.setCamera(self, camX, camY, shakeX, shakeY) -- 1013
	self.camX = camX -- 1014
	self.camY = camY -- 1015
	local vw = View.size.width -- 1016
	local vh = View.size.height -- 1017
	self.vw = vw -- 1018
	self.vh = vh -- 1019
	self.worldRoot.scaleX = ____exports.CAM_ZOOM -- 1023
	self.worldRoot.scaleY = ____exports.CAM_ZOOM -- 1024
	self.worldRoot.position = Vec2(-camX * ____exports.CAM_ZOOM + shakeX, -camY * ____exports.CAM_ZOOM + shakeY) -- 1025
	self:updatePixelBackdrop(camX, camY, vw, vh) -- 1026
	for ____, g in ipairs(self.tileGroups) do -- 1027
		g.node.visible = (g.floor < 0 or g.floor == self.activeFloor) and self:inView(g.x0, g.y0 - 40, g.x1, g.y1 + 40) -- 1029
	end -- 1029
end -- 1013
function WorldRenderer.prototype.setFloorScene(self, floor) -- 1034
	self.sceneBand = math.max( -- 1035
		0, -- 1035
		math.min( -- 1035
			#BG_LAYERS - 1, -- 1035
			math.floor(floor) -- 1035
		) -- 1035
	) -- 1035
	self.activeFloor = self.sceneBand -- 1038
	self:applyFloorHolders(self.sceneFloorHolders) -- 1039
	self:applyFloorHolders(self.decorFloorHolders) -- 1040
	self:applyFloorHolders(self.propSpriteFloorHolders) -- 1041
end -- 1034
function WorldRenderer.prototype.applyFloorHolders(self, holders) -- 1044
	do -- 1044
		local i = 0 -- 1045
		while i < #holders do -- 1045
			holders[i + 1].visible = i == self.activeFloor -- 1046
			i = i + 1 -- 1045
		end -- 1045
	end -- 1045
end -- 1044
function WorldRenderer.prototype.floorHolderIn(self, root, holders, floor) -- 1051
	while #holders <= floor do -- 1051
		local n = Node() -- 1053
		n:addTo(root) -- 1054
		n.visible = #holders == self.activeFloor -- 1055
		holders[#holders + 1] = n -- 1056
	end -- 1056
	return holders[floor + 1] -- 1058
end -- 1051
function WorldRenderer.prototype.floorOfY(self, y) -- 1063
	local f = 0 -- 1064
	do -- 1064
		local i = #FLOOR_TOPS - 1 -- 1065
		while i >= 0 do -- 1065
			if y >= FLOOR_TOPS[i + 1] then -- 1065
				f = i -- 1067
				break -- 1068
			end -- 1068
			i = i - 1 -- 1065
		end -- 1065
	end -- 1065
	return f -- 1071
end -- 1063
function WorldRenderer.prototype.buildPortals(self) -- 1075
	local list = self.data.portals -- 1076
	do -- 1076
		local i = 0 -- 1077
		while i < #list do -- 1077
			local p = list[i + 1] -- 1078
			local holder = Node() -- 1079
			holder:addTo(self.portalLayer) -- 1080
			holder.visible = false -- 1081
			local tex = self:loadTex("assets/tiles/skyruins_portal.png") -- 1082
			if tex ~= nil then -- 1082
				local s = 130 / tex.height -- 1084
				local sp = Sprite(tex) -- 1085
				sp.anchor = Vec2(0.5, 0) -- 1086
				sp.scaleX = s -- 1087
				sp.scaleY = s -- 1088
				sp.filter = "Point" -- 1089
				sp.position = Vec2(p.x, p.y) -- 1090
				sp:addTo(holder) -- 1091
			else -- 1091
				local d = DrawNode() -- 1093
				d:addTo(holder) -- 1094
				d:drawPolygon( -- 1095
					{ -- 1095
						Vec2(p.x - 26, p.y), -- 1096
						Vec2(p.x + 26, p.y), -- 1097
						Vec2(p.x + 26, p.y + 86), -- 1098
						Vec2(p.x, p.y + 118), -- 1099
						Vec2(p.x - 26, p.y + 86) -- 1100
					}, -- 1100
					Color(120, 200, 255, 200) -- 1101
				) -- 1101
			end -- 1101
			local ____self_portalNodes_9 = self.portalNodes -- 1101
			____self_portalNodes_9[#____self_portalNodes_9 + 1] = { -- 1103
				node = holder, -- 1103
				floor = p.floor, -- 1103
				x = p.x, -- 1103
				gateId = p.gateId, -- 1103
				fade = 0 -- 1103
			} -- 1103
			i = i + 1 -- 1077
		end -- 1077
	end -- 1077
end -- 1075
function WorldRenderer.prototype.buildPropSprites(self) -- 1108
	local stoneTex = self:loadTex("assets/tiles/push_stone.png") -- 1110
	if stoneTex ~= nil then -- 1110
		local sx = 56 / stoneTex.width -- 1112
		local sy = 44 / stoneTex.height -- 1113
		for ____, def in ipairs(self.data.pushStones) do -- 1114
			do -- 1114
				local sp = Sprite(stoneTex) -- 1115
				if sp == nil then -- 1115
					goto __continue155 -- 1117
				end -- 1117
				sp.anchor = Vec2(0.5, 0.5) -- 1119
				sp.scaleX = sx -- 1120
				sp.scaleY = sy -- 1121
				sp.position = Vec2(def.x, def.y + 22) -- 1122
				sp.visible = false -- 1123
				sp:addTo(self:floorHolderIn( -- 1124
					self.propSpriteRoot, -- 1124
					self.propSpriteFloorHolders, -- 1124
					self:floorOfY(def.y + 22) -- 1124
				)) -- 1124
				local ____self_stoneSprites_10 = self.stoneSprites -- 1124
				____self_stoneSprites_10[#____self_stoneSprites_10 + 1] = sp -- 1125
			end -- 1125
			::__continue155:: -- 1125
		end -- 1125
	end -- 1125
	local lampTex = self:loadTex("assets/tiles/lamp_stone.png") -- 1129
	if lampTex ~= nil then -- 1129
		local s = 36 / lampTex.height -- 1131
		for ____, c in ipairs(self.data.collectibles) do -- 1132
			do -- 1132
				if c.kind ~= "lampstone" then -- 1132
					goto __continue159 -- 1134
				end -- 1134
				local sp = Sprite(lampTex) -- 1136
				if sp == nil then -- 1136
					goto __continue159 -- 1138
				end -- 1138
				sp.anchor = Vec2(0.5, 0.5) -- 1140
				sp.scaleX = s -- 1141
				sp.scaleY = s -- 1142
				sp.position = Vec2(c.x, c.y + 18) -- 1143
				sp.visible = false -- 1144
				sp:addTo(self:floorHolderIn( -- 1145
					self.propSpriteRoot, -- 1145
					self.propSpriteFloorHolders, -- 1145
					self:floorOfY(c.y) -- 1145
				)) -- 1145
				self.lampStoneSprites[c.id] = sp -- 1146
			end -- 1146
			::__continue159:: -- 1146
		end -- 1146
	end -- 1146
	local moonTex = self:loadTex("assets/tiles/moon_stone.png") -- 1150
	if moonTex ~= nil then -- 1150
		local msc = 36 / moonTex.height -- 1152
		for ____, c in ipairs(self.data.collectibles) do -- 1153
			do -- 1153
				if c.kind ~= "moonstone" then -- 1153
					goto __continue164 -- 1155
				end -- 1155
				local sp = Sprite(moonTex) -- 1157
				if sp == nil then -- 1157
					goto __continue164 -- 1159
				end -- 1159
				sp.anchor = Vec2(0.5, 0.5) -- 1161
				sp.scaleX = msc -- 1162
				sp.scaleY = msc -- 1163
				sp.position = Vec2(c.x, c.y + 18) -- 1164
				sp.visible = false -- 1165
				sp:addTo(self:floorHolderIn( -- 1166
					self.propSpriteRoot, -- 1166
					self.propSpriteFloorHolders, -- 1166
					self:floorOfY(c.y) -- 1166
				)) -- 1166
				self.moonStoneSprites[c.id] = sp -- 1167
			end -- 1167
			::__continue164:: -- 1167
		end -- 1167
	end -- 1167
	local dewTex = self:loadTex("assets/props/blood_dew.png") -- 1171
	if dewTex ~= nil then -- 1171
		print(((("[DewSprite] loaded assets/props/blood_dew.png (" .. tostring(dewTex.width)) .. "x") .. tostring(dewTex.height)) .. ")") -- 1173
		local dc = 36 / dewTex.height -- 1174
		for ____, c in ipairs(self.data.collectibles) do -- 1175
			do -- 1175
				if c.kind ~= "dew" then -- 1175
					goto __continue169 -- 1177
				end -- 1177
				local sp = Sprite(dewTex) -- 1179
				if sp == nil then -- 1179
					goto __continue169 -- 1181
				end -- 1181
				sp.anchor = Vec2(0.5, 0.5) -- 1183
				sp.scaleX = dc -- 1184
				sp.scaleY = dc -- 1185
				sp.position = Vec2(c.x, c.y + 18) -- 1186
				sp.visible = false -- 1187
				sp:addTo(self:floorHolderIn( -- 1188
					self.propSpriteRoot, -- 1188
					self.propSpriteFloorHolders, -- 1188
					self:floorOfY(c.y) -- 1188
				)) -- 1188
				self.dewSprites[c.id] = sp -- 1189
			end -- 1189
			::__continue169:: -- 1189
		end -- 1189
	end -- 1189
	local tokenTex = self:loadTex("assets/props/e7_shard.png") -- 1194
	if tokenTex ~= nil then -- 1194
		local tsc = 36 / tokenTex.height -- 1196
		for ____, c in ipairs(self.data.collectibles) do -- 1197
			do -- 1197
				if c.kind ~= "token" then -- 1197
					goto __continue174 -- 1199
				end -- 1199
				local sp = Sprite(tokenTex) -- 1201
				if sp == nil then -- 1201
					goto __continue174 -- 1203
				end -- 1203
				sp.anchor = Vec2(0.5, 0.5) -- 1205
				sp.scaleX = tsc -- 1206
				sp.scaleY = tsc -- 1207
				sp.position = Vec2(c.x, c.y + 18) -- 1208
				sp.visible = false -- 1209
				sp:addTo(self:floorHolderIn( -- 1210
					self.propSpriteRoot, -- 1210
					self.propSpriteFloorHolders, -- 1210
					self:floorOfY(c.y) -- 1210
				)) -- 1210
				self.tokenSprites[c.id] = sp -- 1211
			end -- 1211
			::__continue174:: -- 1211
		end -- 1211
	end -- 1211
	local offTex = self:loadTex("assets/ui/flag/checkpoint_off.png") -- 1215
	for ____, cp in ipairs(self.data.checkpoints) do -- 1216
		do -- 1216
			if cp.id == "cp_riverbank" then -- 1216
				goto __continue178 -- 1218
			end -- 1218
			local onFrames = {} -- 1220
			do -- 1220
				local fi = 0 -- 1221
				while fi < 4 do -- 1221
					do -- 1221
						local tex = self:loadTex(("assets/ui/flag/checkpoint_on_" .. tostring(fi)) .. ".png") -- 1222
						if tex == nil then -- 1222
							goto __continue181 -- 1224
						end -- 1224
						local sp = Sprite(tex) -- 1226
						if sp == nil then -- 1226
							goto __continue181 -- 1228
						end -- 1228
						self:setupFlagSprite( -- 1230
							sp, -- 1230
							tex.height, -- 1230
							cp.x, -- 1230
							cp.y, -- 1230
							self:floorOfY(cp.y) -- 1230
						) -- 1230
						onFrames[#onFrames + 1] = sp -- 1231
					end -- 1231
					::__continue181:: -- 1231
					fi = fi + 1 -- 1221
				end -- 1221
			end -- 1221
			if offTex ~= nil and #onFrames > 0 then -- 1221
				local spOff = Sprite(offTex) -- 1234
				if spOff ~= nil then -- 1234
					self:setupFlagSprite( -- 1236
						spOff, -- 1236
						offTex.height, -- 1236
						cp.x, -- 1236
						cp.y, -- 1236
						self:floorOfY(cp.y) -- 1236
					) -- 1236
					self.flagSets[cp.id] = {off = spOff, on = onFrames} -- 1237
				end -- 1237
			end -- 1237
		end -- 1237
		::__continue178:: -- 1237
	end -- 1237
end -- 1108
function WorldRenderer.prototype.setupFlagSprite(self, sp, texH, x, y, floor) -- 1243
	local s = 90 / texH -- 1244
	sp.anchor = Vec2(0.5, 0) -- 1245
	sp.scaleX = s -- 1246
	sp.scaleY = s -- 1247
	sp.filter = "Point" -- 1248
	sp.position = Vec2(x, y) -- 1249
	sp.visible = false -- 1250
	sp:addTo(self:floorHolderIn(self.propSpriteRoot, self.propSpriteFloorHolders, floor)) -- 1251
end -- 1243
function WorldRenderer.prototype.updatePortals(self, player, state, dt) -- 1254
	do -- 1254
		local i = 0 -- 1255
		while i < #self.portalNodes do -- 1255
			local rec = self.portalNodes[i + 1] -- 1256
			local unlocked = rec.gateId == nil or state.openedGates[rec.gateId] == true -- 1259
			local want = unlocked and rec.floor == self.sceneBand and math.abs(player.body.x - rec.x) < 280 -- 1260
			rec.fade = rec.fade + ((want and 1 or 0) - rec.fade) * math.min(1, dt * 8) -- 1261
			if rec.fade < 0.005 then -- 1261
				rec.fade = 0 -- 1263
			end -- 1263
			rec.node.visible = rec.fade > 0.02 -- 1265
			rec.node.opacity = rec.fade -- 1266
			i = i + 1 -- 1255
		end -- 1255
	end -- 1255
end -- 1254
function WorldRenderer.prototype.updatePixelBackdrop(self, camX, camY, vw, vh) -- 1271
	if not self.pixelBgOk then -- 1271
		return -- 1273
	end -- 1273
	local band = math.max( -- 1275
		0, -- 1275
		math.min(#self.bgBands - 1, self.sceneBand) -- 1275
	) -- 1275
	do -- 1275
		local i = 0 -- 1276
		while i < #self.bgBands do -- 1276
			self.bgBands[i + 1].node.visible = i == band -- 1277
			i = i + 1 -- 1276
		end -- 1276
	end -- 1276
	local bandTop = self.bgBands[band + 1].floorTop -- 1279
	local function mod(x, m) -- 1280
		local r = x % m -- 1281
		return r < 0 and r + m or r -- 1282
	end -- 1280
	for ____, rec in ipairs(self.bgRecs) do -- 1284
		do -- 1284
			if rec.band ~= band then -- 1284
				goto __continue197 -- 1286
			end -- 1286
			local offX = mod(camX * rec.f, rec.spanW) -- 1288
			rec.node.x = -vw / 2 - offX + rec.copyIndex * rec.spanW -- 1289
			local yBase = -vh / 2 + 1 + rec.baseUp -- 1290
			local targetY = yBase + (bandTop - camY) * rec.f * 0.6 -- 1291
			local yMin = vh / 2 - rec.imgH + 1 -- 1292
			rec.node.y = targetY < yMin and yMin or targetY -- 1293
		end -- 1293
		::__continue197:: -- 1293
	end -- 1293
	self.activeBand = band -- 1295
end -- 1271
function WorldRenderer.prototype.inViewX(self, x0, x1) -- 1298
	local hw = self.vw / (2 * ____exports.CAM_ZOOM) -- 1300
	return x1 >= self.camX - hw - CULL and x0 <= self.camX + hw + CULL -- 1301
end -- 1298
function WorldRenderer.prototype.inViewY(self, y0, y1) -- 1304
	local hh = self.vh / (2 * ____exports.CAM_ZOOM) -- 1305
	return y1 >= self.camY - hh - CULL and y0 <= self.camY + hh + CULL -- 1306
end -- 1304
function WorldRenderer.prototype.inView(self, x0, y0, x1, y1) -- 1309
	return self:inViewX(x0, x1) and self:inViewY(y0, y1) -- 1310
end -- 1309
function WorldRenderer.prototype.update(self, dt, state, player, enemies, mech, time) -- 1313
	self.lightDecor:update(time, dt) -- 1314
	self:updatePortals(player, state, dt) -- 1315
	self:drawBackground(time) -- 1316
	self:drawTerrain(time) -- 1317
	self:drawProps(time, state) -- 1318
	self:drawChars( -- 1319
		time, -- 1319
		state, -- 1319
		player, -- 1319
		enemies, -- 1319
		mech, -- 1319
		dt -- 1319
	) -- 1319
end -- 1313
function WorldRenderer.prototype.drawBackground(self, time) -- 1323
	local d = self.bgDraw -- 1324
	d:clear() -- 1325
	local vw = self.vw -- 1326
	local vh = self.vh -- 1327
	local x0 = -vw / 2 -- 1328
	local y0 = -vh / 2 -- 1329
	if not self.pixelBgOk then -- 1329
		d:drawPolygon( -- 1331
			{ -- 1332
				Vec2(x0 - 4, y0 - 4), -- 1332
				Vec2(x0 + vw + 8, y0 - 4), -- 1332
				Vec2(x0 + vw + 8, y0 + vh + 8), -- 1332
				Vec2(x0 - 4, y0 + vh + 8) -- 1332
			}, -- 1332
			col(Palette.paper), -- 1333
			0, -- 1334
			Color(0, 0, 0, 0) -- 1335
		) -- 1335
	end -- 1335
	local span = vw + 80 -- 1339
	local starsOn = self.sceneBand ~= 4 -- 1340
	do -- 1340
		local i = 0 -- 1341
		while starsOn and i < #self.stars do -- 1341
			local st = self.stars[i + 1] -- 1342
			local wx = st.x - self.camX * 0.04 -- 1343
			wx = wx % span -- 1344
			if wx < 0 then -- 1344
				wx = wx + span -- 1346
			end -- 1346
			local sx = wx - 40 - vw / 2 -- 1348
			local sy = y0 + st.y -- 1349
			local tw = 0.22 + 0.3 * (0.5 + 0.5 * math.sin(time * 1.8 + i * 1.7)) -- 1350
			dot( -- 1351
				d, -- 1351
				sx, -- 1351
				sy, -- 1351
				st.s, -- 1351
				Palette.moonWhite, -- 1351
				tw -- 1351
			) -- 1351
			i = i + 1 -- 1341
		end -- 1341
	end -- 1341
	if self.pixelBgOk and self.sceneBand == 4 then -- 1341
		self:drawMechBackdrop(time) -- 1356
	end -- 1356
	if not self.pixelBgOk then -- 1356
		local ridges = { -- 1360
			{ -- 1361
				p = 0.12, -- 1361
				base = -70, -- 1361
				a1 = 46, -- 1361
				a2 = 18, -- 1361
				c = ink(101, 112, 107, 50), -- 1361
				s = 0.006, -- 1361
				s2 = 0.017 -- 1361
			}, -- 1361
			{ -- 1362
				p = 0.22, -- 1362
				base = -120, -- 1362
				a1 = 58, -- 1362
				a2 = 22, -- 1362
				c = ink(84, 94, 90, 85), -- 1362
				s = 0.007, -- 1362
				s2 = 0.021 -- 1362
			}, -- 1362
			{ -- 1363
				p = 0.35, -- 1363
				base = -180, -- 1363
				a1 = 70, -- 1363
				a2 = 26, -- 1363
				c = ink(66, 74, 70, 130), -- 1363
				s = 0.008, -- 1363
				s2 = 0.026 -- 1363
			} -- 1363
		} -- 1363
		do -- 1363
			local ri = 0 -- 1365
			while ri < #ridges do -- 1365
				local rg = ridges[ri + 1] -- 1366
				local verts = {} -- 1367
				do -- 1367
					local sx = -64 -- 1368
					while sx <= vw + 64 do -- 1368
						local wxs = sx + self.camX * rg.p -- 1369
						local ry = rg.base - self.camY * rg.p * 0.5 + rg.a1 * math.sin(wxs * rg.s + ri * 2.3) + rg.a2 * math.sin(wxs * rg.s2 + ri * 1.1) -- 1370
						verts[#verts + 1] = Vec2(sx - vw / 2, ry) -- 1371
						sx = sx + 64 -- 1368
					end -- 1368
				end -- 1368
				verts[#verts + 1] = Vec2(vw / 2 + 64, y0 - 6) -- 1373
				verts[#verts + 1] = Vec2(-vw / 2 - 64, y0 - 6) -- 1374
				d:drawPolygon( -- 1375
					verts, -- 1375
					col(rg.c), -- 1375
					0, -- 1375
					Color(0, 0, 0, 0) -- 1375
				) -- 1375
				ri = ri + 1 -- 1365
			end -- 1365
		end -- 1365
		self:drawPagoda(time) -- 1377
		self:drawMist(time) -- 1378
		if self.camY - vh / 2 < 300 then -- 1378
			self:drawWaterFront(time) -- 1380
		end -- 1380
	end -- 1380
end -- 1323
function WorldRenderer.prototype.drawMechBackdrop(self, time) -- 1387
	local d = self.bgDraw -- 1388
	local vw = self.vw -- 1389
	local vh = self.vh -- 1390
	local x0 = -vw / 2 -- 1391
	local y0 = -vh / 2 -- 1392
	d:drawPolygon( -- 1394
		{ -- 1395
			Vec2(x0 - 4, y0 - 4), -- 1395
			Vec2(x0 + vw + 8, y0 - 4), -- 1395
			Vec2(x0 + vw + 8, y0 + vh + 8), -- 1395
			Vec2(x0 - 4, y0 + vh + 8) -- 1395
		}, -- 1395
		col(ink(30, 26, 22, 255)), -- 1396
		0, -- 1397
		Color(0, 0, 0, 0) -- 1398
	) -- 1398
	local yShift = -(self.camY - FLOOR_TOPS[5]) * 0.06 -- 1400
	local function mod(x, m) -- 1401
		local r = x % m -- 1402
		return r < 0 and r + m or r -- 1403
	end -- 1401
	local glowCyan = ink(168, 197, 188, 255) -- 1405
	local spanFar = 1500 -- 1407
	local offFar = mod(self.camX * 0.1, spanFar) -- 1408
	do -- 1408
		local i = 0 -- 1409
		while i < 3 do -- 1409
			do -- 1409
				local wx = mod(i * 520 + 240 - offFar, spanFar) - 200 -- 1410
				local gx = wx - vw / 2 -- 1411
				if gx < -260 or gx > vw / 2 + 260 then -- 1411
					goto __continue219 -- 1413
				end -- 1413
				local gy = y0 + 210 + yShift * 0.5 -- 1415
				local dir = i == 1 and -1 or 1 -- 1416
				self:drawGearShape( -- 1417
					d, -- 1417
					gx, -- 1417
					gy, -- 1417
					190 - i * 24, -- 1417
					12, -- 1417
					time * (0.12 + i * 0.04) * dir, -- 1417
					ink(50, 42, 33, 235), -- 1417
					ink(40, 33, 26, 235) -- 1417
				) -- 1417
			end -- 1417
			::__continue219:: -- 1417
			i = i + 1 -- 1409
		end -- 1409
	end -- 1409
	do -- 1409
		local i = 0 -- 1419
		while i < 4 do -- 1419
			do -- 1419
				local wx = mod(i * 430 + 90 - offFar, spanFar) - 200 -- 1420
				local cx = wx - vw / 2 -- 1421
				if cx < -60 or cx > vw / 2 + 60 then -- 1421
					goto __continue222 -- 1423
				end -- 1423
				d:drawPolygon( -- 1425
					{ -- 1426
						Vec2(cx - 22, y0 - 4), -- 1426
						Vec2(cx + 22, y0 - 4), -- 1426
						Vec2(cx + 16, y0 + vh + 8), -- 1426
						Vec2(cx - 16, y0 + vh + 8) -- 1426
					}, -- 1426
					col(ink(42, 36, 29, 220)), -- 1427
					0, -- 1428
					Color(0, 0, 0, 0) -- 1429
				) -- 1429
				seg( -- 1431
					d, -- 1431
					cx - 19, -- 1431
					y0 + 40, -- 1431
					cx - 19, -- 1431
					y0 + vh - 20, -- 1431
					2, -- 1431
					ink(34, 29, 24, 160) -- 1431
				) -- 1431
			end -- 1431
			::__continue222:: -- 1431
			i = i + 1 -- 1419
		end -- 1419
	end -- 1419
	local spanMid = 1200 -- 1434
	local offMid = mod(self.camX * 0.26, spanMid) -- 1435
	local pipeYs = {y0 + vh * 0.72, y0 + vh * 0.5, y0 + vh * 0.3} -- 1436
	do -- 1436
		local pi = 0 -- 1437
		while pi < #pipeYs do -- 1437
			local py = pipeYs[pi + 1] + yShift -- 1438
			seg( -- 1439
				d, -- 1439
				x0 - 20, -- 1439
				py, -- 1439
				x0 + vw + 20, -- 1439
				py, -- 1439
				10 - pi * 2, -- 1439
				ink(60, 50, 38, 235) -- 1439
			) -- 1439
			do -- 1439
				local jx = -((offMid + 60) % 150) -- 1440
				while jx < vw + 20 do -- 1440
					circle( -- 1441
						d, -- 1441
						x0 + jx, -- 1441
						py, -- 1441
						7 - pi, -- 1441
						ink(72, 60, 45, 235), -- 1441
						5 -- 1441
					) -- 1441
					jx = jx + 150 -- 1440
				end -- 1440
			end -- 1440
			do -- 1440
				local jx = -((offMid + 105) % 300) -- 1443
				while jx < vw do -- 1443
					dot( -- 1444
						d, -- 1444
						x0 + jx, -- 1444
						py + 12, -- 1444
						3.2, -- 1444
						glowCyan, -- 1444
						0.3 + 0.22 * math.sin(time * 2.4 + pi * 1.9 + jx) -- 1444
					) -- 1444
					jx = jx + 300 -- 1443
				end -- 1443
			end -- 1443
			pi = pi + 1 -- 1437
		end -- 1437
	end -- 1437
	do -- 1437
		local i = 0 -- 1448
		while i < 5 do -- 1448
			do -- 1448
				local wx = mod(i * 260 + 130 - offMid, spanMid) - 150 -- 1449
				local cx = wx - vw / 2 -- 1450
				if cx < -40 or cx > vw / 2 + 40 then -- 1450
					goto __continue231 -- 1452
				end -- 1452
				local sway = math.sin(time * 0.7 + i * 1.3) * 6 -- 1454
				local topY = y0 + vh + 8 -- 1455
				local botY = y0 + 120 + yShift + i % 2 * 46 -- 1456
				seg( -- 1457
					d, -- 1457
					cx, -- 1457
					topY, -- 1457
					cx + sway, -- 1457
					botY, -- 1457
					2.4, -- 1457
					ink(70, 59, 45, 220) -- 1457
				) -- 1457
				do -- 1457
					local k = 1 -- 1458
					while k < 7 do -- 1458
						local t = k / 7 -- 1459
						dot( -- 1460
							d, -- 1460
							cx + sway * t, -- 1460
							topY + (botY - topY) * t, -- 1460
							3.4, -- 1460
							ink(80, 68, 52, 220), -- 1460
							0.9 -- 1460
						) -- 1460
						k = k + 1 -- 1458
					end -- 1458
				end -- 1458
				circle( -- 1462
					d, -- 1462
					cx + sway, -- 1462
					botY - 8, -- 1462
					9, -- 1462
					ink(76, 63, 48, 235), -- 1462
					6 -- 1462
				) -- 1462
			end -- 1462
			::__continue231:: -- 1462
			i = i + 1 -- 1448
		end -- 1448
	end -- 1448
	local spanNear = 900 -- 1465
	local offNear = mod(self.camX * 0.4, spanNear) -- 1466
	do -- 1466
		local i = 0 -- 1467
		while i < 2 do -- 1467
			do -- 1467
				local wx = mod(i * 470 + 300 - offNear, spanNear) - 150 -- 1468
				local gx = wx - vw / 2 -- 1469
				if gx < -140 or gx > vw / 2 + 140 then -- 1469
					goto __continue236 -- 1471
				end -- 1471
				local gy = y0 + 150 + yShift * 1.4 -- 1473
				local dir = i == 0 and 1 or -1 -- 1474
				self:drawGearShape( -- 1475
					d, -- 1475
					gx, -- 1475
					gy, -- 1475
					74, -- 1475
					9, -- 1475
					time * 0.5 * dir, -- 1475
					ink(66, 55, 42, 240), -- 1475
					ink(52, 43, 33, 240) -- 1475
				) -- 1475
				dot( -- 1476
					d, -- 1476
					gx, -- 1476
					gy, -- 1476
					5, -- 1476
					glowCyan, -- 1476
					0.5 + 0.3 * math.sin(time * 3 + i) -- 1476
				) -- 1476
				self:drawGearShape( -- 1477
					d, -- 1477
					gx + 96, -- 1477
					gy + 26, -- 1477
					40, -- 1477
					7, -- 1477
					-time * 0.5 * dir * (74 / 40), -- 1477
					ink(60, 50, 38, 235), -- 1477
					ink(48, 40, 31, 235) -- 1477
				) -- 1477
			end -- 1477
			::__continue236:: -- 1477
			i = i + 1 -- 1467
		end -- 1467
	end -- 1467
end -- 1387
function WorldRenderer.prototype.drawGearShape(self, d, cx, cy, r, teeth, angle, body, hub) -- 1482
	local verts = {} -- 1483
	local n = teeth * 2 -- 1484
	do -- 1484
		local i = 0 -- 1485
		while i < n do -- 1485
			local rr = i % 2 == 0 and r or r * 0.8 -- 1486
			local a = angle + i / n * math.pi * 2 -- 1487
			verts[#verts + 1] = Vec2( -- 1488
				cx + math.cos(a) * rr, -- 1488
				cy + math.sin(a) * rr -- 1488
			) -- 1488
			i = i + 1 -- 1485
		end -- 1485
	end -- 1485
	d:drawPolygon( -- 1490
		verts, -- 1490
		col(body), -- 1490
		0, -- 1490
		Color(0, 0, 0, 0) -- 1490
	) -- 1490
	circle( -- 1491
		d, -- 1491
		cx, -- 1491
		cy, -- 1491
		r * 0.34, -- 1491
		hub, -- 1491
		5 -- 1491
	) -- 1491
	do -- 1491
		local i = 0 -- 1492
		while i < 4 do -- 1492
			local a = angle + i * math.pi * 0.5 + math.pi * 0.25 -- 1493
			local c = math.cos(a) -- 1494
			local s = math.sin(a) -- 1495
			seg( -- 1496
				d, -- 1496
				cx + c * r * 0.3, -- 1496
				cy + s * r * 0.3, -- 1496
				cx + c * r * 0.78, -- 1496
				cy + s * r * 0.78, -- 1496
				4, -- 1496
				body -- 1496
			) -- 1496
			i = i + 1 -- 1492
		end -- 1492
	end -- 1492
end -- 1482
function WorldRenderer.prototype.drawPagoda(self, time) -- 1500
	local d = self.bgDraw -- 1501
	local vw = self.vw -- 1502
	local baseX = 1500 - self.camX * 0.7 -- 1503
	local px = baseX - vw / 2 -- 1504
	if math.abs(px) > vw / 2 + 220 then -- 1504
		return -- 1506
	end -- 1506
	local baseY = -150 - self.camY * 0.35 -- 1508
	local inkTower = ink(72, 80, 76, 190) -- 1509
	local w = 150 -- 1511
	local h = 30 -- 1512
	local cy = baseY -- 1513
	do -- 1513
		local i = 0 -- 1514
		while i < 7 do -- 1514
			local nw = w * 0.86 -- 1515
			d:drawPolygon( -- 1516
				{ -- 1517
					Vec2(px - w / 2, cy), -- 1517
					Vec2(px + w / 2, cy), -- 1517
					Vec2(px + nw / 2, cy + h), -- 1517
					Vec2(px - nw / 2, cy + h) -- 1517
				}, -- 1517
				col(inkTower), -- 1518
				0, -- 1519
				Color(0, 0, 0, 0) -- 1520
			) -- 1520
			seg( -- 1523
				d, -- 1523
				px - w / 2 - 14, -- 1523
				cy + h, -- 1523
				px + w / 2 + 14, -- 1523
				cy + h, -- 1523
				4.5, -- 1523
				inkTower -- 1523
			) -- 1523
			seg( -- 1524
				d, -- 1524
				px - w / 2 - 14, -- 1524
				cy + h, -- 1524
				px - w / 2 - 20, -- 1524
				cy + h - 7, -- 1524
				2.6, -- 1524
				inkTower -- 1524
			) -- 1524
			seg( -- 1525
				d, -- 1525
				px + w / 2 + 14, -- 1525
				cy + h, -- 1525
				px + w / 2 + 20, -- 1525
				cy + h - 7, -- 1525
				2.6, -- 1525
				inkTower -- 1525
			) -- 1525
			cy = cy + h -- 1526
			h = h * 0.92 -- 1527
			w = nw -- 1528
			i = i + 1 -- 1514
		end -- 1514
	end -- 1514
	seg( -- 1531
		d, -- 1531
		px, -- 1531
		cy, -- 1531
		px, -- 1531
		cy + 30, -- 1531
		3, -- 1531
		inkTower -- 1531
	) -- 1531
	circle( -- 1532
		d, -- 1532
		px, -- 1532
		cy + 34, -- 1532
		6, -- 1532
		inkTower, -- 1532
		10 -- 1532
	) -- 1532
	local flick = 0.6 + 0.4 * math.sin(time * 2.2) -- 1534
	do -- 1534
		local i = 0 -- 1535
		while i < 4 do -- 1535
			dot( -- 1536
				d, -- 1536
				px - 26 + i * 17, -- 1536
				baseY + 60 + i * 32, -- 1536
				2.4, -- 1536
				GOLD, -- 1536
				0.35 + 0.3 * flick -- 1536
			) -- 1536
			i = i + 1 -- 1535
		end -- 1535
	end -- 1535
end -- 1500
function WorldRenderer.prototype.drawMist(self, time) -- 1540
	local d = self.bgDraw -- 1541
	local vw = self.vw -- 1542
	local span = vw + 500 -- 1543
	do -- 1543
		local i = 0 -- 1544
		while i < 3 do -- 1544
			local speed = 12 + i * 9 -- 1545
			local bandY = -170 + i * 55 + math.sin(time * 0.3 + i * 1.7) * 8 -- 1546
			do -- 1546
				local c = 0 -- 1547
				while c < 3 do -- 1547
					local wx = time * speed + c * 460 + i * 190 -- 1548
					wx = wx % span -- 1549
					if wx < 0 then -- 1549
						wx = wx + span -- 1551
					end -- 1551
					local cx0 = wx - 250 - vw / 2 -- 1553
					do -- 1553
						local j = 0 -- 1554
						while j < 6 do -- 1554
							do -- 1554
								local jx = cx0 + j * 84 -- 1555
								if jx < -vw / 2 - 120 or jx > vw / 2 + 120 then -- 1555
									goto __continue256 -- 1557
								end -- 1557
								local jy = bandY + math.sin(jx * 0.01 + time * 0.5 + i) * 6 -- 1559
								dot( -- 1560
									d, -- 1560
									jx, -- 1560
									jy, -- 1560
									16 - i * 3, -- 1560
									Palette.paleInk, -- 1560
									0.1 + i * 0.02 -- 1560
								) -- 1560
							end -- 1560
							::__continue256:: -- 1560
							j = j + 1 -- 1554
						end -- 1554
					end -- 1554
					c = c + 1 -- 1547
				end -- 1547
			end -- 1547
			i = i + 1 -- 1544
		end -- 1544
	end -- 1544
end -- 1540
function WorldRenderer.prototype.drawWaterFront(self, time) -- 1566
	local d = self.bgDraw -- 1567
	local vw = self.vw -- 1568
	local bot = -self.vh / 2 -- 1569
	local top = bot + 46 -- 1570
	d:drawPolygon( -- 1571
		{ -- 1572
			Vec2(-vw / 2 - 4, bot - 4), -- 1572
			Vec2(vw / 2 + 8, bot - 4), -- 1572
			Vec2(vw / 2 + 8, top), -- 1572
			Vec2(-vw / 2 - 4, top) -- 1572
		}, -- 1572
		col(ink(90, 110, 105, 26)), -- 1573
		0, -- 1574
		Color(0, 0, 0, 0) -- 1575
	) -- 1575
	do -- 1575
		local i = 0 -- 1577
		while i < 3 do -- 1577
			local wy = bot + 12 + i * 12 -- 1578
			do -- 1578
				local sx = -vw / 2 -- 1579
				while sx < vw / 2 do -- 1579
					seg( -- 1580
						d, -- 1581
						sx, -- 1582
						wy + waveY(sx, time, i), -- 1583
						sx + 46, -- 1584
						wy + waveY(sx + 46, time, i), -- 1585
						1.6, -- 1586
						i == 0 and CYAN or Palette.paleInk, -- 1587
						0.22 + i * 0.06 -- 1588
					) -- 1588
					sx = sx + 46 -- 1579
				end -- 1579
			end -- 1579
			i = i + 1 -- 1577
		end -- 1577
	end -- 1577
end -- 1566
function WorldRenderer.prototype.drawTerrain(self, time) -- 1595
	local d = self.platformDraw -- 1596
	d:clear() -- 1597
	for ____, p in ipairs(self.data.platforms) do -- 1598
		do -- 1598
			if p.kind == "gate" then -- 1598
				goto __continue264 -- 1600
			end -- 1600
			if self:floorOfY(p.y + p.h) ~= self.activeFloor then -- 1600
				goto __continue264 -- 1604
			end -- 1604
			if not self:inView(p.x, p.y - 60, p.x + p.w, p.y + p.h + 60) then -- 1604
				goto __continue264 -- 1607
			end -- 1607
			if p.mover ~= nil then -- 1607
				self:drawMover(d, p, time) -- 1610
				goto __continue264 -- 1611
			end -- 1611
			if p.kind == "solid" then -- 1611
				if p.w >= 300 then -- 1611
					d:drawPolygon( -- 1616
						{ -- 1617
							Vec2(p.x + 5, p.y + p.h), -- 1618
							Vec2(p.x + p.w - 5, p.y + p.h), -- 1619
							Vec2(p.x + p.w - 1, p.y + 1), -- 1620
							Vec2(p.x + 1, p.y + 1) -- 1621
						}, -- 1621
						col(ink(38, 45, 44, 225)), -- 1623
						0, -- 1624
						Color(0, 0, 0, 0) -- 1625
					) -- 1625
					seg( -- 1627
						d, -- 1627
						p.x + 4, -- 1627
						p.y + p.h - 1, -- 1627
						p.x + p.w - 4, -- 1627
						p.y + p.h - 1, -- 1627
						2, -- 1627
						PAPER_DIM -- 1627
					) -- 1627
					local crackX = p.x + 30 + p.x % math.max(60, p.w - 90) -- 1628
					seg( -- 1629
						d, -- 1629
						crackX, -- 1629
						p.y + p.h - 8, -- 1629
						crackX + 22, -- 1629
						p.y + 8, -- 1629
						1.4, -- 1629
						ink(26, 32, 31, 80) -- 1629
					) -- 1629
				else -- 1629
					d:drawPolygon( -- 1632
						{ -- 1633
							Vec2(p.x, p.y + p.h), -- 1634
							Vec2(p.x + p.w, p.y + p.h), -- 1635
							Vec2(p.x + p.w, p.y + 2), -- 1636
							Vec2(p.x, p.y + 2) -- 1637
						}, -- 1637
						col(ink(96, 70, 48, 220)), -- 1639
						0, -- 1640
						Color(0, 0, 0, 0) -- 1641
					) -- 1641
					seg( -- 1643
						d, -- 1643
						p.x + 2, -- 1643
						p.y + p.h - 1, -- 1643
						p.x + p.w - 2, -- 1643
						p.y + p.h - 1, -- 1643
						1.8, -- 1643
						ink(158, 120, 84, 150) -- 1643
					) -- 1643
					dot( -- 1644
						d, -- 1644
						p.x + 5, -- 1644
						p.y + p.h - 5, -- 1644
						1.6, -- 1644
						Palette.inkDark, -- 1644
						0.75 -- 1644
					) -- 1644
					dot( -- 1645
						d, -- 1645
						p.x + p.w - 5, -- 1645
						p.y + p.h - 5, -- 1645
						1.6, -- 1645
						Palette.inkDark, -- 1645
						0.75 -- 1645
					) -- 1645
				end -- 1645
			else -- 1645
				d:drawPolygon( -- 1649
					{ -- 1650
						Vec2(p.x, p.y + p.h), -- 1651
						Vec2(p.x + p.w, p.y + p.h), -- 1652
						Vec2(p.x + p.w, p.y + p.h - 8), -- 1653
						Vec2(p.x, p.y + p.h - 8) -- 1654
					}, -- 1654
					col(ink(110, 82, 56, 200)), -- 1656
					0, -- 1657
					Color(0, 0, 0, 0) -- 1658
				) -- 1658
				seg( -- 1660
					d, -- 1660
					p.x + 2, -- 1660
					p.y + p.h - 1, -- 1660
					p.x + p.w - 2, -- 1660
					p.y + p.h - 1, -- 1660
					1.5, -- 1660
					PAPER_DIM -- 1660
				) -- 1660
			end -- 1660
		end -- 1660
		::__continue264:: -- 1660
	end -- 1660
	for ____, l in ipairs(self.data.ladders) do -- 1663
		do -- 1663
			if l.floor ~= self.activeFloor then -- 1663
				goto __continue274 -- 1665
			end -- 1665
			if not self:inView(l.x, l.y, l.x + l.w, l.y + l.h) then -- 1665
				goto __continue274 -- 1668
			end -- 1668
			local wood = ink(84, 66, 44, 235) -- 1670
			seg( -- 1671
				d, -- 1671
				l.x + 2, -- 1671
				l.y, -- 1671
				l.x + 2, -- 1671
				l.y + l.h, -- 1671
				3, -- 1671
				wood -- 1671
			) -- 1671
			seg( -- 1672
				d, -- 1672
				l.x + l.w - 2, -- 1672
				l.y, -- 1672
				l.x + l.w - 2, -- 1672
				l.y + l.h, -- 1672
				3, -- 1672
				wood -- 1672
			) -- 1672
			do -- 1672
				local ry = l.y + 10 -- 1673
				while ry < l.y + l.h - 4 do -- 1673
					seg( -- 1674
						d, -- 1674
						l.x + 4, -- 1674
						ry, -- 1674
						l.x + l.w - 4, -- 1674
						ry, -- 1674
						2.4, -- 1674
						ink(102, 80, 52, 220) -- 1674
					) -- 1674
					ry = ry + 18 -- 1673
				end -- 1673
			end -- 1673
		end -- 1673
		::__continue274:: -- 1673
	end -- 1673
	for ____, cw in ipairs(self.data.climbWalls) do -- 1677
		do -- 1677
			if self:floorOfY(cw.y + cw.h) ~= self.activeFloor then -- 1677
				goto __continue280 -- 1679
			end -- 1679
			if not self:inView(cw.x, cw.y, cw.x + cw.w, cw.y + cw.h) then -- 1679
				goto __continue280 -- 1682
			end -- 1682
			local crag = ink(64, 58, 52, 200) -- 1684
			seg( -- 1685
				d, -- 1685
				cw.x, -- 1685
				cw.y + cw.h, -- 1685
				cw.x + cw.w, -- 1685
				cw.y + cw.h, -- 1685
				3, -- 1685
				crag -- 1685
			) -- 1685
			do -- 1685
				local i = 0 -- 1686
				while i <= 4 do -- 1686
					local xx = cw.x + 6 + i * (cw.w - 12) / 4 -- 1687
					seg( -- 1688
						d, -- 1688
						xx, -- 1688
						cw.y + cw.h, -- 1688
						xx + 7, -- 1688
						cw.y + cw.h * 0.55, -- 1688
						3.4, -- 1688
						crag -- 1688
					) -- 1688
					seg( -- 1689
						d, -- 1689
						xx + 7, -- 1689
						cw.y + cw.h * 0.55, -- 1689
						xx + 2, -- 1689
						cw.y + 4, -- 1689
						2.6, -- 1689
						ink(64, 58, 52, 130) -- 1689
					) -- 1689
					i = i + 1 -- 1686
				end -- 1686
			end -- 1686
		end -- 1686
		::__continue280:: -- 1686
	end -- 1686
end -- 1595
function WorldRenderer.prototype.drawMover(self, d, p, time) -- 1694
	local m = p.mover -- 1695
	if m == nil then -- 1695
		return -- 1697
	end -- 1697
	local x = p.x -- 1703
	local y = p.y -- 1704
	do -- 1704
		local i = 0 -- 1706
		while i < 8 do -- 1706
			local t0 = i / 8 + 0.02 -- 1707
			local t1 = t0 + 0.06 -- 1708
			seg( -- 1709
				d, -- 1710
				m.ax + (m.bx - m.ax) * t0 + p.w / 2, -- 1711
				m.ay + (m.by - m.ay) * t0 + p.h / 2, -- 1712
				m.ax + (m.bx - m.ax) * t1 + p.w / 2, -- 1713
				m.ay + (m.by - m.ay) * t1 + p.h / 2, -- 1714
				2, -- 1715
				PAPER_DIM -- 1716
			) -- 1716
			i = i + 1 -- 1706
		end -- 1706
	end -- 1706
	d:drawPolygon( -- 1719
		{ -- 1720
			Vec2(x, y + p.h), -- 1720
			Vec2(x + p.w, y + p.h), -- 1720
			Vec2(x + p.w, y + 2), -- 1720
			Vec2(x, y + 2) -- 1720
		}, -- 1720
		col(ink(52, 60, 58, 230)), -- 1721
		0, -- 1722
		Color(0, 0, 0, 0) -- 1723
	) -- 1723
	seg( -- 1725
		d, -- 1725
		x + 2, -- 1725
		y + p.h - 1, -- 1725
		x + p.w - 2, -- 1725
		y + p.h - 1, -- 1725
		1.8, -- 1725
		PAPER_DIM -- 1725
	) -- 1725
	dot( -- 1726
		d, -- 1726
		x + p.w / 2, -- 1726
		y + p.h / 2, -- 1726
		4 + math.sin(time * 3) * 1, -- 1726
		GOLD, -- 1726
		0.85 -- 1726
	) -- 1726
end -- 1694
function WorldRenderer.prototype.drawProps(self, time, state) -- 1730
	local d = self.propDraw -- 1731
	d:clear() -- 1732
	self:drawGates(d, state) -- 1733
	self:drawRopes(d, time, state) -- 1734
	self:drawBells(d, time, state) -- 1735
	self:drawPlates(d, time, state) -- 1736
	self:drawSwordSlots(d, time, state) -- 1737
	self:drawWindSigils(d, time, state) -- 1738
	self:drawStarNodes(d, time, state) -- 1739
	self:drawLanterns(d, time, state) -- 1740
	self:drawCheckpoints(d, time, state) -- 1741
	self:drawCollectibles(d, time, state) -- 1742
	self:drawDecor(d, time) -- 1743
end -- 1730
function WorldRenderer.prototype.drawGates(self, d, state) -- 1746
	for ____, gp in ipairs(self.gateParts) do -- 1747
		do -- 1747
			if #gp.rects == 0 then -- 1747
				goto __continue292 -- 1749
			end -- 1749
			local open = state.openedGates[gp.gid] == true -- 1751
			local x0 = 1000000000 -- 1752
			local y0 = 1000000000 -- 1753
			local x1 = -1000000000 -- 1754
			local y1 = -1000000000 -- 1755
			for ____, r in ipairs(gp.rects) do -- 1756
				x0 = math.min(x0, r.x) -- 1757
				y0 = math.min(y0, r.y) -- 1758
				x1 = math.max(x1, r.x + r.w) -- 1759
				y1 = math.max(y1, r.y + r.h) -- 1760
			end -- 1760
			if self:floorOfY(y1) ~= self.activeFloor then -- 1760
				goto __continue292 -- 1763
			end -- 1763
			if not self:inView(x0, y0, x1, y1) then -- 1763
				goto __continue292 -- 1766
			end -- 1766
			local postC = ink(52, 46, 38, 235) -- 1769
			for ____, r in ipairs(gp.rects) do -- 1770
				local isPost = r.w <= 14 or r.h >= (y1 - y0) * 0.9 -- 1771
				if not open or isPost then -- 1771
					d:drawPolygon( -- 1773
						{ -- 1774
							Vec2(r.x, r.y + r.h), -- 1774
							Vec2(r.x + r.w, r.y + r.h), -- 1774
							Vec2(r.x + r.w, r.y), -- 1774
							Vec2(r.x, r.y) -- 1774
						}, -- 1774
						col(isPost and postC or ink(64, 58, 50, 220)), -- 1775
						0, -- 1776
						Color(0, 0, 0, 0) -- 1777
					) -- 1777
				end -- 1777
			end -- 1777
			seg( -- 1782
				d, -- 1782
				x0 - 6, -- 1782
				y1 + 4, -- 1782
				x1 + 6, -- 1782
				y1 + 4, -- 1782
				4, -- 1782
				postC -- 1782
			) -- 1782
			seg( -- 1783
				d, -- 1783
				x0 - 6, -- 1783
				y1 + 8, -- 1783
				x1 + 6, -- 1783
				y1 + 8, -- 1783
				1.6, -- 1783
				GOLD, -- 1783
				0.5 -- 1783
			) -- 1783
			if not open then -- 1783
				do -- 1783
					local i = 1 -- 1786
					while i <= 3 do -- 1786
						local sx = x0 + (x1 - x0) * i / 4 -- 1787
						seg( -- 1788
							d, -- 1788
							sx - 10, -- 1788
							y0 + 6, -- 1788
							sx + 10, -- 1788
							y1 - 6, -- 1788
							1.8, -- 1788
							ink(84, 76, 62, 180) -- 1788
						) -- 1788
						i = i + 1 -- 1786
					end -- 1786
				end -- 1786
			end -- 1786
		end -- 1786
		::__continue292:: -- 1786
	end -- 1786
end -- 1746
function WorldRenderer.prototype.drawRopes(self, d, time, state) -- 1794
	for ____, r in ipairs(self.data.ropes) do -- 1795
		do -- 1795
			if self:floorOfY(r.y) ~= self.activeFloor then -- 1795
				goto __continue306 -- 1797
			end -- 1797
			if not self:inView(r.x - 30, r.y - r.length - 30, r.x + 30, r.y + 10) then -- 1797
				goto __continue306 -- 1800
			end -- 1800
			if state.cutRopes[r.id] == true then -- 1800
				seg( -- 1804
					d, -- 1804
					r.x, -- 1804
					r.y, -- 1804
					r.x - 2, -- 1804
					r.y - 12, -- 1804
					3, -- 1804
					Palette.inkDark, -- 1804
					0.9 -- 1804
				) -- 1804
				local fall = math.min(r.length * 0.5, 60) -- 1805
				do -- 1805
					local i = 0 -- 1806
					while i < 4 do -- 1806
						local yy0 = r.y - 12 - i * fall / 4 -- 1807
						local yy1 = r.y - 12 - (i + 1) * fall / 4 -- 1808
						local sway = math.sin(time * 2.4 + i) * 3 -- 1809
						seg( -- 1810
							d, -- 1810
							r.x - 2 + sway * 0.5, -- 1810
							yy0, -- 1810
							r.x - 4 + sway, -- 1810
							yy1, -- 1810
							2.2, -- 1810
							Palette.inkSoft, -- 1810
							0.5 - i * 0.1 -- 1810
						) -- 1810
						i = i + 1 -- 1806
					end -- 1806
				end -- 1806
			else -- 1806
				local px = r.x -- 1814
				local py = r.y -- 1815
				do -- 1815
					local i = 1 -- 1816
					while i <= 8 do -- 1816
						local tt = i / 8 -- 1817
						local yy = r.y - r.length * tt -- 1818
						local sway = math.sin(time * 1.6 + tt * 3 + r.x * 0.05) * 4 * tt -- 1819
						local nx = r.x + sway -- 1820
						seg( -- 1821
							d, -- 1821
							px, -- 1821
							py, -- 1821
							nx, -- 1821
							yy, -- 1821
							2.6, -- 1821
							Palette.inkDark, -- 1821
							0.92 -- 1821
						) -- 1821
						px = nx -- 1822
						py = yy -- 1823
						i = i + 1 -- 1816
					end -- 1816
				end -- 1816
				dot( -- 1825
					d, -- 1825
					px, -- 1825
					py, -- 1825
					3, -- 1825
					Palette.inkDark, -- 1825
					0.9 -- 1825
				) -- 1825
			end -- 1825
		end -- 1825
		::__continue306:: -- 1825
	end -- 1825
end -- 1794
function WorldRenderer.prototype.drawBells(self, d, time, state) -- 1830
	for ____, b in ipairs(self.data.bells) do -- 1831
		do -- 1831
			if self:floorOfY(b.y) ~= self.activeFloor then -- 1831
				goto __continue317 -- 1833
			end -- 1833
			if not self:inView(b.x - 40, b.y, b.x + 40, b.y + 60) then -- 1833
				goto __continue317 -- 1836
			end -- 1836
			local frame = ink(58, 50, 40, 230) -- 1838
			seg( -- 1839
				d, -- 1839
				b.x - 20, -- 1839
				b.y, -- 1839
				b.x - 20, -- 1839
				b.y + 46, -- 1839
				3.5, -- 1839
				frame -- 1839
			) -- 1839
			seg( -- 1840
				d, -- 1840
				b.x + 20, -- 1840
				b.y, -- 1840
				b.x + 20, -- 1840
				b.y + 46, -- 1840
				3.5, -- 1840
				frame -- 1840
			) -- 1840
			seg( -- 1841
				d, -- 1841
				b.x - 26, -- 1841
				b.y + 46, -- 1841
				b.x + 26, -- 1841
				b.y + 46, -- 1841
				3.5, -- 1841
				frame -- 1841
			) -- 1841
			d:drawPolygon( -- 1842
				{ -- 1843
					Vec2(b.x - 13, b.y + 44), -- 1843
					Vec2(b.x + 13, b.y + 44), -- 1843
					Vec2(b.x + 16, b.y + 24), -- 1843
					Vec2(b.x - 16, b.y + 24) -- 1843
				}, -- 1843
				col(ink(46, 52, 50, 235)), -- 1844
				0, -- 1845
				Color(0, 0, 0, 0) -- 1846
			) -- 1846
			seg( -- 1848
				d, -- 1848
				b.x - 17, -- 1848
				b.y + 24, -- 1848
				b.x + 17, -- 1848
				b.y + 24, -- 1848
				2, -- 1848
				GOLD, -- 1848
				0.5 -- 1848
			) -- 1848
			dot( -- 1849
				d, -- 1849
				b.x, -- 1849
				b.y + 21, -- 1849
				2.2, -- 1849
				GOLD, -- 1849
				0.8 -- 1849
			) -- 1849
			if state.rungBells[b.id] == true then -- 1849
				local pulse = time * 0.9 % 1 -- 1851
				local pulse2 = (pulse + 0.5) % 1 -- 1852
				circle( -- 1853
					d, -- 1853
					b.x, -- 1853
					b.y + 30, -- 1853
					10 + pulse * 46, -- 1853
					GOLD, -- 1853
					18, -- 1853
					(1 - pulse) * 0.8 -- 1853
				) -- 1853
				circle( -- 1854
					d, -- 1854
					b.x, -- 1854
					b.y + 30, -- 1854
					10 + pulse2 * 46, -- 1854
					GOLD, -- 1854
					18, -- 1854
					(1 - pulse2) * 0.5 -- 1854
				) -- 1854
			end -- 1854
		end -- 1854
		::__continue317:: -- 1854
	end -- 1854
end -- 1830
function WorldRenderer.prototype.drawPlates(self, d, time, state) -- 1859
	for ____, pl in ipairs(self.data.plates) do -- 1860
		do -- 1860
			if self:floorOfY(pl.y) ~= self.activeFloor then -- 1860
				goto __continue323 -- 1862
			end -- 1862
			if not self:inView(pl.x - 44, pl.y, pl.x + 44, pl.y + 16) then -- 1862
				goto __continue323 -- 1865
			end -- 1865
			local on = state.platesActive[pl.id] == true -- 1867
			local sink = on and 4 or 0 -- 1868
			d:drawPolygon( -- 1869
				{ -- 1870
					Vec2(pl.x - 36, pl.y + 10 - sink), -- 1871
					Vec2(pl.x + 36, pl.y + 10 - sink), -- 1872
					Vec2(pl.x + 32, pl.y + 2 - sink), -- 1873
					Vec2(pl.x - 32, pl.y + 2 - sink) -- 1874
				}, -- 1874
				col(ink(on and 30 or 42, on and 36 or 50, on and 34 or 48, 235)), -- 1876
				0, -- 1877
				Color(0, 0, 0, 0) -- 1878
			) -- 1878
			if on then -- 1878
				seg( -- 1881
					d, -- 1881
					pl.x - 36, -- 1881
					pl.y + 11 - sink, -- 1881
					pl.x + 36, -- 1881
					pl.y + 11 - sink, -- 1881
					1.6, -- 1881
					GOLD, -- 1881
					0.55 + 0.25 * math.sin(time * 6) -- 1881
				) -- 1881
			else -- 1881
				seg( -- 1883
					d, -- 1883
					pl.x - 32, -- 1883
					pl.y + 10, -- 1883
					pl.x + 32, -- 1883
					pl.y + 10, -- 1883
					1.2, -- 1883
					PAPER_DIM -- 1883
				) -- 1883
			end -- 1883
		end -- 1883
		::__continue323:: -- 1883
	end -- 1883
end -- 1859
function WorldRenderer.prototype.drawSwordSlots(self, d, time, state) -- 1889
	local slots = self.data.swordSlots -- 1890
	if slots == nil then -- 1890
		return -- 1892
	end -- 1892
	for ____, slot in ipairs(slots) do -- 1894
		do -- 1894
			if self:floorOfY(slot.y) ~= self.activeFloor then -- 1894
				goto __continue331 -- 1896
			end -- 1896
			if not self:inView(slot.x - 44, slot.y, slot.x + 44, slot.y + 110) then -- 1896
				goto __continue331 -- 1899
			end -- 1899
			local inserted = state.flags["swordslot_" .. slot.id] == true -- 1901
			d:drawPolygon( -- 1903
				{ -- 1904
					Vec2(slot.x - 24, slot.y + 12), -- 1904
					Vec2(slot.x + 24, slot.y + 12), -- 1904
					Vec2(slot.x + 20, slot.y), -- 1904
					Vec2(slot.x - 20, slot.y) -- 1904
				}, -- 1904
				col(ink(58, 54, 48, 235)), -- 1905
				0, -- 1906
				Color(0, 0, 0, 0) -- 1907
			) -- 1907
			seg( -- 1909
				d, -- 1909
				slot.x - 20, -- 1909
				slot.y + 12, -- 1909
				slot.x + 20, -- 1909
				slot.y + 12, -- 1909
				1.6, -- 1909
				PAPER_DIM, -- 1909
				0.8 -- 1909
			) -- 1909
			d:drawPolygon( -- 1911
				{ -- 1912
					Vec2(slot.x - 3.5, slot.y + 58), -- 1912
					Vec2(slot.x + 3.5, slot.y + 58), -- 1912
					Vec2(slot.x + 3.5, slot.y + 10), -- 1912
					Vec2(slot.x - 3.5, slot.y + 10) -- 1912
				}, -- 1912
				col(ink(28, 26, 23, 240)), -- 1913
				0, -- 1914
				Color(0, 0, 0, 0) -- 1915
			) -- 1915
			seg( -- 1917
				d, -- 1917
				slot.x - 3.5, -- 1917
				slot.y + 34, -- 1917
				slot.x - 3.5, -- 1917
				slot.y + 56, -- 1917
				1.2, -- 1917
				GOLD, -- 1917
				inserted and 0.9 or 0.4 -- 1917
			) -- 1917
			seg( -- 1918
				d, -- 1918
				slot.x + 3.5, -- 1918
				slot.y + 34, -- 1918
				slot.x + 3.5, -- 1918
				slot.y + 56, -- 1918
				1.2, -- 1918
				GOLD, -- 1918
				inserted and 0.9 or 0.4 -- 1918
			) -- 1918
			if inserted then -- 1918
				local glow = 0.75 + 0.25 * math.sin(time * 2.2) -- 1921
				d:drawPolygon( -- 1922
					{ -- 1923
						Vec2(slot.x - 4, slot.y + 62), -- 1923
						Vec2(slot.x + 4, slot.y + 62), -- 1923
						Vec2(slot.x + 2.4, slot.y + 16), -- 1923
						Vec2(slot.x - 2.4, slot.y + 16) -- 1923
					}, -- 1923
					col(ink(198, 204, 196, 235)), -- 1924
					0, -- 1925
					Color(0, 0, 0, 0) -- 1926
				) -- 1926
				d:drawPolygon( -- 1928
					{ -- 1929
						Vec2(slot.x - 4, slot.y + 62), -- 1929
						Vec2(slot.x, slot.y + 62), -- 1929
						Vec2(slot.x, slot.y + 16), -- 1929
						Vec2(slot.x - 2.4, slot.y + 16) -- 1929
					}, -- 1929
					col(ink(236, 240, 232, 120)), -- 1930
					0, -- 1931
					Color(0, 0, 0, 0) -- 1932
				) -- 1932
				seg( -- 1934
					d, -- 1934
					slot.x - 12, -- 1934
					slot.y + 58, -- 1934
					slot.x + 12, -- 1934
					slot.y + 58, -- 1934
					4, -- 1934
					GOLD, -- 1934
					0.95 -- 1934
				) -- 1934
				seg( -- 1935
					d, -- 1935
					slot.x - 12, -- 1935
					slot.y + 56.4, -- 1935
					slot.x + 12, -- 1935
					slot.y + 56.4, -- 1935
					1.2, -- 1935
					ink(120, 92, 44, 220), -- 1935
					0.8 -- 1935
				) -- 1935
				seg( -- 1936
					d, -- 1936
					slot.x, -- 1936
					slot.y + 56, -- 1936
					slot.x, -- 1936
					slot.y + 44, -- 1936
					3.2, -- 1936
					ink(74, 58, 40, 235), -- 1936
					0.95 -- 1936
				) -- 1936
				dot( -- 1937
					d, -- 1937
					slot.x, -- 1937
					slot.y + 42.5, -- 1937
					3, -- 1937
					GOLD, -- 1937
					glow -- 1937
				) -- 1937
				dot( -- 1938
					d, -- 1938
					slot.x, -- 1938
					slot.y + 70, -- 1938
					10, -- 1938
					Palette.moonWhite, -- 1938
					0.04 + 0.05 * glow -- 1938
				) -- 1938
			end -- 1938
		end -- 1938
		::__continue331:: -- 1938
	end -- 1938
end -- 1889
function WorldRenderer.prototype.drawWindSigils(self, d, time, state) -- 1944
	do -- 1944
		local i = 0 -- 1945
		while i < #self.data.windSigils do -- 1945
			do -- 1945
				local s = self.data.windSigils[i + 1] -- 1946
				if self:floorOfY(s.y) ~= self.activeFloor or not self:inView(s.x - 60, s.y - 10, s.x + 60, s.y + 110) then -- 1946
					goto __continue338 -- 1948
				end -- 1948
				local on = state.flags["wind_" .. s.id] == true -- 1950
				local cy = s.y + 34 -- 1951
				circle( -- 1952
					d, -- 1952
					s.x, -- 1952
					cy, -- 1952
					26, -- 1952
					ink(58, 54, 48, 200), -- 1952
					3, -- 1952
					0.9 -- 1952
				) -- 1952
				local spin = on and time * 1.6 or 0 -- 1953
				do -- 1953
					local k = 0 -- 1954
					while k < 3 do -- 1954
						local a = spin + k * math.pi * 2 / 3 -- 1955
						local ax = s.x + math.cos(a) * 13 -- 1956
						local ay = cy + math.sin(a) * 11 -- 1957
						local bx = s.x + math.cos(a + 0.9) * 23 -- 1958
						local by = cy + math.sin(a + 0.9) * 19 -- 1959
						seg( -- 1960
							d, -- 1960
							ax, -- 1960
							ay, -- 1960
							bx, -- 1960
							by, -- 1960
							2.6, -- 1960
							on and CYAN or PAPER_DIM, -- 1960
							on and 0.95 or 0.7 -- 1960
						) -- 1960
						k = k + 1 -- 1954
					end -- 1954
				end -- 1954
				dot( -- 1962
					d, -- 1962
					s.x, -- 1962
					cy, -- 1962
					on and 5 or 3, -- 1962
					on and CYAN or PAPER_DIM, -- 1962
					on and 0.95 or 0.8 -- 1962
				) -- 1962
				if on then -- 1962
					do -- 1962
						local k = 0 -- 1964
						while k < 3 do -- 1964
							local t = (time * 0.7 + k / 3) % 1 -- 1965
							dot( -- 1966
								d, -- 1966
								s.x + math.sin((t * 6 + k) * 2) * 8, -- 1966
								s.y + 20 + t * 56, -- 1966
								2.4, -- 1966
								CYAN, -- 1966
								(1 - t) * 0.7 -- 1966
							) -- 1966
							k = k + 1 -- 1964
						end -- 1964
					end -- 1964
					local pulse = time * 0.9 % 1 -- 1968
					circle( -- 1969
						d, -- 1969
						s.x, -- 1969
						cy, -- 1969
						20 + pulse * 40, -- 1969
						CYAN, -- 1969
						14, -- 1969
						(1 - pulse) * 0.5 -- 1969
					) -- 1969
				end -- 1969
			end -- 1969
			::__continue338:: -- 1969
			i = i + 1 -- 1945
		end -- 1945
	end -- 1945
end -- 1944
function WorldRenderer.prototype.drawStarNodes(self, d, time, state) -- 1975
	local nodes = self.data.starNodes -- 1976
	do -- 1976
		local i = 0 -- 1977
		while i < #nodes - 1 do -- 1977
			do -- 1977
				local a = nodes[i + 1] -- 1978
				local b = nodes[i + 1 + 1] -- 1979
				if self:floorOfY(a.y) ~= self.activeFloor or self:floorOfY(b.y) ~= self.activeFloor then -- 1979
					goto __continue347 -- 1981
				end -- 1981
				if state.flags["star_" .. a.id] == true and state.flags["star_" .. b.id] == true then -- 1981
					local pulse = 0.5 + 0.25 * math.sin(time * 2.4 + i) -- 1984
					seg( -- 1985
						d, -- 1985
						a.x, -- 1985
						a.y + 58, -- 1985
						b.x, -- 1985
						b.y + 58, -- 1985
						1.6, -- 1985
						Palette.moonWhite, -- 1985
						pulse -- 1985
					) -- 1985
				end -- 1985
			end -- 1985
			::__continue347:: -- 1985
			i = i + 1 -- 1977
		end -- 1977
	end -- 1977
	do -- 1977
		local i = 0 -- 1988
		while i < #nodes do -- 1988
			do -- 1988
				local s = nodes[i + 1] -- 1989
				if self:floorOfY(s.y) ~= self.activeFloor or not self:inView(s.x - 44, s.y - 20, s.x + 44, s.y + 110) then -- 1989
					goto __continue351 -- 1991
				end -- 1991
				local lit = state.flags["star_" .. s.id] == true -- 1993
				seg( -- 1994
					d, -- 1994
					s.x, -- 1994
					s.y, -- 1994
					s.x, -- 1994
					s.y + 40, -- 1994
					4, -- 1994
					ink(70, 60, 46, 235) -- 1994
				) -- 1994
				seg( -- 1995
					d, -- 1995
					s.x - 9, -- 1995
					s.y + 40, -- 1995
					s.x + 9, -- 1995
					s.y + 40, -- 1995
					3, -- 1995
					ink(70, 60, 46, 235) -- 1995
				) -- 1995
				local cy = s.y + 58 -- 1996
				local c = lit and Palette.moonWhite or PAPER_DIM -- 1997
				local tw = lit and 0.75 + 0.25 * math.sin(time * 3 + i * 1.7) or 0.5 -- 1998
				local r = lit and 12 or 7 -- 1999
				seg( -- 2000
					d, -- 2000
					s.x - r, -- 2000
					cy, -- 2000
					s.x + r, -- 2000
					cy, -- 2000
					1.8, -- 2000
					c, -- 2000
					tw -- 2000
				) -- 2000
				seg( -- 2001
					d, -- 2001
					s.x, -- 2001
					cy - r, -- 2001
					s.x, -- 2001
					cy + r, -- 2001
					1.8, -- 2001
					c, -- 2001
					tw -- 2001
				) -- 2001
				dot( -- 2002
					d, -- 2002
					s.x, -- 2002
					cy, -- 2002
					lit and 5.5 or 3, -- 2002
					c, -- 2002
					tw -- 2002
				) -- 2002
				if lit then -- 2002
					dot( -- 2004
						d, -- 2004
						s.x, -- 2004
						cy, -- 2004
						15, -- 2004
						Palette.moonWhite, -- 2004
						0.06 -- 2004
					) -- 2004
				end -- 2004
			end -- 2004
			::__continue351:: -- 2004
			i = i + 1 -- 1988
		end -- 1988
	end -- 1988
end -- 1975
function WorldRenderer.prototype.drawLanterns(self, d, time, state) -- 2009
	for ____, ln in ipairs(self.data.lanterns) do -- 2010
		do -- 2010
			if self:floorOfY(ln.y) ~= self.activeFloor then -- 2010
				goto __continue355 -- 2012
			end -- 2012
			if not self:inView(ln.x - 30, ln.y, ln.x + 30, ln.y + 76) then -- 2012
				goto __continue355 -- 2015
			end -- 2015
			local pole = ink(70, 60, 46, 235) -- 2017
			seg( -- 2018
				d, -- 2018
				ln.x, -- 2018
				ln.y, -- 2018
				ln.x, -- 2018
				ln.y + 60, -- 2018
				4, -- 2018
				pole -- 2018
			) -- 2018
			seg( -- 2019
				d, -- 2019
				ln.x - 11, -- 2019
				ln.y + 60, -- 2019
				ln.x + 11, -- 2019
				ln.y + 60, -- 2019
				3, -- 2019
				pole -- 2019
			) -- 2019
			seg( -- 2020
				d, -- 2020
				ln.x, -- 2020
				ln.y + 60, -- 2020
				ln.x, -- 2020
				ln.y + 58, -- 2020
				1.6, -- 2020
				pole -- 2020
			) -- 2020
			local bx = ln.x -- 2021
			local by = ln.y + 46 -- 2022
			local lit = state.lanternsLit[ln.id] == true -- 2023
			local alpha = 1 -- 2024
			if state.lanternFailed then -- 2024
				local flash = 0.5 + 0.5 * math.sin(time * 9) -- 2026
				alpha = lit and 0.5 + 0.5 * flash or 0.35 -- 2027
			end -- 2027
			if lit then -- 2027
				dot( -- 2030
					d, -- 2030
					bx, -- 2030
					by, -- 2030
					17, -- 2030
					ink(244, 196, 120, 42), -- 2030
					alpha -- 2030
				) -- 2030
				d:drawPolygon( -- 2031
					{ -- 2032
						Vec2(bx - 9, by + 11), -- 2032
						Vec2(bx + 9, by + 11), -- 2032
						Vec2(bx + 7.5, by - 11), -- 2032
						Vec2(bx - 7.5, by - 11) -- 2032
					}, -- 2032
					col( -- 2033
						ink(238, 178, 92, 150), -- 2033
						alpha -- 2033
					), -- 2033
					0, -- 2034
					Color(0, 0, 0, 0) -- 2035
				) -- 2035
				dot( -- 2037
					d, -- 2037
					bx, -- 2037
					by, -- 2037
					5, -- 2037
					ink(255, 232, 180, 220), -- 2037
					alpha -- 2037
				) -- 2037
			else -- 2037
				d:drawPolygon( -- 2039
					{ -- 2040
						Vec2(bx - 9, by + 11), -- 2040
						Vec2(bx + 9, by + 11), -- 2040
						Vec2(bx + 7.5, by - 11), -- 2040
						Vec2(bx - 7.5, by - 11) -- 2040
					}, -- 2040
					col(ink(58, 62, 60, 200)), -- 2041
					0, -- 2042
					Color(0, 0, 0, 0) -- 2043
				) -- 2043
			end -- 2043
			seg( -- 2046
				d, -- 2046
				bx - 9, -- 2046
				by + 11, -- 2046
				bx + 9, -- 2046
				by + 11, -- 2046
				2, -- 2046
				ink(120, 84, 44, 235), -- 2046
				alpha -- 2046
			) -- 2046
			seg( -- 2047
				d, -- 2047
				bx - 7.5, -- 2047
				by - 11, -- 2047
				bx + 7.5, -- 2047
				by - 11, -- 2047
				2, -- 2047
				ink(120, 84, 44, 235), -- 2047
				alpha -- 2047
			) -- 2047
			if state.lanternFailed and lit then -- 2047
				dot( -- 2049
					d, -- 2049
					bx, -- 2049
					by, -- 2049
					8, -- 2049
					ink(140, 59, 59, 90), -- 2049
					alpha -- 2049
				) -- 2049
			end -- 2049
		end -- 2049
		::__continue355:: -- 2049
	end -- 2049
end -- 2009
function WorldRenderer.prototype.drawCheckpoints(self, d, time, state) -- 2054
	for ____, cp in ipairs(self.data.checkpoints) do -- 2055
		do -- 2055
			if self:floorOfY(cp.y) ~= self.activeFloor then -- 2055
				goto __continue364 -- 2057
			end -- 2057
			if not self:inView(cp.x - 60, cp.y, cp.x + 60, cp.y + 90) then -- 2057
				goto __continue364 -- 2060
			end -- 2060
			if cp.id == "cp_riverbank" then -- 2060
				goto __continue364 -- 2063
			end -- 2063
			local active = state.checkpointsActivated[cp.id] == true -- 2065
			local stone = ink(44, 50, 48, 235) -- 2066
			d:drawPolygon( -- 2067
				{ -- 2068
					Vec2(cp.x - 7, cp.y + 40), -- 2068
					Vec2(cp.x + 7, cp.y + 40), -- 2068
					Vec2(cp.x + 8, cp.y), -- 2068
					Vec2(cp.x - 8, cp.y) -- 2068
				}, -- 2068
				col(stone), -- 2069
				0, -- 2070
				Color(0, 0, 0, 0) -- 2071
			) -- 2071
			dot( -- 2073
				d, -- 2073
				cp.x, -- 2073
				cp.y + 40, -- 2073
				7, -- 2073
				stone -- 2073
			) -- 2073
			seg( -- 2074
				d, -- 2074
				cp.x - 4, -- 2074
				cp.y + 28, -- 2074
				cp.x + 4, -- 2074
				cp.y + 28, -- 2074
				1.2, -- 2074
				PAPER_DIM, -- 2074
				0.8 -- 2074
			) -- 2074
			local fs = self.flagSets[cp.id] -- 2075
			if fs ~= nil then -- 2075
				fs.off.visible = not active -- 2078
				local frame = math.floor(time * 8) % #fs.on -- 2079
				do -- 2079
					local fi = 0 -- 2080
					while fi < #fs.on do -- 2080
						fs.on[fi + 1].visible = active and fi == frame -- 2081
						fi = fi + 1 -- 2080
					end -- 2080
				end -- 2080
				if active then -- 2080
					local pulse = time * 0.7 % 1 -- 2084
					circle( -- 2085
						d, -- 2085
						cp.x, -- 2085
						cp.y + 24, -- 2085
						14 + pulse * 30, -- 2085
						CYAN, -- 2085
						16, -- 2085
						(1 - pulse) * 0.5 -- 2085
					) -- 2085
				end -- 2085
			else -- 2085
				seg( -- 2088
					d, -- 2088
					cp.x + 10, -- 2088
					cp.y, -- 2088
					cp.x + 10, -- 2088
					cp.y + 64, -- 2088
					2.6, -- 2088
					ink(70, 60, 46, 235) -- 2088
				) -- 2088
				if active then -- 2088
					local flap = math.sin(time * 3) * 2 -- 2091
					d:drawPolygon( -- 2092
						{ -- 2093
							Vec2(cp.x + 10, cp.y + 64), -- 2093
							Vec2(cp.x + 32, cp.y + 60 + flap), -- 2093
							Vec2(cp.x + 32, cp.y + 50 + flap), -- 2093
							Vec2(cp.x + 10, cp.y + 54) -- 2093
						}, -- 2093
						col(CYAN, 0.8), -- 2094
						0, -- 2095
						Color(0, 0, 0, 0) -- 2096
					) -- 2096
					seg( -- 2098
						d, -- 2098
						cp.x + 10, -- 2098
						cp.y + 54, -- 2098
						cp.x + 32, -- 2098
						cp.y + 50 + flap, -- 2098
						1.2, -- 2098
						CYAN, -- 2098
						0.5 -- 2098
					) -- 2098
					local pulse = time * 0.7 % 1 -- 2099
					circle( -- 2100
						d, -- 2100
						cp.x, -- 2100
						cp.y + 24, -- 2100
						14 + pulse * 30, -- 2100
						CYAN, -- 2100
						16, -- 2100
						(1 - pulse) * 0.5 -- 2100
					) -- 2100
				else -- 2100
					seg( -- 2102
						d, -- 2102
						cp.x + 10, -- 2102
						cp.y + 64, -- 2102
						cp.x + 13, -- 2102
						cp.y + 50, -- 2102
						5, -- 2102
						Palette.inkSoft, -- 2102
						0.85 -- 2102
					) -- 2102
				end -- 2102
			end -- 2102
		end -- 2102
		::__continue364:: -- 2102
	end -- 2102
end -- 2054
function WorldRenderer.prototype.drawCollectibles(self, d, time, state) -- 2108
	for ____, c in ipairs(self.data.collectibles) do -- 2109
		do -- 2109
			if self:floorOfY(c.y) ~= self.activeFloor then -- 2109
				goto __continue377 -- 2111
			end -- 2111
			if c.loops ~= nil and __TS__ArrayIndexOf(c.loops, state.loopIndex) < 0 then -- 2111
				local gone1 = self.lampStoneSprites[c.id] -- 2114
				if gone1 ~= nil then -- 2114
					gone1.visible = false -- 2116
				end -- 2116
				local gone1m = self.moonStoneSprites[c.id] -- 2118
				if gone1m ~= nil then -- 2118
					gone1m.visible = false -- 2120
				end -- 2120
				local gone1d = self.dewSprites[c.id] -- 2122
				if gone1d ~= nil then -- 2122
					gone1d.visible = false -- 2124
				end -- 2124
				local gone1t = self.tokenSprites[c.id] -- 2126
				if gone1t ~= nil then -- 2126
					gone1t.visible = false -- 2128
				end -- 2128
				goto __continue377 -- 2130
			end -- 2130
			if state.collectedIds[c.id] == true then -- 2130
				local gone2 = self.lampStoneSprites[c.id] -- 2133
				if gone2 ~= nil then -- 2133
					gone2.visible = false -- 2135
				end -- 2135
				local gone2m = self.moonStoneSprites[c.id] -- 2137
				if gone2m ~= nil then -- 2137
					gone2m.visible = false -- 2139
				end -- 2139
				local gone2d = self.dewSprites[c.id] -- 2141
				if gone2d ~= nil then -- 2141
					gone2d.visible = false -- 2143
				end -- 2143
				local gone2t = self.tokenSprites[c.id] -- 2145
				if gone2t ~= nil then -- 2145
					gone2t.visible = false -- 2147
				end -- 2147
				goto __continue377 -- 2149
			end -- 2149
			if not self:inView(c.x - 40, c.y - 10, c.x + 40, c.y + 40) then -- 2149
				goto __continue377 -- 2152
			end -- 2152
			local bob = math.sin(time * 2 + c.x * 0.1) * 3 -- 2154
			local cx = c.x -- 2155
			local cy = c.y + bob -- 2156
			if c.kind == "lampstone" then -- 2156
				local ls = self.lampStoneSprites[c.id] -- 2159
				if ls ~= nil then -- 2159
					ls.visible = true -- 2161
					ls.position = Vec2(cx, cy + 18) -- 2162
				else -- 2162
					circle( -- 2164
						d, -- 2164
						cx, -- 2164
						cy + 14, -- 2164
						13, -- 2164
						GOLD, -- 2164
						18, -- 2164
						0.22 -- 2164
					) -- 2164
					d:drawPolygon( -- 2165
						{ -- 2166
							Vec2(cx - 7, cy + 6), -- 2166
							Vec2(cx + 7, cy + 6), -- 2166
							Vec2(cx + 4, cy + 22), -- 2166
							Vec2(cx - 4, cy + 22) -- 2166
						}, -- 2166
						col(ink(196, 168, 108, 235)), -- 2167
						0, -- 2168
						Color(0, 0, 0, 0) -- 2169
					) -- 2169
					dot( -- 2171
						d, -- 2171
						cx, -- 2171
						cy + 14, -- 2171
						3.4, -- 2171
						Palette.moonWhite, -- 2171
						0.9 -- 2171
					) -- 2171
				end -- 2171
			elseif c.kind == "moonstone" then -- 2171
				local ms = self.moonStoneSprites[c.id] -- 2175
				if ms ~= nil then -- 2175
					ms.visible = true -- 2177
					ms.position = Vec2(cx, cy + 18) -- 2178
				else -- 2178
					dot( -- 2180
						d, -- 2180
						cx, -- 2180
						cy + 12, -- 2180
						13, -- 2180
						CYAN, -- 2180
						0.25 -- 2180
					) -- 2180
					dot( -- 2181
						d, -- 2181
						cx, -- 2181
						cy + 12, -- 2181
						6.5, -- 2181
						CYAN -- 2181
					) -- 2181
					dot( -- 2182
						d, -- 2182
						cx - 2, -- 2182
						cy + 14, -- 2182
						2, -- 2182
						Palette.moonWhite, -- 2182
						0.9 -- 2182
					) -- 2182
				end -- 2182
			elseif c.kind == "mechanism" then -- 2182
				local rot = time * 1.2 -- 2185
				circle( -- 2186
					d, -- 2186
					cx, -- 2186
					cy + 10, -- 2186
					7, -- 2186
					GOLD, -- 2186
					12, -- 2186
					0.95 -- 2186
				) -- 2186
				do -- 2186
					local i = 0 -- 2187
					while i < 6 do -- 2187
						local a = rot + i / 6 * math.pi * 2 -- 2188
						seg( -- 2189
							d, -- 2189
							cx + math.cos(a) * 7, -- 2189
							cy + 10 + math.sin(a) * 7, -- 2189
							cx + math.cos(a) * 10.5, -- 2189
							cy + 10 + math.sin(a) * 10.5, -- 2189
							2.2, -- 2189
							GOLD, -- 2189
							0.95 -- 2189
						) -- 2189
						i = i + 1 -- 2187
					end -- 2187
				end -- 2187
				dot( -- 2191
					d, -- 2191
					cx, -- 2191
					cy + 10, -- 2191
					2.2, -- 2191
					GOLD, -- 2191
					0.9 -- 2191
				) -- 2191
			elseif c.kind == "token" then -- 2191
				local tk = self.tokenSprites[c.id] -- 2194
				if tk ~= nil then -- 2194
					tk.visible = true -- 2196
					tk.position = Vec2(cx, cy + 18) -- 2197
				else -- 2197
					d:drawPolygon( -- 2199
						{ -- 2200
							Vec2(cx - 7, cy + 16), -- 2200
							Vec2(cx + 7, cy + 16), -- 2200
							Vec2(cx + 7, cy + 4), -- 2200
							Vec2(cx - 7, cy + 4) -- 2200
						}, -- 2200
						col(ink(112, 84, 56, 225)), -- 2201
						0, -- 2202
						Color(0, 0, 0, 0) -- 2203
					) -- 2203
					circle( -- 2205
						d, -- 2205
						cx, -- 2205
						cy + 20, -- 2205
						3.2, -- 2205
						Palette.inkDark, -- 2205
						8, -- 2205
						0.9 -- 2205
					) -- 2205
					seg( -- 2206
						d, -- 2206
						cx - 3.5, -- 2206
						cy + 12, -- 2206
						cx + 3.5, -- 2206
						cy + 12, -- 2206
						1, -- 2206
						PAPER_DIM, -- 2206
						0.9 -- 2206
					) -- 2206
				end -- 2206
			else -- 2206
				local dw = self.dewSprites[c.id] -- 2210
				if dw ~= nil then -- 2210
					dw.visible = true -- 2212
					dw.position = Vec2(cx, cy + 18) -- 2213
				else -- 2213
					dot( -- 2215
						d, -- 2215
						cx, -- 2215
						cy + 8, -- 2215
						5.5, -- 2215
						CYAN, -- 2215
						0.75 -- 2215
					) -- 2215
					d:drawPolygon( -- 2216
						{ -- 2217
							Vec2(cx, cy + 18), -- 2217
							Vec2(cx + 3.4, cy + 10), -- 2217
							Vec2(cx - 3.4, cy + 10) -- 2217
						}, -- 2217
						col(CYAN, 0.75), -- 2218
						0, -- 2219
						Color(0, 0, 0, 0) -- 2220
					) -- 2220
					dot( -- 2222
						d, -- 2222
						cx - 1.6, -- 2222
						cy + 7.5, -- 2222
						1.6, -- 2222
						Palette.moonWhite, -- 2222
						0.9 -- 2222
					) -- 2222
				end -- 2222
			end -- 2222
		end -- 2222
		::__continue377:: -- 2222
	end -- 2222
end -- 2108
function WorldRenderer.prototype.drawDecor(self, d, time) -- 2229
	if self.activeFloor == 4 and self:inView(500, FLOOR_TOPS[5], 2100, FLOOR_TOPS[5] + 160) then -- 2229
		self:drawGear( -- 2231
			d, -- 2231
			800, -- 2231
			FLOOR_TOPS[5] + 80, -- 2231
			46, -- 2231
			18, -- 2231
			time * 0.35 -- 2231
		) -- 2231
		self:drawGear( -- 2232
			d, -- 2232
			1800, -- 2232
			FLOOR_TOPS[5] + 80, -- 2232
			34, -- 2232
			14, -- 2232
			-time * 0.5 + 0.4 -- 2232
		) -- 2232
	end -- 2232
	if self.activeFloor == 6 and self:inView(900, FLOOR_TOPS[7] - 90, 1500, FLOOR_TOPS[7] + 310) then -- 2232
		local cx = 1200 -- 2235
		local cy = FLOOR_TOPS[7] + 180 -- 2236
		circle( -- 2237
			d, -- 2237
			cx, -- 2237
			cy, -- 2237
			34, -- 2237
			GOLD, -- 2237
			24, -- 2237
			0.5 -- 2237
		) -- 2237
		circle( -- 2238
			d, -- 2238
			cx, -- 2238
			cy, -- 2238
			22, -- 2238
			GOLD, -- 2238
			20, -- 2238
			0.65 -- 2238
		) -- 2238
		arc( -- 2239
			d, -- 2239
			cx, -- 2239
			cy, -- 2239
			28, -- 2239
			time * 0.4, -- 2239
			time * 0.4 + math.pi * 1.4, -- 2239
			14, -- 2239
			2, -- 2239
			CYAN, -- 2239
			0.7 -- 2239
		) -- 2239
		do -- 2239
			local i = 0 -- 2240
			while i < 12 do -- 2240
				local a = i / 12 * math.pi * 2 + time * 0.05 -- 2241
				seg( -- 2242
					d, -- 2242
					cx + math.cos(a) * 34, -- 2242
					cy + math.sin(a) * 34, -- 2242
					cx + math.cos(a) * 39, -- 2242
					cy + math.sin(a) * 39, -- 2242
					1.6, -- 2242
					GOLD, -- 2242
					0.6 -- 2242
				) -- 2242
				i = i + 1 -- 2240
			end -- 2240
		end -- 2240
		dot( -- 2244
			d, -- 2244
			cx, -- 2244
			cy, -- 2244
			3.4, -- 2244
			CYAN, -- 2244
			0.9 -- 2244
		) -- 2244
	end -- 2244
	if self.activeFloor == 6 and self:inView(1900, FLOOR_TOPS[7] - 40, 2300, FLOOR_TOPS[7] + 260) then -- 2244
		local cx = 2100 -- 2247
		local cy = FLOOR_TOPS[7] + 100 -- 2248
		circle( -- 2249
			d, -- 2249
			cx, -- 2249
			cy, -- 2249
			46, -- 2249
			GOLD, -- 2249
			28, -- 2249
			0.55 -- 2249
		) -- 2249
		circle( -- 2250
			d, -- 2250
			cx, -- 2250
			cy, -- 2250
			34, -- 2250
			GOLD, -- 2250
			24, -- 2250
			0.7 -- 2250
		) -- 2250
		circle( -- 2251
			d, -- 2251
			cx, -- 2251
			cy, -- 2251
			22, -- 2251
			GOLD, -- 2251
			20, -- 2251
			0.85 -- 2251
		) -- 2251
		dot( -- 2252
			d, -- 2252
			cx, -- 2252
			cy, -- 2252
			8, -- 2252
			CYAN, -- 2252
			0.85 + 0.15 * math.sin(time * 2.4) -- 2252
		) -- 2252
		local oa = time * 1.1 -- 2253
		local ox = cx + math.cos(oa) * 22 -- 2254
		local oy = cy + math.sin(oa) * 22 -- 2255
		dot( -- 2256
			d, -- 2256
			ox, -- 2256
			oy, -- 2256
			8, -- 2256
			CYAN, -- 2256
			0.3 -- 2256
		) -- 2256
		dot( -- 2257
			d, -- 2257
			ox, -- 2257
			oy, -- 2257
			4, -- 2257
			Palette.moonWhite, -- 2257
			0.95 -- 2257
		) -- 2257
	end -- 2257
end -- 2229
function WorldRenderer.prototype.drawGear(self, d, cx, cy, r, teeth, rot) -- 2261
	local c = ink(70, 62, 50, 200) -- 2262
	circle( -- 2263
		d, -- 2263
		cx, -- 2263
		cy, -- 2263
		r * 0.62, -- 2263
		c, -- 2263
		20, -- 2263
		0.9 -- 2263
	) -- 2263
	do -- 2263
		local i = 0 -- 2264
		while i < teeth do -- 2264
			local a = rot + i / teeth * math.pi * 2 -- 2265
			seg( -- 2266
				d, -- 2266
				cx + math.cos(a) * r * 0.62, -- 2266
				cy + math.sin(a) * r * 0.62, -- 2266
				cx + math.cos(a) * r, -- 2266
				cy + math.sin(a) * r, -- 2266
				3.4, -- 2266
				c, -- 2266
				0.95 -- 2266
			) -- 2266
			i = i + 1 -- 2264
		end -- 2264
	end -- 2264
	do -- 2264
		local i = 0 -- 2268
		while i < 4 do -- 2268
			local a = rot + i / 4 * math.pi * 2 -- 2269
			seg( -- 2270
				d, -- 2270
				cx, -- 2270
				cy, -- 2270
				cx + math.cos(a) * r * 0.5, -- 2270
				cy + math.sin(a) * r * 0.5, -- 2270
				2.2, -- 2270
				c, -- 2270
				0.6 -- 2270
			) -- 2270
			i = i + 1 -- 2268
		end -- 2268
	end -- 2268
	dot( -- 2272
		d, -- 2272
		cx, -- 2272
		cy, -- 2272
		3.6, -- 2272
		c, -- 2272
		0.95 -- 2272
	) -- 2272
end -- 2261
function WorldRenderer.prototype.syncBossWaveSprites(self, enemies) -- 2277
	if not self.bossWaveChecked then -- 2277
		self.bossWaveChecked = true -- 2279
		self.bossWaveTex = self:loadTex("assets/effects/slash_blue.png") -- 2280
	end -- 2280
	local tex = self.bossWaveTex -- 2282
	if tex == nil then -- 2282
		return false -- 2284
	end -- 2284
	local waves = enemies.waves -- 2286
	local frames = math.max( -- 2287
		1, -- 2287
		math.floor(tex.width / 64) -- 2287
	) -- 2287
	while #self.bossWaveSprites > #waves do -- 2287
		local sp = table.remove(self.bossWaveSprites) -- 2289
		if sp ~= nil then -- 2289
			sp:removeFromParent() -- 2291
		end -- 2291
	end -- 2291
	while #self.bossWaveSprites < #waves do -- 2291
		local created = Sprite( -- 2295
			tex, -- 2295
			Rect( -- 2295
				math.floor(frames / 2) * 64, -- 2295
				0, -- 2295
				64, -- 2295
				64 -- 2295
			) -- 2295
		) -- 2295
		if created == nil then -- 2295
			return false -- 2297
		end -- 2297
		created.filter = "Point" -- 2299
		created:addTo(self.waveSpriteRoot) -- 2300
		local ____self_bossWaveSprites_11 = self.bossWaveSprites -- 2300
		____self_bossWaveSprites_11[#____self_bossWaveSprites_11 + 1] = created -- 2301
	end -- 2301
	local k = 92 / 64 -- 2304
	do -- 2304
		local i = 0 -- 2305
		while i < #self.bossWaveSprites do -- 2305
			local sp = self.bossWaveSprites[i + 1] -- 2306
			local wv = waves[i + 1] -- 2307
			sp.position = Vec2(wv.x, wv.y + 20) -- 2308
			sp.scaleX = (wv.dir >= 0 and 1 or -1) * k -- 2309
			sp.scaleY = k -- 2310
			sp.opacity = wv.life < 0.4 and math.floor(255 * (wv.life / 0.4)) or 255 -- 2311
			i = i + 1 -- 2305
		end -- 2305
	end -- 2305
	return true -- 2313
end -- 2277
function WorldRenderer.prototype.drawArrow(self, d, x, y, vx, vy) -- 2317
	local lenRaw = math.sqrt(vx * vx + vy * vy) -- 2318
	local len = lenRaw > 0.0001 and lenRaw or 1 -- 2319
	local ux = vx / len -- 2320
	local uy = vy / len -- 2321
	seg( -- 2322
		d, -- 2322
		x - ux * 12, -- 2322
		y - uy * 12, -- 2322
		x + ux * 6, -- 2322
		y + uy * 6, -- 2322
		2.2, -- 2322
		ink(196, 188, 168, 235) -- 2322
	) -- 2322
	dot( -- 2323
		d, -- 2323
		x + ux * 7, -- 2323
		y + uy * 7, -- 2323
		2.4, -- 2323
		ink(244, 240, 226, 255) -- 2323
	) -- 2323
end -- 2317
function WorldRenderer.prototype.drawChars(self, time, state, player, enemies, mech, dt) -- 2327
	local d = self.charDraw -- 2328
	d:clear() -- 2329
	self.ninja:beginFrame(dt) -- 2330
	for ____, p in ipairs(enemies.pots) do -- 2331
		do -- 2331
			if not p.alive then -- 2331
				goto __continue428 -- 2333
			end -- 2333
			if self:inView(p.x - 20, p.y - 20, p.x + 20, p.y + 20) then -- 2333
				drawPot(d, p.x, p.y, time) -- 2336
			end -- 2336
		end -- 2336
		::__continue428:: -- 2336
	end -- 2336
	if not self:syncBossWaveSprites(enemies) then -- 2336
		for ____, wv in ipairs(enemies.waves) do -- 2341
			if self:inView(wv.x - 40, wv.y - 20, wv.x + 40, wv.y + 50) then -- 2341
				drawWave( -- 2343
					d, -- 2343
					wv.x, -- 2343
					wv.y, -- 2343
					wv.dir, -- 2343
					time -- 2343
				) -- 2343
			end -- 2343
		end -- 2343
	end -- 2343
	for ____, ar in ipairs(enemies.arrows) do -- 2348
		do -- 2348
			if not ar.alive then -- 2348
				goto __continue436 -- 2350
			end -- 2350
			if self:inView(ar.x - 30, ar.y - 30, ar.x + 30, ar.y + 30) then -- 2350
				self:drawArrow( -- 2353
					d, -- 2353
					ar.x, -- 2353
					ar.y, -- 2353
					ar.vx, -- 2353
					ar.vy -- 2353
				) -- 2353
			end -- 2353
		end -- 2353
		::__continue436:: -- 2353
	end -- 2353
	for ____, e in ipairs(enemies.enemies) do -- 2356
		do -- 2356
			if e.dead and e.deathTimer <= 0 then -- 2356
				goto __continue440 -- 2358
			end -- 2358
			if self:floorOfY(e.body.y) ~= self.activeFloor then -- 2358
				goto __continue440 -- 2362
			end -- 2362
			if self:inView(e.body.x - 60, e.body.y - e.body.h / 2, e.body.x + 60, e.body.y + e.body.h / 2) then -- 2362
				if not self.ninja:drawEnemy(e) then -- 2362
					drawEnemy(d, e, e.animTime) -- 2366
				end -- 2366
			end -- 2366
		end -- 2366
		::__continue440:: -- 2366
	end -- 2366
	self.ninja:endFrame() -- 2370
	do -- 2370
		local si = 0 -- 2371
		while si < #mech.stones do -- 2371
			do -- 2371
				local s = mech.stones[si + 1] -- 2372
				local inR = self:inView(s.x - 40, s.y - 40, s.x + 40, s.y + 40) -- 2373
				if si < #self.stoneSprites then -- 2373
					local sp = self.stoneSprites[si + 1] -- 2376
					sp.visible = inR -- 2377
					if inR then -- 2377
						sp.position = Vec2(s.x, s.y) -- 2379
					end -- 2379
					goto __continue447 -- 2381
				end -- 2381
				if not inR then -- 2381
					goto __continue447 -- 2384
				end -- 2384
				d:drawPolygon( -- 2386
					{ -- 2387
						Vec2(s.x - s.w / 2, s.y + s.h / 2), -- 2388
						Vec2(s.x + s.w / 2, s.y + s.h / 2), -- 2389
						Vec2(s.x + s.w / 2 - 2, s.y - s.h / 2), -- 2390
						Vec2(s.x - s.w / 2 + 2, s.y - s.h / 2) -- 2391
					}, -- 2391
					col(ink(58, 54, 48, 235)), -- 2393
					0, -- 2394
					Color(0, 0, 0, 0) -- 2395
				) -- 2395
				seg( -- 2397
					d, -- 2397
					s.x - s.w / 2 + 6, -- 2397
					s.y + s.h / 2 - 6, -- 2397
					s.x, -- 2397
					s.y - s.h / 2 + 8, -- 2397
					1.4, -- 2397
					ink(40, 37, 33, 120) -- 2397
				) -- 2397
				dot( -- 2398
					d, -- 2398
					s.x - s.w / 4, -- 2398
					s.y + s.h / 4, -- 2398
					2.4, -- 2398
					PAPER_DIM, -- 2398
					0.8 -- 2398
				) -- 2398
			end -- 2398
			::__continue447:: -- 2398
			si = si + 1 -- 2371
		end -- 2371
	end -- 2371
	do -- 2371
		local si = #mech.stones -- 2401
		while si < #self.stoneSprites do -- 2401
			self.stoneSprites[si + 1].visible = false -- 2402
			si = si + 1 -- 2401
		end -- 2401
	end -- 2401
	if self.shenYan ~= nil then -- 2401
		local sy = self.shenYan -- 2405
		if self:floorOfY(sy.y) == self.activeFloor and self:inView(sy.x - 60, sy.y - 20, sy.x + 60, sy.y + 100) then -- 2405
			drawShenYan( -- 2407
				d, -- 2407
				sy.x, -- 2407
				sy.y, -- 2407
				sy.facing, -- 2407
				time, -- 2407
				sy.hostile -- 2407
			) -- 2407
		end -- 2407
	end -- 2407
	if self.observer ~= nil then -- 2407
		local ob = self.observer -- 2411
		if self:floorOfY(ob.y) == self.activeFloor and self:inView(ob.x - 50, ob.y, ob.x + 50, ob.y + 130) then -- 2411
			drawObserver(d, ob.x, ob.y, time) -- 2413
		end -- 2413
	end -- 2413
	local px = player.body.x -- 2416
	local py = player.body.y - player.body.h / 2 -- 2417
	local pose = self:heroPose(player) -- 2418
	local visible = self:inView(px - 80, py - 20, px + 80, py + 120) -- 2420
	local animT = pose == "ladder" and player.climbT or player.animTime -- 2422
	if self.heroTexOk then -- 2422
		self:updateHeroSprite( -- 2424
			px, -- 2424
			py, -- 2424
			player.facing, -- 2424
			pose, -- 2424
			animT, -- 2424
			state.phaseIndex, -- 2424
			visible, -- 2424
			dt -- 2424
		) -- 2424
	elseif visible then -- 2424
		drawHero( -- 2426
			d, -- 2426
			px, -- 2426
			py, -- 2426
			player.facing, -- 2426
			pose, -- 2426
			animT, -- 2426
			state.phaseIndex -- 2426
		) -- 2426
	end -- 2426
end -- 2327
function WorldRenderer.prototype.updateHeroSprite(self, x, y, facing, pose, t, phaseIndex, visible, dt) -- 2431
	local sp = self.heroSprite -- 2441
	local f = self.heroFxDraw -- 2442
	f:clear() -- 2443
	self:updateGhosts(dt) -- 2444
	if not visible then -- 2444
		if sp ~= nil then -- 2444
			sp.visible = false -- 2447
		end -- 2447
		self.heroFrames:hideAll() -- 2449
		return -- 2450
	end -- 2450
	local fr = self.heroFrames:pick(pose, t) -- 2453
	if fr ~= nil then -- 2453
		if sp ~= nil then -- 2453
			sp.visible = false -- 2456
		end -- 2456
		self.heroFrames:hideAll() -- 2458
		fr.sp.visible = true -- 2459
		local bobF = 0 -- 2460
		if pose == "jump" then -- 2460
			bobF = 2 -- 2462
		elseif pose == "fall" then -- 2462
			bobF = -2 -- 2464
		end -- 2464
		fr.sp.position = Vec2(x, y + bobF) -- 2466
		fr.sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT and 1 or -1) -- 2467
		fr.sp.scaleY = fr.scale -- 2468
		if self.ghostCd <= 0 and (pose == "dash" or pose == "jump" or pose == "fall") then -- 2468
			self:spawnGhost(fr, x, y + bobF, facing) -- 2471
			self.ghostCd = GHOST_INTERVAL -- 2472
		end -- 2472
		self:drawHeroFx( -- 2474
			f, -- 2474
			x, -- 2474
			y, -- 2474
			facing, -- 2474
			pose, -- 2474
			t, -- 2474
			phaseIndex, -- 2474
			0 -- 2474
		) -- 2474
		return -- 2475
	end -- 2475
	self.heroFrames:hideAll() -- 2477
	if sp == nil then -- 2477
		self:drawHeroFx( -- 2479
			f, -- 2479
			x, -- 2479
			y, -- 2479
			facing, -- 2479
			pose, -- 2479
			t, -- 2479
			phaseIndex, -- 2479
			0 -- 2479
		) -- 2479
		return -- 2480
	end -- 2480
	sp.visible = true -- 2482
	local bob = 0 -- 2483
	if pose == "idle" then -- 2483
		bob = math.sin(t * 2) * 1.6 -- 2485
	elseif pose == "run" then -- 2485
		bob = -math.abs(math.sin(t * 12)) * 2.2 -- 2487
	elseif pose == "jump" then -- 2487
		bob = 2.5 -- 2489
	elseif pose == "fall" then -- 2489
		bob = -1.5 -- 2491
	end -- 2491
	sp.position = Vec2(x, y + bob) -- 2493
	sp.scaleX = self.heroScale * facing -- 2494
	sp.scaleY = self.heroScale -- 2495
	self:drawHeroFx( -- 2496
		f, -- 2496
		x, -- 2496
		y, -- 2496
		facing, -- 2496
		pose, -- 2496
		t, -- 2496
		phaseIndex, -- 2496
		bob -- 2496
	) -- 2496
end -- 2431
function WorldRenderer.prototype.drawHeroFx(self, f, x, y, _facing, pose, _t, _phaseIndex, _bob) -- 2502
	if pose == "hurt" then -- 2502
		dot( -- 2515
			f, -- 2515
			x, -- 2515
			y + 46, -- 2515
			26, -- 2515
			ink(220, 70, 60, 160), -- 2515
			0.5 -- 2515
		) -- 2515
	end -- 2515
end -- 2502
function WorldRenderer.prototype.updateGhosts(self, dt) -- 2520
	if self.ghostCd > 0 then -- 2520
		self.ghostCd = self.ghostCd - dt -- 2522
	end -- 2522
	local i = #self.ghosts - 1 -- 2524
	while i >= 0 do -- 2524
		local g = self.ghosts[i + 1] -- 2526
		g.t = g.t + dt -- 2527
		if g.t >= g.dur then -- 2527
			g.sp:removeFromParent() -- 2529
			__TS__ArraySplice(self.ghosts, i, 1) -- 2530
		else -- 2530
			g.sp.opacity = GHOST_ALPHA * (1 - g.t / g.dur) -- 2532
		end -- 2532
		i = i - 1 -- 2534
	end -- 2534
end -- 2520
function WorldRenderer.prototype.spawnGhost(self, fr, x, y, facing) -- 2539
	if #self.ghosts >= GHOST_MAX then -- 2539
		return -- 2541
	end -- 2541
	local tex = fr.sp.texture -- 2543
	if tex == nil then -- 2543
		return -- 2545
	end -- 2545
	local sp = Sprite(tex) -- 2547
	if sp == nil then -- 2547
		return -- 2549
	end -- 2549
	sp.anchor = Vec2(0.5, 0) -- 2551
	sp.position = Vec2(x - facing * GHOST_OFFSET, y) -- 2552
	sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT and 1 or -1) -- 2553
	sp.scaleY = fr.scale -- 2554
	sp.color = Color(GHOST_TINT_R, GHOST_TINT_G, GHOST_TINT_B, 255) -- 2555
	sp.opacity = GHOST_ALPHA -- 2556
	sp:addTo(self.ghostRoot) -- 2557
	local ____self_ghosts_12 = self.ghosts -- 2557
	____self_ghosts_12[#____self_ghosts_12 + 1] = {sp = sp, t = 0, dur = GHOST_DUR} -- 2558
end -- 2539
function WorldRenderer.prototype.heroPose(self, p) -- 2561
	if p.onLadder then -- 2561
		return "ladder" -- 2563
	end -- 2563
	local a = p.anim -- 2565
	if a == "wallslide" then -- 2565
		return "cling" -- 2567
	end -- 2567
	if a == "climb" then -- 2567
		return "ladder" -- 2570
	end -- 2570
	if a == "attack" then -- 2570
		local idx = p.attackIndex -- 2573
		return idx <= 0 and "attack1" or (idx == 1 and "attack2" or (idx == 2 and "attack3" or "heavy")) -- 2574
	end -- 2574
	if a == "land" then -- 2574
		return "idle" -- 2577
	end -- 2577
	return a -- 2579
end -- 2561
return ____exports -- 2561