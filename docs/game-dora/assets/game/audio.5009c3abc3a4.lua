local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 2,["6"] = 2,["7"] = 2,["8"] = 2,["9"] = 2,["10"] = 6,["11"] = 6,["12"] = 6,["13"] = 6,["14"] = 6,["15"] = 6,["16"] = 6,["17"] = 6,["18"] = 6,["19"] = 6,["20"] = 6,["21"] = 6,["22"] = 6,["23"] = 24,["24"] = 24,["25"] = 24,["26"] = 24,["27"] = 24,["28"] = 24,["29"] = 24,["30"] = 24,["31"] = 24,["32"] = 34,["33"] = 36,["34"] = 37,["35"] = 38,["36"] = 39,["38"] = 41,["39"] = 36,["40"] = 44,["41"] = 47,["42"] = 47,["43"] = 47,["45"] = 48,["46"] = 49,["49"] = 52,["52"] = 56,["55"] = 54,["61"] = 47,["62"] = 60,["63"] = 60,["64"] = 60,["66"] = 61,["69"] = 65,["72"] = 63,["78"] = 60,["79"] = 70,["80"] = 70,["81"] = 70,["85"] = 82,["88"] = 72,["89"] = 73,["90"] = 74,["92"] = 76,["93"] = 77,["94"] = 78,["95"] = 79,["102"] = 71,["105"] = 70});
local ____exports = {}
local ____Dora = require("Dora")
local Audio = ____Dora.Audio
local AudioSource = ____Dora.AudioSource
local Director = ____Dora.Director
local Node = ____Dora.Node
local BGM_FILES = {
    main = "assets/audio/bgm-main.mp3",
    tension = "assets/audio/bgm-tension.mp3",
    conflict = "assets/audio/bgm-conflict.mp3",
    wuxia = "assets/audio/bgm-wuxia.mp3",
    calm = "assets/audio/bgm-floor4.mp3",
    dusk = "assets/audio/summer_nights.ogg",
    cover = "assets/audio/bgm-cover.mp3",
    start = "assets/audio/bgm-start.mp3",
    floor1 = "assets/audio/bgm-floor1.mp3",
    floor4 = "assets/audio/bgm-floor4.mp3",
    floor7 = "assets/audio/bgm-floor7.mp3"
}
local SFX_FILES = {
    sword = "assets/audio/sfx-sword-draw.mp3",
    dash = "assets/audio/sfx-dash.mp3",
    click = "assets/audio/sfx-ui-click.wav",
    heroHit = "assets/audio/sfx-hero-hit.mp3",
    enemyHurt = "assets/audio/sfx-enemy-hurt.mp3",
    jump1 = "assets/audio/sfx-jump1.mp3",
    jump2 = "assets/audio/sfx-jump2.mp3"
}
local host
local function hostNode()
    if host == nil then
        host = Node()
        host:addTo(Director.entry)
    end
    return host
end
local currentBgm = ""
function ____exports.playBgm(name, fade)
    if fade == nil then
        fade = 1
    end
    local file = BGM_FILES[name]
    if file == currentBgm then
        return
    end
    currentBgm = file
    do
        local function ____catch(e)
            local ____ = e
        end
        local ____try, ____hasReturned = pcall(function()
            Audio:playStream(file, true, fade)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ____exports.stopBgm(fade)
    if fade == nil then
        fade = 1
    end
    currentBgm = ""
    do
        local function ____catch(e)
            local ____ = e
        end
        local ____try, ____hasReturned = pcall(function()
            Audio:stopStream(fade)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ____exports.sfx(name, volume)
    if volume == nil then
        volume = 0.9
    end
    do
        local function ____catch(e)
            local ____ = e
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local src = AudioSource(SFX_FILES[name], true)
            if src == nil then
                return true
            end
            src.volume = volume
            src:addTo(hostNode())
            if not src:play() then
                src:removeFromParent()
            end
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
return ____exports
