-- [ts]: hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Audio = ____Dora.Audio -- 2
local Color = ____Dora.Color -- 2
local Content = ____Dora.Content -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Size = ____Dora.Size -- 2
local Sprite = ____Dora.Sprite -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Vec2 = ____Dora.Vec2 -- 2
local VideoNode = ____Dora.VideoNode -- 2
local View = ____Dora.View -- 2
local ____palette = require("core.palette") -- 3
local Palette = ____palette.Palette -- 3
local ink = ____palette.ink -- 3
local ____story = require("data.story") -- 5
local ENDINGS = ____story.ENDINGS -- 5
local PHASE_NAMES = ____story.PHASE_NAMES -- 5
local ____ending_images = require("data.ending_images") -- 6
local ENDING_IMAGES = ____ending_images.ENDING_IMAGES -- 6
local ____tech_ui = require("ui.tech_ui") -- 9
local makeTechPanel = ____tech_ui.makeTechPanel -- 9
local TECH_BTN_PATH = ____tech_ui.TECH_BTN_PATH -- 9
local ____audio = require("game.audio") -- 10
local playBgm = ____audio.playBgm -- 10
local stopBgm = ____audio.stopBgm -- 10
local FONT = "sarasa-mono-sc-regular" -- 12
local TITLE_FONTS = {"assets/font/NameFont.ttf", "assets/font/DialogFont.ttf"} -- 14
local PANEL_FONT = "assets/font/DialogFont.ttf" -- 15
local NO_FILL = ink(0, 0, 0, 0) -- 16
local HEART_TEX = "assets/ui/icon_heart.png" -- 17
local HEART_SCALE = 3 -- 18
local HEART_STEP = 52 -- 19
local BAR_W = 192 -- 20
local BAR_H = 36 -- 21
local BAR_PAD = 3 -- 22
local HUD_MAX_HEARTS = 8 -- 23
local WHEEL_TEX_NORMAL = "assets/ui/moon_wheel_normal.png" -- 25
local WHEEL_TEX_ACTIVE = "assets/ui/moon_wheel_active.png" -- 26
local WHEEL_TEX_DIM = "assets/ui/moon_wheel_dim.png" -- 27
local WHEEL_PX = 46 -- 28
local MENU_W = 320 -- 30
local MENU_H = 60 -- 31
local MENU_HALF_X = MENU_W / 2 + 28 -- 32
local MENU_HALF_Y = MENU_H / 2 + 16 -- 33
local MENU_X_OFF = 240 -- 35
local MENU_YS = {216, 140, 64} -- 36
local MENU_FLASH_T = 0.28 -- 37
local PANEL_W = 560 -- 38
local PANEL_H = 470 -- 39
local TITLE_PARTICLE_N = 3 -- 40
local FLASH_TIME = 0.45 -- 41
local COVER_VIDEO_PIN = "assets/art/cover_anim.ogv" -- 43
local PROLOGUE_VIDEO_FILE = "assets/art/prologue_720.ogv" -- 47
local PROLOGUE_EXCLUDED_NAME = "游戏前情提要.ogv" -- 48
local PROLOGUE_START_TIMEOUT = 8 -- 49
local PROLOGUE_AUDIO_LEAD = 0 -- 50
local PROLOGUE_AUDIO_TAIL = 5.2 -- 51
local PROLOGUE_AUDIO_FILES = {"assets/audio/bgm-prologue.mp3", "assets/audio/bgm-prologue.ogg"} -- 53
local SETTINGS_KEYS = { -- 55
	"A / D　移动", -- 56
	"W / S　爬梯", -- 56
	"Space　跳跃", -- 56
	"J　攻击", -- 56
	"K　剑气", -- 56
	"LShift　冲刺", -- 57
	"E　交互", -- 57
	"R　月相轮回", -- 57
	"Tab　笔记", -- 57
	"Esc　暂停" -- 57
} -- 57
local PAUSE_KEYS = { -- 60
	"A / D　移动", -- 61
	"Space　跳跃 / 二段跳", -- 61
	"J　攻击", -- 61
	"K　剑气", -- 61
	"Shift　闪身", -- 61
	"W / S　攀爬", -- 61
	"E　交互", -- 62
	"R　月相轮回", -- 62
	"N　引月札", -- 62
	"Tab　手札", -- 62
	"Esc　暂停" -- 62
} -- 62
local function loadTex(path) -- 87
	return Texture2D(path) -- 88
end -- 87
local function pxSprite(tex) -- 91
	local sp = Sprite(tex) -- 92
	sp.filter = "Point" -- 93
	return sp -- 94
end -- 91
local function col(c) -- 97
	return Color(c.r, c.g, c.b, c.a) -- 97
end -- 97
local function makeLabel(parent, size, x, y, ax, ay, color) -- 99
	local lb = Label(FONT, size) -- 100
	if lb == nil then -- 100
		return nil -- 102
	end -- 102
	lb.anchor = Vec2(ax, ay) -- 104
	lb.position = Vec2(x, y) -- 105
	lb.color = Color(color.r, color.g, color.b, color.a) -- 106
	lb:addTo(parent) -- 107
	return lb -- 108
end -- 99
local function setText(lb, text) -- 111
	if lb ~= nil and lb.text ~= text then -- 111
		lb.text = text -- 113
	end -- 113
end -- 111
local function makePixelLabel(parent, size, x, y, ax, ay, color) -- 118
	do -- 118
		local i = 0 -- 119
		while i < #TITLE_FONTS do -- 119
			local lb = Label(TITLE_FONTS[i + 1], size) -- 120
			if lb ~= nil then -- 120
				lb.anchor = Vec2(ax, ay) -- 122
				lb.position = Vec2(x, y) -- 123
				lb.color = Color(color.r, color.g, color.b, color.a) -- 124
				lb:addTo(parent) -- 125
				return lb -- 126
			end -- 126
			i = i + 1 -- 119
		end -- 119
	end -- 119
	return makeLabel( -- 129
		parent, -- 129
		size, -- 129
		x, -- 129
		y, -- 129
		ax, -- 129
		ay, -- 129
		color -- 129
	) -- 129
