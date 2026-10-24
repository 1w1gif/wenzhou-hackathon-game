-- [ts]: dialog.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local ____palette = require("core.palette") -- 3
local Palette = ____palette.Palette -- 3
local ink = ____palette.ink -- 3
local FONT = "sarasa-mono-sc-regular" -- 6
local CHARS_PER_SEC = 28 -- 7
local CHOICE_POOL = 4 -- 8
local function col(c) -- 10
	return Color(c.r, c.g, c.b, c.a) -- 10
end -- 10
local function makeLabel(parent, size, x, y, ax, ay, color) -- 12
	local lb = Label(FONT, size) -- 13
	if lb == nil then -- 13
		return nil -- 15
	end -- 15
	lb.anchor = Vec2(ax, ay) -- 17
	lb.position = Vec2(x, y) -- 18
	lb.color = Color(color.r, color.g, color.b, color.a) -- 19
	lb:addTo(parent) -- 20
	return lb -- 21
end -- 12
local function setText(lb, text) -- 24
	if lb ~= nil and lb.text ~= text then -- 24
		lb.text = text -- 26
	end -- 26
end -- 24
--- 等宽字宽：sarasa 全角＝字号、半角＝半字号（CJK 与全角标点按全角计）
local function charW(ch, size) -- 31
	local code = string.byte(ch, 1) or 0 / 0 -- 32
	return code > 8192 and size or math.floor(size / 2 + 0.5) -- 33
end -- 31
local function setLabelColor(lb, color) -- 36
	if lb ~= nil then -- 36
		lb.color = Color(color.r, color.g, color.b, color.a) -- 38
	end -- 38
