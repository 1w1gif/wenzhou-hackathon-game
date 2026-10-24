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
____exports.CAM_ZOOM = 1 -- 130
local GOLD = ink(212, 168, 84, 255) -- 131
local CYAN = ink(108, 156, 148, 255) -- 132
local PAPER_DIM = ink(219, 208, 184, 120) -- 133
local TILE = 64 -- 166
local TILE_SETS = { -- 167
	"autumn", -- 167
	"autumn", -- 167
	"skyruins", -- 167
	"skyruins", -- 167
	"skyruins", -- 167
	"skyruins", -- 167
	"skyruins" -- 167
} -- 167
local FLOOR_TOPS = { -- 171
	220, -- 171
	1500, -- 171
	2800, -- 171
	4100, -- 171
	5400, -- 171
	6700, -- 171
	8000 -- 171
} -- 171
local BG_AUTUMN = {{path = "assets/bg/autumn_layer0.png", f = 0.12, baseUp = 0}, {path = "assets/bg/autumn_layer1.png", f = 0.26, baseUp = 0}} -- 181
local BG_SKYRUINS = {{path = "assets/bg/skyruins_layer0.png", f = 0.12, baseUp = 0}, {path = "assets/bg/skyruins_layer1.png", f = 0.26, baseUp = 0}} -- 185
local BG_RIVERSIDE = { -- 190
	{path = "assets/bg/river_sky.png", f = 0.06, baseUp = 0}, -- 191
	{path = "assets/bg/river_clouds1.png", f = 0.12, baseUp = 0}, -- 192
	{path = "assets/bg/river_clouds2.png", f = 0.18, baseUp = 0}, -- 193
	{path = "assets/bg/river_rocks.png", f = 0.28, baseUp = 0}, -- 194
	{path = "assets/bg/river_ground.png", f = 0.36, baseUp = 0} -- 195
} -- 195
local BG_TOWERSIDE = { -- 198
	{path = "assets/bg/dusk/sky.png", f = 0.05, baseUp = 0}, -- 199
	{path = "assets/bg/dusk/far_clouds.png", f = 0.1, baseUp = 0}, -- 200
	{path = "assets/bg/dusk/far_mountains.png", f = 0.16, baseUp = 0}, -- 201
	{path = "assets/bg/dusk/mountains.png", f = 0.24, baseUp = 0}, -- 202
	{path = "assets/bg/dusk/near_clouds.png", f = 0.3, baseUp = 0}, -- 203
	{path = "assets/bg/dusk/trees.png", f = 0.38, baseUp = 0} -- 204
} -- 204
local BG_MOONNIGHT = {{path = "assets/bg/moon_far.png", f = 0.08, baseUp = 0}, {path = "assets/bg/moon_mid.png", f = 0.18, baseUp = 0}, {path = "assets/bg/moon_big.png", f = 0.3, baseUp = 0}} -- 207
local BG_LAYERS = { -- 212
	BG_AUTUMN, -- 213
	BG_RIVERSIDE, -- 214
	BG_SKYRUINS, -- 215
	BG_TOWERSIDE, -- 216
	{}, -- 217
	BG_SKYRUINS, -- 218
	BG_MOONNIGHT -- 219
} -- 219
local function styleAllowsDecor(style, path) -- 227
	if style == "skyruins" then -- 227
		return path == "assets/tiles/skyruins_magicstone.png" or path == "assets/tiles/skyruins_portal.png" -- 229
	end -- 229
	return false -- 231
end -- 227
local function waveY(wx, time, i) -- 234
	return math.sin(wx * 0.018 + time * 1.7 + i * 2.1) * 2.6 + math.sin(wx * 0.006 - time * 0.8 + i) * 1.6 -- 235
