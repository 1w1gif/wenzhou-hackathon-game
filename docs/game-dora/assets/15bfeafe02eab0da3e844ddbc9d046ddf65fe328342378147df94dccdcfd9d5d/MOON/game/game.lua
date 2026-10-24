-- [ts]: game.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Keyboard = ____Dora.Keyboard -- 2
local Node = ____Dora.Node -- 2
local Sprite = ____Dora.Sprite -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local ____physics = require("game.physics") -- 4
local activePlatforms = ____physics.activePlatforms -- 4
local bodyRect = ____physics.bodyRect -- 4
local clamp = ____physics.clamp -- 4
local lerp = ____physics.lerp -- 4
local rectOverlap = ____physics.rectOverlap -- 4
local ____world = require("game.world") -- 5
local addTrust = ____world.addTrust -- 5
local createLoopState = ____world.createLoopState -- 5
local restoreFloorCap = ____world.restoreFloorCap -- 5
local rewindFloor = ____world.rewindFloor -- 5
local ____player = require("game.player") -- 6
local Player = ____player.Player -- 6
local ____effects = require("game.effects") -- 7
local EffectSystem = ____effects.EffectSystem -- 7
local ____enemies = require("game.enemies") -- 8
local EnemySystem = ____enemies.EnemySystem -- 8
local ____stealth = require("game.stealth") -- 9
local StealthSystem = ____stealth.StealthSystem -- 9
local ____mechanisms = require("game.mechanisms") -- 10
local MechanismSystem = ____mechanisms.MechanismSystem -- 10
local ____render_world = require("game.render_world") -- 11
local WorldRenderer = ____render_world.WorldRenderer -- 11
local ____hud = require("ui.hud") -- 12
local HUD = ____hud.HUD -- 12
local ____dialog = require("ui.dialog") -- 13
local DialogUI = ____dialog.DialogUI -- 13
local ____notebook = require("ui.notebook") -- 14
local NotebookUI = ____notebook.NotebookUI -- 14
local ____story = require("data.story") -- 15
local ENDINGS = ____story.ENDINGS -- 15
local STORY_NODES = ____story.STORY_NODES -- 15
local Tower = require("data.tower") -- 16
local ____render_chars = require("game.render_chars") -- 17
local drawShenYan = ____render_chars.drawShenYan -- 17
local drawObserver = ____render_chars.drawObserver -- 17
local ____audio = require("game.audio") -- 18
local playBgm = ____audio.playBgm -- 18
local sfx = ____audio.sfx -- 18
local ____sheetfx = require("game.sheetfx") -- 19
local SheetFxSystem = ____sheetfx.SheetFxSystem -- 19
local ____boomfx = require("game.boomfx") -- 20
local BoomFxSystem = ____boomfx.BoomFxSystem -- 20
local ____slashfx = require("game.slashfx") -- 21
local SlashFxSystem = ____slashfx.SlashFxSystem -- 21
local ____timeline_tree = require("game.timeline_tree") -- 22
local TreeSystem = ____timeline_tree.TreeSystem -- 22
local ____causality_fx = require("game.causality_fx") -- 23
local CausalityFx = ____causality_fx.CausalityFx -- 23
local ____name_entry = require("ui.name_entry") -- 24
local NameEntry = ____name_entry.NameEntry -- 24
local ____tree_gallery = require("ui.tree_gallery") -- 25
local TreeGallery = ____tree_gallery.TreeGallery -- 25
local ____archive = require("core.archive") -- 26
local appendArchive = ____archive.appendArchive -- 26
local loadArchive = ____archive.loadArchive -- 26
local loadPlayerName = ____archive.loadPlayerName -- 26
local savePlayerName = ____archive.savePlayerName -- 26
local ____archive = require("core.archive") -- 27
local DEFAULT_NAME = ____archive.DEFAULT_NAME -- 27
local PORTAL_USE_RADIUS = 120 -- 44
local GOLD = {r = 155, g = 113, b = 56, a = 255} -- 46
local CYAN = {r = 168, g = 197, b = 188, a = 255} -- 47
local TREE_LADDER = {{ -- 50
	id = "l_tree", -- 50
	floor = 0, -- 50
	x = 1180, -- 50
	y = 220, -- 50
	w = 44, -- 50
	h = 560 -- 50
}} -- 50
____exports.Game = __TS__Class() -- 52
local Game = ____exports.Game -- 52
Game.name = "Game" -- 52
function Game.prototype.____constructor(self) -- 112
	self.shenTexOk = false -- 63
	self.shenShownIdx = 0 -- 64
	self.treeFloorSeen = {} -- 99
	self.treeGateSeen = {} -- 100
	self.treeDeathSeen = false -- 101
	self.shenRenderX = 0 -- 1101
	self.shenRenderY = 0 -- 1102
	self.shenRenderOk = false -- 1103
	self.pendingFloorStoryFloor = 0 -- 1106
	self.pendingFloorStoryT = 0 -- 1107
	self.hintBubbleX = 0 -- 1111
	self.hintBubbleY = 0 -- 1112
	self.hintBubbleBestD = 1000000000 -- 1113
	self.askList = {} -- 1272
	self.teleportT = -1 -- 1574
	self.root = Node() -- 113
	self.root:addTo(Director.entry) -- 114
	self.renderer = __TS__New(WorldRenderer, self.root, Tower) -- 115
	self.fxDraw = DrawNode() -- 116
	self.fxDraw:addTo(self.root) -- 117
	self.npcDraw = DrawNode() -- 118
	self.npcDraw:addTo(self.root) -- 119
	self.shenNode = Node() -- 120
	self.shenNode:addTo(self.root) -- 121
	self.shenSpNormal = self:makeNpcSprite({"assets/characters/male_hero.png", ".agent/男主.png"}, self.shenNode, "ShenSprite") -- 122
	self.shenSpDark = self:makeNpcSprite({"assets/characters/male_hero_dark.png", ".agent/男主黑化版.png"}, self.shenNode, "ShenSprite") -- 123
	self.obsNode = Node() -- 125
	self.obsNode:addTo(self.root) -- 126
	self.obsSp = self:makeNpcSprite({".agent/观测者.png"}, self.obsNode, "Observer") -- 127
	self.shenTexOk = self.shenSpNormal ~= nil or self.shenSpDark ~= nil -- 128
	self.sheetNode = Node() -- 129
	self.sheetNode:addTo(self.root) -- 130
	self.uiRoot = Node() -- 131
	self.uiRoot:addTo(self.root) -- 132
	self.fx = __TS__New(EffectSystem) -- 133
	self.sheetFx = __TS__New(SheetFxSystem, self.sheetNode) -- 134
	self.boomFx = __TS__New(BoomFxSystem, self.sheetNode) -- 135
	self.slashFx = __TS__New(SlashFxSystem, self.sheetNode) -- 136
	self.lastSwingSeq = -1 -- 137
	self.qiSwingT = 0 -- 138
	self.fx.sheetHook = function(x, y, dir, big) return self.sheetFx:spawn(x, y, dir, big) end -- 139
	self.state = createLoopState() -- 140
	self.player = __TS__New(Player, 800, 410) -- 141
	self.enemies = __TS__New( -- 142
		EnemySystem, -- 142
		self.fx, -- 142
		{ -- 142
			onPlayerHit = function(____, dmg, fromX) return self:onPlayerHit(dmg, fromX) end, -- 143
			onDeath = function(____, def, x, y) return self:onEnemyDeath(def, x, y) end, -- 144
			onPoof = function(____, x, y) return self.fx:spawnDust(x, y, 0) end -- 145
		} -- 145
	) -- 145
	self.mech = __TS__New( -- 147
		MechanismSystem, -- 147
		self.state, -- 147
		self.fx, -- 147
		{ -- 147
			onGateOpen = function(____, gateId) -- 148
				self.fx:spawnRing( -- 149
					self.player.body.x, -- 149
					self.player.body.y + 20, -- 149
					GOLD, -- 149
					16, -- 149
					170, -- 149
					0.7 -- 149
				) -- 149
				self:growGate(gateId) -- 150
			end, -- 148
			onBell = function() return self:shake(0.25, 5) end, -- 152
			onLanternLit = function() return self.fx:spawnStars(self.player.body.x, self.player.body.y + 40, 6) end, -- 153
			onLanternFail = function() return self:shake(0.15, 3) end, -- 154
			onCheckpoint = function() return self:syncFloorScene() end, -- 155
			onCollect = function(____, kind) -- 156
				if kind == "lampstone" then -- 156
					self.mech:addLampStone() -- 158
					self.fx:spawnRing( -- 159
						self.player.body.x, -- 159
						self.player.body.y + 30, -- 159
						GOLD, -- 159
						10, -- 159
						60, -- 159
						0.6 -- 159
					) -- 159
				end -- 159
			end, -- 156
			onSwordInserted = function() -- 162
				self:shake(0.3, 7) -- 163
				self.fx:spawnStars(self.player.body.x, self.player.body.y + 30, 10) -- 164
			end, -- 162
			onLanternNoStone = function() -- 166
				self:shake(0.12, 2) -- 167
			end, -- 166
			onWindSigil = function() -- 170
				self:shake(0.18, 4) -- 171
				self.fx:spawnStars(self.player.body.x, self.player.body.y + 30, 6) -- 172
			end, -- 170
			onStarLit = function() -- 175
				self.fx:spawnStars(self.player.body.x, self.player.body.y + 40, 6) -- 176
			end, -- 175
			onStarFail = function() -- 179
				self:shake(0.15, 3) -- 180
			end -- 179
		} -- 179
	) -- 179
	self.mech:bindLists(Tower.ropes, Tower.bells, Tower.plates) -- 183
	self.mech:bindSwordSlots(Tower.swordSlots) -- 184
	self.mech:bindGateRequirements(Tower.gateRequirements) -- 185
	self.mech:bindWindSigils(Tower.windSigils) -- 186
	self.mech:bindStarNodes(Tower.starNodes) -- 187
	self.stealth = __TS__New(StealthSystem, self.enemies, Tower.platforms) -- 189
	self.stealth:attachTo(self.renderer:getWorldRoot()) -- 190
	self.hud = __TS__New(HUD, self.uiRoot) -- 191
	self.nameEntry = __TS__New(NameEntry, self.uiRoot) -- 192
	self.gallery = __TS__New(TreeGallery, self.uiRoot) -- 193
	self.treeArchived = false -- 194
	self.playerName = "" -- 195
	self.causFx = __TS__New(CausalityFx, self.uiRoot) -- 196
	self.treeSnap = {} -- 197
	self.treeJumpPending = false -- 198
	self.floor1Kill = false -- 199
	self.floor1Alert = false -- 200
	self.deadT = 0 -- 201
	self.hud.onPlayConfirmed = function() -- 203
		sfx("click", 0.8) -- 204
		self.hud:playPrologue(function() -- 205
			self.nameEntry:open( -- 206
				loadPlayerName(), -- 206
				function(name) -- 206
					self.playerName = name -- 207
					savePlayerName(name) -- 208
					self.hud:setTitleVisible(false) -- 209
					self:beginLoop() -- 210
				end, -- 206
				function() -- 211
					self.hud:setTitleVisible(true) -- 213
				end -- 211
			) -- 211
		end) -- 205
	end -- 203
	self.hud.onGalleryConfirmed = function() -- 218
		sfx("click", 0.8) -- 219
		self.gallery:open(loadArchive()) -- 220
	end -- 218
	self.dialog = __TS__New(DialogUI, self.uiRoot) -- 222
	self.notebook = __TS__New(NotebookUI, self.uiRoot) -- 223
	self.mode = "title" -- 224
	self.paused = false -- 225
	self.time = 0 -- 226
	self.hitstop = 0 -- 227
	self.shakeT = 0 -- 228
	self.shakeMag = 0 -- 229
	self.camX = 800 -- 230
	self.camY = 400 -- 231
	self.attackApplied = false -- 232
	self.intentRegenT = 0 -- 233
	self.qiShots = {} -- 234
	self.rewindT = 0 -- 235
	self.bladeT = 0 -- 236
	self.endingId = "" -- 237
	self.hud:setTitleVisible(true) -- 238
	playBgm("cover", 1.5) -- 240
	self.hud.onReturnTitle = function() -- 242
		self:toTitle() -- 243
	end -- 242
	self.hud.onEndingTap = function() -- 246
		if self.mode == "ending" then -- 246
			self:toTitle() -- 248
		end -- 248
	end -- 246
end -- 112
function Game.prototype.start(self) -- 253
	self:resetRun() -- 254
	self.root:schedule(function(dt) -- 256
		self.hud.titleMenuEnabled = self.mode == "title" -- 257
		self:tick(dt) -- 258
		return false -- 259
	end) -- 256
	self.root:onKeyDown(function(key) return self:onKey(key) end) -- 261
	self.root.touchEnabled = true -- 263
	self.root:slot( -- 264
		"Tapped", -- 264
		function() -- 264
			if self.mode == "title" and self.nameEntry:isOpen() then -- 264
				self.nameEntry:handleKey("Return") -- 266
			end -- 266
		end -- 264
	) -- 264
