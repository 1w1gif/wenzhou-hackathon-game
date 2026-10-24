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
local GOLD = ink(212, 168, 84, 255) -- 127
local CYAN = ink(108, 156, 148, 255) -- 128
local PAPER_DIM = ink(219, 208, 184, 120) -- 129
local TILE = 64 -- 162
local TILE_SETS = { -- 163
	"autumn", -- 163
	"autumn", -- 163
	"skyruins", -- 163
	"skyruins", -- 163
	"skyruins", -- 163
	"skyruins", -- 163
	"skyruins" -- 163
} -- 163
local FLOOR_TOPS = { -- 167
	220, -- 167
	1500, -- 167
	2800, -- 167
	4100, -- 167
	5400, -- 167
	6700, -- 167
	8000 -- 167
} -- 167
local BG_AUTUMN = {{path = "assets/bg/autumn_layer0.png", f = 0.12, baseUp = 0}, {path = "assets/bg/autumn_layer1.png", f = 0.26, baseUp = 0}} -- 177
local BG_SKYRUINS = {{path = "assets/bg/skyruins_layer0.png", f = 0.12, baseUp = 0}, {path = "assets/bg/skyruins_layer1.png", f = 0.26, baseUp = 0}} -- 181
local BG_RIVERSIDE = { -- 186
	{path = "assets/bg/river_sky.png", f = 0.06, baseUp = 0}, -- 187
	{path = "assets/bg/river_clouds1.png", f = 0.12, baseUp = 0}, -- 188
	{path = "assets/bg/river_clouds2.png", f = 0.18, baseUp = 0}, -- 189
	{path = "assets/bg/river_rocks.png", f = 0.28, baseUp = 0}, -- 190
	{path = "assets/bg/river_ground.png", f = 0.36, baseUp = 0} -- 191
} -- 191
local BG_TOWERSIDE = { -- 194
	{path = "assets/bg/dusk/sky.png", f = 0.05, baseUp = 0}, -- 195
	{path = "assets/bg/dusk/far_clouds.png", f = 0.1, baseUp = 0}, -- 196
	{path = "assets/bg/dusk/far_mountains.png", f = 0.16, baseUp = 0}, -- 197
	{path = "assets/bg/dusk/mountains.png", f = 0.24, baseUp = 0}, -- 198
	{path = "assets/bg/dusk/near_clouds.png", f = 0.3, baseUp = 0}, -- 199
	{path = "assets/bg/dusk/trees.png", f = 0.38, baseUp = 0} -- 200
} -- 200
local BG_MOONNIGHT = {{path = "assets/bg/moon_far.png", f = 0.08, baseUp = 0}, {path = "assets/bg/moon_mid.png", f = 0.18, baseUp = 0}, {path = "assets/bg/moon_big.png", f = 0.3, baseUp = 0}} -- 203
local BG_LAYERS = { -- 208
	BG_AUTUMN, -- 209
	BG_RIVERSIDE, -- 210
	BG_SKYRUINS, -- 211
	BG_TOWERSIDE, -- 212
	{}, -- 213
	BG_SKYRUINS, -- 214
	BG_MOONNIGHT -- 215
} -- 215
local function styleAllowsDecor(style, path) -- 223
	if style == "skyruins" then -- 223
		return path == "assets/tiles/skyruins_magicstone.png" or path == "assets/tiles/skyruins_portal.png" -- 225
	end -- 225
	return false -- 227
end -- 223
local function waveY(wx, time, i) -- 230
	return math.sin(wx * 0.018 + time * 1.7 + i * 2.1) * 2.6 + math.sin(wx * 0.006 - time * 0.8 + i) * 1.6 -- 231
