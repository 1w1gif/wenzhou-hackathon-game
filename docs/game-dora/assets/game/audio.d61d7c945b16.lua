-- [ts]: audio.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Audio = ____Dora.Audio -- 2
local AudioSource = ____Dora.AudioSource -- 2
local Director = ____Dora.Director -- 2
local Node = ____Dora.Node -- 2
local BGM_FILES = { -- 6
	main = "assets/audio/bgm-main.mp3", -- 7
	tension = "assets/audio/bgm-tension.mp3", -- 8
	conflict = "assets/audio/bgm-conflict.mp3", -- 9
	wuxia = "assets/audio/bgm-wuxia.mp3", -- 10
	calm = "assets/audio/bgm-floor4.mp3", -- 13
	dusk = "assets/audio/summer_nights.ogg", -- 14
	cover = "assets/audio/bgm-cover.mp3", -- 15
	start = "assets/audio/bgm-start.mp3", -- 16
	floor1 = "assets/audio/bgm-floor1.mp3", -- 17
	floor4 = "assets/audio/bgm-floor4.mp3", -- 18
	floor7 = "assets/audio/bgm-floor7.mp3" -- 19
} -- 19
local SFX_FILES = { -- 24
	sword = "assets/audio/sfx-sword-draw.mp3", -- 25
	dash = "assets/audio/sfx-dash.mp3", -- 26
	click = "assets/audio/sfx-ui-click.wav", -- 27
	heroHit = "assets/audio/sfx-hero-hit.mp3", -- 28
	enemyHurt = "assets/audio/sfx-enemy-hurt.mp3", -- 29
	jump1 = "assets/audio/sfx-jump1.mp3", -- 30
	jump2 = "assets/audio/sfx-jump2.mp3" -- 31
} -- 31
local host -- 34
local function hostNode() -- 36
	if host == nil then -- 36
		host = Node() -- 38
		host:addTo(Director.entry) -- 39
	end -- 39
	return host -- 41
end -- 36
local currentBgm = "" -- 44
function ____exports.playBgm(name, fade) -- 47
	if fade == nil then -- 47
		fade = 1 -- 47
	end -- 47
	local file = BGM_FILES[name] -- 48
	if file == currentBgm then -- 48
		return -- 50
	end -- 50
	currentBgm = file -- 52
	do -- 52
		local function ____catch(e) -- 52
			local ____ = e -- 52
		end -- 52
		local ____try, ____hasReturned = pcall(function() -- 52
			Audio:playStream(file, true, fade) -- 54
		end) -- 54
		if not ____try then -- 54
			____catch(____hasReturned) -- 54
		end -- 54
	end -- 54
end -- 47
function ____exports.stopBgm(fade) -- 60
	if fade == nil then -- 60
		fade = 1 -- 60
	end -- 60
	currentBgm = "" -- 61
	do -- 61
		local function ____catch(e) -- 61
			local ____ = e -- 61
		end -- 61
		local ____try, ____hasReturned = pcall(function() -- 61
			Audio:stopStream(fade) -- 63
		end) -- 63
		if not ____try then -- 63
			____catch(____hasReturned) -- 63
		end -- 63
	end -- 63
end -- 60
function ____exports.sfx(name, volume) -- 70
	if volume == nil then -- 70
		volume = 0.9 -- 70
	end -- 70
	do -- 70
		local function ____catch(e) -- 70
			local ____ = e -- 70
		end -- 70
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 70
			local src = AudioSource(SFX_FILES[name], true) -- 72
			if src == nil then -- 72
				return true -- 74
			end -- 74
			src.volume = volume -- 76
			src:addTo(hostNode()) -- 77
			if not src:play() then -- 77
				src:removeFromParent() -- 79
			end -- 79
		end) -- 79
		if not ____try then -- 79
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 79
		end -- 79
		if ____hasReturned then -- 79
			return ____returnValue -- 71
		end -- 71
	end -- 71
end -- 70
return ____exports -- 70