local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 2,["7"] = 2,["8"] = 3,["9"] = 3,["10"] = 7,["11"] = 8,["12"] = 9,["13"] = 10,["15"] = 13,["16"] = 14});
local ____exports = {}
local ____Dora = require("Dora")
local View = ____Dora.View
local ____game = require("game.game")
local Game = ____game.Game
local BASE_WIDTH = 960
local vw = View.size.width
if vw > BASE_WIDTH * 1.15 then
    View.scale = vw / BASE_WIDTH
end
local game = __TS__New(Game)
game:start()
return ____exports
