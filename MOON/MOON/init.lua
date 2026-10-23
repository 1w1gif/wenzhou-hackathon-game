local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 2,["7"] = 2,["8"] = 4,["9"] = 5});
local ____exports = {}
local ____game = require("game.game")
local Game = ____game.Game
local game = __TS__New(Game)
game:start()
return ____exports
