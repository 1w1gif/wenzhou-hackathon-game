local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 2,["6"] = 2,["7"] = 12,["8"] = 13,["9"] = 12,["10"] = 16,["11"] = 16,["12"] = 16,["13"] = 16,["14"] = 16,["15"] = 16,["16"] = 16,["17"] = 16,["18"] = 16,["19"] = 16,["20"] = 16,["21"] = 16,["22"] = 16,["23"] = 16,["24"] = 16,["25"] = 16,["26"] = 16,["27"] = 16,["28"] = 16,["29"] = 16,["30"] = 16,["31"] = 16,["32"] = 16});
local ____exports = {}
local ____Dora = require("Dora")
local Color = ____Dora.Color
function ____exports.ink(r, g, b, a)
    return Color(r, g, b, a == nil and 255 or a)
end
____exports.Palette = {
    paper = ____exports.ink(232, 223, 199, 255),
    paperDim = ____exports.ink(219, 208, 184, 255),
    inkDark = ____exports.ink(30, 37, 36, 255),
    inkSoft = ____exports.ink(30, 37, 36, 210),
    inkWash = ____exports.ink(30, 37, 36, 150),
    inkFaint = ____exports.ink(30, 37, 36, 90),
    paleInk = ____exports.ink(101, 112, 107, 255),
    paleInkFar = ____exports.ink(101, 112, 107, 70),
    paleInkMid = ____exports.ink(101, 112, 107, 130),
    moonCyan = ____exports.ink(168, 197, 188, 255),
    moonCyanSoft = ____exports.ink(168, 197, 188, 160),
    moonCyanFaint = ____exports.ink(168, 197, 188, 90),
    gold = ____exports.ink(155, 113, 56, 255),
    goldSoft = ____exports.ink(155, 113, 56, 170),
    vermilion = ____exports.ink(163, 60, 47, 255),
    vermilionSoft = ____exports.ink(163, 60, 47, 170),
    moonWhite = ____exports.ink(246, 241, 226, 255),
    moonHalo = ____exports.ink(246, 241, 226, 36),
    mist = ____exports.ink(46, 52, 50, 120),
    mistLight = ____exports.ink(60, 68, 66, 70),
    white = ____exports.ink(255, 255, 255, 255)
}
return ____exports
