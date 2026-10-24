-- [ts]: palette.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
function ____exports.ink(r, g, b, a) -- 12
	return Color(r, g, b, a == nil and 255 or a) -- 13
end -- 12
____exports.Palette = { -- 16
	paper = ____exports.ink(232, 223, 199, 255), -- 18
	paperDim = ____exports.ink(219, 208, 184, 255), -- 19
	inkDark = ____exports.ink(30, 37, 36, 255), -- 21
	inkSoft = ____exports.ink(30, 37, 36, 210), -- 22
	inkWash = ____exports.ink(30, 37, 36, 150), -- 23
	inkFaint = ____exports.ink(30, 37, 36, 90), -- 24
	paleInk = ____exports.ink(101, 112, 107, 255), -- 26
	paleInkFar = ____exports.ink(101, 112, 107, 70), -- 27
	paleInkMid = ____exports.ink(101, 112, 107, 130), -- 28
	moonCyan = ____exports.ink(168, 197, 188, 255), -- 30
	moonCyanSoft = ____exports.ink(168, 197, 188, 160), -- 31
	moonCyanFaint = ____exports.ink(168, 197, 188, 90), -- 32
	gold = ____exports.ink(155, 113, 56, 255), -- 34
	goldSoft = ____exports.ink(155, 113, 56, 170), -- 35
	vermilion = ____exports.ink(163, 60, 47, 255), -- 37
	vermilionSoft = ____exports.ink(163, 60, 47, 170), -- 38
	moonWhite = ____exports.ink(246, 241, 226, 255), -- 40
	moonHalo = ____exports.ink(246, 241, 226, 36), -- 41
	mist = ____exports.ink(46, 52, 50, 120), -- 43
	mistLight = ____exports.ink(60, 68, 66, 70), -- 44
	white = ____exports.ink(255, 255, 255, 255) -- 45
} -- 45
return ____exports -- 45