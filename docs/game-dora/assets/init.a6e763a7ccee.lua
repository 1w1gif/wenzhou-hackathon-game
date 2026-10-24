-- [ts]: init.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local View = ____Dora.View -- 2
local ____game = require("game.game") -- 3
local Game = ____game.Game -- 3
local MOBILE_BASE_WIDTH = 960 -- 8
local isMobile = App.platform == "Android" or App.platform == "iOS" -- 9
local vw = View.size.width -- 10
if isMobile and vw > MOBILE_BASE_WIDTH * 1.15 then -- 10
	View.scale = vw / MOBILE_BASE_WIDTH -- 12
elseif not isMobile then -- 12
	View.scale = 2.11 -- 12
end -- 12
local game = __TS__New(Game) -- 15
game:start() -- 16
return ____exports -- 16