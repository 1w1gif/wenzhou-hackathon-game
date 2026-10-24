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
	self.shenRenderX = 0 -- 1068
	self.shenRenderY = 0 -- 1069
	self.shenRenderOk = false -- 1070
	self.pendingFloorStoryFloor = 0 -- 1073
	self.pendingFloorStoryT = 0 -- 1074
	self.hintBubbleX = 0 -- 1078
	self.hintBubbleY = 0 -- 1079
	self.hintBubbleBestD = 1000000000 -- 1080
	self.askList = {} -- 1234
	self.teleportT = -1 -- 1536
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
end -- 253
function Game.prototype.resetRun(self) -- 265
	self.state = createLoopState() -- 266
	self.mech.state = self.state -- 267
	self.mech:syncStones(Tower.pushStones) -- 268
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 269
	__TS__ArraySetLength(self.qiShots, 0) -- 269
	self.attackApplied = false -- 271
	self.intentRegenT = 0 -- 272
	self.bladeT = 0 -- 273
	self.rewindT = 0 -- 274
	self.stealth:resetRuntime() -- 275
	self.causFx:clear() -- 276
	self.treeSnap = {} -- 277
	self.treeJumpPending = false -- 278
	self.floor1Kill = false -- 279
	self.floor1Alert = false -- 280
	self.deadT = 0 -- 281
	self:respawnAt(self.state.currentCheckpointId) -- 285
end -- 265
function Game.prototype.findCheckpoint(self, id) -- 288
	do -- 288
		local i = 0 -- 289
		while i < #Tower.checkpoints do -- 289
			if Tower.checkpoints[i + 1].id == id then -- 289
				return Tower.checkpoints[i + 1] -- 291
			end -- 291
			i = i + 1 -- 289
		end -- 289
	end -- 289
	return nil -- 294