end -- 118
local function wrapCjk(text, maxChars) -- 134
	local breaks = { -- 135
		"，", -- 135
		"；", -- 135
		"。", -- 135
		"！", -- 135
		"？", -- 135
		"：", -- 135
		"）" -- 135
	} -- 135
	local glyphs = {} -- 136
	local i = 0 -- 137
	while i < #text do -- 137
		local b = __TS__StringCharCodeAt(text, i) -- 139
		local seq = b >= 240 and 4 or (b >= 224 and 3 or (b >= 192 and 2 or 1)) -- 140
		glyphs[#glyphs + 1] = __TS__StringSubstring(text, i, i + seq) -- 141
		i = i + seq -- 142
	end -- 142
	local lines = {} -- 144
	local start = 0 -- 145
	while start < #glyphs do -- 145
		local ____end = math.min(start + maxChars, #glyphs) -- 147
		if ____end < #glyphs then -- 147
			do -- 147
				local k = ____end - 1 -- 150
				while k >= ____end - 4 and k > start do -- 150
					if __TS__ArrayIndexOf(breaks, glyphs[k + 1]) >= 0 then -- 150
						____end = k + 1 -- 152
						break -- 153
					end -- 153
					k = k - 1 -- 150
				end -- 150
			end -- 150
		end -- 150
		local line = "" -- 157
		do -- 157
			local k = start -- 158
			while k < ____end do -- 158
				line = line .. glyphs[k + 1] -- 159
				k = k + 1 -- 158
			end -- 158
		end -- 158
		lines[#lines + 1] = line -- 161
		start = ____end -- 162
	end -- 162
	if #lines == 0 then -- 162
		lines[#lines + 1] = "" -- 165
	end -- 165
	return table.concat(lines, "\n") -- 167
end -- 134
____exports.HUD = __TS__Class() -- 170
local HUD = ____exports.HUD -- 170
HUD.name = "HUD" -- 170
function HUD.prototype.____constructor(self, parent) -- 251
	self.titleMenuEnabled = false -- 199
	self.endingLineLbs = {} -- 252
	self.endingTexId = "" -- 253
	self.flashTimer = 0 -- 254
	self.rewindV = -1 -- 255
	self.coverBaseScale = 1 -- 256
	self.coverSp = nil -- 257
	self.titleNameLb = nil -- 258
	self.menuDraws = {} -- 259
	self.menuLbs = {} -- 260
	self.menuBtns = {} -- 261
	self.menuBtnOk = {} -- 262
	self.prologueCoverFailed = false -- 263
	self.menuBtnW = 1 -- 264
	self.menuBtnH = 1 -- 265
	self.menuSel = 0 -- 266
	self.menuFlashT = 0 -- 267
	self.playLock = false -- 268
	self.settingsOpen = false -- 269
	self.particles = {} -- 270
	self.wheelNormalSp = nil -- 271
	self.wheelActiveSp = nil -- 272
	self.wheelDimSp = nil -- 273
	self.wheelMode = "normal" -- 274
	self.prologueVideo = nil -- 275
	self.prologueHintLb = nil -- 276
	self.prologuePlaying = false -- 277
	self.prologueStarted = false -- 278
	self.prologueWaitT = 0 -- 279
	self.prologueLeadT = 0 -- 280
	self.prologueAudioStarted = false -- 281
	self.prologueTailT = 0 -- 282
	self.prologueAudio = "" -- 283
	self.guideWhite = false -- 284
	self.prologueOnDone = nil -- 285
	self.onEndingTap = nil -- 286
	self.endingTapGuard = 0 -- 287
	self.hudNode = Node() -- 288
	self.hudNode:addTo(parent) -- 289
	self.flash = DrawNode() -- 290
	self.flash:addTo(self.hudNode) -- 291
	self.rewindDraw = DrawNode() -- 292
	self.rewindDraw:addTo(self.hudNode) -- 293
	self.hud = DrawNode() -- 294
	self.hud:addTo(self.hudNode) -- 295
	self.heartSps = {} -- 297
	self.heartTex = loadTex(HEART_TEX) -- 298
	if self.heartTex ~= nil then -- 298
		do -- 298
			local i = 0 -- 300
			while i < HUD_MAX_HEARTS do -- 300
				local sp = pxSprite(self.heartTex) -- 301
				sp.anchor = Vec2(0, 0) -- 302
				sp.scaleX = HEART_SCALE -- 303
				sp.scaleY = HEART_SCALE -- 304
				sp.visible = false -- 305
				sp:addTo(self.hudNode) -- 306
				local ____self_heartSps_0 = self.heartSps -- 306
				____self_heartSps_0[#____self_heartSps_0 + 1] = sp -- 307
				i = i + 1 -- 300
			end -- 300
		end -- 300
	end -- 300
	local wheelNTex = loadTex(WHEEL_TEX_NORMAL) -- 311
	local wheelATex = loadTex(WHEEL_TEX_ACTIVE) -- 312
	local wheelDTex = loadTex(WHEEL_TEX_DIM) -- 313
	if wheelNTex ~= nil and wheelATex ~= nil and wheelDTex ~= nil then -- 313
		self.wheelNormalSp = self:makeWheelSprite( -- 315
			wheelNTex, -- 315
			WHEEL_PX / math.max(wheelNTex.width, wheelNTex.height) -- 315
		) -- 315
		self.wheelActiveSp = self:makeWheelSprite( -- 316
			wheelATex, -- 316
			WHEEL_PX / math.max(wheelATex.width, wheelATex.height) -- 316
		) -- 316
		self.wheelDimSp = self:makeWheelSprite( -- 317
			wheelDTex, -- 317
			WHEEL_PX / math.max(wheelDTex.width, wheelDTex.height) -- 317
		) -- 317
	end -- 317
	self.wheelDraw = DrawNode() -- 319
	self.wheelDraw:addTo(self.hudNode) -- 320
	local w = View.size.width -- 321
	local h = View.size.height -- 322
	local left = -w / 2 -- 323
	local top = h / 2 -- 324
	local gr = w / 2 - 24 -- 326
	self.guideTitleLb = makePixelLabel( -- 327
		self.hudNode, -- 327
		36, -- 327
		gr, -- 327
		top - 142, -- 327
		1, -- 327
		0.5, -- 327
		ink(0, 0, 0) -- 327
	) -- 327
	setText(self.guideTitleLb, "— 月相轮的指引 —") -- 328
	self.guideMissionLb = makePixelLabel( -- 329
		self.hudNode, -- 329
		30, -- 329
		gr, -- 329
		top - 178, -- 329
		1, -- 329
		1, -- 329
		ink(0, 0, 0) -- 329
	) -- 329
	self.guideStepLb = makePixelLabel( -- 330
		self.hudNode, -- 330
		26, -- 330
		gr, -- 330
		top - 178, -- 330
		1, -- 330
		1, -- 330
		ink(0, 0, 0) -- 330
	) -- 330
	self.hintLb = makeLabel( -- 331
		self.hudNode, -- 331
		18, -- 331
		0, -- 331
		-top + 30, -- 331
		0.5, -- 331
		0.5, -- 331
		Palette.paleInkMid -- 331
	) -- 331
	self.rewindLb = makeLabel( -- 332
		self.hudNode, -- 332
		26, -- 332
		0, -- 332
		96, -- 332
		0.5, -- 332
		0.5, -- 332
		Palette.moonCyan -- 332
	) -- 332
	setText(self.rewindLb, "回溯中…") -- 333
	if self.rewindLb ~= nil then -- 333
		self.rewindLb.visible = false -- 335
	end -- 335
	local cx = w / 2 - 74 -- 337
	self.phaseLb = makeLabel( -- 338
		self.hudNode, -- 338
		17, -- 338
		cx, -- 338
		top - 78, -- 338
		0.5, -- 338
		0.5, -- 338
		Palette.gold -- 338
	) -- 338
	self.loopLb = makeLabel( -- 339
		self.hudNode, -- 339
		15, -- 339
		cx, -- 339
		top - 102, -- 339
		0.5, -- 339
		0.5, -- 339
		Palette.paleInk -- 339
	) -- 339
	self.endingNode = Node() -- 341
	self.endingNode:addTo(parent) -- 342
	self.endingNode.visible = false -- 343
	self.endingBg = DrawNode() -- 344
	self.endingBg:addTo(self.endingNode) -- 345
	self.endingTitleLb = makeLabel( -- 346
		self.endingNode, -- 346
		46, -- 346
		0, -- 346
		top - 150, -- 346
		0.5, -- 346
		0.5, -- 346
		Palette.inkDark -- 346
	) -- 346
	do -- 346
		local i = 0 -- 347
		while i < 8 do -- 347
			local lb = makeLabel( -- 348
				self.endingNode, -- 348
				20, -- 348
				0, -- 348
				top - 224 - i * 34, -- 348
				0.5, -- 348
				0.5, -- 348
				Palette.inkSoft -- 348
			) -- 348
			if lb ~= nil then -- 348
				local ____self_endingLineLbs_1 = self.endingLineLbs -- 348
				____self_endingLineLbs_1[#____self_endingLineLbs_1 + 1] = lb -- 350
			end -- 350
			i = i + 1 -- 347
		end -- 347
	end -- 347
	self.endingHintLb = makeLabel( -- 353
		self.endingNode, -- 353
		20, -- 353
		0, -- 353
		-top + 46, -- 353
		0.5, -- 353
		0.5, -- 353
		Palette.paleInk -- 353
	) -- 353
	setText(self.endingHintLb, "点击 或 按 R 返回标题") -- 354
	local endingTouch = Node() -- 356
	endingTouch.size = Size(w, h) -- 357
	endingTouch.position = Vec2(0, 0) -- 358
	endingTouch.touchEnabled = true -- 359
	endingTouch:addTo(self.endingNode) -- 360
	endingTouch:onTapBegan(function() -- 361
		if self.endingTapGuard > 0 then -- 361
			return -- 363
		end -- 363
		if self.onEndingTap ~= nil then -- 363
			self.onEndingTap() -- 366
		end -- 366
	end) -- 361
	self.endingNode:schedule(function(dt) -- 369
		if self.endingTapGuard > 0 then -- 369
			self.endingTapGuard = self.endingTapGuard - dt -- 371
		end -- 371
		return false -- 373
	end) -- 369
	self.titleNode = Node() -- 376
	self.titleNode:addTo(parent) -- 377
	self.titleNode.visible = false -- 378
	self.titleBg = DrawNode() -- 379
	self.titleBg:addTo(self.titleNode) -- 380
	local videoFile -- 384
	if Content:exist(COVER_VIDEO_PIN) then -- 384
		videoFile = COVER_VIDEO_PIN -- 386
	end -- 386
	if videoFile == nil then -- 386
		local ogvDirs = {"assets/art", ".agent"} -- 389
		for ____, dir in ipairs(ogvDirs) do -- 390
			do -- 390
				local names = Content:getFiles(dir) -- 391
				if names == nil then -- 391
					goto __continue39 -- 392
				end -- 392
				for ____, name in ipairs(names) do -- 393
					do -- 393
						if name == PROLOGUE_EXCLUDED_NAME then -- 393
							goto __continue41 -- 394
						end -- 394
						local ext = #name >= 4 and __TS__StringSubstring(name, #name - 4) or "" -- 395
						if ext == ".ogv" or ext == ".OGV" then -- 395
							videoFile = (dir .. "/") .. name -- 397
							break -- 398
						end -- 398
					end -- 398
					::__continue41:: -- 398
				end -- 398
				if videoFile ~= nil then -- 398
					break -- 401
				end -- 401
			end -- 401
			::__continue39:: -- 401
		end -- 401
	end -- 401
	local ____temp_2 -- 404
	if videoFile ~= nil then -- 404
		____temp_2 = VideoNode(videoFile, true) -- 404
	else -- 404
		____temp_2 = nil -- 404
	end -- 404
	local coverVideo = ____temp_2 -- 404
	if coverVideo ~= nil then -- 404
		local vw = coverVideo.width -- 406
		local vh = coverVideo.height -- 407
		if vw > 0 and vh > 0 then -- 407
			local cs = math.max(w / vw, h / vh) -- 409
			coverVideo.anchor = Vec2(0.5, 0.5) -- 410
			coverVideo.position = Vec2(0, 0) -- 411
			coverVideo.scaleX = cs -- 412
			coverVideo.scaleY = cs -- 413
		end -- 413
		coverVideo:addTo(self.titleNode) -- 415
		self.coverVideo = coverVideo -- 416
		if not self.titleNode.visible then -- 416
			coverVideo:pause() -- 418
		end -- 418
	end -- 418
	if self.coverVideo == nil then -- 418
		self:drawTitleBg(w, h) -- 422
	end -- 422
	self.titleNameLb = self:makeTitleFontLabel(self.titleNode, 74, 0, top - 168) -- 427
	if self.titleNameLb ~= nil then -- 427
		self.titleNameLb.color = Color(255, 255, 255, 255) -- 429
	end -- 429
	local menuTexts = {"PLAY", "时空树仓库", "SETTINGS"} -- 432
	local btnTex = loadTex(TECH_BTN_PATH) -- 433
	if btnTex ~= nil then -- 433
		self.menuBtnW = btnTex.width -- 435
		self.menuBtnH = btnTex.height -- 436
	end -- 436
	local menuX = left + MENU_X_OFF -- 438
	do -- 438
		local i = 0 -- 439
		while i < #MENU_YS do -- 439
			local item = Node() -- 440
			item.position = Vec2(menuX, -h / 2 + MENU_YS[i + 1]) -- 441
			item:addTo(self.titleNode) -- 442
			local d = DrawNode() -- 443
			d:addTo(item) -- 444
			local ____self_menuDraws_3 = self.menuDraws -- 444
			____self_menuDraws_3[#____self_menuDraws_3 + 1] = d -- 445
			if btnTex ~= nil then -- 445
				local sp = Sprite(btnTex) -- 447
				if sp ~= nil then -- 447
					sp.anchor = Vec2(0.5, 0.5) -- 449
					sp.position = Vec2(0, 0) -- 450
					sp.scaleX = MENU_W / self.menuBtnW -- 451
					sp.scaleY = MENU_H / self.menuBtnH -- 452
					sp.opacity = 0.8 -- 453
					sp:addTo(item) -- 454
					local ____self_menuBtns_4 = self.menuBtns -- 454
					____self_menuBtns_4[#____self_menuBtns_4 + 1] = sp -- 455
					local ____self_menuBtnOk_5 = self.menuBtnOk -- 455
					____self_menuBtnOk_5[#____self_menuBtnOk_5 + 1] = true -- 456
				else -- 456
					local ____self_menuBtnOk_6 = self.menuBtnOk -- 456
					____self_menuBtnOk_6[#____self_menuBtnOk_6 + 1] = false -- 458
				end -- 458
			else -- 458
				local ____self_menuBtnOk_7 = self.menuBtnOk -- 458
				____self_menuBtnOk_7[#____self_menuBtnOk_7 + 1] = false -- 461
			end -- 461
			local lb = makeLabel( -- 463
				item, -- 463
				27, -- 463
				0, -- 463
				0, -- 463
				0.5, -- 463
				0.5, -- 463
				ink(255, 255, 255, 255) -- 463
			) -- 463
			setText(lb, menuTexts[i + 1]) -- 464
			if lb ~= nil then -- 464
				local ____self_menuLbs_8 = self.menuLbs -- 464
				____self_menuLbs_8[#____self_menuLbs_8 + 1] = lb -- 466
			end -- 466
			i = i + 1 -- 439
		end -- 439
	end -- 439
	self.particlesDraw = DrawNode() -- 470
	self.particlesDraw:addTo(self.titleNode) -- 471
	do -- 471
		local i = 0 -- 472
		while i < TITLE_PARTICLE_N do -- 472
			local ____self_particles_9 = self.particles -- 472
			____self_particles_9[#____self_particles_9 + 1] = { -- 473
				x = left + 90 + (w - 180) / TITLE_PARTICLE_N * i + math.random() * 60, -- 474
				y = -top + math.random() * h, -- 475
				vy = -(14 + math.random() * 14), -- 476
				r = 2 + math.random() * 1.6, -- 477
				ph = math.random() * math.pi * 2, -- 478
				gold = i % 2 == 0 -- 479
			} -- 479
			i = i + 1 -- 472
		end -- 472
	end -- 472
	self.settingsNode = Node() -- 483
	self.settingsNode:addTo(self.titleNode) -- 484
	self.settingsNode.visible = false -- 485
	makeTechPanel(self.settingsNode, PANEL_W, PANEL_H) -- 486
	local panelBg = DrawNode() -- 487
	panelBg:addTo(self.settingsNode) -- 488
	self:makePanelLabel( -- 489
		panelBg, -- 489
		24, -- 489
		0, -- 489
		PANEL_H / 2 - 44, -- 489
		"操 作 键 位", -- 489
		ink(255, 255, 255, 255) -- 489
	) -- 489
	do -- 489
		local i = 0 -- 490
		while i < #SETTINGS_KEYS do -- 490
			self:makePanelLabel( -- 491
				panelBg, -- 491
				19, -- 491
				0, -- 491
				PANEL_H / 2 - 86 - i * 32, -- 491
				SETTINGS_KEYS[i + 1], -- 491
				ink(255, 255, 255, 255) -- 491
			) -- 491
			i = i + 1 -- 490
		end -- 490
	end -- 490
	self:makePanelLabel( -- 493
		panelBg, -- 493
		16, -- 493
		0, -- 493
		-PANEL_H / 2 + 34, -- 493
		"Esc 或再次点击 SETTINGS 关闭", -- 493
		ink(255, 255, 255, 255) -- 493
	) -- 493
	local touchNode = Node() -- 495
	touchNode.size = Size(w, h) -- 496
	touchNode.position = Vec2(0, 0) -- 497
	touchNode.touchEnabled = true -- 498
	touchNode:addTo(self.titleNode) -- 499
	touchNode:onTapBegan(function(touch) -- 500
		self:onTitleTap(touch, w, h) -- 501
	end) -- 500
	self.prologueNode = Node() -- 505
	self.prologueNode:addTo(parent) -- 506
	self.prologueNode.visible = false -- 507
	self.prologueBlack = DrawNode() -- 508
	self.prologueBlack:addTo(self.prologueNode) -- 509
	self.prologueBlack:drawPolygon( -- 510
		self:screenVerts(w, h), -- 510
		Color(0, 0, 0, 255) -- 510
	) -- 510
	if Content:exist(PROLOGUE_VIDEO_FILE) then -- 510
		local pv = VideoNode(PROLOGUE_VIDEO_FILE, false) -- 512
		if pv ~= nil then -- 512
			local pvw = pv.width -- 514
			local pvh = pv.height -- 515
			if pvw > 0 and pvh > 0 then -- 515
				local ps = math.max(w / pvw, h / pvh) -- 517
				pv.anchor = Vec2(0.5, 0.5) -- 518
				pv.position = Vec2(0, 0) -- 519
				pv.scaleX = ps -- 520
				pv.scaleY = ps -- 521
			end -- 521
			pv:pause() -- 526
			pv.visible = true -- 527
			pv:addTo(self.prologueNode) -- 528
			self.prologueVideo = pv -- 529
		end -- 529
	end -- 529
	self.prologueCard = Node() -- 534
	self.prologueCard.visible = false -- 535
	self.prologueCard.renderOrder = 10 -- 536
	self.prologueCard:addTo(self.prologueNode) -- 537
	local cardBg = DrawNode() -- 538
	cardBg:addTo(self.prologueCard) -- 539
	cardBg:drawPolygon( -- 540
		self:screenVerts(w, h), -- 540
		Color(0, 0, 0, 255) -- 540
	) -- 540
	self.prologueCardBg = cardBg -- 541
	self.prologueCardTitle = makeLabel( -- 542
		self.prologueCard, -- 542
		46, -- 542
		0, -- 542
		52, -- 542
		0.5, -- 542
		0.5, -- 542
		ink(255, 236, 200, 255) -- 542
	) -- 542
	if self.prologueCardTitle ~= nil then -- 542
		setText(self.prologueCardTitle, "衍 月 · 八 相") -- 544
		self.prologueCardTitle.opacity = 0 -- 545
	end -- 545
	self.prologueCardSub = makeLabel( -- 547
		self.prologueCard, -- 547
		21, -- 547
		0, -- 547
		-14, -- 547
		0.5, -- 547
		0.5, -- 547
		ink(255, 255, 255, 255) -- 547
	) -- 547
	if self.prologueCardSub ~= nil then -- 547
		setText(self.prologueCardSub, "以八相为约 · 满月为限") -- 549
		self.prologueCardSub.opacity = 0 -- 550
	end -- 550
	self.prologueHintLb = makeLabel( -- 552
		self.prologueNode, -- 552
		18, -- 552
		0, -- 552
		-h / 2 + 34, -- 552
		0.5, -- 552
		0.5, -- 552
		ink(255, 255, 255, 255) -- 552
	) -- 552
	setText(self.prologueHintLb, "Esc / 点击画面跳过") -- 553
	local prologueTouch = Node() -- 554
	prologueTouch.size = Size(w, h) -- 555
	prologueTouch.position = Vec2(0, 0) -- 556
	prologueTouch.touchEnabled = true -- 557
	prologueTouch:addTo(self.prologueNode) -- 558
	prologueTouch:onTapBegan(function() -- 559
		self:finishPrologue() -- 560
	end) -- 559
	self.prologueNode:onKeyDown(function(key) -- 562
		if self.prologuePlaying and (key == "Escape" or key == "Space" or key == "Return") then -- 562
			self:finishPrologue() -- 564
		end -- 564
	end) -- 562
	self.pauseNode = Node() -- 568
	self.pauseNode:addTo(parent) -- 569
	self.pauseNode.visible = false -- 570
	makeTechPanel(self.pauseNode, PANEL_W, PANEL_H) -- 571
	local pausePanel = DrawNode() -- 572
	pausePanel:addTo(self.pauseNode) -- 573
	self:makePanelLabel( -- 574
		pausePanel, -- 574
		24, -- 574
		0, -- 574
		PANEL_H / 2 - 44, -- 574
		"暂 停", -- 574
		ink(255, 255, 255, 255) -- 574
	) -- 574
	do -- 574
		local i = 0 -- 575
		while i < #PAUSE_KEYS do -- 575
			self:makePanelLabel( -- 576
				pausePanel, -- 576
				18, -- 576
				0, -- 576
				PANEL_H / 2 - 88 - i * 28, -- 576
				PAUSE_KEYS[i + 1], -- 576
				ink(255, 255, 255, 255) -- 576
			) -- 576
			i = i + 1 -- 575
		end -- 575
	end -- 575
	self:makePanelLabel( -- 579
		pausePanel, -- 579
		20, -- 579
		0, -- 579
		-172, -- 579
		"【 回到标题 】", -- 579
		ink(255, 236, 200, 255) -- 579
	) -- 579
	self:makePanelLabel( -- 580
		pausePanel, -- 580
		16, -- 580
		0, -- 580
		-206, -- 580
		"Esc 继续游戏", -- 580
		ink(255, 255, 255, 255) -- 580
	) -- 580
	local pauseTouch = Node() -- 582
	pauseTouch.size = Size(w, h) -- 583
	pauseTouch.position = Vec2(0, 0) -- 584
	pauseTouch.touchEnabled = true -- 585
	pauseTouch:addTo(self.pauseNode) -- 586
	pauseTouch:onTapBegan(function(touch) -- 587
		local ____local = touch.location -- 588
		local cx = ____local.x - w / 2 -- 589
		local cy = ____local.y - h / 2 -- 590
		if math.abs(cx) <= 160 and cy >= -194 and cy <= -150 and self.onReturnTitle ~= nil then -- 590
			self.onReturnTitle() -- 592
		end -- 592
	end) -- 587
end -- 251
function HUD.prototype.rectVerts(self, x, y, w, h) -- 597
	return { -- 598
		Vec2(x, y), -- 598
		Vec2(x + w, y), -- 598
		Vec2(x + w, y + h), -- 598
		Vec2(x, y + h) -- 598
	} -- 598
end -- 597
function HUD.prototype.screenVerts(self, w, h) -- 601
	return self:rectVerts(-w / 2, -h / 2, w, h) -- 602
end -- 601
function HUD.prototype.circle(self, draw, cx, cy, r, segs, width, color, from, sweep) -- 605
	do -- 605
		local i = 0 -- 606
		while i < segs do -- 606
			local a0 = from + i / segs * sweep -- 607
			local a1 = from + (i + 1) / segs * sweep -- 608
			draw:drawSegment( -- 609
				Vec2( -- 609
					cx + math.cos(a0) * r, -- 609
					cy + math.sin(a0) * r -- 609
				), -- 609
				Vec2( -- 609
					cx + math.cos(a1) * r, -- 609
					cy + math.sin(a1) * r -- 609
				), -- 609
				width, -- 609
				col(color) -- 609
			) -- 609
			i = i + 1 -- 606
		end -- 606
	end -- 606
end -- 605
function HUD.prototype.diamond(self, draw, x, y, s, fill, bw, border) -- 613
	draw:drawPolygon( -- 614
		{ -- 614
			Vec2(x, y + s), -- 614
			Vec2(x + s, y), -- 614
			Vec2(x, y - s), -- 614
			Vec2(x - s, y) -- 614
		}, -- 614
		col(fill), -- 614
		bw, -- 614
		col(border) -- 614
	) -- 614
end -- 613
function HUD.prototype.makeTitleFontLabel(self, parent, size, x, y) -- 617
	do -- 617
		local i = 0 -- 618
		while i < #TITLE_FONTS do -- 618
			local lb = Label(TITLE_FONTS[i + 1], size) -- 619
			if lb ~= nil then -- 619
				lb.anchor = Vec2(0.5, 0.5) -- 621
				lb.position = Vec2(x, y) -- 622
				lb:addTo(parent) -- 623
				return lb -- 624
			end -- 624
			i = i + 1 -- 618
		end -- 618
	end -- 618
	return makeLabel( -- 627
		parent, -- 627
		size - 4, -- 627
		x, -- 627
		y, -- 627
		0.5, -- 627
		0.5, -- 627
		Palette.paleInk -- 627
	) -- 627
end -- 617
function HUD.prototype.makeWheelSprite(self, tex, scale) -- 630
	local sp = Sprite(tex) -- 631
	if sp == nil then -- 631
		return nil -- 633
	end -- 633
	sp.anchor = Vec2(0.5, 0.5) -- 635
	sp.scaleX = scale -- 636
	sp.scaleY = scale -- 637
	sp.visible = false -- 638
	sp:addTo(self.hudNode) -- 639
	return sp -- 640
end -- 630
function HUD.prototype.makePanelLabel(self, parent, size, x, y, text, c) -- 643
	local lb = Label(PANEL_FONT, size) -- 644
	if lb == nil then -- 644
		lb = makeLabel( -- 646
			parent, -- 646
			size, -- 646
			x, -- 646
			y, -- 646
			0.5, -- 646
			0.5, -- 646
			c -- 646
		) -- 646
	else -- 646
		lb.anchor = Vec2(0.5, 0.5) -- 648
		lb.position = Vec2(x, y) -- 649
		lb.color = Color(c.r, c.g, c.b, c.a) -- 650
		lb:addTo(parent) -- 651
	end -- 651
	setText(lb, text) -- 653
end -- 643
function HUD.prototype.updatePixelLife(self, st, x0, rowY) -- 657
	if self.heartTex == nil then -- 657
		return false -- 659
	end -- 659
	local bottomY = rowY - 24 -- 661
	local step = st.maxLife > 5 and 36 or HEART_STEP -- 663
	local barX = x0 + math.min(st.maxLife, HUD_MAX_HEARTS) * step + 16 -- 664
	local ratio = st.maxLife > 0 and math.max( -- 665
		0, -- 665
		math.min(1, st.heroineLife / st.maxLife) -- 665
	) or 0 -- 665
	do -- 665
		local i = 0 -- 666
		while i < #self.heartSps do -- 666
			local sp = self.heartSps[i + 1] -- 667
			local active = i < st.maxLife -- 668
			sp.visible = active -- 669
			if active then -- 669
				sp.position = Vec2(x0 + i * step, bottomY) -- 671
				sp.color = i < st.heroineLife and Color(255, 255, 255, 255) or Color(255, 255, 255, 70) -- 672
			end -- 672
			i = i + 1 -- 666
		end -- 666
	end -- 666
	self.hud:drawPolygon( -- 675
		self:rectVerts(barX, bottomY, BAR_W, BAR_H), -- 675
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 245)), -- 675
		2, -- 675
		col(Palette.inkDark) -- 675
	) -- 675
	if ratio > 0 then -- 675
		local fw = (BAR_W - BAR_PAD * 2) * ratio -- 677
		self.hud:drawPolygon( -- 678
			self:rectVerts(barX + BAR_PAD, bottomY + BAR_PAD, fw, BAR_H - BAR_PAD * 2), -- 678
			col(Palette.vermilion) -- 678
		) -- 678
	end -- 678
	return true -- 680
end -- 657
function HUD.prototype.drawTitleBg(self, w, h) -- 684
	self.titleBg:clear() -- 685
	self.titleBg:drawPolygon( -- 686
		self:screenVerts(w, h), -- 686
		Palette.paper -- 686
	) -- 686
	local mx = w / 2 - 190 -- 687
	local my = h / 2 - 170 -- 688
	self:circle( -- 689
		self.titleBg, -- 689
		mx, -- 689
		my, -- 689
		96, -- 689
		40, -- 689
		2, -- 689
		Palette.goldSoft, -- 689
		0, -- 689
		math.pi * 2 -- 689
	) -- 689
	self.titleBg:drawDot( -- 690
		Vec2(mx, my), -- 690
		84, -- 690
		col(Palette.moonWhite) -- 690
	) -- 690
	do -- 690
		local i = 0 -- 691
		while i < 4 do -- 691
			local x0 = -w / 2 + i * (w / 3.2) -- 692
			self.titleBg:drawSegment( -- 693
				Vec2(x0, -h / 2 + 40 + i * 14), -- 693
				Vec2(x0 + w / 3.6, -h / 2 + 26 + i * 14), -- 693
				26 + i * 8, -- 693
				col(Palette.paleInkFar) -- 693
			) -- 693
			i = i + 1 -- 691
		end -- 691
	end -- 691
end -- 684
function HUD.prototype.onTitleTap(self, touch, w, h) -- 698
	if not self.titleMenuEnabled then -- 698
		return -- 700
	end -- 700
	local x = touch.location.x - w / 2 -- 702
	local y = touch.location.y - h / 2 -- 703
	local menuX = -w / 2 + MENU_X_OFF -- 704
	do -- 704
		local i = 0 -- 705
		while i < #MENU_YS do -- 705
			local yy = -h / 2 + MENU_YS[i + 1] -- 706
			if math.abs(x - menuX) <= MENU_HALF_X and math.abs(y - yy) <= MENU_HALF_Y then -- 706
				if self.settingsOpen then -- 706
					if i == 2 then -- 706
						self:closeSettings() -- 710
					end -- 710
					return -- 712
				end -- 712
				if self.menuSel == i then -- 712
					self:confirmCurrent() -- 715
				else -- 715
					self.menuSel = i -- 717
				end -- 717
				return -- 719
			end -- 719
			i = i + 1 -- 705
		end -- 705
	end -- 705
end -- 698
function HUD.prototype.confirmCurrent(self) -- 724
	if self.playLock then -- 724
		return -- 726
	end -- 726
	if self.menuSel == 0 then -- 726
		self.playLock = true -- 729
		self.menuFlashT = MENU_FLASH_T -- 730
		local cb = self.onPlayConfirmed -- 731
		if cb ~= nil then -- 731
			cb() -- 733
		end -- 733
	elseif self.menuSel == 1 then -- 733
		local gb = self.onGalleryConfirmed -- 736
		if gb ~= nil then -- 736
			gb() -- 738
		end -- 738
	else -- 738
		self:openSettings() -- 741
	end -- 741
end -- 724
function HUD.prototype.openSettings(self) -- 745
	self.settingsOpen = true -- 746
	self.settingsNode.visible = true -- 747
end -- 745
function HUD.prototype.closeSettings(self) -- 750
	self.settingsOpen = false -- 751
	self.settingsNode.visible = false -- 752
end -- 750
function HUD.prototype.flashDamage(self) -- 755
	self.flashTimer = FLASH_TIME -- 756
end -- 755
function HUD.prototype.setRewind(self, v) -- 759
	self.rewindV = v -- 760
	if self.rewindLb ~= nil then -- 760
		self.rewindLb.visible = v >= 0 -- 762
	end -- 762
end -- 759
function HUD.prototype.showEnding(self, id) -- 766
	local e = ENDINGS[id] -- 767
	if e == nil then -- 767
		return -- 769
	end -- 769
	local w = View.size.width -- 771
	local h = View.size.height -- 772
	self.endingBg:clear() -- 773
	self.endingBg:drawPolygon( -- 774
		self:screenVerts(w, h), -- 774
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 242)) -- 774
	) -- 774
	self.endingBg:drawPolygon( -- 775
		self:rectVerts(-w / 2 + 14, -h / 2 + 14, w - 28, h - 28), -- 775
		col(NO_FILL), -- 775
		1, -- 775
		col(Palette.goldSoft) -- 775
	) -- 775
	setText(self.endingTitleLb, e.title) -- 776
	do -- 776
		local i = 0 -- 777
		while i < #self.endingLineLbs do -- 777
			setText(self.endingLineLbs[i + 1], i < #e.lines and e.lines[i + 1] or "") -- 778
			i = i + 1 -- 777
		end -- 777
	end -- 777
	local cands = ENDING_IMAGES[id] -- 782
	if cands ~= nil then -- 782
		local tex -- 784
		local used = "" -- 785
		for ____, p in ipairs(cands) do -- 786
			tex = Texture2D(p) -- 787
			if tex ~= nil then -- 787
				used = p -- 789
				break -- 790
			end -- 790
		end -- 790
		if tex ~= nil and used ~= "" then -- 790
			if self.endingSp == nil or self.endingTexId ~= used then -- 790
				local oldSp = self.endingSp -- 795
				if oldSp ~= nil then -- 795
					oldSp:removeFromParent(true) -- 797
				end -- 797
				self.endingSp = nil -- 799
				local sp = Sprite(tex) -- 800
				if sp ~= nil then -- 800
					sp:addTo(self.endingNode) -- 802
					sp.position = Vec2(0, 0) -- 803
					sp.anchor = Vec2(0.5, 0.5) -- 804
					self.endingSp = sp -- 805
					self.endingTexId = used -- 806
				end -- 806
			end -- 806
			if self.endingSp ~= nil then -- 806
				local iw = tex.width -- 810
				local ih = tex.height -- 811
				if iw > 0 and ih > 0 then -- 811
					local s = math.max(w / iw, h / ih) -- 813
					self.endingSp.scaleX = s -- 814
					self.endingSp.scaleY = s -- 815
				end -- 815
				self.endingSp.visible = true -- 817
			end -- 817
		else -- 817
			if self.endingSp ~= nil then -- 817
				self.endingSp.visible = false -- 821
			end -- 821
		end -- 821
	elseif self.endingSp ~= nil then -- 821
		self.endingSp.visible = false -- 825
	end -- 825
	self.endingTapGuard = 0.8 -- 827
	self.endingNode.visible = true -- 828
end -- 766
function HUD.prototype.hideEnding(self) -- 831
	self.endingNode.visible = false -- 832
end -- 831
function HUD.prototype.setTitleVisible(self, v) -- 835
	self.titleNode.visible = v -- 836
	if self.coverVideo ~= nil then -- 836
		if v then -- 836
			self.coverVideo:resume() -- 840
		else -- 840
			self.coverVideo:pause() -- 842
		end -- 842
	end -- 842
	if v then -- 842
		self.playLock = false -- 847
		self.menuSel = 0 -- 848
		self.menuFlashT = 0 -- 849
		if self.settingsOpen then -- 849
			self:closeSettings() -- 851
		end -- 851
	end -- 851
end -- 835
function HUD.prototype.createPrologueVideo(self) -- 859
	local pv = VideoNode(PROLOGUE_VIDEO_FILE, false) -- 860
	if pv == nil then -- 860
		return nil -- 862
	end -- 862
	local vw = View.size.width -- 864
	local vh = View.size.height -- 865
	if pv.width > 0 and pv.height > 0 then -- 865
		local ps = math.max(vw / pv.width, vh / pv.height) -- 867
		pv.anchor = Vec2(0.5, 0.5) -- 868
		pv.position = Vec2(0, 0) -- 869
		pv.scaleX = ps -- 870
		pv.scaleY = ps -- 871
	end -- 871
	pv.visible = true -- 873
	pv:addTo(self.prologueNode) -- 874
	self.prologueVideo = pv -- 875
	return pv -- 876
end -- 859
function HUD.prototype.startPrologueAudio(self) -- 880
	if self.prologueAudio == "" or self.prologueAudioStarted then -- 880
		return -- 882
	end -- 882
	self.prologueAudioStarted = true -- 884
	stopBgm(0.15) -- 885
	do -- 885
		local function ____catch(e) -- 885
			local ____ = e -- 885
		end -- 885
		local ____try, ____hasReturned = pcall(function() -- 885
			Audio:playStream(self.prologueAudio, false, 0.15) -- 887
		end) -- 887
		if not ____try then -- 887
			____catch(____hasReturned) -- 887
		end -- 887
	end -- 887
end -- 880
function HUD.prototype.playPrologue(self, onDone) -- 893
	local oldVid = self.prologueVideo -- 897
	if oldVid ~= nil then -- 897
		oldVid:removeFromParent() -- 899
		self.prologueVideo = nil -- 900
	end -- 900
	if self.prologuePlaying then -- 900
		return -- 903
	end -- 903
	self.prologuePlaying = true -- 905
	self.prologueStarted = false -- 906
	self.prologueWaitT = 0 -- 907
	self.prologueLeadT = 0 -- 908
	self.prologueAudioStarted = false -- 909
	self.prologueTailT = 0 -- 910
	if self.prologueCard ~= nil then -- 910
		self.prologueCard.visible = false -- 912
	end -- 912
	if self.prologueCardTitle ~= nil then -- 912
		self.prologueCardTitle.opacity = 0 -- 915
	end -- 915
	if self.prologueCardSub ~= nil then -- 915
		self.prologueCardSub.opacity = 0 -- 918
	end -- 918
	local oldTailVid = self.prologueCoverVideo -- 921
	if oldTailVid ~= nil then -- 921
		oldTailVid:removeFromParent() -- 923
		self.prologueCoverVideo = nil -- 924
	end -- 924
	self.prologueCoverFailed = false -- 926
	if self.prologueCardBg ~= nil then -- 926
		self.prologueCardBg.visible = true -- 928
	end -- 928
	self.prologueOnDone = onDone -- 930
	self.prologueNode.visible = true -- 931
	local coverVid = self.coverVideo -- 933
	if coverVid ~= nil then -- 933
		coverVid:pause() -- 935
	end -- 935
	self.prologueAudio = "" -- 938
	do -- 938
		local i = 0 -- 939
		while i < #PROLOGUE_AUDIO_FILES do -- 939
			local f = PROLOGUE_AUDIO_FILES[i + 1] -- 940
			if Content:exist(f) then -- 940
				self.prologueAudio = f -- 942
				break -- 943
			end -- 943
			i = i + 1 -- 939
		end -- 939
	end -- 939
	self.prologueNode:schedule(function(dt) -- 951
		if not self.prologuePlaying then -- 951
			return true -- 953
		end -- 953
		if self.prologueVideo == nil then -- 953
			if self.prologueLeadT < PROLOGUE_AUDIO_LEAD then -- 953
				self.prologueLeadT = self.prologueLeadT + dt -- 958
				if self.prologueLeadT >= PROLOGUE_AUDIO_LEAD then -- 958
					self:startPrologueAudio() -- 960
				end -- 960
				return false -- 962
			end -- 962
			local pv = self:createPrologueVideo() -- 964
			if pv == nil then -- 964
				self:finishPrologue() -- 966
				return true -- 967
			end -- 967
			self.prologueWaitT = 0 -- 969
			return false -- 970
		end -- 970
		local video = self.prologueVideo -- 972
		if not self.prologueStarted then -- 972
			if not video.paused then -- 972
				self.prologueStarted = true -- 975
				self:startPrologueAudio() -- 976
			else -- 976
				self.prologueWaitT = self.prologueWaitT + dt -- 978
				if self.prologueWaitT > PROLOGUE_START_TIMEOUT then -- 978
					self:finishPrologue() -- 980
					return true -- 981
				end -- 981
			end -- 981
		elseif video.paused then -- 981
			self.prologueTailT = self.prologueTailT + dt -- 987
			local tailOn = self.prologueTailT > 0.05 -- 991
			if self.prologueCard ~= nil then -- 991
				self.prologueCard.visible = tailOn -- 993
			end -- 993
			if tailOn and self.prologueCoverVideo == nil and not self.prologueCoverFailed and Content:exist(COVER_VIDEO_PIN) then -- 993
				local cv = VideoNode(COVER_VIDEO_PIN, true) -- 998
				if cv ~= nil then -- 998
					local cw = cv.width -- 1000
					local ch = cv.height -- 1001
					local vw = View.size.width -- 1002
					local vh = View.size.height -- 1003
					if cw > 0 and ch > 0 then -- 1003
						local cs = math.max(vw / cw, vh / ch) -- 1005
						cv.anchor = Vec2(0.5, 0.5) -- 1006
						cv.position = Vec2(0, 0) -- 1007
						cv.scaleX = cs -- 1008
						cv.scaleY = cs -- 1009
					end -- 1009
					cv.opacity = 0 -- 1011
					cv:addTo(self.prologueNode) -- 1012
					self.prologueCoverVideo = cv -- 1013
				else -- 1013
					self.prologueCoverFailed = true -- 1015
				end -- 1015
			end -- 1015
			if self.prologueCardBg ~= nil then -- 1015
				self.prologueCardBg.visible = self.prologueCoverVideo == nil -- 1019
			end -- 1019
			local cardU = math.min(1, self.prologueTailT / 1.2) -- 1021
			local cardA = math.floor(cardU * cardU * 255 + 0.5) -- 1022
			if self.prologueCardTitle ~= nil then -- 1022
				self.prologueCardTitle.opacity = cardA -- 1024
			end -- 1024
			if self.prologueCardSub ~= nil then -- 1024
				self.prologueCardSub.opacity = cardA -- 1027
			end -- 1027
			if self.prologueCoverVideo ~= nil then -- 1027
				self.prologueCoverVideo.opacity = cardU * cardU -- 1030
			end -- 1030
			if self.prologueTailT >= PROLOGUE_AUDIO_TAIL then -- 1030
				self:finishPrologue() -- 1033
				return true -- 1034
			end -- 1034
			return false -- 1036
		else -- 1036
			self.prologueTailT = 0 -- 1039
			if self.prologueCard ~= nil then -- 1039
				self.prologueCard.visible = false -- 1041
			end -- 1041
		end -- 1041
		return false -- 1044
	end) -- 951
end -- 893
function HUD.prototype.finishPrologue(self) -- 1049
	if not self.prologuePlaying then -- 1049
		return -- 1051
	end -- 1051
	self.prologuePlaying = false -- 1053
	local cb = self.prologueOnDone -- 1054
	self.prologueOnDone = nil -- 1055
	local video = self.prologueVideo -- 1056
	if video ~= nil then -- 1056
		video:pause() -- 1058
	end -- 1058
	local tailVid = self.prologueCoverVideo -- 1060
	if tailVid ~= nil then -- 1060
		tailVid:removeFromParent() -- 1062
		self.prologueCoverVideo = nil -- 1063
	end -- 1063
	self.prologueNode.visible = false -- 1065
	if self.prologueAudioStarted then -- 1065
		self.prologueAudioStarted = false -- 1068
		self.prologueAudio = "" -- 1069
		do -- 1069
			local function ____catch(e) -- 1069
				local ____ = e -- 1069
			end -- 1069
			local ____try, ____hasReturned = pcall(function() -- 1069
				Audio:stopStream(0.4) -- 1071
			end) -- 1071
			if not ____try then -- 1071
				____catch(____hasReturned) -- 1071
			end -- 1071
		end -- 1071
		playBgm("cover") -- 1075
	end -- 1075
	local coverVid = self.coverVideo -- 1077
	if coverVid ~= nil and self.titleNode.visible then -- 1077
		coverVid:resume() -- 1079
	end -- 1079
	if cb ~= nil then -- 1079
		cb() -- 1082
	end -- 1082
end -- 1049
function HUD.prototype.setPauseVisible(self, v) -- 1086
	self.pauseNode.visible = v -- 1087
end -- 1086
function HUD.prototype.setMoonWheel(self, mode) -- 1091
	self.wheelMode = mode -- 1092
	local nSp = self.wheelNormalSp -- 1093
	local aSp = self.wheelActiveSp -- 1094
	local dSp = self.wheelDimSp -- 1095
	if nSp ~= nil and aSp ~= nil and dSp ~= nil then -- 1095
		nSp.visible = mode == "normal" -- 1097
		aSp.visible = mode == "active" -- 1098
		dSp.visible = mode == "dim" -- 1099
	end -- 1099
end -- 1091
function HUD.prototype.handleTitleKey(self, key) -- 1104
	if not self.titleMenuEnabled or self.prologuePlaying then -- 1104
		return -- 1106
	end -- 1106
	if key == "Escape" then -- 1106
		if self.settingsOpen then -- 1106
			self:closeSettings() -- 1110
		end -- 1110
		return -- 1112
	end -- 1112
	if self.settingsOpen then -- 1112
		return -- 1116
	end -- 1116
	local n = 3 -- 1118
	if key == "W" or key == "Up" then -- 1118
		self.menuSel = (self.menuSel + n - 1) % n -- 1120
	elseif key == "S" or key == "Down" then -- 1120
		self.menuSel = (self.menuSel + 1) % n -- 1122
	elseif key == "Return" or key == "Space" then -- 1122
		self:confirmCurrent() -- 1124
	end -- 1124
end -- 1104
function HUD.prototype.update(self, dt, args) -- 1128
	local st = args.state -- 1129
	local w = View.size.width -- 1130
	local h = View.size.height -- 1131
	local top = h / 2 -- 1132
	self.hud:clear() -- 1133
	local baseX = -w / 2 + 44 -- 1135
	local rowY = top - 44 -- 1136
	local pxLife = self:updatePixelLife(st, baseX - 4, rowY) -- 1137
	if not pxLife then -- 1137
		do -- 1137
			local i = 0 -- 1139
			while i < st.maxLife do -- 1139
				local x = baseX + i * 30 -- 1140
				if i < st.heroineLife then -- 1140
					self:diamond( -- 1142
						self.hud, -- 1142
						x, -- 1142
						rowY, -- 1142
						12, -- 1142
						Palette.vermilion, -- 1142
						2, -- 1142
						Palette.inkDark -- 1142
					) -- 1142
				else -- 1142
					self:diamond( -- 1144
						self.hud, -- 1144
						x, -- 1144
						rowY, -- 1144
						12, -- 1144
						NO_FILL, -- 1144
						2, -- 1144
						Palette.inkFaint -- 1144
					) -- 1144
				end -- 1144
				i = i + 1 -- 1139
			end -- 1139
		end -- 1139
	end -- 1139
	local ix0 = pxLife and baseX - 4 + math.min(st.maxLife, HUD_MAX_HEARTS) * (st.maxLife > 5 and 36 or HEART_STEP) + 16 + BAR_W + 16 or baseX + st.maxLife * 30 + 26 -- 1148
	do -- 1148
		local i = 0 -- 1151
		while i < st.maxSwordIntent do -- 1151
			local x = ix0 + i * 16 -- 1152
			if i < st.swordIntent then -- 1152
				self.hud:drawSegment( -- 1154
					Vec2(x, rowY - 10), -- 1154
					Vec2(x, rowY + 10), -- 1154
					4, -- 1154
					col(Palette.moonCyan) -- 1154
				) -- 1154
			else -- 1154
				self.hud:drawSegment( -- 1156
					Vec2(x, rowY - 10), -- 1156
					Vec2(x, rowY + 10), -- 1156
					2, -- 1156
					col(Palette.inkFaint) -- 1156
				) -- 1156
			end -- 1156
			i = i + 1 -- 1151
		end -- 1151
	end -- 1151
	setText(self.phaseLb, st.phaseIndex >= 0 and st.phaseIndex < #PHASE_NAMES and PHASE_NAMES[st.phaseIndex + 1] or "") -- 1159
	setText( -- 1160
		self.loopLb, -- 1160
		("第" .. tostring(st.loopIndex + 1)) .. "周目" -- 1160
	) -- 1160
	local missionLb = self.guideMissionLb -- 1162
	local stepLb = self.guideStepLb -- 1163
	setText( -- 1164
		missionLb, -- 1164
		wrapCjk((("「" .. args.floorName) .. "」") .. args.mission, 13) -- 1164
	) -- 1164
	setText( -- 1165
		stepLb, -- 1165
		wrapCjk(args.objective, 14) -- 1165
	) -- 1165
	if missionLb ~= nil and stepLb ~= nil then -- 1165
		local mh = missionLb.height -- 1167
		stepLb.y = missionLb.y - (mh > 0 and mh or 30) - 8 -- 1168
	end -- 1168
	local gw = args.guideLight == true -- 1171
	if gw ~= self.guideWhite then -- 1171
		self.guideWhite = gw -- 1173
		local c = gw and Color(255, 255, 255, 255) or Color(0, 0, 0, 255) -- 1174
		if self.guideTitleLb ~= nil then -- 1174
			self.guideTitleLb.color = c -- 1176
		end -- 1176
		if missionLb ~= nil then -- 1176
			missionLb.color = c -- 1179
		end -- 1179
		if stepLb ~= nil then -- 1179
			stepLb.color = c -- 1182
		end -- 1182
	end -- 1182
	setText(self.hintLb, args.hint) -- 1185
	local boss = args.boss -- 1187
	if boss ~= nil and not boss.dead and boss.maxHp > 0 then -- 1187
		local bw = 520 -- 1189
		local bx = -bw / 2 -- 1190
		local by = -top + 66 -- 1191
		self.hud:drawPolygon( -- 1192
			self:rectVerts(bx, by, bw, 12), -- 1192
			col(NO_FILL), -- 1192
			2, -- 1192
			col(Palette.inkDark) -- 1192
		) -- 1192
		local frac = math.max( -- 1193
			0, -- 1193
			math.min(1, boss.hp / boss.maxHp) -- 1193
		) -- 1193
		if frac > 0 then -- 1193
			self.hud:drawPolygon( -- 1195
				self:rectVerts(bx + 2, by + 2, (bw - 4) * frac, 8), -- 1195
				col(Palette.vermilion) -- 1195
			) -- 1195
		end -- 1195
	end -- 1195
	local wheelCx = w / 2 - 74 -- 1199
	local wheelCy = top - 40 -- 1200
	local nSp = self.wheelNormalSp -- 1201
	local aSp = self.wheelActiveSp -- 1202
	local dSp = self.wheelDimSp -- 1203
	if nSp ~= nil and aSp ~= nil and dSp ~= nil then -- 1203
		nSp.position = Vec2(wheelCx, wheelCy) -- 1205
		aSp.position = Vec2(wheelCx, wheelCy) -- 1206
		dSp.position = Vec2(wheelCx, wheelCy) -- 1207
		nSp.visible = self.wheelMode == "normal" -- 1208
		aSp.visible = self.wheelMode == "active" -- 1209
		dSp.visible = self.wheelMode == "dim" -- 1210
		self.wheelDraw:clear() -- 1211
	else -- 1211
		self.wheelDraw:clear() -- 1213
		self:circle( -- 1214
			self.wheelDraw, -- 1214
			wheelCx, -- 1214
			wheelCy, -- 1214
			22, -- 1214
			28, -- 1214
			2, -- 1214
			self.wheelMode == "active" and Palette.moonWhite or Palette.gold, -- 1214
			0, -- 1214
			math.pi * 2 -- 1214
		) -- 1214
	end -- 1214
	self.flash:clear() -- 1217
	if self.flashTimer > 0 then -- 1217
		self.flashTimer = math.max(0, self.flashTimer - dt) -- 1219
		local a = math.floor(255 * 0.35 * (self.flashTimer / FLASH_TIME)) -- 1220
		self.flash:drawPolygon( -- 1221
			self:screenVerts(w, h), -- 1221
			col(ink(Palette.vermilion.r, Palette.vermilion.g, Palette.vermilion.b, a)) -- 1221
		) -- 1221
	end -- 1221
	self.rewindDraw:clear() -- 1224
	if self.rewindV >= 0 then -- 1224
		local v = math.max( -- 1226
			0, -- 1226
			math.min(1, self.rewindV) -- 1226
		) -- 1226
		self.rewindDraw:drawPolygon( -- 1227
			self:screenVerts(w, h), -- 1227
			col(Palette.mist) -- 1227
		) -- 1227
		self:circle( -- 1228
			self.rewindDraw, -- 1228
			0, -- 1228
			0, -- 1228
			46, -- 1228
			36, -- 1228
			4, -- 1228
			Palette.moonCyan, -- 1228
			-math.pi / 2, -- 1228
			v * math.pi * 2 -- 1228
		) -- 1228
	end -- 1228
	if args.fade ~= nil and args.fade > 0 then -- 1228
		local f = math.max( -- 1232
			0, -- 1232
			math.min(1, args.fade) -- 1232
		) -- 1232
		self.hud:drawPolygon( -- 1233
			self:screenVerts(w, h), -- 1233
			col(ink( -- 1233
				6, -- 1233
				8, -- 1233
				16, -- 1233
				math.floor(255 * f) -- 1233
			)) -- 1233
		) -- 1233
	end -- 1233
	if self.titleNode.visible then -- 1233
		self:updateTitleEffects(dt, args.time, w, h) -- 1237
	end -- 1237
end -- 1128
function HUD.prototype.updateTitleEffects(self, dt, time, w, h) -- 1241
	if self.coverSp ~= nil then -- 1241
		local breath = 1 + 0.015 * (1 + math.sin(time * 0.7)) -- 1244
		self.coverSp.scaleX = self.coverBaseScale * breath -- 1245
		self.coverSp.scaleY = self.coverBaseScale * breath -- 1246
	end -- 1246
	if self.titleNameLb ~= nil then -- 1246
		local a = 205 + math.floor(50 * math.sin(time * 2.2)) -- 1249
		self.titleNameLb.color = Color(255, 233, 172, a) -- 1250
	end -- 1250
	self.menuFlashT = math.max(0, self.menuFlashT - dt) -- 1252
	self:drawMenu(time) -- 1253
	self.particlesDraw:clear() -- 1254
	do -- 1254
		local i = 0 -- 1255
		while i < #self.particles do -- 1255
			local p = self.particles[i + 1] -- 1256
			p.y = p.y + p.vy * dt -- 1257
			if p.y < -h / 2 - 12 then -- 1257
				p.y = h / 2 + 12 -- 1259
				p.x = -w / 2 + 40 + math.random() * (w - 80) -- 1260
			end -- 1260
			local tw = 0.55 + 0.45 * math.sin(time * 2 + p.ph) -- 1262
			local a = math.floor(210 * tw) -- 1263
			self.particlesDraw:drawDot( -- 1264
				Vec2(p.x, p.y), -- 1264
				p.r + 1.4 * tw, -- 1264
				p.gold and Color(255, 216, 130, a) or Color(216, 230, 255, a) -- 1264
			) -- 1264
			i = i + 1 -- 1255
		end -- 1255
	end -- 1255
end -- 1241
function HUD.prototype.drawMenu(self, time) -- 1268
	local bi = 0 -- 1269
	do -- 1269
		local i = 0 -- 1270
		while i < #self.menuDraws do -- 1270
			local d = self.menuDraws[i + 1] -- 1271
			local selected = i == self.menuSel and not self.settingsOpen -- 1272
			d:clear() -- 1273
			if self.menuBtnOk[i + 1] == true then -- 1273
				local sp = self.menuBtns[bi + 1] -- 1275
				bi = bi + 1 -- 1276
				if sp ~= nil then -- 1276
					local s = selected and 1.07 or 1 -- 1278
					sp.scaleX = MENU_W / self.menuBtnW * s -- 1279
					sp.scaleY = MENU_H / self.menuBtnH * s -- 1280
					sp.opacity = selected and 1 or 0.72 -- 1281
				end -- 1281
			elseif selected then -- 1281
				d:drawPolygon( -- 1285
					self:rectVerts(-MENU_W / 2, -MENU_H / 2, MENU_W, MENU_H), -- 1285
					Color(96, 200, 255, 26), -- 1285
					2, -- 1285
					Color(96, 200, 255, 220) -- 1285
				) -- 1285
			end -- 1285
			local lb = self.menuLbs[i + 1] -- 1287
			if lb ~= nil then -- 1287
				if selected then -- 1287
					local glow = 215 + math.floor(40 * math.sin(time * 3.4)) -- 1290
					local flash = self.menuFlashT > 0 -- 1291
					lb.color = flash and Color(255, 255, 255, 255) or Color(255, 255, 255, glow) -- 1292
					lb.scaleX = 1.06 -- 1293
					lb.scaleY = 1.06 -- 1294
				else -- 1294
					lb.color = Color(255, 255, 255, 205) -- 1296
					lb.scaleX = 1 -- 1297
					lb.scaleY = 1 -- 1298
				end -- 1298
			end -- 1298
			i = i + 1 -- 1270
		end -- 1270
	end -- 1270
end -- 1268
return ____exports -- 1268