end -- 36
____exports.DialogUI = __TS__Class() -- 42
local DialogUI = ____exports.DialogUI -- 42
DialogUI.name = "DialogUI" -- 42
function DialogUI.prototype.____constructor(self, parent) -- 71
	self.lines = {} -- 72
	self.charLbs = {} -- 73
	self.appliedLine = "" -- 74
	self.glyphCount = 0 -- 75
	self.choiceLbs = {} -- 76
	self.node = nil -- 77
	self.fallbackSpeaker = "" -- 78
	self.lineIndex = 0 -- 79
	self.charShown = 0 -- 80
	self.shownCount = -1 -- 81
	self.choiceMode = false -- 82
	self.selected = 0 -- 83
	self.choiceDone = false -- 84
	self.pendingChoice = -1 -- 85
	self.openFlag = false -- 86
	self.onChoice = function(self, _index) -- 87
	end -- 87
	self.onChoiceAsk = function(self, _index) -- 88
	end -- 88
	self.nextChoices = {} -- 89
	self.root = Node() -- 90
	self.root:addTo(parent) -- 91
	self.root.visible = false -- 92
	self.panel = DrawNode() -- 93
	self.panel:addTo(self.root) -- 94
	local h = View.size.height -- 95
	local top = -h / 2 + 196 -- 96
	local bot = -h / 2 + 26 -- 97
	self.panel:drawPolygon( -- 98
		{ -- 99
			Vec2(-490, bot), -- 99
			Vec2(490, bot), -- 99
			Vec2(490, top), -- 99
			Vec2(-490, top) -- 99
		}, -- 99
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 235)), -- 100
		2, -- 100
		col(Palette.inkDark) -- 100
	) -- 100
	self.panel:drawSegment( -- 102
		Vec2(-490, top - 52), -- 102
		Vec2(490, top - 52), -- 102
		1, -- 102
		col(Palette.goldSoft) -- 102
	) -- 102
	self.panel:drawPolygon( -- 104
		{ -- 105
			Vec2(-478, top - 46), -- 105
			Vec2(-318, top - 46), -- 105
			Vec2(-318, top - 10), -- 105
			Vec2(-478, top - 10) -- 105
		}, -- 105
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), -- 106
		2, -- 106
		col(Palette.inkDark) -- 106
	) -- 106
	self.speakerLb = makeLabel( -- 108
		self.root, -- 108
		24, -- 108
		-462, -- 108
		top - 28, -- 108
		0, -- 108
		0.5, -- 108
		Palette.inkDark -- 108
	) -- 108
	do -- 108
		local i = 0 -- 110
		while i < 64 do -- 110
			local lb = makeLabel( -- 111
				self.root, -- 111
				22, -- 111
				-462, -- 111
				-h / 2 + 112, -- 111
				0, -- 111
				0.5, -- 111
				Palette.inkSoft -- 111
			) -- 111
			if lb ~= nil then -- 111
				lb.text = "" -- 113
				lb.visible = false -- 114
				local ____self_charLbs_0 = self.charLbs -- 114
				____self_charLbs_0[#____self_charLbs_0 + 1] = lb -- 115
			end -- 115
			i = i + 1 -- 110
		end -- 110
	end -- 110
	self.hintLb = makeLabel( -- 119
		self.root, -- 119
		16, -- 119
		455, -- 119
		bot + 20, -- 119
		1, -- 119
		0.5, -- 119
		Palette.paleInkMid -- 119
	) -- 119
	setText(self.hintLb, "空格 / 回车 继续…") -- 120
	if self.hintLb ~= nil then -- 120
		self.hintLb.visible = false -- 122
	end -- 122
	self.choicesDraw = DrawNode() -- 124
	self.choicesDraw:addTo(self.root) -- 125
	do -- 125
		local i = 0 -- 126
		while i < CHOICE_POOL do -- 126
			local lb = makeLabel( -- 127
				self.root, -- 127
				20, -- 127
				0, -- 127
				-h / 2 + 260 - i * 42, -- 127
				0.5, -- 127
				0.5, -- 127
				Palette.paleInk -- 127
			) -- 127
			if lb ~= nil then -- 127
				local ____self_choiceLbs_1 = self.choiceLbs -- 127
				____self_choiceLbs_1[#____self_choiceLbs_1 + 1] = lb -- 129
			end -- 129
			i = i + 1 -- 126
		end -- 126
	end -- 126
end -- 71
function DialogUI.prototype.open(self, node, speaker) -- 134
	self.node = node -- 135
	self.fallbackSpeaker = speaker -- 136
	self.lines = node.lines -- 137
	self.lineIndex = 0 -- 138
	self.charShown = 0 -- 139
	self.shownCount = -1 -- 140
	self.appliedLine = "" -- 141
	self.choiceMode = false -- 142
	self.selected = 0 -- 143
	self.choiceDone = false -- 144
	self.pendingChoice = -1 -- 145
	self.nextChoices = {} -- 146
	self.openFlag = true -- 147
	self.root.visible = true -- 148
	self.choicesDraw:clear() -- 149
	self:applyLine() -- 150
end -- 134
function DialogUI.prototype.close(self) -- 153
	self.openFlag = false -- 154
	self.root.visible = false -- 155
	self.choiceMode = false -- 156
	self.choicesDraw:clear() -- 157
	do -- 157
		local i = 0 -- 158
		while i < #self.choiceLbs do -- 158
			setText(self.choiceLbs[i + 1], "") -- 159
			i = i + 1 -- 158
		end -- 158
	end -- 158
end -- 153
function DialogUI.prototype.setNextChoices(self, choices) -- 164
	self.nextChoices = choices -- 165
end -- 164
function DialogUI.prototype.reopenChoices(self) -- 169
	if #self.nextChoices == 0 then -- 169
		return false -- 171
	end -- 171
	local base = self.node -- 173
	if base == nil then -- 173
		self.nextChoices = {} -- 175
		return false -- 176
	end -- 176
	self.node = __TS__ObjectAssign({}, base, {choices = self.nextChoices}) -- 178
	self.nextChoices = {} -- 179
	self.pendingChoice = -1 -- 180
	self.choiceDone = false -- 181
	self.choiceMode = true -- 182
	self.selected = 0 -- 183
	self:applyChoices() -- 184
	self:drawChoices() -- 185
	self:updateHint() -- 186
	return true -- 187
end -- 169
function DialogUI.prototype.isOpen(self) -- 190
	return self.openFlag -- 191
end -- 190
function DialogUI.prototype.hasChoices(self) -- 194
	return self.node ~= nil and self.node.choices ~= nil and #self.node.choices > 0 -- 195
end -- 194
function DialogUI.prototype.inChoiceMode(self) -- 199
	return self.openFlag and self.choiceMode -- 200
end -- 199
function DialogUI.prototype.choiceCount(self) -- 203
	if self.node == nil or self.node.choices == nil then -- 203
		return 0 -- 205
	end -- 205
	return #self.node.choices -- 207
end -- 203
function DialogUI.prototype.moveChoice(self, dir) -- 210
	if not self.choiceMode or self:choiceCount() == 0 then -- 210
		return -- 212
	end -- 212
	local n = self:choiceCount() -- 214
	self.selected = math.max( -- 215
		0, -- 215
		math.min(n - 1, self.selected + dir) -- 215
	) -- 215
	self:drawChoices() -- 216
end -- 210
function DialogUI.prototype.confirmChoice(self) -- 219
	if not self.choiceMode then -- 219
		self:advance() -- 222
		return -- 223
	end -- 223
	local idx = self.selected -- 225
	local node = self.node -- 226
	local ____temp_2 -- 227
	if node ~= nil and node.choices ~= nil then -- 227
		____temp_2 = node.choices[idx + 1].replies -- 227
	else -- 227
		____temp_2 = nil -- 227
	end -- 227
	local replies = ____temp_2 -- 227
	if replies ~= nil and #replies > 0 then -- 227
		self.pendingChoice = idx -- 230
		self.choiceDone = true -- 231
		self.choiceMode = false -- 232
		self.selected = 0 -- 233
		self.choicesDraw:clear() -- 234
		do -- 234
			local i = 0 -- 235
			while i < #self.choiceLbs do -- 235
				setText(self.choiceLbs[i + 1], "") -- 236
				i = i + 1 -- 235
			end -- 235
		end -- 235
		local insertAt = math.min(self.lineIndex + 1, #self.lines) -- 238
		local tail = __TS__ArraySlice(self.lines, insertAt) -- 239
		self.lines = __TS__ArrayConcat( -- 240
			__TS__ArraySlice(self.lines, 0, insertAt), -- 240
			replies, -- 240
			tail -- 240
		) -- 240
		self.lineIndex = insertAt -- 241
		self.charShown = 0 -- 242
		self.shownCount = -1 -- 243
		self:applyLine() -- 244
		self:onChoiceAsk(idx) -- 245
		return -- 246
	end -- 246
	self:onChoiceAsk(idx) -- 248
	if self:reopenChoices() then -- 248
		return -- 250
	end -- 250
	local cb = self.onChoice -- 252
	self:close() -- 253
	cb(nil, idx) -- 254
end -- 219
function DialogUI.prototype.advance(self) -- 257
	if not self.openFlag or self.choiceMode or self.lineIndex >= #self.lines then -- 257
		return -- 259
	end -- 259
	local full = self.glyphCount -- 261
	if self.charShown < full then -- 261
		self.charShown = full -- 263
		self:applyLine() -- 264
		return -- 265
	end -- 265
	if self.lineIndex < #self.lines - 1 then -- 265
		self.lineIndex = self.lineIndex + 1 -- 268
		self.charShown = 0 -- 269
		self.shownCount = -1 -- 270
		self:applyLine() -- 271
		return -- 272
	end -- 272
	if self:hasChoices() and self:choiceCount() > 0 and not self.choiceDone then -- 272
		self.choiceMode = true -- 275
		self.selected = 0 -- 276
		self:applyChoices() -- 277
		self:drawChoices() -- 278
		self:updateHint() -- 279
		return -- 280
	end -- 280
	if self:reopenChoices() then -- 280
		return -- 283
	end -- 283
	local done = self.pendingChoice -- 287
	self.pendingChoice = -1 -- 288
	local cb = self.onChoice -- 289
	self:close() -- 290
	cb(nil, done) -- 291
end -- 257
function DialogUI.prototype.update(self, dt) -- 294
	if not self.openFlag or self.choiceMode or self.lineIndex >= #self.lines then -- 294
		return -- 296
	end -- 296
	if self.charShown >= self.glyphCount then -- 296
		return -- 299
	end -- 299
	self.charShown = math.min(self.charShown + CHARS_PER_SEC * dt, self.glyphCount) -- 301
	self:applyLine() -- 302
end -- 294
function DialogUI.prototype.applyLine(self) -- 305
	if self.lineIndex >= #self.lines then -- 305
		self:updateHint() -- 307
		return -- 308
	end -- 308
	local line = self.lines[self.lineIndex + 1] -- 310
	local speaker = line.speaker ~= "" and line.speaker or self.fallbackSpeaker -- 311
	setText(self.speakerLb, speaker) -- 312
	local n = math.floor(self.charShown) -- 313
	if line.text ~= self.appliedLine then -- 313
		self.appliedLine = line.text -- 315
		self:layoutLine(line.text) -- 316
	end -- 316
	if n ~= self.shownCount then -- 316
		self.shownCount = n -- 319
		do -- 319
			local i = 0 -- 320
			while i < #self.charLbs do -- 320
				self.charLbs[i + 1].visible = i < n -- 321
				i = i + 1 -- 320
			end -- 320
		end -- 320
	end -- 320
	self:updateHint() -- 324
end -- 305
function DialogUI.prototype.layoutLine(self, text) -- 329
	local maxW = 924 -- 330
	local rowH = 32 -- 331
	local baseY = -View.size.height / 2 + 112 -- 332
	local x = -462 -- 333
	local row = 0 -- 334
	local used = 0 -- 335
	local laid = 0 -- 336
	local i = 0 -- 337
	while i < #text and laid < #self.charLbs do -- 337
		local b = __TS__StringCharCodeAt(text, i) -- 339
		local seq = b >= 240 and 4 or (b >= 224 and 3 or (b >= 192 and 2 or 1)) -- 340
		local ch = __TS__StringSubstring(text, i, i + seq) -- 341
		local lb = self.charLbs[laid + 1] -- 342
		lb.text = ch -- 343
		local w = lb.width > 0 and lb.width or charW(ch, 22) -- 344
		if used + w > maxW and row == 0 then -- 344
			row = 1 -- 346
			used = 0 -- 347
			x = -462 -- 348
		end -- 348
		if used + w > maxW then -- 348
			break -- 351
		end -- 351
		lb.visible = false -- 353
		lb.position = Vec2(x, baseY - row * rowH) -- 354
		used = used + w -- 355
		x = x + w -- 356
		laid = laid + 1 -- 357
		i = i + seq -- 358
	end -- 358
	do -- 358
		local j = laid -- 360
		while j < #self.charLbs do -- 360
			self.charLbs[j + 1].text = "" -- 361
			self.charLbs[j + 1].visible = false -- 362
			j = j + 1 -- 360
		end -- 360
	end -- 360
	self.glyphCount = laid -- 364
end -- 329
function DialogUI.prototype.updateHint(self) -- 368
	if self.hintLb == nil then -- 368
		return -- 370
	end -- 370
	local full = self.lineIndex < #self.lines and self.glyphCount or 0 -- 372
	self.hintLb.visible = self.openFlag and not self.choiceMode and full > 0 and self.charShown >= full -- 373
end -- 368
function DialogUI.prototype.applyChoices(self) -- 376
	if self.node == nil or self.node.choices == nil then -- 376
		return -- 378
	end -- 378
	do -- 378
		local i = 0 -- 380
		while i < #self.choiceLbs do -- 380
			setText(self.choiceLbs[i + 1], i < #self.node.choices and self.node.choices[i + 1].text or "") -- 381
			i = i + 1 -- 380
		end -- 380
	end -- 380
end -- 376
function DialogUI.prototype.drawChoices(self) -- 385
	self.choicesDraw:clear() -- 386
	if not self.choiceMode or self.node == nil or self.node.choices == nil then -- 386
		return -- 388
	end -- 388
	local h = View.size.height -- 390
	local n = #self.node.choices -- 391
	local boxH = n * 42 + 24 -- 392
	local boxY = -h / 2 + 260 - (n - 1) * 21 -- 393
	self.choicesDraw:drawPolygon( -- 395
		{ -- 396
			Vec2(-290, boxY - boxH / 2), -- 396
			Vec2(290, boxY - boxH / 2), -- 396
			Vec2(290, boxY + boxH / 2), -- 396
			Vec2(-290, boxY + boxH / 2) -- 396
		}, -- 396
		col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 250)), -- 397
		2, -- 397
		col(Palette.inkDark) -- 397
	) -- 397
	self.choicesDraw:drawPolygon( -- 399
		{ -- 400
			Vec2(-282, boxY - boxH / 2 + 8), -- 400
			Vec2(282, boxY - boxH / 2 + 8), -- 400
			Vec2(282, boxY + boxH / 2 - 8), -- 400
			Vec2(-282, boxY + boxH / 2 - 8) -- 400
		}, -- 400
		col(ink(0, 0, 0, 0)), -- 401
		1, -- 401
		col(Palette.goldSoft) -- 401
	) -- 401
	do -- 401
		local i = 0 -- 403
		while i < #self.choiceLbs do -- 403
			do -- 403
				local sel = i == self.selected -- 404
				local lb = self.choiceLbs[i + 1] -- 405
				if i >= n then -- 405
					setText(lb, "") -- 407
					goto __continue71 -- 408
				end -- 408
				local y = -h / 2 + 260 - i * 42 -- 410
				local tw = lb.width -- 412
				local leftAlign = tw <= 470 -- 413
				lb.position = Vec2( -- 414
					leftAlign and -232 or math.max(-250, -tw / 2), -- 414
					y -- 414
				) -- 414
				lb.anchor = Vec2(leftAlign and 0 or 0.5, 0.5) -- 415
				setLabelColor(lb, sel and Palette.inkDark or Palette.paleInk) -- 416
				self.choicesDraw:drawPolygon( -- 418
					{ -- 419
						Vec2(-262, y - 16), -- 419
						Vec2(262, y - 16), -- 419
						Vec2(262, y + 16), -- 419
						Vec2(-262, y + 16) -- 419
					}, -- 419
					sel and col(ink(Palette.moonCyan.r, Palette.moonCyan.g, Palette.moonCyan.b, 46)) or col(ink(Palette.paper.r, Palette.paper.g, Palette.paper.b, 255)), -- 420
					sel and 2 or 1, -- 421
					sel and col(Palette.moonCyan) or col(Palette.inkFaint) -- 422
				) -- 422
				if sel then -- 422
					self.choicesDraw:drawPolygon( -- 425
						{ -- 426
							Vec2(-250, y + 9), -- 426
							Vec2(-241, y), -- 426
							Vec2(-250, y - 9), -- 426
							Vec2(-259, y) -- 426
						}, -- 426
						col(Palette.moonCyan) -- 427
					) -- 427
				end -- 427
			end -- 427
			::__continue71:: -- 427
			i = i + 1 -- 403
		end -- 403
	end -- 403
end -- 385
return ____exports -- 385