end -- 288
function Game.prototype.playFloorBgm(self, fade) -- 298
	if fade == nil then -- 298
		fade = 1.2 -- 298
	end -- 298
	if self.mode ~= "play" and self.mode ~= "confront" and self.mode ~= "rewind" then -- 298
		return -- 300
	end -- 300
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 302
	local floor = cp and cp.floor or 0 -- 303
	local names = { -- 304
		"floor1", -- 304
		"tension", -- 304
		"wuxia", -- 304
		"floor4", -- 304
		"dusk", -- 304
		"conflict", -- 304
		"floor7" -- 304
	} -- 304
	local name = names[math.max( -- 305
		0, -- 305
		math.min(#names - 1, floor) -- 305
	) + 1] -- 305
	playBgm(name, fade) -- 306
end -- 298
function Game.prototype.findStoryTrigger(self, id) -- 309
	do -- 309
		local i = 0 -- 310
		while i < #Tower.storyTriggers do -- 310
			if Tower.storyTriggers[i + 1].storyId == id then -- 310
				return Tower.storyTriggers[i + 1] -- 312
			end -- 312
			i = i + 1 -- 310
		end -- 310
	end -- 310
	return nil -- 315
end -- 309
function Game.prototype.isAutoMonologue(self, id) -- 319
	return id == "story_check_intro" or id == "story_town" or id == "story_sneak_hint" or id == "story_workshop" -- 320
end -- 319
function Game.prototype.floorIntroStory(self, floor) -- 324
	local best -- 325
	do -- 325
		local i = 0 -- 326
		while i < #Tower.storyTriggers do -- 326
			do -- 326
				local t = Tower.storyTriggers[i + 1] -- 327
				if t.floor ~= floor or not self:isAutoMonologue(t.storyId) or self.state.storySeen[t.storyId] then -- 327
					goto __continue44 -- 329
				end -- 329
				if best == nil or t.x < best.x then -- 329
					best = t -- 332
				end -- 332
			end -- 332
			::__continue44:: -- 332
			i = i + 1 -- 326
		end -- 326
	end -- 326
	return best ~= nil and best.storyId or nil -- 335
end -- 324
function Game.prototype.tickPendingFloorStory(self, dt) -- 339
	local id = self.pendingFloorStory -- 340
	if id == nil then -- 340
		return -- 342
	end -- 342
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 344
	if cp == nil or cp.floor ~= self.pendingFloorStoryFloor or self.state.storySeen[id] then -- 344
		self.pendingFloorStory = nil -- 346
		return -- 347
	end -- 347
	self.pendingFloorStoryT = self.pendingFloorStoryT - dt -- 349
	if self.pendingFloorStoryT > 0 or self.teleportT >= 0 then -- 349
		return -- 351
	end -- 351
	self.pendingFloorStory = nil -- 353
	self:openDialog(id) -- 354
end -- 339
function Game.prototype.storyPromptAnchor(self, id) -- 358
	local trig = self:findStoryTrigger(id) -- 359
	local groundY = Tower.TOPS[(trig ~= nil and trig.floor or 0) + 1] -- 360
	local cx = trig ~= nil and trig.x + trig.w / 2 or self.player.body.x -- 361
	local node = STORY_NODES[id] -- 362
	local kind = node ~= nil and #node.lines > 0 and node.lines[1].speaker or "" -- 363
	if (string.find(kind, "观测者", nil, true) or 0) - 1 >= 0 then -- 363
		return {x = 800, y = groundY + 88} -- 365
	end -- 365
	if ((string.find(kind, "沈砚", nil, true) or 0) - 1 >= 0 or (string.find(kind, "申言", nil, true) or 0) - 1 >= 0) and self.shenRenderOk then -- 365
		return {x = self.shenRenderX, y = self.shenRenderY + 92} -- 368
	end -- 368
	return {x = cx, y = groundY + 52} -- 370
end -- 358
function Game.prototype.syncInteractPrompt(self) -- 374
	if self.mode == "play" and not self.paused then -- 374
		if self.hintBubbleText ~= nil then -- 374
			self.renderer:setPrompt(self.hintBubbleX, self.hintBubbleY, self.hintBubbleText) -- 378
			return -- 379
		end -- 379
		if not self:inCombatNear() then -- 379
			if self.state.flags.confront then -- 379
				local cx6 = self:shenX() -- 385
				local cy6 = self:shenY() -- 386
				if math.abs(self.player.body.x - cx6) < 420 and math.abs(self.player.body.y - cy6) < 260 then -- 386
					self.renderer:setPrompt(cx6, cy6 + 130, "E 放下剑 · Q 以命换命 · J 剑锋相向") -- 388
					return -- 389
				end -- 389
			end -- 389
			local portal = self:nearPortal(self.player.body.x, self.player.body.y) -- 392
			if portal ~= nil then -- 392
				self.renderer:setPrompt(portal.x, portal.y + 130, "按 E 传送") -- 395
				return -- 396
			end -- 396
			if self.nearStoryId ~= nil then -- 396
				local anchor = self:storyPromptAnchor(self.nearStoryId) -- 399
				self.renderer:setPrompt(anchor.x, anchor.y, "按 E 对话") -- 400
				return -- 401
			end -- 401
		end -- 401
	end -- 401
	local cpHere = self:findCheckpoint(self.state.currentCheckpointId) -- 406
	if (cpHere and cpHere.floor or 0) == 0 and not self:inCombatNear() then -- 406
		local fx = self.state.flags -- 408
		local pxHere = self.player.body.x -- 409
		if not fx.treePlanted and not fx.saplingTaken and math.abs(pxHere - 700) < 90 then -- 409
			self.renderer:setPrompt(700, Tower.TOPS[1] + 46, "按 E 移取树苗") -- 411
			return -- 412
		end -- 412
		if not fx.bucketFull and not fx.treePlanted and math.abs(pxHere - 860) < 90 then -- 412
			self.renderer:setPrompt(860, Tower.TOPS[1] + 64, "按 E 打一桶井水") -- 415
			return -- 416
		end -- 416
		if fx.saplingTaken == true and fx.treePlanted ~= true and math.abs(pxHere - 1200) < 110 then -- 416
			self.renderer:setPrompt(1200, Tower.TOPS[1] + 46, "按 E 种下树苗") -- 419
			return -- 420
		end -- 420
	end -- 420
	local cpF4 = self:findCheckpoint(self.state.currentCheckpointId) -- 424
	if (cpF4 and cpF4.floor or 0) == 4 and not self.mech:isGateOpen("gate_mech") then -- 424
		local px4 = self.player.body.x -- 426
		local py4 = self.player.body.y -- 427
		local top4 = Tower.TOPS[5] -- 428
		local plateDone = self.state.platesActive.plate0 == true or self.state.platesActive.plate1 == true -- 429
		local slotDone = self.state.flags.swordslot_slot_mech == true -- 430
		if not plateDone and math.abs(py4 - (top4 + 40)) < 170 and #self.mech.stones > 0 then -- 430
			local sx4 = self.mech.stones[1].x -- 433
			local nearStone = math.abs(px4 - sx4) < 170 -- 434
			local nearPlate = math.abs(px4 - 900) < 120 or math.abs(px4 - 1300) < 120 -- 435
			if nearStone or nearPlate then -- 435
				local ax4 = nearStone and sx4 or (px4 < 1100 and 900 or 1300) -- 437
				self.renderer:setPrompt(ax4, top4 + 92, "按住 A/D 顶着石块推上石板") -- 438
				return -- 439
			end -- 439
		end -- 439
		if not slotDone and math.abs(px4 - 1500) < 140 and math.abs(py4 - (top4 + 40)) < 170 then -- 439
			self.renderer:setPrompt(1500, top4 + 100, "以剑气 K 插入剑槽") -- 444
			return -- 445
		end -- 445
	end -- 445
	local cpF3 = self:findCheckpoint(self.state.currentCheckpointId) -- 449
	if (cpF3 and cpF3.floor or 0) == 3 and not self.mech:isGateOpen("gate_corridor") and not self:inCombatNear() then -- 449
		local px3 = self.player.body.x -- 451
		if math.abs(self.player.body.y - (Tower.TOPS[4] + 40)) < 170 then -- 451
			do -- 451
				local i = 0 -- 453
				while i < #Tower.windSigils do -- 453
					do -- 453
						local s3 = Tower.windSigils[i + 1] -- 454
						if self.state.flags["wind_" .. s3.id] == true or math.abs(px3 - s3.x) >= 130 then -- 454
							goto __continue73 -- 456
						end -- 456
						local lit3 = 0 -- 458
						do -- 458
							local k = 0 -- 459
							while k < #Tower.windSigils do -- 459
								if self.state.flags["wind_" .. Tower.windSigils[k + 1].id] == true then -- 459
									lit3 = lit3 + 1 -- 461
								end -- 461
								k = k + 1 -- 459
							end -- 459
						end -- 459
						self.renderer:setPrompt( -- 464
							s3.x, -- 464
							Tower.TOPS[4] + 96, -- 464
							("冲刺穿过风息符文（" .. tostring(lit3)) .. "/3）" -- 464
						) -- 464
						return -- 465
					end -- 465
					::__continue73:: -- 465
					i = i + 1 -- 453
				end -- 453
			end -- 453
		end -- 453
	end -- 453
	local cpF2 = self:findCheckpoint(self.state.currentCheckpointId) -- 471
	if (cpF2 and cpF2.floor or 0) == 2 and not self.mech:isGateOpen("lanternGate") and not self:inCombatNear() then -- 471
		local px2 = self.player.body.x -- 473
		local py2 = self.player.body.y -- 474
		do -- 474
			local i = 0 -- 475
			while i < #Tower.lanterns do -- 475
				do -- 475
					local lt2 = Tower.lanterns[i + 1] -- 476
					if self.state.lanternsLit[lt2.id] == true then -- 476
						goto __continue80 -- 478
					end -- 478
					if math.abs(px2 - lt2.x) >= 110 or math.abs(py2 - (lt2.y + 40)) >= 150 then -- 478
						goto __continue80 -- 481
					end -- 481
					local lit2 = 0 -- 483
					do -- 483
						local k = 0 -- 484
						while k < #Tower.lanterns do -- 484
							if self.state.lanternsLit[Tower.lanterns[k + 1].id] == true then -- 484
								lit2 = lit2 + 1 -- 486
							end -- 486
							k = k + 1 -- 484
						end -- 484
					end -- 484
					local expected2 = self.state.lanternSequence + 1 -- 489
					local tip2 = lt2.order == expected2 and ((("按 E 点亮悬灯（" .. tostring(lit2)) .. "/") .. tostring(#Tower.lanterns)) .. "，依序）" or ("此灯未轮到——先点亮第 " .. tostring(expected2)) .. " 盏悬灯" -- 490
					self.renderer:setPrompt(lt2.x, lt2.y + 96, tip2) -- 493
					return -- 494
				end -- 494
				::__continue80:: -- 494
				i = i + 1 -- 475
			end -- 475
		end -- 475
	end -- 475
	local cpF5 = self:findCheckpoint(self.state.currentCheckpointId) -- 498
	if (cpF5 and cpF5.floor or 0) == 5 and not self.mech:isGateOpen("gate_star") and not self:inCombatNear() then -- 498
		local px5 = self.player.body.x -- 500
		local py5 = self.player.body.y -- 501
		do -- 501
			local i = 0 -- 502
			while i < #Tower.starNodes do -- 502
				do -- 502
					local s5 = Tower.starNodes[i + 1] -- 503
					if self.state.flags["star_" .. s5.id] == true then -- 503
						goto __continue88 -- 505
					end -- 505
					if math.abs(px5 - s5.x) >= 110 or math.abs(py5 - (s5.y + 40)) >= 150 then -- 505
						goto __continue88 -- 508
					end -- 508
					local lit5 = 0 -- 510
					do -- 510
						local k = 0 -- 511
						while k < #Tower.starNodes do -- 511
							if self.state.flags["star_" .. Tower.starNodes[k + 1].id] == true then -- 511
								lit5 = lit5 + 1 -- 513
							end -- 513
							k = k + 1 -- 511
						end -- 511
					end -- 511
					self.renderer:setPrompt( -- 516
						s5.x, -- 516
						s5.y + 96, -- 516
						((("按 E 点亮星位（" .. tostring(lit5)) .. "/") .. tostring(#Tower.starNodes)) .. "，错序将熄灭）" -- 516
					) -- 516
					return -- 517
				end -- 517
				::__continue88:: -- 517
				i = i + 1 -- 502
			end -- 502
		end -- 502
	end -- 502
	self.renderer:setPrompt(0, 0, nil) -- 520
end -- 374
function Game.prototype.inCombatNear(self) -- 524
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 525
	local floor = cp and cp.floor or 0 -- 526
	local infos = self.enemies:stealthInfos() -- 527
	do -- 527
		local i = 0 -- 528
		while i < #infos do -- 528
			do -- 528
				local inf = infos[i + 1] -- 529
				if inf.floor ~= floor then -- 529
					goto __continue96 -- 531
				end -- 531
				if inf.state == "patrol" or inf.state == "dead" then -- 531
					goto __continue96 -- 534
				end -- 534
				if math.abs(inf.x - self.player.body.x) < 560 then -- 534
					return true -- 537
				end -- 537
			end -- 537
			::__continue96:: -- 537
			i = i + 1 -- 528
		end -- 528
	end -- 528
	return false -- 540
end -- 524
function Game.prototype.shake(self, t, mag) -- 543
	self.shakeT = t -- 544
	self.shakeMag = mag -- 545
end -- 543
function Game.prototype.buildInput(self, active) -- 548
	if not active then -- 548
		return { -- 550
			left = false, -- 550
			right = false, -- 550
			up = false, -- 550
			down = false, -- 550
			jumpPressed = false, -- 550
			attackPressed = false, -- 550
			qiPressed = false, -- 550
			dashPressed = false -- 550
		} -- 550
	end -- 550
	return { -- 552
		left = Keyboard:isKeyPressed("A"), -- 553
		right = Keyboard:isKeyPressed("D"), -- 554
		up = Keyboard:isKeyPressed("W"), -- 555
		down = Keyboard:isKeyPressed("S"), -- 556
		jumpPressed = Keyboard:isKeyDown("Space"), -- 557
		attackPressed = Keyboard:isKeyDown("J"), -- 558
		qiPressed = Keyboard:isKeyDown("K"), -- 559
		dashPressed = Keyboard:isKeyDown("LShift") -- 560
	} -- 560
end -- 548
function Game.prototype.onKey(self, key) -- 564
	if key == "Escape" then -- 564
		if self.tree ~= nil and self.tree:isOverlayOpen() then -- 564
			self.tree:handleKey(key) -- 568
			return -- 569
		end -- 569
		local inPlay = self.mode == "play" or self.mode == "confront" -- 571
		if inPlay or self.paused then -- 571
			self.paused = not self.paused -- 573
			self.hud:setPauseVisible(self.paused) -- 574
			return -- 575
		end -- 575
	end -- 575
	repeat -- 575
		local ____switch107 = self.mode -- 575
		local ____cond107 = ____switch107 == "title" -- 575
		if ____cond107 then -- 575
			if self.nameEntry:isOpen() then -- 575
				self.nameEntry:handleKey(key) -- 582
				break -- 583
			end -- 583
			if self.gallery:isOpen() then -- 583
				self.gallery:handleKey(key) -- 586
				break -- 587
			end -- 587
			self.hud:handleTitleKey(key) -- 589
			break -- 590
		end -- 590
		____cond107 = ____cond107 or ____switch107 == "prologue" -- 590
		if ____cond107 then -- 590
			if key == "Escape" and self.intro then -- 590
				self.intro:skip() -- 593
			end -- 593
			break -- 595
		end -- 595
		____cond107 = ____cond107 or (____switch107 == "play" or ____switch107 == "confront") -- 595
		if ____cond107 then -- 595
			if not self.paused then -- 595
				self:onPlayKey(key) -- 599
			end -- 599
			break -- 601
		end -- 601
		____cond107 = ____cond107 or ____switch107 == "dialog" -- 601
		if ____cond107 then -- 601
			if key == "W" then -- 601
				self.dialog:moveChoice(-1) -- 604
			elseif key == "S" then -- 604
				self.dialog:moveChoice(1) -- 606
			elseif key == "E" or key == "Space" or key == "Return" then -- 606
				if self.dialog:inChoiceMode() then -- 606
					self.dialog:confirmChoice() -- 610
				else -- 610
					self.dialog:advance() -- 612
				end -- 612
			end -- 612
			break -- 615
		end -- 615
		____cond107 = ____cond107 or ____switch107 == "dead" -- 615
		if ____cond107 then -- 615
			if key == "R" then -- 615
				if self.state.maxLife <= 1 then -- 615
					self:toTitle() -- 620
				else -- 620
					self:startRewind() -- 622
				end -- 622
			end -- 622
			break -- 625
		end -- 625
		____cond107 = ____cond107 or ____switch107 == "ending" -- 625
		if ____cond107 then -- 625
			if key == "R" then -- 625
				self:toTitle() -- 628
			end -- 628
			break -- 630
		end -- 630
		do -- 630
			break -- 632
		end -- 632
	until true -- 632
end -- 564
function Game.prototype.onPlayKey(self, key) -- 636
	if self.tree ~= nil then -- 636
		self.tree:handleKey(key) -- 639
	end -- 639
	if key == "Tab" then -- 639
		self.notebook:toggle() -- 642
		return -- 643
	end -- 643
	if key == "E" then -- 643
		self:interact() -- 646
		return -- 647
	end -- 647
	if key == "R" then -- 647
		self:startRewind() -- 650
	end -- 650
	if key == "Q" then -- 650
		self:onQ() -- 653
	end -- 653
end -- 636
function Game.prototype.onQ(self) -- 658
	if self.mode == "play" then -- 658
		self:throwPebble() -- 660
		return -- 661
	end -- 661
	if self.mode == "confront" then -- 661
		local px = self.player.body.x -- 664
		local py = self.player.body.y -- 665
		if math.abs(px - self:shenX()) < 150 and math.abs(py - self:shenY()) < 200 then -- 665
			if self.tree ~= nil then -- 665
				self.tree:addChoice("以命换命") -- 668
			end -- 668
			self:logCause("以命换命·月相永驻") -- 670
			self:endGame("sacrifice") -- 671
		end -- 671
	end -- 671
end -- 658
function Game.prototype.tick(self, dt) -- 676
	self.time = self.time + dt -- 677
	self.causFx:update(dt) -- 678
	local shakeX = 0 -- 679
	local shakeY = 0 -- 680
	if self.shakeT > 0 then -- 680
		self.shakeT = self.shakeT - dt -- 682
		shakeX = (math.random() * 2 - 1) * self.shakeMag -- 683
		shakeY = (math.random() * 2 - 1) * self.shakeMag -- 684
	end -- 684
	if self.mode == "prologue" and self.intro then -- 684
		self.intro:update(math.min(dt, 0.05)) -- 688
		if self.intro:done() then -- 688
			self.intro = nil -- 690
			self:toTitle() -- 691
		end -- 691
	elseif self.mode == "rewind" then -- 691
		self.rewindT = self.rewindT + dt -- 695
		self.hud:setRewind(math.min(1, self.rewindT / 2)) -- 696
		if self.rewindT >= 2 then -- 696
			self.hud:setRewind(-1) -- 698
			self:doRewind() -- 699
		end -- 699
	elseif self.mode == "dead" then -- 699
		if self.deadT > 0 then -- 699
			self.deadT = self.deadT - dt -- 704
			if self.deadT <= 0 then -- 704
				self:startRewind() -- 706
			end -- 706
		end -- 706
	elseif self.mode == "dialog" then -- 706
		if not self.dialog:isOpen() then -- 706
			self.mode = "play" -- 712
		else -- 712
			self.dialog:update(dt) -- 714
		end -- 714
	elseif (self.mode == "play" or self.mode == "confront") and not self.paused then -- 714
		if self.hitstop > 0 then -- 714
			self.hitstop = self.hitstop - dt -- 718
		else -- 718
			if self.bladeT > 0 then -- 718
				self.bladeT = self.bladeT - dt -- 721
				if self.bladeT <= 0 then -- 721
					self:endGame("blade") -- 723
				end -- 723
			end -- 723
			self:tickPendingFloorStory(dt) -- 726
			if self.mode == "play" or self.mode == "confront" then -- 726
				if self.teleportT >= 0 then -- 726
					self:advanceTeleport(dt) -- 729
				else -- 729
					self:simWorld(dt) -- 731
				end -- 731
			end -- 731
		end -- 731
	end -- 731
	self:updateVisuals(dt, shakeX, shakeY) -- 736
end -- 676
function Game.prototype.updateMovers(self) -- 739
	local plats = Tower.platforms -- 740
	do -- 740
		local i = 0 -- 741
		while i < #plats do -- 741
			do -- 741
				local p = plats[i + 1] -- 742
				if not p.mover then -- 742
					goto __continue154 -- 744
				end -- 744
				local m = p.mover -- 746
				local s = 0.5 - 0.5 * math.cos((self.time / m.period + m.phase) * 6.2831853) -- 747
				local nx = lerp(m.ax, m.bx, s) -- 748
				local ny = lerp(m.ay, m.by, s) -- 749
				local dx = nx - p.x -- 750
				local dy = ny - p.y -- 751
				p.x = nx -- 752
				p.y = ny -- 753
				if self.player.body.groundId == p.id then -- 753
					local ____self_player_body_0, ____x_1 = self.player.body, "x" -- 753
					____self_player_body_0[____x_1] = ____self_player_body_0[____x_1] + dx -- 755
					local ____self_player_body_2, ____y_3 = self.player.body, "y" -- 755
					____self_player_body_2[____y_3] = ____self_player_body_2[____y_3] + dy -- 756
				end -- 756
			end -- 756
			::__continue154:: -- 756
			i = i + 1 -- 741
		end -- 741
	end -- 741
end -- 739
function Game.prototype.beginLoop(self) -- 761
	self.tree = __TS__New(TreeSystem, "启程") -- 763
	self.tree:attachTo(self.uiRoot) -- 764
	self.tree.onJumpTo = function(____, id) return self:jumpToNode(id) end -- 766
	self.tree.onNodeAdded = function(____, id) -- 768
		self.treeSnap[id] = self:cloneLoopState(self.state) -- 769
	end -- 768
	self.treeSnap[self.tree.nodes[1].id] = self:cloneLoopState(self.state) -- 771
	self.treeArchived = false -- 772
	self.treeFloorSeen = {} -- 774
	self.treeGateSeen = {} -- 775
	self.treeDeathSeen = false -- 776
	self:growFloor(0) -- 777
	self.causFx:clear() -- 778
	self.stealth:resetRuntime() -- 779
	self:applyLoopVariants() -- 780
	self.mode = "play" -- 781
	self:playFloorBgm(1.5) -- 782
end -- 761
function Game.prototype.growFloor(self, floor) -- 788
	if self.tree == nil or self.treeFloorSeen[floor] == true then -- 788
		return -- 790
	end -- 790
	self.treeFloorSeen[floor] = true -- 792
	local short = { -- 794
		"初临河滩", -- 794
		"入古镇街巷", -- 794
		"上悬空工坊", -- 794
		"登塔外环廊", -- 794
		"探机关层", -- 794
		"入观星之间", -- 794
		"登观星台" -- 794
	} -- 794
	local name = floor >= 0 and floor < #short and short[floor + 1] or "行至新境" -- 795
	self.tree:extend(name) -- 796
end -- 788
function Game.prototype.growGate(self, gateId) -- 799
	if self.tree == nil or self.treeGateSeen[gateId] == true then -- 799
		return -- 801
	end -- 801
	self.treeGateSeen[gateId] = true -- 803
	local via = gateId == "gate_bell" and "钟鸣桥落" or (gateId == "gate_corridor" and "双信闸启" or (gateId == "gate_mech" and "压石嵌剑" or (gateId == "gate_star" and "星门台现" or "闸开"))) -- 804
	self.tree:extend(via) -- 813
end -- 799
function Game.prototype.growNight(self) -- 816
	if self.tree == nil then -- 816
		return -- 818
	end -- 818
	local n = self.state.loopIndex + 1 -- 820
	local cn = { -- 821
		"", -- 821
		"一", -- 821
		"二", -- 821
		"三", -- 821
		"四", -- 821
		"五", -- 821
		"六", -- 821
		"七", -- 821
		"八", -- 821
		"九" -- 821
	} -- 821
	local label = n <= 9 and ("第" .. cn[n + 1]) .. "夜重溯" or ("第" .. tostring(n)) .. "夜" -- 822
	self.tree:extend(label) -- 823
end -- 816
function Game.prototype.simWorld(self, dt) -- 826
	self:updateMovers() -- 827
	local plats = activePlatforms(Tower.platforms, self.state.openedGates) -- 828
	local ctx = { -- 830
		platforms = plats, -- 830
		ladders = self:activeLadders(), -- 830
		climbWalls = Tower.climbWalls -- 830
	} -- 830
	local wasGround = self.player.body.onGround -- 831
	local vyBefore = self.player.body.vy -- 832
	local input = self:buildInput(true) -- 833
	self.player:update(dt, input, ctx) -- 834
	self:consumeAttack() -- 835
	self:consumeQi() -- 836
	self:updateSwingArc(dt) -- 837
	local pbody = self.player.body -- 838
	local prect = bodyRect(pbody) -- 839
	self.enemies:update( -- 840
		dt, -- 840
		pbody.x, -- 840
		pbody.y, -- 840
		prect, -- 840
		self.player:isInvulnerable(), -- 840
		ctx, -- 840
		pbody.vy -- 840
	) -- 840
	local cpNow = self:findCheckpoint(self.state.currentCheckpointId) -- 842
	local pfloor = cpNow and cpNow.floor or 0 -- 843
	local landing = not wasGround and self.player.body.onGround and vyBefore < -420 and -vyBefore or 0 -- 844
	self.stealth:update( -- 847
		dt, -- 847
		pbody.x, -- 847
		pbody.y, -- 847
		self.player.dashTimer > 0, -- 847
		{landingSpeed = landing > 0 and landing or nil, floor = pfloor, attackX = self.player.attack ~= nil and pbody.x or nil} -- 847
	) -- 847
	local alerted = self.stealth:anyAlerted() -- 852
	self.state.stealthAlert = alerted -- 853
	if alerted and pfloor == 1 then -- 853
		self.floor1Alert = true -- 855
	end -- 855
	local pushDir = (input.right and 1 or 0) - (input.left and 1 or 0) -- 858
	self.mech:update( -- 859
		dt, -- 859
		prect, -- 859
		pushDir, -- 859
		self:playerAttackRect(), -- 859
		self:qiRects(), -- 859
		ctx -- 859
	) -- 859
	if self.player.dashTimer > 0 then -- 859
		self.mech:tryDashWindSigils(pbody.x, pbody.y) -- 862
	end -- 862
	self:clampPlayerToStones(prect) -- 864
	self:updateQiShots(dt, plats) -- 865
	if pbody.y < -240 and (self.mode == "play" or self.mode == "confront") then -- 865
		self:pitFall() -- 867
	end -- 867
	if self.mode == "play" then -- 867
		self.mech:touchCheckpoints(Tower.checkpoints, pbody.x, pbody.y) -- 870
		self.mech:touchCollectibles(Tower.collectibles, pbody.x, pbody.y) -- 871
		self:checkStoryTriggers() -- 872
		self:checkHazards() -- 873
	end -- 873
	local boss = self.enemies:boss() -- 875
	if boss and not self.state.storySeen.story_boss_intro and not self.state.flags.bossDown then -- 875
		local b = boss.body -- 877
		if math.abs(b.x - pbody.x) < 520 and math.abs(b.y - pbody.y) < 320 then -- 877
			self:openDialog("story_boss_intro") -- 879
		end -- 879
	end -- 879
	self:regenIntent(dt) -- 882
	if pbody.y < -80 then -- 882
		if self.player:hurt(1, pbody.x) then -- 882
			self:applyHurt(1) -- 885
		end -- 885
		if self.state.heroineLife > 0 then -- 885
			self:respawnAt(self.state.currentCheckpointId) -- 888
		end -- 888
	end -- 888
end -- 826
function Game.prototype.playerAttackRect(self) -- 893
	return self.player.attack and self.player.attack.hitbox or nil -- 894
end -- 893
function Game.prototype.clampPlayerToStones(self, prect) -- 899
	local b = self.player.body -- 900
	do -- 900
		local i = 0 -- 901
		while i < #self.mech.stones do -- 901
			do -- 901
				local s = self.mech.stones[i + 1] -- 902
				local sx = s.x - s.w / 2 -- 903
				local sy = s.y - s.h / 2 -- 904
				local overlapX = prect.x < sx + s.w and prect.x + prect.w > sx -- 905
				local overlapY = prect.y < sy + s.h and prect.y + prect.h > sy -- 906
				if not overlapX or not overlapY then -- 906
					goto __continue179 -- 908
				end -- 908
				local penLeft = prect.x + prect.w - sx -- 910
				local penRight = sx + s.w - prect.x -- 911
				if penLeft < penRight and penLeft <= 30 then -- 911
					b.x = sx - prect.w / 2 -- 913
				elseif penRight < penLeft and penRight <= 30 then -- 913
					b.x = sx + s.w + prect.w / 2 -- 915
				end -- 915
			end -- 915
			::__continue179:: -- 915
			i = i + 1 -- 901
		end -- 901
	end -- 901
end -- 899
function Game.prototype.consumeAttack(self) -- 920
	local atk = self.player.attack -- 921
	if not atk then -- 921
		self.attackApplied = false -- 923
		return -- 924
	end -- 924
	if self.attackApplied then -- 924
		return -- 927
	end -- 927
	self.attackApplied = true -- 929
	local hits = self.enemies:takeHit( -- 930
		atk.hitbox, -- 930
		1, -- 930
		atk.dir, -- 930
		220, -- 930
		self.player.body.x -- 930
	) -- 930
	if self.state.flags.treePlanted == true and self.state.flags.treeCut ~= true then -- 930
		local hb = atk.hitbox -- 933
		local tx = 1120 -- 934
		if hb.x < tx + 160 and hb.x + hb.w > tx and hb.y < Tower.TOPS[1] + 300 and hb.y + hb.h > Tower.TOPS[1] then -- 934
			self:cutTree() -- 936
		end -- 936
	end -- 936
	if hits > 0 then -- 936
		self.hitstop = 0.06 -- 940
		sfx("heroHit", 0.9) -- 941
		sfx("enemyHurt", 0.65) -- 942
		self.fx:spawnSpark(atk.hitbox.x + (atk.dir > 0 and atk.hitbox.w or 0), atk.hitbox.y + atk.hitbox.h / 2, atk.dir) -- 943
	end -- 943
	if self.state.flags.confront and not self.state.drawnBladeAgainst then -- 943
		local dx = math.abs(atk.hitbox.x + atk.hitbox.w / 2 - self:shenX()) -- 946
		local dy = math.abs(atk.hitbox.y + atk.hitbox.h / 2 - self:shenY()) -- 947
		if dx < 130 and dy < 130 then -- 947
			self.state.drawnBladeAgainst = true -- 949
			self.state.flags.bladeClash = true -- 950
			self.bladeT = 0.9 -- 951
			self:shake(0.3, 7) -- 952
			self.fx:spawnRing( -- 953
				self:shenX(), -- 953
				self:shenY() + 30, -- 953
				{r = 43, g = 40, b = 36, a = 255}, -- 953
				20, -- 953
				180, -- 953
				0.6 -- 953
			) -- 953
			if self.tree ~= nil then -- 953
				self.tree:addChoice("剑锋相向") -- 956
			end -- 956
			self:logCause("剑锋相向·因果断裂") -- 958
		end -- 958
	end -- 958
end -- 920
function Game.prototype.consumeQi(self) -- 963
	local req = self.player.qiReq -- 964
	if not req then -- 964
		return -- 966
	end -- 966
	self.player.qiReq = nil -- 968
	if self.state.swordIntent < 1 then -- 968
		self.fx:spawnDust(req.x, req.y, req.dir) -- 970
		return -- 971
	end -- 971
	local ____self_state_4, ____swordIntent_5 = self.state, "swordIntent" -- 971
	____self_state_4[____swordIntent_5] = ____self_state_4[____swordIntent_5] - 1 -- 973
	sfx("sword", 1) -- 974
	local ____self_qiShots_6 = self.qiShots -- 974
	____self_qiShots_6[#____self_qiShots_6 + 1] = { -- 975
		x = req.x, -- 975
		y = req.y, -- 975
		dir = req.dir, -- 975
		life = 1.6, -- 975
		alive = true, -- 975
		phase = #self.qiShots * 1.7, -- 975
		hits = 0, -- 975
		hitCd = 0, -- 975
		trailT = 0 -- 975
	} -- 975
	self.fx:spawnInkBurst(req.x, req.y, req.dir) -- 976
	self.sheetFx:spawn(req.x + req.dir * 14, req.y, req.dir, true) -- 977
	self.slashFx:spawnSwing(req.x + req.dir * 10, req.y, req.dir, true) -- 979
	self.qiSwingT = 0.2 -- 980
end -- 963
function Game.prototype.updateSwingArc(self, dt) -- 984
	if self.qiSwingT > 0 then -- 984
		self.qiSwingT = self.qiSwingT - dt -- 986
	end -- 986
	if self.player.attackTimer <= 0 then -- 986
		self.lastSwingSeq = -1 -- 989
		return -- 990
	end -- 990
	local seq = self.player.attackSeq -- 992
	if seq ~= self.lastSwingSeq then -- 992
		self.lastSwingSeq = seq -- 994
		if self.qiSwingT <= 0 then -- 994
			self.slashFx:spawnSwing(self.player.body.x + self.player.facing * 26, self.player.body.y + 8, self.player.facing, false) -- 996
		end -- 996
	end -- 996
end -- 984
function Game.prototype.qiRects(self) -- 1001
	local list = {} -- 1002
	do -- 1002
		local i = 0 -- 1003
		while i < #self.qiShots do -- 1003
			local q = self.qiShots[i + 1] -- 1004
			if q.alive then -- 1004
				list[#list + 1] = {x = q.x - 20, y = q.y - 32, w = 90, h = 64} -- 1006
			end -- 1006
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	return list -- 1009
end -- 1001
function Game.prototype.updateQiShots(self, dt, plats) -- 1012
	do -- 1012
		local i = 0 -- 1013
		while i < #self.qiShots do -- 1013
			do -- 1013
				local q = self.qiShots[i + 1] -- 1014
				if not q.alive then -- 1014
					goto __continue206 -- 1016
				end -- 1016
				q.x = q.x + q.dir * 720 * dt -- 1018
				q.life = q.life - dt -- 1019
				q.hitCd = q.hitCd - dt -- 1020
				q.trailT = q.trailT - dt -- 1021
				if q.trailT <= 0 then -- 1021
					self.sheetFx:spawn(q.x - q.dir * 18, q.y, q.dir, false) -- 1023
					q.trailT = 0.1 -- 1024
				end -- 1024
				if q.life <= 0 then -- 1024
					q.alive = false -- 1027
					goto __continue206 -- 1028
				end -- 1028
				local rect = {x = q.x - 20, y = q.y - 32, w = 90, h = 64} -- 1030
				if q.hitCd <= 0 and self.enemies:takeHit(rect, 1, q.dir, 160) > 0 then -- 1030
					q.hits = q.hits + 1 -- 1032
					q.hitCd = 0.22 -- 1033
					self.hitstop = 0.05 -- 1034
					self.fx:spawnInkBurst(q.x, q.y, q.dir) -- 1035
					self.sheetFx:spawn(q.x + q.dir * 6, q.y, q.dir, true) -- 1036
					if q.hits >= 3 then -- 1036
						q.alive = false -- 1038
						goto __continue206 -- 1039
					end -- 1039
				end -- 1039
				do -- 1039
					local j = 0 -- 1042
					while j < #plats do -- 1042
						local p = plats[j + 1] -- 1043
						if p.kind ~= "one-way" and rectOverlap(rect, p) then -- 1043
							q.alive = false -- 1045
							self.fx:spawnDust(q.x, q.y, -q.dir) -- 1046
							self.sheetFx:spawn(q.x, q.y, q.dir, false) -- 1047
							break -- 1048
						end -- 1048
						j = j + 1 -- 1042
					end -- 1042
				end -- 1042
			end -- 1042
			::__continue206:: -- 1042
			i = i + 1 -- 1013
		end -- 1013
	end -- 1013
end -- 1012
function Game.prototype.regenIntent(self, dt) -- 1054
	if self.state.swordIntent >= self.state.maxSwordIntent then -- 1054
		return -- 1056
	end -- 1056
	self.intentRegenT = self.intentRegenT + dt -- 1058
	if self.intentRegenT >= 5 then -- 1058
		self.intentRegenT = 0 -- 1060
		local ____self_state_7, ____swordIntent_8 = self.state, "swordIntent" -- 1060
		____self_state_7[____swordIntent_8] = ____self_state_7[____swordIntent_8] + 1 -- 1061
	end -- 1061
end -- 1054
function Game.prototype.checkStoryTriggers(self) -- 1082
	self.nearStoryId = nil -- 1083
	self.hintBubbleText = nil -- 1084
	self.hintBubbleBestD = 1000000000 -- 1085
	local prect = bodyRect(self.player.body) -- 1086
	local trigs = Tower.storyTriggers -- 1087
	local bestD = 1000000000 -- 1088
	do -- 1088
		local i = 0 -- 1089
		while i < #trigs do -- 1089
			do -- 1089
				local t = trigs[i + 1] -- 1090
				if t.hint ~= nil then -- 1090
					if rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1090
						local d = math.abs(self.player.body.x - (t.x + t.w / 2)) -- 1095
						if d < self.hintBubbleBestD then -- 1095
							self.hintBubbleBestD = d -- 1097
							self.hintBubbleText = t.hint -- 1098
							self.hintBubbleX = t.x + t.w -- 1099
							self.hintBubbleY = t.y + t.h -- 1100
						end -- 1100
					end -- 1100
					goto __continue220 -- 1103
				end -- 1103
				if t.storyId == "story_arrow" then -- 1103
					if not self.state.storySeen[t.storyId] and rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1103
						self:openDialog(t.storyId) -- 1108
						return -- 1109
					end -- 1109
					goto __continue220 -- 1111
				end -- 1111
				if t.once and self.state.storySeen[t.storyId] then -- 1111
					goto __continue220 -- 1114
				end -- 1114
				if self:isAutoMonologue(t.storyId) then -- 1114
					if rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1114
						self:openDialog(t.storyId) -- 1119
						return -- 1120
					end -- 1120
					goto __continue220 -- 1122
				end -- 1122
				if rectOverlap(prect, {x = t.x, y = t.y, w = t.w, h = t.h}) then -- 1122
					local d = math.abs(self.player.body.x - (t.x + t.w / 2)) -- 1125
					if d < bestD then -- 1125
						bestD = d -- 1127
						self.nearStoryId = t.storyId -- 1128
					end -- 1128
				end -- 1128
			end -- 1128
			::__continue220:: -- 1128
			i = i + 1 -- 1089
		end -- 1089
	end -- 1089
end -- 1082
function Game.prototype.checkHazards(self) -- 1134
	local prect = bodyRect(self.player.body) -- 1135
	local hs = Tower.hazards -- 1136
	do -- 1136
		local i = 0 -- 1137
		while i < #hs do -- 1137
			if rectOverlap(prect, hs[i + 1]) then -- 1137
				if self.player:hurt(hs[i + 1].damage, self.player.body.x) then -- 1137
					self:applyHurt(hs[i + 1].damage) -- 1140
				end -- 1140
				break -- 1144
			end -- 1144
			i = i + 1 -- 1137
		end -- 1137
	end -- 1137
end -- 1134
function Game.prototype.nearBoss(self) -- 1151
	local b = self.enemies:boss() -- 1152
	if b == nil then -- 1152
		return false -- 1154
	end -- 1154
	return math.abs(b.body.x - self.player.body.x) < 720 and math.abs(b.body.y - self.player.body.y) < 240 -- 1156
end -- 1151
function Game.prototype.onPlayerHit(self, dmg, fromX) -- 1159
	if self.player:hurt(dmg, fromX) then -- 1159
		self:applyHurt(dmg) -- 1161
	end -- 1161
end -- 1159
function Game.prototype.applyHurt(self, dmg) -- 1165
	self.state.heroineLife = math.max(0, self.state.heroineLife - dmg) -- 1166
	self.hud:flashDamage() -- 1167
	self:shake(0.22, 6) -- 1168
	self.hitstop = 0.08 -- 1169
	if self.state.heroineLife <= 0 then -- 1169
		self:die() -- 1171
	end -- 1171
end -- 1165
function Game.prototype.interact(self) -- 1175
	local px = self.player.body.x -- 1176
	local py = self.player.body.y -- 1177
	local portal = self:nearPortal(px, py) -- 1178
	if portal ~= nil then -- 1178
		self:startPortal(portal) -- 1180
		return -- 1181
	end -- 1181
	if self.nearStoryId ~= nil then -- 1181
		local id = self.nearStoryId -- 1184
		self.nearStoryId = nil -- 1185
		self:openDialog(id) -- 1186
		return -- 1187
	end -- 1187
	if self.mech:tryLightLantern(Tower.lanterns, px, py) then -- 1187
		return -- 1190
	end -- 1190
	if self.mech:tryLightStar(px, py) then -- 1190
		return -- 1194
	end -- 1194
	if self:tryTreePuzzle(px, py) then -- 1194
		return -- 1198
	end -- 1198
	if self:tryPebblePickup(px, py) then -- 1198
		return -- 1201
	end -- 1201
	if self:tryBarrel(px, py) then -- 1201
		return -- 1204
	end -- 1204
	if self:tryWaiter(px, py) then -- 1204
		return -- 1207
	end -- 1207
	local nearShen = math.abs(px - self:shenX()) < 90 and math.abs(py - self:shenY()) < 140 -- 1209
	if self.state.flags.confront and nearShen then -- 1209
		self:putDownSword() -- 1211
		return -- 1212
	end -- 1212
	if not self.state.storySeen.story_check_intro and nearShen then -- 1212
		self:openDialog("story_check_intro") -- 1215
	end -- 1215
end -- 1175
function Game.prototype.putDownSword(self) -- 1219
	self.state.drawnBladeAgainst = false -- 1220
	self.state.flags.putDownSword = true -- 1221
	if self.state.shenyanTrust >= 4 then -- 1221
		if self.tree ~= nil then -- 1221
			self.tree:addChoice("重逢月满") -- 1224
		end -- 1224
		self:endGame("reunion") -- 1226
	else -- 1226
		self.state.objective = "他叹息离去——也许，还有下一次轮回。（回溯再试试）" -- 1228
		self:loopAdvance() -- 1229
	end -- 1229
end -- 1219
function Game.prototype.openDialog(self, id) -- 1236
	local node = STORY_NODES[id] -- 1237
	if node == nil then -- 1237
		return -- 1239
	end -- 1239
	self.state.storySeen[id] = true -- 1241
	if node.setFlag then -- 1241
		self.state.flags[node.setFlag] = true -- 1243
	end -- 1243
	if node.objective then -- 1243
		self.state.objective = node.objective -- 1246
	end -- 1246
	self.mode = "dialog" -- 1248
	local loops = "" .. tostring(7 + self.state.rewindCount) -- 1250
	local lines = __TS__ArrayMap( -- 1251
		node.lines, -- 1251
		function(____, ln) return { -- 1251
			speaker = ln.speaker, -- 1251
			text = __TS__StringReplace(ln.text, "{loops}", loops) -- 1251
		} end -- 1251
	) -- 1251
	local asked = self.state.askedChoices -- 1253
	local allChoices = node.choices -- 1254
	local openChoices = allChoices ~= nil and __TS__ArrayFilter( -- 1255
		allChoices, -- 1255
		function(____, c) return not asked[(node.id .. "|") .. c.text] end -- 1255
	) or nil -- 1255
	local runtime = __TS__ObjectAssign({}, node, {lines = lines, choices = openChoices}) -- 1256
	self.askList = openChoices ~= nil and __TS__ArraySlice(openChoices) or ({}) -- 1257
	self.dialog.onChoiceAsk = function(____, index) return self:onChoiceAsk(runtime, index) end -- 1258
	self.dialog.onChoice = function(____, index) return self:applyChoice(runtime, index) end -- 1259
	local speaker = #runtime.lines > 0 and runtime.lines[1].speaker or "沈砚" -- 1260
	self.dialog:open(runtime, speaker) -- 1261
end -- 1236
function Game.prototype.onChoiceAsk(self, node, index) -- 1265
	local choice = node.choices ~= nil and node.choices[index + 1] or nil -- 1266
	if choice == nil then -- 1266
		return -- 1268
	end -- 1268
	local ____self_state_9, ____shenyanTrust_10 = self.state, "shenyanTrust" -- 1268
	____self_state_9[____shenyanTrust_10] = ____self_state_9[____shenyanTrust_10] + choice.trust -- 1270
	if choice.memory and __TS__ArrayIndexOf(self.state.memories, choice.memory) < 0 then -- 1270
		local ____self_state_memories_11 = self.state.memories -- 1270
		____self_state_memories_11[#____self_state_memories_11 + 1] = choice.memory -- 1272
	end -- 1272
	self.fx:spawnRing( -- 1274
		self.player.body.x, -- 1274
		self.player.body.y + 30, -- 1274
		CYAN, -- 1274
		10, -- 1274
		90, -- 1274
		0.5 -- 1274
	) -- 1274
	self.state.askedChoices[(node.id .. "|") .. choice.text] = true -- 1275
	local remaining = {} -- 1278
	if node.id == "story_observer_1" then -- 1278
		remaining = __TS__ArrayFilter( -- 1280
			self.askList, -- 1280
			function(____, c) return not self.state.askedChoices[(node.id .. "|") .. c.text] end -- 1280
		) -- 1280
	end -- 1280
	self.dialog:setNextChoices(remaining) -- 1282
end -- 1265
function Game.prototype.applyChoice(self, node, index) -- 1287
	if node.id == "story_arrow" and index == 0 then -- 1287
		self:onPlayerHit(1, self.player.body.x + 60) -- 1290
	end -- 1290
	if node.id == "story_final" then -- 1290
		self.state.flags.confront = true -- 1293
		self.state.objective = "走近沈砚：E 放下剑 · Q 以命换命 · J 剑锋相向" -- 1294
		self.mode = "confront" -- 1295
	elseif self.mode == "dialog" then -- 1295
		self.mode = "play" -- 1297
	end -- 1297
end -- 1287
function Game.prototype.shenProgress(self) -- 1301
	local trigs = Tower.storyTriggers -- 1302
	local n = 0 -- 1303
	do -- 1303
		local i = 0 -- 1304
		while i < #trigs do -- 1304
			if self.state.storySeen[trigs[i + 1].storyId] then -- 1304
				n = n + 1 -- 1306
			end -- 1306
			i = i + 1 -- 1304
		end -- 1304
	end -- 1304
	return n -- 1309
end -- 1301
function Game.prototype.shenX(self) -- 1312
	if self.state.flags.confront then -- 1312
		return 2200 -- 1314
	end -- 1314
	local xs = { -- 1316
		560, -- 1316
		500, -- 1316
		650, -- 1316
		480, -- 1316
		520, -- 1316
		460 -- 1316
	} -- 1316
	return xs[math.min( -- 1317
		self:shenProgress(), -- 1317
		#xs - 1 -- 1317
	) + 1] -- 1317
end -- 1312
function Game.prototype.shenY(self) -- 1320
	if self.state.flags.confront then -- 1320
		return Tower.TOPS[#Tower.TOPS] -- 1324
	end -- 1324
	local tops = Tower.TOPS -- 1327
	return tops[math.min( -- 1328
		self:shenProgress(), -- 1328
		#tops - 2 -- 1328
	) + 1] -- 1328
end -- 1320
function Game.prototype.pitFall(self) -- 1332
	local ____self_state_12, ____heroineLife_13 = self.state, "heroineLife" -- 1332
	____self_state_12[____heroineLife_13] = ____self_state_12[____heroineLife_13] - 1 -- 1333
	self.hud:flashDamage() -- 1334
	self:shake(0.3, 8) -- 1335
	__TS__ArraySetLength(self.qiShots, 0) -- 1335
	if self.state.heroineLife <= 0 then -- 1335
		self:die() -- 1338
		return -- 1339
	end -- 1339
	self:respawnAt(self.state.currentCheckpointId) -- 1341
end -- 1332
function Game.prototype.onEnemyDeath(self, def, x, y) -- 1344
	self.fx:spawnMist(def.x, def.y, def.kind == "boss" and 10 or 4, def.kind == "boss" and 1.6 or 1) -- 1345
	self.boomFx:spawn(x, y + 40, def.kind == "boss") -- 1346
	if def.floor == 1 then -- 1346
		self.floor1Kill = true -- 1349
	end -- 1349
	if def.kind == "boss" then -- 1349
		self:shake(0.5, 9) -- 1352
		self:startConfront() -- 1353
	end -- 1353
	if def.id == "e00" and not self.state.flags.banditDown then -- 1353
		self.state.flags.banditDown = true -- 1356
		self.state.objective = "强盗已退——登上东边木梯（W 攀爬），进入古镇街巷" -- 1357
	end -- 1357
end -- 1344
function Game.prototype.startConfront(self) -- 1361
	self.state.flags.bossDown = true -- 1362
	if self.tree ~= nil then -- 1362
		self.tree:extend("斩观星者") -- 1364
	end -- 1364
	self:openDialog("story_final") -- 1366
end -- 1361
function Game.prototype.die(self) -- 1370
	self.mode = "dead" -- 1371
	if self.state.maxLife <= 1 then -- 1371
		if self.tree ~= nil then -- 1371
			self.tree:addChoice("力竭而终") -- 1374
		end -- 1374
		self:logCause("力竭而终·月相永滞") -- 1376
		self:endGame("exhausted") -- 1377
		return -- 1378
	end -- 1378
	self.deadT = 0.8 -- 1380
	self.hud:flashDamage() -- 1381
	self.state.objective = "月相逆卷——正在回溯本层……（R 立即回溯）" -- 1382
end -- 1370
function Game.prototype.startRewind(self) -- 1386
	if self.mode == "ending" or self.mode == "title" or self.mode == "prologue" then -- 1386
		return -- 1388
	end -- 1388
	self.hud:hideEnding() -- 1390
	self.mode = "rewind" -- 1391
	self.rewindT = 0 -- 1392
	self.causFx:play("rewind", "月相逆卷·本层回溯") -- 1393
	rewindFloor(self.state) -- 1394
	self.hud:setRewind(0) -- 1395
end -- 1386
function Game.prototype.doRewind(self) -- 1399
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 1400
	self.stealth:resetRuntime() -- 1401
	self.floor1Kill = false -- 1402
	self.floor1Alert = false -- 1403
	__TS__ArraySetLength(self.qiShots, 0) -- 1403
	if not self.treeDeathSeen and not self.treeJumpPending then -- 1403
		self.treeDeathSeen = true -- 1406
		if self.tree ~= nil then -- 1406
			self.tree:extend("殒落再临") -- 1408
		end -- 1408
	end -- 1408
	self.treeJumpPending = false -- 1411
	self:respawnAt(self.state.currentCheckpointId) -- 1412
	self.mode = "play" -- 1413
end -- 1399
function Game.prototype.copyBoolRecord(self, src) -- 1417
	local out = {} -- 1418
	for k in pairs(src) do -- 1419
		out[k] = src[k] -- 1420
	end -- 1420
	return out -- 1422
end -- 1417
function Game.prototype.cloneLoopState(self, s) -- 1426
	return { -- 1427
		loopIndex = s.loopIndex, -- 1428
		phaseIndex = s.phaseIndex, -- 1429
		heroineLife = s.heroineLife, -- 1430
		maxLife = s.maxLife, -- 1431
		swordIntent = s.swordIntent, -- 1432
		maxSwordIntent = s.maxSwordIntent, -- 1433
		shenyanTrust = s.shenyanTrust, -- 1434
		drawnBladeAgainst = s.drawnBladeAgainst, -- 1435
		rewindCount = s.rewindCount, -- 1436
		moonstones = s.moonstones, -- 1437
		mechanismParts = s.mechanismParts, -- 1438
		tokens = s.tokens, -- 1439
		memories = __TS__ArraySlice(s.memories), -- 1440
		flags = self:copyBoolRecord(s.flags), -- 1441
		cutRopes = self:copyBoolRecord(s.cutRopes), -- 1442
		rungBells = self:copyBoolRecord(s.rungBells), -- 1443
		platesActive = self:copyBoolRecord(s.platesActive), -- 1444
		lanternsLit = self:copyBoolRecord(s.lanternsLit), -- 1445
		lanternSequence = s.lanternSequence, -- 1446
		lanternFailed = s.lanternFailed, -- 1447
		openedGates = self:copyBoolRecord(s.openedGates), -- 1448
		collectedIds = self:copyBoolRecord(s.collectedIds), -- 1449
		checkpointsActivated = self:copyBoolRecord(s.checkpointsActivated), -- 1450
		currentCheckpointId = s.currentCheckpointId, -- 1451
		storySeen = self:copyBoolRecord(s.storySeen), -- 1452
		askedChoices = self:copyBoolRecord(s.askedChoices), -- 1453
		objective = s.objective, -- 1454
		stealthAlert = s.stealthAlert, -- 1455
		sneakBonus = s.sneakBonus, -- 1456
		rewindPenalty = s.rewindPenalty, -- 1457
		pebbles = s.pebbles, -- 1458
		causalityLog = __TS__ArraySlice(s.causalityLog) -- 1459
	} -- 1459
end -- 1426
function Game.prototype.jumpToNode(self, id) -- 1466
	local snap = self.treeSnap[id] -- 1467
	if snap == nil then -- 1467
		return -- 1469
	end -- 1469
	if self.dialog:isOpen() or self.teleportT >= 0 then -- 1469
		return -- 1472
	end -- 1472
	local prevSeen = self.state.storySeen -- 1477
	local prevAsked = self.state.askedChoices -- 1478
	local prevMemories = __TS__ArraySlice(self.state.memories) -- 1479
	self.state = self:cloneLoopState(snap) -- 1480
	for k in pairs(prevSeen) do -- 1481
		self.state.storySeen[k] = true -- 1482
	end -- 1482
	for k in pairs(prevAsked) do -- 1484
		self.state.askedChoices[k] = true -- 1485
	end -- 1485
	do -- 1485
		local i = 0 -- 1487
		while i < #prevMemories do -- 1487
			if __TS__ArrayIndexOf(self.state.memories, prevMemories[i + 1]) < 0 then -- 1487
				local ____self_state_memories_14 = self.state.memories -- 1487
				____self_state_memories_14[#____self_state_memories_14 + 1] = prevMemories[i + 1] -- 1489
			end -- 1489
			i = i + 1 -- 1487
		end -- 1487
	end -- 1487
	self.mech.state = self.state -- 1492
	self.mech:syncStones(Tower.pushStones) -- 1493
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 1494
	self.stealth:resetRuntime() -- 1495
	__TS__ArraySetLength(self.qiShots, 0) -- 1495
	self.attackApplied = false -- 1497
	self.intentRegenT = 0 -- 1498
	self.bladeT = 0 -- 1499
	self.floor1Kill = false -- 1500
	self.floor1Alert = false -- 1501
	self.treeFloorSeen = {} -- 1503
	self.treeGateSeen = {} -- 1504
	self.treeDeathSeen = false -- 1505
	self.treeJumpPending = true -- 1506
	self:respawnAt(self.state.currentCheckpointId) -- 1507
	self.mode = "rewind" -- 1508
	self.rewindT = 0 -- 1509
	self.causFx:play("rewind", "时空回溯·跳回节点") -- 1510
	self.hud:setRewind(0) -- 1511
end -- 1466
function Game.prototype.respawnAt(self, id) -- 1514
	local cp = self:findCheckpoint(id) -- 1515
	local x = cp and cp.x or 800 -- 1516
	local y = (cp and cp.y or 320) + 42 -- 1518
	self.player:respawn(x, y) -- 1519
	self.camX = x -- 1520
	self.camY = y -- 1521
	self.renderer:setFloorScene(cp and cp.floor or 0) -- 1522
	self:playFloorBgm() -- 1523
	if cp ~= nil then -- 1523
		local intro = self:floorIntroStory(cp.floor) -- 1526
		if intro ~= nil then -- 1526
			self.pendingFloorStory = intro -- 1528
			self.pendingFloorStoryFloor = cp.floor -- 1529
			self.pendingFloorStoryT = 0.6 -- 1530
		end -- 1530
	end -- 1530
end -- 1514
function Game.prototype.nearPortal(self, px, py) -- 1540
	if self.teleportT >= 0 or self.mode ~= "play" then -- 1540
		return nil -- 1542
	end -- 1542
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1544
	local floor = cp and cp.floor or -1 -- 1545
	do -- 1545
		local i = 0 -- 1546
		while i < #Tower.portals do -- 1546
			do -- 1546
				local p = Tower.portals[i + 1] -- 1547
				if p.gateId ~= nil and self.mech:isGateOpen(p.gateId) ~= true then -- 1547
					goto __continue318 -- 1550
				end -- 1550
				if p.floor == floor and math.abs(px - p.x) < PORTAL_USE_RADIUS and math.abs(py - (p.y + 55)) < 95 then -- 1550
					return p -- 1553
				end -- 1553
			end -- 1553
			::__continue318:: -- 1553
			i = i + 1 -- 1546
		end -- 1546
	end -- 1546
	return nil -- 1556
end -- 1540
function Game.prototype.startPortal(self, p) -- 1560
	local cp = self:checkpointOfFloor(p.targetFloor) -- 1561
	if cp == nil then -- 1561
		return -- 1563
	end -- 1563
	self.teleportT = 0 -- 1565
	self.pendingPortalTarget = {cpId = cp.id, floor = cp.floor, x = cp.x, y = cp.y} -- 1566
	self.fx:spawnStars(p.x, p.y + 50, 8) -- 1567
	self:shake(0.2, 3) -- 1568
end -- 1560
function Game.prototype.checkpointOfFloor(self, floor) -- 1571
	do -- 1571
		local i = 0 -- 1572
		while i < #Tower.checkpoints do -- 1572
			local c = Tower.checkpoints[i + 1] -- 1573
			if c.floor == floor then -- 1573
				return {id = c.id, x = c.x, y = c.y, floor = c.floor} -- 1575
			end -- 1575
			i = i + 1 -- 1572
		end -- 1572
	end -- 1572
	return nil -- 1578
end -- 1571
function Game.prototype.advanceTeleport(self, dt) -- 1581
	self.teleportT = self.teleportT + dt -- 1582
	local t = self.pendingPortalTarget -- 1583
	if t ~= nil and self.teleportT >= 0.45 then -- 1583
		self.pendingPortalTarget = nil -- 1585
		self.state.currentCheckpointId = t.cpId -- 1586
		self.state.checkpointsActivated[t.cpId] = true -- 1587
		restoreFloorCap(self.state) -- 1589
		self:settleFloorSneak(t.floor) -- 1590
		self:respawnAt(t.cpId) -- 1591
		self:growFloor(t.floor) -- 1592
		self.camY = t.y + 160 -- 1593
		self.fx:spawnRing( -- 1594
			t.x, -- 1594
			t.y + 60, -- 1594
			GOLD, -- 1594
			16, -- 1594
			170, -- 1594
			0.7 -- 1594
		) -- 1594
	end -- 1594
	if self.teleportT >= 0.9 then -- 1594
		self.teleportT = -1 -- 1597
	end -- 1597
end -- 1581
function Game.prototype.teleportFade(self) -- 1601
	if self.teleportT < 0 then -- 1601
		return 0 -- 1603
	end -- 1603
	if self.teleportT < 0.45 then -- 1603
		return self.teleportT / 0.45 -- 1606
	end -- 1606
	return math.max(0, 1 - (self.teleportT - 0.45) / 0.45) -- 1608
end -- 1601
function Game.prototype.syncFloorScene(self) -- 1611
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1612
	self.renderer:setFloorScene(cp and cp.floor or 0) -- 1613
end -- 1611
function Game.prototype.activeLadders(self) -- 1617
	if self.state.flags.treePlanted == true and self.state.flags.treeCut ~= true then -- 1617
		return TREE_LADDER -- 1619
	end -- 1619
	return Tower.ladders -- 1621
end -- 1617
function Game.prototype.logCause(self, text) -- 1625
	if __TS__ArrayIndexOf(self.state.causalityLog, text) >= 0 then -- 1625
		return -- 1627
	end -- 1627
	local ____self_state_causalityLog_15 = self.state.causalityLog -- 1627
	____self_state_causalityLog_15[#____self_state_causalityLog_15 + 1] = text -- 1629
	if #self.state.causalityLog > 12 then -- 1629
		__TS__ArraySplice(self.state.causalityLog, 0, #self.state.causalityLog - 12) -- 1631
	end -- 1631
end -- 1625
function Game.prototype.floorOfCheckpoint(self) -- 1635
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1636
	return cp and cp.floor or 0 -- 1637
end -- 1635
function Game.prototype.throwPebble(self) -- 1641
	if self.state.pebbles <= 0 then -- 1641
		return -- 1643
	end -- 1643
	local ____self_state_16, ____pebbles_17 = self.state, "pebbles" -- 1643
	____self_state_16[____pebbles_17] = ____self_state_16[____pebbles_17] - 1 -- 1645
	local px = self.player.body.x -- 1646
	local py = self.player.body.y -- 1647
	local landX = px + self.player.facing * 260 -- 1648
	self.stealth:emitNoise( -- 1649
		landX, -- 1649
		self:floorOfCheckpoint(), -- 1649
		320 -- 1649
	) -- 1649
	self.fx:spawnDust(landX, py, self.player.facing) -- 1650
	sfx("dash", 0.4) -- 1651
	self.state.objective = "石子落地——附近的守卫被吸引了过去" -- 1652
end -- 1641
function Game.prototype.tryTreePuzzle(self, px, py) -- 1656
	if self.state.flags.treeCut == true then -- 1656
		return false -- 1658
	end -- 1658
	if self:floorOfCheckpoint() ~= 0 or math.abs(py - (Tower.TOPS[1] + 42)) > 90 then -- 1658
		return false -- 1661
	end -- 1661
	local planted = self.state.flags.treePlanted == true -- 1663
	if not planted and self.state.flags.saplingTaken ~= true and math.abs(px - 700) < 90 then -- 1663
		self.state.flags.saplingTaken = true -- 1665
		self:logCause("渡口移苗·根带旧土") -- 1666
		sfx("click", 0.9) -- 1667
		self.fx:spawnStars(px, py + 40, 6) -- 1668
		self.state.objective = "树苗在手——东边枯坑（x≈1200）在等它；路过水井（x≈860）可先打一桶水" -- 1669
		return true -- 1670
	end -- 1670
	if self.state.flags.bucketFull ~= true and math.abs(px - 860) < 90 then -- 1670
		self.state.flags.bucketFull = true -- 1673
		self:logCause("井水打满·一桶月色") -- 1674
		self.causFx:play("fill", "一桶井水") -- 1675
		self.state.objective = "水已打好——去移树苗（x≈700），再种进枯坑（x≈1200）" -- 1676
		return true -- 1677
	end -- 1677
	if not planted and math.abs(px - 1200) < 100 then -- 1677
		if self.state.flags.saplingTaken == true then -- 1677
			self.state.flags.treePlanted = true -- 1681
			self.state.flags.saplingTaken = false -- 1682
			if self.state.flags.bucketFull == true then -- 1682
				self.state.flags.bucketFull = false -- 1685
			end -- 1685
			self.mech:openGate("gate_ferry") -- 1687
			if self.tree ~= nil then -- 1687
				self.tree:addChoice("种下树苗") -- 1689
			end -- 1689
			self:logCause("枯坑种树·因果成立") -- 1691
			self.causFx:play("grow", "种下·对岸月影同时落地") -- 1692
			self.fx:spawnRing( -- 1693
				px, -- 1693
				py + 30, -- 1693
				CYAN, -- 1693
				14, -- 1693
				130, -- 1693
				0.8 -- 1693
			) -- 1693
			sfx("click", 1) -- 1694
			self.state.objective = "树影成双——月华凝成新的月石（攀树梯而上，x≈1180 按 W）；渡口尽头的传送门亮起了" -- 1695
			return true -- 1696
		end -- 1696
		self.state.objective = "枯坑沉默着……像在等一株树苗（西边有井，也有苗）" -- 1698
		return true -- 1699
	end -- 1699
	if planted and self.state.flags.bucketFull == true and math.abs(px - 1200) < 100 then -- 1699
		self.state.flags.bucketFull = false -- 1703
		self:logCause("月色浇灌·新苗抽枝") -- 1704
		self.causFx:play("grow", "浇灌·月华入土") -- 1705
		self.fx:spawnRing( -- 1706
			px, -- 1706
			py + 30, -- 1706
			CYAN, -- 1706
			12, -- 1706
			120, -- 1706
			0.7 -- 1706
		) -- 1706
		sfx("click", 1) -- 1707
		self.state.objective = "浇透了——小树轻轻颤了颤；井（x≈860）随时可再打一桶" -- 1708
		return true -- 1709
	end -- 1709
	return false -- 1711
end -- 1656
function Game.prototype.cutTree(self) -- 1715
	self.state.flags.treeCut = true -- 1716
	if self.tree ~= nil then -- 1716
		self.tree:addChoice("砍倒小树") -- 1718
	end -- 1718
	self:logCause("刀落砍树·两树同枯") -- 1720
	self.causFx:play("cut", "砍伐·因果反噬") -- 1721
	self:shake(0.35, 7) -- 1722
	sfx("enemyHurt", 0.8) -- 1723
	self.state.objective = "树桩无言——砍倒它，树冠上的月华也随之湮灭" -- 1724
end -- 1715
function Game.prototype.tryPebblePickup(self, px, py) -- 1728
	if self:floorOfCheckpoint() ~= 1 or self.state.pebbles > 0 then -- 1728
		return false -- 1730
	end -- 1730
	if math.abs(px - 1450) < 80 and math.abs(py - (Tower.TOPS[2] + 42)) < 90 then -- 1730
		self.state.pebbles = 3 -- 1733
		self:logCause("拾起石子·三枚") -- 1734
		sfx("click", 0.9) -- 1735
		self.state.objective = "拾起 3 枚石子——Q 丢向前方，引开守卫视线" -- 1736
		return true -- 1737
	end -- 1737
	return false -- 1739
end -- 1728
function Game.prototype.tryBarrel(self, px, py) -- 1743
	if self:floorOfCheckpoint() ~= 1 or self.state.flags.barrelDown == true then -- 1743
		return false -- 1745
	end -- 1745
	if math.abs(px - 1900) < 90 and math.abs(py - (Tower.TOPS[2] + 42)) < 90 then -- 1745
		local left = self.player.facing < 0 -- 1748
		self.state.flags.barrelDown = true -- 1749
		self.state.flags.barrelLeft = left -- 1750
		local fallX = left and 1760 or 2040 -- 1751
		self.enemies:stunNear(fallX, 1, 180, 3.5) -- 1752
		self.stealth:emitNoise(fallX, 1, 340) -- 1753
		self:shake(0.35, 8) -- 1754
		sfx("enemyHurt", 0.8) -- 1755
		self:logCause("酒桶砸落·震慑一时") -- 1756
		self.state.objective = "酒桶轰然砸落——附近守卫被震晕了（趁现在！）" -- 1757
		return true -- 1758
	end -- 1758
	return false -- 1760
end -- 1743
function Game.prototype.tryWaiter(self, px, py) -- 1764
	if self:floorOfCheckpoint() ~= 1 or self.state.flags.waiterFreed == true then -- 1764
		return false -- 1766
	end -- 1766
	if math.abs(px - 1985) < 80 and math.abs(py - (Tower.TOPS[2] + 42)) < 90 then -- 1766
		self.state.flags.waiterFreed = true -- 1769
		addTrust(self.state, 1) -- 1770
		if self.tree ~= nil then -- 1770
			self.tree:addChoice("救出店小二") -- 1772
		end -- 1772
		self:logCause("割绳救人·剑意上限+1") -- 1774
		local ____self_state_18, ____maxSwordIntent_19 = self.state, "maxSwordIntent" -- 1774
		____self_state_18[____maxSwordIntent_19] = ____self_state_18[____maxSwordIntent_19] + 1 -- 1775
		self.state.swordIntent = self.state.maxSwordIntent -- 1776
		self.causFx:play("rescue", "救人·剑意上限 +1") -- 1777
		sfx("click", 1) -- 1778
		self.state.objective = "店小二低声道：别走大道……酒桶后面能蹲人。" -- 1779
		return true -- 1780
	end -- 1780
	return false -- 1782
end -- 1764
function Game.prototype.settleFloorSneak(self, arrivedFloor) -- 1786
	if arrivedFloor ~= 2 or self.state.flags.floor1Settled == true then -- 1786
		return -- 1788
	end -- 1788
	self.state.flags.floor1Settled = true -- 1790
	if not self.floor1Kill and not self.floor1Alert then -- 1790
		self.state.sneakBonus = true -- 1792
		local ____self_state_20, ____maxSwordIntent_21 = self.state, "maxSwordIntent" -- 1792
		____self_state_20[____maxSwordIntent_21] = ____self_state_20[____maxSwordIntent_21] + 1 -- 1793
		self.state.swordIntent = self.state.maxSwordIntent -- 1794
		if self.tree ~= nil then -- 1794
			self.tree:addChoice("古镇不杀") -- 1796
		end -- 1796
		self:logCause("古镇不杀·剑意上限+1") -- 1798
		self.fx:spawnRing( -- 1799
			self.player.body.x, -- 1799
			self.player.body.y + 40, -- 1799
			GOLD, -- 1799
			12, -- 1799
			110, -- 1799
			0.8 -- 1799
		) -- 1799
		self.state.objective = "潜行奖励：全程不杀而穿过古镇——剑意上限 +1" -- 1800
	elseif self.floor1Kill then -- 1800
		if self.tree ~= nil then -- 1800
			self.tree:addChoice("杀出古镇") -- 1803
		end -- 1803
		self:logCause("杀出古镇·血染街巷") -- 1805
	else -- 1805
		self:logCause("古镇遇警·惊动街巷") -- 1807
	end -- 1807
	self.floor1Kill = false -- 1809
	self.floor1Alert = false -- 1810
end -- 1786
function Game.prototype.drawFloor1Npcs(self, d, p) -- 1814
	local cp = self:findCheckpoint(self.state.currentCheckpointId) -- 1815
	local floor = cp and cp.floor or 0 -- 1816
	local wy = Tower.TOPS[2] -- 1817
	if math.abs(p.x - 1985) < 1100 and math.abs(p.y - (wy + 60)) < 700 then -- 1817
		local freed = self.state.flags.waiterFreed == true -- 1819
		d:drawPolygon( -- 1820
			{ -- 1820
				Vec2(1975, wy), -- 1820
				Vec2(1995, wy), -- 1820
				Vec2(1993, wy - 44), -- 1820
				Vec2(1977, wy - 44) -- 1820
			}, -- 1820
			Color(74, 62, 56, 255) -- 1820
		) -- 1820
		d:drawDot( -- 1821
			Vec2(1985, wy - 54), -- 1821
			9, -- 1821
			Color(216, 192, 162, 255) -- 1821
		) -- 1821
		if freed then -- 1821
			d:drawSegment( -- 1823
				Vec2(1995, wy - 40), -- 1823
				Vec2(2007, wy - 60), -- 1823
				3, -- 1823
				Color(216, 192, 162, 255) -- 1823
			) -- 1823
		else -- 1823
			d:drawSegment( -- 1825
				Vec2(1971, wy - 30), -- 1825
				Vec2(1999, wy - 30), -- 1825
				3, -- 1825
				Color(126, 94, 60, 255) -- 1825
			) -- 1825
		end -- 1825
	end -- 1825
	if self.state.pebbles == 0 and floor == 1 and math.abs(p.x - 1450) < 900 and math.abs(p.y - (wy + 60)) < 500 then -- 1825
		d:drawPolygon( -- 1829
			{ -- 1829
				Vec2(1430, wy), -- 1829
				Vec2(1472, wy), -- 1829
				Vec2(1462, wy - 16), -- 1829
				Vec2(1440, wy - 16) -- 1829
			}, -- 1829
			Color(120, 118, 112, 255) -- 1829
		) -- 1829
		d:drawDot( -- 1830
			Vec2(1450, wy - 22), -- 1830
			6, -- 1830
			Color(150, 148, 140, 255) -- 1830
		) -- 1830
	end -- 1830
end -- 1814
function Game.prototype.loopAdvance(self) -- 1834
	local ____self_state_22, ____loopIndex_23 = self.state, "loopIndex" -- 1834
	____self_state_22[____loopIndex_23] = ____self_state_22[____loopIndex_23] + 1 -- 1835
	self.state.shenyanTrust = 0 -- 1836
	__TS__ArraySetLength(self.state.memories, 0) -- 1836
	self:growNight() -- 1839
	self.treeFloorSeen = {} -- 1840
	self.treeDeathSeen = false -- 1841
	self:applyLoopVariants() -- 1842
	self.enemies:spawnAll(Tower.enemies, self.state.loopIndex) -- 1843
	self.stealth:resetRuntime() -- 1844
	self.state.currentCheckpointId = "cp_riverbank" -- 1845
	self:respawnAt(self.state.currentCheckpointId) -- 1846
	self.mode = "rewind" -- 1847
	self.rewindT = 0 -- 1848
end -- 1834
function Game.prototype.applyLoopVariants(self) -- 1851
	self.state.cutRopes = {} -- 1852
	self.state.rungBells = {} -- 1853
	self.state.platesActive = {} -- 1854
	self.state.lanternsLit = {} -- 1855
	self.state.lanternSequence = 0 -- 1856
	self.state.lanternFailed = false -- 1857
	self.state.openedGates = {} -- 1858
	self.state.swordIntent = self.state.maxSwordIntent -- 1859
	self.state.flags.confront = false -- 1860
	self.state.flags.bladeClash = false -- 1861
	self.state.flags.putDownSword = false -- 1862
	self.state.flags.floor1Settled = false -- 1863
	self.state.flags.treePlanted = false -- 1866
	self.state.flags.saplingTaken = false -- 1867
	self.state.flags.treeCut = false -- 1868
	self.state.flags.bucketFull = false -- 1869
	self.mech:syncStones(Tower.pushStones) -- 1870
end -- 1851
function Game.prototype.endGame(self, id) -- 1873
	self.endingId = id -- 1874
	self.hud:setRewind(-1) -- 1875
	self.mode = "ending" -- 1876
	self.hud:showEnding(id) -- 1877
	self:archiveRun(id) -- 1878
	playBgm("calm", 2) -- 1879
end -- 1873
function Game.prototype.archiveRun(self, endingId) -- 1883
	if self.treeArchived then -- 1883
		return -- 1885
	end -- 1885
	self.treeArchived = true -- 1887
	local e = ENDINGS[endingId] -- 1888
	local name = self.playerName ~= "" and self.playerName or (loadPlayerName() ~= "" and loadPlayerName() or DEFAULT_NAME) -- 1889
	local entry = { -- 1890
		name = name, -- 1891
		endingTitle = e ~= nil and e.title or endingId, -- 1892
		rewindCount = self.tree ~= nil and self.tree.rewindCount or 0, -- 1893
		currentId = self.tree ~= nil and self.tree.currentId or "", -- 1894
		nodes = self.tree ~= nil and self.tree.nodes or ({}) -- 1895
	} -- 1895
	appendArchive(entry) -- 1897
end -- 1883
function Game.prototype.toTitle(self) -- 1900
	self.hud:hideEnding() -- 1901
	self.paused = false -- 1902
	self.hud:setPauseVisible(false) -- 1903
	self:resetRun() -- 1904
	self.sheetFx:clear() -- 1905
	self.renderer:setPrompt(0, 0, nil) -- 1906
	playBgm("cover", 1) -- 1907
	self.mode = "title" -- 1908
	self.hud:setTitleVisible(true) -- 1909
end -- 1900
function Game.prototype.hintText(self) -- 1912
	if self.mode == "confront" then -- 1912
		return "走近沈砚：E 放下剑 · Q 以命换命 · J 剑锋相向 · Tab 手札" -- 1914
	end -- 1914
	if self.mode == "play" and (self:nearPortal(self.player.body.x, self.player.body.y) ~= nil or self.nearStoryId ~= nil) then -- 1914
		return "" -- 1918
	end -- 1918
	if self.player.onLadder then -- 1918
		return "W/S 攀爬 · 到顶后按 Space 跳向右侧平台" -- 1921
	end -- 1921
	return "" -- 1923
end -- 1912
function Game.prototype.makeNpcSprite(self, paths, parent, tag) -- 1927
	local tex -- 1928
	local used = "" -- 1929
	for ____, p in ipairs(paths) do -- 1930
		tex = Texture2D(p) -- 1931
		if tex ~= nil then -- 1931
			used = p -- 1933
			break -- 1934
		end -- 1934
	end -- 1934
	if tex == nil or used == "" then -- 1934
		print((("[" .. tag) .. "] texture load failed: ") .. table.concat(paths, " | ")) -- 1938
		return nil -- 1939
	end -- 1939
	print(((((((("[" .. tag) .. "] loaded ") .. used) .. " (") .. tostring(tex.width)) .. "x") .. tostring(tex.height)) .. ")") -- 1941
	local sp = Sprite(tex) -- 1942
	if sp == nil then -- 1942
		return nil -- 1944
	end -- 1944
	local s = 90 / tex.height -- 1946
	sp.scaleX = s -- 1947
	sp.scaleY = s -- 1948
	sp.anchor = Vec2(0.5, 0) -- 1949
	sp.visible = false -- 1950
	sp:addTo(parent) -- 1951
	return sp -- 1952
end -- 1927
function Game.prototype.drawNpcs(self) -- 1955
	local p = self.player.body -- 1956
	local d = self.npcDraw -- 1957
	self:drawFloor1Npcs(d, p) -- 1958
	self.shenRenderOk = false -- 1959
	self.obsNode.position = self.npcDraw.position -- 1960
	local obsY = Tower.TOPS[4] -- 1962
	local obsNear = math.abs(p.x - 800) < 1300 and math.abs(p.y - obsY) < 900 -- 1963
	if self.obsSp ~= nil then -- 1963
		self.obsSp.visible = obsNear -- 1966
		if obsNear then -- 1966
			self.obsSp.position = Vec2(800, obsY) -- 1968
			self.obsSp.scaleX = math.abs(self.obsSp.scaleX) * (p.x > 800 and 1 or -1) -- 1969
		end -- 1969
	elseif obsNear then -- 1969
		drawObserver(d, 800, obsY, self.time) -- 1972
	end -- 1972
	local sx -- 1976
	local sy -- 1977
	local hideShen = false -- 1978
	if self.state.flags.confront then -- 1978
		sx = 2200 -- 1980
		sy = self:shenY() -- 1981
	else -- 1981
		local xs = { -- 1984
			560, -- 1984
			500, -- 1984
			650, -- 1984
			480, -- 1984
			1900, -- 1984
			460 -- 1984
		} -- 1984
		local tops = Tower.TOPS -- 1985
		local target = math.min( -- 1986
			self:shenProgress(), -- 1986
			#xs - 1 -- 1986
		) -- 1986
		if target < self.shenShownIdx then -- 1986
			self.shenShownIdx = target -- 1988
		elseif target > self.shenShownIdx then -- 1988
			local nx = xs[target + 1] -- 1990
			local ny = tops[math.min(target, #tops - 2) + 1] -- 1991
			if math.min(target, #tops - 2) == 3 or math.abs(p.x - nx) < 1200 and math.abs(p.y - ny) < 900 then -- 1991
				self.shenShownIdx = target -- 1994
			end -- 1994
		end -- 1994
		local idx = math.min(self.shenShownIdx, target) -- 1997
		sx = xs[idx + 1] -- 1998
		sy = tops[math.min(idx, #tops - 2) + 1] -- 1999
		hideShen = math.min(idx, #tops - 2) == 3 or math.min(idx, #tops - 2) == 5 -- 2001
	end -- 2001
	if self.mode ~= "ending" and not hideShen and math.abs(p.x - sx) < 1400 then -- 2001
		self.shenRenderX = sx -- 2004
		self.shenRenderY = sy -- 2005
		self.shenRenderOk = true -- 2006
		local dark = self.state.flags.confront and self.shenSpDark ~= nil and self.shenSpDark or self.shenSpNormal -- 2007
		if self.shenSpNormal ~= nil then -- 2007
			self.shenSpNormal.visible = dark == self.shenSpNormal -- 2009
		end -- 2009
		if self.shenSpDark ~= nil then -- 2009
			self.shenSpDark.visible = dark == self.shenSpDark -- 2012
		end -- 2012
		if dark ~= nil then -- 2012
			self.shenNode.position = self.npcDraw.position -- 2016
			dark.position = Vec2(sx, sy) -- 2017
			dark.scaleX = math.abs(dark.scaleX) * (p.x > sx and 1 or -1) -- 2018
		else -- 2018
			drawShenYan( -- 2020
				d, -- 2020
				sx, -- 2020
				sy, -- 2020
				p.x > sx and -1 or 1, -- 2020
				self.time, -- 2020
				self.state.flags.confront -- 2020
			) -- 2020
		end -- 2020
	else -- 2020
		if self.shenSpNormal ~= nil then -- 2020
			self.shenSpNormal.visible = false -- 2024
		end -- 2024
		if self.shenSpDark ~= nil then -- 2024
			self.shenSpDark.visible = false -- 2027
		end -- 2027
	end -- 2027
	local blueTexReady = self.slashFx:hasBlueTex() -- 2030
	local shots = {} -- 2031
	do -- 2031
		local i = 0 -- 2032
		while i < #self.qiShots do -- 2032
			do -- 2032
				local q = self.qiShots[i + 1] -- 2033
				if not q.alive then -- 2033
					goto __continue410 -- 2035
				end -- 2035
				local wob = math.sin(self.time * 22 + q.phase) * 4 -- 2037
				if blueTexReady then -- 2037
					shots[#shots + 1] = {x = q.x, y = q.y + wob, dir = q.dir} -- 2040
					goto __continue410 -- 2041
				end -- 2041
				local function buildCres(scale, ox) -- 2043
					local pts = {} -- 2044
					local R = 46 * scale -- 2045
					local aOut = 1.45 -- 2046
					do -- 2046
						local k = 0 -- 2047
						while k <= 10 do -- 2047
							local t = aOut - 2 * aOut * k / 10 -- 2048
							pts[#pts + 1] = Vec2( -- 2049
								q.x + q.dir * (ox + R * math.cos(t)), -- 2049
								q.y + wob + R * math.sin(t) -- 2049
							) -- 2049
							k = k + 1 -- 2047
						end -- 2047
					end -- 2047
					local c2 = -0.6 * R -- 2051
					local ri = 1.2266 * R -- 2052
					local aIn = 0.9425 -- 2053
					do -- 2053
						local k = 0 -- 2054
						while k <= 10 do -- 2054
							local t = -aIn + 2 * aIn * k / 10 -- 2055
							pts[#pts + 1] = Vec2( -- 2056
								q.x + q.dir * (ox + c2 + ri * math.cos(t)), -- 2056
								q.y + wob + ri * math.sin(t) -- 2056
							) -- 2056
							k = k + 1 -- 2054
						end -- 2054
					end -- 2054
					return pts -- 2058
				end -- 2043
				d:drawPolygon( -- 2060
					buildCres(0.72, -38), -- 2060
					Color(CYAN.r, CYAN.g, CYAN.b, 42) -- 2060
				) -- 2060
				d:drawPolygon( -- 2061
					buildCres(0.86, -18), -- 2061
					Color(CYAN.r, CYAN.g, CYAN.b, 82) -- 2061
				) -- 2061
				d:drawPolygon( -- 2062
					buildCres(1, 0), -- 2062
					Color(CYAN.r, CYAN.g, CYAN.b, 150) -- 2062
				) -- 2062
				d:drawPolygon( -- 2063
					buildCres(0.6, 7), -- 2063
					Color(255, 255, 255, 215) -- 2063
				) -- 2063
			end -- 2063
			::__continue410:: -- 2063
			i = i + 1 -- 2032
		end -- 2032
	end -- 2032
	if blueTexReady then -- 2032
		self.slashFx:syncShots(shots) -- 2066
	end -- 2066
end -- 1955
function Game.prototype.updateVisuals(self, dt, shakeX, shakeY) -- 2070
	local view = View.size -- 2071
	local active = self.mode == "play" or self.mode == "confront" or self.mode == "dialog" or self.mode == "rewind" or self.mode == "dead" or self.mode == "ending" -- 2072
	if active then -- 2072
		local tx = clamp(self.player.body.x, view.width / 2, Tower.WORLD_W - view.width / 2) -- 2074
		local ty = clamp(self.player.body.y + 70, Tower.TOPS[1] + view.height / 2 - 56, Tower.WORLD_H - view.height / 2) -- 2076
		local k = math.min(1, dt * 6) -- 2077
		self.camX = tx -- 2079
		self.camY = self.camY + (ty - self.camY) * k -- 2080
	else -- 2080
		self.camX = 800 -- 2082
		self.camY = 400 -- 2083
	end -- 2083
	self.fxDraw.position = Vec2(-self.camX + shakeX, -self.camY + shakeY) -- 2086
	self.npcDraw.position = self.fxDraw.position -- 2087
	self.sheetNode.position = self.fxDraw.position -- 2088
	self.fx:update(dt) -- 2089
	self.sheetFx:update(dt) -- 2090
	self.boomFx:update(dt) -- 2091
	self.slashFx:update(dt) -- 2092
	self.fxDraw:clear() -- 2093
	self.fx:draw(self.fxDraw) -- 2094
	self.npcDraw:clear() -- 2095
	if self.mode ~= "title" and self.mode ~= "prologue" then -- 2095
		self:drawNpcs() -- 2097
	end -- 2097
	self.renderer:setWorldVisible(self.mode ~= "title" and self.mode ~= "prologue") -- 2099
	self.renderer:setCamera(self.camX, self.camY, shakeX, shakeY) -- 2100
	self.renderer:syncTreePuzzle(self.state.flags) -- 2102
	self.renderer:syncBarrel(dt, self.state.flags.barrelDown == true, self.state.flags.barrelLeft == true) -- 2103
	self.renderer:update( -- 2104
		dt, -- 2104
		self.state, -- 2104
		self.player, -- 2104
		self.enemies, -- 2104
		self.mech, -- 2104
		self.time -- 2104
	) -- 2104
	self:syncInteractPrompt() -- 2105
	local cpNow = self:findCheckpoint(self.state.currentCheckpointId) -- 2106
	local floorNow = math.max( -- 2107
		0, -- 2107
		math.min(cpNow and cpNow.floor or 0, #Tower.FLOORS - 1) -- 2107
	) -- 2107
	local ____self_28 = self.hud -- 2107
	local ____self_28_update_29 = ____self_28.update -- 2107
	local ____dt_27 = dt -- 2108
	local ____self_state_25 = self.state -- 2109
	local ____self_player_26 = self.player -- 2110
	local ____table_nearBoss_result_24 -- 2111
	if self:nearBoss() then -- 2111
		____table_nearBoss_result_24 = self.enemies:boss() -- 2111
	else -- 2111
		____table_nearBoss_result_24 = nil -- 2111
	end -- 2111
	____self_28_update_29( -- 2111
		____self_28, -- 2111
		____dt_27, -- 2108
		{ -- 2108
			state = ____self_state_25, -- 2109
			player = ____self_player_26, -- 2110
			boss = ____table_nearBoss_result_24, -- 2111
			objective = self.state.objective, -- 2112
			mission = Tower.FLOOR_MISSIONS[math.min(floorNow, #Tower.FLOOR_MISSIONS - 1) + 1], -- 2113
			floorName = Tower.FLOORS[floorNow + 1], -- 2114
			guideLight = floorNow == 6 or floorNow == 4, -- 2115
			hint = self:hintText(), -- 2116
			time = self.time, -- 2117
			fade = self:teleportFade() -- 2118
		} -- 2118
	) -- 2118
	self.notebook:update(dt, self.state) -- 2120
end -- 2070
return ____exports -- 2070