end -- 234
____exports.WorldRenderer = __TS__Class() -- 238
local WorldRenderer = ____exports.WorldRenderer -- 238
WorldRenderer.name = "WorldRenderer" -- 238
function WorldRenderer.prototype.____constructor(self, parent, data) -- 317
	self.bgRecs = {} -- 254
	self.activeFloor = 0 -- 258
	self.sceneFloorHolders = {} -- 259
	self.decorFloorHolders = {} -- 260
	self.propSpriteFloorHolders = {} -- 261
	self.bgBands = {} -- 262
	self.tileGroups = {} -- 263
	self.promptW = 0 -- 269
	self.promptH = 0 -- 270
	self.promptText = "" -- 271
	self.promptX = 0 -- 272
	self.promptY = 0 -- 273
	self.promptShown = false -- 275
	self.promptPopT = 0 -- 276
	self.promptHideT = 0 -- 277
	self.promptAnimT = 0 -- 278
	self.promptRelayoutT = 0 -- 279
	self.heroTexOk = false -- 284
	self.heroScale = 0.065 -- 285
	self.ghosts = {} -- 289
	self.ghostCd = 0 -- 290
	self.pixelBgOk = false -- 294
	self.activeBand = -1 -- 295
	self.sceneBand = 0 -- 296
	self.portalNodes = {} -- 297
	self.stoneSprites = {} -- 302
	self.bossWaveSprites = {} -- 305
	self.bossWaveChecked = false -- 307
	self.lampStoneSprites = {} -- 308
	self.moonStoneSprites = {} -- 309
	self.dewSprites = {} -- 310
	self.tokenSprites = {} -- 311
	self.flagSets = {} -- 312
	self.texCache = {} -- 313
	self.puzzleBuilt = false -- 835
	self.barrelT = 0 -- 836
	self.barrelLeft = false -- 837
	self.data = data -- 318
	self.parent = parent -- 319
	self.camX = 0 -- 320
	self.camY = 0 -- 321
	self.vw = View.size.width -- 322
	self.vh = View.size.height -- 323
	self.shenYan = nil -- 324
	self.observer = nil -- 325
	self.stars = {} -- 326
	do -- 326
		local i = 0 -- 327
		while i < 42 do -- 327
			local ____self_stars_0 = self.stars -- 327
			____self_stars_0[#____self_stars_0 + 1] = {x = i * 617 % 2600, y = 60 + i * 149 % 330, s = 0.5 + i * 37 % 10 / 14} -- 328
			i = i + 1 -- 327
		end -- 327
	end -- 327
	self.gateParts = {} -- 334
	local byId = {} -- 335
	for ____, p in ipairs(data.platforms) do -- 336
		if p.kind == "gate" and p.gateId ~= nil then -- 336
			local list = byId[p.gateId] -- 338
			if list == nil then -- 338
				byId[p.gateId] = {p} -- 340
			else -- 340
				list[#list + 1] = p -- 342
			end -- 342
		end -- 342
	end -- 342
	for ____, g in ipairs(data.gates) do -- 346
		local ____self_gateParts_1 = self.gateParts -- 346
		____self_gateParts_1[#____self_gateParts_1 + 1] = {gid = g.id, rects = byId[g.id] == nil and ({}) or byId[g.id]} -- 347
	end -- 347
	self.bgSpriteRoot = Node() -- 349
	self.bgSpriteRoot:addTo(parent) -- 350
	self.bgDraw = DrawNode() -- 351
	self.bgDraw:addTo(parent) -- 352
	self.worldRoot = Node() -- 353
	self.worldRoot:addTo(parent) -- 354
	self.platformDraw = DrawNode() -- 355
	self.platformDraw:addTo(self.worldRoot) -- 356
	self.propDraw = DrawNode() -- 357
	self.propDraw:addTo(self.worldRoot) -- 358
	self.scenePropsRoot = Node() -- 360
	self.scenePropsRoot:addTo(self.worldRoot) -- 361
	self.propSpriteRoot = Node() -- 363
	self.propSpriteRoot:addTo(self.worldRoot) -- 364
	self.portalLayer = Node() -- 366
	self.portalLayer:addTo(self.worldRoot) -- 367
	self.waveSpriteRoot = Node() -- 368
	self.waveSpriteRoot:addTo(self.worldRoot) -- 369
	self.charDraw = DrawNode() -- 370
	self.charDraw:addTo(self.worldRoot) -- 371
	self.ninjaRoot = Node() -- 373
	self.ninjaRoot:addTo(self.worldRoot) -- 374
	self.ninja = __TS__New(NinjaLayer, self.ninjaRoot) -- 375
	local heroTex = self:loadTex("assets/characters/衍月.png") -- 377
	if heroTex ~= nil then -- 377
		local sp = Sprite(heroTex) -- 379
		sp.anchor = Vec2(0.5, 0) -- 380
		self.heroScale = 90 / heroTex.height -- 381
		sp.scaleX = self.heroScale -- 382
		sp.scaleY = self.heroScale -- 383
		sp:addTo(self.worldRoot) -- 384
		self.heroSprite = sp -- 385
		self.heroTexOk = true -- 386
	end -- 386
	self.ghostRoot = Node() -- 389
	self.ghostRoot:addTo(self.worldRoot) -- 390
	self.heroFrames = __TS__New(HeroFrameSet, self.worldRoot) -- 391
	self.heroFxDraw = DrawNode() -- 392
	self.heroFxDraw:addTo(self.worldRoot) -- 393
	self.decorNode = Node() -- 394
	self.decorNode:addTo(self.worldRoot) -- 395
	self.lightDecor = __TS__New(LightDecor, self.decorNode) -- 396
	self.promptNode = Node() -- 398
	self.promptNode:addTo(self.worldRoot) -- 399
	self.promptNode.visible = false -- 400
	self.promptDraw = DrawNode() -- 401
	self.promptDraw:addTo(self.promptNode) -- 402
	self.promptDraw.visible = true -- 403
	self.promptNode.passOpacity = true -- 404
	self.promptNode:schedule(function(dt) -- 406
		self:updatePromptAnim(dt) -- 407
		return false -- 408
	end) -- 406
	self:buildPixelBackgrounds() -- 410
	self:buildPixelTerrain() -- 411
	self:buildPixelDecor() -- 412
	self:buildSceneProps() -- 413
	self:buildPortals() -- 414
	self:buildLightDecor() -- 415
	self:buildPropSprites() -- 416
end -- 317
function WorldRenderer.prototype.setPrompt(self, x, y, text) -- 421
	if text == nil then -- 421
		if self.promptShown then -- 421
			self.promptShown = false -- 424
			self.promptHideT = 0.1 -- 425
		end -- 425
		return -- 427
	end -- 427
	if self.promptShown and text == self.promptText and x == self.promptX and y == self.promptY then -- 427
		return -- 430
	end -- 430
	local fresh = not self.promptShown -- 432
	self.promptText = text -- 433
	self.promptX = x -- 434
	self.promptY = y -- 435
	if fresh then -- 435
		self.promptShown = true -- 437
		self.promptPopT = 0.15 -- 438
		self.promptHideT = 0 -- 439
		self.promptAnimT = 0 -- 440
		self.promptNode.visible = true -- 441
		self.promptNode.opacity = 1 -- 442
		self.promptNode.scaleX = 0.9 -- 443
		self.promptNode.scaleY = 0.9 -- 444
	end -- 444
	self:redrawPrompt() -- 446
	self:applyPromptPosition(0) -- 447
	self.promptRelayoutT = 0.12 -- 448
end -- 421
function WorldRenderer.prototype.applyPromptPosition(self, bob) -- 452
	local w = self.promptW -- 453
	local h = self.promptH -- 454
	local px = self.promptX -- 455
	local py = self.promptY + h / 2 + 14 -- 456
	local minX = self.camX - self.vw / (2 * ____exports.CAM_ZOOM) + w / 2 + 8 -- 457
	local maxX = self.camX + self.vw / (2 * ____exports.CAM_ZOOM) - w / 2 - 8 -- 458
	local minY = self.camY - self.vh / (2 * ____exports.CAM_ZOOM) + h / 2 + 8 -- 459
	local maxY = self.camY + self.vh / (2 * ____exports.CAM_ZOOM) - h / 2 - 8 -- 460
	if maxX > minX then -- 460
		px = math.max( -- 462
			minX, -- 462
			math.min(maxX, px) -- 462
		) -- 462
	end -- 462
	if maxY > minY then -- 462
		py = math.max( -- 465
			minY, -- 465
			math.min(maxY, py) -- 465
		) -- 465
	end -- 465
	self.promptNode.position = Vec2(px, py + bob) -- 467
end -- 452
function WorldRenderer.prototype.updatePromptAnim(self, dt) -- 471
	if not self.promptNode.visible then -- 471
		return -- 473
	end -- 473
	if self.promptShown then -- 473
		if self.promptRelayoutT > 0 then -- 473
			self.promptRelayoutT = self.promptRelayoutT - dt -- 477
			self:redrawPrompt() -- 478
		end -- 478
		self.promptAnimT = self.promptAnimT + dt -- 480
		if self.promptPopT > 0 then -- 480
			self.promptPopT = math.max(0, self.promptPopT - dt) -- 482
			local t = 1 - self.promptPopT / 0.15 -- 483
			local e = 1 - (1 - t) * (1 - t) -- 484
			local s = 0.9 + 0.1 * e -- 485
			self.promptNode.scaleX = s -- 486
			self.promptNode.scaleY = s -- 487
		else -- 487
			self.promptNode.scaleX = 1 -- 489
			self.promptNode.scaleY = 1 -- 490
		end -- 490
		local bob = 3 * math.sin(math.pi * self.promptAnimT) -- 492
		self:applyPromptPosition(bob) -- 493
		self.promptNode.opacity = 1 -- 494
	else -- 494
		self.promptHideT = self.promptHideT - dt -- 496
		if self.promptHideT <= 0 then -- 496
			self.promptHideT = 0 -- 498
			self.promptNode.visible = false -- 499
			self.promptNode.opacity = 1 -- 500
		else -- 500
			self.promptNode.opacity = self.promptHideT / 0.1 -- 502
		end -- 502
	end -- 502
end -- 471
function WorldRenderer.prototype.makePromptLabel(self, size) -- 507
	local lb = Label("assets/font/DialogFont.ttf", size) -- 508
	if lb ~= nil then -- 508
		return lb -- 510
	end -- 510
	return Label("sarasa-mono-sc-regular", size) -- 512
end -- 507
function WorldRenderer.prototype.redrawPrompt(self) -- 515
	local draw = self.promptDraw -- 517
	draw:clear() -- 518
	draw.visible = false -- 519
	if self.promptLbMain == nil then -- 519
		self.promptLbMain = self:makePromptLabel(21) -- 521
		if self.promptLbMain ~= nil then -- 521
			self.promptLbMain.anchor = Vec2(0.5, 0.5) -- 523
			self.promptLbMain.color = Color(255, 255, 255, 255) -- 524
			self.promptLbMain:addTo(self.promptNode) -- 525
		end -- 525
	end -- 525
	local main = self.promptLbMain -- 528
	if main == nil then -- 528
		return -- 530
	end -- 530
	main.visible = true -- 533
	main.color = Color(255, 255, 255, 255) -- 534
	main.alignment = "Center" -- 535
	main.text = self.promptText -- 536
	main.width = Label.AutomaticWidth -- 537
	main.position = Vec2(0, 0) -- 538
	local textW = main.width -- 539
	local textH = main.height > 0 and main.height or 24 -- 540
	local maxTextW = 280 -- 541
	if textW + 2 > maxTextW then -- 541
		local rows = math.ceil((textW + 2) / maxTextW) -- 543
		main.width = maxTextW -- 544
		textW = maxTextW -- 545
		textH = math.max(main.height, textH * rows) -- 546
	end -- 546
	self.promptW = textW -- 548
	self.promptH = textH -- 549
end -- 515
function WorldRenderer.prototype.buildLightDecor(self) -- 554
	local lightFloors = {3, 4, 5} -- 556
	local lanternFloors = {{top = FLOOR_TOPS[4], cx = 1000}, {top = FLOOR_TOPS[5], cx = 1200}, {top = FLOOR_TOPS[6], cx = 1700}} -- 557
	local lanternSpots = {} -- 562
	for ____, lf in ipairs(lanternFloors) do -- 563
		lanternSpots[#lanternSpots + 1] = {x = lf.cx - 350, y = lf.top + 240} -- 564
		lanternSpots[#lanternSpots + 1] = {x = lf.cx, y = lf.top + 240} -- 565
		lanternSpots[#lanternSpots + 1] = {x = lf.cx + 350, y = lf.top + 240} -- 566
	end -- 566
	self.lightDecor:addLanterns(lanternSpots) -- 568
	local torchSpots = {} -- 569
	for ____, rec in ipairs(self.portalNodes) do -- 570
		do -- 570
			local sanctioned = false -- 571
			for ____, lf in ipairs(lightFloors) do -- 572
				if lf == rec.floor then -- 572
					sanctioned = true -- 574
					break -- 575
				end -- 575
			end -- 575
			if not sanctioned then -- 575
				goto __continue44 -- 579
			end -- 579
			local top = rec.floor >= 0 and rec.floor < #FLOOR_TOPS and FLOOR_TOPS[rec.floor + 1] or 220 -- 581
			torchSpots[#torchSpots + 1] = {x = rec.x - 90, y = top} -- 582
			torchSpots[#torchSpots + 1] = {x = rec.x + 90, y = top} -- 583
		end -- 583
		::__continue44:: -- 583
	end -- 583
	self.lightDecor:addTorches(torchSpots) -- 585
end -- 554
function WorldRenderer.prototype.loadTex(self, path) -- 588
	local hit = self.texCache[path] -- 589
	if hit ~= nil then -- 589
		return hit -- 591
	end -- 591
	local tex = Texture2D(path) -- 593
	if tex == nil then -- 593
		return nil -- 595
	end -- 595
	self.texCache[path] = tex -- 597
	return tex -- 598
end -- 588
function WorldRenderer.prototype.setWorldVisible(self, v) -- 602
	self.bgSpriteRoot.visible = v -- 603
	self.worldRoot.visible = v -- 604
end -- 602
function WorldRenderer.prototype.debugPixelStats(self) -- 608
	return (((((((("bgRecs=" .. tostring(#self.bgRecs)) .. " bands=") .. tostring(#self.bgBands)) .. " tiles=") .. tostring(#self.tileGroups)) .. " pixelOk=") .. tostring(self.pixelBgOk)) .. " band=") .. tostring(self.activeBand) -- 609
end -- 608
function WorldRenderer.prototype.buildPixelBackgrounds(self) -- 612
	local vw = View.size.width -- 613
	local vh = View.size.height -- 614
	do -- 614
		local band = 0 -- 615
		while band < #BG_LAYERS do -- 615
			local bandNode = Node() -- 616
			bandNode:addTo(self.bgSpriteRoot) -- 617
			bandNode.visible = false -- 618
			local top = FLOOR_TOPS[band + 1] -- 619
			local ____self_bgBands_2 = self.bgBands -- 619
			____self_bgBands_2[#____self_bgBands_2 + 1] = {node = bandNode, floorTop = top} -- 620
			for ____, layer in ipairs(BG_LAYERS[band + 1]) do -- 621
				do -- 621
					local tex = self:loadTex(layer.path) -- 622
					if tex == nil then -- 622
						goto __continue58 -- 624
					end -- 624
					self.pixelBgOk = true -- 626
					local s = math.max(vw / tex.width, (vh + 40) / tex.height) -- 627
					local spanW = tex.width * s -- 628
					local copies = math.ceil(vw / spanW) + 2 -- 629
					do -- 629
						local j = 0 -- 630
						while j < copies do -- 630
							do -- 630
								local sp = Sprite(tex) -- 631
								if sp == nil then -- 631
									goto __continue61 -- 633
								end -- 633
								sp.anchor = Vec2(0, 0) -- 635
								sp.scaleX = s -- 636
								sp.scaleY = s -- 637
								sp.filter = "Point" -- 638
								sp:addTo(bandNode) -- 639
								local ____self_bgRecs_3 = self.bgRecs -- 639
								____self_bgRecs_3[#____self_bgRecs_3 + 1] = { -- 640
									node = sp, -- 641
									band = band, -- 642
									f = layer.f, -- 643
									spanW = spanW, -- 644
									imgH = tex.height * s, -- 645
									baseUp = layer.baseUp, -- 646
									copyIndex = j -- 647
								} -- 647
							end -- 647
							::__continue61:: -- 647
							j = j + 1 -- 630
						end -- 630
					end -- 630
				end -- 630
				::__continue58:: -- 630
			end -- 630
			band = band + 1 -- 615
		end -- 615
	end -- 615
end -- 612
function WorldRenderer.prototype.tileSprite(self, band, tex, x, y, cropW, cropH) -- 654
	local sp = Sprite( -- 655
		tex, -- 655
		Rect(0, 0, cropW, cropH) -- 655
	) -- 655
	if sp == nil then -- 655
		return -- 657
	end -- 657
	sp.anchor = Vec2(0, 0) -- 659
	sp.scaleX = 0.5 -- 660
	sp.scaleY = 0.5 -- 661
	sp.filter = "Point" -- 662
	sp.position = Vec2(x, y) -- 663
	sp:addTo(band) -- 664
end -- 654
function WorldRenderer.prototype.buildPixelTerrain(self) -- 667
	for ____, p in ipairs(self.data.platforms) do -- 668
		do -- 668
			if p.kind ~= "solid" or p.mover ~= nil or p.w < 300 then -- 668
				goto __continue67 -- 670
			end -- 670
			local key = TILE_SETS[p.floor + 1] -- 672
			local topTex = self:loadTex(("assets/tiles/" .. key) .. "_top.png") -- 673
			local fillTex = self:loadTex(("assets/tiles/" .. key) .. "_fill.png") -- 674
			if topTex == nil then -- 674
				goto __continue67 -- 676
			end -- 676
			local node = Node() -- 678
			node:addTo(self.worldRoot) -- 679
			local topY = p.y + p.h -- 680
			local cols = math.ceil(p.w / TILE) -- 681
			local rows = math.max( -- 682
				1, -- 682
				math.ceil(p.h / TILE) -- 682
			) -- 682
			local remW = p.w - (cols - 1) * TILE -- 683
			do -- 683
				local c = 0 -- 684
				while c < cols do -- 684
					local cw = c == cols - 1 and remW * 2 or 128 -- 685
					self:tileSprite( -- 686
						node, -- 686
						topTex, -- 686
						p.x + c * TILE, -- 686
						topY - TILE, -- 686
						cw, -- 686
						128 -- 686
					) -- 686
					c = c + 1 -- 684
				end -- 684
			end -- 684
			do -- 684
				local r = 1 -- 688
				while r < rows do -- 688
					if fillTex == nil then -- 688
						break -- 690
					end -- 690
					local fy = topY - TILE * (r + 1) -- 692
					local fh = r == rows - 1 and (topY - p.y - TILE * rows) * 2 or 128 -- 693
					if fh <= 0 then -- 693
						break -- 695
					end -- 695
					do -- 695
						local c = 0 -- 697
						while c < cols do -- 697
							local cw = c == cols - 1 and remW * 2 or 128 -- 698
							self:tileSprite( -- 699
								node, -- 699
								fillTex, -- 699
								p.x + c * TILE, -- 699
								fy, -- 699
								cw, -- 699
								fh -- 699
							) -- 699
							c = c + 1 -- 697
						end -- 697
					end -- 697
					r = r + 1 -- 688
				end -- 688
			end -- 688
			local ____self_tileGroups_4 = self.tileGroups -- 688
			____self_tileGroups_4[#____self_tileGroups_4 + 1] = { -- 702
				node = node, -- 702
				x0 = p.x, -- 702
				y0 = p.y, -- 702
				x1 = p.x + p.w, -- 702
				y1 = topY, -- 702
				floor = p.floor -- 702
			} -- 702
		end -- 702
		::__continue67:: -- 702
	end -- 702
	for ____, p in ipairs(self.data.platforms) do -- 706
		do -- 706
			if p.id ~= "wallL" and p.id ~= "wallR" then -- 706
				goto __continue79 -- 708
			end -- 708
			local fillTex = self:loadTex(("assets/tiles/" .. TILE_SETS[p.floor + 1]) .. "_fill.png") -- 710
			if fillTex == nil then -- 710
				goto __continue79 -- 712
			end -- 712
			local node = Node() -- 714
			node:addTo(self.worldRoot) -- 715
			local rows = math.ceil(p.h / TILE) -- 716
			do -- 716
				local r = 0 -- 717
				while r < rows do -- 717
					local rh = r == rows - 1 and (p.h - (rows - 1) * TILE) * 2 or 128 -- 718
					if rh <= 0 then -- 718
						break -- 720
					end -- 720
					self:tileSprite( -- 722
						node, -- 722
						fillTex, -- 722
						p.x, -- 722
						p.y + p.h - (r + 1) * TILE, -- 722
						160, -- 722
						rh -- 722
					) -- 722
					r = r + 1 -- 717
				end -- 717
			end -- 717
			local ____self_tileGroups_5 = self.tileGroups -- 717
			____self_tileGroups_5[#____self_tileGroups_5 + 1] = { -- 725
				node = node, -- 725
				x0 = p.x, -- 725
				y0 = p.y, -- 725
				x1 = p.x + p.w, -- 725
				y1 = p.y + p.h, -- 725
				floor = -1 -- 725
			} -- 725
		end -- 725
		::__continue79:: -- 725
	end -- 725
	for ____, hz in ipairs(self.data.hazards) do -- 728
		do -- 728
			local key = TILE_SETS[hz.floor + 1] -- 729
			local spikeTex = self:loadTex(("assets/tiles/" .. key) .. "_spike.png") -- 730
			if spikeTex == nil then -- 730
				goto __continue86 -- 732
			end -- 732
			local node = Node() -- 734
			node:addTo(self.worldRoot) -- 735
			local cols = math.ceil(hz.w / TILE) -- 736
			do -- 736
				local c = 0 -- 737
				while c < cols do -- 737
					self:tileSprite( -- 738
						node, -- 738
						spikeTex, -- 738
						hz.x + c * TILE, -- 738
						hz.y + 4, -- 738
						128, -- 738
						64 -- 738
					) -- 738
					c = c + 1 -- 737
				end -- 737
			end -- 737
			local ____self_tileGroups_6 = self.tileGroups -- 737
			____self_tileGroups_6[#____self_tileGroups_6 + 1] = { -- 740
				node = node, -- 740
				x0 = hz.x, -- 740
				y0 = hz.y, -- 740
				x1 = hz.x + hz.w, -- 740
				y1 = hz.y + hz.h, -- 740
				floor = hz.floor -- 740
			} -- 740
		end -- 740
		::__continue86:: -- 740
	end -- 740
	for ____, l in ipairs(self.data.ladders) do -- 743
		do -- 743
			local key = TILE_SETS[l.floor + 1] -- 744
			local tex = self:loadTex(("assets/tiles/" .. key) .. "_ladder.png") -- 745
			if tex == nil then -- 745
				goto __continue91 -- 747
			end -- 747
			local node = Node() -- 749
			node:addTo(self.worldRoot) -- 750
			local rows = math.ceil(l.h / TILE) -- 751
			do -- 751
				local r = 0 -- 752
				while r < rows do -- 752
					local rh = r == rows - 1 and (l.h - (rows - 1) * TILE) * 2 or 128 -- 753
					if rh <= 0 then -- 753
						break -- 755
					end -- 755
					self:tileSprite( -- 757
						node, -- 757
						tex, -- 757
						l.x, -- 757
						l.y + l.h - (r + 1) * TILE, -- 757
						92, -- 757
						rh -- 757
					) -- 757
					r = r + 1 -- 752
				end -- 752
			end -- 752
			local ____self_tileGroups_7 = self.tileGroups -- 752
			____self_tileGroups_7[#____self_tileGroups_7 + 1] = { -- 759
				node = node, -- 759
				x0 = l.x, -- 759
				y0 = l.y, -- 759
				x1 = l.x + l.w, -- 759
				y1 = l.y + l.h, -- 759
				floor = l.floor -- 759
			} -- 759
		end -- 759
		::__continue91:: -- 759
	end -- 759
	for ____, p in ipairs(self.data.platforms) do -- 762
		do -- 762
			if p.kind ~= "one-way" then -- 762
				goto __continue97 -- 764
			end -- 764
			local key = TILE_SETS[p.floor + 1] -- 766
			local tex = self:loadTex(("assets/tiles/" .. key) .. "_brick.png") -- 767
			if tex == nil then -- 767
				goto __continue97 -- 769
			end -- 769
			local node = Node() -- 771
			node:addTo(self.worldRoot) -- 772
			local cols = math.ceil(p.w / TILE) -- 773
			do -- 773
				local c = 0 -- 774
				while c < cols do -- 774
					local cw = c == cols - 1 and (p.w - (cols - 1) * TILE) * 2 or 128 -- 775
					if cw <= 0 then -- 775
						break -- 777
					end -- 777
					self:tileSprite( -- 779
						node, -- 779
						tex, -- 779
						p.x + c * TILE, -- 779
						p.y, -- 779
						cw, -- 779
						36 -- 779
					) -- 779
					c = c + 1 -- 774
				end -- 774
			end -- 774
			local ____self_tileGroups_8 = self.tileGroups -- 774
			____self_tileGroups_8[#____self_tileGroups_8 + 1] = { -- 781
				node = node, -- 781
				x0 = p.x, -- 781
				y0 = p.y, -- 781
				x1 = p.x + p.w, -- 781
				y1 = p.y + p.h, -- 781
				floor = p.floor -- 781
			} -- 781
		end -- 781
		::__continue97:: -- 781
	end -- 781
end -- 667
function WorldRenderer.prototype.buildPixelDecor(self) -- 785
	local decor = { -- 789
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 1300, y = FLOOR_TOPS[4]}, -- 791
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 600, y = FLOOR_TOPS[4]}, -- 794
		{path = "assets/tiles/skyruins_magicstone.png", floor = 3, x = 1900, y = FLOOR_TOPS[4]}, -- 795
		{path = "assets/tiles/skyruins_magicstone.png", floor = 6, x = 700, y = FLOOR_TOPS[7]}, -- 796
		{path = "assets/tiles/skyruins_magicstone.png", floor = 6, x = 1900, y = FLOOR_TOPS[7]} -- 797
	} -- 797
	for ____, d in ipairs(decor) do -- 799
		do -- 799
			if not styleAllowsDecor(TILE_SETS[d.floor + 1], d.path) then -- 799
				goto __continue105 -- 801
			end -- 801
			local tex = self:loadTex(d.path) -- 803
			if tex == nil then -- 803
				goto __continue105 -- 805
			end -- 805
			local sp = Sprite(tex) -- 807
			if sp == nil then -- 807
				goto __continue105 -- 809
			end -- 809
			sp.anchor = Vec2(0.5, 0) -- 811
			sp.scaleX = 0.5 -- 812
			sp.scaleY = 0.5 -- 813
			sp.filter = "Point" -- 814
			sp.position = Vec2(d.x, d.y) -- 815
			sp:addTo(self:floorHolderIn(self.decorNode, self.decorFloorHolders, d.floor)) -- 816
		end -- 816
		::__continue105:: -- 816
	end -- 816
end -- 785
function WorldRenderer.prototype.makePropSprite(self, path, x, y, boxW, boxH, fit) -- 840
	local tex = self:loadTex(path) -- 841
	if tex == nil then -- 841
		return nil -- 843
	end -- 843
	local sp = Sprite(tex) -- 845
	if sp == nil then -- 845
		return nil -- 847
	end -- 847
	local sW = boxW / tex.width -- 849
	local sH = boxH / tex.height -- 850
	local s = fit == "w" and sW or (fit == "h" and sH or math.min(sW, sH)) -- 851
	sp.anchor = Vec2(0.5, 0) -- 852
	sp.scaleX = s -- 853
	sp.scaleY = s -- 854
	sp.filter = "Point" -- 855
	sp.position = Vec2(x, y) -- 856
	sp:addTo(self:floorHolderIn( -- 857
		self.scenePropsRoot, -- 857
		self.sceneFloorHolders, -- 857
		self:floorOfY(y) -- 857
	)) -- 857
	return sp -- 858
end -- 840
function WorldRenderer.prototype.ensurePuzzleProps(self) -- 861
	if self.puzzleBuilt then -- 861
		return -- 863
	end -- 863
	self.puzzleBuilt = true -- 865
	self.treeSapling = self:makePropSprite( -- 866
		"assets/props/a2_sapling.png", -- 866
		700, -- 866
		FLOOR_TOPS[1], -- 866
		150, -- 866
		120, -- 866
		"min" -- 866
	) -- 866
	self.treePit = self:makePropSprite( -- 867
		"assets/props/a1_pit.png", -- 867
		1200, -- 867
		FLOOR_TOPS[1], -- 867
		150, -- 867
		26, -- 867
		"min" -- 867
	) -- 867
	self.treeMain = self:makePropSprite( -- 869
		"assets/props/a3_tree.png", -- 869
		1200, -- 869
		FLOOR_TOPS[1], -- 869
		260, -- 869
		200, -- 869
		"min" -- 869
	) -- 869
	self.treeMirror = self:makePropSprite( -- 870
		"assets/props/a3_tree.png", -- 870
		700, -- 870
		FLOOR_TOPS[1], -- 870
		210, -- 870
		162, -- 870
		"min" -- 870
	) -- 870
	self.stumpMain = self:makePropSprite( -- 871
		"assets/props/a4_stump.png", -- 871
		1200, -- 871
		FLOOR_TOPS[1], -- 871
		110, -- 871
		80, -- 871
		"min" -- 871
	) -- 871
	self.stumpMirror = self:makePropSprite( -- 872
		"assets/props/a4_stump.png", -- 872
		700, -- 872
		FLOOR_TOPS[1], -- 872
		110, -- 872
		80, -- 872
		"min" -- 872
	) -- 872
	self.barrelSp = self:makePropSprite( -- 873
		"assets/props/b6_barrel.png", -- 873
		1900, -- 873
		FLOOR_TOPS[2], -- 873
		92, -- 873
		84, -- 873
		"min" -- 873
	) -- 873
	local ladder = DrawNode() -- 874
	ladder:addTo(self.scenePropsRoot) -- 875
	local rail = Color(122, 88, 58, 255) -- 877
	local rung = Color(150, 112, 74, 255) -- 878
	ladder:drawSegment( -- 879
		Vec2(1160, FLOOR_TOPS[1]), -- 879
		Vec2(1160, FLOOR_TOPS[1] + 560), -- 879
		4, -- 879
		rail -- 879
	) -- 879
	ladder:drawSegment( -- 880
		Vec2(1200, FLOOR_TOPS[1]), -- 880
		Vec2(1200, FLOOR_TOPS[1] + 560), -- 880
		4, -- 880
		rail -- 880
	) -- 880
	do -- 880
		local y = FLOOR_TOPS[1] + 40 -- 881
		while y <= FLOOR_TOPS[1] + 540 do -- 881
			ladder:drawSegment( -- 882
				Vec2(1160, y), -- 882
				Vec2(1200, y), -- 882
				3, -- 882
				rung -- 882
			) -- 882
			y = y + 56 -- 881
		end -- 881
	end -- 881
	ladder.visible = false -- 884
	self.treeLadderDraw = ladder -- 885
end -- 861
function WorldRenderer.prototype.setVisible(self, sp, on) -- 888
	if sp ~= nil then -- 888
		sp.visible = on -- 890
	end -- 890
end -- 888
function WorldRenderer.prototype.syncTreePuzzle(self, flags) -- 895
	self:ensurePuzzleProps() -- 896
	local planted = flags.treePlanted == true -- 897
	local cut = flags.treeCut == true -- 898
	local taken = flags.saplingTaken == true -- 899
	self:setVisible(self.treeSapling, not planted and not cut and not taken) -- 900
	self:setVisible(self.treePit, not planted) -- 901
	self:setVisible(self.treeMain, planted and not cut) -- 902
	self:setVisible(self.treeMirror, planted and not cut) -- 903
	self:setVisible(self.stumpMain, cut) -- 904
	self:setVisible(self.stumpMirror, cut) -- 905
	if self.treeLadderDraw ~= nil then -- 905
		self.treeLadderDraw.visible = planted and not cut and self.activeFloor == 0 -- 907
	end -- 907
end -- 895
function WorldRenderer.prototype.syncBarrel(self, dt, down, left) -- 912
	self:ensurePuzzleProps() -- 913
	if self.barrelSp == nil then -- 913
		return -- 915
	end -- 915
	if not down then -- 915
		self.barrelT = 0 -- 918
		self.barrelSp.angle = 0 -- 919
		self.barrelSp.position = Vec2(1900, FLOOR_TOPS[2]) -- 920
		return -- 921
	end -- 921
	if self.barrelLeft ~= left then -- 921
		self.barrelLeft = left -- 924
		self.barrelT = 0 -- 925
	end -- 925
	if self.barrelT < 1 then -- 925
		self.barrelT = math.min(1, self.barrelT + dt * 3) -- 928
		local e = 1 - (1 - self.barrelT) * (1 - self.barrelT) -- 929
		self.barrelSp.angle = (left and -1 or 1) * 90 * e -- 930
		self.barrelSp.position = Vec2(1900 + (left and -1 or 1) * 40 * e, FLOOR_TOPS[2] + 6 * e) -- 931
	end -- 931
end -- 912
function WorldRenderer.prototype.getWorldRoot(self) -- 936
	return self.worldRoot -- 937
end -- 936
function WorldRenderer.prototype.buildSceneProps(self) -- 940
	local defs = { -- 941
		{ -- 943
			path = "assets/props/a3_tree.png", -- 943
			x = 2000, -- 943
			y = FLOOR_TOPS[1], -- 943
			w = 340, -- 943
			h = 220, -- 943
			fit = "min" -- 943
		}, -- 943
		{ -- 944
			path = "assets/props/a5_well.png", -- 944
			x = 860, -- 944
			y = FLOOR_TOPS[1], -- 944
			w = 150, -- 944
			h = 110, -- 944
			fit = "min" -- 944
		}, -- 944
		{ -- 946
			path = "assets/props/a4_stump.png", -- 946
			x = 1550, -- 946
			y = FLOOR_TOPS[1], -- 946
			w = 110, -- 946
			h = 80, -- 946
			fit = "min" -- 946
		}, -- 946
		{ -- 947
			path = "assets/props/a6_bucket.png", -- 947
			x = 1650, -- 947
			y = FLOOR_TOPS[1], -- 947
			w = 56, -- 947
			h = 42, -- 947
			fit = "min" -- 947
		}, -- 947
		{ -- 951
			path = "assets/decor/lantern_1.png", -- 951
			x = 980, -- 951
			y = FLOOR_TOPS[2], -- 951
			w = 42, -- 951
			h = 74, -- 951
			fit = "h" -- 951
		}, -- 951
		{ -- 952
			path = "assets/decor/lantern_1.png", -- 952
			x = 2150, -- 952
			y = FLOOR_TOPS[2], -- 952
			w = 42, -- 952
			h = 74, -- 952
			fit = "h" -- 952
		}, -- 952
		{ -- 956
			path = "assets/props/e2_dice.png", -- 956
			x = 490, -- 956
			y = FLOOR_TOPS[2], -- 956
			w = 34, -- 956
			h = 30, -- 956
			fit = "min" -- 956
		}, -- 956
		{ -- 957
			path = "assets/props/b7_table.png", -- 957
			x = 550, -- 957
			y = FLOOR_TOPS[2], -- 957
			w = 190, -- 957
			h = 78, -- 957
			fit = "min" -- 957
		}, -- 957
		{ -- 958
			path = "assets/props/e6_offering.png", -- 958
			x = 1020, -- 958
			y = FLOOR_TOPS[2], -- 958
			w = 52, -- 958
			h = 36, -- 958
			fit = "min" -- 958
		}, -- 958
		{ -- 959
			path = "assets/props/b5_counter.png", -- 959
			x = 1755, -- 959
			y = FLOOR_TOPS[2], -- 959
			w = 160, -- 959
			h = 110, -- 959
			fit = "min" -- 959
		}, -- 959
		{ -- 962
			path = "assets/props/withered_reed.png", -- 962
			x = 1360, -- 962
			y = FLOOR_TOPS[1], -- 962
			w = 64, -- 962
			h = 78, -- 962
			fit = "w" -- 962
		}, -- 962
		{ -- 963
			path = "assets/props/withered_reed.png", -- 963
			x = 1690, -- 963
			y = FLOOR_TOPS[1], -- 963
			w = 56, -- 963
			h = 70, -- 963
			fit = "w" -- 963
		}, -- 963
		{ -- 965
			path = "assets/props/b6_barrel.png", -- 965
			x = 660, -- 965
			y = FLOOR_TOPS[3], -- 965
			w = 92, -- 965
			h = 84, -- 965
			fit = "min" -- 965
		}, -- 965
		{ -- 966
			path = "assets/props/b7_table.png", -- 966
			x = 1750, -- 966
			y = FLOOR_TOPS[3], -- 966
			w = 190, -- 966
			h = 78, -- 966
			fit = "min" -- 966
		}, -- 966
		{ -- 967
			path = "assets/props/b6_barrel.png", -- 967
			x = 1980, -- 967
			y = FLOOR_TOPS[3], -- 967
			w = 92, -- 967
			h = 84, -- 967
			fit = "min" -- 967
		}, -- 967
		{ -- 969
			path = "assets/props/withered_reed.png", -- 969
			x = 480, -- 969
			y = FLOOR_TOPS[6], -- 969
			w = 60, -- 969
			h = 74, -- 969
			fit = "w" -- 969
		}, -- 969
		{ -- 973
			path = "assets/props/e5_herb.png", -- 973
			x = 1150, -- 973
			y = FLOOR_TOPS[2], -- 973
			w = 36, -- 973
			h = 30, -- 973
			fit = "min" -- 973
		}, -- 973
		{ -- 974
			path = "assets/props/e3_lingzhi.png", -- 974
			x = 1310, -- 974
			y = FLOOR_TOPS[2], -- 974
			w = 44, -- 974
			h = 36, -- 974
			fit = "min" -- 974
		}, -- 974
		{ -- 975
			path = "assets/props/e4_ginseng.png", -- 975
			x = 1650, -- 975
			y = FLOOR_TOPS[2], -- 975
			w = 40, -- 975
			h = 34, -- 975
			fit = "min" -- 975
		}, -- 975
		{ -- 979
			path = "assets/props/e7_shard.png", -- 979
			x = 980, -- 979
			y = FLOOR_TOPS[7], -- 979
			w = 46, -- 979
			h = 40, -- 979
			fit = "min" -- 979
		} -- 979
	} -- 979
	for ____, d in ipairs(defs) do -- 981
		self:addSceneProp( -- 982
			d.path, -- 982
			d.x, -- 982
			d.y, -- 982
			d.w, -- 982
			d.h, -- 982
			d.fit -- 982
		) -- 982
	end -- 982
	for ____, hs in ipairs(HIDE_SPOTS) do -- 987
		local top = hs.floor >= 0 and hs.floor < #FLOOR_TOPS and FLOOR_TOPS[hs.floor + 1] or FLOOR_TOPS[2] -- 988
		self:addSceneProp( -- 989
			"assets/props/b1_bush.png", -- 989
			hs.x, -- 989
			top, -- 989
			104, -- 989
			64, -- 989
			"w" -- 989
		) -- 989
		self:addSceneProp( -- 990
			"assets/props/withered_reed.png", -- 990
			hs.x, -- 990
			top, -- 990
			96, -- 990
			72, -- 990
			"w" -- 990
		) -- 990
	end -- 990
end -- 940
function WorldRenderer.prototype.addSceneProp(self, path, x, y, boxW, boxH, fit) -- 995
	local tex = self:loadTex(path) -- 996
	if tex == nil then -- 996
		return -- 998
	end -- 998
	local sp = Sprite(tex) -- 1000
	if sp == nil then -- 1000
		return -- 1002
	end -- 1002
	local sW = boxW / tex.width -- 1004
	local sH = boxH / tex.height -- 1005
	local s = fit == "w" and sW or (fit == "h" and sH or math.min(sW, sH)) -- 1006
	sp.anchor = Vec2(0.5, 0) -- 1007
	sp.scaleX = s -- 1008
	sp.scaleY = s -- 1009
	sp.filter = "Point" -- 1010
	sp.position = Vec2(x, y) -- 1011
	sp:addTo(self:floorHolderIn( -- 1012
		self.scenePropsRoot, -- 1012
		self.sceneFloorHolders, -- 1012
		self:floorOfY(y) -- 1012
	)) -- 1012
end -- 995
function WorldRenderer.prototype.setCamera(self, camX, camY, shakeX, shakeY) -- 1015
	self.camX = camX -- 1016
	self.camY = camY -- 1017
	local vw = View.size.width -- 1018
	local vh = View.size.height -- 1019
	self.vw = vw -- 1020
	self.vh = vh -- 1021
	self.worldRoot.scaleX = ____exports.CAM_ZOOM -- 1025
	self.worldRoot.scaleY = ____exports.CAM_ZOOM -- 1026
	self.worldRoot.position = Vec2(-camX * ____exports.CAM_ZOOM + shakeX, -camY * ____exports.CAM_ZOOM + shakeY) -- 1027
	self:updatePixelBackdrop(camX, camY, vw, vh) -- 1028
	for ____, g in ipairs(self.tileGroups) do -- 1029
		g.node.visible = (g.floor < 0 or g.floor == self.activeFloor) and self:inView(g.x0, g.y0 - 40, g.x1, g.y1 + 40) -- 1031
	end -- 1031
end -- 1015
function WorldRenderer.prototype.setFloorScene(self, floor) -- 1036
	self.sceneBand = math.max( -- 1037
		0, -- 1037
		math.min( -- 1037
			#BG_LAYERS - 1, -- 1037
			math.floor(floor) -- 1037
		) -- 1037
	) -- 1037
	self.activeFloor = self.sceneBand -- 1040
	self:applyFloorHolders(self.sceneFloorHolders) -- 1041
	self:applyFloorHolders(self.decorFloorHolders) -- 1042
	self:applyFloorHolders(self.propSpriteFloorHolders) -- 1043
end -- 1036
function WorldRenderer.prototype.applyFloorHolders(self, holders) -- 1046
	do -- 1046
		local i = 0 -- 1047
		while i < #holders do -- 1047
			holders[i + 1].visible = i == self.activeFloor -- 1048
			i = i + 1 -- 1047
		end -- 1047
	end -- 1047
end -- 1046
function WorldRenderer.prototype.floorHolderIn(self, root, holders, floor) -- 1053
	while #holders <= floor do -- 1053
		local n = Node() -- 1055
		n:addTo(root) -- 1056
		n.visible = #holders == self.activeFloor -- 1057
		holders[#holders + 1] = n -- 1058
	end -- 1058
	return holders[floor + 1] -- 1060
end -- 1053
function WorldRenderer.prototype.floorOfY(self, y) -- 1065
	local f = 0 -- 1066
	do -- 1066
		local i = #FLOOR_TOPS - 1 -- 1067
		while i >= 0 do -- 1067
			if y >= FLOOR_TOPS[i + 1] then -- 1067
				f = i -- 1069
				break -- 1070
			end -- 1070
			i = i - 1 -- 1067
		end -- 1067
	end -- 1067
	return f -- 1073
end -- 1065
function WorldRenderer.prototype.buildPortals(self) -- 1077
	local list = self.data.portals -- 1078
	do -- 1078
		local i = 0 -- 1079
		while i < #list do -- 1079
			local p = list[i + 1] -- 1080
			local holder = Node() -- 1081
			holder:addTo(self.portalLayer) -- 1082
			holder.visible = false -- 1083
			local tex = self:loadTex("assets/tiles/skyruins_portal.png") -- 1084
			if tex ~= nil then -- 1084
				local s = 130 / tex.height -- 1086
				local sp = Sprite(tex) -- 1087
				sp.anchor = Vec2(0.5, 0) -- 1088
				sp.scaleX = s -- 1089
				sp.scaleY = s -- 1090
				sp.filter = "Point" -- 1091
				sp.position = Vec2(p.x, p.y) -- 1092
				sp:addTo(holder) -- 1093
			else -- 1093
				local d = DrawNode() -- 1095
				d:addTo(holder) -- 1096
				d:drawPolygon( -- 1097
					{ -- 1097
						Vec2(p.x - 26, p.y), -- 1098
						Vec2(p.x + 26, p.y), -- 1099
						Vec2(p.x + 26, p.y + 86), -- 1100
						Vec2(p.x, p.y + 118), -- 1101
						Vec2(p.x - 26, p.y + 86) -- 1102
					}, -- 1102
					Color(120, 200, 255, 200) -- 1103
				) -- 1103
			end -- 1103
			local ____self_portalNodes_9 = self.portalNodes -- 1103
			____self_portalNodes_9[#____self_portalNodes_9 + 1] = { -- 1105
				node = holder, -- 1105
				floor = p.floor, -- 1105
				x = p.x, -- 1105
				gateId = p.gateId, -- 1105
				fade = 0 -- 1105
			} -- 1105
			i = i + 1 -- 1079
		end -- 1079
	end -- 1079
end -- 1077
function WorldRenderer.prototype.buildPropSprites(self) -- 1110
	local stoneTex = self:loadTex("assets/tiles/push_stone.png") -- 1112
	if stoneTex ~= nil then -- 1112
		local sx = 56 / stoneTex.width -- 1114
		local sy = 44 / stoneTex.height -- 1115
		for ____, def in ipairs(self.data.pushStones) do -- 1116
			do -- 1116
				local sp = Sprite(stoneTex) -- 1117
				if sp == nil then -- 1117
					goto __continue155 -- 1119
				end -- 1119
				sp.anchor = Vec2(0.5, 0.5) -- 1121
				sp.scaleX = sx -- 1122
				sp.scaleY = sy -- 1123
				sp.position = Vec2(def.x, def.y + 22) -- 1124
				sp.visible = false -- 1125
				sp:addTo(self:floorHolderIn( -- 1126
					self.propSpriteRoot, -- 1126
					self.propSpriteFloorHolders, -- 1126
					self:floorOfY(def.y + 22) -- 1126
				)) -- 1126
				local ____self_stoneSprites_10 = self.stoneSprites -- 1126
				____self_stoneSprites_10[#____self_stoneSprites_10 + 1] = sp -- 1127
			end -- 1127
			::__continue155:: -- 1127
		end -- 1127
	end -- 1127
	local lampTex = self:loadTex("assets/tiles/lamp_stone.png") -- 1131
	if lampTex ~= nil then -- 1131
		local s = 36 / lampTex.height -- 1133
		for ____, c in ipairs(self.data.collectibles) do -- 1134
			do -- 1134
				if c.kind ~= "lampstone" then -- 1134
					goto __continue159 -- 1136
				end -- 1136
				local sp = Sprite(lampTex) -- 1138
				if sp == nil then -- 1138
					goto __continue159 -- 1140
				end -- 1140
				sp.anchor = Vec2(0.5, 0.5) -- 1142
				sp.scaleX = s -- 1143
				sp.scaleY = s -- 1144
				sp.position = Vec2(c.x, c.y + 18) -- 1145
				sp.visible = false -- 1146
				sp:addTo(self:floorHolderIn( -- 1147
					self.propSpriteRoot, -- 1147
					self.propSpriteFloorHolders, -- 1147
					self:floorOfY(c.y) -- 1147
				)) -- 1147
				self.lampStoneSprites[c.id] = sp -- 1148
			end -- 1148
			::__continue159:: -- 1148
		end -- 1148
	end -- 1148
	local moonTex = self:loadTex("assets/tiles/moon_stone.png") -- 1152
	if moonTex ~= nil then -- 1152
		local msc = 36 / moonTex.height -- 1154
		for ____, c in ipairs(self.data.collectibles) do -- 1155
			do -- 1155
				if c.kind ~= "moonstone" then -- 1155
					goto __continue164 -- 1157
				end -- 1157
				local sp = Sprite(moonTex) -- 1159
				if sp == nil then -- 1159
					goto __continue164 -- 1161
				end -- 1161
				sp.anchor = Vec2(0.5, 0.5) -- 1163
				sp.scaleX = msc -- 1164
				sp.scaleY = msc -- 1165
				sp.position = Vec2(c.x, c.y + 18) -- 1166
				sp.visible = false -- 1167
				sp:addTo(self:floorHolderIn( -- 1168
					self.propSpriteRoot, -- 1168
					self.propSpriteFloorHolders, -- 1168
					self:floorOfY(c.y) -- 1168
				)) -- 1168
				self.moonStoneSprites[c.id] = sp -- 1169
			end -- 1169
			::__continue164:: -- 1169
		end -- 1169
	end -- 1169
	local dewTex = self:loadTex("assets/props/blood_dew.png") -- 1173
	if dewTex ~= nil then -- 1173
		print(((("[DewSprite] loaded assets/props/blood_dew.png (" .. tostring(dewTex.width)) .. "x") .. tostring(dewTex.height)) .. ")") -- 1175
		local dc = 36 / dewTex.height -- 1176
		for ____, c in ipairs(self.data.collectibles) do -- 1177
			do -- 1177
				if c.kind ~= "dew" then -- 1177
					goto __continue169 -- 1179
				end -- 1179
				local sp = Sprite(dewTex) -- 1181
				if sp == nil then -- 1181
					goto __continue169 -- 1183
				end -- 1183
				sp.anchor = Vec2(0.5, 0.5) -- 1185
				sp.scaleX = dc -- 1186
				sp.scaleY = dc -- 1187
				sp.position = Vec2(c.x, c.y + 18) -- 1188
				sp.visible = false -- 1189
				sp:addTo(self:floorHolderIn( -- 1190
					self.propSpriteRoot, -- 1190
					self.propSpriteFloorHolders, -- 1190
					self:floorOfY(c.y) -- 1190
				)) -- 1190
				self.dewSprites[c.id] = sp -- 1191
			end -- 1191
			::__continue169:: -- 1191
		end -- 1191
	end -- 1191
	local tokenTex = self:loadTex("assets/props/e7_shard.png") -- 1196
	if tokenTex ~= nil then -- 1196
		local tsc = 36 / tokenTex.height -- 1198
		for ____, c in ipairs(self.data.collectibles) do -- 1199
			do -- 1199
				if c.kind ~= "token" then -- 1199
					goto __continue174 -- 1201
				end -- 1201
				local sp = Sprite(tokenTex) -- 1203
				if sp == nil then -- 1203
					goto __continue174 -- 1205
				end -- 1205
				sp.anchor = Vec2(0.5, 0.5) -- 1207
				sp.scaleX = tsc -- 1208
				sp.scaleY = tsc -- 1209
				sp.position = Vec2(c.x, c.y + 18) -- 1210
				sp.visible = false -- 1211
				sp:addTo(self:floorHolderIn( -- 1212
					self.propSpriteRoot, -- 1212
					self.propSpriteFloorHolders, -- 1212
					self:floorOfY(c.y) -- 1212
				)) -- 1212
				self.tokenSprites[c.id] = sp -- 1213
			end -- 1213
			::__continue174:: -- 1213
		end -- 1213
	end -- 1213
	local offTex = self:loadTex("assets/ui/flag/checkpoint_off.png") -- 1217
	for ____, cp in ipairs(self.data.checkpoints) do -- 1218
		do -- 1218
			if cp.id == "cp_riverbank" then -- 1218
				goto __continue178 -- 1220
			end -- 1220
			local onFrames = {} -- 1222
			do -- 1222
				local fi = 0 -- 1223
				while fi < 4 do -- 1223
					do -- 1223
						local tex = self:loadTex(("assets/ui/flag/checkpoint_on_" .. tostring(fi)) .. ".png") -- 1224
						if tex == nil then -- 1224
							goto __continue181 -- 1226
						end -- 1226
						local sp = Sprite(tex) -- 1228
						if sp == nil then -- 1228
							goto __continue181 -- 1230
						end -- 1230
						self:setupFlagSprite( -- 1232
							sp, -- 1232
							tex.height, -- 1232
							cp.x, -- 1232
							cp.y, -- 1232
							self:floorOfY(cp.y) -- 1232
						) -- 1232
						onFrames[#onFrames + 1] = sp -- 1233
					end -- 1233
					::__continue181:: -- 1233
					fi = fi + 1 -- 1223
				end -- 1223
			end -- 1223
			if offTex ~= nil and #onFrames > 0 then -- 1223
				local spOff = Sprite(offTex) -- 1236
				if spOff ~= nil then -- 1236
					self:setupFlagSprite( -- 1238
						spOff, -- 1238
						offTex.height, -- 1238
						cp.x, -- 1238
						cp.y, -- 1238
						self:floorOfY(cp.y) -- 1238
					) -- 1238
					self.flagSets[cp.id] = {off = spOff, on = onFrames} -- 1239
				end -- 1239
			end -- 1239
		end -- 1239
		::__continue178:: -- 1239
	end -- 1239
end -- 1110
function WorldRenderer.prototype.setupFlagSprite(self, sp, texH, x, y, floor) -- 1245
	local s = 90 / texH -- 1246
	sp.anchor = Vec2(0.5, 0) -- 1247
	sp.scaleX = s -- 1248
	sp.scaleY = s -- 1249
	sp.filter = "Point" -- 1250
	sp.position = Vec2(x, y) -- 1251
	sp.visible = false -- 1252
	sp:addTo(self:floorHolderIn(self.propSpriteRoot, self.propSpriteFloorHolders, floor)) -- 1253
end -- 1245
function WorldRenderer.prototype.updatePortals(self, player, state, dt) -- 1256
	do -- 1256
		local i = 0 -- 1257
		while i < #self.portalNodes do -- 1257
			local rec = self.portalNodes[i + 1] -- 1258
			local unlocked = rec.gateId == nil or state.openedGates[rec.gateId] == true -- 1261
			local want = unlocked and rec.floor == self.sceneBand and math.abs(player.body.x - rec.x) < 280 -- 1262
			rec.fade = rec.fade + ((want and 1 or 0) - rec.fade) * math.min(1, dt * 8) -- 1263
			if rec.fade < 0.005 then -- 1263
				rec.fade = 0 -- 1265
			end -- 1265
			rec.node.visible = rec.fade > 0.02 -- 1267
			rec.node.opacity = rec.fade -- 1268
			i = i + 1 -- 1257
		end -- 1257
	end -- 1257
end -- 1256
function WorldRenderer.prototype.updatePixelBackdrop(self, camX, camY, vw, vh) -- 1273
	if not self.pixelBgOk then -- 1273
		return -- 1275
	end -- 1275
	local band = math.max( -- 1277
		0, -- 1277
		math.min(#self.bgBands - 1, self.sceneBand) -- 1277
	) -- 1277
	do -- 1277
		local i = 0 -- 1278
		while i < #self.bgBands do -- 1278
			self.bgBands[i + 1].node.visible = i == band -- 1279
			i = i + 1 -- 1278
		end -- 1278
	end -- 1278
	local bandTop = self.bgBands[band + 1].floorTop -- 1281
	local function mod(x, m) -- 1282
		local r = x % m -- 1283
		return r < 0 and r + m or r -- 1284
	end -- 1282
	for ____, rec in ipairs(self.bgRecs) do -- 1286
		do -- 1286
			if rec.band ~= band then -- 1286
				goto __continue197 -- 1288
			end -- 1288
			local offX = mod(camX * rec.f, rec.spanW) -- 1290
			rec.node.x = -vw / 2 - offX + rec.copyIndex * rec.spanW -- 1291
			local yBase = -vh / 2 + 1 + rec.baseUp -- 1292
			local targetY = yBase + (bandTop - camY) * rec.f * 0.6 -- 1293
			local yMin = vh / 2 - rec.imgH + 1 -- 1294
			rec.node.y = targetY < yMin and yMin or targetY -- 1295
		end -- 1295
		::__continue197:: -- 1295
	end -- 1295
	self.activeBand = band -- 1297
end -- 1273
function WorldRenderer.prototype.inViewX(self, x0, x1) -- 1300
	local hw = self.vw / (2 * ____exports.CAM_ZOOM) -- 1302
	return x1 >= self.camX - hw - CULL and x0 <= self.camX + hw + CULL -- 1303
end -- 1300
function WorldRenderer.prototype.inViewY(self, y0, y1) -- 1306
	local hh = self.vh / (2 * ____exports.CAM_ZOOM) -- 1307
	return y1 >= self.camY - hh - CULL and y0 <= self.camY + hh + CULL -- 1308
end -- 1306
function WorldRenderer.prototype.inView(self, x0, y0, x1, y1) -- 1311
	return self:inViewX(x0, x1) and self:inViewY(y0, y1) -- 1312
end -- 1311
function WorldRenderer.prototype.update(self, dt, state, player, enemies, mech, time) -- 1315
	self.lightDecor:update(time, dt) -- 1316
	self:updatePortals(player, state, dt) -- 1317
	self:drawBackground(time) -- 1318
	self:drawTerrain(time) -- 1319
	self:drawProps(time, state) -- 1320
	self:drawChars( -- 1321
		time, -- 1321
		state, -- 1321
		player, -- 1321
		enemies, -- 1321
		mech, -- 1321
		dt -- 1321
	) -- 1321
end -- 1315
function WorldRenderer.prototype.drawBackground(self, time) -- 1325
	local d = self.bgDraw -- 1326
	d:clear() -- 1327
	local vw = self.vw -- 1328
	local vh = self.vh -- 1329
	local x0 = -vw / 2 -- 1330
	local y0 = -vh / 2 -- 1331
	if not self.pixelBgOk then -- 1331
		d:drawPolygon( -- 1333
			{ -- 1334
				Vec2(x0 - 4, y0 - 4), -- 1334
				Vec2(x0 + vw + 8, y0 - 4), -- 1334
				Vec2(x0 + vw + 8, y0 + vh + 8), -- 1334
				Vec2(x0 - 4, y0 + vh + 8) -- 1334
			}, -- 1334
			col(Palette.paper), -- 1335
			0, -- 1336
			Color(0, 0, 0, 0) -- 1337
		) -- 1337
	end -- 1337
	local span = vw + 80 -- 1341
	local starsOn = self.sceneBand ~= 4 -- 1342
	do -- 1342
		local i = 0 -- 1343
		while starsOn and i < #self.stars do -- 1343
			local st = self.stars[i + 1] -- 1344
			local wx = st.x - self.camX * 0.04 -- 1345
			wx = wx % span -- 1346
			if wx < 0 then -- 1346
				wx = wx + span -- 1348
			end -- 1348
			local sx = wx - 40 - vw / 2 -- 1350
			local sy = y0 + st.y -- 1351
			local tw = 0.22 + 0.3 * (0.5 + 0.5 * math.sin(time * 1.8 + i * 1.7)) -- 1352
			dot( -- 1353
				d, -- 1353
				sx, -- 1353
				sy, -- 1353
				st.s, -- 1353
				Palette.moonWhite, -- 1353
				tw -- 1353
			) -- 1353
			i = i + 1 -- 1343
		end -- 1343
	end -- 1343
	if self.pixelBgOk and self.sceneBand == 4 then -- 1343
		self:drawMechBackdrop(time) -- 1358
	end -- 1358
	if not self.pixelBgOk then -- 1358
		local ridges = { -- 1362
			{ -- 1363
				p = 0.12, -- 1363
				base = -70, -- 1363
				a1 = 46, -- 1363
				a2 = 18, -- 1363
				c = ink(101, 112, 107, 50), -- 1363
				s = 0.006, -- 1363
				s2 = 0.017 -- 1363
			}, -- 1363
			{ -- 1364
				p = 0.22, -- 1364
				base = -120, -- 1364
				a1 = 58, -- 1364
				a2 = 22, -- 1364
				c = ink(84, 94, 90, 85), -- 1364
				s = 0.007, -- 1364
				s2 = 0.021 -- 1364
			}, -- 1364
			{ -- 1365
				p = 0.35, -- 1365
				base = -180, -- 1365
				a1 = 70, -- 1365
				a2 = 26, -- 1365
				c = ink(66, 74, 70, 130), -- 1365
				s = 0.008, -- 1365
				s2 = 0.026 -- 1365
			} -- 1365
		} -- 1365
		do -- 1365
			local ri = 0 -- 1367
			while ri < #ridges do -- 1367
				local rg = ridges[ri + 1] -- 1368
				local verts = {} -- 1369
				do -- 1369
					local sx = -64 -- 1370
					while sx <= vw + 64 do -- 1370
						local wxs = sx + self.camX * rg.p -- 1371
						local ry = rg.base - self.camY * rg.p * 0.5 + rg.a1 * math.sin(wxs * rg.s + ri * 2.3) + rg.a2 * math.sin(wxs * rg.s2 + ri * 1.1) -- 1372
						verts[#verts + 1] = Vec2(sx - vw / 2, ry) -- 1373
						sx = sx + 64 -- 1370
					end -- 1370
				end -- 1370
				verts[#verts + 1] = Vec2(vw / 2 + 64, y0 - 6) -- 1375
				verts[#verts + 1] = Vec2(-vw / 2 - 64, y0 - 6) -- 1376
				d:drawPolygon( -- 1377
					verts, -- 1377
					col(rg.c), -- 1377
					0, -- 1377
					Color(0, 0, 0, 0) -- 1377
				) -- 1377
				ri = ri + 1 -- 1367
			end -- 1367
		end -- 1367
		self:drawPagoda(time) -- 1379
		self:drawMist(time) -- 1380
		if self.camY - vh / 2 < 300 then -- 1380
			self:drawWaterFront(time) -- 1382
		end -- 1382
	end -- 1382
end -- 1325
function WorldRenderer.prototype.drawMechBackdrop(self, time) -- 1389
	local d = self.bgDraw -- 1390
	local vw = self.vw -- 1391
	local vh = self.vh -- 1392
	local x0 = -vw / 2 -- 1393
	local y0 = -vh / 2 -- 1394
	d:drawPolygon( -- 1396
		{ -- 1397
			Vec2(x0 - 4, y0 - 4), -- 1397
			Vec2(x0 + vw + 8, y0 - 4), -- 1397
			Vec2(x0 + vw + 8, y0 + vh + 8), -- 1397
			Vec2(x0 - 4, y0 + vh + 8) -- 1397
		}, -- 1397
		col(ink(30, 26, 22, 255)), -- 1398
		0, -- 1399
		Color(0, 0, 0, 0) -- 1400
	) -- 1400
	local yShift = -(self.camY - FLOOR_TOPS[5]) * 0.06 -- 1402
	local function mod(x, m) -- 1403
		local r = x % m -- 1404
		return r < 0 and r + m or r -- 1405
	end -- 1403
	local glowCyan = ink(168, 197, 188, 255) -- 1407
	local spanFar = 1500 -- 1409
	local offFar = mod(self.camX * 0.1, spanFar) -- 1410
	do -- 1410
		local i = 0 -- 1411
		while i < 3 do -- 1411
			do -- 1411
				local wx = mod(i * 520 + 240 - offFar, spanFar) - 200 -- 1412
				local gx = wx - vw / 2 -- 1413
				if gx < -260 or gx > vw / 2 + 260 then -- 1413
					goto __continue219 -- 1415
				end -- 1415
				local gy = y0 + 210 + yShift * 0.5 -- 1417
				local dir = i == 1 and -1 or 1 -- 1418
				self:drawGearShape( -- 1419
					d, -- 1419
					gx, -- 1419
					gy, -- 1419
					190 - i * 24, -- 1419
					12, -- 1419
					time * (0.12 + i * 0.04) * dir, -- 1419
					ink(50, 42, 33, 235), -- 1419
					ink(40, 33, 26, 235) -- 1419
				) -- 1419
			end -- 1419
			::__continue219:: -- 1419
			i = i + 1 -- 1411
		end -- 1411
	end -- 1411
	do -- 1411
		local i = 0 -- 1421
		while i < 4 do -- 1421
			do -- 1421
				local wx = mod(i * 430 + 90 - offFar, spanFar) - 200 -- 1422
				local cx = wx - vw / 2 -- 1423
				if cx < -60 or cx > vw / 2 + 60 then -- 1423
					goto __continue222 -- 1425
				end -- 1425
				d:drawPolygon( -- 1427
					{ -- 1428
						Vec2(cx - 22, y0 - 4), -- 1428
						Vec2(cx + 22, y0 - 4), -- 1428
						Vec2(cx + 16, y0 + vh + 8), -- 1428
						Vec2(cx - 16, y0 + vh + 8) -- 1428
					}, -- 1428
					col(ink(42, 36, 29, 220)), -- 1429
					0, -- 1430
					Color(0, 0, 0, 0) -- 1431
				) -- 1431
				seg( -- 1433
					d, -- 1433
					cx - 19, -- 1433
					y0 + 40, -- 1433
					cx - 19, -- 1433
					y0 + vh - 20, -- 1433
					2, -- 1433
					ink(34, 29, 24, 160) -- 1433
				) -- 1433
			end -- 1433
			::__continue222:: -- 1433
			i = i + 1 -- 1421
		end -- 1421
	end -- 1421
	local spanMid = 1200 -- 1436
	local offMid = mod(self.camX * 0.26, spanMid) -- 1437
	local pipeYs = {y0 + vh * 0.72, y0 + vh * 0.5, y0 + vh * 0.3} -- 1438
	do -- 1438
		local pi = 0 -- 1439
		while pi < #pipeYs do -- 1439
			local py = pipeYs[pi + 1] + yShift -- 1440
			seg( -- 1441
				d, -- 1441
				x0 - 20, -- 1441
				py, -- 1441
				x0 + vw + 20, -- 1441
				py, -- 1441
				10 - pi * 2, -- 1441
				ink(60, 50, 38, 235) -- 1441
			) -- 1441
			do -- 1441
				local jx = -((offMid + 60) % 150) -- 1442
				while jx < vw + 20 do -- 1442
					circle( -- 1443
						d, -- 1443
						x0 + jx, -- 1443
						py, -- 1443
						7 - pi, -- 1443
						ink(72, 60, 45, 235), -- 1443
						5 -- 1443
					) -- 1443
					jx = jx + 150 -- 1442
				end -- 1442
			end -- 1442
			do -- 1442
				local jx = -((offMid + 105) % 300) -- 1445
				while jx < vw do -- 1445
					dot( -- 1446
						d, -- 1446
						x0 + jx, -- 1446
						py + 12, -- 1446
						3.2, -- 1446
						glowCyan, -- 1446
						0.3 + 0.22 * math.sin(time * 2.4 + pi * 1.9 + jx) -- 1446
					) -- 1446
					jx = jx + 300 -- 1445
				end -- 1445
			end -- 1445
			pi = pi + 1 -- 1439
		end -- 1439
	end -- 1439
	do -- 1439
		local i = 0 -- 1450
		while i < 5 do -- 1450
			do -- 1450
				local wx = mod(i * 260 + 130 - offMid, spanMid) - 150 -- 1451
				local cx = wx - vw / 2 -- 1452
				if cx < -40 or cx > vw / 2 + 40 then -- 1452
					goto __continue231 -- 1454
				end -- 1454
				local sway = math.sin(time * 0.7 + i * 1.3) * 6 -- 1456
				local topY = y0 + vh + 8 -- 1457
				local botY = y0 + 120 + yShift + i % 2 * 46 -- 1458
				seg( -- 1459
					d, -- 1459
					cx, -- 1459
					topY, -- 1459
					cx + sway, -- 1459
					botY, -- 1459
					2.4, -- 1459
					ink(70, 59, 45, 220) -- 1459
				) -- 1459
				do -- 1459
					local k = 1 -- 1460
					while k < 7 do -- 1460
						local t = k / 7 -- 1461
						dot( -- 1462
							d, -- 1462
							cx + sway * t, -- 1462
							topY + (botY - topY) * t, -- 1462
							3.4, -- 1462
							ink(80, 68, 52, 220), -- 1462
							0.9 -- 1462
						) -- 1462
						k = k + 1 -- 1460
					end -- 1460
				end -- 1460
				circle( -- 1464
					d, -- 1464
					cx + sway, -- 1464
					botY - 8, -- 1464
					9, -- 1464
					ink(76, 63, 48, 235), -- 1464
					6 -- 1464
				) -- 1464
			end -- 1464
			::__continue231:: -- 1464
			i = i + 1 -- 1450
		end -- 1450
	end -- 1450
	local spanNear = 900 -- 1467
	local offNear = mod(self.camX * 0.4, spanNear) -- 1468
	do -- 1468
		local i = 0 -- 1469
		while i < 2 do -- 1469
			do -- 1469
				local wx = mod(i * 470 + 300 - offNear, spanNear) - 150 -- 1470
				local gx = wx - vw / 2 -- 1471
				if gx < -140 or gx > vw / 2 + 140 then -- 1471
					goto __continue236 -- 1473
				end -- 1473
				local gy = y0 + 150 + yShift * 1.4 -- 1475
				local dir = i == 0 and 1 or -1 -- 1476
				self:drawGearShape( -- 1477
					d, -- 1477
					gx, -- 1477
					gy, -- 1477
					74, -- 1477
					9, -- 1477
					time * 0.5 * dir, -- 1477
					ink(66, 55, 42, 240), -- 1477
					ink(52, 43, 33, 240) -- 1477
				) -- 1477
				dot( -- 1478
					d, -- 1478
					gx, -- 1478
					gy, -- 1478
					5, -- 1478
					glowCyan, -- 1478
					0.5 + 0.3 * math.sin(time * 3 + i) -- 1478
				) -- 1478
				self:drawGearShape( -- 1479
					d, -- 1479
					gx + 96, -- 1479
					gy + 26, -- 1479
					40, -- 1479
					7, -- 1479
					-time * 0.5 * dir * (74 / 40), -- 1479
					ink(60, 50, 38, 235), -- 1479
					ink(48, 40, 31, 235) -- 1479
				) -- 1479
			end -- 1479
			::__continue236:: -- 1479
			i = i + 1 -- 1469
		end -- 1469
	end -- 1469
end -- 1389
function WorldRenderer.prototype.drawGearShape(self, d, cx, cy, r, teeth, angle, body, hub) -- 1484
	local verts = {} -- 1485
	local n = teeth * 2 -- 1486
	do -- 1486
		local i = 0 -- 1487
		while i < n do -- 1487
			local rr = i % 2 == 0 and r or r * 0.8 -- 1488
			local a = angle + i / n * math.pi * 2 -- 1489
			verts[#verts + 1] = Vec2( -- 1490
				cx + math.cos(a) * rr, -- 1490
				cy + math.sin(a) * rr -- 1490
			) -- 1490
			i = i + 1 -- 1487
		end -- 1487
	end -- 1487
	d:drawPolygon( -- 1492
		verts, -- 1492
		col(body), -- 1492
		0, -- 1492
		Color(0, 0, 0, 0) -- 1492
	) -- 1492
	circle( -- 1493
		d, -- 1493
		cx, -- 1493
		cy, -- 1493
		r * 0.34, -- 1493
		hub, -- 1493
		5 -- 1493
	) -- 1493
	do -- 1493
		local i = 0 -- 1494
		while i < 4 do -- 1494
			local a = angle + i * math.pi * 0.5 + math.pi * 0.25 -- 1495
			local c = math.cos(a) -- 1496
			local s = math.sin(a) -- 1497
			seg( -- 1498
				d, -- 1498
				cx + c * r * 0.3, -- 1498
				cy + s * r * 0.3, -- 1498
				cx + c * r * 0.78, -- 1498
				cy + s * r * 0.78, -- 1498
				4, -- 1498
				body -- 1498
			) -- 1498
			i = i + 1 -- 1494
		end -- 1494
	end -- 1494
end -- 1484
function WorldRenderer.prototype.drawPagoda(self, time) -- 1502
	local d = self.bgDraw -- 1503
	local vw = self.vw -- 1504
	local baseX = 1500 - self.camX * 0.7 -- 1505
	local px = baseX - vw / 2 -- 1506
	if math.abs(px) > vw / 2 + 220 then -- 1506
		return -- 1508
	end -- 1508
	local baseY = -150 - self.camY * 0.35 -- 1510
	local inkTower = ink(72, 80, 76, 190) -- 1511
	local w = 150 -- 1513
	local h = 30 -- 1514
	local cy = baseY -- 1515
	do -- 1515
		local i = 0 -- 1516
		while i < 7 do -- 1516
			local nw = w * 0.86 -- 1517
			d:drawPolygon( -- 1518
				{ -- 1519
					Vec2(px - w / 2, cy), -- 1519
					Vec2(px + w / 2, cy), -- 1519
					Vec2(px + nw / 2, cy + h), -- 1519
					Vec2(px - nw / 2, cy + h) -- 1519
				}, -- 1519
				col(inkTower), -- 1520
				0, -- 1521
				Color(0, 0, 0, 0) -- 1522
			) -- 1522
			seg( -- 1525
				d, -- 1525
				px - w / 2 - 14, -- 1525
				cy + h, -- 1525
				px + w / 2 + 14, -- 1525
				cy + h, -- 1525
				4.5, -- 1525
				inkTower -- 1525
			) -- 1525
			seg( -- 1526
				d, -- 1526
				px - w / 2 - 14, -- 1526
				cy + h, -- 1526
				px - w / 2 - 20, -- 1526
				cy + h - 7, -- 1526
				2.6, -- 1526
				inkTower -- 1526
			) -- 1526
			seg( -- 1527
				d, -- 1527
				px + w / 2 + 14, -- 1527
				cy + h, -- 1527
				px + w / 2 + 20, -- 1527
				cy + h - 7, -- 1527
				2.6, -- 1527
				inkTower -- 1527
			) -- 1527
			cy = cy + h -- 1528
			h = h * 0.92 -- 1529
			w = nw -- 1530
			i = i + 1 -- 1516
		end -- 1516
	end -- 1516
	seg( -- 1533
		d, -- 1533
		px, -- 1533
		cy, -- 1533
		px, -- 1533
		cy + 30, -- 1533
		3, -- 1533
		inkTower -- 1533
	) -- 1533
	circle( -- 1534
		d, -- 1534
		px, -- 1534
		cy + 34, -- 1534
		6, -- 1534
		inkTower, -- 1534
		10 -- 1534
	) -- 1534
	local flick = 0.6 + 0.4 * math.sin(time * 2.2) -- 1536
	do -- 1536
		local i = 0 -- 1537
		while i < 4 do -- 1537
			dot( -- 1538
				d, -- 1538
				px - 26 + i * 17, -- 1538
				baseY + 60 + i * 32, -- 1538
				2.4, -- 1538
				GOLD, -- 1538
				0.35 + 0.3 * flick -- 1538
			) -- 1538
			i = i + 1 -- 1537
		end -- 1537
	end -- 1537
end -- 1502
function WorldRenderer.prototype.drawMist(self, time) -- 1542
	local d = self.bgDraw -- 1543
	local vw = self.vw -- 1544
	local span = vw + 500 -- 1545
	do -- 1545
		local i = 0 -- 1546
		while i < 3 do -- 1546
			local speed = 12 + i * 9 -- 1547
			local bandY = -170 + i * 55 + math.sin(time * 0.3 + i * 1.7) * 8 -- 1548
			do -- 1548
				local c = 0 -- 1549
				while c < 3 do -- 1549
					local wx = time * speed + c * 460 + i * 190 -- 1550
					wx = wx % span -- 1551
					if wx < 0 then -- 1551
						wx = wx + span -- 1553
					end -- 1553
					local cx0 = wx - 250 - vw / 2 -- 1555
					do -- 1555
						local j = 0 -- 1556
						while j < 6 do -- 1556
							do -- 1556
								local jx = cx0 + j * 84 -- 1557
								if jx < -vw / 2 - 120 or jx > vw / 2 + 120 then -- 1557
									goto __continue256 -- 1559
								end -- 1559
								local jy = bandY + math.sin(jx * 0.01 + time * 0.5 + i) * 6 -- 1561
								dot( -- 1562
									d, -- 1562
									jx, -- 1562
									jy, -- 1562
									16 - i * 3, -- 1562
									Palette.paleInk, -- 1562
									0.1 + i * 0.02 -- 1562
								) -- 1562
							end -- 1562
							::__continue256:: -- 1562
							j = j + 1 -- 1556
						end -- 1556
					end -- 1556
					c = c + 1 -- 1549
				end -- 1549
			end -- 1549
			i = i + 1 -- 1546
		end -- 1546
	end -- 1546
end -- 1542
function WorldRenderer.prototype.drawWaterFront(self, time) -- 1568
	local d = self.bgDraw -- 1569
	local vw = self.vw -- 1570
	local bot = -self.vh / 2 -- 1571
	local top = bot + 46 -- 1572
	d:drawPolygon( -- 1573
		{ -- 1574
			Vec2(-vw / 2 - 4, bot - 4), -- 1574
			Vec2(vw / 2 + 8, bot - 4), -- 1574
			Vec2(vw / 2 + 8, top), -- 1574
			Vec2(-vw / 2 - 4, top) -- 1574
		}, -- 1574
		col(ink(90, 110, 105, 26)), -- 1575
		0, -- 1576
		Color(0, 0, 0, 0) -- 1577
	) -- 1577
	do -- 1577
		local i = 0 -- 1579
		while i < 3 do -- 1579
			local wy = bot + 12 + i * 12 -- 1580
			do -- 1580
				local sx = -vw / 2 -- 1581
				while sx < vw / 2 do -- 1581
					seg( -- 1582
						d, -- 1583
						sx, -- 1584
						wy + waveY(sx, time, i), -- 1585
						sx + 46, -- 1586
						wy + waveY(sx + 46, time, i), -- 1587
						1.6, -- 1588
						i == 0 and CYAN or Palette.paleInk, -- 1589
						0.22 + i * 0.06 -- 1590
					) -- 1590
					sx = sx + 46 -- 1581
				end -- 1581
			end -- 1581
			i = i + 1 -- 1579
		end -- 1579
	end -- 1579
end -- 1568
function WorldRenderer.prototype.drawTerrain(self, time) -- 1597
	local d = self.platformDraw -- 1598
	d:clear() -- 1599
	for ____, p in ipairs(self.data.platforms) do -- 1600
		do -- 1600
			if p.kind == "gate" then -- 1600
				goto __continue264 -- 1602
			end -- 1602
			if self:floorOfY(p.y + p.h) ~= self.activeFloor then -- 1602
				goto __continue264 -- 1606
			end -- 1606
			if not self:inView(p.x, p.y - 60, p.x + p.w, p.y + p.h + 60) then -- 1606
				goto __continue264 -- 1609
			end -- 1609
			if p.mover ~= nil then -- 1609
				self:drawMover(d, p, time) -- 1612
				goto __continue264 -- 1613
			end -- 1613
			if p.kind == "solid" then -- 1613
				if p.w >= 300 then -- 1613
					d:drawPolygon( -- 1618
						{ -- 1619
							Vec2(p.x + 5, p.y + p.h), -- 1620
							Vec2(p.x + p.w - 5, p.y + p.h), -- 1621
							Vec2(p.x + p.w - 1, p.y + 1), -- 1622
							Vec2(p.x + 1, p.y + 1) -- 1623
						}, -- 1623
						col(ink(38, 45, 44, 225)), -- 1625
						0, -- 1626
						Color(0, 0, 0, 0) -- 1627
					) -- 1627
					seg( -- 1629
						d, -- 1629
						p.x + 4, -- 1629
						p.y + p.h - 1, -- 1629
						p.x + p.w - 4, -- 1629
						p.y + p.h - 1, -- 1629
						2, -- 1629
						PAPER_DIM -- 1629
					) -- 1629
					local crackX = p.x + 30 + p.x % math.max(60, p.w - 90) -- 1630
					seg( -- 1631
						d, -- 1631
						crackX, -- 1631
						p.y + p.h - 8, -- 1631
						crackX + 22, -- 1631
						p.y + 8, -- 1631
						1.4, -- 1631
						ink(26, 32, 31, 80) -- 1631
					) -- 1631
				else -- 1631
					d:drawPolygon( -- 1634
						{ -- 1635
							Vec2(p.x, p.y + p.h), -- 1636
							Vec2(p.x + p.w, p.y + p.h), -- 1637
							Vec2(p.x + p.w, p.y + 2), -- 1638
							Vec2(p.x, p.y + 2) -- 1639
						}, -- 1639
						col(ink(96, 70, 48, 220)), -- 1641
						0, -- 1642
						Color(0, 0, 0, 0) -- 1643
					) -- 1643
					seg( -- 1645
						d, -- 1645
						p.x + 2, -- 1645
						p.y + p.h - 1, -- 1645
						p.x + p.w - 2, -- 1645
						p.y + p.h - 1, -- 1645
						1.8, -- 1645
						ink(158, 120, 84, 150) -- 1645
					) -- 1645
					dot( -- 1646
						d, -- 1646
						p.x + 5, -- 1646
						p.y + p.h - 5, -- 1646
						1.6, -- 1646
						Palette.inkDark, -- 1646
						0.75 -- 1646
					) -- 1646
					dot( -- 1647
						d, -- 1647
						p.x + p.w - 5, -- 1647
						p.y + p.h - 5, -- 1647
						1.6, -- 1647
						Palette.inkDark, -- 1647
						0.75 -- 1647
					) -- 1647
				end -- 1647
			else -- 1647
				d:drawPolygon( -- 1651
					{ -- 1652
						Vec2(p.x, p.y + p.h), -- 1653
						Vec2(p.x + p.w, p.y + p.h), -- 1654
						Vec2(p.x + p.w, p.y + p.h - 8), -- 1655
						Vec2(p.x, p.y + p.h - 8) -- 1656
					}, -- 1656
					col(ink(110, 82, 56, 200)), -- 1658
					0, -- 1659
					Color(0, 0, 0, 0) -- 1660
				) -- 1660
				seg( -- 1662
					d, -- 1662
					p.x + 2, -- 1662
					p.y + p.h - 1, -- 1662
					p.x + p.w - 2, -- 1662
					p.y + p.h - 1, -- 1662
					1.5, -- 1662
					PAPER_DIM -- 1662
				) -- 1662
			end -- 1662
		end -- 1662
		::__continue264:: -- 1662
	end -- 1662
	for ____, l in ipairs(self.data.ladders) do -- 1665
		do -- 1665
			if l.floor ~= self.activeFloor then -- 1665
				goto __continue274 -- 1667
			end -- 1667
			if not self:inView(l.x, l.y, l.x + l.w, l.y + l.h) then -- 1667
				goto __continue274 -- 1670
			end -- 1670
			local wood = ink(84, 66, 44, 235) -- 1672
			seg( -- 1673
				d, -- 1673
				l.x + 2, -- 1673
				l.y, -- 1673
				l.x + 2, -- 1673
				l.y + l.h, -- 1673
				3, -- 1673
				wood -- 1673
			) -- 1673
			seg( -- 1674
				d, -- 1674
				l.x + l.w - 2, -- 1674
				l.y, -- 1674
				l.x + l.w - 2, -- 1674
				l.y + l.h, -- 1674
				3, -- 1674
				wood -- 1674
			) -- 1674
			do -- 1674
				local ry = l.y + 10 -- 1675
				while ry < l.y + l.h - 4 do -- 1675
					seg( -- 1676
						d, -- 1676
						l.x + 4, -- 1676
						ry, -- 1676
						l.x + l.w - 4, -- 1676
						ry, -- 1676
						2.4, -- 1676
						ink(102, 80, 52, 220) -- 1676
					) -- 1676
					ry = ry + 18 -- 1675
				end -- 1675
			end -- 1675
		end -- 1675
		::__continue274:: -- 1675
	end -- 1675
	for ____, cw in ipairs(self.data.climbWalls) do -- 1679
		do -- 1679
			if self:floorOfY(cw.y + cw.h) ~= self.activeFloor then -- 1679
				goto __continue280 -- 1681
			end -- 1681
			if not self:inView(cw.x, cw.y, cw.x + cw.w, cw.y + cw.h) then -- 1681
				goto __continue280 -- 1684
			end -- 1684
			local crag = ink(64, 58, 52, 200) -- 1686
			seg( -- 1687
				d, -- 1687
				cw.x, -- 1687
				cw.y + cw.h, -- 1687
				cw.x + cw.w, -- 1687
				cw.y + cw.h, -- 1687
				3, -- 1687
				crag -- 1687
			) -- 1687
			do -- 1687
				local i = 0 -- 1688
				while i <= 4 do -- 1688
					local xx = cw.x + 6 + i * (cw.w - 12) / 4 -- 1689
					seg( -- 1690
						d, -- 1690
						xx, -- 1690
						cw.y + cw.h, -- 1690
						xx + 7, -- 1690
						cw.y + cw.h * 0.55, -- 1690
						3.4, -- 1690
						crag -- 1690
					) -- 1690
					seg( -- 1691
						d, -- 1691
						xx + 7, -- 1691
						cw.y + cw.h * 0.55, -- 1691
						xx + 2, -- 1691
						cw.y + 4, -- 1691
						2.6, -- 1691
						ink(64, 58, 52, 130) -- 1691
					) -- 1691
					i = i + 1 -- 1688
				end -- 1688
			end -- 1688
		end -- 1688
		::__continue280:: -- 1688
	end -- 1688
end -- 1597
function WorldRenderer.prototype.drawMover(self, d, p, time) -- 1696
	local m = p.mover -- 1697
	if m == nil then -- 1697
		return -- 1699
	end -- 1699
	local x = p.x -- 1705
	local y = p.y -- 1706
	do -- 1706
		local i = 0 -- 1708
		while i < 8 do -- 1708
			local t0 = i / 8 + 0.02 -- 1709
			local t1 = t0 + 0.06 -- 1710
			seg( -- 1711
				d, -- 1712
				m.ax + (m.bx - m.ax) * t0 + p.w / 2, -- 1713
				m.ay + (m.by - m.ay) * t0 + p.h / 2, -- 1714
				m.ax + (m.bx - m.ax) * t1 + p.w / 2, -- 1715
				m.ay + (m.by - m.ay) * t1 + p.h / 2, -- 1716
				2, -- 1717
				PAPER_DIM -- 1718
			) -- 1718
			i = i + 1 -- 1708
		end -- 1708
	end -- 1708
	d:drawPolygon( -- 1721
		{ -- 1722
			Vec2(x, y + p.h), -- 1722
			Vec2(x + p.w, y + p.h), -- 1722
			Vec2(x + p.w, y + 2), -- 1722
			Vec2(x, y + 2) -- 1722
		}, -- 1722
		col(ink(52, 60, 58, 230)), -- 1723
		0, -- 1724
		Color(0, 0, 0, 0) -- 1725
	) -- 1725
	seg( -- 1727
		d, -- 1727
		x + 2, -- 1727
		y + p.h - 1, -- 1727
		x + p.w - 2, -- 1727
		y + p.h - 1, -- 1727
		1.8, -- 1727
		PAPER_DIM -- 1727
	) -- 1727
	dot( -- 1728
		d, -- 1728
		x + p.w / 2, -- 1728
		y + p.h / 2, -- 1728
		4 + math.sin(time * 3) * 1, -- 1728
		GOLD, -- 1728
		0.85 -- 1728
	) -- 1728
end -- 1696
function WorldRenderer.prototype.drawProps(self, time, state) -- 1732
	local d = self.propDraw -- 1733
	d:clear() -- 1734
	self:drawGates(d, state) -- 1735
	self:drawRopes(d, time, state) -- 1736
	self:drawBells(d, time, state) -- 1737
	self:drawPlates(d, time, state) -- 1738
	self:drawSwordSlots(d, time, state) -- 1739
	self:drawWindSigils(d, time, state) -- 1740
	self:drawStarNodes(d, time, state) -- 1741
	self:drawLanterns(d, time, state) -- 1742
	self:drawCheckpoints(d, time, state) -- 1743
	self:drawCollectibles(d, time, state) -- 1744
	self:drawDecor(d, time) -- 1745
end -- 1732
function WorldRenderer.prototype.drawGates(self, d, state) -- 1748
	for ____, gp in ipairs(self.gateParts) do -- 1749
		do -- 1749
			if #gp.rects == 0 then -- 1749
				goto __continue292 -- 1751
			end -- 1751
			local open = state.openedGates[gp.gid] == true -- 1753
			local x0 = 1000000000 -- 1754
			local y0 = 1000000000 -- 1755
			local x1 = -1000000000 -- 1756
			local y1 = -1000000000 -- 1757
			for ____, r in ipairs(gp.rects) do -- 1758
				x0 = math.min(x0, r.x) -- 1759
				y0 = math.min(y0, r.y) -- 1760
				x1 = math.max(x1, r.x + r.w) -- 1761
				y1 = math.max(y1, r.y + r.h) -- 1762
			end -- 1762
			if self:floorOfY(y1) ~= self.activeFloor then -- 1762
				goto __continue292 -- 1765
			end -- 1765
			if not self:inView(x0, y0, x1, y1) then -- 1765
				goto __continue292 -- 1768
			end -- 1768
			local postC = ink(52, 46, 38, 235) -- 1771
			for ____, r in ipairs(gp.rects) do -- 1772
				local isPost = r.w <= 14 or r.h >= (y1 - y0) * 0.9 -- 1773
				if not open or isPost then -- 1773
					d:drawPolygon( -- 1775
						{ -- 1776
							Vec2(r.x, r.y + r.h), -- 1776
							Vec2(r.x + r.w, r.y + r.h), -- 1776
							Vec2(r.x + r.w, r.y), -- 1776
							Vec2(r.x, r.y) -- 1776
						}, -- 1776
						col(isPost and postC or ink(64, 58, 50, 220)), -- 1777
						0, -- 1778
						Color(0, 0, 0, 0) -- 1779
					) -- 1779
				end -- 1779
			end -- 1779
			seg( -- 1784
				d, -- 1784
				x0 - 6, -- 1784
				y1 + 4, -- 1784
				x1 + 6, -- 1784
				y1 + 4, -- 1784
				4, -- 1784
				postC -- 1784
			) -- 1784
			seg( -- 1785
				d, -- 1785
				x0 - 6, -- 1785
				y1 + 8, -- 1785
				x1 + 6, -- 1785
				y1 + 8, -- 1785
				1.6, -- 1785
				GOLD, -- 1785
				0.5 -- 1785
			) -- 1785
			if not open then -- 1785
				do -- 1785
					local i = 1 -- 1788
					while i <= 3 do -- 1788
						local sx = x0 + (x1 - x0) * i / 4 -- 1789
						seg( -- 1790
							d, -- 1790
							sx - 10, -- 1790
							y0 + 6, -- 1790
							sx + 10, -- 1790
							y1 - 6, -- 1790
							1.8, -- 1790
							ink(84, 76, 62, 180) -- 1790
						) -- 1790
						i = i + 1 -- 1788
					end -- 1788
				end -- 1788
			end -- 1788
		end -- 1788
		::__continue292:: -- 1788
	end -- 1788
end -- 1748
function WorldRenderer.prototype.drawRopes(self, d, time, state) -- 1796
	for ____, r in ipairs(self.data.ropes) do -- 1797
		do -- 1797
			if self:floorOfY(r.y) ~= self.activeFloor then -- 1797
				goto __continue306 -- 1799
			end -- 1799
			if not self:inView(r.x - 30, r.y - r.length - 30, r.x + 30, r.y + 10) then -- 1799
				goto __continue306 -- 1802
			end -- 1802
			if state.cutRopes[r.id] == true then -- 1802
				seg( -- 1806
					d, -- 1806
					r.x, -- 1806
					r.y, -- 1806
					r.x - 2, -- 1806
					r.y - 12, -- 1806
					3, -- 1806
					Palette.inkDark, -- 1806
					0.9 -- 1806
				) -- 1806
				local fall = math.min(r.length * 0.5, 60) -- 1807
				do -- 1807
					local i = 0 -- 1808
					while i < 4 do -- 1808
						local yy0 = r.y - 12 - i * fall / 4 -- 1809
						local yy1 = r.y - 12 - (i + 1) * fall / 4 -- 1810
						local sway = math.sin(time * 2.4 + i) * 3 -- 1811
						seg( -- 1812
							d, -- 1812
							r.x - 2 + sway * 0.5, -- 1812
							yy0, -- 1812
							r.x - 4 + sway, -- 1812
							yy1, -- 1812
							2.2, -- 1812
							Palette.inkSoft, -- 1812
							0.5 - i * 0.1 -- 1812
						) -- 1812
						i = i + 1 -- 1808
					end -- 1808
				end -- 1808
			else -- 1808
				local px = r.x -- 1816
				local py = r.y -- 1817
				do -- 1817
					local i = 1 -- 1818
					while i <= 8 do -- 1818
						local tt = i / 8 -- 1819
						local yy = r.y - r.length * tt -- 1820
						local sway = math.sin(time * 1.6 + tt * 3 + r.x * 0.05) * 4 * tt -- 1821
						local nx = r.x + sway -- 1822
						seg( -- 1823
							d, -- 1823
							px, -- 1823
							py, -- 1823
							nx, -- 1823
							yy, -- 1823
							2.6, -- 1823
							Palette.inkDark, -- 1823
							0.92 -- 1823
						) -- 1823
						px = nx -- 1824
						py = yy -- 1825
						i = i + 1 -- 1818
					end -- 1818
				end -- 1818
				dot( -- 1827
					d, -- 1827
					px, -- 1827
					py, -- 1827
					3, -- 1827
					Palette.inkDark, -- 1827
					0.9 -- 1827
				) -- 1827
			end -- 1827
		end -- 1827
		::__continue306:: -- 1827
	end -- 1827
end -- 1796
function WorldRenderer.prototype.drawBells(self, d, time, state) -- 1832
	for ____, b in ipairs(self.data.bells) do -- 1833
		do -- 1833
			if self:floorOfY(b.y) ~= self.activeFloor then -- 1833
				goto __continue317 -- 1835
			end -- 1835
			if not self:inView(b.x - 40, b.y, b.x + 40, b.y + 60) then -- 1835
				goto __continue317 -- 1838
			end -- 1838
			local frame = ink(58, 50, 40, 230) -- 1840
			seg( -- 1841
				d, -- 1841
				b.x - 20, -- 1841
				b.y, -- 1841
				b.x - 20, -- 1841
				b.y + 46, -- 1841
				3.5, -- 1841
				frame -- 1841
			) -- 1841
			seg( -- 1842
				d, -- 1842
				b.x + 20, -- 1842
				b.y, -- 1842
				b.x + 20, -- 1842
				b.y + 46, -- 1842
				3.5, -- 1842
				frame -- 1842
			) -- 1842
			seg( -- 1843
				d, -- 1843
				b.x - 26, -- 1843
				b.y + 46, -- 1843
				b.x + 26, -- 1843
				b.y + 46, -- 1843
				3.5, -- 1843
				frame -- 1843
			) -- 1843
			d:drawPolygon( -- 1844
				{ -- 1845
					Vec2(b.x - 13, b.y + 44), -- 1845
					Vec2(b.x + 13, b.y + 44), -- 1845
					Vec2(b.x + 16, b.y + 24), -- 1845
					Vec2(b.x - 16, b.y + 24) -- 1845
				}, -- 1845
				col(ink(46, 52, 50, 235)), -- 1846
				0, -- 1847
				Color(0, 0, 0, 0) -- 1848
			) -- 1848
			seg( -- 1850
				d, -- 1850
				b.x - 17, -- 1850
				b.y + 24, -- 1850
				b.x + 17, -- 1850
				b.y + 24, -- 1850
				2, -- 1850
				GOLD, -- 1850
				0.5 -- 1850
			) -- 1850
			dot( -- 1851
				d, -- 1851
				b.x, -- 1851
				b.y + 21, -- 1851
				2.2, -- 1851
				GOLD, -- 1851
				0.8 -- 1851
			) -- 1851
			if state.rungBells[b.id] == true then -- 1851
				local pulse = time * 0.9 % 1 -- 1853
				local pulse2 = (pulse + 0.5) % 1 -- 1854
				circle( -- 1855
					d, -- 1855
					b.x, -- 1855
					b.y + 30, -- 1855
					10 + pulse * 46, -- 1855
					GOLD, -- 1855
					18, -- 1855
					(1 - pulse) * 0.8 -- 1855
				) -- 1855
				circle( -- 1856
					d, -- 1856
					b.x, -- 1856
					b.y + 30, -- 1856
					10 + pulse2 * 46, -- 1856
					GOLD, -- 1856
					18, -- 1856
					(1 - pulse2) * 0.5 -- 1856
				) -- 1856
			end -- 1856
		end -- 1856
		::__continue317:: -- 1856
	end -- 1856
end -- 1832
function WorldRenderer.prototype.drawPlates(self, d, time, state) -- 1861
	for ____, pl in ipairs(self.data.plates) do -- 1862
		do -- 1862
			if self:floorOfY(pl.y) ~= self.activeFloor then -- 1862
				goto __continue323 -- 1864
			end -- 1864
			if not self:inView(pl.x - 44, pl.y, pl.x + 44, pl.y + 16) then -- 1864
				goto __continue323 -- 1867
			end -- 1867
			local on = state.platesActive[pl.id] == true -- 1869
			local sink = on and 4 or 0 -- 1870
			d:drawPolygon( -- 1871
				{ -- 1872
					Vec2(pl.x - 36, pl.y + 10 - sink), -- 1873
					Vec2(pl.x + 36, pl.y + 10 - sink), -- 1874
					Vec2(pl.x + 32, pl.y + 2 - sink), -- 1875
					Vec2(pl.x - 32, pl.y + 2 - sink) -- 1876
				}, -- 1876
				col(ink(on and 30 or 42, on and 36 or 50, on and 34 or 48, 235)), -- 1878
				0, -- 1879
				Color(0, 0, 0, 0) -- 1880
			) -- 1880
			if on then -- 1880
				seg( -- 1883
					d, -- 1883
					pl.x - 36, -- 1883
					pl.y + 11 - sink, -- 1883
					pl.x + 36, -- 1883
					pl.y + 11 - sink, -- 1883
					1.6, -- 1883
					GOLD, -- 1883
					0.55 + 0.25 * math.sin(time * 6) -- 1883
				) -- 1883
			else -- 1883
				seg( -- 1885
					d, -- 1885
					pl.x - 32, -- 1885
					pl.y + 10, -- 1885
					pl.x + 32, -- 1885
					pl.y + 10, -- 1885
					1.2, -- 1885
					PAPER_DIM -- 1885
				) -- 1885
			end -- 1885
		end -- 1885
		::__continue323:: -- 1885
	end -- 1885
end -- 1861
function WorldRenderer.prototype.drawSwordSlots(self, d, time, state) -- 1891
	local slots = self.data.swordSlots -- 1892
	if slots == nil then -- 1892
		return -- 1894
	end -- 1894
	for ____, slot in ipairs(slots) do -- 1896
		do -- 1896
			if self:floorOfY(slot.y) ~= self.activeFloor then -- 1896
				goto __continue331 -- 1898
			end -- 1898
			if not self:inView(slot.x - 44, slot.y, slot.x + 44, slot.y + 110) then -- 1898
				goto __continue331 -- 1901
			end -- 1901
			local inserted = state.flags["swordslot_" .. slot.id] == true -- 1903
			d:drawPolygon( -- 1905
				{ -- 1906
					Vec2(slot.x - 24, slot.y + 12), -- 1906
					Vec2(slot.x + 24, slot.y + 12), -- 1906
					Vec2(slot.x + 20, slot.y), -- 1906
					Vec2(slot.x - 20, slot.y) -- 1906
				}, -- 1906
				col(ink(58, 54, 48, 235)), -- 1907
				0, -- 1908
				Color(0, 0, 0, 0) -- 1909
			) -- 1909
			seg( -- 1911
				d, -- 1911
				slot.x - 20, -- 1911
				slot.y + 12, -- 1911
				slot.x + 20, -- 1911
				slot.y + 12, -- 1911
				1.6, -- 1911
				PAPER_DIM, -- 1911
				0.8 -- 1911
			) -- 1911
			d:drawPolygon( -- 1913
				{ -- 1914
					Vec2(slot.x - 3.5, slot.y + 58), -- 1914
					Vec2(slot.x + 3.5, slot.y + 58), -- 1914
					Vec2(slot.x + 3.5, slot.y + 10), -- 1914
					Vec2(slot.x - 3.5, slot.y + 10) -- 1914
				}, -- 1914
				col(ink(28, 26, 23, 240)), -- 1915
				0, -- 1916
				Color(0, 0, 0, 0) -- 1917
			) -- 1917
			seg( -- 1919
				d, -- 1919
				slot.x - 3.5, -- 1919
				slot.y + 34, -- 1919
				slot.x - 3.5, -- 1919
				slot.y + 56, -- 1919
				1.2, -- 1919
				GOLD, -- 1919
				inserted and 0.9 or 0.4 -- 1919
			) -- 1919
			seg( -- 1920
				d, -- 1920
				slot.x + 3.5, -- 1920
				slot.y + 34, -- 1920
				slot.x + 3.5, -- 1920
				slot.y + 56, -- 1920
				1.2, -- 1920
				GOLD, -- 1920
				inserted and 0.9 or 0.4 -- 1920
			) -- 1920
			if inserted then -- 1920
				local glow = 0.75 + 0.25 * math.sin(time * 2.2) -- 1923
				d:drawPolygon( -- 1924
					{ -- 1925
						Vec2(slot.x - 4, slot.y + 62), -- 1925
						Vec2(slot.x + 4, slot.y + 62), -- 1925
						Vec2(slot.x + 2.4, slot.y + 16), -- 1925
						Vec2(slot.x - 2.4, slot.y + 16) -- 1925
					}, -- 1925
					col(ink(198, 204, 196, 235)), -- 1926
					0, -- 1927
					Color(0, 0, 0, 0) -- 1928
				) -- 1928
				d:drawPolygon( -- 1930
					{ -- 1931
						Vec2(slot.x - 4, slot.y + 62), -- 1931
						Vec2(slot.x, slot.y + 62), -- 1931
						Vec2(slot.x, slot.y + 16), -- 1931
						Vec2(slot.x - 2.4, slot.y + 16) -- 1931
					}, -- 1931
					col(ink(236, 240, 232, 120)), -- 1932
					0, -- 1933
					Color(0, 0, 0, 0) -- 1934
				) -- 1934
				seg( -- 1936
					d, -- 1936
					slot.x - 12, -- 1936
					slot.y + 58, -- 1936
					slot.x + 12, -- 1936
					slot.y + 58, -- 1936
					4, -- 1936
					GOLD, -- 1936
					0.95 -- 1936
				) -- 1936
				seg( -- 1937
					d, -- 1937
					slot.x - 12, -- 1937
					slot.y + 56.4, -- 1937
					slot.x + 12, -- 1937
					slot.y + 56.4, -- 1937
					1.2, -- 1937
					ink(120, 92, 44, 220), -- 1937
					0.8 -- 1937
				) -- 1937
				seg( -- 1938
					d, -- 1938
					slot.x, -- 1938
					slot.y + 56, -- 1938
					slot.x, -- 1938
					slot.y + 44, -- 1938
					3.2, -- 1938
					ink(74, 58, 40, 235), -- 1938
					0.95 -- 1938
				) -- 1938
				dot( -- 1939
					d, -- 1939
					slot.x, -- 1939
					slot.y + 42.5, -- 1939
					3, -- 1939
					GOLD, -- 1939
					glow -- 1939
				) -- 1939
				dot( -- 1940
					d, -- 1940
					slot.x, -- 1940
					slot.y + 70, -- 1940
					10, -- 1940
					Palette.moonWhite, -- 1940
					0.04 + 0.05 * glow -- 1940
				) -- 1940
			end -- 1940
		end -- 1940
		::__continue331:: -- 1940
	end -- 1940
end -- 1891
function WorldRenderer.prototype.drawWindSigils(self, d, time, state) -- 1946
	do -- 1946
		local i = 0 -- 1947
		while i < #self.data.windSigils do -- 1947
			do -- 1947
				local s = self.data.windSigils[i + 1] -- 1948
				if self:floorOfY(s.y) ~= self.activeFloor or not self:inView(s.x - 60, s.y - 10, s.x + 60, s.y + 110) then -- 1948
					goto __continue338 -- 1950
				end -- 1950
				local on = state.flags["wind_" .. s.id] == true -- 1952
				local cy = s.y + 34 -- 1953
				circle( -- 1954
					d, -- 1954
					s.x, -- 1954
					cy, -- 1954
					26, -- 1954
					ink(58, 54, 48, 200), -- 1954
					3, -- 1954
					0.9 -- 1954
				) -- 1954
				local spin = on and time * 1.6 or 0 -- 1955
				do -- 1955
					local k = 0 -- 1956
					while k < 3 do -- 1956
						local a = spin + k * math.pi * 2 / 3 -- 1957
						local ax = s.x + math.cos(a) * 13 -- 1958
						local ay = cy + math.sin(a) * 11 -- 1959
						local bx = s.x + math.cos(a + 0.9) * 23 -- 1960
						local by = cy + math.sin(a + 0.9) * 19 -- 1961
						seg( -- 1962
							d, -- 1962
							ax, -- 1962
							ay, -- 1962
							bx, -- 1962
							by, -- 1962
							2.6, -- 1962
							on and CYAN or PAPER_DIM, -- 1962
							on and 0.95 or 0.7 -- 1962
						) -- 1962
						k = k + 1 -- 1956
					end -- 1956
				end -- 1956
				dot( -- 1964
					d, -- 1964
					s.x, -- 1964
					cy, -- 1964
					on and 5 or 3, -- 1964
					on and CYAN or PAPER_DIM, -- 1964
					on and 0.95 or 0.8 -- 1964
				) -- 1964
				if on then -- 1964
					do -- 1964
						local k = 0 -- 1966
						while k < 3 do -- 1966
							local t = (time * 0.7 + k / 3) % 1 -- 1967
							dot( -- 1968
								d, -- 1968
								s.x + math.sin((t * 6 + k) * 2) * 8, -- 1968
								s.y + 20 + t * 56, -- 1968
								2.4, -- 1968
								CYAN, -- 1968
								(1 - t) * 0.7 -- 1968
							) -- 1968
							k = k + 1 -- 1966
						end -- 1966
					end -- 1966
					local pulse = time * 0.9 % 1 -- 1970
					circle( -- 1971
						d, -- 1971
						s.x, -- 1971
						cy, -- 1971
						20 + pulse * 40, -- 1971
						CYAN, -- 1971
						14, -- 1971
						(1 - pulse) * 0.5 -- 1971
					) -- 1971
				end -- 1971
			end -- 1971
			::__continue338:: -- 1971
			i = i + 1 -- 1947
		end -- 1947
	end -- 1947
end -- 1946
function WorldRenderer.prototype.drawStarNodes(self, d, time, state) -- 1977
	local nodes = self.data.starNodes -- 1978
	do -- 1978
		local i = 0 -- 1979
		while i < #nodes - 1 do -- 1979
			do -- 1979
				local a = nodes[i + 1] -- 1980
				local b = nodes[i + 1 + 1] -- 1981
				if self:floorOfY(a.y) ~= self.activeFloor or self:floorOfY(b.y) ~= self.activeFloor then -- 1981
					goto __continue347 -- 1983
				end -- 1983
				if state.flags["star_" .. a.id] == true and state.flags["star_" .. b.id] == true then -- 1983
					local pulse = 0.5 + 0.25 * math.sin(time * 2.4 + i) -- 1986
					seg( -- 1987
						d, -- 1987
						a.x, -- 1987
						a.y + 58, -- 1987
						b.x, -- 1987
						b.y + 58, -- 1987
						1.6, -- 1987
						Palette.moonWhite, -- 1987
						pulse -- 1987
					) -- 1987
				end -- 1987
			end -- 1987
			::__continue347:: -- 1987
			i = i + 1 -- 1979
		end -- 1979
	end -- 1979
	do -- 1979
		local i = 0 -- 1990
		while i < #nodes do -- 1990
			do -- 1990
				local s = nodes[i + 1] -- 1991
				if self:floorOfY(s.y) ~= self.activeFloor or not self:inView(s.x - 44, s.y - 20, s.x + 44, s.y + 110) then -- 1991
					goto __continue351 -- 1993
				end -- 1993
				local lit = state.flags["star_" .. s.id] == true -- 1995
				seg( -- 1996
					d, -- 1996
					s.x, -- 1996
					s.y, -- 1996
					s.x, -- 1996
					s.y + 40, -- 1996
					4, -- 1996
					ink(70, 60, 46, 235) -- 1996
				) -- 1996
				seg( -- 1997
					d, -- 1997
					s.x - 9, -- 1997
					s.y + 40, -- 1997
					s.x + 9, -- 1997
					s.y + 40, -- 1997
					3, -- 1997
					ink(70, 60, 46, 235) -- 1997
				) -- 1997
				local cy = s.y + 58 -- 1998
				local c = lit and Palette.moonWhite or PAPER_DIM -- 1999
				local tw = lit and 0.75 + 0.25 * math.sin(time * 3 + i * 1.7) or 0.5 -- 2000
				local r = lit and 12 or 7 -- 2001
				seg( -- 2002
					d, -- 2002
					s.x - r, -- 2002
					cy, -- 2002
					s.x + r, -- 2002
					cy, -- 2002
					1.8, -- 2002
					c, -- 2002
					tw -- 2002
				) -- 2002
				seg( -- 2003
					d, -- 2003
					s.x, -- 2003
					cy - r, -- 2003
					s.x, -- 2003
					cy + r, -- 2003
					1.8, -- 2003
					c, -- 2003
					tw -- 2003
				) -- 2003
				dot( -- 2004
					d, -- 2004
					s.x, -- 2004
					cy, -- 2004
					lit and 5.5 or 3, -- 2004
					c, -- 2004
					tw -- 2004
				) -- 2004
				if lit then -- 2004
					dot( -- 2006
						d, -- 2006
						s.x, -- 2006
						cy, -- 2006
						15, -- 2006
						Palette.moonWhite, -- 2006
						0.06 -- 2006
					) -- 2006
				end -- 2006
			end -- 2006
			::__continue351:: -- 2006
			i = i + 1 -- 1990
		end -- 1990
	end -- 1990
end -- 1977
function WorldRenderer.prototype.drawLanterns(self, d, time, state) -- 2011
	for ____, ln in ipairs(self.data.lanterns) do -- 2012
		do -- 2012
			if self:floorOfY(ln.y) ~= self.activeFloor then -- 2012
				goto __continue355 -- 2014
			end -- 2014
			if not self:inView(ln.x - 30, ln.y, ln.x + 30, ln.y + 76) then -- 2014
				goto __continue355 -- 2017
			end -- 2017
			local pole = ink(70, 60, 46, 235) -- 2019
			seg( -- 2020
				d, -- 2020
				ln.x, -- 2020
				ln.y, -- 2020
				ln.x, -- 2020
				ln.y + 60, -- 2020
				4, -- 2020
				pole -- 2020
			) -- 2020
			seg( -- 2021
				d, -- 2021
				ln.x - 11, -- 2021
				ln.y + 60, -- 2021
				ln.x + 11, -- 2021
				ln.y + 60, -- 2021
				3, -- 2021
				pole -- 2021
			) -- 2021
			seg( -- 2022
				d, -- 2022
				ln.x, -- 2022
				ln.y + 60, -- 2022
				ln.x, -- 2022
				ln.y + 58, -- 2022
				1.6, -- 2022
				pole -- 2022
			) -- 2022
			local bx = ln.x -- 2023
			local by = ln.y + 46 -- 2024
			local lit = state.lanternsLit[ln.id] == true -- 2025
			local alpha = 1 -- 2026
			if state.lanternFailed then -- 2026
				local flash = 0.5 + 0.5 * math.sin(time * 9) -- 2028
				alpha = lit and 0.5 + 0.5 * flash or 0.35 -- 2029
			end -- 2029
			if lit then -- 2029
				dot( -- 2032
					d, -- 2032
					bx, -- 2032
					by, -- 2032
					17, -- 2032
					ink(244, 196, 120, 42), -- 2032
					alpha -- 2032
				) -- 2032
				d:drawPolygon( -- 2033
					{ -- 2034
						Vec2(bx - 9, by + 11), -- 2034
						Vec2(bx + 9, by + 11), -- 2034
						Vec2(bx + 7.5, by - 11), -- 2034
						Vec2(bx - 7.5, by - 11) -- 2034
					}, -- 2034
					col( -- 2035
						ink(238, 178, 92, 150), -- 2035
						alpha -- 2035
					), -- 2035
					0, -- 2036
					Color(0, 0, 0, 0) -- 2037
				) -- 2037
				dot( -- 2039
					d, -- 2039
					bx, -- 2039
					by, -- 2039
					5, -- 2039
					ink(255, 232, 180, 220), -- 2039
					alpha -- 2039
				) -- 2039
			else -- 2039
				d:drawPolygon( -- 2041
					{ -- 2042
						Vec2(bx - 9, by + 11), -- 2042
						Vec2(bx + 9, by + 11), -- 2042
						Vec2(bx + 7.5, by - 11), -- 2042
						Vec2(bx - 7.5, by - 11) -- 2042
					}, -- 2042
					col(ink(58, 62, 60, 200)), -- 2043
					0, -- 2044
					Color(0, 0, 0, 0) -- 2045
				) -- 2045
			end -- 2045
			seg( -- 2048
				d, -- 2048
				bx - 9, -- 2048
				by + 11, -- 2048
				bx + 9, -- 2048
				by + 11, -- 2048
				2, -- 2048
				ink(120, 84, 44, 235), -- 2048
				alpha -- 2048
			) -- 2048
			seg( -- 2049
				d, -- 2049
				bx - 7.5, -- 2049
				by - 11, -- 2049
				bx + 7.5, -- 2049
				by - 11, -- 2049
				2, -- 2049
				ink(120, 84, 44, 235), -- 2049
				alpha -- 2049
			) -- 2049
			if state.lanternFailed and lit then -- 2049
				dot( -- 2051
					d, -- 2051
					bx, -- 2051
					by, -- 2051
					8, -- 2051
					ink(140, 59, 59, 90), -- 2051
					alpha -- 2051
				) -- 2051
			end -- 2051
		end -- 2051
		::__continue355:: -- 2051
	end -- 2051
end -- 2011
function WorldRenderer.prototype.drawCheckpoints(self, d, time, state) -- 2056
	for ____, cp in ipairs(self.data.checkpoints) do -- 2057
		do -- 2057
			if self:floorOfY(cp.y) ~= self.activeFloor then -- 2057
				goto __continue364 -- 2059
			end -- 2059
			if not self:inView(cp.x - 60, cp.y, cp.x + 60, cp.y + 90) then -- 2059
				goto __continue364 -- 2062
			end -- 2062
			if cp.id == "cp_riverbank" then -- 2062
				goto __continue364 -- 2065
			end -- 2065
			local active = state.checkpointsActivated[cp.id] == true -- 2067
			local stone = ink(44, 50, 48, 235) -- 2068
			d:drawPolygon( -- 2069
				{ -- 2070
					Vec2(cp.x - 7, cp.y + 40), -- 2070
					Vec2(cp.x + 7, cp.y + 40), -- 2070
					Vec2(cp.x + 8, cp.y), -- 2070
					Vec2(cp.x - 8, cp.y) -- 2070
				}, -- 2070
				col(stone), -- 2071
				0, -- 2072
				Color(0, 0, 0, 0) -- 2073
			) -- 2073
			dot( -- 2075
				d, -- 2075
				cp.x, -- 2075
				cp.y + 40, -- 2075
				7, -- 2075
				stone -- 2075
			) -- 2075
			seg( -- 2076
				d, -- 2076
				cp.x - 4, -- 2076
				cp.y + 28, -- 2076
				cp.x + 4, -- 2076
				cp.y + 28, -- 2076
				1.2, -- 2076
				PAPER_DIM, -- 2076
				0.8 -- 2076
			) -- 2076
			local fs = self.flagSets[cp.id] -- 2077
			if fs ~= nil then -- 2077
				fs.off.visible = not active -- 2080
				local frame = math.floor(time * 8) % #fs.on -- 2081
				do -- 2081
					local fi = 0 -- 2082
					while fi < #fs.on do -- 2082
						fs.on[fi + 1].visible = active and fi == frame -- 2083
						fi = fi + 1 -- 2082
					end -- 2082
				end -- 2082
				if active then -- 2082
					local pulse = time * 0.7 % 1 -- 2086
					circle( -- 2087
						d, -- 2087
						cp.x, -- 2087
						cp.y + 24, -- 2087
						14 + pulse * 30, -- 2087
						CYAN, -- 2087
						16, -- 2087
						(1 - pulse) * 0.5 -- 2087
					) -- 2087
				end -- 2087
			else -- 2087
				seg( -- 2090
					d, -- 2090
					cp.x + 10, -- 2090
					cp.y, -- 2090
					cp.x + 10, -- 2090
					cp.y + 64, -- 2090
					2.6, -- 2090
					ink(70, 60, 46, 235) -- 2090
				) -- 2090
				if active then -- 2090
					local flap = math.sin(time * 3) * 2 -- 2093
					d:drawPolygon( -- 2094
						{ -- 2095
							Vec2(cp.x + 10, cp.y + 64), -- 2095
							Vec2(cp.x + 32, cp.y + 60 + flap), -- 2095
							Vec2(cp.x + 32, cp.y + 50 + flap), -- 2095
							Vec2(cp.x + 10, cp.y + 54) -- 2095
						}, -- 2095
						col(CYAN, 0.8), -- 2096
						0, -- 2097
						Color(0, 0, 0, 0) -- 2098
					) -- 2098
					seg( -- 2100
						d, -- 2100
						cp.x + 10, -- 2100
						cp.y + 54, -- 2100
						cp.x + 32, -- 2100
						cp.y + 50 + flap, -- 2100
						1.2, -- 2100
						CYAN, -- 2100
						0.5 -- 2100
					) -- 2100
					local pulse = time * 0.7 % 1 -- 2101
					circle( -- 2102
						d, -- 2102
						cp.x, -- 2102
						cp.y + 24, -- 2102
						14 + pulse * 30, -- 2102
						CYAN, -- 2102
						16, -- 2102
						(1 - pulse) * 0.5 -- 2102
					) -- 2102
				else -- 2102
					seg( -- 2104
						d, -- 2104
						cp.x + 10, -- 2104
						cp.y + 64, -- 2104
						cp.x + 13, -- 2104
						cp.y + 50, -- 2104
						5, -- 2104
						Palette.inkSoft, -- 2104
						0.85 -- 2104
					) -- 2104
				end -- 2104
			end -- 2104
		end -- 2104
		::__continue364:: -- 2104
	end -- 2104
end -- 2056
function WorldRenderer.prototype.drawCollectibles(self, d, time, state) -- 2110
	for ____, c in ipairs(self.data.collectibles) do -- 2111
		do -- 2111
			if self:floorOfY(c.y) ~= self.activeFloor then -- 2111
				goto __continue377 -- 2113
			end -- 2113
			if c.loops ~= nil and __TS__ArrayIndexOf(c.loops, state.loopIndex) < 0 then -- 2113
				local gone1 = self.lampStoneSprites[c.id] -- 2116
				if gone1 ~= nil then -- 2116
					gone1.visible = false -- 2118
				end -- 2118
				local gone1m = self.moonStoneSprites[c.id] -- 2120
				if gone1m ~= nil then -- 2120
					gone1m.visible = false -- 2122
				end -- 2122
				local gone1d = self.dewSprites[c.id] -- 2124
				if gone1d ~= nil then -- 2124
					gone1d.visible = false -- 2126
				end -- 2126
				local gone1t = self.tokenSprites[c.id] -- 2128
				if gone1t ~= nil then -- 2128
					gone1t.visible = false -- 2130
				end -- 2130
				goto __continue377 -- 2132
			end -- 2132
			if state.collectedIds[c.id] == true then -- 2132
				local gone2 = self.lampStoneSprites[c.id] -- 2135
				if gone2 ~= nil then -- 2135
					gone2.visible = false -- 2137
				end -- 2137
				local gone2m = self.moonStoneSprites[c.id] -- 2139
				if gone2m ~= nil then -- 2139
					gone2m.visible = false -- 2141
				end -- 2141
				local gone2d = self.dewSprites[c.id] -- 2143
				if gone2d ~= nil then -- 2143
					gone2d.visible = false -- 2145
				end -- 2145
				local gone2t = self.tokenSprites[c.id] -- 2147
				if gone2t ~= nil then -- 2147
					gone2t.visible = false -- 2149
				end -- 2149
				goto __continue377 -- 2151
			end -- 2151
			if not self:inView(c.x - 40, c.y - 10, c.x + 40, c.y + 40) then -- 2151
				goto __continue377 -- 2154
			end -- 2154
			local bob = math.sin(time * 2 + c.x * 0.1) * 3 -- 2156
			local cx = c.x -- 2157
			local cy = c.y + bob -- 2158
			if c.kind == "lampstone" then -- 2158
				local ls = self.lampStoneSprites[c.id] -- 2161
				if ls ~= nil then -- 2161
					ls.visible = true -- 2163
					ls.position = Vec2(cx, cy + 18) -- 2164
				else -- 2164
					circle( -- 2166
						d, -- 2166
						cx, -- 2166
						cy + 14, -- 2166
						13, -- 2166
						GOLD, -- 2166
						18, -- 2166
						0.22 -- 2166
					) -- 2166
					d:drawPolygon( -- 2167
						{ -- 2168
							Vec2(cx - 7, cy + 6), -- 2168
							Vec2(cx + 7, cy + 6), -- 2168
							Vec2(cx + 4, cy + 22), -- 2168
							Vec2(cx - 4, cy + 22) -- 2168
						}, -- 2168
						col(ink(196, 168, 108, 235)), -- 2169
						0, -- 2170
						Color(0, 0, 0, 0) -- 2171
					) -- 2171
					dot( -- 2173
						d, -- 2173
						cx, -- 2173
						cy + 14, -- 2173
						3.4, -- 2173
						Palette.moonWhite, -- 2173
						0.9 -- 2173
					) -- 2173
				end -- 2173
			elseif c.kind == "moonstone" then -- 2173
				local ms = self.moonStoneSprites[c.id] -- 2177
				if ms ~= nil then -- 2177
					ms.visible = true -- 2179
					ms.position = Vec2(cx, cy + 18) -- 2180
				else -- 2180
					dot( -- 2182
						d, -- 2182
						cx, -- 2182
						cy + 12, -- 2182
						13, -- 2182
						CYAN, -- 2182
						0.25 -- 2182
					) -- 2182
					dot( -- 2183
						d, -- 2183
						cx, -- 2183
						cy + 12, -- 2183
						6.5, -- 2183
						CYAN -- 2183
					) -- 2183
					dot( -- 2184
						d, -- 2184
						cx - 2, -- 2184
						cy + 14, -- 2184
						2, -- 2184
						Palette.moonWhite, -- 2184
						0.9 -- 2184
					) -- 2184
				end -- 2184
			elseif c.kind == "mechanism" then -- 2184
				local rot = time * 1.2 -- 2187
				circle( -- 2188
					d, -- 2188
					cx, -- 2188
					cy + 10, -- 2188
					7, -- 2188
					GOLD, -- 2188
					12, -- 2188
					0.95 -- 2188
				) -- 2188
				do -- 2188
					local i = 0 -- 2189
					while i < 6 do -- 2189
						local a = rot + i / 6 * math.pi * 2 -- 2190
						seg( -- 2191
							d, -- 2191
							cx + math.cos(a) * 7, -- 2191
							cy + 10 + math.sin(a) * 7, -- 2191
							cx + math.cos(a) * 10.5, -- 2191
							cy + 10 + math.sin(a) * 10.5, -- 2191
							2.2, -- 2191
							GOLD, -- 2191
							0.95 -- 2191
						) -- 2191
						i = i + 1 -- 2189
					end -- 2189
				end -- 2189
				dot( -- 2193
					d, -- 2193
					cx, -- 2193
					cy + 10, -- 2193
					2.2, -- 2193
					GOLD, -- 2193
					0.9 -- 2193
				) -- 2193
			elseif c.kind == "token" then -- 2193
				local tk = self.tokenSprites[c.id] -- 2196
				if tk ~= nil then -- 2196
					tk.visible = true -- 2198
					tk.position = Vec2(cx, cy + 18) -- 2199
				else -- 2199
					d:drawPolygon( -- 2201
						{ -- 2202
							Vec2(cx - 7, cy + 16), -- 2202
							Vec2(cx + 7, cy + 16), -- 2202
							Vec2(cx + 7, cy + 4), -- 2202
							Vec2(cx - 7, cy + 4) -- 2202
						}, -- 2202
						col(ink(112, 84, 56, 225)), -- 2203
						0, -- 2204
						Color(0, 0, 0, 0) -- 2205
					) -- 2205
					circle( -- 2207
						d, -- 2207
						cx, -- 2207
						cy + 20, -- 2207
						3.2, -- 2207
						Palette.inkDark, -- 2207
						8, -- 2207
						0.9 -- 2207
					) -- 2207
					seg( -- 2208
						d, -- 2208
						cx - 3.5, -- 2208
						cy + 12, -- 2208
						cx + 3.5, -- 2208
						cy + 12, -- 2208
						1, -- 2208
						PAPER_DIM, -- 2208
						0.9 -- 2208
					) -- 2208
				end -- 2208
			else -- 2208
				local dw = self.dewSprites[c.id] -- 2212
				if dw ~= nil then -- 2212
					dw.visible = true -- 2214
					dw.position = Vec2(cx, cy + 18) -- 2215
				else -- 2215
					dot( -- 2217
						d, -- 2217
						cx, -- 2217
						cy + 8, -- 2217
						5.5, -- 2217
						CYAN, -- 2217
						0.75 -- 2217
					) -- 2217
					d:drawPolygon( -- 2218
						{ -- 2219
							Vec2(cx, cy + 18), -- 2219
							Vec2(cx + 3.4, cy + 10), -- 2219
							Vec2(cx - 3.4, cy + 10) -- 2219
						}, -- 2219
						col(CYAN, 0.75), -- 2220
						0, -- 2221
						Color(0, 0, 0, 0) -- 2222
					) -- 2222
					dot( -- 2224
						d, -- 2224
						cx - 1.6, -- 2224
						cy + 7.5, -- 2224
						1.6, -- 2224
						Palette.moonWhite, -- 2224
						0.9 -- 2224
					) -- 2224
				end -- 2224
			end -- 2224
		end -- 2224
		::__continue377:: -- 2224
	end -- 2224
end -- 2110
function WorldRenderer.prototype.drawDecor(self, d, time) -- 2231
	if self.activeFloor == 4 and self:inView(500, FLOOR_TOPS[5], 2100, FLOOR_TOPS[5] + 160) then -- 2231
		self:drawGear( -- 2233
			d, -- 2233
			800, -- 2233
			FLOOR_TOPS[5] + 80, -- 2233
			46, -- 2233
			18, -- 2233
			time * 0.35 -- 2233
		) -- 2233
		self:drawGear( -- 2234
			d, -- 2234
			1800, -- 2234
			FLOOR_TOPS[5] + 80, -- 2234
			34, -- 2234
			14, -- 2234
			-time * 0.5 + 0.4 -- 2234
		) -- 2234
	end -- 2234
	if self.activeFloor == 6 and self:inView(900, FLOOR_TOPS[7] - 90, 1500, FLOOR_TOPS[7] + 310) then -- 2234
		local cx = 1200 -- 2237
		local cy = FLOOR_TOPS[7] + 180 -- 2238
		circle( -- 2239
			d, -- 2239
			cx, -- 2239
			cy, -- 2239
			34, -- 2239
			GOLD, -- 2239
			24, -- 2239
			0.5 -- 2239
		) -- 2239
		circle( -- 2240
			d, -- 2240
			cx, -- 2240
			cy, -- 2240
			22, -- 2240
			GOLD, -- 2240
			20, -- 2240
			0.65 -- 2240
		) -- 2240
		arc( -- 2241
			d, -- 2241
			cx, -- 2241
			cy, -- 2241
			28, -- 2241
			time * 0.4, -- 2241
			time * 0.4 + math.pi * 1.4, -- 2241
			14, -- 2241
			2, -- 2241
			CYAN, -- 2241
			0.7 -- 2241
		) -- 2241
		do -- 2241
			local i = 0 -- 2242
			while i < 12 do -- 2242
				local a = i / 12 * math.pi * 2 + time * 0.05 -- 2243
				seg( -- 2244
					d, -- 2244
					cx + math.cos(a) * 34, -- 2244
					cy + math.sin(a) * 34, -- 2244
					cx + math.cos(a) * 39, -- 2244
					cy + math.sin(a) * 39, -- 2244
					1.6, -- 2244
					GOLD, -- 2244
					0.6 -- 2244
				) -- 2244
				i = i + 1 -- 2242
			end -- 2242
		end -- 2242
		dot( -- 2246
			d, -- 2246
			cx, -- 2246
			cy, -- 2246
			3.4, -- 2246
			CYAN, -- 2246
			0.9 -- 2246
		) -- 2246
	end -- 2246
	if self.activeFloor == 6 and self:inView(1900, FLOOR_TOPS[7] - 40, 2300, FLOOR_TOPS[7] + 260) then -- 2246
		local cx = 2100 -- 2249
		local cy = FLOOR_TOPS[7] + 100 -- 2250
		circle( -- 2251
			d, -- 2251
			cx, -- 2251
			cy, -- 2251
			46, -- 2251
			GOLD, -- 2251
			28, -- 2251
			0.55 -- 2251
		) -- 2251
		circle( -- 2252
			d, -- 2252
			cx, -- 2252
			cy, -- 2252
			34, -- 2252
			GOLD, -- 2252
			24, -- 2252
			0.7 -- 2252
		) -- 2252
		circle( -- 2253
			d, -- 2253
			cx, -- 2253
			cy, -- 2253
			22, -- 2253
			GOLD, -- 2253
			20, -- 2253
			0.85 -- 2253
		) -- 2253
		dot( -- 2254
			d, -- 2254
			cx, -- 2254
			cy, -- 2254
			8, -- 2254
			CYAN, -- 2254
			0.85 + 0.15 * math.sin(time * 2.4) -- 2254
		) -- 2254
		local oa = time * 1.1 -- 2255
		local ox = cx + math.cos(oa) * 22 -- 2256
		local oy = cy + math.sin(oa) * 22 -- 2257
		dot( -- 2258
			d, -- 2258
			ox, -- 2258
			oy, -- 2258
			8, -- 2258
			CYAN, -- 2258
			0.3 -- 2258
		) -- 2258
		dot( -- 2259
			d, -- 2259
			ox, -- 2259
			oy, -- 2259
			4, -- 2259
			Palette.moonWhite, -- 2259
			0.95 -- 2259
		) -- 2259
	end -- 2259
end -- 2231
function WorldRenderer.prototype.drawGear(self, d, cx, cy, r, teeth, rot) -- 2263
	local c = ink(70, 62, 50, 200) -- 2264
	circle( -- 2265
		d, -- 2265
		cx, -- 2265
		cy, -- 2265
		r * 0.62, -- 2265
		c, -- 2265
		20, -- 2265
		0.9 -- 2265
	) -- 2265
	do -- 2265
		local i = 0 -- 2266
		while i < teeth do -- 2266
			local a = rot + i / teeth * math.pi * 2 -- 2267
			seg( -- 2268
				d, -- 2268
				cx + math.cos(a) * r * 0.62, -- 2268
				cy + math.sin(a) * r * 0.62, -- 2268
				cx + math.cos(a) * r, -- 2268
				cy + math.sin(a) * r, -- 2268
				3.4, -- 2268
				c, -- 2268
				0.95 -- 2268
			) -- 2268
			i = i + 1 -- 2266
		end -- 2266
	end -- 2266
	do -- 2266
		local i = 0 -- 2270
		while i < 4 do -- 2270
			local a = rot + i / 4 * math.pi * 2 -- 2271
			seg( -- 2272
				d, -- 2272
				cx, -- 2272
				cy, -- 2272
				cx + math.cos(a) * r * 0.5, -- 2272
				cy + math.sin(a) * r * 0.5, -- 2272
				2.2, -- 2272
				c, -- 2272
				0.6 -- 2272
			) -- 2272
			i = i + 1 -- 2270
		end -- 2270
	end -- 2270
	dot( -- 2274
		d, -- 2274
		cx, -- 2274
		cy, -- 2274
		3.6, -- 2274
		c, -- 2274
		0.95 -- 2274
	) -- 2274
end -- 2263
function WorldRenderer.prototype.syncBossWaveSprites(self, enemies) -- 2279
	if not self.bossWaveChecked then -- 2279
		self.bossWaveChecked = true -- 2281
		self.bossWaveTex = self:loadTex("assets/effects/slash_blue.png") -- 2282
	end -- 2282
	local tex = self.bossWaveTex -- 2284
	if tex == nil then -- 2284
		return false -- 2286
	end -- 2286
	local waves = enemies.waves -- 2288
	local frames = math.max( -- 2289
		1, -- 2289
		math.floor(tex.width / 64) -- 2289
	) -- 2289
	while #self.bossWaveSprites > #waves do -- 2289
		local sp = table.remove(self.bossWaveSprites) -- 2291
		if sp ~= nil then -- 2291
			sp:removeFromParent() -- 2293
		end -- 2293
	end -- 2293
	while #self.bossWaveSprites < #waves do -- 2293
		local created = Sprite( -- 2297
			tex, -- 2297
			Rect( -- 2297
				math.floor(frames / 2) * 64, -- 2297
				0, -- 2297
				64, -- 2297
				64 -- 2297
			) -- 2297
		) -- 2297
		if created == nil then -- 2297
			return false -- 2299
		end -- 2299
		created.filter = "Point" -- 2301
		created:addTo(self.waveSpriteRoot) -- 2302
		local ____self_bossWaveSprites_11 = self.bossWaveSprites -- 2302
		____self_bossWaveSprites_11[#____self_bossWaveSprites_11 + 1] = created -- 2303
	end -- 2303
	local k = 92 / 64 -- 2306
	do -- 2306
		local i = 0 -- 2307
		while i < #self.bossWaveSprites do -- 2307
			local sp = self.bossWaveSprites[i + 1] -- 2308
			local wv = waves[i + 1] -- 2309
			sp.position = Vec2(wv.x, wv.y + 20) -- 2310
			sp.scaleX = (wv.dir >= 0 and 1 or -1) * k -- 2311
			sp.scaleY = k -- 2312
			sp.opacity = wv.life < 0.4 and math.floor(255 * (wv.life / 0.4)) or 255 -- 2313
			i = i + 1 -- 2307
		end -- 2307
	end -- 2307
	return true -- 2315
end -- 2279
function WorldRenderer.prototype.drawArrow(self, d, x, y, vx, vy) -- 2319
	local lenRaw = math.sqrt(vx * vx + vy * vy) -- 2320
	local len = lenRaw > 0.0001 and lenRaw or 1 -- 2321
	local ux = vx / len -- 2322
	local uy = vy / len -- 2323
	seg( -- 2324
		d, -- 2324
		x - ux * 12, -- 2324
		y - uy * 12, -- 2324
		x + ux * 6, -- 2324
		y + uy * 6, -- 2324
		2.2, -- 2324
		ink(196, 188, 168, 235) -- 2324
	) -- 2324
	dot( -- 2325
		d, -- 2325
		x + ux * 7, -- 2325
		y + uy * 7, -- 2325
		2.4, -- 2325
		ink(244, 240, 226, 255) -- 2325
	) -- 2325
end -- 2319
function WorldRenderer.prototype.drawChars(self, time, state, player, enemies, mech, dt) -- 2329
	local d = self.charDraw -- 2330
	d:clear() -- 2331
	self.ninja:beginFrame(dt) -- 2332
	for ____, p in ipairs(enemies.pots) do -- 2333
		do -- 2333
			if not p.alive then -- 2333
				goto __continue428 -- 2335
			end -- 2335
			if self:inView(p.x - 20, p.y - 20, p.x + 20, p.y + 20) then -- 2335
				drawPot(d, p.x, p.y, time) -- 2338
			end -- 2338
		end -- 2338
		::__continue428:: -- 2338
	end -- 2338
	if not self:syncBossWaveSprites(enemies) then -- 2338
		for ____, wv in ipairs(enemies.waves) do -- 2343
			if self:inView(wv.x - 40, wv.y - 20, wv.x + 40, wv.y + 50) then -- 2343
				drawWave( -- 2345
					d, -- 2345
					wv.x, -- 2345
					wv.y, -- 2345
					wv.dir, -- 2345
					time -- 2345
				) -- 2345
			end -- 2345
		end -- 2345
	end -- 2345
	for ____, ar in ipairs(enemies.arrows) do -- 2350
		do -- 2350
			if not ar.alive then -- 2350
				goto __continue436 -- 2352
			end -- 2352
			if self:inView(ar.x - 30, ar.y - 30, ar.x + 30, ar.y + 30) then -- 2352
				self:drawArrow( -- 2355
					d, -- 2355
					ar.x, -- 2355
					ar.y, -- 2355
					ar.vx, -- 2355
					ar.vy -- 2355
				) -- 2355
			end -- 2355
		end -- 2355
		::__continue436:: -- 2355
	end -- 2355
	for ____, e in ipairs(enemies.enemies) do -- 2358
		do -- 2358
			if e.dead and e.deathTimer <= 0 then -- 2358
				goto __continue440 -- 2360
			end -- 2360
			if self:floorOfY(e.body.y) ~= self.activeFloor then -- 2360
				goto __continue440 -- 2364
			end -- 2364
			if self:inView(e.body.x - 60, e.body.y - e.body.h / 2, e.body.x + 60, e.body.y + e.body.h / 2) then -- 2364
				if not self.ninja:drawEnemy(e) then -- 2364
					drawEnemy(d, e, e.animTime) -- 2368
				end -- 2368
			end -- 2368
		end -- 2368
		::__continue440:: -- 2368
	end -- 2368
	self.ninja:endFrame() -- 2372
	do -- 2372
		local si = 0 -- 2373
		while si < #mech.stones do -- 2373
			do -- 2373
				local s = mech.stones[si + 1] -- 2374
				local inR = self:inView(s.x - 40, s.y - 40, s.x + 40, s.y + 40) -- 2375
				if si < #self.stoneSprites then -- 2375
					local sp = self.stoneSprites[si + 1] -- 2378
					sp.visible = inR -- 2379
					if inR then -- 2379
						sp.position = Vec2(s.x, s.y) -- 2381
					end -- 2381
					goto __continue447 -- 2383
				end -- 2383
				if not inR then -- 2383
					goto __continue447 -- 2386
				end -- 2386
				d:drawPolygon( -- 2388
					{ -- 2389
						Vec2(s.x - s.w / 2, s.y + s.h / 2), -- 2390
						Vec2(s.x + s.w / 2, s.y + s.h / 2), -- 2391
						Vec2(s.x + s.w / 2 - 2, s.y - s.h / 2), -- 2392
						Vec2(s.x - s.w / 2 + 2, s.y - s.h / 2) -- 2393
					}, -- 2393
					col(ink(58, 54, 48, 235)), -- 2395
					0, -- 2396
					Color(0, 0, 0, 0) -- 2397
				) -- 2397
				seg( -- 2399
					d, -- 2399
					s.x - s.w / 2 + 6, -- 2399
					s.y + s.h / 2 - 6, -- 2399
					s.x, -- 2399
					s.y - s.h / 2 + 8, -- 2399
					1.4, -- 2399
					ink(40, 37, 33, 120) -- 2399
				) -- 2399
				dot( -- 2400
					d, -- 2400
					s.x - s.w / 4, -- 2400
					s.y + s.h / 4, -- 2400
					2.4, -- 2400
					PAPER_DIM, -- 2400
					0.8 -- 2400
				) -- 2400
			end -- 2400
			::__continue447:: -- 2400
			si = si + 1 -- 2373
		end -- 2373
	end -- 2373
	do -- 2373
		local si = #mech.stones -- 2403
		while si < #self.stoneSprites do -- 2403
			self.stoneSprites[si + 1].visible = false -- 2404
			si = si + 1 -- 2403
		end -- 2403
	end -- 2403
	if self.shenYan ~= nil then -- 2403
		local sy = self.shenYan -- 2407
		if self:floorOfY(sy.y) == self.activeFloor and self:inView(sy.x - 60, sy.y - 20, sy.x + 60, sy.y + 100) then -- 2407
			drawShenYan( -- 2409
				d, -- 2409
				sy.x, -- 2409
				sy.y, -- 2409
				sy.facing, -- 2409
				time, -- 2409
				sy.hostile -- 2409
			) -- 2409
		end -- 2409
	end -- 2409
	if self.observer ~= nil then -- 2409
		local ob = self.observer -- 2413
		if self:floorOfY(ob.y) == self.activeFloor and self:inView(ob.x - 50, ob.y, ob.x + 50, ob.y + 130) then -- 2413
			drawObserver(d, ob.x, ob.y, time) -- 2415
		end -- 2415
	end -- 2415
	local px = player.body.x -- 2418
	local py = player.body.y - player.body.h / 2 -- 2419
	local pose = self:heroPose(player) -- 2420
	local visible = self:inView(px - 80, py - 20, px + 80, py + 120) -- 2422
	local animT = pose == "ladder" and player.climbT or player.animTime -- 2424
	if self.heroTexOk then -- 2424
		self:updateHeroSprite( -- 2426
			px, -- 2426
			py, -- 2426
			player.facing, -- 2426
			pose, -- 2426
			animT, -- 2426
			state.phaseIndex, -- 2426
			visible, -- 2426
			dt -- 2426
		) -- 2426
	elseif visible then -- 2426
		drawHero( -- 2428
			d, -- 2428
			px, -- 2428
			py, -- 2428
			player.facing, -- 2428
			pose, -- 2428
			animT, -- 2428
			state.phaseIndex -- 2428
		) -- 2428
	end -- 2428
end -- 2329
function WorldRenderer.prototype.updateHeroSprite(self, x, y, facing, pose, t, phaseIndex, visible, dt) -- 2433
	local sp = self.heroSprite -- 2443
	local f = self.heroFxDraw -- 2444
	f:clear() -- 2445
	self:updateGhosts(dt) -- 2446
	if not visible then -- 2446
		if sp ~= nil then -- 2446
			sp.visible = false -- 2449
		end -- 2449
		self.heroFrames:hideAll() -- 2451
		return -- 2452
	end -- 2452
	local fr = self.heroFrames:pick(pose, t) -- 2455
	if fr ~= nil then -- 2455
		if sp ~= nil then -- 2455
			sp.visible = false -- 2458
		end -- 2458
		self.heroFrames:hideAll() -- 2460
		fr.sp.visible = true -- 2461
		local bobF = 0 -- 2462
		if pose == "jump" then -- 2462
			bobF = 2 -- 2464
		elseif pose == "fall" then -- 2464
			bobF = -2 -- 2466
		end -- 2466
		fr.sp.position = Vec2(x, y + bobF) -- 2468
		fr.sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT and 1 or -1) -- 2469
		fr.sp.scaleY = fr.scale -- 2470
		if self.ghostCd <= 0 and (pose == "dash" or pose == "jump" or pose == "fall") then -- 2470
			self:spawnGhost(fr, x, y + bobF, facing) -- 2473
			self.ghostCd = GHOST_INTERVAL -- 2474
		end -- 2474
		self:drawHeroFx( -- 2476
			f, -- 2476
			x, -- 2476
			y, -- 2476
			facing, -- 2476
			pose, -- 2476
			t, -- 2476
			phaseIndex, -- 2476
			0 -- 2476
		) -- 2476
		return -- 2477
	end -- 2477
	self.heroFrames:hideAll() -- 2479
	if sp == nil then -- 2479
		self:drawHeroFx( -- 2481
			f, -- 2481
			x, -- 2481
			y, -- 2481
			facing, -- 2481
			pose, -- 2481
			t, -- 2481
			phaseIndex, -- 2481
			0 -- 2481
		) -- 2481
		return -- 2482
	end -- 2482
	sp.visible = true -- 2484
	local bob = 0 -- 2485
	if pose == "idle" then -- 2485
		bob = math.sin(t * 2) * 1.6 -- 2487
	elseif pose == "run" then -- 2487
		bob = -math.abs(math.sin(t * 12)) * 2.2 -- 2489
	elseif pose == "jump" then -- 2489
		bob = 2.5 -- 2491
	elseif pose == "fall" then -- 2491
		bob = -1.5 -- 2493
	end -- 2493
	sp.position = Vec2(x, y + bob) -- 2495
	sp.scaleX = self.heroScale * facing -- 2496
	sp.scaleY = self.heroScale -- 2497
	self:drawHeroFx( -- 2498
		f, -- 2498
		x, -- 2498
		y, -- 2498
		facing, -- 2498
		pose, -- 2498
		t, -- 2498
		phaseIndex, -- 2498
		bob -- 2498
	) -- 2498
end -- 2433
function WorldRenderer.prototype.drawHeroFx(self, f, x, y, _facing, pose, _t, _phaseIndex, _bob) -- 2504
	if pose == "hurt" then -- 2504
		dot( -- 2517
			f, -- 2517
			x, -- 2517
			y + 46, -- 2517
			26, -- 2517
			ink(220, 70, 60, 160), -- 2517
			0.5 -- 2517
		) -- 2517
	end -- 2517
end -- 2504
function WorldRenderer.prototype.updateGhosts(self, dt) -- 2522
	if self.ghostCd > 0 then -- 2522
		self.ghostCd = self.ghostCd - dt -- 2524
	end -- 2524
	local i = #self.ghosts - 1 -- 2526
	while i >= 0 do -- 2526
		local g = self.ghosts[i + 1] -- 2528
		g.t = g.t + dt -- 2529
		if g.t >= g.dur then -- 2529
			g.sp:removeFromParent() -- 2531
			__TS__ArraySplice(self.ghosts, i, 1) -- 2532
		else -- 2532
			g.sp.opacity = GHOST_ALPHA * (1 - g.t / g.dur) -- 2534
		end -- 2534
		i = i - 1 -- 2536
	end -- 2536
end -- 2522
function WorldRenderer.prototype.spawnGhost(self, fr, x, y, facing) -- 2541
	if #self.ghosts >= GHOST_MAX then -- 2541
		return -- 2543
	end -- 2543
	local tex = fr.sp.texture -- 2545
	if tex == nil then -- 2545
		return -- 2547
	end -- 2547
	local sp = Sprite(tex) -- 2549
	if sp == nil then -- 2549
		return -- 2551
	end -- 2551
	sp.anchor = Vec2(0.5, 0) -- 2553
	sp.position = Vec2(x - facing * GHOST_OFFSET, y) -- 2554
	sp.scaleX = fr.scale * facing * (HERO_FRAMES_FACE_RIGHT and 1 or -1) -- 2555
	sp.scaleY = fr.scale -- 2556
	sp.color = Color(GHOST_TINT_R, GHOST_TINT_G, GHOST_TINT_B, 255) -- 2557
	sp.opacity = GHOST_ALPHA -- 2558
	sp:addTo(self.ghostRoot) -- 2559
	local ____self_ghosts_12 = self.ghosts -- 2559
	____self_ghosts_12[#____self_ghosts_12 + 1] = {sp = sp, t = 0, dur = GHOST_DUR} -- 2560
end -- 2541
function WorldRenderer.prototype.heroPose(self, p) -- 2563
	if p.onLadder then -- 2563
		return "ladder" -- 2565
	end -- 2565
	local a = p.anim -- 2567
	if a == "wallslide" then -- 2567
		return "cling" -- 2569
	end -- 2569
	if a == "climb" then -- 2569
		return "ladder" -- 2572
	end -- 2572
	if a == "attack" then -- 2572
		local idx = p.attackIndex -- 2575
		return idx <= 0 and "attack1" or (idx == 1 and "attack2" or (idx == 2 and "attack3" or "heavy")) -- 2576
	end -- 2576
	if a == "land" then -- 2576
		return "idle" -- 2579
	end -- 2579
	return a -- 2581
end -- 2563
return ____exports -- 2563