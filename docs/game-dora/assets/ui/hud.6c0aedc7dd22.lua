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
local COVER_VIDEO_PIN = ".agent/封面动画.ogv" -- 43
local PROLOGUE_VIDEO_FILE = ".agent/720.ogv" -- 47
local PROLOGUE_EXCLUDED_NAME = "游戏前情提要.ogv" -- 48
local PROLOGUE_START_TIMEOUT = 8 -- 49
local PROLOGUE_VIDEO_DELAY = 0.4 -- 50
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
function HUD.prototype.____constructor(self, parent) -- 247
	self.titleMenuEnabled = false -- 199
	self.endingLineLbs = {} -- 248
	self.endingTexId = "" -- 249
	self.flashTimer = 0 -- 250
	self.rewindV = -1 -- 251
	self.coverBaseScale = 1 -- 252
	self.coverSp = nil -- 253
	self.titleNameLb = nil -- 254
	self.menuDraws = {} -- 255
	self.menuLbs = {} -- 256
	self.menuBtns = {} -- 257
	self.menuBtnOk = {} -- 258
	self.menuBtnW = 1 -- 259
	self.menuBtnH = 1 -- 260
	self.menuSel = 0 -- 261
	self.menuFlashT = 0 -- 262
	self.playLock = false -- 263
	self.settingsOpen = false -- 264
	self.particles = {} -- 265
	self.wheelNormalSp = nil -- 266
	self.wheelActiveSp = nil -- 267
	self.wheelDimSp = nil -- 268
	self.wheelMode = "normal" -- 269
	self.prologueVideo = nil -- 270
	self.prologueHintLb = nil -- 271
	self.prologuePlaying = false -- 272
	self.prologueStarted = false -- 273
	self.prologueWaitT = 0 -- 274
	self.prologueDelayT = 0 -- 275
	self.prologueTailT = 0 -- 276
	self.prologueAudio = "" -- 277
	self.guideWhite = false -- 278
	self.prologueOnDone = nil -- 279
	self.onEndingTap = nil -- 280
	self.endingTapGuard = 0 -- 281
	self.hudNode = Node() -- 282
	self.hudNode:addTo(parent) -- 283
	self.flash = DrawNode() -- 284
	self.flash:addTo(self.hudNode) -- 285
	self.rewindDraw = DrawNode() -- 286
	self.rewindDraw:addTo(self.hudNode) -- 287
	self.hud = DrawNode() -- 288
	self.hud:addTo(self.hudNode) -- 289
	self.heartSps = {} -- 291
	self.heartTex = loadTex(HEART_TEX) -- 292
	if self.heartTex ~= nil then -- 292
		do -- 292
			local i = 0 -- 294
			while i < HUD_MAX_HEARTS do -- 294
				local sp = pxSprite(self.heartTex) -- 295
				sp.anchor = Vec2(0, 0) -- 296
				sp.scaleX = HEART_SCALE -- 297
				sp.scaleY = HEART_SCALE -- 298
				sp.visible = false -- 299
				sp:addTo(self.hudNode) -- 300
				local ____self_heartSps_0 = self.heartSps -- 300
				____self_heartSps_0[#____self_heartSps_0 + 1] = sp -- 301
				i = i + 1 -- 294
			end -- 294
		end -- 294
	end -- 294
	local wheelNTex = loadTex(WHEEL_TEX_NORMAL) -- 305
	local wheelATex = loadTex(WHEEL_TEX_ACTIVE) -- 306
	local wheelDTex = loadTex(WHEEL_TEX_DIM) -- 307
	if wheelNTex ~= nil and wheelATex ~= nil and wheelDTex ~= nil then -- 307
		self.wheelNormalSp = self:makeWheelSprite( -- 309
			wheelNTex, -- 309
			WHEEL_PX / math.max(wheelNTex.width, wheelNTex.height) -- 309
		) -- 309
		self.wheelActiveSp = self:makeWheelSprite( -- 310
			wheelATex, -- 310
			WHEEL_PX / math.max(wheelATex.width, wheelATex.height) -- 310
		) -- 310
		self.wheelDimSp = self:makeWheelSprite( -- 311
			wheelDTex, -- 311
			WHEEL_PX / math.max(wheelDTex.width, wheelDTex.height) -- 311
		) -- 311
	end -- 311
	self.wheelDraw = DrawNode() -- 313
	self.wheelDraw:addTo(self.hudNode) -- 314
	local w = View.size.width -- 315
	local h = View.size.height -- 316
	local left = -w / 2 -- 317
	local top = h / 2 -- 318
	local gr = w / 2 - 24 -- 320
	self.guideTitleLb = makePixelLabel( -- 321
		self.hudNode, -- 321
		36, -- 321
		gr, -- 321
		top - 142, -- 321
		1, -- 321
		0.5, -- 321
		ink(0, 0, 0) -- 321
	) -- 321
	setText(self.guideTitleLb, "— 月相轮的指引 —") -- 322
	self.guideMissionLb = makePixelLabel( -- 323
		self.hudNode, -- 323
		30, -- 323
		gr, -- 323
		top - 178, -- 323
		1, -- 323
		1, -- 323
		ink(0, 0, 0) -- 323
	) -- 323
	self.guideStepLb = makePixelLabel( -- 324
		self.hudNode, -- 324
		26, -- 324
		gr, -- 324
		top - 178, -- 324
		1, -- 324
		1, -- 324
		ink(0, 0, 0) -- 324
	) -- 324
	self.hintLb = makeLabel( -- 325
		self.hudNode, -- 325
		18, -- 325
		0, -- 325
		-top + 30, -- 325
		0.5, -- 325
		0.5, -- 325
		Palette.paleInkMid -- 325
	) -- 325
	self.rewindLb = makeLabel( -- 326
		self.hudNode, -- 326
		26, -- 326
		0, -- 326
		96, -- 326
		0.5, -- 326
		0.5, -- 326
		Palette.moonCyan -- 326
	) -- 326
	setText(self.rewindLb, "回溯中…") -- 327
	if self.rewindLb ~= nil then -- 327
		self.rewindLb.visible = false -- 329
	end -- 329
	local cx = w / 2 - 74 -- 331
	self.phaseLb = makeLabel( -- 332
		self.hudNode, -- 332
		17, -- 332
		cx, -- 332
		top - 78, -- 332
		0.5, -- 332
		0.5, -- 332
		Palette.gold -- 332
	) -- 332
	self.loopLb = makeLabel( -- 333
		self.hudNode, -- 333
		15, -- 333
		cx, -- 333
		top - 102, -- 333
		0.5, -- 333
		0.5, -- 333
		Palette.paleInk -- 333
	) -- 333
	self.endingNode = Node() -- 335
	self.endingNode:addTo(parent) -- 336
	self.endingNode.visible = false -- 337
	self.endingBg = DrawNode() -- 338
	self.endingBg:addTo(self.endingNode) -- 339
	self.endingTitleLb = makeLabel( -- 340
		self.endingNode, -- 340
		46, -- 340
		0, -- 340
		top - 150, -- 340
		0.5, -- 340
		0.5, -- 340
		Palette.inkDark -- 340
	) -- 340
	do -- 340
		local i = 0 -- 341
		while i < 8 do -- 341
			local lb = makeLabel( -- 342
				self.endingNode, -- 342
				20, -- 342
				0, -- 342
				top - 224 - i * 34, -- 342
				0.5, -- 342
				0.5, -- 342
				Palette.inkSoft -- 342
			) -- 342
			if lb ~= nil then -- 342
				local ____self_endingLineLbs_1 = self.endingLineLbs -- 342
				____self_endingLineLbs_1[#____self_endingLineLbs_1 + 1] = lb -- 344
			end -- 344
			i = i + 1 -- 341
		end -- 341
	end -- 341
	self.endingHintLb = makeLabel( -- 347
		self.endingNode, -- 347
		20, -- 347
		0, -- 347
		-top + 46, -- 347
		0.5, -- 347
		0.5, -- 347
		Palette.paleInk -- 347
	) -- 347
	setText(self.endingHintLb, "点击 或 按 R 返回标题") -- 348
	local endingTouch = Node() -- 350
	endingTouch.size = Size(w, h) -- 351
	endingTouch.position = Vec2(0, 0) -- 352
	endingTouch.touchEnabled = true -- 353
	endingTouch:addTo(self.endingNode) -- 354
	endingTouch:onTapBegan(function() -- 355
		if self.endingTapGuard > 0 then -- 355
			return -- 357
		end -- 357
		if self.onEndingTap ~= nil then -- 357
			self.onEndingTap() -- 360
		end -- 360
	end) -- 355
	self.endingNode:schedule(function(dt) -- 363
		if self.endingTapGuard > 0 then -- 363
			self.endingTapGuard = self.endingTapGuard - dt -- 365
		end -- 365
		return false -- 367
	end) -- 363
	self.titleNode = Node() -- 370
	self.titleNode:addTo(parent) -- 371
	self.titleNode.visible = false -- 372
	self.titleBg = DrawNode() -- 373
	self.titleBg:addTo(self.titleNode) -- 374
	local videoFile -- 378
	if Content:exist(COVER_VIDEO_PIN) then -- 378
		videoFile = COVER_VIDEO_PIN -- 380
	end -- 380
	if videoFile == nil then -- 380
		local ogvDirs = {"assets/art", ".agent"} -- 383
		for ____, dir in ipairs(ogvDirs) do -- 384
			do -- 384
				local names = Content:getFiles(dir) -- 385
				if names == nil then -- 385
					goto __continue39 -- 386
				end -- 386
				for ____, name in ipairs(names) do -- 387
					do -- 387
						if name == PROLOGUE_EXCLUDED_NAME then -- 387
							goto __continue41 -- 388
						end -- 388
						local ext = #name >= 4 and __TS__StringSubstring(name, #name - 4) or "" -- 389
						if ext == ".ogv" or ext == ".OGV" then -- 389
							videoFile = (dir .. "/") .. name -- 391
							break -- 392
						end -- 392
					end -- 392
					::__continue41:: -- 392
				end -- 392
				if videoFile ~= nil then -- 392
					break -- 395
				end -- 395
			end -- 395
			::__continue39:: -- 395
		end -- 395
	end -- 395
	local ____temp_2 -- 398
	if videoFile ~= nil then -- 398
		____temp_2 = VideoNode(videoFile, true) -- 398
	else -- 398
		____temp_2 = nil -- 398
	end -- 398
	local coverVideo = ____temp_2 -- 398
	if coverVideo ~= nil then -- 398
		local vw = coverVideo.width -- 400
		local vh = coverVideo.height -- 401
		if vw > 0 and vh > 0 then -- 401
			local cs = math.max(w / vw, h / vh) -- 403
			coverVideo.anchor = Vec2(0.5, 0.5) -- 404
			coverVideo.position = Vec2(0, 0) -- 405
			coverVideo.scaleX = cs -- 406
			coverVideo.scaleY = cs -- 407
		end -- 407
		coverVideo:addTo(self.titleNode) -- 409
		self.coverVideo = coverVideo -- 410
		if not self.titleNode.visible then -- 410
			coverVideo:pause() -- 412
		end -- 412
	end -- 412
	if self.coverVideo == nil then -- 412
		self:drawTitleBg(w, h) -- 416
	end -- 416
	self.titleNameLb = self:makeTitleFontLabel(self.titleNode, 74, 0, top - 168) -- 421
	if self.titleNameLb ~= nil then -- 421
		self.titleNameLb.color = Color(255, 255, 255, 255) -- 423
	end -- 423
	local menuTexts = {"PLAY", "时空树仓库", "SETTINGS"} -- 426
	local btnTex = loadTex(TECH_BTN_PATH) -- 427
	if btnTex ~= nil then -- 427
		self.menuBtnW = btnTex.width -- 429
		self.menuBtnH = btnTex.height -- 430
	end -- 430
	local menuX = left + MENU_X_OFF -- 432
	do -- 432
		local i = 0 -- 433
		while i < #MENU_YS do -- 433
			local item = Node() -- 434
			item.position = Vec2(menuX, -h / 2 + MENU_YS[i + 1]) -- 435
			item:addTo(self.titleNode) -- 436
			local d = DrawNode() -- 437
			d:addTo(item) -- 438
			local ____self_menuDraws_3 = self.menuDraws -- 438
			____self_menuDraws_3[#____self_menuDraws_3 + 1] = d -- 439
			if btnTex ~= nil then -- 439
				local sp = Sprite(btnTex) -- 441
				if sp ~= nil then -- 441
					sp.anchor = Vec2(0.5, 0.5) -- 443
					sp.position = Vec2(0, 0) -- 444
					sp.scaleX = MENU_W / self.menuBtnW -- 445
					sp.scaleY = MENU_H / self.menuBtnH -- 446
					sp.opacity = 0.8 -- 447
					sp:addTo(item) -- 448
					local ____self_menuBtns_4 = self.menuBtns -- 448
					____self_menuBtns_4[#____self_menuBtns_4 + 1] = sp -- 449
					local ____self_menuBtnOk_5 = self.menuBtnOk -- 449
					____self_menuBtnOk_5[#____self_menuBtnOk_5 + 1] = true -- 450
				else -- 450
					local ____self_menuBtnOk_6 = self.menuBtnOk -- 450
					____self_menuBtnOk_6[#____self_menuBtnOk_6 + 1] = false -- 452
				end -- 452
			else -- 452
				local ____self_menuBtnOk_7 = self.menuBtnOk -- 452
				____self_menuBtnOk_7[#____self_menuBtnOk_7 + 1] = false -- 455
			end -- 455
			local lb = makeLabel( -- 457
				item, -- 457
				27, -- 457
				0, -- 457
				0, -- 457
				0.5, -- 457
				0.5, -- 457
				ink(255, 255, 255, 255) -- 457
			) -- 457
			setText(lb, menuTexts[i + 1]) -- 458
			if lb ~= nil then -- 458
				local ____self_menuLbs_8 = self.menuLbs -- 458
				____self_menuLbs_8[#____self_menuLbs_8 + 1] = lb -- 460
			end -- 460
			i = i + 1 -- 433
		end -- 433
	end -- 433
	self.particlesDraw = DrawNode() -- 464
	self.particlesDraw:addTo(self.titleNode) -- 465
	do -- 465
		local i = 0 -- 466
		while i < TITLE_PARTICLE_N do -- 466
			local ____self_particles_9 = self.particles -- 466
			____self_particles_9[#____self_particles_9 + 1] = { -- 467
				x = left + 90 + (w - 180) / TITLE_PARTICLE_N * i + math.random() * 60, -- 468
				y = -top + math.random() * h, -- 469
				vy = -(14 + math.random() * 14), -- 470
				r = 2 + math.random() * 1.6, -- 471
				ph = math.random() * math.pi * 2, -- 472
				gold = i % 2 == 0 -- 473
			} -- 473
			i = i + 1 -- 466
		end -- 466
	end -- 466
	self.settingsNode = Node() -- 477
	self.settingsNode:addTo(self.titleNode) -- 478
	self.settingsNode.visible = false -- 479
	makeTechPanel(self.settingsNode, PANEL_W, PANEL_H) -- 480
	local panelBg = DrawNode() -- 481
	panelBg:addTo(self.settingsNode) -- 482
	self:makePanelLabel( -- 483
		panelBg, -- 483
		24, -- 483
		0, -- 483
		PANEL_H / 2 - 44, -- 483
		"操 作 键 位", -- 483
		ink(255, 255, 255, 255) -- 483
	) -- 483
	do -- 483
		local i = 0 -- 484
		while i < #SETTINGS_KEYS do -- 484
			self:makePanelLabel( -- 485
				panelBg, -- 485
				19, -- 485
				0, -- 485
				PANEL_H / 2 - 86 - i * 32, -- 485
				SETTINGS_KEYS[i + 1], -- 485
				ink(255, 255, 255, 255) -- 485
			) -- 485
			i = i + 1 -- 484
		end -- 484
	end -- 484
	self:makePanelLabel( -- 487
		panelBg, -- 487
		16, -- 487
		0, -- 487
		-PANEL_H / 2 + 34, -- 487
		"Esc 或再次点击 SETTINGS 关闭", -- 487
		ink(255, 255, 255, 255) -- 487
	) -- 487
	local touchNode = Node() -- 489
	touchNode.size = Size(w, h) -- 490
	touchNode.position = Vec2(0, 0) -- 491
	touchNode.touchEnabled = true -- 492
	touchNode:addTo(self.titleNode) -- 493
	touchNode:onTapBegan(function(touch) -- 494
		self:onTitleTap(touch, w, h) -- 495
	end) -- 494
	self.prologueNode = Node() -- 499
	self.prologueNode:addTo(parent) -- 500
	self.prologueNode.visible = false -- 501
	self.prologueBlack = DrawNode() -- 502
	self.prologueBlack:addTo(self.prologueNode) -- 503
	self.prologueBlack:drawPolygon( -- 504
		self:screenVerts(w, h), -- 504
		Color(0, 0, 0, 255) -- 504
	) -- 504
	if Content:exist(PROLOGUE_VIDEO_FILE) then -- 504
		local pv = VideoNode(PROLOGUE_VIDEO_FILE, false) -- 506
		if pv ~= nil then -- 506
			local pvw = pv.width -- 508
			local pvh = pv.height -- 509
			if pvw > 0 and pvh > 0 then -- 509
				local ps = math.max(w / pvw, h / pvh) -- 511
				pv.anchor = Vec2(0.5, 0.5) -- 512
				pv.position = Vec2(0, 0) -- 513
				pv.scaleX = ps -- 514
				pv.scaleY = ps -- 515
			end -- 515
			pv:pause() -- 520
			pv.visible = true -- 521
			pv:addTo(self.prologueNode) -- 522
			self.prologueVideo = pv -- 523
		end -- 523
	end -- 523
	self.prologueCard = Node() -- 528
	self.prologueCard.visible = false -- 529
	self.prologueCard:addTo(self.prologueNode) -- 530
	local cardBg = DrawNode() -- 531
	cardBg:addTo(self.prologueCard) -- 532
	cardBg:drawPolygon( -- 533
		self:screenVerts(w, h), -- 533
		Color(0, 0, 0, 255) -- 533
	) -- 533
	self.prologueCardTitle = makeLabel( -- 534
		self.prologueCard, -- 534
		46, -- 534
		0, -- 534
		52, -- 534
		0.5, -- 534
		0.5, -- 534
		ink(255, 236, 200, 255) -- 534
	) -- 534
	if self.prologueCardTitle ~= nil then -- 534
		setText(self.prologueCardTitle, "衍 月 · 八 相") -- 536
		self.prologueCardTitle.opacity = 0 -- 537
	end -- 537
	self.prologueCardSub = makeLabel( -- 539
		self.prologueCard, -- 539
		21, -- 539
		0, -- 539
		-14, -- 539
		0.5, -- 539
		0.5, -- 539
		ink(255, 255, 255, 255) -- 539
	) -- 539
	if self.prologueCardSub ~= nil then -- 539
		setText(self.prologueCardSub, "以八相为约 · 满月为限") -- 541
		self.prologueCardSub.opacity = 0 -- 542
	end -- 542
	self.prologueHintLb = makeLabel( -- 544
		self.prologueNode, -- 544
		18, -- 544
		0, -- 544
		-h / 2 + 34, -- 544
		0.5, -- 544
		0.5, -- 544
		ink(255, 255, 255, 255) -- 544
	) -- 544
	setText(self.prologueHintLb, "Esc / 点击画面跳过") -- 545
	local prologueTouch = Node() -- 546
	prologueTouch.size = Size(w, h) -- 547
	prologueTouch.position = Vec2(0, 0) -- 548
	prologueTouch.touchEnabled = true -- 549
	prologueTouch:addTo(self.prologueNode) -- 550
	prologueTouch:onTapBegan(function() -- 551
		self:finishPrologue() -- 552
	end) -- 551
	self.prologueNode:onKeyDown(function(key) -- 554
		if self.prologuePlaying and (key == "Escape" or key == "Space" or key == "Return") then -- 554
			self:finishPrologue() -- 556
		end -- 556
	end) -- 554
	self.pauseNode = Node() -- 560
	self.pauseNode:addTo(parent) -- 561
	self.pauseNode.visible = false -- 562
	makeTechPanel(self.pauseNode, PANEL_W, PANEL_H) -- 563
	local pausePanel = DrawNode() -- 564
	pausePanel:addTo(self.pauseNode) -- 565
	self:makePanelLabel( -- 566
		pausePanel, -- 566
		24, -- 566
		0, -- 566
		PANEL_H / 2 - 44, -- 566
		"暂 停", -- 566
		ink(255, 255, 255, 255) -- 566
	) -- 566
	do -- 566
		local i = 0 -- 567
		while i < #PAUSE_KEYS do -- 567
			self:makePanelLabel( -- 568
				pausePanel, -- 568
				18, -- 568
				0, -- 568
				PANEL_H / 2 - 88 - i * 28, -- 568
				PAUSE_KEYS[i + 1], -- 568
				ink(255, 255, 255, 255) -- 568
			) -- 568
			i = i + 1 -- 567
		end -- 567
	end -- 567
	self:makePanelLabel( -- 571
		pausePanel, -- 571
		20, -- 571
		0, -- 571
		-172, -- 571
		"【 回到标题 】", -- 571
		ink(255, 236, 200, 255) -- 571
	) -- 571
	self:makePanelLabel( -- 572
		pausePanel, -- 572
		16, -- 572
		0, -- 572
		-206, -- 572
		"Esc 继续游戏", -- 572
		ink(255, 255, 255, 255) -- 572
	) -- 572
	local pauseTouch = Node() -- 574
	pauseTouch.size = Size(w, h) -- 575
	pauseTouch.position = Vec2(0, 0) -- 576
	pauseTouch.touchEnabled = true -- 577
	pauseTouch:addTo(self.pauseNode) -- 578
	pauseTouch:onTapBegan(function(touch) -- 579
		local ____local = touch.location -- 580
		local cx = ____local.x - w / 2 -- 581
		local cy = ____local.y - h / 2 -- 582
		if math.abs(cx) <= 160 and cy >= -194 and cy <= -150 and self.onReturnTitle ~= nil then -- 582
			self.onReturnTitle() -- 584
		end -- 584
	end) -- 579
end -- 247
function HUD.prototype.rectVerts(self, x, y, w, h) -- 589
	return { -- 590
		Vec2(x, y), -- 590
		Vec2(x + w, y), -- 590
		Vec2(x + w, y + h), -- 590
		Vec2(x, y + h) -- 590
	} -- 590
end -- 589
function HUD.prototype.screenVerts(self, w, h) -- 593
	return self:rectVerts(-w / 2, -h / 2, w, h) -- 594
end -- 593
function HUD.prototype.circle(self, draw, cx, cy, r, segs, width, color, from, sweep) -- 597
	do -- 597
		local i = 0 -- 598
		while i < segs do -- 598
			local a0 = from + i / segs * sweep -- 599
			local a1 = from + (i + 1) / segs * sweep -- 600
			draw:drawSegment( -- 601
				Vec2( -- 601
					cx + math.cos(a0) * r, -- 601
					cy + math.sin(a0) * r -- 601
				), -- 601
				Vec2( -- 601
					cx + math.cos(a1) * r, -- 601
					cy + math.sin(a1) * r -- 601
				), -- 601
				width, -- 601
				col(color) -- 601
			) -- 601
			i = i + 1 -- 598
		end -- 598
	end -- 598
end -- 597
function HUD.prototype.diamond(self, draw, x, y, s, fill, bw, border) -- 605
	draw:drawPolygon( -- 606
		{ -- 606
			Vec2(x, y + s), -- 606
			Vec2(x + s, y), -- 606
			Vec2(x, y - s), -- 606
			Vec2(x - s, y) -- 606
		}, -- 606
		col(fill), -- 606
		bw, -- 606
		col(border) -- 606
	) -- 606
end -- 605
function HUD.prototype.makeTitleFontLabel(self, parent, size, x, y) -- 609
	do -- 609
		local i = 0 -- 610
		while i < #TITLE_FONTS do -- 610
			local lb = Label(TITLE_FONTS[i + 1], size) -- 611
			if lb ~= nil then -- 611
				lb.anchor = Vec2(0.5, 0.5) -- 613
				lb.position = Vec2(x, y) -- 614
				lb:addTo(parent) -- 615
				return lb -- 616
			end -- 616
			i = i + 1 -- 610
		end -- 610
	end -- 610
	return makeLabel( -- 619
		parent, -- 619
		size - 4, -- 619
		x, -- 619
		y, -- 619
		0.5, -- 619
		0.5, -- 619
		Palette.paleInk -- 619
	) -- 619
end -- 609
function HUD.prototype.makeWheelSprite(self, tex, scale) -- 622
	local sp = Sprite(tex) -- 623
	if sp == nil then -- 623
		return nil -- 625
	end -- 625
	sp.anchor = Vec2(0.5, 0.5) -- 627
	sp.scaleX = scale -- 628
	sp.scaleY = scale -- 629
	sp.visible = false -- 630
	sp:addTo(self.hudNode) -- 631
	return sp -- 632
end -- 622
function HUD.prototype.makePanelLabel(self, parent, size, x, y, text, c) -- 635
	local lb = Label(PANEL_FONT, size) -- 636
	if lb == nil then -- 636
		lb = makeLabel( -- 638
			parent, -- 638
			size, -- 638
			x, -- 638
			y, -- 638
			0.5, -- 638
			0.5, -- 638
			c -- 638
		) -- 638
	else -- 638
		lb.anchor = Vec2(0.5, 0.5) -- 640
		lb.position = Vec2(x, y) -- 641
		lb.color = Color(c.r, c.g, c.b, c.a) -- 642
		lb:addTo(parent) -- 643
	end -- 643
	setText(lb, text) -- 645
end -- 635
function HUD.prototype.updatePixelLife(self, st, x0, rowY) -- 649
	if self.heartTex == nil then -- 649
		return false -- 651
	end -- 651
	local bottomY = rowY - 24 -- 653
	local step = st.maxLife > 5 and 36 or HEART_STEP -- 655
	local barX = x0 + math.min(st.maxLife, HUD_MAX_HEARTS) * step + 16 -- 656
	local ratio = st.maxLife > 0 and math.max( -- 657
		0, -- 657
		math.min(1, st.heroineLife / st.maxLife) -- 657
	) or 0 -- 657
	do -- 657
		local i = 0 -- 658
		while i < #self.heartSps do -- 658
			local sp = self.heartSps[i + 1] -- 659
			local active = i < st.maxLife -- 660
			sp.visible = active -- 661
			if active then -- 661
				sp.position = Vec2(x0 + i * step, bottomY) -- 663
				sp.color = i < st.heroineLife and Color(255, 255, 255, 255) or Color(255, 255, 255, 70) -- 664
			end -- 664
			i = i + 1 -- 658
		end -- 658
	end -- 658
	self.hud:drawPolygon( -- 667
		self:rectVerts(barX, bottomY, BAR_W, BAR_H), -- 667
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 245)), -- 667
		2, -- 667
		col(Palette.inkDark) -- 667
	) -- 667
	if ratio > 0 then -- 667
		local fw = (BAR_W - BAR_PAD * 2) * ratio -- 669
		self.hud:drawPolygon( -- 670
			self:rectVerts(barX + BAR_PAD, bottomY + BAR_PAD, fw, BAR_H - BAR_PAD * 2), -- 670
			col(Palette.vermilion) -- 670
		) -- 670
	end -- 670
	return true -- 672
end -- 649
function HUD.prototype.drawTitleBg(self, w, h) -- 676
	self.titleBg:clear() -- 677
	self.titleBg:drawPolygon( -- 678
		self:screenVerts(w, h), -- 678
		Palette.paper -- 678
	) -- 678
	local mx = w / 2 - 190 -- 679
	local my = h / 2 - 170 -- 680
	self:circle( -- 681
		self.titleBg, -- 681
		mx, -- 681
		my, -- 681
		96, -- 681
		40, -- 681
		2, -- 681
		Palette.goldSoft, -- 681
		0, -- 681
		math.pi * 2 -- 681
	) -- 681
	self.titleBg:drawDot( -- 682
		Vec2(mx, my), -- 682
		84, -- 682
		col(Palette.moonWhite) -- 682
	) -- 682
	do -- 682
		local i = 0 -- 683
		while i < 4 do -- 683
			local x0 = -w / 2 + i * (w / 3.2) -- 684
			self.titleBg:drawSegment( -- 685
				Vec2(x0, -h / 2 + 40 + i * 14), -- 685
				Vec2(x0 + w / 3.6, -h / 2 + 26 + i * 14), -- 685
				26 + i * 8, -- 685
				col(Palette.paleInkFar) -- 685
			) -- 685
			i = i + 1 -- 683
		end -- 683
	end -- 683
end -- 676
function HUD.prototype.onTitleTap(self, touch, w, h) -- 690
	if not self.titleMenuEnabled then -- 690
		return -- 692
	end -- 692
	local x = touch.location.x - w / 2 -- 694
	local y = touch.location.y - h / 2 -- 695
	local menuX = -w / 2 + MENU_X_OFF -- 696
	do -- 696
		local i = 0 -- 697
		while i < #MENU_YS do -- 697
			local yy = -h / 2 + MENU_YS[i + 1] -- 698
			if math.abs(x - menuX) <= MENU_HALF_X and math.abs(y - yy) <= MENU_HALF_Y then -- 698
				if self.settingsOpen then -- 698
					if i == 2 then -- 698
						self:closeSettings() -- 702
					end -- 702
					return -- 704
				end -- 704
				if self.menuSel == i then -- 704
					self:confirmCurrent() -- 707
				else -- 707
					self.menuSel = i -- 709
				end -- 709
				return -- 711
			end -- 711
			i = i + 1 -- 697
		end -- 697
	end -- 697
end -- 690
function HUD.prototype.confirmCurrent(self) -- 716
	if self.playLock then -- 716
		return -- 718
	end -- 718
	if self.menuSel == 0 then -- 718
		self.playLock = true -- 721
		self.menuFlashT = MENU_FLASH_T -- 722
		local cb = self.onPlayConfirmed -- 723
		if cb ~= nil then -- 723
			cb() -- 725
		end -- 725
	elseif self.menuSel == 1 then -- 725
		local gb = self.onGalleryConfirmed -- 728
		if gb ~= nil then -- 728
			gb() -- 730
		end -- 730
	else -- 730
		self:openSettings() -- 733
	end -- 733
end -- 716
function HUD.prototype.openSettings(self) -- 737
	self.settingsOpen = true -- 738
	self.settingsNode.visible = true -- 739
end -- 737
function HUD.prototype.closeSettings(self) -- 742
	self.settingsOpen = false -- 743
	self.settingsNode.visible = false -- 744
end -- 742
function HUD.prototype.flashDamage(self) -- 747
	self.flashTimer = FLASH_TIME -- 748
end -- 747
function HUD.prototype.setRewind(self, v) -- 751
	self.rewindV = v -- 752
	if self.rewindLb ~= nil then -- 752
		self.rewindLb.visible = v >= 0 -- 754
	end -- 754
end -- 751
function HUD.prototype.showEnding(self, id) -- 758
	local e = ENDINGS[id] -- 759
	if e == nil then -- 759
		return -- 761
	end -- 761
	local w = View.size.width -- 763
	local h = View.size.height -- 764
	self.endingBg:clear() -- 765
	self.endingBg:drawPolygon( -- 766
		self:screenVerts(w, h), -- 766
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 242)) -- 766
	) -- 766
	self.endingBg:drawPolygon( -- 767
		self:rectVerts(-w / 2 + 14, -h / 2 + 14, w - 28, h - 28), -- 767
		col(NO_FILL), -- 767
		1, -- 767
		col(Palette.goldSoft) -- 767
	) -- 767
	setText(self.endingTitleLb, e.title) -- 768
	do -- 768
		local i = 0 -- 769
		while i < #self.endingLineLbs do -- 769
			setText(self.endingLineLbs[i + 1], i < #e.lines and e.lines[i + 1] or "") -- 770
			i = i + 1 -- 769
		end -- 769
	end -- 769
	local cands = ENDING_IMAGES[id] -- 774
	if cands ~= nil then -- 774
		local tex -- 776
		local used = "" -- 777
		for ____, p in ipairs(cands) do -- 778
			tex = Texture2D(p) -- 779
			if tex ~= nil then -- 779
				used = p -- 781
				break -- 782
			end -- 782
		end -- 782
		if tex ~= nil and used ~= "" then -- 782
			if self.endingSp == nil or self.endingTexId ~= used then -- 782
				local oldSp = self.endingSp -- 787
				if oldSp ~= nil then -- 787
					oldSp:removeFromParent(true) -- 789
				end -- 789
				self.endingSp = nil -- 791
				local sp = Sprite(tex) -- 792
				if sp ~= nil then -- 792
					sp:addTo(self.endingNode) -- 794
					sp.position = Vec2(0, 0) -- 795
					sp.anchor = Vec2(0.5, 0.5) -- 796
					self.endingSp = sp -- 797
					self.endingTexId = used -- 798
				end -- 798
			end -- 798
			if self.endingSp ~= nil then -- 798
				local iw = tex.width -- 802
				local ih = tex.height -- 803
				if iw > 0 and ih > 0 then -- 803
					local s = math.max(w / iw, h / ih) -- 805
					self.endingSp.scaleX = s -- 806
					self.endingSp.scaleY = s -- 807
				end -- 807
				self.endingSp.visible = true -- 809
			end -- 809
		else -- 809
			if self.endingSp ~= nil then -- 809
				self.endingSp.visible = false -- 813
			end -- 813
		end -- 813
	elseif self.endingSp ~= nil then -- 813
		self.endingSp.visible = false -- 817
	end -- 817
	self.endingTapGuard = 0.8 -- 819
	self.endingNode.visible = true -- 820
end -- 758
function HUD.prototype.hideEnding(self) -- 823
	self.endingNode.visible = false -- 824
end -- 823
function HUD.prototype.setTitleVisible(self, v) -- 827
	self.titleNode.visible = v -- 828
	if self.coverVideo ~= nil then -- 828
		if v then -- 828
			self.coverVideo:resume() -- 832
		else -- 832
			self.coverVideo:pause() -- 834
		end -- 834
	end -- 834
	if v then -- 834
		self.playLock = false -- 839
		self.menuSel = 0 -- 840
		self.menuFlashT = 0 -- 841
		if self.settingsOpen then -- 841
			self:closeSettings() -- 843
		end -- 843
	end -- 843
end -- 827
function HUD.prototype.createPrologueVideo(self) -- 851
	local pv = VideoNode(PROLOGUE_VIDEO_FILE, false) -- 852
	if pv == nil then -- 852
		return nil -- 854
	end -- 854
	local vw = View.size.width -- 856
	local vh = View.size.height -- 857
	if pv.width > 0 and pv.height > 0 then -- 857
		local ps = math.max(vw / pv.width, vh / pv.height) -- 859
		pv.anchor = Vec2(0.5, 0.5) -- 860
		pv.position = Vec2(0, 0) -- 861
		pv.scaleX = ps -- 862
		pv.scaleY = ps -- 863
	end -- 863
	pv.visible = true -- 865
	pv:addTo(self.prologueNode) -- 866
	self.prologueVideo = pv -- 867
	return pv -- 868
end -- 851
function HUD.prototype.playPrologue(self, onDone) -- 871
	local oldVid = self.prologueVideo -- 875
	if oldVid ~= nil then -- 875
		oldVid:removeFromParent() -- 877
		self.prologueVideo = nil -- 878
	end -- 878
	if self.prologuePlaying then -- 878
		return -- 881
	end -- 881
	self.prologuePlaying = true -- 883
	self.prologueStarted = false -- 884
	self.prologueWaitT = 0 -- 885
	self.prologueDelayT = 0 -- 886
	self.prologueTailT = 0 -- 887
	if self.prologueCard ~= nil then -- 887
		self.prologueCard.visible = false -- 889
	end -- 889
	if self.prologueCardTitle ~= nil then -- 889
		self.prologueCardTitle.opacity = 0 -- 892
	end -- 892
	if self.prologueCardSub ~= nil then -- 892
		self.prologueCardSub.opacity = 0 -- 895
	end -- 895
	self.prologueOnDone = onDone -- 897
	self.prologueNode.visible = true -- 898
	local coverVid = self.coverVideo -- 900
	if coverVid ~= nil then -- 900
		coverVid:pause() -- 902
	end -- 902
	self.prologueAudio = "" -- 905
	do -- 905
		local i = 0 -- 906
		while i < #PROLOGUE_AUDIO_FILES do -- 906
			local f = PROLOGUE_AUDIO_FILES[i + 1] -- 907
			if Content:exist(f) then -- 907
				self.prologueAudio = f -- 909
				break -- 910
			end -- 910
			i = i + 1 -- 906
		end -- 906
	end -- 906
	if self.prologueAudio ~= "" then -- 906
		stopBgm(0.15) -- 914
		do -- 914
			local function ____catch(e) -- 914
				local ____ = e -- 914
			end -- 914
			local ____try, ____hasReturned = pcall(function() -- 914
				Audio:playStream(self.prologueAudio, false, 0.15) -- 916
			end) -- 916
			if not ____try then -- 916
				____catch(____hasReturned) -- 916
			end -- 916
		end -- 916
	end -- 916
	self.prologueNode:schedule(function(dt) -- 923
		if not self.prologuePlaying then -- 923
			return true -- 925
		end -- 925
		if self.prologueVideo == nil then -- 925
			self.prologueDelayT = self.prologueDelayT + dt -- 928
			if self.prologueDelayT < PROLOGUE_VIDEO_DELAY then -- 928
				return false -- 930
			end -- 930
			local pv = self:createPrologueVideo() -- 932
			if pv == nil then -- 932
				self:finishPrologue() -- 934
				return true -- 935
			end -- 935
			self.prologueWaitT = 0 -- 937
			return false -- 938
		end -- 938
		local video = self.prologueVideo -- 940
		if not self.prologueStarted then -- 940
			if not video.paused then -- 940
				self.prologueStarted = true -- 943
			else -- 943
				self.prologueWaitT = self.prologueWaitT + dt -- 945
				if self.prologueWaitT > PROLOGUE_START_TIMEOUT then -- 945
					self:finishPrologue() -- 947
					return true -- 948
				end -- 948
			end -- 948
		elseif video.paused then -- 948
			self.prologueTailT = self.prologueTailT + dt -- 954
			if self.prologueCard ~= nil then -- 954
				self.prologueCard.visible = self.prologueTailT > 0.05 -- 957
			end -- 957
			local cardU = math.min(1, self.prologueTailT / 1.2) -- 959
			local cardA = math.floor(cardU * cardU * 255 + 0.5) -- 960
			if self.prologueCardTitle ~= nil then -- 960
				self.prologueCardTitle.opacity = cardA -- 962
			end -- 962
			if self.prologueCardSub ~= nil then -- 962
				self.prologueCardSub.opacity = cardA -- 965
			end -- 965
			if self.prologueTailT >= PROLOGUE_AUDIO_TAIL then -- 965
				self:finishPrologue() -- 968
				return true -- 969
			end -- 969
			return false -- 971
		else -- 971
			self.prologueTailT = 0 -- 974
			if self.prologueCard ~= nil then -- 974
				self.prologueCard.visible = false -- 976
			end -- 976
		end -- 976
		return false -- 979
	end) -- 923
end -- 871
function HUD.prototype.finishPrologue(self) -- 984
	if not self.prologuePlaying then -- 984
		return -- 986
	end -- 986
	self.prologuePlaying = false -- 988
	local cb = self.prologueOnDone -- 989
	self.prologueOnDone = nil -- 990
	local video = self.prologueVideo -- 991
	if video ~= nil then -- 991
		video:pause() -- 993
	end -- 993
	self.prologueNode.visible = false -- 995
	if self.prologueAudio ~= "" then -- 995
		self.prologueAudio = "" -- 998
		do -- 998
			local function ____catch(e) -- 998
				local ____ = e -- 998
			end -- 998
			local ____try, ____hasReturned = pcall(function() -- 998
				Audio:stopStream(0.4) -- 1000
			end) -- 1000
			if not ____try then -- 1000
				____catch(____hasReturned) -- 1000
			end -- 1000
		end -- 1000
		playBgm("cover") -- 1004
	end -- 1004
	local coverVid = self.coverVideo -- 1006
	if coverVid ~= nil and self.titleNode.visible then -- 1006
		coverVid:resume() -- 1008
	end -- 1008
	if cb ~= nil then -- 1008
		cb() -- 1011
	end -- 1011
end -- 984
function HUD.prototype.setPauseVisible(self, v) -- 1015
	self.pauseNode.visible = v -- 1016
end -- 1015
function HUD.prototype.setMoonWheel(self, mode) -- 1020
	self.wheelMode = mode -- 1021
	local nSp = self.wheelNormalSp -- 1022
	local aSp = self.wheelActiveSp -- 1023
	local dSp = self.wheelDimSp -- 1024
	if nSp ~= nil and aSp ~= nil and dSp ~= nil then -- 1024
		nSp.visible = mode == "normal" -- 1026
		aSp.visible = mode == "active" -- 1027
		dSp.visible = mode == "dim" -- 1028
	end -- 1028
end -- 1020
function HUD.prototype.handleTitleKey(self, key) -- 1033
	if not self.titleMenuEnabled or self.prologuePlaying then -- 1033
		return -- 1035
	end -- 1035
	if key == "Escape" then -- 1035
		if self.settingsOpen then -- 1035
			self:closeSettings() -- 1039
		end -- 1039
		return -- 1041
	end -- 1041
	if self.settingsOpen then -- 1041
		return -- 1045
	end -- 1045
	local n = 3 -- 1047
	if key == "W" or key == "Up" then -- 1047
		self.menuSel = (self.menuSel + n - 1) % n -- 1049
	elseif key == "S" or key == "Down" then -- 1049
		self.menuSel = (self.menuSel + 1) % n -- 1051
	elseif key == "Return" or key == "Space" then -- 1051
		self:confirmCurrent() -- 1053
	end -- 1053
end -- 1033
function HUD.prototype.update(self, dt, args) -- 1057
	local st = args.state -- 1058
	local w = View.size.width -- 1059
	local h = View.size.height -- 1060
	local top = h / 2 -- 1061
	self.hud:clear() -- 1062
	local baseX = -w / 2 + 44 -- 1064
	local rowY = top - 44 -- 1065
	local pxLife = self:updatePixelLife(st, baseX - 4, rowY) -- 1066
	if not pxLife then -- 1066
		do -- 1066
			local i = 0 -- 1068
			while i < st.maxLife do -- 1068
				local x = baseX + i * 30 -- 1069
				if i < st.heroineLife then -- 1069
					self:diamond( -- 1071
						self.hud, -- 1071
						x, -- 1071
						rowY, -- 1071
						12, -- 1071
						Palette.vermilion, -- 1071
						2, -- 1071
						Palette.inkDark -- 1071
					) -- 1071
				else -- 1071
					self:diamond( -- 1073
						self.hud, -- 1073
						x, -- 1073
						rowY, -- 1073
						12, -- 1073
						NO_FILL, -- 1073
						2, -- 1073
						Palette.inkFaint -- 1073
					) -- 1073
				end -- 1073
				i = i + 1 -- 1068
			end -- 1068
		end -- 1068
	end -- 1068
	local ix0 = pxLife and baseX - 4 + math.min(st.maxLife, HUD_MAX_HEARTS) * (st.maxLife > 5 and 36 or HEART_STEP) + 16 + BAR_W + 16 or baseX + st.maxLife * 30 + 26 -- 1077
	do -- 1077
		local i = 0 -- 1080
		while i < st.maxSwordIntent do -- 1080
			local x = ix0 + i * 16 -- 1081
			if i < st.swordIntent then -- 1081
				self.hud:drawSegment( -- 1083
					Vec2(x, rowY - 10), -- 1083
					Vec2(x, rowY + 10), -- 1083
					4, -- 1083
					col(Palette.moonCyan) -- 1083
				) -- 1083
			else -- 1083
				self.hud:drawSegment( -- 1085
					Vec2(x, rowY - 10), -- 1085
					Vec2(x, rowY + 10), -- 1085
					2, -- 1085
					col(Palette.inkFaint) -- 1085
				) -- 1085
			end -- 1085
			i = i + 1 -- 1080
		end -- 1080
	end -- 1080
	setText(self.phaseLb, st.phaseIndex >= 0 and st.phaseIndex < #PHASE_NAMES and PHASE_NAMES[st.phaseIndex + 1] or "") -- 1088
	setText( -- 1089
		self.loopLb, -- 1089
		("第" .. tostring(st.loopIndex + 1)) .. "周目" -- 1089
	) -- 1089
	local missionLb = self.guideMissionLb -- 1091
	local stepLb = self.guideStepLb -- 1092
	setText( -- 1093
		missionLb, -- 1093
		wrapCjk((("「" .. args.floorName) .. "」") .. args.mission, 13) -- 1093
	) -- 1093
	setText( -- 1094
		stepLb, -- 1094
		wrapCjk(args.objective, 14) -- 1094
	) -- 1094
	if missionLb ~= nil and stepLb ~= nil then -- 1094
		local mh = missionLb.height -- 1096
		stepLb.y = missionLb.y - (mh > 0 and mh or 30) - 8 -- 1097
	end -- 1097
	local gw = args.guideLight == true -- 1100
	if gw ~= self.guideWhite then -- 1100
		self.guideWhite = gw -- 1102
		local c = gw and Color(255, 255, 255, 255) or Color(0, 0, 0, 255) -- 1103
		if self.guideTitleLb ~= nil then -- 1103
			self.guideTitleLb.color = c -- 1105
		end -- 1105
		if missionLb ~= nil then -- 1105
			missionLb.color = c -- 1108
		end -- 1108
		if stepLb ~= nil then -- 1108
			stepLb.color = c -- 1111
		end -- 1111
	end -- 1111
	setText(self.hintLb, args.hint) -- 1114
	local boss = args.boss -- 1116
	if boss ~= nil and not boss.dead and boss.maxHp > 0 then -- 1116
		local bw = 520 -- 1118
		local bx = -bw / 2 -- 1119
		local by = -top + 66 -- 1120
		self.hud:drawPolygon( -- 1121
			self:rectVerts(bx, by, bw, 12), -- 1121
			col(NO_FILL), -- 1121
			2, -- 1121
			col(Palette.inkDark) -- 1121
		) -- 1121
		local frac = math.max( -- 1122
			0, -- 1122
			math.min(1, boss.hp / boss.maxHp) -- 1122
		) -- 1122
		if frac > 0 then -- 1122
			self.hud:drawPolygon( -- 1124
				self:rectVerts(bx + 2, by + 2, (bw - 4) * frac, 8), -- 1124
				col(Palette.vermilion) -- 1124
			) -- 1124
		end -- 1124
	end -- 1124
	local wheelCx = w / 2 - 74 -- 1128
	local wheelCy = top - 40 -- 1129
	local nSp = self.wheelNormalSp -- 1130
	local aSp = self.wheelActiveSp -- 1131
	local dSp = self.wheelDimSp -- 1132
	if nSp ~= nil and aSp ~= nil and dSp ~= nil then -- 1132
		nSp.position = Vec2(wheelCx, wheelCy) -- 1134
		aSp.position = Vec2(wheelCx, wheelCy) -- 1135
		dSp.position = Vec2(wheelCx, wheelCy) -- 1136
		nSp.visible = self.wheelMode == "normal" -- 1137
		aSp.visible = self.wheelMode == "active" -- 1138
		dSp.visible = self.wheelMode == "dim" -- 1139
		self.wheelDraw:clear() -- 1140
	else -- 1140
		self.wheelDraw:clear() -- 1142
		self:circle( -- 1143
			self.wheelDraw, -- 1143
			wheelCx, -- 1143
			wheelCy, -- 1143
			22, -- 1143
			28, -- 1143
			2, -- 1143
			self.wheelMode == "active" and Palette.moonWhite or Palette.gold, -- 1143
			0, -- 1143
			math.pi * 2 -- 1143
		) -- 1143
	end -- 1143
	self.flash:clear() -- 1146
	if self.flashTimer > 0 then -- 1146
		self.flashTimer = math.max(0, self.flashTimer - dt) -- 1148
		local a = math.floor(255 * 0.35 * (self.flashTimer / FLASH_TIME)) -- 1149
		self.flash:drawPolygon( -- 1150
			self:screenVerts(w, h), -- 1150
			col(ink(Palette.vermilion.r, Palette.vermilion.g, Palette.vermilion.b, a)) -- 1150
		) -- 1150
	end -- 1150
	self.rewindDraw:clear() -- 1153
	if self.rewindV >= 0 then -- 1153
		local v = math.max( -- 1155
			0, -- 1155
			math.min(1, self.rewindV) -- 1155
		) -- 1155
		self.rewindDraw:drawPolygon( -- 1156
			self:screenVerts(w, h), -- 1156
			col(Palette.mist) -- 1156
		) -- 1156
		self:circle( -- 1157
			self.rewindDraw, -- 1157
			0, -- 1157
			0, -- 1157
			46, -- 1157
			36, -- 1157
			4, -- 1157
			Palette.moonCyan, -- 1157
			-math.pi / 2, -- 1157
			v * math.pi * 2 -- 1157
		) -- 1157
	end -- 1157
	if args.fade ~= nil and args.fade > 0 then -- 1157
		local f = math.max( -- 1161
			0, -- 1161
			math.min(1, args.fade) -- 1161
		) -- 1161
		self.hud:drawPolygon( -- 1162
			self:screenVerts(w, h), -- 1162
			col(ink( -- 1162
				6, -- 1162
				8, -- 1162
				16, -- 1162
				math.floor(255 * f) -- 1162
			)) -- 1162
		) -- 1162
	end -- 1162
	if self.titleNode.visible then -- 1162
		self:updateTitleEffects(dt, args.time, w, h) -- 1166
	end -- 1166
end -- 1057
function HUD.prototype.updateTitleEffects(self, dt, time, w, h) -- 1170
	if self.coverSp ~= nil then -- 1170
		local breath = 1 + 0.015 * (1 + math.sin(time * 0.7)) -- 1173
		self.coverSp.scaleX = self.coverBaseScale * breath -- 1174
		self.coverSp.scaleY = self.coverBaseScale * breath -- 1175
	end -- 1175
	if self.titleNameLb ~= nil then -- 1175
		local a = 205 + math.floor(50 * math.sin(time * 2.2)) -- 1178
		self.titleNameLb.color = Color(255, 233, 172, a) -- 1179
	end -- 1179
	self.menuFlashT = math.max(0, self.menuFlashT - dt) -- 1181
	self:drawMenu(time) -- 1182
	self.particlesDraw:clear() -- 1183
	do -- 1183
		local i = 0 -- 1184
		while i < #self.particles do -- 1184
			local p = self.particles[i + 1] -- 1185
			p.y = p.y + p.vy * dt -- 1186
			if p.y < -h / 2 - 12 then -- 1186
				p.y = h / 2 + 12 -- 1188
				p.x = -w / 2 + 40 + math.random() * (w - 80) -- 1189
			end -- 1189
			local tw = 0.55 + 0.45 * math.sin(time * 2 + p.ph) -- 1191
			local a = math.floor(210 * tw) -- 1192
			self.particlesDraw:drawDot( -- 1193
				Vec2(p.x, p.y), -- 1193
				p.r + 1.4 * tw, -- 1193
				p.gold and Color(255, 216, 130, a) or Color(216, 230, 255, a) -- 1193
			) -- 1193
			i = i + 1 -- 1184
		end -- 1184
	end -- 1184
end -- 1170
function HUD.prototype.drawMenu(self, time) -- 1197
	local bi = 0 -- 1198
	do -- 1198
		local i = 0 -- 1199
		while i < #self.menuDraws do -- 1199
			local d = self.menuDraws[i + 1] -- 1200
			local selected = i == self.menuSel and not self.settingsOpen -- 1201
			d:clear() -- 1202
			if self.menuBtnOk[i + 1] == true then -- 1202
				local sp = self.menuBtns[bi + 1] -- 1204
				bi = bi + 1 -- 1205
				if sp ~= nil then -- 1205
					local s = selected and 1.07 or 1 -- 1207
					sp.scaleX = MENU_W / self.menuBtnW * s -- 1208
					sp.scaleY = MENU_H / self.menuBtnH * s -- 1209
					sp.opacity = selected and 1 or 0.72 -- 1210
				end -- 1210
			elseif selected then -- 1210
				d:drawPolygon( -- 1214
					self:rectVerts(-MENU_W / 2, -MENU_H / 2, MENU_W, MENU_H), -- 1214
					Color(96, 200, 255, 26), -- 1214
					2, -- 1214
					Color(96, 200, 255, 220) -- 1214
				) -- 1214
			end -- 1214
			local lb = self.menuLbs[i + 1] -- 1216
			if lb ~= nil then -- 1216
				if selected then -- 1216
					local glow = 215 + math.floor(40 * math.sin(time * 3.4)) -- 1219
					local flash = self.menuFlashT > 0 -- 1220
					lb.color = flash and Color(255, 255, 255, 255) or Color(255, 255, 255, glow) -- 1221
					lb.scaleX = 1.06 -- 1222
					lb.scaleY = 1.06 -- 1223
				else -- 1223
					lb.color = Color(255, 255, 255, 205) -- 1225
					lb.scaleX = 1 -- 1226
					lb.scaleY = 1 -- 1227
				end -- 1227
			end -- 1227
			i = i + 1 -- 1199
		end -- 1199
	end -- 1199
end -- 1197
return ____exports -- 1197