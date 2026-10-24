-- [ts]: init.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____game = require("game.game") -- 2
local Game = ____game.Game -- 2
local game = __TS__New(Game) -- 4
game:start() -- 5
return ____exports -- 5