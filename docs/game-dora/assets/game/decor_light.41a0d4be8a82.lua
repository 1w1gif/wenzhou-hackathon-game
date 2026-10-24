local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 3,["12"] = 3,["13"] = 4,["14"] = 4,["15"] = 5,["16"] = 5,["17"] = 21,["18"] = 22,["19"] = 23,["20"] = 24,["21"] = 25,["22"] = 26,["23"] = 28,["24"] = 28,["25"] = 28,["26"] = 38,["27"] = 31,["28"] = 33,["29"] = 34,["30"] = 35,["31"] = 36,["32"] = 39,["33"] = 40,["34"] = 41,["36"] = 42,["37"] = 42,["39"] = 43,["40"] = 44,["41"] = 45,["43"] = 47,["44"] = 48,["47"] = 42,["50"] = 50,["51"] = 51,["53"] = 53,["54"] = 54,["55"] = 55,["57"] = 57,["58"] = 58,["59"] = 38,["60"] = 62,["61"] = 63,["64"] = 66,["65"] = 67,["67"] = 68,["68"] = 68,["70"] = 69,["71"] = 70,["72"] = 71,["74"] = 73,["75"] = 74,["76"] = 75,["77"] = 76,["78"] = 77,["79"] = 78,["80"] = 79,["81"] = 80,["82"] = 81,["85"] = 68,["88"] = 83,["89"] = 84,["92"] = 62,["93"] = 90,["94"] = 91,["97"] = 94,["98"] = 95,["99"] = 95,["100"] = 95,["101"] = 95,["102"] = 96,["103"] = 97,["104"] = 98,["105"] = 99,["106"] = 100,["107"] = 101,["108"] = 102,["110"] = 90,["111"] = 106,["112"] = 107,["113"] = 108,["114"] = 109,["116"] = 110,["117"] = 110,["118"] = 111,["119"] = 110,["123"] = 114,["124"] = 115,["125"] = 116,["127"] = 118,["128"] = 119,["129"] = 120,["130"] = 120,["131"] = 120,["132"] = 120,["133"] = 120,["134"] = 120,["135"] = 120,["136"] = 120,["138"] = 122,["139"] = 123,["140"] = 123,["141"] = 123,["142"] = 123,["143"] = 123,["144"] = 123,["145"] = 123,["146"] = 123,["148"] = 106});
local ____exports = {}
local ____Dora = require("Dora")
local DrawNode = ____Dora.DrawNode
local Node = ____Dora.Node
local Rect = ____Dora.Rect
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local Vec2 = ____Dora.Vec2
local ____palette = require("core.palette")
local ink = ____palette.ink
local ____render_chars = require("game.render_chars")
local dot = ____render_chars.dot
local LANTERN_COUNT = 5
local LANTERN_FPS = 5
local LANTERN_SCALE = 0.42
local TORCH_FRAMES = 30
local TORCH_FPS = 14
local TORCH_SCALE = 1.15
____exports.LightDecor = __TS__Class()
local LightDecor = ____exports.LightDecor
LightDecor.name = "LightDecor"
function LightDecor.prototype.____constructor(self, parent)
    self.lanternTex = {}
    self.lanterns = {}
    self.torches = {}
    self.t = 0
    self.ok = false
    self.root = Node()
    self.root:addTo(parent)
    local anyTex = false
    do
        local i = 1
        while i <= LANTERN_COUNT do
            do
                local tex = Texture2D(("assets/decor/lantern_" .. tostring(i)) .. ".png")
                if tex == nil then
                    goto __continue4
                end
                self.lanternTex[i - 1] = tex
                anyTex = true
            end
            ::__continue4::
            i = i + 1
        end
    end
    if anyTex then
        self.ok = true
    end
    self.torchTex = Texture2D("assets/decor/torch.png")
    if self.torchTex ~= nil then
        self.ok = true
    end
    self.glow = DrawNode()
    self.glow:addTo(self.root)
end
function LightDecor.prototype.addLanterns(self, spots)
    if not self.ok then
        return
    end
    for ____, s in ipairs(spots) do
        local sprites = {}
        do
            local i = 0
            while i < LANTERN_COUNT do
                do
                    local tex = self.lanternTex[i]
                    if tex == nil then
                        goto __continue12
                    end
                    local sp = Sprite(tex)
                    sp.filter = "Point"
                    sp.anchor = Vec2(0.5, 1)
                    sp.scaleX = LANTERN_SCALE
                    sp.scaleY = LANTERN_SCALE
                    sp.position = Vec2(s.x, s.y)
                    sp.visible = false
                    sp:addTo(self.root)
                    sprites:push(sp)
                end
                ::__continue12::
                i = i + 1
            end
        end
        if #sprites > 0 then
            self.lanterns:push({x = s.x, y = s.y, phase = s.x * 0.013 % 6.28, sprites = sprites})
        end
    end
end
function LightDecor.prototype.addTorches(self, spots)
    if self.torchTex == nil then
        return
    end
    for ____, s in ipairs(spots) do
        local sp = Sprite(
            self.torchTex,
            Rect(0, 0, 64, 64)
        )
        sp.filter = "Point"
        sp.anchor = Vec2(0.5, 0)
        sp.scaleX = TORCH_SCALE
        sp.scaleY = TORCH_SCALE
        sp.position = Vec2(s.x, s.y)
        sp:addTo(self.root)
        self.torches:push({x = s.x, y = s.y, sp = sp, phase = s.x * 0.017 % 6.28})
    end
end
function LightDecor.prototype.update(self, time, dt)
    self.t = self.t + dt
    for ____, ln in ipairs(self.lanterns) do
        local idx = Math:floor(self.t * LANTERN_FPS + ln.phase) % #ln.sprites
        do
            local j = 0
            while j < #ln.sprites do
                ln.sprites[j + 1].visible = j == idx
                j = j + 1
            end
        end
    end
    for ____, tc in ipairs(self.torches) do
        local idx = Math:floor(self.t * TORCH_FPS + tc.phase * 2) % TORCH_FRAMES
        tc.sp.textureRect = Rect(idx * 64, 0, 64, 64)
    end
    self.glow:clear()
    for ____, ln in ipairs(self.lanterns) do
        dot(
            self.glow,
            ln.x,
            ln.y - 50,
            52,
            ink(255, 186, 96, 90),
            0.1 + 0.05 * Math:sin(time * 3 + ln.phase)
        )
    end
    for ____, tc in ipairs(self.torches) do
        dot(
            self.glow,
            tc.x,
            tc.y + 40,
            40,
            ink(255, 150, 60, 110),
            0.12 + 0.06 * Math:sin(time * 9 + tc.phase)
        )
    end
end
return ____exports
