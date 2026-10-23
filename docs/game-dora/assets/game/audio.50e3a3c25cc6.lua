local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 2,["6"] = 2,["7"] = 2,["8"] = 2,["9"] = 2,["10"] = 6,["11"] = 16,["12"] = 21,["13"] = 23,["14"] = 24,["15"] = 25,["16"] = 26,["18"] = 28,["19"] = 23,["20"] = 32,["21"] = 32,["22"] = 32,["26"] = 36,["29"] = 34,["35"] = 32,["36"] = 40,["37"] = 40,["38"] = 40,["42"] = 44,["45"] = 42,["51"] = 40,["52"] = 49,["53"] = 49,["54"] = 49,["58"] = 61,["61"] = 51,["62"] = 52,["63"] = 53,["65"] = 55,["66"] = 56,["67"] = 57,["68"] = 58,["75"] = 50,["78"] = 49});
local ____exports = {}
local ____Dora = require("Dora")
local Audio = ____Dora.Audio
local AudioSource = ____Dora.AudioSource
local Director = ____Dora.Director
local Node = ____Dora.Node
local BGM_FILES = {tension = "assets/audio/bgm-tension.mp3", conflict = "assets/audio/bgm-conflict.mp3", wuxia = "assets/audio/bgm-wuxia.mp3", calm = "assets/audio/bgm-calm.wav"}
local SFX_FILES = {sword = "assets/audio/sfx-sword-draw.mp3", dash = "assets/audio/sfx-sword-draw.mp3"}
local host
local function hostNode()
    if host == nil then
        host = Node()
        host:addTo(Director.entry)
    end
    return host
end
function ____exports.playBgm(name, fade)
    if fade == nil then
        fade = 1
    end
    do
        local function ____catch(e)
            local ____ = e
        end
        local ____try, ____hasReturned = pcall(function()
            Audio:playStream(BGM_FILES[name], true, fade)
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
