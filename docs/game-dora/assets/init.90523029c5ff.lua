-- [ts]: init.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local View = ____Dora.View -- 2
local ____game = require("game.game") -- 3
local Game = ____game.Game -- 3
local MOBILE_BASE_WIDTH = 960 -- 10
local isMobile = App.platform == "Android" or App.platform == "iOS" -- 11
local vw = View.size.width -- 12
if isMobile then -- 12
	if vw > MOBILE_BASE_WIDTH * 1.15 then -- 12
		View.scale = vw / MOBILE_BASE_WIDTH -- 14
	end -- 14
	View.scale = View.scale * 2.0 -- 手机视野再放大2x（用户指令 2026-10-25）
elseif vw > 0 then -- 12
	View.scale = 1.5 -- 桌面视野放大1.5x（用户指令 2026-10-25）
end -- 14
local game = __TS__New(Game) -- 17
game:start() -- 18
return ____exports -- 18