end -- 230
____exports.WorldRenderer = __TS__Class() -- 234
local WorldRenderer = ____exports.WorldRenderer -- 234
WorldRenderer.name = "WorldRenderer" -- 234
function WorldRenderer.prototype.____constructor(self, parent, data) -- 313
	self.bgRecs = {} -- 250
	self.activeFloor = 0 -- 254
	self.sceneFloorHolders = {} -- 255
	self.decorFloorHolders = {} -- 256
	self.propSpriteFloorHolders = {} -- 257
	self.bgBands = {} -- 258
	self.tileGroups = {} -- 259
	self.promptW = 0 -- 265
	self.promptH = 0 -- 266
	self.promptText = "" -- 267
	self.promptX = 0 -- 268
	self.promptY = 0 -- 269
	self.promptShown = false -- 271
	self.promptPopT = 0 -- 272
	self.promptHideT = 0 -- 273
	self.promptAnimT = 0 -- 274
	self.promptRelayoutT = 0 -- 275
	self.heroTexOk = false -- 280
	self.heroScale = 0.065 -- 281
	self.ghosts = {} -- 285
	self.ghostCd = 0 -- 286
	self.pixelBgOk = false -- 290
	self.activeBand = -1 -- 291
	self.sceneBand = 0 -- 292
	self.portalNodes = {} -- 293
	self.stoneSprites = {} -- 298
	self.bossWaveSprites = {} -- 301
	self.bossWaveChecked = false -- 303
	self.lampStoneSprites = {} -- 304
	self.moonStoneSprites = {} -- 305
	self.dewSprites = {} -- 306
	self.tokenSprites = {} -- 307
	self.flagSets = {} -- 308
	self.texCache = {} -- 309
	self.puzzleBuilt = false -- 831
	self.barrelT = 0 -- 832
	self.barrelLeft = false -- 833
	self.data = data -- 314
	self.parent = parent -- 315
	self.camX = 0 -- 316
	self.camY = 0 -- 317
	self.vw = View.size.width -- 318
	self.vh = View.size.height -- 319
	self.shenYan = nil -- 320
	self.observer = nil -- 321
	self.stars = {} -- 322
	do -- 322
		local i = 0 -- 323
		while i < 42 do -- 323
			local ____self_stars_0 = self.stars -- 323
			____self_stars_0[#____self_stars_0 + 1] = {x = i * 617 % 2600, y = 60 + i * 149 % 330, s = 0.5 + i * 37 % 10 / 14} -- 324
			i = i + 1 -- 323
		end -- 323
	end -- 323
	self.gateParts = {} -- 330
	local byId = {} -- 331
	for ____, p in ipairs(data.platforms) do -- 332
		if p.kind == "gate" and p.gateId ~= nil then -- 332
			local list = byId[p.gateId] -- 334
			if list == nil then -- 334
				byId[p.gateId] = {p} -- 336
			else -- 336
				list[#list + 1] = p -- 338
			end -- 338
		end -- 338
	end -- 338
	for ____, g in ipairs(data.gates) do -- 342
		local ____self_gateParts_1 = self.gateParts -- 342
		____self_gateParts_1[#____self_gateParts_1 + 1] = {gid = g.id, rects = byId[g.id] == nil and ({}) or byId[g.id]} -- 343
	end -- 343
	self.bgSpriteRoot = Node() -- 345
	self.bgSpriteRoot:addTo(parent) -- 346
	self.bgDraw = DrawNode() -- 347
	self.bgDraw:addTo(parent) -- 348
	self.worldRoot = Node() -- 349
	self.worldRoot:addTo(parent) -- 350
	self.platformDraw = DrawNode() -- 351
	self.platformDraw:addTo(self.worldRoot) -- 352
	self.propDraw = DrawNode() -- 353
	self.propDraw:addTo(self.worldRoot) -- 354
	self.scenePropsRoot = Node() -- 356
	self.scenePropsRoot:addTo(self.worldRoot) -- 357
	self.propSpriteRoot = Node() -- 359
	self.propSpriteRoot:addTo(self.worldRoot) -- 360
	self.portalLayer = Node() -- 362
	self.portalLayer:addTo(self.worldRoot) -- 363
	self.waveSpriteRoot = Node() -- 364
	self.waveSpriteRoot:addTo(self.worldRoot) -- 365
	self.charDraw = DrawNode() -- 366
	self.charDraw:addTo(self.worldRoot) -- 367
	self.ninjaRoot = Node() -- 369
	self.ninjaRoot:addTo(self.worldRoot) -- 370
	self.ninja = __TS__New(NinjaLayer, self.ninjaRoot) -- 371
	local heroTex = self:loadTex("assets/characters/衍月.png") -- 373
	if heroTex ~= nil then -- 373
		local sp = Sprite(heroTex) -- 375
		sp.anchor = Vec2(0.5, 0) -- 376
		self.heroScale = 90 / heroTex.height -- 377
		sp.scaleX = self.heroScale -- 378
		sp.scaleY = self.heroScale -- 379
		sp:addTo(self.worldRoot) -- 380
		self.heroSprite = sp -- 381
		self.heroTexOk = true -- 382
	end -- 382
	self.ghostRoot = Node() -- 385
	self.ghostRoot:addTo(self.worldRoot) -- 386
	self.heroFrames = __TS__New(HeroFrameSet, self.worldRoot) -- 387
	self.heroFxDraw = DrawNode() -- 388
	self.heroFxDraw:addTo(self.worldRoot) -- 389
	self.decorNode = Node() -- 390
	self.decorNode:addTo(self.worldRoot) -- 391
	self.lightDecor = __TS__New(LightDecor, self.decorNode) -- 392
	self.promptNode = Node() -- 394
	self.promptNode:addTo(self.worldRoot) -- 395
	self.promptNode.visible = false -- 396
	self.promptDraw = DrawNode() -- 397
	self.promptDraw:addTo(self.promptNode) -- 398
	self.promptDraw.visible = true -- 399
	self.promptNode.passOpacity = true -- 400
	self.promptNode:schedule(function(dt) -- 402
		self:updatePromptAnim(dt) -- 403
		return false -- 404
	end) -- 402
	self:buildPixelBackgrounds() -- 406
	self:buildPixelTerrain() -- 407
	self:buildPixelDecor() -- 408
	self:buildSceneProps() -- 409
	self:buildPortals() -- 410
	self:buildLightDecor() -- 411
	self:buildPropSprites() -- 412
end -- 313
function WorldRenderer.prototype.setPrompt(self, x, y, text) -- 417
	if text == nil then -- 417
		if self.promptShown then -- 417
			self.promptShown = false -- 420
			self.promptHideT = 0.1 -- 421
		end -- 421
		return -- 423
	end -- 423
	if self.promptShown and text == self.promptText and x == self.promptX and y == self.promptY then -- 423
		return -- 426
	end -- 426
	local fresh = not self.promptShown -- 428
	self.promptText = text -- 429
	self.promptX = x -- 430
	self.promptY = y -- 431
	if fresh then -- 431
		self.promptShown = true -- 433
		self.promptPopT = 0.15 -- 434
		self.promptHideT = 0 -- 435
		self.promptAnimT = 0 -- 436
		self.promptNode.visible = true -- 437
		self.promptNode.opacity = 1 -- 438
		self.promptNode.scaleX = 0.9 -- 439
		self.promptNode.scaleY = 0.9 -- 440
	end -- 440
	self:redrawPrompt() -- 442
	self:applyPromptPosition(0) -- 443
	self.promptRelayoutT = 0.12 -- 444
end -- 417
function WorldRenderer.prototype.applyPromptPosition(self, bob) -- 448
	local w = self.promptW -- 449
	local h = self.promptH -- 450
	local px = self.promptX -- 451
	local py = self.promptY + h / 2 + 14 -- 452
	local minX = self.camX - self.vw / 2 + w / 2 + 8 -- 453
	local maxX = self.camX + self.vw / 2 - w / 2 - 8 -- 454
	local minY = self.camY - self.vh / 2 + h / 2 + 8 -- 455
	local maxY = self.camY + self.vh / 2 - h / 2 - 8 -- 456
	if maxX > minX then -- 456
		px = math.max( -- 458
			minX, -- 458
			math.min(maxX, px) -- 458
		) -- 458
	end -- 458
	if maxY > minY then -- 458
		py = math.max( -- 461
			minY, -- 461
			math.min(maxY, py) -- 461
		) -- 461
	end -- 461
	self.promptNode.position = Vec2(px, py + bob) -- 463
end -- 448
function WorldRenderer.prototype.updatePromptAnim(self, dt) -- 467
	if not self.promptNode.visible then -- 467
		return -- 469
	end -- 469
	if self.promptShown then -- 469
		if self.promptRelayoutT > 0 then -- 469
			self.promptRelayoutT = self.promptRelayoutT - dt -- 473
			self:redrawPrompt() -- 474
		end -- 474
		self.promptAnimT = self.promptAnimT + dt -- 476
		if self.promptPopT > 0 then -- 476
			self.promptPopT = math.max(0, self.promptPopT - dt) -- 478
			local t = 1 - self.promptPopT / 0.15 -- 479
			local e = 1 - (1 - t) * (1 - t) -- 480
			local s = 0.9 + 0.1 * e -- 481
			self.promptNode.scaleX = s -- 482
			self.promptNode.scaleY = s -- 483
		else -- 483
			self.promptNode.scaleX = 1 -- 485
			self.promptNode.scaleY = 1 -- 486
		end -- 486
		local bob = 3 * math.sin(math.pi * self.promptAnimT) -- 488
		self:applyPromptPosition(bob) -- 489
		self.promptNode.opacity = 1 -- 490
	else -- 490
		self.promptHideT = self.promptHideT - dt -- 492
		if self.promptHideT <= 0 then -- 492
			self.promptHideT = 0 -- 494
			self.promptNode.visible = false -- 495
			self.promptNode.opacity = 1 -- 496
		else -- 496
			self.promptNode.opacity = self.promptHideT / 0.1 -- 498
		end -- 498
	end -- 498
end -- 467
function WorldRenderer.prototype.makePromptLabel(self, size) -- 503
	local lb = Label("assets/font/DialogFont.ttf", size) -- 504
	if lb ~= nil then -- 504
		return lb -- 506
	end -- 506
	return Label("sarasa-mono-sc-regular", size) -- 508
end -- 503
function WorldRenderer.prototype.redrawPrompt(self) -- 511
	local draw = self.promptDraw -- 513
	draw:clear() -- 514
	draw.visible = false -- 515
	if self.promptLbMain == nil then -- 515
		self.promptLbMain = self:makePromptLabel(21) -- 517
		if self.promptLbMain ~= nil then -- 517
			self.promptLbMain.anchor = Vec2(0.5, 0.5) -- 519
			self.promptLbMain.color = Color(255, 255, 255, 255) -- 520
			self.promptLbMain:addTo(self.promptNode) -- 521
		end -- 521
	end -- 521
	local main = self.promptLbMain -- 524
	if main == nil then -- 524
		return -- 526
	end -- 526
	main.visible = true -- 529
	main.color = Color(255, 255, 255, 255) -- 530
	main.alignment = "Center" -- 531
	main.text = self.promptText -- 532
	main.width = Label.AutomaticWidth -- 533
	main.position = Vec2(0, 0) -- 534
	local textW = main.width -- 535
	local textH = main.height > 0 and main.height or 24 -- 536
	local maxTextW = 280 -- 537
	if textW + 2 > maxTextW then -- 537
		local rows = math.ceil((textW + 2) / maxTextW) -- 539
		main.width = maxTextW -- 540
		textW = maxTextW -- 541
		textH = math.max(main.height, textH * rows) -- 542
	end -- 542
	self.promptW = textW -- 544
	self.promptH = textH -- 545
end -- 511
function WorldRenderer.prototype.buildLightDecor(self) -- 550
	local lightFloors = {3, 4, 5} -- 552
	local lanternFloors = {{top = FLOOR_TOPS[4], cx = 1000}, {top = FLOOR_TOPS[5], cx = 1200}, {top = FLOOR_TOPS[6], cx = 1700}} -- 553
	local lanternSpots = {} -- 558
	for ____, lf in ipairs(lanternFloors) do -- 559
		lanternSpots[#lanternSpots + 1] = {x = lf.cx - 350, y = lf.top + 240} -- 560
		lanternSpots[#lanternSpots + 1] = {x = lf.cx, y = lf.top + 240} -- 561
		lanternSpots[#lanternSpots + 1] = {x = lf.cx + 350, y = lf.top + 240} -- 562
	end -- 562
	self.lightDecor:addLanterns(lanternSpots) -- 564
	local torchSpots = {} -- 565
	for ____, rec in ipairs(self.portalNodes) do -- 566
		do -- 566
			local sanctioned = false -- 567
			for ____, lf in ipairs(lightFloors) do -- 568
				if lf == rec.floor then -- 568
					sanctioned = true -- 570
					break -- 571
				end -- 571
			end -- 571
			if not sanctioned then -- 571
				goto __continue44 -- 575
			end -- 575
			local top = rec.floor >= 0 and rec.floor < #FLOOR_TOPS and FLOOR_TOPS[rec.floor + 1] or 220 -- 577
			torchSpots[#torchSpots + 1] = {x = rec.x - 90, y = top} -- 578
			torchSpots[#torchSpots + 1] = {x = rec.x + 90, y = top} -- 579
		end -- 579
		::__continue44:: -- 579
	end -- 579
	self.lightDecor:addTorches(torchSpots) -- 581
end -- 550
function WorldRenderer.prototype.loadTex(self, path) -- 584
	local hit = self.texCache[path] -- 585
	if hit ~= nil then -- 585
		return hit -- 587
	end -- 587
	local tex = Texture2D(path) -- 589
	if tex == nil then -- 589
		return nil -- 591
	end -- 591
	self.texCache[path] = tex -- 593
	return tex -- 594
end -- 584
function WorldRenderer.prototype.setWorldVisible(self, v) -- 598
	self.bgSpriteRoot.visible = v -- 599
	self.worldRoot.visible = v -- 600
end -- 598
function WorldRenderer.prototype.debugPixelStats(self) -- 604
	return (((((((("bgRecs=" .. tostring(#self.bgRecs)) .. " bands=") .. tostring(#self.bgBands)) .. " tiles=") .. tostring(#self.tileGroups)) .. " pixelOk=") .. tostring(self.pixelBgOk)) .. " band=") .. tostring(self.activeBand) -- 605
end -- 604
function WorldRenderer.prototype.buildPixelBackgrounds(self) -- 608
	local vw = View.size.width -- 609
	local vh = View.size.height -- 610
	do -- 610
		local band = 0 -- 611
		while band < #BG_LAYERS do -- 611
			local bandNode = Node() -- 612
			bandNode:addTo(self.bgSpriteRoot) -- 613
			bandNode.visible = false -- 614
			local top = FLOOR_TOPS[band + 1] -- 615
			local ____self_bgBands_2 = self.bgBands -- 615
			____self_bgBands_2[#____self_bgBands_2 + 1] = {node = bandNode, floorTop = top} -- 616
			for ____, layer in ipairs(BG_LAYERS[band + 1]) do -- 617
				do -- 617
					local tex = self:loadTex(layer.path) -- 618
					if tex == nil then -- 618
						goto __continue58 -- 620
					end -- 620
					self.pixelBgOk = true -- 622
					local s = math.max(vw / tex.width, (vh + 40) / tex.height) -- 623
					local spanW = tex.width * s -- 624
					local copies = math.ceil(vw / spanW) + 2 -- 625
					do -- 625
						local j = 0 -- 626
						while j < copies do -- 626
							do -- 626
								local sp = Sprite(tex) -- 627
								if sp == nil then -- 627
									goto __continue61 -- 629
								end -- 629
								sp.anchor = Vec2(0, 0) -- 631
								sp.scaleX = s -- 632
								sp.scaleY = s -- 633
								sp.filter = "Point" -- 634
								sp:addTo(bandNode) -- 635
								local ____self_bgRecs_3 = self.bgRecs -- 635
								____self_bgRecs_3[#____self_bgRecs_3 + 1] = { -- 636
									node = sp, -- 637
									band = band, -- 638
									f = layer.f, -- 639
									spanW = spanW, -- 640
									imgH = tex.height * s, -- 641
									baseUp = layer.baseUp, -- 642
									copyIndex = j -- 643
								} -- 643
							end -- 643
							::__continue61:: -- 643
							j = j + 1 -- 626
						end -- 626
					end -- 626
				end -- 626
				::__continue58:: -- 626
			end -- 626
			band = band + 1 -- 611
		end -- 611
	end -- 611
end -- 608
function WorldRenderer.prototype.tileSprite(self, band, tex, x, y, cropW, cropH) -- 650
	local sp = Sprite( -- 651
		tex, -- 651
		Rect(0, 0, cropW, cropH) -- 651
	) -- 651
	if sp == nil then -- 651
		return -- 653
	end -- 653
	sp.anchor = Vec2(0, 0) -- 655
	sp.scaleX = 0.5 -- 656
	sp.scaleY = 0.5 -- 657
	sp.filter = "Point" -- 658
	sp.position = Vec2(x, y) -- 659
	sp:addTo(band) -- 660
end -- 650
function WorldRenderer.prototype.buildPixelTerrain(self) -- 663
	for ____, p in ipairs(self.data.platforms) do -- 664
		do -- 664
			if p.kind ~= "solid" or p.mover ~= nil or p.w < 300 then -- 664
				goto __continue67 -- 666
			end -- 666
			local key = TILE_SETS[p.floor + 1] -- 668
			local topTex = self:loadTex(("assets/tiles/" .. key) .. "_top.png") -- 669
			local fillTex = self:loadTex(("assets/tiles/" .. key) .. "_fill.png") -- 670
			if topTex == nil then -- 670
				goto __continue67 -- 672
			end -- 672
			local node = Node() -- 674
			node:addTo(self.worldRoot) -- 675
			local topY = p.y + p.h -- 676
			local cols = math.ceil(p.w / TILE) -- 677
			local rows = math.max( -- 678
				1, -- 678
				math.ceil(p.h / TILE) -- 678
			) -- 678
			local remW = p.w - (cols - 1) * TILE -- 679
			do -- 679
				local c = 0 -- 680
				while c < cols do -- 680
					local cw = c == cols - 1 and remW * 2 or 128 -- 681
					self:tileSprite( -- 682
						node, -- 682
						topTex, -- 682
						p.x + c * TILE, -- 682
						topY - TILE, -- 682
						cw, -- 682
						128 -- 682
					) -- 682
					c = c + 1 -- 680
				end -- 680
			end -- 680
			do -- 680
				local r = 1 -- 684
				while r < rows do -- 684
					if fillTex == nil then -- 684
						break -- 686
					end -- 686
					local fy = topY - TILE * (r + 1) -- 688
					local fh = r == rows - 1 and (topY - p.y - TILE * rows) * 2 or 128 -- 689
					if fh <= 0 then -- 689
						break -- 691
					end -- 691
					do -- 691
						local c = 0 -- 693
						while c < cols do -- 693
							local cw = c == cols - 1 and remW * 2 or 128 -- 694
							self:tileSprite( -- 695
								node, -- 695
								fillTex, -- 695
								p.x + c * TILE, -- 695
								fy, -- 695
								cw, -- 695
								fh -- 695
							) -- 695
							c = c + 1 -- 693
						end -- 693
					end -- 693
					r = r + 1 -- 684
				end -- 684
			end -- 684
			local ____self_tileGroups_4 = self.tileGroups -- 684
			____self_tileGroups_4[#____self_tileGroups_4 + 1] = { -- 698
				node = node, -- 698
				x0 = p.x, -- 698
				y0 = p.y, -- 698
				x1 = p.x + p.w, -- 698
				y1 = topY, -- 698
				floor = p.floor -- 698
			} -- 698
		end -- 698
		::__continue67:: -- 698
	end -- 698
	for ____, p in ipairs(self.data.platforms) do -- 702
		do -- 702
			if p.id ~= "wallL" and p.id ~= "wallR" then -- 702
				goto __continue79 -- 704
			end -- 704
			local fillTex = self:loadTex(("assets/tiles/" .. TILE_SETS[p.floor + 1]) .. "_fill.png") -- 706
			if fillTex == nil then -- 706
				goto __continue79 -- 708
			end -- 708
			local node = Node() -- 710
			node:addTo(self.worldRoot) -- 711
			local rows = math.ceil(p.h / TILE) -- 712
			do -- 712
				local r = 0 -- 713
				while r < rows do -- 713
					local rh = r == rows - 1 and (p.h - (rows - 1) * TILE) * 2 or 128 -- 714
					if rh <= 0 then -- 714
						break -- 716
					end -- 716
					self:tileSprite( -- 718
						node, -- 718
						fillTex, -- 718
						p.x, -- 718
						p.y + p.h - (r + 1) * TILE, -- 718
						160, -- 718
						rh -- 718
					) -- 718
					r = r + 1 -- 713
				end -- 713
			end -- 713
			local ____self_tileGroups_5 = self.tileGroups -- 713
			____self_tileGroups_5[#____self_tileGroups_5 + 1] = { -- 721
				node = node, -- 721
				x0 = p.x, -- 721
				y0 = p.y, -- 721
				x1 = p.x + p.w, -- 721
				y1 = p.y + p.h, -- 721
				floor = -1 -- 721
			} -- 721
		end -- 721
		::__continue79:: -- 721
	end -- 721
	for ____, hz in ipairs(self.data.hazards) do -- 724
		do -- 724
			local key = TILE_SETS[hz.floor + 1] -- 725
			local spikeTex = self:loadTex(("assets/tiles/" .. key) .. "_spike.png") -- 726
			if spikeTex == nil then -- 726
				goto __continue86 -- 728
			end -- 728
			local node = Node() -- 730
			node:addTo(self.worldRoot) -- 731
			local cols = math.ceil(hz.w / TILE) -- 732
			do -- 732
				local c = 0 -- 733
				while c < cols do -- 733
					self:tileSprite( -- 734
						node, -- 734
						spikeTex, -- 734
						hz.x + c * TILE, -- 734
						hz.y + 4, -- 734
						128, -- 734
						64 -- 734
					) -- 734
					c = c + 1 -- 733
				end -- 733
			end -- 733
			local ____self_tileGroups_6 = self.tileGroups -- 733
			____self_tileGroups_6[#____self_tileGroups_6 + 1] = { -- 736
				node = node, -- 736
				x0 = hz.x, -- 736
				y0 = hz.y, -- 736
				x1 = hz.x + hz.w, -- 736
				y1 = hz.y + hz.h, -- 736
				floor = hz.floor -- 736
			} -- 736
		end -- 736
		::__continue86:: -- 736
	end -- 736
	for ____, l in ipairs(self.data.ladders) do -- 739
		do -- 739
			local key = TILE_SETS[l.floor + 1] -- 740
			local tex = self:loadTex(("assets/tiles/" .. key) .. "_ladder.png") -- 741
			if tex == nil then -- 741
				goto __continue91 -- 743
			end -- 743
			local node = Node() -- 745
			node:addTo(self.worldRoot) -- 746
			local rows = math.ceil(l.h / TILE) -- 747
			do -- 747
				local r = 0 -- 748
				while r < rows do -- 748
					local rh = r == rows - 1 and (l.h - (rows - 1) * TILE) * 2 or 128 -- 749
					if rh <= 0 then -- 749
						break -- 751
					end -- 751
					self:tileSprite( -- 753
						node, -- 753
						tex, -- 753
						l.x, -- 753
						l.y + l.h - (r + 1) * TILE, -- 753
						92, -- 753
						rh -- 753
					) -- 753
					r = r + 1 -- 748
				end -- 748
			end -- 748
			local ____self_tileGroups_7 = self.tileGroups -- 748
			____self_tileGroups_7[#____self_tileGroups_7 + 1] = { -- 755
				node = node, -- 755
				x0 = l.x, -- 755
				y0 = l.y, -- 755
				x1 = l.x + l.w, -- 755
				y1 = l.y + l.h, -- 755
				floor = l.floor -- 755
			} -- 755
		end -- 755
		::__continue91:: -- 755
	end -- 755
	for ____, p in ipairs(self.data.platforms) do -- 758
		do -- 758
			if p.kind ~= "one-way" then -- 758
				goto __continue97 -- 760
			end -- 760
			local key = TILE_SETS[p.floor + 1] -- 762
			local tex = self:loadTex(("assets/tiles/" .. key) .. "_brick.png") -- 763
			if tex == nil then -- 763
				goto __continue97 -- 765
			end -- 765
			local node = Node() -- 767
			node:addTo(self.worldRoot) -- 768
			local cols = math.ceil(p.w / TILE) -- 769
			do -- 769
				local c = 0 -- 770
				while c < cols do -- 770
					local cw = c == cols - 1 and (p.w - (cols - 1) * TILE) * 2 or 128 -- 771
					if cw <= 0 then -- 771
						break -- 773
					end -- 773
					self:tileSprite( -- 775
						node, -- 775
						tex, -- 775
						p.x + c * TILE, -- 775
						p.y, -- 775
						cw, -- 775
						36 -- 775
					) -- 775
					c = c + 1 -- 770
				end -- 770
			end -- 770
			local ____self_tileGroups_8 = self.tileGroups -- 770
			____self_tileGroups_8[#____self_tileGroups_8 + 1] = { -- 777
				node = node, -- 777
				x0 = p.x, -- 777
				y0 = p.y, -- 777
				x1 = p.x + p.w, -- 777
				y1 = p.y + p.h, -- 777
				floor = p.floor -- 777
			} -- 777
		end -- 777
		::__continue97:: -- 777
	end -- 777
end -- 663
function WorldRenderer.prototype.buildPixelDecor(self) -- 781
	local decor = { -- 785
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 1300, y = FLOOR_TOPS[4]}, -- 787
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 600, y = FLOOR_TOPS[4]}, -- 790
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 1900, y = FLOOR_TOPS[4]}, -- 791
		{path = "assets/tiles/skyruins_magicstone.png", floor = 6, x = 700, y = FLOOR_TOPS[7]}, -- 792
		{path = "assets/tiles/skyruins_magicstone.png", floor = 6, x = 1900, y = FLOOR_TOPS[7]} -- 793
	} -- 793
	for ____, d in ipairs(decor) do -- 795
		do -- 795
			if not styleAllowsDecor(TILE_SETS[d.floor + 1], d.path) then -- 795
				goto __continue105 -- 797
			end -- 797
			local tex = self:loadTex(d.path) -- 799
			if tex == nil then -- 799
				goto __continue105 -- 801
			end -- 801
			local sp = Sprite(tex) -- 803
			if sp == nil then -- 803
				goto __continue105 -- 805
			end -- 805
			sp.anchor = Vec2(0.5, 0) -- 807
			sp.scaleX = 0.5 -- 808
			sp.scaleY = 0.5 -- 809
			sp.filter = "Point" -- 810
			sp.position = Vec2(d.x, d.y) -- 811
			sp:addTo(self:floorHolderIn(self.decorNode, self.decorFloorHolders, d.floor)) -- 812
		end -- 812
		::__continue105:: -- 812
	end -- 812
end -- 781
function WorldRenderer.prototype.makePropSprite(self, path, x, y, boxW, boxH, fit) -- 836
	local tex = self:loadTex(path) -- 837
	if tex == nil then -- 837
		return nil -- 839
	end -- 839
	local sp = Sprite(tex) -- 841
	if sp == nil then -- 841
		return nil -- 843
	end -- 843
	local sW = boxW / tex.width -- 845
	local sH = boxH / tex.height -- 846
	local s = fit == "w" and sW or (fit == "h" and sH or math.min(sW, sH)) -- 847
	sp.anchor = Vec2(0.5, 0) -- 848
	sp.scaleX = s -- 849
	sp.scaleY = s -- 850
	sp.filter = "Point" -- 851
	sp.position = Vec2(x, y) -- 852
	sp:addTo(self:floorHolderIn( -- 853
		self.scenePropsRoot, -- 853
		self.sceneFloorHolders, -- 853
		self:floorOfY(y) -- 853
	)) -- 853
	return sp -- 854
end -- 836
function WorldRenderer.prototype.ensurePuzzleProps(self) -- 857
	if self.puzzleBuilt then -- 857
		return -- 859
	end -- 859
	self.puzzleBuilt = true -- 861
	self.treeSapling = self:makePropSprite( -- 862
		"assets/props/a2_sapling.png", -- 862
		700, -- 862
		FLOOR_TOPS[1], -- 862
		150, -- 862
		120, -- 862
		"min" -- 862
	) -- 862
	self.treePit = self:makePropSprite( -- 863
		"assets/props/a1_pit.png", -- 863
		1200, -- 863
		FLOOR_TOPS[1], -- 863
		150, -- 863
		26, -- 863
		"min" -- 863
	) -- 863
	self.treeMain = self:makePropSprite( -- 865
		"assets/props/a3_tree.png", -- 865
		1200, -- 865
		FLOOR_TOPS[1], -- 865
		260, -- 865
		200, -- 865
		"min" -- 865
	) -- 865
	self.treeMirror = self:makePropSprite( -- 866
		"assets/props/a3_tree.png", -- 866
		700, -- 866
		FLOOR_TOPS[1], -- 866
		210, -- 866
		162, -- 866
		"min" -- 866
	) -- 866
	self.stumpMain = self:makePropSprite( -- 867
		"assets/props/a4_stump.png", -- 867
		1200, -- 867
		FLOOR_TOPS[1], -- 867
		110, -- 867
		80, -- 867
		"min" -- 867
	) -- 867
	self.stumpMirror = self:makePropSprite( -- 868
		"assets/props/a4_stump.png", -- 868
		700, -- 868
		FLOOR_TOPS[1], -- 868
		110, -- 868
		80, -- 868
		"min" -- 868
	) -- 868
	self.barrelSp = self:makePropSprite( -- 869
		"assets/props/b6_barrel.png", -- 869
		1900, -- 869
		FLOOR_TOPS[2], -- 869
		92, -- 869
		84, -- 869
		"min" -- 869
	) -- 869
	local ladder = DrawNode() -- 870
	ladder:addTo(self.scenePropsRoot) -- 871
	local rail = Color(122, 88, 58, 255) -- 873
	local rung = Color(150, 112, 74, 255) -- 874
	ladder:drawSegment( -- 875
		Vec2(1160, FLOOR_TOPS[1]), -- 875
		Vec2(1160, FLOOR_TOPS[1] + 560), -- 875
		4, -- 875
		rail -- 875
	) -- 875
	ladder:drawSegment( -- 876
		Vec2(1200, FLOOR_TOPS[1]), -- 876
		Vec2(1200, FLOOR_TOPS[1] + 560), -- 876
		4, -- 876
		rail -- 876
	) -- 876
	do -- 876
		local y = FLOOR_TOPS[1] + 40 -- 877
		while y <= FLOOR_TOPS[1] + 540 do -- 877
			ladder:drawSegment( -- 878
				Vec2(1160, y), -- 878
				Vec2(1200, y), -- 878
				3, -- 878
				rung -- 878
			) -- 878
			y = y + 56 -- 877
		end -- 877
	end -- 877
	ladder.visible = false -- 880
	self.treeLadderDraw = ladder -- 881
end -- 857
function WorldRenderer.prototype.setVisible(self, sp, on) -- 884
	if sp ~= nil then -- 884
		sp.visible = on -- 886
	end -- 886
end -- 884
function WorldRenderer.prototype.syncTreePuzzle(self, flags) -- 891
	self:ensurePuzzleProps() -- 892
	local planted = flags.treePlanted == true -- 893
	local cut = flags.treeCut == true -- 894
	local taken = flags.saplingTaken == true -- 895
	self:setVisible(self.treeSapling, not planted and not cut and not taken) -- 896
	self:setVisible(self.treePit, not planted) -- 897
	self:setVisible(self.treeMain, planted and not cut) -- 898
	self:setVisible(self.treeMirror, planted and not cut) -- 899
	self:setVisible(self.stumpMain, cut) -- 900
	self:setVisible(self.stumpMirror, cut) -- 901
	if self.treeLadderDraw ~= nil then -- 901
		self.treeLadderDraw.visible = planted and not cut and self.activeFloor == 0 -- 903
	end -- 903
end -- 891
function WorldRenderer.prototype.syncBarrel(self, dt, down, left) -- 908
	self:ensurePuzzleProps() -- 909
	if self.barrelSp == nil then -- 909
		return -- 911
	end -- 911
	if not down then -- 911
		self.barrelT = 0 -- 914
		self.barrelSp.angle = 0 -- 915
		self.barrelSp.position = Vec2(1900, FLOOR_TOPS[2]) -- 916
		return -- 917
	end -- 917
	if self.barrelLeft ~= left then -- 917
		self.barrelLeft = left -- 920
		self.barrelT = 0 -- 921
	end -- 921
	if self.barrelT < 1 then -- 921
		self.barrelT = math.min(1, self.barrelT + dt * 3) -- 924
		local e = 1 - (1 - self.barrelT) * (1 - self.barrelT) -- 925
		self.barrelSp.angle = (left and -1 or 1) * 90 * e -- 926
		self.barrelSp.position = Vec2(1900 + (left and -1 or 1) * 40 * e, FLOOR_TOPS[2] + 6 * e) -- 927
	end -- 927
end -- 908
function WorldRenderer.prototype.getWorldRoot(self) -- 932
	return self.worldRoot -- 933
end -- 932
function WorldRenderer.prototype.buildSceneProps(self) -- 936
	local defs = { -- 937
		{ -- 939
			path = "assets/props/a3_tree.png", -- 939
			x = 2000, -- 939
			y = FLOOR_TOPS[1], -- 939
			w = 340, -- 939
			h = 220, -- 939
			fit = "min" -- 939
		}, -- 939
		{ -- 940
			path = "assets/props/a5_well.png", -- 940
			x = 860, -- 940
			y = FLOOR_TOPS[1], -- 940
			w = 150, -- 940
			h = 110, -- 940
			fit = "min" -- 940
		}, -- 940
		{ -- 942
			path = "assets/props/a4_stump.png", -- 942
			x = 1550, -- 942
			y = FLOOR_TOPS[1], -- 942
			w = 110, -- 942
			h = 80, -- 942
			fit = "min" -- 942
		}, -- 942
		{ -- 943
			path = "assets/props/a6_bucket.png", -- 943
			x = 1650, -- 943
			y = FLOOR_TOPS[1], -- 943
			w = 56, -- 943
			h = 42, -- 943
			fit = "min" -- 943
		}, -- 943
		{ -- 947
			path = "assets/decor/lantern_1.png", -- 947
			x = 980, -- 947
			y = FLOOR_TOPS[2], -- 947
			w = 42, -- 947
			h = 74, -- 947
			fit = "h" -- 947
		}, -- 947
		{ -- 948
			path = "assets/decor/lantern_1.png", -- 948
			x = 2150, -- 948
			y = FLOOR_TOPS[2], -- 948
			w = 42, -- 948
			h = 74, -- 948
			fit = "h" -- 948
		}, -- 948
		{ -- 952
			path = "assets/props/e2_dice.png", -- 952
			x = 490, -- 952
			y = FLOOR_TOPS[2], -- 952
			w = 34, -- 952
			h = 30, -- 952
			fit = "min" -- 952
		}, -- 952
		{ -- 953
			path = "assets/props/b7_table.png", -- 953
			x = 550, -- 953
			y = FLOOR_TOPS[2], -- 953
			w = 190, -- 953
			h = 78, -- 953
			fit = "min" -- 953
		}, -- 953
		{ -- 954
			path = "assets/props/e6_offering.png", -- 954
			x = 1020, -- 954
			y = FLOOR_TOPS[2], -- 954
			w = 52, -- 954
			h = 36, -- 954
			fit = "min" -- 954
		}, -- 954
		{ -- 955
			path = "assets/props/b5_counter.png", -- 955
			x = 1755, -- 955
			y = FLOOR_TOPS[2], -- 955
			w = 160, -- 955
			h = 110, -- 955
			fit = "min" -- 955
		}, -- 955
		{ -- 958
			path = "assets/props/withered_reed.png", -- 958
			x = 1360, -- 958
			y = FLOOR_TOPS[1], -- 958
			w = 64, -- 958
			h = 78, -- 958
			fit = "w" -- 958
		}, -- 958
		{ -- 959
			path = "assets/props/withered_reed.png", -- 959
			x = 1690, -- 959
			y = FLOOR_TOPS[1], -- 959
			w = 56, -- 959
			h = 70, -- 959
			fit = "w" -- 959
		}, -- 959
		{ -- 961
			path = "assets/props/b6_barrel.png", -- 961
			x = 660, -- 961
			y = FLOOR_TOPS[3], -- 961
			w = 92, -- 961
			h = 84, -- 961
			fit = "min" -- 961
		}, -- 961
		{ -- 962
			path = "assets/props/b7_table.png", -- 962
			x = 1750, -- 962
			y = FLOOR_TOPS[3], -- 962
			w = 190, -- 962
			h = 78, -- 962
			fit = "min" -- 962
		}, -- 962
		{ -- 963
			path = "assets/props/b6_barrel.png", -- 963
			x = 1980, -- 963
			y = FLOOR_TOPS[3], -- 963
			w = 92, -- 963
			h = 84, -- 963
			fit = "min" -- 963
		}, -- 963
		{ -- 965
			path = "assets/props/withered_reed.png", -- 965
			x = 480, -- 965
			y = FLOOR_TOPS[6], -- 965
			w = 60, -- 965
			h = 74, -- 965
			fit = "w" -- 965
		}, -- 965
		{ -- 969
			path = "assets/props/e5_herb.png", -- 969
			x = 1150, -- 969
			y = FLOOR_TOPS[2], -- 969
			w = 36, -- 969
			h = 30, -- 969
			fit = "min" -- 969
		}, -- 969
		{ -- 970
			path = "assets/props/e3_lingzhi.png", -- 970
			x = 1310, -- 970
			y = FLOOR_TOPS[2], -- 970
			w = 44, -- 970
			h = 36, -- 970
			fit = "min" -- 970
		}, -- 970
		{ -- 971
			path = "assets/props/e4_ginseng.png", -- 971
			x = 1650, -- 971
			y = FLOOR_TOPS[2], -- 971
			w = 40, -- 971
			h = 34, -- 971
			fit = "min" -- 971
		}, -- 971
		{ -- 975
			path = "assets/props/e7_shard.png", -- 975
			x = 980, -- 975
			y = FLOOR_TOPS[7], -- 975
			w = 46, -- 975
			h = 40, -- 975
			fit = "min" -- 975
		} -- 975
	} -- 975
	for ____, d in ipairs(defs) do -- 977
		self:addSceneProp( -- 978
			d.path, -- 978
			d.x, -- 978
			d.y, -- 978
			d.w, -- 978
			d.h, -- 978
			d.fit -- 978
		) -- 978
	end -- 978
	for ____, hs in ipairs(HIDE_SPOTS) do -- 983
		local top = hs.floor >= 0 and hs.floor < #FLOOR_TOPS and FLOOR_TOPS[hs.floor + 1] or FLOOR_TOPS[2] -- 984
		self:addSceneProp( -- 985
			"assets/props/b1_bush.png", -- 985
			hs.x, -- 985
			top, -- 985
			104, -- 985
			64, -- 985
			"w" -- 985
		) -- 985
		self:addSceneProp( -- 986
			"assets/props/withered_reed.png", -- 986
			hs.x, -- 986
			top, -- 986
			96, -- 986
			72, -- 986
			"w" -- 986
		) -- 986
	end -- 986
end -- 936
function WorldRenderer.prototype.addSceneProp(self, path, x, y, boxW, boxH, fit) -- 991
	local tex = self:loadTex(path) -- 992
	if tex == nil then -- 992
		return -- 994
	end -- 994
	local sp = Sprite(tex) -- 996
	if sp == nil then -- 996
		return -- 998
	end -- 998
	local sW = boxW / tex.width -- 1000
	local sH = boxH / tex.height -- 1001
	local s = fit == "w" and sW or (fit == "h" and sH or math.min(sW, sH)) -- 1002
	sp.anchor = Vec2(0.5, 0) -- 1003
	sp.scaleX = s -- 1004
	sp.scaleY = s -- 1005
	sp.filter = "Point" -- 1006
	sp.position = Vec2(x, y) -- 1007
	sp:addTo(self:floorHolderIn( -- 1008
		self.scenePropsRoot, -- 1008
		self.sceneFloorHolders, -- 1008
		self:floorOfY(y) -- 1008
	)) -- 1008
end -- 991
function WorldRenderer.prototype.setCamera(self, camX, camY, shakeX, shakeY) -- 1011
	self.camX = camX -- 1012
	self.camY = camY -- 1013
	local vw = View.size.width -- 1014
	local vh = View.size.height -- 1015
	self.vw = vw -- 1016
	self.vh = vh -- 1017
	self.worldRoot.position = Vec2(-camX + shakeX, -camY + shakeY) -- 1020
	self:updatePixelBackdrop(camX, camY, vw, vh) -- 1021
	for ____, g in ipairs(self.tileGroups) do -- 1022
		g.node.visible = (g.floor < 0 or g.floor == self.activeFloor) and self:inView(g.x0, g.y0 - 40, g.x1, g.y1 + 40) -- 1024
	end -- 1024
end -- 1011
function WorldRenderer.prototype.setFloorScene(self, floor) -- 1029
	self.sceneBand = math.max( -- 1030
		0, -- 1030
		math.min( -- 1030
			#BG_LAYERS - 1, -- 1030
			math.floor(floor) -- 1030
		) -- 1030
	) -- 1030
	self.activeFloor = self.sceneBand -- 1033
	self:applyFloorHolders(self.sceneFloorHolders) -- 1034
	self:applyFloorHolders(self.decorFloorHolders) -- 1035
	self:applyFloorHolders(self.propSpriteFloorHolders) -- 1036
end -- 1029
function WorldRenderer.prototype.applyFloorHolders(self, holders) -- 1039
	do -- 1039
		local i = 0 -- 1040
		while i < #holders do -- 1040
			holders[i + 1].visible = i == self.activeFloor -- 1041
			i = i + 1 -- 1040
		end -- 1040
	end -- 1040
end -- 1039
function WorldRenderer.prototype.floorHolderIn(self, root, holders, floor) -- 1046
	while #holders <= floor do -- 1046
		local n = Node() -- 1048
		n:addTo(root) -- 1049
		n.visible = #holders == self.activeFloor -- 1050
		holders[#holders + 1] = n -- 1051
	end -- 1051
	return holders[floor + 1] -- 1053
end -- 1046
function WorldRenderer.prototype.floorOfY(self, y) -- 1058
	local f = 0 -- 1059
	do -- 1059
		local i = #FLOOR_TOPS - 1 -- 1060
		while i >= 0 do -- 1060
			if y >= FLOOR_TOPS[i + 1] then -- 1060
				f = i -- 1062
				break -- 1063
			end -- 1063
			i = i - 1 -- 1060
		end -- 1060
	end -- 1060
	return f -- 1066
end -- 1058
function WorldRenderer.prototype.buildPortals(self) -- 1070
	local list = self.data.portals -- 1071
	do -- 1071
		local i = 0 -- 1072
		while i < #list do -- 1072
			local p = list[i + 1] -- 1073
			local holder = Node() -- 1074
			holder:addTo(self.portalLayer) -- 1075
			holder.visible = false -- 1076
			local tex = self:loadTex("assets/tiles/skyruins_portal.png") -- 1077
			if tex ~= nil then -- 1077
				local s = 130 / tex.height -- 1079
				local sp = Sprite(tex) -- 1080
				sp.anchor = Vec2(0.5, 0) -- 1081
				sp.scaleX = s -- 1082
				sp.scaleY = s -- 1083
				sp.filter = "Point" -- 1084
				sp.position = Vec2(p.x, p.y) -- 1085
				sp:addTo(holder) -- 1086
			else -- 1086
				local d = DrawNode() -- 1088
				d:addTo(holder) -- 1089
				d:drawPolygon( -- 1090
					{ -- 1090
						Vec2(p.x - 26, p.y), -- 1091
						Vec2(p.x + 26, p.y), -- 1092
						Vec2(p.x + 26, p.y + 86), -- 1093
						Vec2(p.x, p.y + 118), -- 1094
						Vec2(p.x - 26, p.y + 86) -- 1095
					}, -- 1095
					Color(120, 200, 255, 200) -- 1096
				) -- 1096
			end -- 1096
			local ____self_portalNodes_9 = self.portalNodes -- 1096
			____self_portalNodes_9[#____self_portalNodes_9 + 1] = { -- 1098
				node = holder, -- 1098
				floor = p.floor, -- 1098
				x = p.x, -- 1098
				gateId = p.gateId, -- 1098
				fade = 0 -- 1098
			} -- 1098
			i = i + 1 -- 1072
		end -- 1072
	end -- 1072
end -- 1070
function WorldRenderer.prototype.buildPropSprites(self) -- 1103
	local stoneTex = self:loadTex("assets/tiles/push_stone.png") -- 1105
	if stoneTex ~= nil then -- 1105
		local sx = 56 / stoneTex.width -- 1107
		local sy = 44 / stoneTex.height -- 1108
		for ____, def in ipairs(self.data.pushStones) do -- 1109
			do -- 1109
				local sp = Sprite(stoneTex) -- 1110
				if sp == nil then -- 1110
					goto __continue155 -- 1112
				end -- 1112
				sp.anchor = Vec2(0.5, 0.5) -- 1114
				sp.scaleX = sx -- 1115
				sp.scaleY = sy -- 1116
				sp.position = Vec2(def.x, def.y + 22) -- 1117
				sp.visible = false -- 1118
				sp:addTo(self:floorHolderIn( -- 1119
					self.propSpriteRoot, -- 1119
					self.propSpriteFloorHolders, -- 1119
					self:floorOfY(def.y + 22) -- 1119
				)) -- 1119
				local ____self_stoneSprites_10 = self.stoneSprites -- 1119
				____self_stoneSprites_10[#____self_stoneSprites_10 + 1] = sp -- 1120
			end -- 1120
			::__continue155:: -- 1120
		end -- 1120
	end -- 1120
	local lampTex = self:loadTex("assets/tiles/lamp_stone.png") -- 1124
	if lampTex ~= nil then -- 1124
		local s = 36 / lampTex.height -- 1126
		for ____, c in ipairs(self.data.collectibles) do -- 1127
			do -- 1127
				if c.kind ~= "lampstone" then -- 1127
					goto __continue159 -- 1129
				end -- 1129
				local sp = Sprite(lampTex) -- 1131
				if sp == nil then -- 1131
					goto __continue159 -- 1133
				end -- 1133
				sp.anchor = Vec2(0.5, 0.5) -- 1135
				sp.scaleX = s -- 1136
				sp.scaleY = s -- 1137
				sp.position = Vec2(c.x, c.y + 18) -- 1138
				sp.visible = false -- 1139
				sp:addTo(self:floorHolderIn( -- 1140
					self.propSpriteRoot, -- 1140
					self.propSpriteFloorHolders, -- 1140
					self:floorOfY(c.y) -- 1140
				)) -- 1140
				self.lampStoneSprites[c.id] = sp -- 1141
			end -- 1141
			::__continue159:: -- 1141
		end -- 1141
	end -- 1141
	local moonTex = self:loadTex("assets/tiles/moon_stone.png") -- 1145
	if moonTex ~= nil then -- 1145
		local msc = 36 / moonTex.height -- 1147
		for ____, c in ipairs(self.data.collectibles) do -- 1148
			do -- 1148
				if c.kind ~= "moonstone" then -- 1148
					goto __continue164 -- 1150
				end -- 1150
				local sp = Sprite(moonTex) -- 1152
				if sp == nil then -- 1152
					goto __continue164 -- 1154
				end -- 1154
				sp.anchor = Vec2(0.5, 0.5) -- 1156
				sp.scaleX = msc -- 1157
				sp.scaleY = msc -- 1158
				sp.position = Vec2(c.x, c.y + 18) -- 1159
				sp.visible = false -- 1160
				sp:addTo(self:floorHolderIn( -- 1161
					self.propSpriteRoot, -- 1161
					self.propSpriteFloorHolders, -- 1161
					self:floorOfY(c.y) -- 1161
				)) -- 1161
				self.moonStoneSprites[c.id] = sp -- 1162
			end -- 1162
			::__continue164:: -- 1162
		end -- 1162
	end -- 1162
	local dewTex = self:loadTex(".agent/血包.png") -- 1166
	if dewTex ~= nil then -- 1166
		print(((("[DewSprite] loaded .agent/血包.png (" .. tostring(dewTex.width)) .. "x") .. tostring(dewTex.height)) .. ")") -- 1168
		local dc = 36 / dewTex.height -- 1169
		for ____, c in ipairs(self.data.collectibles) do -- 1170
			do -- 1170
				if c.kind ~= "dew" then -- 1170
					goto __continue169 -- 1172
				end -- 1172
				local sp = Sprite(dewTex) -- 1174
				if sp == nil then -- 1174
					goto __continue169 -- 1176
				end -- 1176
				sp.anchor = Vec2(0.5, 0.5) -- 1178
				sp.scaleX = dc -- 1179
				sp.scaleY = dc -- 1180
				sp.position = Vec2(c.x, c.y + 18) -- 1181
				sp.visible = false -- 1182
				sp:addTo(self:floorHolderIn( -- 1183
					self.propSpriteRoot, -- 1183
					self.propSpriteFloorHolders, -- 1183
					self:floorOfY(c.y) -- 1183
				)) -- 1183
				self.dewSprites[c.id] = sp -- 1184
			end -- 1184
			::__continue169:: -- 1184
		end -- 1184
	end -- 1184
	local tokenTex = self:loadTex("assets/props/e7_shard.png") -- 1189
	if tokenTex ~= nil then -- 1189
		local tsc = 36 / tokenTex.height -- 1191
		for ____, c in ipairs(self.data.collectibles) do -- 1192
			do -- 1192
				if c.kind ~= "token" then -- 1192
					goto __continue174 -- 1194
				end -- 1194
				local sp = Sprite(tokenTex) -- 1196
				if sp == nil then -- 1196
					goto __continue174 -- 1198
				end -- 1198
				sp.anchor = Vec2(0.5, 0.5) -- 1200
				sp.scaleX = tsc -- 1201
				sp.scaleY = tsc -- 1202
				sp.position = Vec2(c.x, c.y + 18) -- 1203
				sp.visible = false -- 1204
				sp:addTo(self:floorHolderIn( -- 1205
					self.propSpriteRoot, -- 1205
					self.propSpriteFloorHolders, -- 1205
					self:floorOfY(c.y) -- 1205
				)) -- 1205
				self.tokenSprites[c.id] = sp -- 1206
			end -- 1206
			::__continue174:: -- 1206
		end -- 1206
	end -- 1206
	local offTex = self:loadTex("assets/ui/flag/checkpoint_off.png") -- 1210
	for ____, cp in ipairs(self.data.checkpoints) do -- 1211
		do -- 1211
			if cp.id == "cp_riverbank" then -- 1211
				goto __continue178 -- 1213
			end -- 1213
			local onFrames = {} -- 1215
			do -- 1215
				local fi = 0 -- 1216
				while fi < 4 do -- 1216
					do -- 1216
						local tex = self:loadTex(("assets/ui/flag/checkpoint_on_" .. tostring(fi)) .. ".png") -- 1217
						if tex == nil then -- 1217
							goto __continue181 -- 1219
						end -- 1219
						local sp = Sprite(tex) -- 1221
						if sp == nil then -- 1221
							goto __continue181 -- 1223
						end -- 1223
						self:setupFlagSprite( -- 1225
							sp, -- 1225
							tex.height, -- 1225
							cp.x, -- 1225
							cp.y, -- 1225
							self:floorOfY(cp.y) -- 1225
						) -- 1225
						onFrames[#onFrames + 1] = sp -- 1226
					end -- 1226
					::__continue181:: -- 1226
					fi = fi + 1 -- 1216
				end -- 1216
			end -- 1216
			if offTex ~= nil and #onFrames > 0 then -- 1216
				local spOff = Sprite(offTex) -- 1229
				if spOff ~= nil then -- 1229
					self:setupFlagSprite( -- 1231
						spOff, -- 1231
						offTex.height, -- 1231
						cp.x, -- 1231
						cp.y, -- 1231
						self:floorOfY(cp.y) -- 1231
					) -- 1231
					self.flagSets[cp.id] = {off = spOff, on = onFrames} -- 1232
				end -- 1232
			end -- 1232
		end -- 1232
		::__continue178:: -- 1232
	end -- 1232
end -- 1103
function WorldRenderer.prototype.setupFlagSprite(self, sp, texH, x, y, floor) -- 1238
	local s = 90 / texH -- 1239
	sp.anchor = Vec2(0.5, 0) -- 1240
	sp.scaleX = s -- 1241
	sp.scaleY = s -- 1242
	sp.filter = "Point" -- 1243
	sp.position = Vec2(x, y) -- 1244
	sp.visible = false -- 1245
	sp:addTo(self:floorHolderIn(self.propSpriteRoot, self.propSpriteFloorHolders, floor)) -- 1246
end -- 1238
function WorldRenderer.prototype.updatePortals(self, player, state, dt) -- 1249
	do -- 1249
		local i = 0 -- 1250
		while i < #self.portalNodes do -- 1250
			local rec = self.portalNodes[i + 1] -- 1251
			local unlocked = rec.gateId == nil or state.openedGates[rec.gateId] == true -- 1254
			local want = unlocked and rec.floor == self.sceneBand and math.abs(player.body.x - rec.x) < 280 -- 1255
			rec.fade = rec.fade + ((want and 1 or 0) - rec.fade) * math.min(1, dt * 8) -- 1256
			if rec.fade < 0.005 then -- 1256
				rec.fade = 0 -- 1258
			end -- 1258
			rec.node.visible = rec.fade > 0.02 -- 1260
			rec.node.opacity = rec.fade -- 1261
			i = i + 1 -- 1250
		end -- 1250
	end -- 1250
end -- 1249
function WorldRenderer.prototype.updatePixelBackdrop(self, camX, camY, vw, vh) -- 1266
	if not self.pixelBgOk then -- 1266
		return -- 1268
	end -- 1268
	local band = math.max( -- 1270
		0, -- 1270
		math.min(#self.bgBands - 1, self.sceneBand) -- 1270
	) -- 1270
	do -- 1270
		local i = 0 -- 1271
		while i < #self.bgBands do -- 1271
			self.bgBands[i + 1].node.visible = i == band -- 1272
			i = i + 1 -- 1271
		end -- 1271
	end -- 1271
	local bandTop = self.bgBands[band + 1].floorTop -- 1274
	local function mod(x, m) -- 1275
		local r = x % m -- 1276
		return r < 0 and r + m or r -- 1277
	end -- 1275
	for ____, rec in ipairs(self.bgRecs) do -- 1279
		do -- 1279
			if rec.band ~= band then -- 1279
				goto __continue197 -- 1281
			end -- 1281
			local offX = mod(camX * rec.f, rec.spanW) -- 1283
			rec.node.x = -vw / 2 - offX + rec.copyIndex * rec.spanW -- 1284
			local yBase = -vh / 2 + 1 + rec.baseUp -- 1285
			local targetY = yBase + (bandTop - camY) * rec.f * 0.6 -- 1286
			local yMin = vh / 2 - rec.imgH + 1 -- 1287
			rec.node.y = targetY < yMin and yMin or targetY -- 1288
		end -- 1288
		::__continue197:: -- 1288
	end -- 1288
	self.activeBand = band -- 1290
end -- 1266
function WorldRenderer.prototype.inViewX(self, x0, x1) -- 1293
	return x1 >= self.camX - self.vw / 2 - CULL and x0 <= self.camX + self.vw / 2 + CULL -- 1294
end -- 1293
function WorldRenderer.prototype.inViewY(self, y0, y1) -- 1297
	return y1 >= self.camY - self.vh / 2 - CULL and y0 <= self.camY + self.vh / 2 + CULL -- 1298
end -- 1297
function WorldRenderer.prototype.inView(self, x0, y0, x1, y1) -- 1301
	return self:inViewX(x0, x1) and self:inViewY(y0, y1) -- 1302
end -- 1301
function WorldRenderer.prototype.update(self, dt, state, player, enemies, mech, time) -- 1305
	self.lightDecor:update(time, dt) -- 1306
	self:updatePortals(player, state, dt) -- 1307
	self:drawBackground(time) -- 1308
	self:drawTerrain(time) -- 1309
	self:drawProps(time, state) -- 1310
	self:drawChars( -- 1311
		time, -- 1311
		state, -- 1311
		player, -- 1311
		enemies, -- 1311
		mech, -- 1311
		dt -- 1311
	) -- 1311
end -- 1305
function WorldRenderer.prototype.drawBackground(self, time) -- 1315
	local d = self.bgDraw -- 1316
	d:clear() -- 1317
	local vw = self.vw -- 1318
	local vh = self.vh -- 1319
	local x0 = -vw / 2 -- 1320
	local y0 = -vh / 2 -- 1321
	if not self.pixelBgOk then -- 1321
		d:drawPolygon( -- 1323
			{ -- 1324
				Vec2(x0 - 4, y0 - 4), -- 1324
				Vec2(x0 + vw + 8, y0 - 4), -- 1324
				Vec2(x0 + vw + 8, y0 + vh + 8), -- 1324
				Vec2(x0 - 4, y0 + vh + 8) -- 1324
			}, -- 1324
			col(Palette.paper), -- 1325
			0, -- 1326
			Color(0, 0, 0, 0) -- 1327
		) -- 1327
	end -- 1327
	local span = vw + 80 -- 1331
	local starsOn = self.sceneBand ~= 4 -- 1332
	do -- 1332
		local i = 0 -- 1333
		while starsOn and i < #self.stars do -- 1333
			local st = self.stars[i + 1] -- 1334
			local wx = st.x - self.camX * 0.04 -- 1335
			wx = wx % span -- 1336
			if wx < 0 then -- 1336
				wx = wx + span -- 1338
			end -- 1338
			local sx = wx - 40 - vw / 2 -- 1340
			local sy = y0 + st.y -- 1341
			local tw = 0.22 + 0.3 * (0.5 + 0.5 * math.sin(time * 1.8 + i * 1.7)) -- 1342
			dot( -- 1343
				d, -- 1343
				sx, -- 1343
				sy, -- 1343
				st.s, -- 1343
				Palette.moonWhite, -- 1343
				tw -- 1343
			) -- 1343
			i = i + 1 -- 1333
		end -- 1333
	end -- 1333
	if self.pixelBgOk and self.sceneBand == 4 then -- 1333
		self:drawMechBackdrop(time) -- 1348
	end -- 1348
	if not self.pixelBgOk then -- 1348
		local ridges = { -- 1352
			{ -- 1353
				p = 0.12, -- 1353
				base = -70, -- 1353
				a1 = 46, -- 1353
				a2 = 18, -- 1353
				c = ink(101, 112, 107, 50), -- 1353
				s = 0.006, -- 1353
				s2 = 0.017 -- 1353
			}, -- 1353
			{ -- 1354
				p = 0.22, -- 1354
				base = -120, -- 1354
				a1 = 58, -- 1354
				a2 = 22, -- 1354
				c = ink(84, 94, 90, 85), -- 1354
				s = 0.007, -- 1354
				s2 = 0.021 -- 1354
			}, -- 1354
			{ -- 1355
				p = 0.35, -- 1355
				base = -180, -- 1355
				a1 = 70, -- 1355
				a2 = 26, -- 1355
				c = ink(66, 74, 70, 130), -- 1355
				s = 0.008, -- 1355
				s2 = 0.026 -- 1355
			} -- 1355
		} -- 1355
		do -- 1355
			local ri = 0 -- 1357
			while ri < #ridges do -- 1357
				local rg = ridges[ri + 1] -- 1358
				local verts = {} -- 1359
				do -- 1359
					local sx = -64 -- 1360
					while sx <= vw + 64 do -- 1360
						local wxs = sx + self.camX * rg.p -- 1361
						local ry = rg.base - self.camY * rg.p * 0.5 + rg.a1 * math.sin(wxs * rg.s + ri * 2.3) + rg.a2 * math.sin(wxs * rg.s2 + ri * 1.1) -- 1362
						verts[#verts + 1] = Vec2(sx - vw / 2, ry) -- 1363
						sx = sx + 64 -- 1360
					end -- 1360
				end -- 1360
				verts[#verts + 1] = Vec2(vw / 2 + 64, y0 - 6) -- 1365
				verts[#verts + 1] = Vec2(-vw / 2 - 64, y0 - 6) -- 1366
				d:drawPolygon( -- 1367
					verts, -- 1367
					col(rg.c), -- 1367
					0, -- 1367
					Color(0, 0, 0, 0) -- 1367
				) -- 1367
				ri = ri + 1 -- 1357
			end -- 1357
		end -- 1357
		self:drawPagoda(time) -- 1369
		self:drawMist(time) -- 1370
		if self.camY - vh / 2 < 300 then -- 1370
			self:drawWaterFront(time) -- 1372
		end -- 1372
	end -- 1372
end -- 1315
function WorldRenderer.prototype.drawMechBackdrop(self, time) -- 1379
	local d = self.bgDraw -- 1380
	local vw = self.vw -- 1381
	local vh = self.vh -- 1382
	local x0 = -vw / 2 -- 1383
	local y0 = -vh / 2 -- 1384
	d:drawPolygon( -- 1386
		{ -- 1387
			Vec2(x0 - 4, y0 - 4), -- 1387
			Vec2(x0 + vw + 8, y0 - 4), -- 1387
			Vec2(x0 + vw + 8, y0 + vh + 8), -- 1387
			Vec2(x0 - 4, y0 + vh + 8) -- 1387
		}, -- 1387
		col(ink(30, 26, 22, 255)), -- 1388
		0, -- 1389
		Color(0, 0, 0, 0) -- 1390
	) -- 1390
	local yShift = -(self.camY - FLOOR_TOPS[5]) * 0.06 -- 1392
	local function mod(x, m) -- 1393
		local r = x % m -- 1394
		return r < 0 and r + m or r -- 1395
	end -- 1393
	local glowCyan = ink(168, 197, 188, 255) -- 1397
	local spanFar = 1500 -- 1399
	local offFar = mod(self.camX * 0.1, spanFar) -- 1400
	do -- 1400
		local i = 0 -- 1401
		while i < 3 do -- 1401
			do -- 1401
				local wx = mod(i * 520 + 240 - offFar, spanFar) - 200 -- 1402
				local gx = wx - vw / 2 -- 1403
				if gx < -260 or gx > vw / 2 + 260 then -- 1403
					goto __continue219 -- 1405
				end -- 1405
				local gy = y0 + 210 + yShift * 0.5 -- 1407
				local dir = i == 1 and -1 or 1 -- 1408
				self:drawGearShape( -- 1409
					d, -- 1409
					gx, -- 1409
					gy, -- 1409
					190 - i * 24, -- 1409
					12, -- 1409
					time * (0.12 + i * 0.04) * dir, -- 1409
					ink(50, 42, 33, 235), -- 1409
					ink(40, 33, 26, 235) -- 1409
				) -- 1409
			end -- 1409
			::__continue219:: -- 1409
			i = i + 1 -- 1401
		end -- 1401
	end -- 1401
	do -- 1401
		local i = 0 -- 1411
		while i < 4 do -- 1411
			do -- 1411
				local wx = mod(i * 430 + 90 - offFar, spanFar) - 200 -- 1412
				local cx = wx - vw / 2 -- 1413
				if cx < -60 or cx > vw / 2 + 60 then -- 1413
					goto __continue222 -- 1415
				end -- 1415
				d:drawPolygon( -- 1417
					{ -- 1418
						Vec2(cx - 22, y0 - 4), -- 1418
						Vec2(cx + 22, y0 - 4), -- 1418
						Vec2(cx + 16, y0 + vh + 8), -- 1418
						Vec2(cx - 16, y0 + vh + 8) -- 1418
					}, -- 1418
					col(ink(42, 36, 29, 220)), -- 1419
					0, -- 1420
					Color(0, 0, 0, 0) -- 1421
				) -- 1421
				seg( -- 1423
					d, -- 1423
					cx - 19, -- 1423
					y0 + 40, -- 1423
					cx - 19, -- 1423
					y0 + vh - 20, -- 1423
					2, -- 1423
					ink(34, 29, 24, 160) -- 1423
				) -- 1423
			end -- 1423
			::__continue222:: -- 1423
			i = i + 1 -- 1411
		end -- 1411
	end -- 1411
	local spanMid = 1200 -- 1426
	local offMid = mod(self.camX * 0.26, spanMid) -- 1427
	local pipeYs = {y0 + vh * 0.72, y0 + vh * 0.5, y0 + vh * 0.3} -- 1428
	do -- 1428
		local pi = 0 -- 1429
		while pi < #pipeYs do -- 1429
			local py = pipeYs[pi + 1] + yShift -- 1430
			seg( -- 1431
				d, -- 1431
				x0 - 20, -- 1431
				py, -- 1431
				x0 + vw + 20, -- 1431
				py, -- 1431
				10 - pi * 2, -- 1431
				ink(60, 50, 38, 235) -- 1431
			) -- 1431
			do -- 1431
				local jx = -((offMid + 60) % 150) -- 1432
				while jx < vw + 20 do -- 1432
					circle( -- 1433
						d, -- 1433
						x0 + jx, -- 1433
						py, -- 1433
						7 - pi, -- 1433
						ink(72, 60, 45, 235), -- 1433
						5 -- 1433
					) -- 1433
					jx = jx + 150 -- 1432
				end -- 1432
			end -- 1432
			do -- 1432
				local jx = -((offMid + 105) % 300) -- 1435
				while jx < vw do -- 1435
					dot( -- 1436
						d, -- 1436
						x0 + jx, -- 1436
						py + 12, -- 1436
						3.2, -- 1436
						glowCyan, -- 1436
						0.3 + 0.22 * math.sin(time * 2.4 + pi * 1.9 + jx) -- 1436
					) -- 1436
					jx = jx + 300 -- 1435
				end -- 1435
			end -- 1435
			pi = pi + 1 -- 1429
		end -- 1429
	end -- 1429
	do -- 1429
		local i = 0 -- 1440
		while i < 5 do -- 1440
			do -- 1440
				local wx = mod(i * 260 + 130 - offMid, spanMid) - 150 -- 1441
				local cx = wx - vw / 2 -- 1442
				if cx < -40 or cx > vw / 2 + 40 then -- 1442
					goto __continue231 -- 1444
				end -- 1444
				local sway = math.sin(time * 0.7 + i * 1.3) * 6 -- 1446
				local topY = y0 + vh + 8 -- 1447
				local botY = y0 + 120 + yShift + i % 2 * 46 -- 1448
				seg( -- 1449
					d, -- 1449
					cx, -- 1449
					topY, -- 1449
					cx + sway, -- 1449
					botY, -- 1449
					2.4, -- 1449
					ink(70, 59, 45, 220) -- 1449
				) -- 1449
				do -- 1449
					local k = 1 -- 1450
					while k < 7 do -- 1450
						local t = k / 7 -- 1451
						dot( -- 1452
							d, -- 1452
							cx + sway * t, -- 1452
							topY + (botY - topY) * t, -- 1452
							3.4, -- 1452
							ink(80, 68, 52, 220), -- 1452
							0.9 -- 1452
						) -- 1452
						k = k + 1 -- 1450
					end -- 1450
				end -- 1450
				circle( -- 1454
					d, -- 1454
					cx + sway, -- 1454
					botY - 8, -- 1454
					9, -- 1454
					ink(76, 63, 48, 235), -- 1454
					6 -- 1454
				) -- 1454
			end -- 1454
			::__continue231:: -- 1454
			i = i + 1 -- 1440
		end -- 1440
	end -- 1440
	local spanNear = 900 -- 1457
	local offNear = mod(self.camX * 0.4, spanNear) -- 1458
	do -- 1458
		local i = 0 -- 1459
		while i < 2 do -- 1459
			do -- 1459
				local wx = mod(i * 470 + 300 - offNear, spanNear) - 150 -- 1460
				local gx = wx - vw / 2 -- 1461
				if gx < -140 or gx > vw / 2 + 140 then -- 1461
					goto __continue236 -- 1463
				end -- 1463
				local gy = y0 + 150 + yShift * 1.4 -- 1465
				local dir = i == 0 and 1 or -1 -- 1466
				self:drawGearShape( -- 1467
					d, -- 1467
					gx, -- 1467
					gy, -- 1467
					74, -- 1467
					9, -- 1467
					time * 0.5 * dir, -- 1467
					ink(66, 55, 42, 240), -- 1467
					ink(52, 43, 33, 240) -- 1467
				) -- 1467
				dot( -- 1468
					d, -- 1468
					gx, -- 1468
					gy, -- 1468
					5, -- 1468
					glowCyan, -- 1468
					0.5 + 0.3 * math.sin(time * 3 + i) -- 1468
				) -- 1468
				self:drawGearShape( -- 1469
					d, -- 1469
					gx + 96, -- 1469
					gy + 26, -- 1469
					40, -- 1469
					7, -- 1469
					-time * 0.5 * dir * (74 / 40), -- 1469
					ink(60, 50, 38, 235), -- 1469
					ink(48, 40, 31, 235) -- 1469
				) -- 1469
			end -- 1469
			::__continue236:: -- 1469
			i = i + 1 -- 1459
		end -- 1459
	end -- 1459
end -- 1379
function WorldRenderer.prototype.drawGearShape(self, d, cx, cy, r, teeth, angle, body, hub) -- 1474
	local verts = {} -- 1475
	local n = teeth * 2 -- 1476
	do -- 1476
		local i = 0 -- 1477
		while i < n do -- 1477
			local rr = i % 2 == 0 and r or r * 0.8 -- 1478
			local a = angle + i / n * math.pi * 2 -- 1479
			verts[#verts + 1] = Vec2( -- 1480
				cx + math.cos(a) * rr, -- 1480
				cy + math.sin(a) * rr -- 1480
			) -- 1480
			i = i + 1 -- 1477
		end -- 1477
	end -- 1477
	d:drawPolygon( -- 1482
		verts, -- 1482
		col(body), -- 1482
		0, -- 1482
		Color(0, 0, 0, 0) -- 1482
	) -- 1482
	circle( -- 1483
		d, -- 1483
		cx, -- 1483
		cy, -- 1483
		r * 0.34, -- 1483
		hub, -- 1483
		5 -- 1483
	) -- 1483
	do -- 1483
		local i = 0 -- 1484
		while i < 4 do -- 1484
			local a = angle + i * math.pi * 0.5 + math.pi * 0.25 -- 1485
			local c = math.cos(a) -- 1486
			local s = math.sin(a) -- 1487
			seg( -- 1488
				d, -- 1488
				cx + c * r * 0.3, -- 1488
				cy + s * r * 0.3, -- 1488
				cx + c * r * 0.78, -- 1488
				cy + s * r * 0.78, -- 1488
				4, -- 1488
				body -- 1488
			) -- 1488
			i = i + 1 -- 1484
		end -- 1484
	end -- 1484
end -- 1474
function WorldRenderer.prototype.drawPagoda(self, time) -- 1492
	local d = self.bgDraw -- 1493
	local vw = self.vw -- 1494
	local baseX = 1500 - self.camX * 0.7 -- 1495
	local px = baseX - vw / 2 -- 1496
	if math.abs(px) > vw / 2 + 220 then -- 1496
		return -- 1498
	end -- 1498
	local baseY = -150 - self.camY * 0.35 -- 1500
	local inkTower = ink(72, 80, 76, 190) -- 1501
	local w = 150 -- 1503
	local h = 30 -- 1504
	local cy = baseY -- 1505
	do -- 1505
		local i = 0 -- 1506
		while i < 7 do -- 1506
			local nw = w * 0.86 -- 1507
			d:drawPolygon( -- 1508
				{ -- 1509
					Vec2(px - w / 2, cy), -- 1509
					Vec2(px + w / 2, cy), -- 1509
					Vec2(px + nw / 2, cy + h), -- 1509
					Vec2(px - nw / 2, cy + h) -- 1509
				}, -- 1509
				col(inkTower), -- 1510
				0, -- 1511
				Color(0, 0, 0, 0) -- 1512
			) -- 1512
			seg( -- 1515
				d, -- 1515
				px - w / 2 - 14, -- 1515
				cy + h, -- 1515
				px + w / 2 + 14, -- 1515
				cy + h, -- 1515
				4.5, -- 1515
				inkTower -- 1515
			) -- 1515
			seg( -- 1516
				d, -- 1516
				px - w / 2 - 14, -- 1516
				cy + h, -- 1516
				px - w / 2 - 20, -- 1516
				cy + h - 7, -- 1516
				2.6, -- 1516
				inkTower -- 1516
			) -- 1516
			seg( -- 1517
				d, -- 1517
				px + w / 2 + 14, -- 1517
				cy + h, -- 1517
				px + w / 2 + 20, -- 1517
				cy + h - 7, -- 1517
				2.6, -- 1517
				inkTower -- 1517
			) -- 1517
			cy = cy + h -- 1518
			h = h * 0.92 -- 1519
			w = nw -- 1520
			i = i + 1 -- 1506
		end -- 1506
	end -- 1506
	seg( -- 1523
		d, -- 1523
		px, -- 1523
		cy, -- 1523
		px, -- 1523
		cy + 30, -- 1523
		3, -- 1523
		inkTower -- 1523
	) -- 1523
	circle( -- 1524
		d, -- 1524
		px, -- 1524
		cy + 34, -- 1524
		6, -- 1524
		inkTower, -- 1524
		10 -- 1524
	) -- 1524
	local flick = 0.6 + 0.4 * math.sin(time * 2.2) -- 1526
	do -- 1526
		local i = 0 -- 1527
		while i < 4 do -- 1527
			dot( -- 1528
				d, -- 1528
				px - 26 + i * 17, -- 1528
				baseY + 60 + i * 32, -- 1528
				2.4, -- 1528
				GOLD, -- 1528
				0.35 + 0.3 * flick -- 1528
			) -- 1528
			i = i + 1 -- 1527
		end -- 1527
	end -- 1527
end -- 1492
function WorldRenderer.prototype.drawMist(self, time) -- 1532
	local d = self.bgDraw -- 1533
	local vw = self.vw -- 1534
	local span = vw + 500 -- 1535
	do -- 1535
		local i = 0 -- 1536
		while i < 3 do -- 1536
			local speed = 12 + i * 9 -- 1537
			local bandY = -170 + i * 55 + math.sin(time * 0.3 + i * 1.7) * 8 -- 1538
			do -- 1538
				local c = 0 -- 1539
				while c < 3 do -- 1539
					local wx = time * speed + c * 460 + i * 190 -- 1540
					wx = wx % span -- 1541
					if wx < 0 then -- 1541
						wx = wx + span -- 1543
					end -- 1543
					local cx0 = wx - 250 - vw / 2 -- 1545
					do -- 1545
						local j = 0 -- 1546
						while j < 6 do -- 1546
							do -- 1546
								local jx = cx0 + j * 84 -- 1547
								if jx < -vw / 2 - 120 or jx > vw / 2 + 120 then -- 1547
									goto __continue256 -- 1549
								end -- 1549
								local jy = bandY + math.sin(jx * 0.01 + time * 0.5 + i) * 6 -- 1551
								dot( -- 1552
									d, -- 1552
									jx, -- 1552
									jy, -- 1552
									16 - i * 3, -- 1552
									Palette.paleInk, -- 1552
									0.1 + i * 0.02 -- 1552
								) -- 1552
							end -- 1552
							::__continue256:: -- 1552
							j = j + 1 -- 1546
						end -- 1546
					end -- 1546
					c = c + 1 -- 1539
				end -- 1539
			end -- 1539
			i = i + 1 -- 1536
		end -- 1536
	end -- 1536
end -- 1532
function WorldRenderer.prototype.drawWaterFront(self, time) -- 1558
	local d = self.bgDraw -- 1559
	local vw = self.vw -- 1560
	local bot = -self.vh / 2 -- 1561
	local top = bot + 46 -- 1562
	d:drawPolygon( -- 1563
		{ -- 1564
			Vec2(-vw / 2 - 4, bot - 4), -- 1564
			Vec2(vw / 2 + 8, bot - 4), -- 1564
			Vec2(vw / 2 + 8, top), -- 1564
			Vec2(-vw / 2 - 4, top) -- 1564
		}, -- 1564
		col(ink(90, 110, 105, 26)), -- 1565
		0, -- 1566
		Color(0, 0, 0, 0) -- 1567
	) -- 1567
	do -- 1567
		local i = 0 -- 1569
		while i < 3 do -- 1569
			local wy = bot + 12 + i * 12 -- 1570
			do -- 1570
				local sx = -vw / 2 -- 1571
				while sx < vw / 2 do -- 1571
					seg( -- 1572
						d, -- 1573
						sx, -- 1574
						wy + waveY(sx, time, i), -- 1575
						sx + 46, -- 1576
						wy + waveY(sx + 46, time, i), -- 1577
						1.6, -- 1578
						i == 0 and CYAN or Palette.paleInk, -- 1579
						0.22 + i * 0.06 -- 1580
					) -- 1580
					sx = sx + 46 -- 1571
				end -- 1571
			end -- 1571
			i = i + 1 -- 1569
		end -- 1569
	end -- 1569
end -- 1558
function WorldRenderer.prototype.drawTerrain(self, time) -- 1587
	local d = self.platformDraw -- 1588
	d:clear() -- 1589
	for ____, p in ipairs(self.data.platforms) do -- 1590
		do -- 1590
			if p.kind == "gate" then -- 1590
				goto __continue264 -- 1592
			end -- 1592
			if self:floorOfY(p.y + p.h) ~= self.activeFloor then -- 1592
				goto __continue264 -- 1596
			end -- 1596
			if not self:inView(p.x, p.y - 60, p.x + p.w, p.y + p.h + 60) then -- 1596
				goto __continue264 -- 1599
			end -- 1599
			if p.mover ~= nil then -- 1599
				self:drawMover(d, p, time) -- 1602
				goto __continue264 -- 1603
			end -- 1603
			if p.kind == "solid" then -- 1603
				if p.w >= 300 then -- 1603
					d:drawPolygon( -- 1608
						{ -- 1609
							Vec2(p.x + 5, p.y + p.h), -- 1610
							Vec2(p.x + p.w - 5, p.y + p.h), -- 1611
							Vec2(p.x + p.w - 1, p.y + 1), -- 1612
							Vec2(p.x + 1, p.y + 1) -- 1613
						}, -- 1613
						col(ink(38, 45, 44, 225)), -- 1615
						0, -- 1616
						Color(0, 0, 0, 0) -- 1617
					) -- 1617
					seg( -- 1619
						d, -- 1619
						p.x + 4, -- 1619
						p.y + p.h - 1, -- 1619
						p.x + p.w - 4, -- 1619
						p.y + p.h - 1, -- 1619
						2, -- 1619
						PAPER_DIM -- 1619
					) -- 1619
					local crackX = p.x + 30 + p.x % math.max(60, p.w - 90) -- 1620
					seg( -- 1621
						d, -- 1621
						crackX, -- 1621
						p.y + p.h - 8, -- 1621
						crackX + 22, -- 1621
						p.y + 8, -- 1621
						1.4, -- 1621
						ink(26, 32, 31, 80) -- 1621
					) -- 1621
				else -- 1621
					d:drawPolygon( -- 1624
						{ -- 1625
							Vec2(p.x, p.y + p.h), -- 1626
							Vec2(p.x + p.w, p.y + p.h), -- 1627
							Vec2(p.x + p.w, p.y + 2), -- 1628
							Vec2(p.x, p.y + 2) -- 1629
						}, -- 1629
						col(ink(96, 70, 48, 220)), -- 1631
						0, -- 1632
						Color(0, 0, 0, 0) -- 1633
					) -- 1633
					seg( -- 1635
						d, -- 1635
						p.x + 2, -- 1635
						p.y + p.h - 1, -- 1635
						p.x + p.w - 2, -- 1635
						p.y + p.h - 1, -- 1635
						1.8, -- 1635
						ink(158, 120, 84, 150) -- 1635
					) -- 1635
					dot( -- 1636
						d, -- 1636
						p.x + 5, -- 1636
						p.y + p.h - 5, -- 1636
						1.6, -- 1636
						Palette.inkDark, -- 1636
						0.75 -- 1636
					) -- 1636
					dot( -- 1637
						d, -- 1637
						p.x + p.w - 5, -- 1637
						p.y + p.h - 5, -- 1637
						1.6, -- 1637
						Palette.inkDark, -- 1637
						0.75 -- 1637
					) -- 1637
				end -- 1637
			else -- 1637
				d:drawPolygon( -- 1641
					{ -- 1642
						Vec2(p.x, p.y + p.h), -- 1643
						Vec2(p.x + p.w, p.y + p.h), -- 1644
						Vec2(p.x + p.w, p.y + p.h - 8), -- 1645
						Vec2(p.x, p.y + p.h - 8) -- 1646
					}, -- 1646
					col(ink(110, 82, 56, 200)), -- 1648
					0, -- 1649
					Color(0, 0, 0, 0) -- 1650
				) -- 1650
				seg( -- 1652
					d, -- 1652
					p.x + 2, -- 1652
					p.y + p.h - 1, -- 1652
					p.x + p.w - 2, -- 1652
					p.y + p.h - 1, -- 1652
					1.5, -- 1652
					PAPER_DIM -- 1652
				) -- 1652
			end -- 1652
		end -- 1652
		::__continue264:: -- 1652
	end -- 1652
	for ____, l in ipairs(self.data.ladders) do -- 1655
		do -- 1655
			if l.floor ~= self.activeFloor then -- 1655
				goto __continue274 -- 1657
			end -- 1657
			if not self:inView(l.x, l.y, l.x + l.w, l.y + l.h) then -- 1657
				goto __continue274 -- 1660
			end -- 1660
			local wood = ink(84, 66, 44, 235) -- 1662
			seg( -- 1663
				d, -- 1663
				l.x + 2, -- 1663
				l.y, -- 1663
				l.x + 2, -- 1663
				l.y + l.h, -- 1663
				3, -- 1663
				wood -- 1663
			) -- 1663
			seg( -- 1664
				d, -- 1664
				l.x + l.w - 2, -- 1664
				l.y, -- 1664
				l.x + l.w - 2, -- 1664
				l.y + l.h, -- 1664
				3, -- 1664
				wood -- 1664
			) -- 1664
			do -- 1664
				local ry = l.y + 10 -- 1665
				while ry < l.y + l.h - 4 do -- 1665
					seg( -- 1666
						d, -- 1666
						l.x + 4, -- 1666
						ry, -- 1666
						l.x + l.w - 4, -- 1666
						ry, -- 1666
						2.4, -- 1666
						ink(102, 80, 52, 220) -- 1666
					) -- 1666
					ry = ry + 18 -- 1665
				end -- 1665
			end -- 1665
		end -- 1665
		::__continue274:: -- 1665
	end -- 1665
	for ____, cw in ipairs(self.data.climbWalls) do -- 1669
		do -- 1669
			if self:floorOfY(cw.y + cw.h) ~= self.activeFloor then -- 1669
				goto __continue280 -- 1671
			end -- 1671
			if not self:inView(cw.x, cw.y, cw.x + cw.w, cw.y + cw.h) then -- 1671
				goto __continue280 -- 1674
			end -- 1674
			local crag = ink(64, 58, 52, 200) -- 1676
			seg( -- 1677
				d, -- 1677
				cw.x, -- 1677
				cw.y + cw.h, -- 1677
				cw.x + cw.w, -- 1677
				cw.y + cw.h, -- 1677
				3, -- 1677
				crag -- 1677
			) -- 1677
			do -- 1677
				local i = 0 -- 1678
				while i <= 4 do -- 1678
					local xx = cw.x + 6 + i * (cw.w - 12) / 4 -- 1679
					seg( -- 1680
						d, -- 1680
						xx, -- 1680
						cw.y + cw.h, -- 1680
						xx + 7, -- 1680
						cw.y + cw.h * 0.55, -- 1680
						3.4, -- 1680
						crag -- 1680
					) -- 1680
					seg( -- 1681
						d, -- 1681
						xx + 7, -- 1681
						cw.y + cw.h * 0.55, -- 1681
						xx + 2, -- 1681
						cw.y + 4, -- 1681
						2.6, -- 1681
						ink(64, 58, 52, 130) -- 1681
					) -- 1681
					i = i + 1 -- 1678
				end -- 1678
			end -- 1678
		end -- 1678
		::__continue280:: -- 1678
	end -- 1678
end -- 1587
function WorldRenderer.prototype.drawMover(self, d, p, time) -- 1686
	local m = p.mover -- 1687
	if m == nil then -- 1687
		return -- 1689
	end -- 1689
	local x = p.x -- 1695
	local y = p.y -- 1696
	do -- 1696
		local i = 0 -- 1698
		while i < 8 do -- 1698
			local t0 = i / 8 + 0.02 -- 1699
			local t1 = t0 + 0.06 -- 1700
			seg( -- 1701
				d, -- 1702
				m.ax + (m.bx - m.ax) * t0 + p.w / 2, -- 1703
				m.ay + (m.by - m.ay) * t0 + p.h / 2, -- 1704
				m.ax + (m.bx - m.ax) * t1 + p.w / 2, -- 1705
				m.ay + (m.by - m.ay) * t1 + p.h / 2, -- 1706
				2, -- 1707
				PAPER_DIM -- 1708
			) -- 1708
			i = i + 1 -- 1698
		end -- 1698
	end -- 1698
	d:drawPolygon( -- 1711
		{ -- 1712
			Vec2(x, y + p.h), -- 1712
			Vec2(x + p.w, y + p.h), -- 1712
			Vec2(x + p.w, y + 2), -- 1712
			Vec2(x, y + 2) -- 1712
		}, -- 1712
		col(ink(52, 60, 58, 230)), -- 1713
		0, -- 1714
		Color(0, 0, 0, 0) -- 1715
	) -- 1715
	seg( -- 1717
		d, -- 1717
		x + 2, -- 1717
		y + p.h - 1, -- 1717
		x + p.w - 2, -- 1717
		y + p.h - 1, -- 1717
		1.8, -- 1717
		PAPER_DIM -- 1717
	) -- 1717
	dot( -- 1718
		d, -- 1718
		x + p.w / 2, -- 1718
		y + p.h / 2, -- 1718
		4 + math.sin(time * 3) * 1, -- 1718
		GOLD, -- 1718
		0.85 -- 1718
	) -- 1718
end -- 1686
function WorldRenderer.prototype.drawProps(self, time, state) -- 1722
	local d = self.propDraw -- 1723
	d:clear() -- 1724
	self:drawGates(d, state) -- 1725
	self:drawRopes(d, time, state) -- 1726
	self:drawBells(d, time, state) -- 1727
	self:drawPlates(d, time, state) -- 1728
	self:drawSwordSlots(d, time, state) -- 1729
	self:drawWindSigils(d, time, state) -- 1730
	self:drawStarNodes(d, time, state) -- 1731
	self:drawLanterns(d, time, state) -- 1732
	self:drawCheckpoints(d, time, state) -- 1733
	self:drawCollectibles(d, time, state) -- 1734
	self:drawDecor(d, time) -- 1735
end -- 1722
function WorldRenderer.prototype.drawGates(self, d, state) -- 1738
	for ____, gp in ipairs(self.gateParts) do -- 1739
		do -- 1739
			if #gp.rects == 0 then -- 1739
				goto __continue292 -- 1741
			end -- 1741
			local open = state.openedGates[gp.gid] == true -- 1743
			local x0 = 1000000000 -- 1744
			local y0 = 1000000000 -- 1745
			local x1 = -1000000000 -- 1746
			local y1 = -1000000000 -- 1747
			for ____, r in ipairs(gp.rects) do -- 1748
				x0 = math.min(x0, r.x) -- 1749
				y0 = math.min(y0, r.y) -- 1750
				x1 = math.max(x1, r.x + r.w) -- 1751
				y1 = math.max(y1, r.y + r.h) -- 1752
			end -- 1752
			if self:floorOfY(y1) ~= self.activeFloor then -- 1752
				goto __continue292 -- 1755
			end -- 1755
			if not self:inView(x0, y0, x1, y1) then -- 1755
				goto __continue292 -- 1758
			end -- 1758
			local postC = ink(52, 46, 38, 235) -- 1761
			for ____, r in ipairs(gp.rects) do -- 1762
				local isPost = r.w <= 14 or r.h >= (y1 - y0) * 0.9 -- 1763
				if not open or isPost then -- 1763
					d:drawPolygon( -- 1765
						{ -- 1766
							Vec2(r.x, r.y + r.h), -- 1766
							Vec2(r.x + r.w, r.y + r.h), -- 1766
							Vec2(r.x + r.w, r.y), -- 1766
							Vec2(r.x, r.y) -- 1766
						}, -- 1766
						col(isPost and postC or ink(64, 58, 50, 220)), -- 1767
						0, -- 1768
						Color(0, 0, 0, 0) -- 1769
					) -- 1769
				end -- 1769
			end -- 1769
			seg( -- 1774
				d, -- 1774
				x0 - 6, -- 1774
				y1 + 4, -- 1774
				x1 + 6, -- 1774
				y1 + 4, -- 1774
				4, -- 1774
				postC -- 1774
			) -- 1774
			seg( -- 1775
				d, -- 1775
				x0 - 6, -- 1775
				y1 + 8, -- 1775
				x1 + 6, -- 1775
				y1 + 8, -- 1775
				1.6, -- 1775
				GOLD, -- 1775
				0.5 -- 1775
			) -- 1775
			if not open then -- 1775
				do -- 1775
					local i = 1 -- 1778
					while i <= 3 do -- 1778
						local sx = x0 + (x1 - x0) * i / 4 -- 1779
						seg( -- 1780
							d, -- 1780
							sx - 10, -- 1780
							y0 + 6, -- 1780
							sx + 10, -- 1780
							y1 - 6, -- 1780
							1.8, -- 1780
							ink(84, 76, 62, 180) -- 1780
						) -- 1780
						i = i + 1 -- 1778
					end -- 1778
				end -- 1778
			end -- 1778
		end -- 1778
		::__continue292:: -- 1778
	end -- 1778
end -- 1738
function WorldRenderer.prototype.drawRopes(self, d, time, state) -- 1786
	for ____, r in ipairs(self.data.ropes) do -- 1787
		do -- 1787
			if self:floorOfY(r.y) ~= self.activeFloor then -- 1787
				goto __continue306 -- 1789
			end -- 1789
			if not self:inView(r.x - 30, r.y - r.length - 30, r.x + 30, r.y + 10) then -- 1789
				goto __continue306 -- 1792
			end -- 1792
			if state.cutRopes[r.id] == true then -- 1792
				seg( -- 1796
					d, -- 1796
					r.x, -- 1796
					r.y, -- 1796
					r.x - 2, -- 1796
					r.y - 12, -- 1796
					3, -- 1796
					Palette.inkDark, -- 1796
					0.9 -- 1796
				) -- 1796
				local fall = math.min(r.length * 0.5, 60) -- 1797
				do -- 1797
					local i = 0 -- 1798
					while i < 4 do -- 1798
						local yy0 = r.y - 12 - i * fall / 4 -- 1799
						local yy1 = r.y - 12 - (i + 1) * fall / 4 -- 1800
						local sway = math.sin(time * 2.4 + i) * 3 -- 1801
						seg( -- 1802
							d, -- 1802
							r.x - 2 + sway * 0.5, -- 1802
							yy0, -- 1802
							r.x - 4 + sway, -- 1802
							yy1, -- 1802
							2.2, -- 1802
							Palette.inkSoft, -- 1802
							0.5 - i * 0.1 -- 1802
						) -- 1802
						i = i + 1 -- 1798
					end -- 1798
				end -- 1798
			else -- 1798
				local px = r.x -- 1806
				local py = r.y -- 1807
				do -- 1807
					local i = 1 -- 1808
					while i <= 8 do -- 1808
						local tt = i / 8 -- 1809
						local yy = r.y - r.length * tt -- 1810
						local sway = math.sin(time * 1.6 + tt * 3 + r.x * 0.05) * 4 * tt -- 1811
						local nx = r.x + sway -- 1812
						seg( -- 1813
							d, -- 1813
							px, -- 1813
							py, -- 1813
							nx, -- 1813
							yy, -- 1813
							2.6, -- 1813
							Palette.inkDark, -- 1813
							0.92 -- 1813
						) -- 1813
						px = nx -- 1814
						py = yy -- 1815
						i = i + 1 -- 1808
					end -- 1808
				end -- 1808
				dot( -- 1817
					d, -- 1817
					px, -- 1817
					py, -- 1817
					3, -- 1817
					Palette.inkDark, -- 1817
					0.9 -- 1817
				) -- 1817
			end -- 1817
		end -- 1817
		::__continue306:: -- 1817
	end -- 1817
end -- 1786
function WorldRenderer.prototype.drawBells(self, d, time, state) -- 1822
	for ____, b in ipairs(self.data.bells) do -- 1823
		do -- 1823
			if self:floorOfY(b.y) ~= self.activeFloor then -- 1823
				goto __continue317 -- 1825
			end -- 1825
			if not self:inView(b.x - 40, b.y, b.x + 40, b.y + 60) then -- 1825
				goto __continue317 -- 1828
			end -- 1828
			local frame = ink(58, 50, 40, 230) -- 1830
			seg( -- 1831
				d, -- 1831
				b.x - 20, -- 1831
				b.y, -- 1831
				b.x - 20, -- 1831
				b.y + 46, -- 1831
				3.5, -- 1831
				frame -- 1831
			) -- 1831
			seg( -- 1832
				d, -- 1832
				b.x + 20, -- 1832
				b.y, -- 1832
				b.x + 20, -- 1832
				b.y + 46, -- 1832
				3.5, -- 1832
				frame -- 1832
			) -- 1832
			seg( -- 1833
				d, -- 1833
				b.x - 26, -- 1833
				b.y + 46, -- 1833
				b.x + 26, -- 1833
				b.y + 46, -- 1833
				3.5, -- 1833
				frame -- 1833
			) -- 1833
			d:drawPolygon( -- 1834
				{ -- 1835
					Vec2(b.x - 13, b.y + 44), -- 1835
					Vec2(b.x + 13, b.y + 44), -- 1835
					Vec2(b.x + 16, b.y + 24), -- 1835
					Vec2(b.x - 16, b.y + 24) -- 1835
				}, -- 1835
				col(ink(46, 52, 50, 235)), -- 1836
				0, -- 1837
				Color(0, 0, 0, 0) -- 1838
			) -- 1838
			seg( -- 1840
				d, -- 1840
				b.x - 17, -- 1840
				b.y + 24, -- 1840
				b.x + 17, -- 1840
				b.y + 24, -- 1840
				2, -- 1840
				GOLD, -- 1840
				0.5 -- 1840
			) -- 1840
			dot( -- 1841
				d, -- 1841
				b.x, -- 1841
				b.y + 21, -- 1841
				2.2, -- 1841
				GOLD, -- 1841
				0.8 -- 1841
			) -- 1841
			if state.rungBells[b.id] == true then -- 1841
				local pulse = time * 0.9 % 1 -- 1843
				local pulse2 = (pulse + 0.5) % 1 -- 1844
				circle( -- 1845
					d, -- 1845
					b.x, -- 1845
					b.y + 30, -- 1845
					10 + pulse * 46, -- 1845
					GOLD, -- 1845
					18, -- 1845
					(1 - pulse) * 0.8 -- 1845
				) -- 1845
				circle( -- 1846
					d, -- 1846
					b.x, -- 1846
					b.y + 30, -- 1846
					10 + pulse2 * 46, -- 1846
					GOLD, -- 1846
					18, -- 1846
					(1 - pulse2) * 0.5 -- 1846
				) -- 1846
			end -- 1846
		end -- 1846
		::__continue317:: -- 1846
	end -- 1846
end -- 1822
function WorldRenderer.prototype.drawPlates(self, d, time, state) -- 1851
	for ____, pl in ipairs(self.data.plates) do -- 1852
		do -- 1852
			if self:floorOfY(pl.y) ~= self.activeFloor then -- 1852
				goto __continue323 -- 1854
			end -- 1854
			if not self:inView(pl.x - 44, pl.y, pl.x + 44, pl.y + 16) then -- 1854
				goto __continue323 -- 1857
			end -- 1857
			local on = state.platesActive[pl.id] == true -- 1859
			local sink = on and 4 or 0 -- 1860
			d:drawPolygon( -- 1861
				{ -- 1862
					Vec2(pl.x - 36, pl.y + 10 - sink), -- 1863
					Vec2(pl.x + 36, pl.y + 10 - sink), -- 1864
					Vec2(pl.x + 32, pl.y + 2 - sink), -- 1865
					Vec2(pl.x - 32, pl.y + 2 - sink) -- 1866
				}, -- 1866
				col(ink(on and 30 or 42, on and 36 or 50, on and 34 or 48, 235)), -- 1868
				0, -- 1869
				Color(0, 0, 0, 0) -- 1870
			) -- 1870
			if on then -- 1870
				seg( -- 1873
					d, -- 1873
					pl.x - 36, -- 1873
					pl.y + 11 - sink, -- 1873
					pl.x + 36, -- 1873
					pl.y + 11 - sink, -- 1873
					1.6, -- 1873
					GOLD, -- 1873
					0.55 + 0.25 * math.sin(time * 6) -- 1873
				) -- 1873
			else -- 1873
				seg( -- 1875
					d, -- 1875
					pl.x - 32, -- 1875
					pl.y + 10, -- 1875
					pl.x + 32, -- 1875
					pl.y + 10, -- 1875
					1.2, -- 1875
					PAPER_DIM -- 1875
				) -- 1875
			end -- 1875
		end -- 1875
		::__continue323:: -- 1875
	end -- 1875
end -- 1851
function WorldRenderer.prototype.drawSwordSlots(self, d, time, state) -- 1881
	local slots = self.data.swordSlots -- 1882
	if slots == nil then -- 1882
		return -- 1884
	end -- 1884
	for ____, slot in ipairs(slots) do -- 1886
		do -- 1886
			if self:floorOfY(slot.y) ~= self.activeFloor then -- 1886
				goto __continue331 -- 1888
			end -- 1888
			if not self:inView(slot.x - 44, slot.y, slot.x + 44, slot.y + 110) then -- 1888
				goto __continue331 -- 1891
			end -- 1891
			local inserted = state.flags["swordslot_" .. slot.id] == true -- 1893
			d:drawPolygon( -- 1895
				{ -- 1896
					Vec2(slot.x - 24, slot.y + 12), -- 1896
					Vec2(slot.x + 24, slot.y + 12), -- 1896
					Vec2(slot.x + 20, slot.y), -- 1896
					Vec2(slot.x - 20, slot.y) -- 1896
				}, -- 1896
				col(ink(58, 54, 48, 235)), -- 1897
				0, -- 1898
				Color(0, 0, 0, 0) -- 1899
			) -- 1899
			seg( -- 1901
				d, -- 1901
				slot.x - 20, -- 1901
				slot.y + 12, -- 1901
				slot.x + 20, -- 1901
				slot.y + 12, -- 1901
				1.6, -- 1901
				PAPER_DIM, -- 1901
				0.8 -- 1901
			) -- 1901
			d:drawPolygon( -- 1903
				{ -- 1904
					Vec2(slot.x - 3.5, slot.y + 58), -- 1904
					Vec2(slot.x + 3.5, slot.y + 58), -- 1904
					Vec2(slot.x + 3.5, slot.y + 10), -- 1904
					Vec2(slot.x - 3.5, slot.y + 10) -- 1904
				}, -- 1904
				col(ink(28, 26, 23, 240)), -- 1905
				0, -- 1906
				Color(0, 0, 0, 0) -- 1907
			) -- 1907
			seg( -- 1909
				d, -- 1909
				slot.x - 3.5, -- 1909
				slot.y + 34, -- 1909
				slot.x - 3.5, -- 1909
				slot.y + 56, -- 1909
				1.2, -- 1909
				GOLD, -- 1909
				inserted and 0.9 or 0.4 -- 1909
			) -- 1909
			seg( -- 1910
				d, -- 1910
				slot.x + 3.5, -- 1910
				slot.y + 34, -- 1910
				slot.x + 3.5, -- 1910
				slot.y + 56, -- 1910
				1.2, -- 1910
				GOLD, -- 1910
				inserted and 0.9 or 0.4 -- 1910
			) -- 1910
			if inserted then -- 1910
				local glow = 0.75 + 0.25 * math.sin(time * 2.2) -- 1913
				d:drawPolygon( -- 1914
					{ -- 1915
						Vec2(slot.x - 4, slot.y + 62), -- 1915
						Vec2(slot.x + 4, slot.y + 62), -- 1915
						Vec2(slot.x + 2.4, slot.y + 16), -- 1915
						Vec2(slot.x - 2.4, slot.y + 16) -- 1915
					}, -- 1915
					col(ink(198, 204, 196, 235)), -- 1916
					0, -- 1917
					Color(0, 0, 0, 0) -- 1918
				) -- 1918
				d:drawPolygon( -- 1920
					{ -- 1921
						Vec2(slot.x - 4, slot.y + 62), -- 1921
						Vec2(slot.x, slot.y + 62), -- 1921
						Vec2(slot.x, slot.y + 16), -- 1921
						Vec2(slot.x - 2.4, slot.y + 16) -- 1921
					}, -- 1921
					col(ink(236, 240, 232, 120)), -- 1922
					0, -- 1923
					Color(0, 0, 0, 0) -- 1924
				) -- 1924
				seg( -- 1926
					d, -- 1926
					slot.x - 12, -- 1926
					slot.y + 58, -- 1926
					slot.x + 12, -- 1926
					slot.y + 58, -- 1926
					4, -- 1926
					GOLD, -- 1926
					0.95 -- 1926
				) -- 1926
				seg( -- 1927
					d, -- 1927
					slot.x - 12, -- 1927
					slot.y + 56.4, -- 1927
					slot.x + 12, -- 1927
					slot.y + 56.4, -- 1927
					1.2, -- 1927
					ink(120, 92, 44, 220), -- 1927
					0.8 -- 1927
				) -- 1927
				seg( -- 1928
					d, -- 1928
					slot.x, -- 1928
					slot.y + 56, -- 1928
					slot.x, -- 1928
					slot.y + 44, -- 1928
					3.2, -- 1928
					ink(74, 58, 40, 235), -- 1928
					0.95 -- 1928
				) -- 1928
				dot( -- 1929
					d, -- 1929
					slot.x, -- 1929
					slot.y + 42.5, -- 1929
					3, -- 1929
					GOLD, -- 1929
					glow -- 1929
				) -- 1929
				dot( -- 1930
					d, -- 1930
					slot.x, -- 1930
					slot.y + 70, -- 1930
					10, -- 1930
					Palette.moonWhite, -- 1930
					0.04 + 0.05 * glow -- 1930
				) -- 1930
			end -- 1930
		end -- 1930
		::__continue331:: -- 1930
	end -- 1930
end -- 1881
function WorldRenderer.prototype.drawWindSigils(self, d, time, state) -- 1936
	do -- 1936
		local i = 0 -- 1937
		while i < #self.data.windSigils do -- 1937
			do -- 1937
				local s = self.data.windSigils[i + 1] -- 1938
				if self:floorOfY(s.y) ~= self.activeFloor or not self:inView(s.x - 60, s.y - 10, s.x + 60, s.y + 110) then -- 1938
					goto __continue338 -- 1940
				end -- 1940
				local on = state.flags["wind_" .. s.id] == true -- 1942
				local cy = s.y + 34 -- 1943
				circle( -- 1944
					d, -- 1944
					s.x, -- 1944
					cy, -- 1944
					26, -- 1944
					ink(58, 54, 48, 200), -- 1944
					3, -- 1944
					0.9 -- 1944
				) -- 1944
				local spin = on and time * 1.6 or 0 -- 1945
				do -- 1945
					local k = 0 -- 1946
					while k < 3 do -- 1946
						local a = spin + k * math.pi * 2 / 3 -- 1947
						local ax = s.x + math.cos(a) * 13 -- 1948
						local ay = cy + math.sin(a) * 11 -- 1949
						local bx = s.x + math.cos(a + 0.9) * 23 -- 1950
						local by = cy + math.sin(a + 0.9) * 19 -- 1951
						seg( -- 1952
							d, -- 1952
							ax, -- 1952
							ay, -- 1952
							bx, -- 1952
							by, -- 1952
							2.6, -- 1952
							on and CYAN or PAPER_DIM, -- 1952
							on and 0.95 or 0.7 -- 1952
						) -- 1952
						k = k + 1 -- 1946
					end -- 1946
				end -- 1946
				dot( -- 1954
					d, -- 1954
					s.x, -- 1954
					cy, -- 1954
					on and 5 or 3, -- 1954
					on and CYAN or PAPER_DIM, -- 1954
					on and 0.95 or 0.8 -- 1954
				) -- 1954
				if on then -- 1954
					do -- 1954
						local k = 0 -- 1956
						while k < 3 do -- 1956
							local t = (time * 0.7 + k / 3) % 1 -- 1957
							dot( -- 1958
								d, -- 1958
								s.x + math.sin((t * 6 + k) * 2) * 8, -- 1958
								s.y + 20 + t * 56, -- 1958
								2.4, -- 1958
								CYAN, -- 1958
								(1 - t) * 0.7 -- 1958
							) -- 1958
							k = k + 1 -- 1956
						end -- 1956
					end -- 1956
					local pulse = time * 0.9 % 1 -- 1960
					circle( -- 1961
						d, -- 1961
						s.x, -- 1961
						cy, -- 1961
						20 + pulse * 40, -- 1961
						CYAN, -- 1961
						14, -- 1961
						(1 - pulse) * 0.5 -- 1961
					) -- 1961
				end -- 1961
			end -- 1961
			::__continue338:: -- 1961
			i = i + 1 -- 1937
		end -- 1937
	end -- 1937
end -- 1936
function WorldRenderer.prototype.drawStarNodes(self, d, time, state) -- 1967
	local nodes = self.data.starNodes -- 1968
	do -- 1968
		local i = 0 -- 1969
		while i < #nodes - 1 do -- 1969
			do -- 1969
				local a = nodes[i + 1] -- 1970
				local b = nodes[i + 1 + 1] -- 1971
				if self:floorOfY(a.y) ~= self.activeFloor or self:floorOfY(b.y) ~= self.activeFloor then -- 1971
					goto __continue347 -- 1973
				end -- 1973
				if state.flags["star_" .. a.id] == true and state.flags["star_" .. b.id] == true then -- 1973
					local pulse = 0.5 + 0.25 * math.sin(time * 2.4 + i) -- 1976
					seg( -- 1977
						d, -- 1977
						a.x, -- 1977
						a.y + 58, -- 1977
						b.x, -- 1977
						b.y + 58, -- 1977
						1.6, -- 1977
						Palette.moonWhite, -- 1977
						pulse -- 1977
					) -- 1977
				end -- 1977
			end -- 1977
			::__continue347:: -- 1977
			i = i + 1 -- 1969
		end -- 1969
	end -- 1969
	do -- 1969
		local i = 0 -- 1980
		while i < #nodes do -- 1980
			do -- 1980
				local s = nodes[i + 1] -- 1981
				if self:floorOfY(s.y) ~= self.activeFloor or not self:inView(s.x - 44, s.y - 20, s.x + 44, s.y + 110) then -- 1981
					goto __continue351 -- 1983
				end -- 1983
				local lit = state.flags["star_" .. s.id] == true -- 1985
				seg( -- 1986
					d, -- 1986
					s.x, -- 1986
					s.y, -- 1986
					s.x, -- 1986
					s.y + 40, -- 1986
					4, -- 1986
					ink(70, 60, 46, 235) -- 1986
				) -- 1986
				seg( -- 1987
					d, -- 1987
					s.x - 9, -- 1987
					s.y + 40, -- 1987
					s.x + 9, -- 1987
					s.y + 40, -- 1987
					3, -- 1987
					ink(70, 60, 46, 235) -- 1987
				) -- 1987
				local cy = s.y + 58 -- 1988
				local c = lit and Palette.moonWhite or PAPER_DIM -- 1989
				local tw = lit and 0.75 + 0.25 * math.sin(time * 3 + i * 1.7) or 0.5 -- 1990
				local r = lit and 12 or 7 -- 1991
				seg( -- 1992
					d, -- 1992
					s.x - r, -- 1992
					cy, -- 1992
					s.x + r, -- 1992
					cy, -- 1992
					1.8, -- 1992
					c, -- 1992
					tw -- 1992
				) -- 1992
				seg( -- 1993
					d, -- 1993
					s.x, -- 1993
					cy - r, -- 1993
					s.x, -- 1993
					cy + r, -- 1993
					1.8, -- 1993
					c, -- 1993
					tw -- 1993
				) -- 1993
				dot( -- 1994
					d, -- 1994
					s.x, -- 1994
					cy, -- 1994
					lit and 5.5 or 3, -- 1994
					c, -- 1994
					tw -- 1994
				) -- 1994
				if lit then -- 1994
					dot( -- 1996
						d, -- 1996
						s.x, -- 1996
						cy, -- 1996
						15, -- 1996
						Palette.moonWhite, -- 1996
						0.06 -- 1996
					) -- 1996
				end -- 1996
			end -- 1996
			::__continue351:: -- 1996
			i = i + 1 -- 1980
		end -- 1980
	end -- 1980
end -- 1967
function WorldRenderer.prototype.drawLanterns(self, d, time, state) -- 2001
	for ____, ln in ipairs(self.data.lanterns) do -- 2002
		do -- 2002
			if self:floorOfY(ln.y) ~= self.activeFloor then -- 2002
				goto __continue355 -- 2004
			end -- 2004
			if not self:inView(ln.x - 30, ln.y, ln.x + 30, ln.y + 76) then -- 2004
				goto __continue355 -- 2007
			end -- 2007
			local pole = ink(70, 60, 46, 235) -- 2009
			seg( -- 2010
				d, -- 2010
				ln.x, -- 2010
				ln.y, -- 2010
				ln.x, -- 2010
				ln.y + 60, -- 2010
				4, -- 2010
				pole -- 2010
			) -- 2010
			seg( -- 2011
				d, -- 2011
				ln.x - 11, -- 2011
				ln.y + 60, -- 2011
				ln.x + 11, -- 2011
				ln.y + 60, -- 2011
				3, -- 2011
				pole -- 2011
			) -- 2011
			seg( -- 2012
				d, -- 2012
				ln.x, -- 2012
				ln.y + 60, -- 2012
				ln.x, -- 2012
				ln.y + 58, -- 2012
				1.6, -- 2012
				pole -- 2012
			) -- 2012
			local bx = ln.x -- 2013
			local by = ln.y + 46 -- 2014
			local lit = state.lanternsLit[ln.id] == true -- 2015
			local alpha = 1 -- 2016
			if state.lanternFailed then -- 2016
				local flash = 0.5 + 0.5 * math.sin(time * 9) -- 2018
				alpha = lit and 0.5 + 0.5 * flash or 0.35 -- 2019
			end -- 2019
			if lit then -- 2019
				dot( -- 2022
					d, -- 2022
					bx, -- 2022
					by, -- 2022
					17, -- 2022
					ink(244, 196, 120, 42), -- 2022
					alpha -- 2022
				) -- 2022
				d:drawPolygon( -- 2023
					{ -- 2024
						Vec2(bx - 9, by + 11), -- 2024
						Vec2(bx + 9, by + 11), -- 2024
						Vec2(bx + 7.5, by - 11), -- 2024
						Vec2(bx - 7.5, by - 11) -- 2024
					}, -- 2024
					col( -- 2025
						ink(238, 178, 92, 150), -- 2025
						alpha -- 2025
					), -- 2025
					0, -- 2026
					Color(0, 0, 0, 0) -- 2027
				) -- 2027
				dot( -- 2029
					d, -- 2029
					bx, -- 2029
					by, -- 2029
					5, -- 2029
					ink(255, 232, 180, 220), -- 2029
					alpha -- 2029
				) -- 2029
			else -- 2029
				d:drawPolygon( -- 2031
					{ -- 2032
						Vec2(bx - 9, by + 11), -- 2032
						Vec2(bx + 9, by + 11), -- 2032
						Vec2(bx + 7.5, by - 11), -- 2032
						Vec2(bx - 7.5, by - 11) -- 2032
					}, -- 2032
					col(ink(58, 62, 60, 200)), -- 2033
					0, -- 2034
					Color(0, 0, 0, 0) -- 2035
				) -- 2035
			end -- 2035
			seg( -- 2038
				d, -- 2038
				bx - 9, -- 2038
				by + 11, -- 2038
				bx + 9, -- 2038
				by + 11, -- 2038
				2, -- 2038
				ink(120, 84, 44, 235), -- 2038
				alpha -- 2038
			) -- 2038
			seg( -- 2039
				d, -- 2039
				bx - 7.5, -- 2039
				by - 11, -- 2039
				bx + 7.5, -- 2039
				by - 11, -- 2039
				2, -- 2039
				ink(120, 84, 44, 235), -- 2039
				alpha -- 2039
			) -- 2039
			if state.lanternFailed and lit then -- 2039
				dot( -- 2041
					d, -- 2041
					bx, -- 2041
					by, -- 2041
					8, -- 2041
					ink(140, 59, 59, 90), -- 2041
					alpha -- 2041
				) -- 2041
			end -- 2041
		end -- 2041
		::__continue355:: -- 2041
	end -- 2041
end -- 2001
function WorldRenderer.prototype.drawCheckpoints(self, d, time, state) -- 2046
	for ____, cp in ipairs(self.data.checkpoints) do -- 2047
		do -- 2047
			if self:floorOfY(cp.y) ~= self.activeFloor then -- 2047
				goto __continue364 -- 2049
			end -- 2049
			if not self:inView(cp.x - 60, cp.y, cp.x + 60, cp.y + 90) then -- 2049
				goto __continue364 -- 2052
			end -- 2052
			if cp.id == "cp_riverbank" then -- 2052
				goto __continue364 -- 2055
			end -- 2055
			local active = state.checkpointsActivated[cp.id] == true -- 2057
			local stone = ink(44, 50, 48, 235) -- 2058
			d:drawPolygon( -- 2059
				{ -- 2060
					Vec2(cp.x - 7, cp.y + 40), -- 2060
					Vec2(cp.x + 7, cp.y + 40), -- 2060
					Vec2(cp.x + 8, cp.y), -- 2060
					Vec2(cp.x - 8, cp.y) -- 2060
				}, -- 2060
				col(stone), -- 2061
				0, -- 2062
				Color(0, 0, 0, 0) -- 2063
			) -- 2063
			dot( -- 2065
				d, -- 2065
				cp.x, -- 2065
				cp.y + 40, -- 2065
				7, -- 2065
				stone -- 2065
			) -- 2065
			seg( -- 2066
				d, -- 2066
				cp.x - 4, -- 2066
				cp.y + 28, -- 2066
				cp.x + 4, -- 2066
				cp.y + 28, -- 2066
				1.2, -- 2066
				PAPER_DIM, -- 2066
				0.8 -- 2066
			) -- 2066
			local fs = self.flagSets[cp.id] -- 2067
			if fs ~= nil then -- 2067
				fs.off.visible = not active -- 2070
				local frame = math.floor(time * 8) % #fs.on -- 2071
				do -- 2071
					local fi = 0 -- 2072
					while fi < #fs.on do -- 2072
						fs.on[fi + 1].visible = active and fi == frame -- 2073
						fi = fi + 1 -- 2072
					end -- 2072
				end -- 2072
				if active then -- 2072
					local pulse = time * 0.7 % 1 -- 2076
					circle( -- 2077
						d, -- 2077
						cp.x, -- 2077
						cp.y + 24, -- 2077
						14 + pulse * 30, -- 2077
						CYAN, -- 2077
						16, -- 2077
						(1 - pulse) * 0.5 -- 2077
					) -- 2077
				end -- 2077
			else -- 2077
				seg( -- 2080
					d, -- 2080
					cp.x + 10, -- 2080
					cp.y, -- 2080
					cp.x + 10, -- 2080
					cp.y + 64, -- 2080
					2.6, -- 2080
					ink(70, 60, 46, 235) -- 2080
				) -- 2080
				if active then -- 2080
					local flap = math.sin(time * 3) * 2 -- 2083
					d:drawPolygon( -- 2084
						{ -- 2085
							Vec2(cp.x + 10, cp.y + 64), -- 2085
							Vec2(cp.x + 32, cp.y + 60 + flap), -- 2085
							Vec2(cp.x + 32, cp.y + 50 + flap), -- 2085
							Vec2(cp.x + 10, cp.y + 54) -- 2085
						}, -- 2085
						col(CYAN, 0.8), -- 2086
						0, -- 2087
						Color(0, 0, 0, 0) -- 2088
					) -- 2088
					seg( -- 2090
						d, -- 2090
						cp.x + 10, -- 2090
						cp.y + 54, -- 2090
						cp.x + 32, -- 2090
						cp.y + 50 + flap, -- 2090
						1.2, -- 2090
						CYAN, -- 2090
						0.5 -- 2090
					) -- 2090
					local pulse = time * 0.7 % 1 -- 2091
					circle( -- 2092
						d, -- 2092
						cp.x, -- 2092
						cp.y + 24, -- 2092
						14 + pulse * 30, -- 2092
						CYAN, -- 2092
						16, -- 2092
						(1 - pulse) * 0.5 -- 2092
					) -- 2092
				else -- 2092
					seg( -- 2094
						d, -- 2094
						cp.x + 10, -- 2094
						cp.y + 64, -- 2094
						cp.x + 13, -- 2094
						cp.y + 50, -- 2094
						5, -- 2094
						Palette.inkSoft, -- 2094
						0.85 -- 2094
					) -- 2094
				end -- 2094
			end -- 2094
		end -- 2094
		::__continue364:: -- 2094
	end -- 2094
end -- 2046
function WorldRenderer.prototype.drawCollectibles(self, d, time, state) -- 2100
	for ____, c in ipairs(self.data.collectibles) do -- 2101
		do -- 2101
			if self:floorOfY(c.y) ~= self.activeFloor then -- 2101
				goto __continue377 -- 2103
			end -- 2103
			if c.loops ~= nil and __TS__ArrayIndexOf(c.loops, state.loopIndex) < 0 then -- 2103
				local gone1 = self.lampStoneSprites[c.id] -- 2106
				if gone1 ~= nil then -- 2106
					gone1.visible = false -- 2108
				end -- 2108
				local gone1m = self.moonStoneSprites[c.id] -- 2110
				if gone1m ~= nil then -- 2110
					gone1m.visible = false -- 2112
				end -- 2112
				local gone1d = self.dewSprites[c.id] -- 2114
				if gone1d ~= nil then -- 2114
					gone1d.visible = false -- 2116
				end -- 2116
				local gone1t = self.tokenSprites[c.id] -- 2118
				if gone1t ~= nil then -- 2118
					gone1t.visible = false -- 2120
				end -- 2120
				goto __continue377 -- 2122
			end -- 2122
			if state.collectedIds[c.id] == true then -- 2122
				local gone2 = self.lampStoneSprites[c.id] -- 2125
				if gone2 ~= nil then -- 2125
					gone2.visible = false -- 2127
				end -- 2127
				local gone2m = self.moonStoneSprites[c.id] -- 2129
				if gone2m ~= nil then -- 2129
					gone2m.visible = false -- 2131
				end -- 2131
				local gone2d = self.dewSprites[c.id] -- 2133
				if gone2d ~= nil then -- 2133
					gone2d.visible = false -- 2135
				end -- 2135
				local gone2t = self.tokenSprites[c.id] -- 2137
				if gone2t ~= nil then -- 2137
					gone2t.visible = false -- 2139
				end -- 2139
				goto __continue377 -- 2141
			end -- 2141
			if not self:inView(c.x - 40, c.y - 10, c.x + 40, c.y + 40) then -- 2141
				goto __continue377 -- 2144
			end -- 2144
			local bob = math.sin(time * 2 + c.x * 0.1) * 3 -- 2146
			local cx = c.x -- 2147
			local cy = c.y + bob -- 2148
			if c.kind == "lampstone" then -- 2148
				local ls = self.lampStoneSprites[c.id] -- 2151
				if ls ~= nil then -- 2151
					ls.visible = true -- 2153
					ls.position = Vec2(cx, cy + 18) -- 2154
				else -- 2154
					circle( -- 2156
						d, -- 2156
						cx, -- 2156
						cy + 14, -- 2156
						13, -- 2156
						GOLD, -- 2156
						18, -- 2156
						0.22 -- 2156
					) -- 2156
					d:drawPolygon( -- 2157
						{ -- 2158
							Vec2(cx - 7, cy + 6), -- 2158
							Vec2(cx + 7, cy + 6), -- 2158
							Vec2(cx + 4, cy + 22), -- 2158
							Vec2(cx - 4, cy + 22) -- 2158
						}, -- 2158
						col(ink(196, 168, 108, 235)), -- 2159
						0, -- 2160
						Color(0, 0, 0, 0) -- 2161
					) -- 2161
					dot( -- 2163
						d, -- 2163
						cx, -- 2163
						cy + 14, -- 2163
						3.4, -- 2163
						Palette.moonWhite, -- 2163
						0.9 -- 2163
					) -- 2163
				end -- 2163
			elseif c.kind == "moonstone" then -- 2163
				local ms = self.moonStoneSprites[c.id] -- 2167
				if ms ~= nil then -- 2167
					ms.visible = true -- 2169
					ms.position = Vec2(cx, cy + 18) -- 2170
				else -- 2170
					dot( -- 2172
						d, -- 2172
						cx, -- 2172
						cy + 12, -- 2172
						13, -- 2172
						CYAN, -- 2172
						0.25 -- 2172
					) -- 2172
					dot( -- 2173
						d, -- 2173
						cx, -- 2173
						cy + 12, -- 2173
						6.5, -- 2173
						CYAN -- 2173
					) -- 2173
					dot( -- 2174
						d, -- 2174
						cx - 2, -- 2174
						cy + 14, -- 2174
						2, -- 2174
						Palette.moonWhite, -- 2174
						0.9 -- 2174
					) -- 2174
				end -- 2174
			elseif c.kind == "mechanism" then -- 2174
				local rot = time * 1.2 -- 2177
				circle( -- 2178
					d, -- 2178
					cx, -- 2178
					cy + 10, -- 2178
					7, -- 2178
					GOLD, -- 2178
					12, -- 2178
					0.95 -- 2178
				) -- 2178
				do -- 2178
					local i = 0 -- 2179
					while i < 6 do -- 2179
						local a = rot + i / 6 * math.pi * 2 -- 2180
						seg( -- 2181
							d, -- 2181
							cx + math.cos(a) * 7, -- 2181
							cy + 10 + math.sin(a) * 7, -- 2181
							cx + math.cos(a) * 10.5, -- 2181
							cy + 10 + math.sin(a) * 10.5, -- 2181
							2.2, -- 2181
							GOLD, -- 2181
							0.95 -- 2181
						) -- 2181
						i = i + 1 -- 2179
					end -- 2179
				end -- 2179
				dot( -- 2183
					d, -- 2183
					cx, -- 2183
					cy + 10, -- 2183
					2.2, -- 2183
					GOLD, -- 2183
					0.9 -- 2183
				) -- 2183
			elseif c.kind == "token" then -- 2183
				local tk = self.tokenSprites[c.id] -- 2186
				if tk ~= nil then -- 2186
					tk.visible = true -- 2188
					tk.position = Vec2(cx, cy + 18) -- 2189
				else -- 2189
					d:drawPolygon( -- 2191
						{ -- 2192
							Vec2(cx - 7, cy + 16), -- 2192
							Vec2(cx + 7, cy + 16), -- 2192
							Vec2(cx + 7, cy + 4), -- 2192
							Vec2(cx - 7, cy + 4) -- 2192
						}, -- 2192
						col(ink(112, 84, 56, 225)), -- 2193
						0, -- 2194
						Color(0, 0, 0, 0) -- 2195
					) -- 2195
					circle( -- 2197
						d, -- 2197
						cx, -- 2197
						cy + 20, -- 2197
						3.2, -- 2197
						Palette.inkDark, -- 2197
						8, -- 2197
						0.9 -- 2197
					) -- 2197
					seg( -- 2198
						d, -- 2198
						cx - 3.5, -- 2198
						cy + 12, -- 2198
						cx + 3.5, -- 2198
						cy + 12, -- 2198
						1, -- 2198
						PAPER_DIM, -- 2198
						0.9 -- 2198
					) -- 2198
				end -- 2198
			else -- 2198
				local dw = self.dewSprites[c.id] -- 2202
				if dw ~= nil then -- 2202
					dw.visible = true -- 2204
					dw.position = Vec2(cx, cy + 18) -- 2205
				else -- 2205
					dot( -- 2207
						d, -- 2207
						cx, -- 2207
						cy + 8, -- 2207
						5.5, -- 2207
						CYAN, -- 2207
						0.75 -- 2207
					) -- 2207
					d:drawPolygon( -- 2208
						{ -- 2209
							Vec2(cx, cy + 18), -- 2209
							Vec2(cx + 3.4, cy + 10), -- 2209
							Vec2(cx - 3.4, cy + 10) -- 2209
						}, -- 2209
						col(CYAN, 0.75), -- 2210
						0, -- 2211
						Color(0, 0, 0, 0) -- 2212
					) -- 2212
					dot( -- 2214
						d, -- 2214
						cx - 1.6, -- 2214
						cy + 7.5, -- 2214
						1.6, -- 2214
						Palette.moonWhite, -- 2214
						0.9 -- 2214
					) -- 2214
				end -- 2214
			end -- 2214
		end -- 2214
		::__continue377:: -- 2214
	end -- 2214
end -- 2100
function WorldRenderer.prototype.drawDecor(self, d, time) -- 2221
	if self.activeFloor == 4 and self:inView(500, FLOOR_TOPS[5], 2100, FLOOR_TOPS[5] + 160) then -- 2221
		self:drawGear( -- 2223
			d, -- 2223
			800, -- 2223
			FLOOR_TOPS[5] + 80, -- 2223
			46, -- 2223
			18, -- 2223
			time * 0.35 -- 2223
		) -- 2223
		self:drawGear( -- 2224
			d, -- 2224
			1800, -- 2224
			FLOOR_TOPS[5] + 80, -- 2224
			34, -- 2224
			14, -- 2224
			-time * 0.5 + 0.4 -- 2224
		) -- 2224
	end -- 2224
	if self.activeFloor == 6 and self:inView(900, FLOOR_TOPS[7] - 90, 1500, FLOOR_TOPS[7] + 310) then -- 2224
		local cx = 1200 -- 2227
		local cy = FLOOR_TOPS[7] + 180 -- 2228
		circle( -- 2229
			d, -- 2229
			cx, -- 2229
			cy, -- 2229
			34, -- 2229
			GOLD, -- 2229
			24, -- 2229
			0.5 -- 2229
		) -- 2229
		circle( -- 2230
			d, -- 2230
			cx, -- 2230
			cy, -- 2230
			22, -- 2230
			GOLD, -- 2230
			20, -- 2230
			0.65 -- 2230
		) -- 2230
		arc( -- 2231
			d, -- 2231
			cx, -- 2231
			cy, -- 2231
			28, -- 2231
			time * 0.4, -- 2231
			time * 0.4 + math.pi * 1.4, -- 2231
			14, -- 2231
			2, -- 2231
			CYAN, -- 2231
			0.7 -- 2231
		) -- 2231
		do -- 2231
			local i = 0 -- 2232
			while i < 12 do -- 2232
				local a = i / 12 * math.pi * 2 + time * 0.05 -- 2233
				seg( -- 2234
					d, -- 2234
					cx + math.cos(a) * 34, -- 2234
					cy + math.sin(a) * 34, -- 2234
					cx + math.cos(a) * 39, -- 2234
					cy + math.sin(a) * 39, -- 2234
					1.6, -- 2234
					GOLD, -- 2234
					0.6 -- 2234
				) -- 2234
				i = i + 1 -- 2232
			end -- 2232
		end -- 2232
		dot( -- 2236
			d, -- 2236
			cx, -- 2236
			cy, -- 2236
			3.4, -- 2236
			CYAN, -- 2236
			0.9 -- 2236
		) -- 2236
	end -- 2236
	if self.activeFloor == 6 and self:inView(1900, FLOOR_TOPS[7] - 40, 2300, FLOOR_TOPS[7] + 260) then -- 2236
		local cx = 2100 -- 2239
		local cy = FLOOR_TOPS[7] + 100 -- 2240
		circle( -- 2241
			d, -- 2241
			cx, -- 2241
			cy, -- 2241
			46, -- 2241
			GOLD, -- 2241
			28, -- 2241
			0.55 -- 2241
		) -- 2241
		circle( -- 2242
			d, -- 2242
			cx, -- 2242
			cy, -- 2242
			34, -- 2242
			GOLD, -- 2242
			24, -- 2242
			0.7 -- 2242
		) -- 2242
		circle( -- 2243
			d, -- 2243
			cx, -- 2243
			cy, -- 2243
			22, -- 2243
			GOLD, -- 2243
			20, -- 2243
			0.85 -- 2243
		) -- 2243
		dot( -- 2244
			d, -- 2244
			cx, -- 2244
			cy, -- 2244
			8, -- 2244
			CYAN, -- 2244
			0.85 + 0.15 * math.sin(time * 2.4) -- 2244
		) -- 2244
		local oa = time * 1.1 -- 2245
		local ox = cx + math.cos(oa) * 22 -- 2246
		local oy = cy + math.sin(oa) * 22 -- 2247
		dot( -- 2248
			d, -- 2248
			ox, -- 2248
			oy, -- 2248
			8, -- 2248
			CYAN, -- 2248
			0.3 -- 2248
		) -- 2248
		dot( -- 2249
			d, -- 2249
			ox, -- 2249
			oy, -- 2249
			4, -- 2249
			Palette.moonWhite, -- 2249
			0.95 -- 2249
		) -- 2249
	end -- 2249
end -- 2221
function WorldRenderer.prototype.drawGear(self, d, cx, cy, r, teeth, rot) -- 2253
	local c = ink(70, 62, 50, 200) -- 2254
	circle( -- 2255
		d, -- 2255
		cx, -- 2255
		cy, -- 2255
		r * 0.62, -- 2255
		c, -- 2255
		20, -- 2255
		0.9 -- 2255
	) -- 2255
	do -- 2255
		local i = 0 -- 2256
		while i < teeth do -- 2256
			local a = rot + i / teeth * math.pi * 2 -- 2257
			seg( -- 2258
				d, -- 2258
				cx + math.cos(a) * r * 0.62, -- 2258
				cy + math.sin(a) * r * 0.62, -- 2258
				cx + math.cos(a) * r, -- 2258
				cy + math.sin(a) * r, -- 2258
				3.4, -- 2258
				c, -- 2258
				0.95 -- 2258
			) -- 2258
			i = i + 1 -- 2256
		end -- 2256
	end -- 2256
	do -- 2256
		local i = 0 -- 2260
		while i < 4 do -- 2260
			local a = rot + i / 4 * math.pi * 2 -- 2261
			seg( -- 2262
				d, -- 2262
				cx, -- 2262
				cy, -- 2262
				cx + math.cos(a) * r * 0.5, -- 2262
				cy + math.sin(a) * r * 0.5, -- 2262
				2.2, -- 2262
				c, -- 2262
				0.6 -- 2262
			) -- 2262
			i = i + 1 -- 2260
		end -- 2260
	end -- 2260
	dot( -- 2264
		d, -- 2264
		cx, -- 2264
		cy, -- 2264
		3.6, -- 2264
		c, -- 2264
		0.95 -- 2264
	) -- 2264
end -- 2253
function WorldRenderer.prototype.syncBossWaveSprites(self, enemies) -- 2269
	if not self.bossWaveChecked then -- 2269
		self.bossWaveChecked = true -- 2271
		self.bossWaveTex = self:loadTex("assets/effects/slash_blue.png") -- 2272
	end -- 2272
	local tex = self.bossWaveTex -- 2274
	if tex == nil then -- 2274
		return false -- 2276
	end -- 2276
	local waves = enemies.waves -- 2278
	local frames = math.max( -- 2279
		1, -- 2279
		math.floor(tex.width / 64) -- 2279
	) -- 2279
	while #self.bossWaveSprites > #waves do -- 2279
		local sp = table.remove(self.bossWaveSprites) -- 2281
		if sp ~= nil then -- 2281
			sp:removeFromParent() -- 2283
		end -- 2283
	end -- 2283
	while #self.bossWaveSprites < #waves do -- 2283
		local created = Sprite( -- 2287
			tex, -- 2287
			Rect( -- 2287
				math.floor(frames / 2) * 64, -- 2287
				0, -- 2287
				64, -- 2287
				64 -- 2287
			) -- 2287
		) -- 2287
		if created == nil then -- 2287
			return false -- 2289
		end -- 2289
		created.filter = "Point" -- 2291
		created:addTo(self.waveSpriteRoot) -- 2292
		local ____self_bossWaveSprites_11 = self.bossWaveSprites -- 2292
		____self_bossWaveSprites_11[#____self_bossWaveSprites_11 + 1] = created -- 2293
	end -- 2293
	local k = 92 / 64 -- 2296
	do -- 2296
		local i = 0 -- 2297
		while i < #self.bossWaveSprites do -- 2297
			local sp = self.bossWaveSprites[i + 1] -- 2298
			local wv = waves[i + 1] -- 2299
			sp.position = Vec2(wv.x, wv.y + 20) -- 2300
			sp.scaleX = (wv.dir >= 0 and 1 or -1) * k -- 2301
			sp.scaleY = k -- 2302
			sp.opacity = wv.life < 0.4 and math.floor(255 * (wv.life / 0.4)) or 255 -- 2303
			i = i + 1 -- 2297
		end -- 2297
	end -- 2297
	return true -- 2305
end -- 2269
function WorldRenderer.prototype.drawArrow(self, d, x, y, vx, vy) -- 2309
	local lenRaw = math.sqrt(vx * vx + vy * vy) -- 2310
	local len = lenRaw > 0.0001 and lenRaw or 1 -- 2311
	local ux = vx / len -- 2312
	local uy = vy / len -- 2313
	seg( -- 2314
		d, -- 2314
		x - ux * 12, -- 2314
		y - uy * 12, -- 2314
		x + ux * 6, -- 2314
		y + uy * 6, -- 2314
		2.2, -- 2314
		ink(196, 188, 168, 235) -- 2314
	) -- 2314
	dot( -- 2315
		d, -- 2315
		x + ux * 7, -- 2315
		y + uy * 7, -- 2315
		2.4, -- 2315
		ink(244, 240, 226, 255) -- 2315
	) -- 2315
end -- 2309
function WorldRenderer.prototype.drawChars(self, time, state, player, enemies, mech, dt) -- 2319
	local d = self.charDraw -- 2320
	d:clear() -- 2321
	self.ninja:beginFrame(dt) -- 2322
	for ____, p in ipairs(enemies.pots) do -- 2323
		do -- 2323
			if not p.alive then -- 2323
				goto __continue428 -- 2325
			end -- 2325
			if self:inView(p.x - 20, p.y - 20, p.x + 20, p.y + 20) then -- 2325
				drawPot(d, p.x, p.y, time) -- 2328
			end -- 2328
		end -- 2328
		::__continue428:: -- 2328
	end -- 2328
	if not self:syncBossWaveSprites(enemies) then -- 2328
		for ____, wv in ipairs(enemies.waves) do -- 2333
			if self:inView(wv.x - 40, wv.y - 20, wv.x + 40, wv.y + 50) then -- 2333
				drawWave( -- 2335
					d, -- 2335
					wv.x, -- 2335
					wv.y, -- 2335
					wv.dir, -- 2335
					time -- 2335
				) -- 2335
			end -- 2335
		end -- 2335
	end -- 2335
	for ____, ar in ipairs(enemies.arrows) do -- 2340
		do -- 2340
			if not ar.alive then -- 2340
				goto __continue436 -- 2342
			end -- 2342
			if self:inView(ar.x - 30, ar.y - 30, ar.x + 30, ar.y + 30) then -- 2342
				self:drawArrow( -- 2345
					d, -- 2345
					ar.x, -- 2345
					ar.y, -- 2345
					ar.vx, -- 2345
					ar.vy -- 2345
				) -- 2345
			end -- 2345
		end -- 2345
		::__continue436:: -- 2345
	end -- 2345
	for ____, e in ipairs(enemies.enemies) do -- 2348
		do -- 2348
			if e.dead and e.deathTimer <= 0 then -- 2348
				goto __continue440 -- 2350
			end -- 2350
			if self:floorOfY(e.body.y) ~= self.activeFloor then -- 2350
				goto __continue440 -- 2354
			end -- 2354
			if self:inView(e.body.x - 60, e.body.y - e.body.h / 2, e.body.x + 60, e.body.y + e.body.h / 2) then -- 2354
				if not self.ninja:drawEnemy(e) then -- 2354
					drawEnemy(d, e, e.animTime) -- 2358
				end -- 2358
			end -- 2358
		end -- 2358
		::__continue440:: -- 2358
	end -- 2358
	self.ninja:endFrame() -- 2362
	do -- 2362
		local si = 0 -- 2363
		while si < #mech.stones do -- 2363
			do -- 2363
				local s = mech.stones[si + 1] -- 2364
				local inR = self:inView(s.x - 40, s.y - 40, s.x + 40, s.y + 40) -- 2365
				if si < #self.stoneSprites then -- 2365
					local sp = self.stoneSprites[si + 1] -- 2368
					sp.visible = inR -- 2369
					if inR then -- 2369
						sp.position = Vec2(s.x, s.y) -- 2371
					end -- 2371
					goto __continue447 -- 2373
				end -- 2373
				if not inR then -- 2373
					goto __continue447 -- 2376
				end -- 2376
				d:drawPolygon( -- 2378
					{ -- 2379
						Vec2(s.x - s.w / 2, s.y + s.h / 2), -- 2380
						Vec2(s.x + s.w / 2, s.y + s.h / 2), -- 2381
						Vec2(s.x + s.w / 2 - 2, s.y - s.h / 2), -- 2382
						Vec2(s.x - s.w / 2 + 2, s.y - s.h / 2) -- 2383
					}, -- 2383
					col(ink(58, 54, 48, 235)), -- 2385
					0, -- 2386
					Color(0, 0, 0, 0) -- 2387
				) -- 2387
				seg( -- 2389
					d, -- 2389
					s.x - s.w / 2 + 6, -- 2389
					s.y + s.h / 2 - 6, -- 2389
					s.x, -- 2389
					s.y - s.h / 2 + 8, -- 2389
					1.4, -- 2389
					ink(40, 37, 33, 120) -- 2389
				) -- 2389
				dot( -- 2390
					d, -- 2390
					s.x - s.w / 4, -- 2390
					s.y + s.h / 4, -- 2390
					2.4, -- 2390
					PAPER_DIM, -- 2390
					0.8 -- 2390
				) -- 2390
			end -- 2390
			::__continue447:: -- 2390
			si = si + 1 -- 2363
		end -- 2363
	end -- 2363
	do -- 2363
		local si = #mech.stones -- 2393
		while si < #self.stoneSprites do -- 2393
			self.stoneSprites[si + 1].visible = false -- 2394
			si = si + 1 -- 2393
		end -- 2393
	end -- 2393
	if self.shenYan ~= nil then -- 2393
		local sy = self.shenYan -- 2397
		if self:floorOfY(sy.y) == self.activeFloor and self:inView(sy.x - 60, sy.y - 20, sy.x + 60, sy.y + 100) then -- 2397
			drawShenYan( -- 2399
				d, -- 2399
				sy.x, -- 2399
				sy.y, -- 2399
				sy.facing, -- 2399
				time, -- 2399
				sy.hostile -- 2399
			) -- 2399
		end -- 2399
	end -- 2399
	if self.observer ~= nil then -- 2399
		local ob = self.observer -- 2403
		if self:floorOfY(ob.y) == self.activeFloor and self:inView(ob.x - 50, ob.y, ob.x + 50, ob.y + 130) then -- 2403
			drawObserver(d, ob.x, ob.y, time) -- 2405
		end -- 2405
	end -- 2405
	local px = player.body.x -- 2408
	local py = player.body.y - player.body.h / 2 -- 2409
	local pose = self:heroPose(player) -- 2410
	local visible = self:inView(px - 80, py - 20, px + 80, py + 120) -- 2412
	local animT = pose == "ladder" and player.climbT or player.animTime -- 2414
	if self.heroTexOk then -- 2414
		self:updateHeroSprite( -- 2416
			px, -- 2416
			py, -- 2416
			player.facing, -- 2416
			pose, -- 2416
			animT, -- 2416
			state.phaseIndex, -- 2416
			visible, -- 2416
			dt -- 2416
		) -- 2416
	elseif visible then -- 2416
		drawHero( -- 2418
			d, -- 2418
			px, -- 2418
			py, -- 2418
			player.facing, -- 2418
			pose, -- 2418
			animT, -- 2418
			state.phaseIndex -- 2418
		) -- 2418
	end -- 2418
end -- 2319
function WorldRenderer.prototype.updateHeroSprite(self, x, y, facing, pose, t, phaseIndex, visible, dt) -- 2423
	local sp = self.heroSprite -- 2433
	local f = self.heroFxDraw -- 2434
	f:clear() -- 2435
	self:updateGhosts(dt) -- 2436
	if not visible then -- 2436
		if sp ~= nil then -- 2436
			sp.visible = false -- 2439
		end -- 2439
		self.heroFrames:hideAll() -- 2441
		return -- 2442
	end -- 2442
	local fr = self.heroFrames:pick(pose, t) -- 2445
	if fr ~= nil then -- 2445
		if sp ~= nil then -- 2445
			sp.visible = false -- 2448
		end -- 2448
		self.heroFrames:hideAll() -- 2450
		fr.sp.visible = true -- 2451
		local bobF = 0 -- 2452
		if pose == "jump" then -- 2452
			bobF = 2 -- 2454
		elseif pose == "fall" then -- 2454
			bobF = -2 -- 2456
		end -- 2456
		fr.sp.position = Vec2(x, y + bobF) -- 2458
		fr.sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT and 1 or -1) -- 2459
		fr.sp.scaleY = fr.scale -- 2460
		if self.ghostCd <= 0 and (pose == "dash" or pose == "jump" or pose == "fall") then -- 2460
			self:spawnGhost(fr, x, y + bobF, facing) -- 2463
			self.ghostCd = GHOST_INTERVAL -- 2464
		end -- 2464
		self:drawHeroFx( -- 2466
			f, -- 2466
			x, -- 2466
			y, -- 2466
			facing, -- 2466
			pose, -- 2466
			t, -- 2466
			phaseIndex, -- 2466
			0 -- 2466
		) -- 2466
		return -- 2467
	end -- 2467
	self.heroFrames:hideAll() -- 2469
	if sp == nil then -- 2469
		self:drawHeroFx( -- 2471
			f, -- 2471
			x, -- 2471
			y, -- 2471
			facing, -- 2471
			pose, -- 2471
			t, -- 2471
			phaseIndex, -- 2471
			0 -- 2471
		) -- 2471
		return -- 2472
	end -- 2472
	sp.visible = true -- 2474
	local bob = 0 -- 2475
	if pose == "idle" then -- 2475
		bob = math.sin(t * 2) * 1.6 -- 2477
	elseif pose == "run" then -- 2477
		bob = -math.abs(math.sin(t * 12)) * 2.2 -- 2479
	elseif pose == "jump" then -- 2479
		bob = 2.5 -- 2481
	elseif pose == "fall" then -- 2481
		bob = -1.5 -- 2483
	end -- 2483
	sp.position = Vec2(x, y + bob) -- 2485
	sp.scaleX = self.heroScale * facing -- 2486
	sp.scaleY = self.heroScale -- 2487
	self:drawHeroFx( -- 2488
		f, -- 2488
		x, -- 2488
		y, -- 2488
		facing, -- 2488
		pose, -- 2488
		t, -- 2488
		phaseIndex, -- 2488
		bob -- 2488
	) -- 2488
end -- 2423
function WorldRenderer.prototype.drawHeroFx(self, f, x, y, _facing, pose, _t, _phaseIndex, _bob) -- 2494
	if pose == "hurt" then -- 2494
		dot( -- 2507
			f, -- 2507
			x, -- 2507
			y + 46, -- 2507
			26, -- 2507
			ink(220, 70, 60, 160), -- 2507
			0.5 -- 2507
		) -- 2507
	end -- 2507
end -- 2494
function WorldRenderer.prototype.updateGhosts(self, dt) -- 2512
	if self.ghostCd > 0 then -- 2512
		self.ghostCd = self.ghostCd - dt -- 2514
	end -- 2514
	local i = #self.ghosts - 1 -- 2516
	while i >= 0 do -- 2516
		local g = self.ghosts[i + 1] -- 2518
		g.t = g.t + dt -- 2519
		if g.t >= g.dur then -- 2519
			g.sp:removeFromParent() -- 2521
			__TS__ArraySplice(self.ghosts, i, 1) -- 2522
		else -- 2522
			g.sp.opacity = GHOST_ALPHA * (1 - g.t / g.dur) -- 2524
		end -- 2524
		i = i - 1 -- 2526
	end -- 2526
end -- 2512
function WorldRenderer.prototype.spawnGhost(self, fr, x, y, facing) -- 2531
	if #self.ghosts >= GHOST_MAX then -- 2531
		return -- 2533
	end -- 2533
	local tex = fr.sp.texture -- 2535
	if tex == nil then -- 2535
		return -- 2537
	end -- 2537
	local sp = Sprite(tex) -- 2539
	if sp == nil then -- 2539
		return -- 2541
	end -- 2541
	sp.anchor = Vec2(0.5, 0) -- 2543
	sp.position = Vec2(x - facing * GHOST_OFFSET, y) -- 2544
	sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT and 1 or -1) -- 2545
	sp.scaleY = fr.scale -- 2546
	sp.color = Color(GHOST_TINT_R, GHOST_TINT_G, GHOST_TINT_B, 255) -- 2547
	sp.opacity = GHOST_ALPHA -- 2548
	sp:addTo(self.ghostRoot) -- 2549
	local ____self_ghosts_12 = self.ghosts -- 2549
	____self_ghosts_12[#____self_ghosts_12 + 1] = {sp = sp, t = 0, dur = GHOST_DUR} -- 2550
end -- 2531
function WorldRenderer.prototype.heroPose(self, p) -- 2553
	if p.onLadder then -- 2553
		return "ladder" -- 2555
	end -- 2555
	local a = p.anim -- 2557
	if a == "wallslide" then -- 2557
		return "cling" -- 2559
	end -- 2559
	if a == "climb" then -- 2559
		return "ladder" -- 2562
	end -- 2562
	if a == "attack" then -- 2562
		local idx = p.attackIndex -- 2565
		return idx <= 0 and "attack1" or (idx == 1 and "attack2" or (idx == 2 and "attack3" or "heavy")) -- 2566
	end -- 2566
	if a == "land" then -- 2566
		return "idle" -- 2569
	end -- 2569
	return a -- 2571
end -- 2553
return ____exports -- 2553