end -- 253
function Game.prototype.resetRun(self) -- 272
	self.state = createLoopState() -- 273
	self.mech.state = self.state -- 274
	self.mech:syncStones(Tower.pushStones) -- 275
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 276
	__TS__ArraySetLength(self.qiShots, 0) -- 276
	self.attackApplied = false -- 278
	self.intentRegenT = 0 -- 279
	self.bladeT = 0 -- 280
	self.rewindT = 0 -- 281
	self.stealth:resetRuntime() -- 282
	self.causFx:clear() -- 283
	self.treeSnap = {} -- 284
	self.treeJumpPending = false -- 285
	self.floor1Kill = false -- 286
	self.floor1Alert = false -- 287
	self.deadT = 0 -- 288
	self:respawnAt(self.state.currentCheckpointId) -- 292
end -- 272
function Game.prototype.findCheckpoint(self, id) -- 295
	do -- 295
		local i = 0 -- 296
		while i < #Tower.checkpoints do -- 296
			if Tower.checkpoints[i + 1].id == id then -- 296
				return Tower.checkpoints[i + 1] -- 298
			end -- 298
			i = i + 1 -- 296
		end -- 296
	end -- 296
	return nil -- 301
end -- 295
function Game.prototype.playFloorBgm(self, fade) -- 305
	if fade == nil then -- 305
		fade = 1.2 -- 305
	end -- 305
	if self.mode ~= "play" and self.mode ~= "confront" and self.mode ~= "rewind" then -- 305
		return -- 307
	end -- 307
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 309
	local floor = cp and cp.floor or 0 -- 310
	local names = { -- 311
		"floor1", -- 311
		"tension", -- 311
		"wuxia", -- 311
		"floor4", -- 311
		"dusk", -- 311
		"conflict", -- 311
		"floor7" -- 311
	} -- 311
	local name = names[math.max( -- 312
		0, -- 312
		math.min(#names - 1, floor) -- 312
	) + 1] -- 312
	playBgm(name, fade) -- 313
end -- 305
function Game.prototype.findStoryTrigger(self, id) -- 316
	do -- 316
		local i = 0 -- 317
		while i < #Tower.storyTriggers do -- 317
			if Tower.storyTriggers[i + 1].storyId == id then -- 317
				return Tower.storyTriggers[i + 1] -- 319
			end -- 319
			i = i + 1 -- 317
		end -- 317
	end -- 317
	return nil -- 322
end -- 316
function Game.prototype.isAutoMonologue(self, id) -- 326
	return id == "story_check_intro" or id == "story_town" or id == "story_sneak_hint" or id == "story_workshop" -- 327
end -- 326
function Game.prototype.floorIntroStory(self, floor) -- 331
	local best -- 332
	do -- 332
		local i = 0 -- 333
		while i < #Tower.storyTriggers do -- 333
			do -- 333
				local t = Tower.storyTriggers[i + 1] -- 334
				if t.floor ~= floor or not self:isAutoMonologue(t.storyId) or self.state.storySeen[t.storyId] then -- 334
					goto __continue46 -- 336
				end -- 336
				if best == nil or t.x < best.x then -- 336
					best = t -- 339
				end -- 339
			end -- 339
			::__continue46:: -- 339
			i = i + 1 -- 333
		end -- 333
	end -- 333
	return best ~= nil and best.storyId or nil -- 342
end -- 331
function Game.prototype.tickPendingFloorStory(self, dt) -- 346
	local id = self.pendingFloorStory -- 347
	if id == nil then -- 347
		return -- 349
	end -- 349
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 351
	if cp == nil or cp.floor ~= self.pendingFloorStoryFloor or self.state.storySeen[id] then -- 351
		self.pendingFloorStory = nil -- 353
		return -- 354
	end -- 354
	self.pendingFloorStoryT = self.pendingFloorStoryT - dt -- 356
	if self.pendingFloorStoryT > 0 or self.teleportT >= 0 then -- 356
		return -- 358
	end -- 358
	self.pendingFloorStory = nil -- 360
	self:openDialog(id) -- 361
end -- 346
function Game.prototype.storyPromptAnchor(self, id) -- 365
	local trig = self:findStoryTrigger(id) -- 366
	local groundY = Tower.TOPS[(trig ~= nil and trig.floor or 0) + 1] -- 367
	local cx = trig ~= nil and trig.x + trig.w / 2 or self.player.body.x -- 368
	local node = STORY_NODES[id] -- 369
	local kind = node ~= nil and #node.lines > 0 and node.lines[1].speaker or "" -- 370
	if (string.find(kind, "观测者", nil, true) or 0) - 1 >= 0 then -- 370
		return {x = 800, y = groundY + 88} -- 372
	end -- 372
	if ((string.find(kind, "沈砚", nil, true) or 0) - 1 >= 0 or (string.find(kind, "申言", nil, true) or 0) - 1 >= 0) and self.shenRenderOk then -- 372
		return {x = self.shenRenderX, y = self.shenRenderY + 92} -- 375
	end -- 375
	return {x = cx, y = groundY + 52} -- 377
end -- 365
function Game.prototype.syncInteractPrompt(self) -- 381
	if self.mode == "play" and not self.paused then -- 381
		if self.hintBubbleText ~= nil then -- 381
			self.renderer:setPrompt(self.hintBubbleX, self.hintBubbleY, self.hintBubbleText) -- 385
			return -- 386
		end -- 386
		if not self:inCombatNear() then -- 386
			if self.state.flags.confront then -- 386
				local cx6 = self:shenX() -- 392
				local cy6 = self:shenY() -- 393
				if math.abs(self.player.body.x - cx6) < 420 and math.abs(self.player.body.y - cy6) < 260 then -- 393
					self.renderer:setPrompt(cx6, cy6 + 130, "E 放下剑 · Q 以命换命 · J 剑锋相向") -- 395
					return -- 396
				end -- 396
			end -- 396
			local portal = self:nearPortal(self.player.body.x, self.player.body.y) -- 399
			if portal ~= nil then -- 399
				self.renderer:setPrompt(portal.x, portal.y + 130, "按 E 传送") -- 402
				return -- 403
			end -- 403
			if self.nearStoryId ~= nil then -- 403
				local anchor = self:storyPromptAnchor(self.nearStoryId) -- 406
				self.renderer:setPrompt(anchor.x, anchor.y, "按 E 对话") -- 407
				return -- 408
			end -- 408
		end -- 408
	end -- 408
	local cpHere = self:findCheckpoint(self.state.currentCheckpointId) -- 413
	if (cpHere and cpHere.floor or 0) == 0 and not self:inCombatNear() then -- 413
		local fx = self.state.flags -- 415
		local pxHere = self.player.body.x -- 416
		if not fx.treePlanted and not fx.saplingTaken and math.abs(pxHere - 700) < 90 then -- 416
			self.renderer:setPrompt(700, Tower.TOPS[1] + 46, "按 E 移取树苗") -- 418
			return -- 419
		end -- 419
		if not fx.bucketFull and not fx.treePlanted and math.abs(pxHere - 860) < 90 then -- 419
			self.renderer:setPrompt(860, Tower.TOPS[1] + 64, "按 E 打一桶井水") -- 422
			return -- 423
		end -- 423
		if fx.saplingTaken == true and fx.treePlanted ~= true and math.abs(pxHere - 1200) < 100 then -- 423
			self.renderer:setPrompt(1200, Tower.TOPS[1] + 46, "按 E 种下树苗") -- 426
			return -- 427
		end -- 427
	end -- 427
	local cpF1 = self:findCheckpoint(self.state.currentCheckpointId) -- 433
	if (cpF1 and cpF1.floor or 0) == 1 and not self:inCombatNear() then -- 433
		local px1 = self.player.body.x -- 435
		local py1 = self.player.body.y -- 436
		if math.abs(py1 - (Tower.TOPS[2] + 42)) < 90 then -- 436
			if self.state.pebbles <= 0 and math.abs(px1 - 1450) < 80 then -- 436
				self.renderer:setPrompt(1450, Tower.TOPS[2] + 96, "按 E 拾取石子（Q 丢石引开视线）") -- 439
				return -- 440
			end -- 440
			if self.state.flags.barrelDown ~= true and math.abs(px1 - 1900) < 90 then -- 440
				self.renderer:setPrompt(1900, Tower.TOPS[2] + 96, "按 E 踢倒酒桶（震晕附近守卫）") -- 443
				return -- 444
			end -- 444
			if self.state.flags.waiterFreed ~= true and math.abs(px1 - 1985) < 80 then -- 444
				self.renderer:setPrompt(1985, Tower.TOPS[2] + 96, "按 E 割绳救出店小二") -- 447
				return -- 448
			end -- 448
		end -- 448
	end -- 448
	local cpF4 = self:findCheckpoint(self.state.currentCheckpointId) -- 453
	if (cpF4 and cpF4.floor or 0) == 4 and not self.mech:isGateOpen("gate_mech") then -- 453
		local px4 = self.player.body.x -- 455
		local py4 = self.player.body.y -- 456
		local top4 = Tower.TOPS[5] -- 457
		local plateDone = self.state.platesActive.plate0 == true or self.state.platesActive.plate1 == true -- 458
		local slotDone = self.state.flags.swordslot_slot_mech == true -- 459
		if not plateDone and math.abs(py4 - (top4 + 40)) < 170 and #self.mech.stones > 0 then -- 459
			local sx4 = self.mech.stones[1].x -- 462
			local nearStone = math.abs(px4 - sx4) < 170 -- 463
			local nearPlate = math.abs(px4 - 900) < 120 or math.abs(px4 - 1300) < 120 -- 464
			if nearStone or nearPlate then -- 464
				local ax4 = nearStone and sx4 or (px4 < 1100 and 900 or 1300) -- 466
				self.renderer:setPrompt(ax4, top4 + 92, "按住 A/D 顶着石块推上石板") -- 467
				return -- 468
			end -- 468
		end -- 468
		if not slotDone and math.abs(px4 - 1500) < 140 and math.abs(py4 - (top4 + 40)) < 170 then -- 468
			self.renderer:setPrompt(1500, top4 + 100, "以剑气 K 插入剑槽") -- 473
			return -- 474
		end -- 474
	end -- 474
	local cpF3 = self:findCheckpoint(self.state.currentCheckpointId) -- 478
	if (cpF3 and cpF3.floor or 0) == 3 and not self.mech:isGateOpen("gate_corridor") and not self:inCombatNear() then -- 478
		local px3 = self.player.body.x -- 480
		local py3 = self.player.body.y -- 481
		do -- 481
			local i = 0 -- 482
			while i < #Tower.windSigils do -- 482
				do -- 482
					local s3 = Tower.windSigils[i + 1] -- 483
					if self.state.flags["wind_" .. s3.id] == true or math.abs(px3 - s3.x) >= 130 then -- 483
						goto __continue79 -- 485
					end -- 485
					if math.abs(py3 - (s3.y + 40)) >= 170 then -- 485
						goto __continue79 -- 489
					end -- 489
					local lit3 = 0 -- 491
					do -- 491
						local k = 0 -- 492
						while k < #Tower.windSigils do -- 492
							if self.state.flags["wind_" .. Tower.windSigils[k + 1].id] == true then -- 492
								lit3 = lit3 + 1 -- 494
							end -- 494
							k = k + 1 -- 492
						end -- 492
					end -- 492
					self.renderer:setPrompt( -- 498
						s3.x, -- 498
						s3.y + 96, -- 498
						((("冲刺穿过风息符文（" .. tostring(lit3)) .. "/") .. tostring(#Tower.windSigils)) .. "）" -- 498
					) -- 498
					return -- 499
				end -- 499
				::__continue79:: -- 499
				i = i + 1 -- 482
			end -- 482
		end -- 482
	end -- 482
	local cpF2 = self:findCheckpoint(self.state.currentCheckpointId) -- 504
	if (cpF2 and cpF2.floor or 0) == 2 and not self.mech:isGateOpen("lanternGate") and not self:inCombatNear() then -- 504
		local px2 = self.player.body.x -- 506
		local py2 = self.player.body.y -- 507
		do -- 507
			local i = 0 -- 508
			while i < #Tower.lanterns do -- 508
				do -- 508
					local lt2 = Tower.lanterns[i + 1] -- 509
					if self.state.lanternsLit[lt2.id] == true then -- 509
						goto __continue87 -- 511
					end -- 511
					if math.abs(px2 - lt2.x) >= 110 or math.abs(py2 - lt2.y) >= 150 then -- 511
						goto __continue87 -- 514
					end -- 514
					local lit2 = 0 -- 516
					do -- 516
						local k = 0 -- 517
						while k < #Tower.lanterns do -- 517
							if self.state.lanternsLit[Tower.lanterns[k + 1].id] == true then -- 517
								lit2 = lit2 + 1 -- 519
							end -- 519
							k = k + 1 -- 517
						end -- 517
					end -- 517
					local expected2 = self.state.lanternSequence + 1 -- 522
					local tip2 = lt2.order == expected2 and ((("按 E 点亮悬灯（" .. tostring(lit2)) .. "/") .. tostring(#Tower.lanterns)) .. "，依序）" or ("此灯未轮到——先点亮第 " .. tostring(expected2)) .. " 盏悬灯" -- 523
					self.renderer:setPrompt(lt2.x, lt2.y + 96, tip2) -- 526
					return -- 527
				end -- 527
				::__continue87:: -- 527
				i = i + 1 -- 508
			end -- 508
		end -- 508
	end -- 508
	local cpF5 = self:findCheckpoint(self.state.currentCheckpointId) -- 531
	if (cpF5 and cpF5.floor or 0) == 5 and not self.mech:isGateOpen("gate_star") and not self:inCombatNear() then -- 531
		local px5 = self.player.body.x -- 533
		local py5 = self.player.body.y -- 534
		do -- 534
			local i = 0 -- 535
			while i < #Tower.starNodes do -- 535
				do -- 535
					local s5 = Tower.starNodes[i + 1] -- 536
					if self.state.flags["star_" .. s5.id] == true then -- 536
						goto __continue95 -- 538
					end -- 538
					if math.abs(px5 - s5.x) >= 110 or math.abs(py5 - s5.y) >= 150 then -- 538
						goto __continue95 -- 541
					end -- 541
					local lit5 = 0 -- 543
					do -- 543
						local k = 0 -- 544
						while k < #Tower.starNodes do -- 544
							if self.state.flags["star_" .. Tower.starNodes[k + 1].id] == true then -- 544
								lit5 = lit5 + 1 -- 546
							end -- 546
							k = k + 1 -- 544
						end -- 544
					end -- 544
					self.renderer:setPrompt( -- 549
						s5.x, -- 549
						s5.y + 96, -- 549
						((("按 E 点亮星位（" .. tostring(lit5)) .. "/") .. tostring(#Tower.starNodes)) .. "，错序将熄灭）" -- 549
					) -- 549
					return -- 550
				end -- 550
				::__continue95:: -- 550
				i = i + 1 -- 535
			end -- 535
		end -- 535
	end -- 535
	self.renderer:setPrompt(0, 0, nil) -- 553
end -- 381
function Game.prototype.inCombatNear(self) -- 557
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 558
	local floor = cp and cp.floor or 0 -- 559
	local infos = self.enemies:stealthInfos() -- 560
	do -- 560
		local i = 0 -- 561
		while i < #infos do -- 561
			do -- 561
				local inf = infos[i + 1] -- 562
				if inf.floor ~= floor then -- 562
					goto __continue103 -- 564
				end -- 564
				if inf.state == "patrol" or inf.state == "dead" then -- 564
					goto __continue103 -- 567
				end -- 567
				if math.abs(inf.x - self.player.body.x) < 560 then -- 567
					return true -- 570
				end -- 570
			end -- 570
			::__continue103:: -- 570
			i = i + 1 -- 561
		end -- 561
	end -- 561
	return false -- 573
end -- 557
function Game.prototype.shake(self, t, mag) -- 576
	self.shakeT = t -- 577
	self.shakeMag = mag -- 578
end -- 576
function Game.prototype.buildInput(self, active) -- 581
	if not active then -- 581
		return { -- 583
			left = false, -- 583
			right = false, -- 583
			up = false, -- 583
			down = false, -- 583
			jumpPressed = false, -- 583
			attackPressed = false, -- 583
			qiPressed = false, -- 583
			dashPressed = false -- 583
		} -- 583
	end -- 583
	return { -- 585
		left = Keyboard:isKeyPressed("A"), -- 586
		right = Keyboard:isKeyPressed("D"), -- 587
		up = Keyboard:isKeyPressed("W"), -- 588
		down = Keyboard:isKeyPressed("S"), -- 589
		jumpPressed = Keyboard:isKeyDown("Space"), -- 590
		attackPressed = Keyboard:isKeyDown("J"), -- 591
		qiPressed = Keyboard:isKeyDown("K"), -- 592
		dashPressed = Keyboard:isKeyDown("LShift") -- 593
	} -- 593
end -- 581
function Game.prototype.onKey(self, key) -- 597
	if key == "Escape" then -- 597
		if self.tree ~= nil and self.tree:isOverlayOpen() then -- 597
			self.tree:handleKey(key) -- 601
			return -- 602
		end -- 602
		local inPlay = self.mode == "play" or self.mode == "confront" -- 604
		if inPlay or self.paused then -- 604
			self.paused = not self.paused -- 606
			self.hud:setPauseVisible(self.paused) -- 607
			return -- 608
		end -- 608
	end -- 608
	repeat -- 608
		local ____switch114 = self.mode -- 608
		local ____cond114 = ____switch114 == "title" -- 608
		if ____cond114 then -- 608
			if self.nameEntry:isOpen() then -- 608
				self.nameEntry:handleKey(key) -- 615
				break -- 616
			end -- 616
			if self.gallery:isOpen() then -- 616
				self.gallery:handleKey(key) -- 619
				break -- 620
			end -- 620
			self.hud:handleTitleKey(key) -- 622
			break -- 623
		end -- 623
		____cond114 = ____cond114 or ____switch114 == "prologue" -- 623
		if ____cond114 then -- 623
			if key == "Escape" and self.intro then -- 623
				self.intro:skip() -- 626
			end -- 626
			break -- 628
		end -- 628
		____cond114 = ____cond114 or (____switch114 == "play" or ____switch114 == "confront") -- 628
		if ____cond114 then -- 628
			if not self.paused then -- 628
				self:onPlayKey(key) -- 632
			end -- 632
			break -- 634
		end -- 634
		____cond114 = ____cond114 or ____switch114 == "dialog" -- 634
		if ____cond114 then -- 634
			if key == "W" then -- 634
				self.dialog:moveChoice(-1) -- 637
			elseif key == "S" then -- 637
				self.dialog:moveChoice(1) -- 639
			elseif key == "E" or key == "Space" or key == "Return" then -- 639
				if self.dialog:inChoiceMode() then -- 639
					self.dialog:confirmChoice() -- 643
				else -- 643
					self.dialog:advance() -- 645
				end -- 645
			end -- 645
			break -- 648
		end -- 648
		____cond114 = ____cond114 or ____switch114 == "dead" -- 648
		if ____cond114 then -- 648
			if key == "R" then -- 648
				if self.state.maxLife <= 1 then -- 648
					self:toTitle() -- 653
				else -- 653
					self:startRewind() -- 655
				end -- 655
			end -- 655
			break -- 658
		end -- 658
		____cond114 = ____cond114 or ____switch114 == "ending" -- 658
		if ____cond114 then -- 658
			if key == "R" then -- 658
				self:toTitle() -- 661
			end -- 661
			break -- 663
		end -- 663
		do -- 663
			break -- 665
		end -- 665
	until true -- 665
end -- 597
function Game.prototype.onPlayKey(self, key) -- 669
	if self.tree ~= nil then -- 669
		self.tree:handleKey(key) -- 672
	end -- 672
	if key == "Tab" then -- 672
		self.notebook:toggle() -- 675
		return -- 676
	end -- 676
	if key == "E" then -- 676
		self:interact() -- 679
		return -- 680
	end -- 680
	if key == "R" then -- 680
		self:startRewind() -- 683
	end -- 683
	if key == "Q" then -- 683
		self:onQ() -- 686
	end -- 686
end -- 669
function Game.prototype.onQ(self) -- 691
	if self.mode == "play" then -- 691
		self:throwPebble() -- 693
		return -- 694
	end -- 694
	if self.mode == "confront" then -- 694
		local px = self.player.body.x -- 697
		local py = self.player.body.y -- 698
		if math.abs(px - self:shenX()) < 150 and math.abs(py - self:shenY()) < 200 then -- 698
			if self.tree ~= nil then -- 698
				self.tree:addChoice("以命换命") -- 701
			end -- 701
			self:logCause("以命换命·月相永驻") -- 703
			self:endGame("sacrifice") -- 704
		end -- 704
	end -- 704
end -- 691
function Game.prototype.tick(self, dt) -- 709
	self.time = self.time + dt -- 710
	self.causFx:update(dt) -- 711
	local shakeX = 0 -- 712
	local shakeY = 0 -- 713
	if self.shakeT > 0 then -- 713
		self.shakeT = self.shakeT - dt -- 715
		shakeX = (math.random() * 2 - 1) * self.shakeMag -- 716
		shakeY = (math.random() * 2 - 1) * self.shakeMag -- 717
	end -- 717
	if self.mode == "prologue" and self.intro then -- 717
		self.intro:update(math.min(dt, 0.05)) -- 721
		if self.intro:done() then -- 721
			self.intro = nil -- 723
			self:toTitle() -- 724
		end -- 724
	elseif self.mode == "rewind" then -- 724
		self.rewindT = self.rewindT + dt -- 728
		self.hud:setRewind(math.min(1, self.rewindT / 2)) -- 729
		if self.rewindT >= 2 then -- 729
			self.hud:setRewind(-1) -- 731
			self:doRewind() -- 732
		end -- 732
	elseif self.mode == "dead" then -- 732
		if self.deadT > 0 then -- 732
			self.deadT = self.deadT - dt -- 737
			if self.deadT <= 0 then -- 737
				self:startRewind() -- 739
			end -- 739
		end -- 739
	elseif self.mode == "dialog" then -- 739
		if not self.dialog:isOpen() then -- 739
			self.mode = "play" -- 745
		else -- 745
			self.dialog:update(dt) -- 747
		end -- 747
	elseif (self.mode == "play" or self.mode == "confront") and not self.paused then -- 747
		if self.hitstop > 0 then -- 747
			self.hitstop = self.hitstop - dt -- 751
		else -- 751
			if self.bladeT > 0 then -- 751
				self.bladeT = self.bladeT - dt -- 754
				if self.bladeT <= 0 then -- 754
					self:endGame("blade") -- 756
				end -- 756
			end -- 756
			self:tickPendingFloorStory(dt) -- 759
			if self.mode == "play" or self.mode == "confront" then -- 759
				if self.teleportT >= 0 then -- 759
					self:advanceTeleport(dt) -- 762
				else -- 762
					self:simWorld(dt) -- 764
				end -- 764
			end -- 764
		end -- 764
	end -- 764
	self:updateVisuals(dt, shakeX, shakeY) -- 769
end -- 709
function Game.prototype.updateMovers(self) -- 772
	local plats = Tower.platforms -- 773
	do -- 773
		local i = 0 -- 774
		while i < #plats do -- 774
			do -- 774
				local p = plats[i + 1] -- 775
				if not p.mover then -- 775
					goto __continue161 -- 777
				end -- 777
				local m = p.mover -- 779
				local s = 0.5 - 0.5 * math.cos((self.time / m.period + m.phase) * 6.2831853) -- 780
				local nx = lerp(m.ax, m.bx, s) -- 781
				local ny = lerp(m.ay, m.by, s) -- 782
				local dx = nx - p.x -- 783
				local dy = ny - p.y -- 784
				p.x = nx -- 785
				p.y = ny -- 786
				if self.player.body.groundId == p.id then -- 786
					local ____self_player_body_0, ____x_1 = self.player.body, "x" -- 786
					____self_player_body_0[____x_1] = ____self_player_body_0[____x_1] + dx -- 788
					local ____self_player_body_2, ____y_3 = self.player.body, "y" -- 788
					____self_player_body_2[____y_3] = ____self_player_body_2[____y_3] + dy -- 789
				end -- 789
			end -- 789
			::__continue161:: -- 789
			i = i + 1 -- 774
		end -- 774
	end -- 774
end -- 772
function Game.prototype.beginLoop(self) -- 794
	self.tree = __TS__New(TreeSystem, "启程") -- 796
	self.tree:attachTo(self.uiRoot) -- 797
	self.tree.onJumpTo = function(____, id) return self:jumpToNode(id) end -- 799
	self.tree.onNodeAdded = function(____, id) -- 801
		self.treeSnap[id] = self:cloneLoopState(self.state) -- 802
	end -- 801
	self.treeSnap[self.tree.nodes[1].id] = self:cloneLoopState(self.state) -- 804
	self.treeArchived = false -- 805
	self.treeFloorSeen = {} -- 807
	self.treeGateSeen = {} -- 808
	self.treeDeathSeen = false -- 809
	self:growFloor(0) -- 810
	self.causFx:clear() -- 811
	self.stealth:resetRuntime() -- 812
	self:applyLoopVariants() -- 813
	self.mode = "play" -- 814
	self:playFloorBgm(1.5) -- 815
end -- 794
function Game.prototype.growFloor(self, floor) -- 821
	if self.tree == nil or self.treeFloorSeen[floor] == true then -- 821
		return -- 823
	end -- 823
	self.treeFloorSeen[floor] = true -- 825
	local short = { -- 827
		"初临河滩", -- 827
		"入古镇街巷", -- 827
		"上悬空工坊", -- 827
		"登塔外环廊", -- 827
		"探机关层", -- 827
		"入观星之间", -- 827
		"登观星台" -- 827
	} -- 827
	local name = floor >= 0 and floor < #short and short[floor + 1] or "行至新境" -- 828
	self.tree:extend(name) -- 829
end -- 821
function Game.prototype.growGate(self, gateId) -- 832
	if self.tree == nil or self.treeGateSeen[gateId] == true then -- 832
		return -- 834
	end -- 834
	self.treeGateSeen[gateId] = true -- 836
	local via = gateId == "gate_bell" and "钟鸣桥落" or (gateId == "gate_corridor" and "双信闸启" or (gateId == "gate_mech" and "压石嵌剑" or (gateId == "gate_star" and "星门台现" or "闸开"))) -- 837
	self.tree:extend(via) -- 846
end -- 832
function Game.prototype.growNight(self) -- 849
	if self.tree == nil then -- 849
		return -- 851
	end -- 851
	local n = self.state.loopIndex + 1 -- 853
	local cn = { -- 854
		"", -- 854
		"一", -- 854
		"二", -- 854
		"三", -- 854
		"四", -- 854
		"五", -- 854
		"六", -- 854
		"七", -- 854
		"八", -- 854
		"九" -- 854
	} -- 854
	local label = n <= 9 and ("第" .. cn[n + 1]) .. "夜重溯" or ("第" .. tostring(n)) .. "夜" -- 855
	self.tree:extend(label) -- 856
end -- 849
function Game.prototype.simWorld(self, dt) -- 859
	self:updateMovers() -- 860
	local plats = activePlatforms(Tower.platforms, self.state.openedGates) -- 861
	local ctx = { -- 863
		platforms = plats, -- 863
		ladders = self:activeLadders(), -- 863
		climbWalls = Tower.climbWalls -- 863
	} -- 863
	local wasGround = self.player.body.onGround -- 864
	local vyBefore = self.player.body.vy -- 865
	local input = self:buildInput(true) -- 866
	self.player:update(dt, input, ctx) -- 867
	self:consumeAttack() -- 868
	self:consumeQi() -- 869
	self:updateSwingArc(dt) -- 870
	local pbody = self.player.body -- 871
	local prect = bodyRect(pbody) -- 872
	self.enemies:update( -- 873
		dt, -- 873
		pbody.x, -- 873
		pbody.y, -- 873
		prect, -- 873
		self.player:isInvulnerable(), -- 873
		ctx, -- 873
		pbody.vy -- 873
	) -- 873
	local cpNow = self:findCheckpoint(self.state.currentCheckpointId) -- 875
	local pfloor = cpNow and cpNow.floor or 0 -- 876
	local landing = not wasGround and self.player.body.onGround and vyBefore < -420 and -vyBefore or 0 -- 877
	self.stealth:update( -- 880
		dt, -- 880
		pbody.x, -- 880
		pbody.y, -- 880
		self.player.dashTimer > 0, -- 880
		{landingSpeed = landing > 0 and landing or nil, floor = pfloor, attackX = self.player.attack ~= nil and pbody.x or nil} -- 880
	) -- 880
	local alerted = self.stealth:anyAlerted() -- 885
	self.state.stealthAlert = alerted -- 886
	if alerted and pfloor == 1 then -- 886
		self.floor1Alert = true -- 888
	end -- 888
	local pushDir = (input.right and 1 or 0) - (input.left and 1 or 0) -- 891
	self.mech:update( -- 892
		dt, -- 892
		prect, -- 892
		pushDir, -- 892
		self:playerAttackRect(), -- 892
		self:qiRects(), -- 892
		ctx -- 892
	) -- 892
	if self.player.dashTimer > 0 then -- 892
		self.mech:tryDashWindSigils(pbody.x, pbody.y) -- 895
	end -- 895
	self:clampPlayerToStones(prect) -- 897
	self:updateQiShots(dt, plats) -- 898
	if pbody.y < -240 and (self.mode == "play" or self.mode == "confront") then -- 898
		self:pitFall() -- 900
	end -- 900
	if self.mode == "play" then -- 900
		self.mech:touchCheckpoints(Tower.checkpoints, pbody.x, pbody.y) -- 903
		self.mech:touchCollectibles(Tower.collectibles, pbody.x, pbody.y) -- 904
		self:checkStoryTriggers() -- 905
		self:checkHazards() -- 906
	end -- 906
	local boss = self.enemies:boss() -- 908
	if boss and not self.state.storySeen.story_boss_intro and not self.state.flags.bossDown then -- 908
		local b = boss.body -- 910
		if math.abs(b.x - pbody.x) < 520 and math.abs(b.y - pbody.y) < 320 then -- 910
			self:openDialog("story_boss_intro") -- 912
		end -- 912
	end -- 912
	self:regenIntent(dt) -- 915
	if pbody.y < -80 then -- 915
		if self.player:hurt(1, pbody.x) then -- 915
			self:applyHurt(1) -- 918
		end -- 918
		if self.state.heroineLife > 0 then -- 918
			self:respawnAt(self.state.currentCheckpointId) -- 921
		end -- 921
	end -- 921
end -- 859
function Game.prototype.playerAttackRect(self) -- 926
	return self.player.attack and self.player.attack.hitbox or nil -- 927
end -- 926
function Game.prototype.clampPlayerToStones(self, prect) -- 932
	local b = self.player.body -- 933
	do -- 933
		local i = 0 -- 934
		while i < #self.mech.stones do -- 934
			do -- 934
				local s = self.mech.stones[i + 1] -- 935
				local sx = s.x - s.w / 2 -- 936
				local sy = s.y - s.h / 2 -- 937
				local overlapX = prect.x < sx + s.w and prect.x + prect.w > sx -- 938
				local overlapY = prect.y < sy + s.h and prect.y + prect.h > sy -- 939
				if not overlapX or not overlapY then -- 939
					goto __continue186 -- 941
				end -- 941
				local penLeft = prect.x + prect.w - sx -- 943
				local penRight = sx + s.w - prect.x -- 944
				if penLeft < penRight and penLeft <= 30 then -- 944
					b.x = sx - prect.w / 2 -- 946
				elseif penRight < penLeft and penRight <= 30 then -- 946
					b.x = sx + s.w + prect.w / 2 -- 948
				end -- 948
			end -- 948
			::__continue186:: -- 948
			i = i + 1 -- 934
		end -- 934
	end -- 934
end -- 932
function Game.prototype.consumeAttack(self) -- 953
	local atk = self.player.attack -- 954
	if not atk then -- 954
		self.attackApplied = false -- 956
		return -- 957
	end -- 957
	if self.attackApplied then -- 957
		return -- 960
	end -- 960
	self.attackApplied = true -- 962
	local hits = self.enemies:takeHit( -- 963
		atk.hitbox, -- 963
		1, -- 963
		atk.dir, -- 963
		220, -- 963
		self.player.body.x -- 963
	) -- 963
	if self.state.flags.treePlanted == true and self.state.flags.treeCut ~= true then -- 963
		local hb = atk.hitbox -- 966
		local tx = 1120 -- 967
		if hb.x < tx + 160 and hb.x + hb.w > tx and hb.y < Tower.TOPS[1] + 300 and hb.y + hb.h > Tower.TOPS[1] then -- 967
			self:cutTree() -- 969
		end -- 969
	end -- 969
	if hits > 0 then -- 969
		self.hitstop = 0.06 -- 973
		sfx("heroHit", 0.9) -- 974
		sfx("enemyHurt", 0.65) -- 975
		self.fx:spawnSpark(atk.hitbox.x + (atk.dir > 0 and atk.hitbox.w or 0), atk.hitbox.y + atk.hitbox.h / 2, atk.dir) -- 976
	end -- 976
	if self.state.flags.confront and not self.state.drawnBladeAgainst then -- 976
		local dx = math.abs(atk.hitbox.x + atk.hitbox.w / 2 - self:shenX()) -- 979
		local dy = math.abs(atk.hitbox.y + atk.hitbox.h / 2 - self:shenY()) -- 980
		if dx < 130 and dy < 130 then -- 980
			self.state.drawnBladeAgainst = true -- 982
			self.state.flags.bladeClash = true -- 983
			self.bladeT = 0.9 -- 984
			self:shake(0.3, 7) -- 985
			self.fx:spawnRing( -- 986
				self:shenX(), -- 986
				self:shenY() + 30, -- 986
				{r = 43, g = 40, b = 36, a = 255}, -- 986
				20, -- 986
				180, -- 986
				0.6 -- 986
			) -- 986
			if self.tree ~= nil then -- 986
				self.tree:addChoice("剑锋相向") -- 989
			end -- 989
			self:logCause("剑锋相向·因果断裂") -- 991
		end -- 991
	end -- 991
end -- 953
function Game.prototype.consumeQi(self) -- 996
	local req = self.player.qiReq -- 997
	if not req then -- 997
		return -- 999
	end -- 999
	self.player.qiReq = nil -- 1001
	if self.state.swordIntent < 1 then -- 1001
		self.fx:spawnDust(req.x, req.y, req.dir) -- 1003
		return -- 1004
	end -- 1004
	local ____self_state_4, ____swordIntent_5 = self.state, "swordIntent" -- 1004
	____self_state_4[____swordIntent_5] = ____self_state_4[____swordIntent_5] - 1 -- 1006
	sfx("sword", 1) -- 1007
	local ____self_qiShots_6 = self.qiShots -- 1007
	____self_qiShots_6[#____self_qiShots_6 + 1] = { -- 1008
		x = req.x, -- 1008
		y = req.y, -- 1008
		dir = req.dir, -- 1008
		life = 1.6, -- 1008
		alive = true, -- 1008
		phase = #self.qiShots * 1.7, -- 1008
		hits = 0, -- 1008
		hitCd = 0, -- 1008
		trailT = 0 -- 1008
	} -- 1008
	self.fx:spawnInkBurst(req.x, req.y, req.dir) -- 1009
	self.sheetFx:spawn(req.x + req.dir * 14, req.y, req.dir, true) -- 1010
	self.slashFx:spawnSwing(req.x + req.dir * 10, req.y, req.dir, true) -- 1012
	self.qiSwingT = 0.2 -- 1013
end -- 996
function Game.prototype.updateSwingArc(self, dt) -- 1017
	if self.qiSwingT > 0 then -- 1017
		self.qiSwingT = self.qiSwingT - dt -- 1019
	end -- 1019
	if self.player.attackTimer <= 0 then -- 1019
		self.lastSwingSeq = -1 -- 1022
		return -- 1023
	end -- 1023
	local seq = self.player.attackSeq -- 1025
	if seq ~= self.lastSwingSeq then -- 1025
		self.lastSwingSeq = seq -- 1027
		if self.qiSwingT <= 0 then -- 1027
			self.slashFx:spawnSwing(self.player.body.x + self.player.facing * 26, self.player.body.y + 8, self.player.facing, false) -- 1029
		end -- 1029
	end -- 1029
end -- 1017
function Game.prototype.qiRects(self) -- 1034
	local list = {} -- 1035
	do -- 1035
		local i = 0 -- 1036
		while i < #self.qiShots do -- 1036
			local q = self.qiShots[i + 1] -- 1037
			if q.alive then -- 1037
				list[#list + 1] = {x = q.x - 20, y = q.y - 32, w = 90, h = 64} -- 1039
			end -- 1039
			i = i + 1 -- 1036
		end -- 1036
	end -- 1036
	return list -- 1042
end -- 1034
function Game.prototype.updateQiShots(self, dt, plats) -- 1045
	do -- 1045
		local i = 0 -- 1046
		while i < #self.qiShots do -- 1046
			do -- 1046
				local q = self.qiShots[i + 1] -- 1047
				if not q.alive then -- 1047
					goto __continue213 -- 1049
				end -- 1049
				q.x = q.x + q.dir * 720 * dt -- 1051
				q.life = q.life - dt -- 1052
				q.hitCd = q.hitCd - dt -- 1053
				q.trailT = q.trailT - dt -- 1054
				if q.trailT <= 0 then -- 1054
					self.sheetFx:spawn(q.x - q.dir * 18, q.y, q.dir, false) -- 1056
					q.trailT = 0.1 -- 1057
				end -- 1057
				if q.life <= 0 then -- 1057
					q.alive = false -- 1060
					goto __continue213 -- 1061
				end -- 1061
				local rect = {x = q.x - 20, y = q.y - 32, w = 90, h = 64} -- 1063
				if q.hitCd <= 0 and self.enemies:takeHit(rect, 1, q.dir, 160) > 0 then -- 1063
					q.hits = q.hits + 1 -- 1065
					q.hitCd = 0.22 -- 1066
					self.hitstop = 0.05 -- 1067
					self.fx:spawnInkBurst(q.x, q.y, q.dir) -- 1068
					self.sheetFx:spawn(q.x + q.dir * 6, q.y, q.dir, true) -- 1069
					if q.hits >= 3 then -- 1069
						q.alive = false -- 1071
						goto __continue213 -- 1072
					end -- 1072
				end -- 1072
				do -- 1072
					local j = 0 -- 1075
					while j < #plats do -- 1075
						local p = plats[j + 1] -- 1076
						if p.kind ~= "one-way" and rectOverlap(rect, p) then -- 1076
							q.alive = false -- 1078
							self.fx:spawnDust(q.x, q.y, -q.dir) -- 1079
							self.sheetFx:spawn(q.x, q.y, q.dir, false) -- 1080
							break -- 1081
						end -- 1081
						j = j + 1 -- 1075
					end -- 1075
				end -- 1075
			end -- 1075
			::__continue213:: -- 1075
			i = i + 1 -- 1046
		end -- 1046
	end -- 1046
end -- 1045
function Game.prototype.regenIntent(self, dt) -- 1087
	if self.state.swordIntent >= self.state.maxSwordIntent then -- 1087
		return -- 1089
	end -- 1089
	self.intentRegenT = self.intentRegenT + dt -- 1091
	if self.intentRegenT >= 5 then -- 1091
		self.intentRegenT = 0 -- 1093
		local ____self_state_7, ____swordIntent_8 = self.state, "swordIntent" -- 1093
		____self_state_7[____swordIntent_8] = ____self_state_7[____swordIntent_8] + 1 -- 1094
	end -- 1094
end -- 1087
function Game.prototype.checkStoryTriggers(self) -- 1115
	self.nearStoryId = nil -- 1116
	self.hintBubbleText = nil -- 1117
	self.hintBubbleBestD = 1000000000 -- 1118
	local prect = bodyRect(self.player.body) -- 1119
	local trigs = Tower.storyTriggers -- 1120
	local bestD = 1000000000 -- 1121
	do -- 1121
		local i = 0 -- 1122
		while i < #trigs do -- 1122
			do -- 1122
				local t = trigs[i + 1] -- 1123
				if t.hint ~= nil then -- 1123
					if rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1123
						local d = math.abs(self.player.body.x - (t.x + t.w / 2)) -- 1128
						if d < self.hintBubbleBestD then -- 1128
							self.hintBubbleBestD = d -- 1130
							self.hintBubbleText = t.hint -- 1131
							self.hintBubbleX = t.x + t.w -- 1132
							self.hintBubbleY = t.y + t.h -- 1133
						end -- 1133
					end -- 1133
					goto __continue227 -- 1136
				end -- 1136
				if t.storyId == "story_arrow" then -- 1136
					if not self.state.storySeen[t.storyId] and rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1136
						self:openDialog(t.storyId) -- 1141
						return -- 1142
					end -- 1142
					goto __continue227 -- 1144
				end -- 1144
				if t.once and self.state.storySeen[t.storyId] then -- 1144
					goto __continue227 -- 1147
				end -- 1147
				if self:isAutoMonologue(t.storyId) then -- 1147
					if rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1147
						self:openDialog(t.storyId) -- 1152
						return -- 1153
					end -- 1153
					goto __continue227 -- 1155
				end -- 1155
				if rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1155
					local d = math.abs(self.player.body.x - (t.x + t.w / 2)) -- 1158
					if d < bestD then -- 1158
						bestD = d -- 1160
						self.nearStoryId = t.storyId -- 1161
					end -- 1161
				end -- 1161
			end -- 1161
			::__continue227:: -- 1161
			i = i + 1 -- 1122
		end -- 1122
	end -- 1122
end -- 1115
function Game.prototype.checkHazards(self) -- 1167
	local prect = bodyRect(self.player.body) -- 1168
	local hs = Tower.hazards -- 1169
	do -- 1169
		local i = 0 -- 1170
		while i < #hs do -- 1170
			if rectOverlap(prect, hs[i + 1]) then -- 1170
				if self.player:hurt(hs[i + 1].damage, self.player.body.x) then -- 1170
					self:applyHurt(hs[i + 1].damage) -- 1173
				end -- 1173
				break -- 1177
			end -- 1177
			i = i + 1 -- 1170
		end -- 1170
	end -- 1170
end -- 1167
function Game.prototype.nearBoss(self) -- 1184
	local b = self.enemies:boss() -- 1185
	if b == nil then -- 1185
		return false -- 1187
	end -- 1187
	return math.abs(b.body.x - self.player.body.x) < 720 and math.abs(b.body.y - self.player.body.y) < 240 -- 1189
end -- 1184
function Game.prototype.onPlayerHit(self, dmg, fromX) -- 1192
	if self.player:hurt(dmg, fromX) then -- 1192
		self:applyHurt(dmg) -- 1194
	end -- 1194
end -- 1192
function Game.prototype.applyHurt(self, dmg) -- 1198
	self.state.heroineLife = math.max(0, self.state.heroineLife - dmg) -- 1199
	self.hud:flashDamage() -- 1200
	self:shake(0.22, 6) -- 1201
	self.hitstop = 0.08 -- 1202
	if self.state.heroineLife <= 0 then -- 1202
		self:die() -- 1204
	end -- 1204
end -- 1198
function Game.prototype.interact(self) -- 1208
	local px = self.player.body.x -- 1209
	local py = self.player.body.y -- 1210
	local portal = self:nearPortal(px, py) -- 1211
	if portal ~= nil then -- 1211
		self:startPortal(portal) -- 1213
		return -- 1214
	end -- 1214
	if self.nearStoryId ~= nil then -- 1214
		local id = self.nearStoryId -- 1217
		self.nearStoryId = nil -- 1218
		self:openDialog(id) -- 1219
		return -- 1220
	end -- 1220
	if self.mech:tryLightLantern(Tower.lanterns, px, py) then -- 1220
		return -- 1223
	end -- 1223
	if self.mech:tryLightStar(px, py) then -- 1223
		return -- 1227
	end -- 1227
	if self:tryTreePuzzle(px, py) then -- 1227
		return -- 1231
	end -- 1231
	if self:tryPebblePickup(px, py) then -- 1231
		return -- 1234
	end -- 1234
	if self:tryBarrel(px, py) then -- 1234
		return -- 1237
	end -- 1237
	if self:tryWaiter(px, py) then -- 1237
		return -- 1240
	end -- 1240
	local nearShen = math.abs(px - self:shenX()) < 90 and math.abs(py - self:shenY()) < 140 -- 1242
	if self.state.flags.confront and nearShen then -- 1242
		self:putDownSword() -- 1244
		return -- 1245
	end -- 1245
	if not self.state.storySeen.story_check_intro and nearShen then -- 1245
		self:openDialog("story_check_intro") -- 1248
		return -- 1249
	end -- 1249
	if not self.state.storySeen.story_riverside and nearShen then -- 1249
		self:openDialog("story_riverside") -- 1253
	end -- 1253
end -- 1208
function Game.prototype.putDownSword(self) -- 1257
	self.state.drawnBladeAgainst = false -- 1258
	self.state.flags.putDownSword = true -- 1259
	if self.state.shenyanTrust >= 4 then -- 1259
		if self.tree ~= nil then -- 1259
			self.tree:addChoice("重逢月满") -- 1262
		end -- 1262
		self:endGame("reunion") -- 1264
	else -- 1264
		self.state.objective = "他叹息离去——也许，还有下一次轮回。（回溯再试试）" -- 1266
		self:loopAdvance() -- 1267
	end -- 1267
end -- 1257
function Game.prototype.openDialog(self, id) -- 1274
	local node = STORY_NODES[id] -- 1275
	if node == nil then -- 1275
		return -- 1277
	end -- 1277
	self.state.storySeen[id] = true -- 1279
	if node.setFlag then -- 1279
		self.state.flags[node.setFlag] = true -- 1281
	end -- 1281
	if node.objective then -- 1281
		self.state.objective = node.objective -- 1284
	end -- 1284
	self.mode = "dialog" -- 1286
	local loops = "" .. tostring(7 + self.state.rewindCount) -- 1288
	local lines = __TS__ArrayMap( -- 1289
		node.lines, -- 1289
		function(____, ln) return { -- 1289
			speaker = ln.speaker, -- 1289
			text = __TS__StringReplace(ln.text, "{loops}", loops) -- 1289
		} end -- 1289
	) -- 1289
	local asked = self.state.askedChoices -- 1291
	local allChoices = node.choices -- 1292
	local openChoices = allChoices ~= nil and __TS__ArrayFilter( -- 1293
		allChoices, -- 1293
		function(____, c) return not asked[(node.id .. "|") .. c.text] end -- 1293
	) or nil -- 1293
	local runtime = __TS__ObjectAssign({}, node, {lines = lines, choices = openChoices}) -- 1294
	self.askList = openChoices ~= nil and __TS__ArraySlice(openChoices) or ({}) -- 1295
	self.dialog.onChoiceAsk = function(____, index) return self:onChoiceAsk(runtime, index) end -- 1296
	self.dialog.onChoice = function(____, index) return self:applyChoice(runtime, index) end -- 1297
	local speaker = #runtime.lines > 0 and runtime.lines[1].speaker or "沈砚" -- 1298
	self.dialog:open(runtime, speaker) -- 1299
end -- 1274
function Game.prototype.onChoiceAsk(self, node, index) -- 1303
	local choice = node.choices ~= nil and node.choices[index + 1] or nil -- 1304
	if choice == nil then -- 1304
		return -- 1306
	end -- 1306
	local ____self_state_9, ____shenyanTrust_10 = self.state, "shenyanTrust" -- 1306
	____self_state_9[____shenyanTrust_10] = ____self_state_9[____shenyanTrust_10] + choice.trust -- 1308
	if choice.memory and __TS__ArrayIndexOf(self.state.memories, choice.memory) < 0 then -- 1308
		local ____self_state_memories_11 = self.state.memories -- 1308
		____self_state_memories_11[#____self_state_memories_11 + 1] = choice.memory -- 1310
	end -- 1310
	self.fx:spawnRing( -- 1312
		self.player.body.x, -- 1312
		self.player.body.y + 30, -- 1312
		CYAN, -- 1312
		10, -- 1312
		90, -- 1312
		0.5 -- 1312
	) -- 1312
	self.state.askedChoices[(node.id .. "|") .. choice.text] = true -- 1313
	local remaining = {} -- 1316
	if node.id == "story_observer_1" then -- 1316
		remaining = __TS__ArrayFilter( -- 1318
			self.askList, -- 1318
			function(____, c) return not self.state.askedChoices[(node.id .. "|") .. c.text] end -- 1318
		) -- 1318
	end -- 1318
	self.dialog:setNextChoices(remaining) -- 1320
end -- 1303
function Game.prototype.applyChoice(self, node, index) -- 1325
	if node.id == "story_arrow" and index == 0 then -- 1325
		self:onPlayerHit(1, self.player.body.x + 60) -- 1328
	end -- 1328
	if node.id == "story_final" then -- 1328
		self.state.flags.confront = true -- 1331
		self.state.objective = "走近沈砚：E 放下剑 · Q 以命换命 · J 剑锋相向" -- 1332
		self.mode = "confront" -- 1333
	elseif self.mode == "dialog" then -- 1333
		self.mode = "play" -- 1335
	end -- 1335
end -- 1325
function Game.prototype.shenProgress(self) -- 1339
	local trigs = Tower.storyTriggers -- 1340
	local n = 0 -- 1341
	do -- 1341
		local i = 0 -- 1342
		while i < #trigs do -- 1342
			if self.state.storySeen[trigs[i + 1].storyId] then -- 1342
				n = n + 1 -- 1344
			end -- 1344
			i = i + 1 -- 1342
		end -- 1342
	end -- 1342
	return n -- 1347
end -- 1339
function Game.prototype.shenX(self) -- 1350
	if self.state.flags.confront then -- 1350
		return 2200 -- 1352
	end -- 1352
	local xs = { -- 1354
		560, -- 1354
		500, -- 1354
		650, -- 1354
		480, -- 1354
		520, -- 1354
		460 -- 1354
	} -- 1354
	return xs[math.min( -- 1355
		self:shenProgress(), -- 1355
		#xs - 1 -- 1355
	) + 1] -- 1355
end -- 1350
function Game.prototype.shenY(self) -- 1358
	if self.state.flags.confront then -- 1358
		return Tower.TOPS[#Tower.TOPS] -- 1362
	end -- 1362
	local tops = Tower.TOPS -- 1365
	return tops[math.min( -- 1366
		self:shenProgress(), -- 1366
		#tops - 2 -- 1366
	) + 1] -- 1366
end -- 1358
function Game.prototype.pitFall(self) -- 1370
	local ____self_state_12, ____heroineLife_13 = self.state, "heroineLife" -- 1370
	____self_state_12[____heroineLife_13] = ____self_state_12[____heroineLife_13] - 1 -- 1371
	self.hud:flashDamage() -- 1372
	self:shake(0.3, 8) -- 1373
	__TS__ArraySetLength(self.qiShots, 0) -- 1373
	if self.state.heroineLife <= 0 then -- 1373
		self:die() -- 1376
		return -- 1377
	end -- 1377
	self:respawnAt(self.state.currentCheckpointId) -- 1379
end -- 1370
function Game.prototype.onEnemyDeath(self, def, x, y) -- 1382
	self.fx:spawnMist(def.x, def.y, def.kind == "boss" and 10 or 4, def.kind == "boss" and 1.6 or 1) -- 1383
	self.boomFx:spawn(x, y + 40, def.kind == "boss") -- 1384
	if def.floor == 1 then -- 1384
		self.floor1Kill = true -- 1387
	end -- 1387
	if def.kind == "boss" then -- 1387
		self:shake(0.5, 9) -- 1390
		self:startConfront() -- 1391
	end -- 1391
	if def.id == "e00" and not self.state.flags.banditDown then -- 1391
		self.state.flags.banditDown = true -- 1394
		self.state.objective = "强盗已退——登上东边木梯（W 攀爬），进入古镇街巷" -- 1395
	end -- 1395
end -- 1382
function Game.prototype.startConfront(self) -- 1399
	self.state.flags.bossDown = true -- 1400
	if self.tree ~= nil then -- 1400
		self.tree:extend("斩观星者") -- 1402
	end -- 1402
	self:openDialog("story_final") -- 1404
end -- 1399
function Game.prototype.die(self) -- 1408
	self.mode = "dead" -- 1409
	if self.state.maxLife <= 1 then -- 1409
		if self.tree ~= nil then -- 1409
			self.tree:addChoice("力竭而终") -- 1412
		end -- 1412
		self:logCause("力竭而终·月相永滞") -- 1414
		self:endGame("exhausted") -- 1415
		return -- 1416
	end -- 1416
	self.deadT = 0.8 -- 1418
	self.hud:flashDamage() -- 1419
	self.state.objective = "月相逆卷——正在回溯本层……（R 立即回溯）" -- 1420
end -- 1408
function Game.prototype.startRewind(self) -- 1424
	if self.mode == "ending" or self.mode == "title" or self.mode == "prologue" then -- 1424
		return -- 1426
	end -- 1426
	self.hud:hideEnding() -- 1428
	self.mode = "rewind" -- 1429
	self.rewindT = 0 -- 1430
	self.causFx:play("rewind", "月相逆卷·本层回溯") -- 1431
	rewindFloor(self.state) -- 1432
	self.hud:setRewind(0) -- 1433
end -- 1424
function Game.prototype.doRewind(self) -- 1437
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 1438
	self.stealth:resetRuntime() -- 1439
	self.floor1Kill = false -- 1440
	self.floor1Alert = false -- 1441
	__TS__ArraySetLength(self.qiShots, 0) -- 1441
	if not self.treeDeathSeen and not self.treeJumpPending then -- 1441
		self.treeDeathSeen = true -- 1444
		if self.tree ~= nil then -- 1444
			self.tree:extend("殒落再临") -- 1446
		end -- 1446
	end -- 1446
	self.treeJumpPending = false -- 1449
	self:respawnAt(self.state.currentCheckpointId) -- 1450
	self.mode = "play" -- 1451
end -- 1437
function Game.prototype.copyBoolRecord(self, src) -- 1455
	local out = {} -- 1456
	for k in pairs(src) do -- 1457
		out[k] = src[k] -- 1458
	end -- 1458
	return out -- 1460
end -- 1455
function Game.prototype.cloneLoopState(self, s) -- 1464
	return { -- 1465
		loopIndex = s.loopIndex, -- 1466
		phaseIndex = s.phaseIndex, -- 1467
		heroineLife = s.heroineLife, -- 1468
		maxLife = s.maxLife, -- 1469
		swordIntent = s.swordIntent, -- 1470
		maxSwordIntent = s.maxSwordIntent, -- 1471
		shenyanTrust = s.shenyanTrust, -- 1472
		drawnBladeAgainst = s.drawnBladeAgainst, -- 1473
		rewindCount = s.rewindCount, -- 1474
		moonstones = s.moonstones, -- 1475
		mechanismParts = s.mechanismParts, -- 1476
		tokens = s.tokens, -- 1477
		memories = __TS__ArraySlice(s.memories), -- 1478
		flags = self:copyBoolRecord(s.flags), -- 1479
		cutRopes = self:copyBoolRecord(s.cutRopes), -- 1480
		rungBells = self:copyBoolRecord(s.rungBells), -- 1481
		platesActive = self:copyBoolRecord(s.platesActive), -- 1482
		lanternsLit = self:copyBoolRecord(s.lanternsLit), -- 1483
		lanternSequence = s.lanternSequence, -- 1484
		lanternFailed = s.lanternFailed, -- 1485
		openedGates = self:copyBoolRecord(s.openedGates), -- 1486
		collectedIds = self:copyBoolRecord(s.collectedIds), -- 1487
		checkpointsActivated = self:copyBoolRecord(s.checkpointsActivated), -- 1488
		currentCheckpointId = s.currentCheckpointId, -- 1489
		storySeen = self:copyBoolRecord(s.storySeen), -- 1490
		askedChoices = self:copyBoolRecord(s.askedChoices), -- 1491
		objective = s.objective, -- 1492
		stealthAlert = s.stealthAlert, -- 1493
		sneakBonus = s.sneakBonus, -- 1494
		rewindPenalty = s.rewindPenalty, -- 1495
		pebbles = s.pebbles, -- 1496
		causalityLog = __TS__ArraySlice(s.causalityLog) -- 1497
	} -- 1497
end -- 1464
function Game.prototype.jumpToNode(self, id) -- 1504
	local snap = self.treeSnap[id] -- 1505
	if snap == nil then -- 1505
		return -- 1507
	end -- 1507
	if self.dialog:isOpen() or self.teleportT >= 0 then -- 1507
		return -- 1510
	end -- 1510
	local prevSeen = self.state.storySeen -- 1515
	local prevAsked = self.state.askedChoices -- 1516
	local prevMemories = __TS__ArraySlice(self.state.memories) -- 1517
	self.state = self:cloneLoopState(snap) -- 1518
	for k in pairs(prevSeen) do -- 1519
		self.state.storySeen[k] = true -- 1520
	end -- 1520
	for k in pairs(prevAsked) do -- 1522
		self.state.askedChoices[k] = true -- 1523
	end -- 1523
	do -- 1523
		local i = 0 -- 1525
		while i < #prevMemories do -- 1525
			if __TS__ArrayIndexOf(self.state.memories, prevMemories[i + 1]) < 0 then -- 1525
				local ____self_state_memories_14 = self.state.memories -- 1525
				____self_state_memories_14[#____self_state_memories_14 + 1] = prevMemories[i + 1] -- 1527
			end -- 1527
			i = i + 1 -- 1525
		end -- 1525
	end -- 1525
	self.mech.state = self.state -- 1530
	self.mech:syncStones(Tower.pushStones) -- 1531
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 1532
	self.stealth:resetRuntime() -- 1533
	__TS__ArraySetLength(self.qiShots, 0) -- 1533
	self.attackApplied = false -- 1535
	self.intentRegenT = 0 -- 1536
	self.bladeT = 0 -- 1537
	self.floor1Kill = false -- 1538
	self.floor1Alert = false -- 1539
	self.treeFloorSeen = {} -- 1541
	self.treeGateSeen = {} -- 1542
	self.treeDeathSeen = false -- 1543
	self.treeJumpPending = true -- 1544
	self:respawnAt(self.state.currentCheckpointId) -- 1545
	self.mode = "rewind" -- 1546
	self.rewindT = 0 -- 1547
	self.causFx:play("rewind", "时空回溯·跳回节点") -- 1548
	self.hud:setRewind(0) -- 1549
end -- 1504
function Game.prototype.respawnAt(self, id) -- 1552
	local cp = self:findCheckpoint(id) -- 1553
	local x = cp and cp.x or 800 -- 1554
	local y = (cp and cp.y or 320) + 42 -- 1556
	self.player:respawn(x, y) -- 1557
	self.camX = x -- 1558
	self.camY = y -- 1559
	self.renderer:setFloorScene(cp and cp.floor or 0) -- 1560
	self:playFloorBgm() -- 1561
	if cp ~= nil then -- 1561
		local intro = self:floorIntroStory(cp.floor) -- 1564
		if intro ~= nil then -- 1564
			self.pendingFloorStory = intro -- 1566
			self.pendingFloorStoryFloor = cp.floor -- 1567
			self.pendingFloorStoryT = 0.6 -- 1568
		end -- 1568
	end -- 1568
end -- 1552
function Game.prototype.nearPortal(self, px, py) -- 1578
	if self.teleportT >= 0 or self.mode ~= "play" then -- 1578
		return nil -- 1580
	end -- 1580
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1582
	local floor = cp and cp.floor or -1 -- 1583
	do -- 1583
		local i = 0 -- 1584
		while i < #Tower.portals do -- 1584
			do -- 1584
				local p = Tower.portals[i + 1] -- 1585
				if p.gateId ~= nil and self.mech:isGateOpen(p.gateId) ~= true then -- 1585
					goto __continue326 -- 1588
				end -- 1588
				if p.floor == floor and math.abs(px - p.x) < PORTAL_USE_RADIUS and math.abs(py - (p.y + 55)) < 95 then -- 1588
					return p -- 1591
				end -- 1591
			end -- 1591
			::__continue326:: -- 1591
			i = i + 1 -- 1584
		end -- 1584
	end -- 1584
	return nil -- 1594
end -- 1578
function Game.prototype.startPortal(self, p) -- 1598
	local cp = self:checkpointOfFloor(p.targetFloor) -- 1599
	if cp == nil then -- 1599
		return -- 1601
	end -- 1601
	self.teleportT = 0 -- 1603
	self.pendingPortalTarget = {cpId = cp.id, floor = cp.floor, x = cp.x, y = cp.y} -- 1604
	self.fx:spawnStars(p.x, p.y + 50, 8) -- 1605
	self:shake(0.2, 3) -- 1606
end -- 1598
function Game.prototype.checkpointOfFloor(self, floor) -- 1609
	do -- 1609
		local i = 0 -- 1610
		while i < #Tower.checkpoints do -- 1610
			local c = Tower.checkpoints[i + 1] -- 1611
			if c.floor == floor then -- 1611
				return {id = c.id, x = c.x, y = c.y, floor = c.floor} -- 1613
			end -- 1613
			i = i + 1 -- 1610
		end -- 1610
	end -- 1610
	return nil -- 1616
end -- 1609
function Game.prototype.advanceTeleport(self, dt) -- 1619
	self.teleportT = self.teleportT + dt -- 1620
	local t = self.pendingPortalTarget -- 1621
	if t ~= nil and self.teleportT >= 0.45 then -- 1621
		self.pendingPortalTarget = nil -- 1623
		self.state.currentCheckpointId = t.cpId -- 1624
		self.state.checkpointsActivated[t.cpId] = true -- 1625
		restoreFloorCap(self.state) -- 1627
		self:settleFloorSneak(t.floor) -- 1628
		self:respawnAt(t.cpId) -- 1629
		self:growFloor(t.floor) -- 1630
		self.camY = t.y + 160 -- 1631
		self.fx:spawnRing( -- 1632
			t.x, -- 1632
			t.y + 60, -- 1632
			GOLD, -- 1632
			16, -- 1632
			170, -- 1632
			0.7 -- 1632
		) -- 1632
	end -- 1632
	if self.teleportT >= 0.9 then -- 1632
		self.teleportT = -1 -- 1635
	end -- 1635
end -- 1619
function Game.prototype.teleportFade(self) -- 1639
	if self.teleportT < 0 then -- 1639
		return 0 -- 1641
	end -- 1641
	if self.teleportT < 0.45 then -- 1641
		return self.teleportT / 0.45 -- 1644
	end -- 1644
	return math.max(0, 1 - (self.teleportT - 0.45) / 0.45) -- 1646
end -- 1639
function Game.prototype.syncFloorScene(self) -- 1649
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1650
	self.renderer:setFloorScene(cp and cp.floor or 0) -- 1651
end -- 1649
function Game.prototype.activeLadders(self) -- 1655
	if self.state.flags.treePlanted == true and self.state.flags.treeCut ~= true then -- 1655
		return TREE_LADDER -- 1657
	end -- 1657
	return Tower.ladders -- 1659
end -- 1655
function Game.prototype.logCause(self, text) -- 1663
	if __TS__ArrayIndexOf(self.state.causalityLog, text) >= 0 then -- 1663
		return -- 1665
	end -- 1665
	local ____self_state_causalityLog_15 = self.state.causalityLog -- 1665
	____self_state_causalityLog_15[#____self_state_causalityLog_15 + 1] = text -- 1667
	if #self.state.causalityLog > 12 then -- 1667
		__TS__ArraySplice(self.state.causalityLog, 0, #self.state.causalityLog - 12) -- 1669
	end -- 1669
end -- 1663
function Game.prototype.floorOfCheckpoint(self) -- 1673
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1674
	return cp and cp.floor or 0 -- 1675
end -- 1673
function Game.prototype.throwPebble(self) -- 1679
	if self.state.pebbles <= 0 then -- 1679
		return -- 1681
	end -- 1681
	local ____self_state_16, ____pebbles_17 = self.state, "pebbles" -- 1681
	____self_state_16[____pebbles_17] = ____self_state_16[____pebbles_17] - 1 -- 1683
	local px = self.player.body.x -- 1684
	local py = self.player.body.y -- 1685
	local landX = px + self.player.facing * 260 -- 1686
	self.stealth:emitNoise( -- 1687
		landX, -- 1687
		self:floorOfCheckpoint(), -- 1687
		320 -- 1687
	) -- 1687
	self.fx:spawnDust(landX, py, self.player.facing) -- 1688
	sfx("dash", 0.4) -- 1689
	self.state.objective = "石子落地——附近的守卫被吸引了过去" -- 1690
end -- 1679
function Game.prototype.tryTreePuzzle(self, px, py) -- 1694
	if self.state.flags.treeCut == true then -- 1694
		return false -- 1696
	end -- 1696
	if self:floorOfCheckpoint() ~= 0 or math.abs(py - (Tower.TOPS[1] + 42)) > 90 then -- 1696
		return false -- 1699
	end -- 1699
	local planted = self.state.flags.treePlanted == true -- 1701
	if not planted and self.state.flags.saplingTaken ~= true and math.abs(px - 700) < 90 then -- 1701
		self.state.flags.saplingTaken = true -- 1703
		self:logCause("渡口移苗·根带旧土") -- 1704
		sfx("click", 0.9) -- 1705
		self.fx:spawnStars(px, py + 40, 6) -- 1706
		self.state.objective = "树苗在手——东边枯坑（x≈1200）在等它；路过水井（x≈860）可先打一桶水" -- 1707
		return true -- 1708
	end -- 1708
	if self.state.flags.bucketFull ~= true and math.abs(px - 860) < 90 then -- 1708
		self.state.flags.bucketFull = true -- 1711
		self:logCause("井水打满·一桶月色") -- 1712
		self.causFx:play("fill", "一桶井水") -- 1713
		self.state.objective = "水已打好——去移树苗（x≈700），再种进枯坑（x≈1200）" -- 1714
		return true -- 1715
	end -- 1715
	if not planted and math.abs(px - 1200) < 100 then -- 1715
		if self.state.flags.saplingTaken == true then -- 1715
			self.state.flags.treePlanted = true -- 1719
			self.state.flags.saplingTaken = false -- 1720
			if self.state.flags.bucketFull == true then -- 1720
				self.state.flags.bucketFull = false -- 1723
			end -- 1723
			self.mech:openGate("gate_ferry") -- 1725
			if self.tree ~= nil then -- 1725
				self.tree:addChoice("种下树苗") -- 1727
			end -- 1727
			self:logCause("枯坑种树·因果成立") -- 1729
			self.causFx:play("grow", "种下·对岸月影同时落地") -- 1730
			self.fx:spawnRing( -- 1731
				px, -- 1731
				py + 30, -- 1731
				CYAN, -- 1731
				14, -- 1731
				130, -- 1731
				0.8 -- 1731
			) -- 1731
			sfx("click", 1) -- 1732
			self.state.objective = "树影成双——月华凝成新的月石（攀树梯而上，x≈1180 按 W）；渡口尽头的传送门亮起了" -- 1733
			return true -- 1734
		end -- 1734
		self.state.objective = "枯坑沉默着……像在等一株树苗（西边有井，也有苗）" -- 1736
		return true -- 1737
	end -- 1737
	if planted and self.state.flags.bucketFull == true and math.abs(px - 1200) < 100 then -- 1737
		self.state.flags.bucketFull = false -- 1741
		self:logCause("月色浇灌·新苗抽枝") -- 1742
		self.causFx:play("grow", "浇灌·月华入土") -- 1743
		self.fx:spawnRing( -- 1744
			px, -- 1744
			py + 30, -- 1744
			CYAN, -- 1744
			12, -- 1744
			120, -- 1744
			0.7 -- 1744
		) -- 1744
		sfx("click", 1) -- 1745
		self.state.objective = "浇透了——小树轻轻颤了颤；井（x≈860）随时可再打一桶" -- 1746
		return true -- 1747
	end -- 1747
	return false -- 1749
end -- 1694
function Game.prototype.cutTree(self) -- 1753
	self.state.flags.treeCut = true -- 1754
	if self.tree ~= nil then -- 1754
		self.tree:addChoice("砍倒小树") -- 1756
	end -- 1756
	self:logCause("刀落砍树·两树同枯") -- 1758
	self.causFx:play("cut", "砍伐·因果反噬") -- 1759
	self:shake(0.35, 7) -- 1760
	sfx("enemyHurt", 0.8) -- 1761
	self.state.objective = "树桩无言——砍倒它，树冠上的月华也随之湮灭" -- 1762
end -- 1753
function Game.prototype.tryPebblePickup(self, px, py) -- 1766
	if self:floorOfCheckpoint() ~= 1 or self.state.pebbles > 0 then -- 1766
		return false -- 1768
	end -- 1768
	if math.abs(px - 1450) < 80 and math.abs(py - (Tower.TOPS[2] + 42)) < 90 then -- 1768
		self.state.pebbles = 3 -- 1771
		self:logCause("拾起石子·三枚") -- 1772
		sfx("click", 0.9) -- 1773
		self.state.objective = "拾起 3 枚石子——Q 丢向前方，引开守卫视线" -- 1774
		return true -- 1775
	end -- 1775
	return false -- 1777
end -- 1766
function Game.prototype.tryBarrel(self, px, py) -- 1781
	if self:floorOfCheckpoint() ~= 1 or self.state.flags.barrelDown == true then -- 1781
		return false -- 1783
	end -- 1783
	if math.abs(px - 1900) < 90 and math.abs(py - (Tower.TOPS[2] + 42)) < 90 then -- 1783
		local left = self.player.facing < 0 -- 1786
		self.state.flags.barrelDown = true -- 1787
		self.state.flags.barrelLeft = left -- 1788
		local fallX = left and 1760 or 2040 -- 1789
		self.enemies:stunNear(fallX, 1, 180, 3.5) -- 1790
		self.stealth:emitNoise(fallX, 1, 340) -- 1791
		self:shake(0.35, 8) -- 1792
		sfx("enemyHurt", 0.8) -- 1793
		self:logCause("酒桶砸落·震慑一时") -- 1794
		self.state.objective = "酒桶轰然砸落——附近守卫被震晕了（趁现在！）" -- 1795
		return true -- 1796
	end -- 1796
	return false -- 1798
end -- 1781
function Game.prototype.tryWaiter(self, px, py) -- 1802
	if self:floorOfCheckpoint() ~= 1 or self.state.flags.waiterFreed == true then -- 1802
		return false -- 1804
	end -- 1804
	if math.abs(px - 1985) < 80 and math.abs(py - (Tower.TOPS[2] + 42)) < 90 then -- 1804
		self.state.flags.waiterFreed = true -- 1807
		addTrust(self.state, 1) -- 1808
		if self.tree ~= nil then -- 1808
			self.tree:addChoice("救出店小二") -- 1810
		end -- 1810
		self:logCause("割绳救人·剑意上限+1") -- 1812
		local ____self_state_18, ____maxSwordIntent_19 = self.state, "maxSwordIntent" -- 1812
		____self_state_18[____maxSwordIntent_19] = ____self_state_18[____maxSwordIntent_19] + 1 -- 1813
		self.state.swordIntent = self.state.maxSwordIntent -- 1814
		self.causFx:play("rescue", "救人·剑意上限 +1") -- 1815
		sfx("click", 1) -- 1816
		self.state.objective = "店小二低声道：别走大道……酒桶后面能蹲人。" -- 1817
		return true -- 1818
	end -- 1818
	return false -- 1820
end -- 1802
function Game.prototype.settleFloorSneak(self, arrivedFloor) -- 1824
	if arrivedFloor ~= 2 or self.state.flags.floor1Settled == true then -- 1824
		return -- 1826
	end -- 1826
	self.state.flags.floor1Settled = true -- 1828
	if not self.floor1Kill and not self.floor1Alert then -- 1828
		self.state.sneakBonus = true -- 1830
		local ____self_state_20, ____maxSwordIntent_21 = self.state, "maxSwordIntent" -- 1830
		____self_state_20[____maxSwordIntent_21] = ____self_state_20[____maxSwordIntent_21] + 1 -- 1831
		self.state.swordIntent = self.state.maxSwordIntent -- 1832
		if self.tree ~= nil then -- 1832
			self.tree:addChoice("古镇不杀") -- 1834
		end -- 1834
		self:logCause("古镇不杀·剑意上限+1") -- 1836
		self.fx:spawnRing( -- 1837
			self.player.body.x, -- 1837
			self.player.body.y + 40, -- 1837
			GOLD, -- 1837
			12, -- 1837
			110, -- 1837
			0.8 -- 1837
		) -- 1837
		self.state.objective = "潜行奖励：全程不杀而穿过古镇——剑意上限 +1" -- 1838
	elseif self.floor1Kill then -- 1838
		if self.tree ~= nil then -- 1838
			self.tree:addChoice("杀出古镇") -- 1841
		end -- 1841
		self:logCause("杀出古镇·血染街巷") -- 1843
	else -- 1843
		self:logCause("古镇遇警·惊动街巷") -- 1845
	end -- 1845
	self.floor1Kill = false -- 1847
	self.floor1Alert = false -- 1848
end -- 1824
function Game.prototype.drawFloor1Npcs(self, d, p) -- 1852
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1853
	local floor = cp and cp.floor or 0 -- 1854
	local wy = Tower.TOPS[2] -- 1855
	if math.abs(p.x - 1985) < 1100 and math.abs(p.y - (wy + 60)) < 700 then -- 1855
		local freed = self.state.flags.waiterFreed == true -- 1857
		d:drawPolygon( -- 1858
			{ -- 1858
				Vec2(1975, wy), -- 1858
				Vec2(1995, wy), -- 1858
				Vec2(1993, wy - 44), -- 1858
				Vec2(1977, wy - 44) -- 1858
			}, -- 1858
			Color(74, 62, 56, 255) -- 1858
		) -- 1858
		d:drawDot( -- 1859
			Vec2(1985, wy - 54), -- 1859
			9, -- 1859
			Color(216, 192, 162, 255) -- 1859
		) -- 1859
		if freed then -- 1859
			d:drawSegment( -- 1861
				Vec2(1995, wy - 40), -- 1861
				Vec2(2007, wy - 60), -- 1861
				3, -- 1861
				Color(216, 192, 162, 255) -- 1861
			) -- 1861
		else -- 1861
			d:drawSegment( -- 1863
				Vec2(1971, wy - 30), -- 1863
				Vec2(1999, wy - 30), -- 1863
				3, -- 1863
				Color(126, 94, 60, 255) -- 1863
			) -- 1863
		end -- 1863
	end -- 1863
	if self.state.pebbles == 0 and floor == 1 and math.abs(p.x - 1450) < 900 and math.abs(p.y - (wy + 60)) < 500 then -- 1863
		d:drawPolygon( -- 1867
			{ -- 1867
				Vec2(1430, wy), -- 1867
				Vec2(1472, wy), -- 1867
				Vec2(1462, wy - 16), -- 1867
				Vec2(1440, wy - 16) -- 1867
			}, -- 1867
			Color(120, 118, 112, 255) -- 1867
		) -- 1867
		d:drawDot( -- 1868
			Vec2(1450, wy - 22), -- 1868
			6, -- 1868
			Color(150, 148, 140, 255) -- 1868
		) -- 1868
	end -- 1868
end -- 1852
function Game.prototype.loopAdvance(self) -- 1872
	local ____self_state_22, ____loopIndex_23 = self.state, "loopIndex" -- 1872
	____self_state_22[____loopIndex_23] = ____self_state_22[____loopIndex_23] + 1 -- 1873
	self.state.shenyanTrust = 0 -- 1874
	__TS__ArraySetLength(self.state.memories, 0) -- 1874
	self:growNight() -- 1877
	self.treeFloorSeen = {} -- 1878
	self.treeDeathSeen = false -- 1879
	self:applyLoopVariants() -- 1880
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 1881
	self.stealth:resetRuntime() -- 1882
	self.state.currentCheckpointId = "cp_riverbank" -- 1883
	self:respawnAt(self.state.currentCheckpointId) -- 1884
	self.mode = "rewind" -- 1885
	self.rewindT = 0 -- 1886
end -- 1872
function Game.prototype.applyLoopVariants(self) -- 1889
	self.state.cutRopes = {} -- 1890
	self.state.rungBells = {} -- 1891
	self.state.platesActive = {} -- 1892
	self.state.lanternsLit = {} -- 1893
	self.state.lanternSequence = 0 -- 1894
	self.state.lanternFailed = false -- 1895
	self.state.openedGates = {} -- 1896
	self.state.swordIntent = self.state.maxSwordIntent -- 1897
	self.state.flags.confront = false -- 1898
	self.state.flags.bladeClash = false -- 1899
	self.state.flags.putDownSword = false -- 1900
	self.state.flags.floor1Settled = false -- 1901
	self.state.flags.treePlanted = false -- 1904
	self.state.flags.saplingTaken = false -- 1905
	self.state.flags.treeCut = false -- 1906
	self.state.flags.bucketFull = false -- 1907
	self.mech:syncStones(Tower.pushStones) -- 1908
end -- 1889
function Game.prototype.endGame(self, id) -- 1911
	self.endingId = id -- 1912
	self.hud:setRewind(-1) -- 1913
	self.mode = "ending" -- 1914
	self.hud:showEnding(id) -- 1915
	self:archiveRun(id) -- 1916
	playBgm("calm", 2) -- 1917
end -- 1911
function Game.prototype.archiveRun(self, endingId) -- 1921
	if self.treeArchived then -- 1921
		return -- 1923
	end -- 1923
	self.treeArchived = true -- 1925
	local e = ENDINGS[endingId] -- 1926
	local name = self.playerName ~= "" and self.playerName or (loadPlayerName() ~= "" and loadPlayerName() or DEFAULT_NAME) -- 1927
	local entry = { -- 1928
		name = name, -- 1929
		endingTitle = e ~= nil and e.title or endingId, -- 1930
		rewindCount = self.tree ~= nil and self.tree.rewindCount or 0, -- 1931
		currentId = self.tree ~= nil and self.tree.currentId or "", -- 1932
		nodes = self.tree ~= nil and self.tree.nodes or ({}) -- 1933
	} -- 1933
	appendArchive(entry) -- 1935
end -- 1921
function Game.prototype.toTitle(self) -- 1938
	self.hud:hideEnding() -- 1939
	self.paused = false -- 1940
	self.hud:setPauseVisible(false) -- 1941
	self:resetRun() -- 1942
	self.sheetFx:clear() -- 1943
	self.renderer:setPrompt(0, 0, nil) -- 1944
	playBgm("cover", 1) -- 1945
	self.mode = "title" -- 1946
	self.hud:setTitleVisible(true) -- 1947
end -- 1938
function Game.prototype.hintText(self) -- 1950
	if self.mode == "confront" then -- 1950
		return "走近沈砚：E 放下剑 · Q 以命换命 · J 剑锋相向 · Tab 手札" -- 1952
	end -- 1952
	if self.mode == "play" and (self:nearPortal(self.player.body.x, self.player.body.y) ~= nil or self.nearStoryId ~= nil) then -- 1952
		return "" -- 1956
	end -- 1956
	if self.player.onLadder then -- 1956
		return "W/S 攀爬 · 到顶后按 Space 跳向右侧平台" -- 1959
	end -- 1959
	return "" -- 1961
end -- 1950
function Game.prototype.makeNpcSprite(self, paths, parent, tag) -- 1965
	local tex -- 1966
	local used = "" -- 1967
	for ____, p in ipairs(paths) do -- 1968
		tex = Texture2D(p) -- 1969
		if tex ~= nil then -- 1969
			used = p -- 1971
			break -- 1972
		end -- 1972
	end -- 1972
	if tex == nil or used == "" then -- 1972
		print((("[" .. tag) .. "] texture load failed: ") .. table.concat(paths, " | ")) -- 1976
		return nil -- 1977
	end -- 1977
	print(((((((("[" .. tag) .. "] loaded ") .. used) .. " (") .. tostring(tex.width)) .. "x") .. tostring(tex.height)) .. ")") -- 1979
	local sp = Sprite(tex) -- 1980
	if sp == nil then -- 1980
		return nil -- 1982
	end -- 1982
	local s = 90 / tex.height -- 1984
	sp.scaleX = s -- 1985
	sp.scaleY = s -- 1986
	sp.anchor = Vec2(0.5, 0) -- 1987
	sp.visible = false -- 1988
	sp:addTo(parent) -- 1989
	return sp -- 1990
end -- 1965
function Game.prototype.drawNpcs(self) -- 1993
	local p = self.player.body -- 1994
	local d = self.npcDraw -- 1995
	self:drawFloor1Npcs(d, p) -- 1996
	self.shenRenderOk = false -- 1997
	self.obsNode.position = self.npcDraw.position -- 1998
	local obsY = Tower.TOPS[4] -- 2000
	local obsNear = math.abs(p.x - 800) < 1300 and math.abs(p.y - obsY) < 900 -- 2001
	if self.obsSp ~= nil then -- 2001
		self.obsSp.visible = obsNear -- 2004
		if obsNear then -- 2004
			self.obsSp.position = Vec2(800, obsY) -- 2006
			self.obsSp.scaleX = math.abs(self.obsSp.scaleX) * (p.x > 800 and 1 or -1) -- 2007
		end -- 2007
	elseif obsNear then -- 2007
		drawObserver(d, 800, obsY, self.time) -- 2010
	end -- 2010
	local sx -- 2014
	local sy -- 2015
	local hideShen = false -- 2016
	if self.state.flags.confront then -- 2016
		sx = 2200 -- 2018
		sy = self:shenY() -- 2019
	else -- 2019
		local xs = { -- 2022
			560, -- 2022
			500, -- 2022
			650, -- 2022
			480, -- 2022
			1900, -- 2022
			460 -- 2022
		} -- 2022
		local tops = Tower.TOPS -- 2023
		local target = math.min( -- 2024
			self:shenProgress(), -- 2024
			#xs - 1 -- 2024
		) -- 2024
		if target < self.shenShownIdx then -- 2024
			self.shenShownIdx = target -- 2026
		elseif target > self.shenShownIdx then -- 2026
			local nx = xs[target + 1] -- 2028
			local ny = tops[math.min(target, #tops - 2) + 1] -- 2029
			if math.min(target, #tops - 2) == 3 or math.abs(p.x - nx) < 1200 and math.abs(p.y - ny) < 900 then -- 2029
				self.shenShownIdx = target -- 2032
			end -- 2032
		end -- 2032
		local idx = math.min(self.shenShownIdx, target) -- 2035
		sx = xs[idx + 1] -- 2036
		sy = tops[math.min(idx, #tops - 2) + 1] -- 2037
		hideShen = math.min(idx, #tops - 2) == 3 or math.min(idx, #tops - 2) == 5 -- 2039
	end -- 2039
	if self.mode ~= "ending" and not hideShen and math.abs(p.x - sx) < 1400 then -- 2039
		self.shenRenderX = sx -- 2042
		self.shenRenderY = sy -- 2043
		self.shenRenderOk = true -- 2044
		local dark = self.state.flags.confront and self.shenSpDark ~= nil and self.shenSpDark or self.shenSpNormal -- 2045
		if self.shenSpNormal ~= nil then -- 2045
			self.shenSpNormal.visible = dark == self.shenSpNormal -- 2047
		end -- 2047
		if self.shenSpDark ~= nil then -- 2047
			self.shenSpDark.visible = dark == self.shenSpDark -- 2050
		end -- 2050
		if dark ~= nil then -- 2050
			self.shenNode.position = self.npcDraw.position -- 2054
			dark.position = Vec2(sx, sy) -- 2055
			dark.scaleX = math.abs(dark.scaleX) * (p.x > sx and 1 or -1) -- 2056
		else -- 2056
			drawShenYan( -- 2058
				d, -- 2058
				sx, -- 2058
				sy, -- 2058
				p.x > sx and -1 or 1, -- 2058
				self.time, -- 2058
				self.state.flags.confront -- 2058
			) -- 2058
		end -- 2058
	else -- 2058
		if self.shenSpNormal ~= nil then -- 2058
			self.shenSpNormal.visible = false -- 2062
		end -- 2062
		if self.shenSpDark ~= nil then -- 2062
			self.shenSpDark.visible = false -- 2065
		end -- 2065
	end -- 2065
	local blueTexReady = self.slashFx:hasBlueTex() -- 2068
	local shots = {} -- 2069
	do -- 2069
		local i = 0 -- 2070
		while i < #self.qiShots do -- 2070
			do -- 2070
				local q = self.qiShots[i + 1] -- 2071
				if not q.alive then -- 2071
					goto __continue418 -- 2073
				end -- 2073
				local wob = math.sin(self.time * 22 + q.phase) * 4 -- 2075
				if blueTexReady then -- 2075
					shots[#shots + 1] = {x = q.x, y = q.y + wob, dir = q.dir} -- 2078
					goto __continue418 -- 2079
				end -- 2079
				local function buildCres(scale, ox) -- 2081
					local pts = {} -- 2082
					local R = 46 * scale -- 2083
					local aOut = 1.45 -- 2084
					do -- 2084
						local k = 0 -- 2085
						while k <= 10 do -- 2085
							local t = aOut - 2 * aOut * k / 10 -- 2086
							pts[#pts + 1] = Vec2( -- 2087
								q.x + q.dir * (ox + R * math.cos(t)), -- 2087
								q.y + wob + R * math.sin(t) -- 2087
							) -- 2087
							k = k + 1 -- 2085
						end -- 2085
					end -- 2085
					local c2 = -0.6 * R -- 2089
					local ri = 1.2266 * R -- 2090
					local aIn = 0.9425 -- 2091
					do -- 2091
						local k = 0 -- 2092
						while k <= 10 do -- 2092
							local t = -aIn + 2 * aIn * k / 10 -- 2093
							pts[#pts + 1] = Vec2( -- 2094
								q.x + q.dir * (ox + c2 + ri * math.cos(t)), -- 2094
								q.y + wob + ri * math.sin(t) -- 2094
							) -- 2094
							k = k + 1 -- 2092
						end -- 2092
					end -- 2092
					return pts -- 2096
				end -- 2081
				d:drawPolygon( -- 2098
					buildCres(0.72, -38), -- 2098
					Color(CYAN.r, CYAN.g, CYAN.b, 42) -- 2098
				) -- 2098
				d:drawPolygon( -- 2099
					buildCres(0.86, -18), -- 2099
					Color(CYAN.r, CYAN.g, CYAN.b, 82) -- 2099
				) -- 2099
				d:drawPolygon( -- 2100
					buildCres(1, 0), -- 2100
					Color(CYAN.r, CYAN.g, CYAN.b, 150) -- 2100
				) -- 2100
				d:drawPolygon( -- 2101
					buildCres(0.6, 7), -- 2101
					Color(255, 255, 255, 215) -- 2101
				) -- 2101
			end -- 2101
			::__continue418:: -- 2101
			i = i + 1 -- 2070
		end -- 2070
	end -- 2070
	if blueTexReady then -- 2070
		self.slashFx:syncShots(shots) -- 2104
	end -- 2104
end -- 1993
function Game.prototype.updateVisuals(self, dt, shakeX, shakeY) -- 2108
	local view = View.size -- 2109
	local active = self.mode == "play" or self.mode == "confront" or self.mode == "dialog" or self.mode == "rewind" or self.mode == "dead" or self.mode == "ending" -- 2110
	if active then -- 2110
		local tx = clamp(self.player.body.x, view.width / 2, Tower.WORLD_W - view.width / 2) -- 2112
		local ty = clamp(self.player.body.y + 70, Tower.TOPS[1] + view.height / 2 - 56, Tower.WORLD_H - view.height / 2) -- 2114
		local k = math.min(1, dt * 6) -- 2115
		self.camX = tx -- 2117
		self.camY = self.camY + (ty - self.camY) * k -- 2118
	else -- 2118
		self.camX = 800 -- 2120
		self.camY = 400 -- 2121
	end -- 2121
	self.fxDraw.position = Vec2(-self.camX + shakeX, -self.camY + shakeY) -- 2124
	self.npcDraw.position = self.fxDraw.position -- 2125
	self.sheetNode.position = self.fxDraw.position -- 2126
	self.fx:update(dt) -- 2127
	self.sheetFx:update(dt) -- 2128
	self.boomFx:update(dt) -- 2129
	self.slashFx:update(dt) -- 2130
	self.fxDraw:clear() -- 2131
	self.fx:draw(self.fxDraw) -- 2132
	self.npcDraw:clear() -- 2133
	if self.mode ~= "title" and self.mode ~= "prologue" then -- 2133
		self:drawNpcs() -- 2135
	end -- 2135
	self.renderer:setWorldVisible(self.mode ~= "title" and self.mode ~= "prologue") -- 2137
	self.renderer:setCamera(self.camX, self.camY, shakeX, shakeY) -- 2138
	self.renderer:syncTreePuzzle(self.state.flags) -- 2140
	self.renderer:syncBarrel(dt, self.state.flags.barrelDown == true, self.state.flags.barrelLeft == true) -- 2141
	self.renderer:update( -- 2142
		dt, -- 2142
		self.state, -- 2142
		self.player, -- 2142
		self.enemies, -- 2142
		self.mech, -- 2142
		self.time -- 2142
	) -- 2142
	self:syncInteractPrompt() -- 2143
	local cpNow = self:findCheckpoint(self.state.currentCheckpointId) -- 2144
	local floorNow = math.max( -- 2145
		0, -- 2145
		math.min(cpNow and cpNow.floor or 0, #Tower.FLOORS - 1) -- 2145
	) -- 2145
	local ____self_28 = self.hud -- 2145
	local ____self_28_update_29 = ____self_28.update -- 2145
	local ____dt_27 = dt -- 2146
	local ____self_state_25 = self.state -- 2147
	local ____self_player_26 = self.player -- 2148
	local ____table_nearBoss_result_24 -- 2149
	if self:nearBoss() then -- 2149
		____table_nearBoss_result_24 = self.enemies:boss() -- 2149
	else -- 2149
		____table_nearBoss_result_24 = nil -- 2149
	end -- 2149
	____self_28_update_29( -- 2149
		____self_28, -- 2149
		____dt_27, -- 2146
		{ -- 2146
			state = ____self_state_25, -- 2147
			player = ____self_player_26, -- 2148
			boss = ____table_nearBoss_result_24, -- 2149
			objective = self.state.objective, -- 2150
			mission = Tower.FLOOR_MISSIONS[math.min(floorNow, #Tower.FLOOR_MISSIONS - 1) + 1], -- 2151
			floorName = Tower.FLOORS[floorNow + 1], -- 2152
			guideLight = floorNow == 6 or floorNow == 4, -- 2153
			hint = self:hintText(), -- 2154
			time = self.time, -- 2155
			fade = self:teleportFade() -- 2156
		} -- 2156
	) -- 2156
	self.notebook:update(dt, self.state) -- 2158
end -- 2108
return ____exports -- 2108