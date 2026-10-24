local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 3,["12"] = 3,["13"] = 7,["14"] = 8,["15"] = 11,["16"] = 11,["17"] = 11,["18"] = 11,["19"] = 11,["20"] = 11,["21"] = 11,["22"] = 19,["23"] = 19,["24"] = 19,["25"] = 26,["26"] = 27,["27"] = 28,["28"] = 29,["29"] = 30,["30"] = 31,["31"] = 32,["32"] = 33,["33"] = 34,["34"] = 35,["35"] = 36,["36"] = 37,["37"] = 38,["38"] = 39,["39"] = 40,["41"] = 26,["42"] = 44,["43"] = 45,["44"] = 46,["45"] = 47,["46"] = 48,["47"] = 49,["49"] = 44,["50"] = 53,["51"] = 54,["52"] = 55,["53"] = 56,["54"] = 53,["55"] = 59,["56"] = 60,["57"] = 59,["58"] = 63,["59"] = 64,["62"] = 67,["63"] = 68,["64"] = 69,["67"] = 72,["68"] = 73,["69"] = 74,["70"] = 75,["71"] = 76,["72"] = 77,["73"] = 79,["74"] = 80,["75"] = 80,["76"] = 80,["77"] = 80,["78"] = 80,["79"] = 79,["80"] = 81,["81"] = 81,["82"] = 81,["83"] = 81,["84"] = 81,["85"] = 79,["86"] = 79,["87"] = 84,["89"] = 85,["90"] = 85,["91"] = 86,["92"] = 87,["93"] = 88,["95"] = 89,["96"] = 89,["97"] = 90,["98"] = 91,["99"] = 91,["100"] = 91,["101"] = 91,["102"] = 89,["105"] = 93,["106"] = 93,["107"] = 93,["108"] = 93,["109"] = 93,["110"] = 93,["111"] = 93,["112"] = 93,["113"] = 93,["114"] = 93,["115"] = 93,["116"] = 93,["117"] = 93,["118"] = 93,["119"] = 93,["120"] = 93,["121"] = 85,["124"] = 95,["125"] = 96,["126"] = 96,["127"] = 96,["128"] = 96,["129"] = 96,["130"] = 96,["132"] = 63});
local ____exports = {}
local ____Dora = require("Dora")
local Color = ____Dora.Color
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Vec2 = ____Dora.Vec2
local View = ____Dora.View
local DUR = 1.1
local FONT = "sarasa-mono-sc-regular"
local TINT = {
    rewind = {r = 214, g = 226, b = 235},
    grow = {r = 168, g = 214, b = 156},
    cut = {r = 196, g = 116, b = 104},
    rescue = {r = 232, g = 202, b = 138},
    fill = {r = 150, g = 190, b = 216}
}
____exports.CausalityFx = __TS__Class()
local CausalityFx = ____exports.CausalityFx
CausalityFx.name = "CausalityFx"
function CausalityFx.prototype.____constructor(self, parent)
    self.t = -1
    self.kind = "rewind"
    self.root = Node()
    self.root:addTo(parent)
    self.root.visible = false
    self.draw = DrawNode()
    self.draw:addTo(self.root)
    local lb = Label(FONT, 30)
    if lb ~= nil then
        lb.anchor = Vec2(0.5, 0.5)
        lb.position = Vec2(0, -View.size.height / 2 + 130)
        lb.color = Color(255, 255, 255, 0)
        lb:addTo(self.root)
        self.caption = lb
    end
end
function CausalityFx.prototype.play(self, kind, caption)
    self.kind = kind
    self.t = 0
    self.root.visible = true
    if self.caption ~= nil then
        self.caption.text = caption
    end
end
function CausalityFx.prototype.clear(self)
    self.t = -1
    self.root.visible = false
    self.draw:clear()
end
function CausalityFx.prototype.isBusy(self)
    return self.t >= 0
end
function CausalityFx.prototype.update(self, dt)
    if self.t < 0 then
        return
    end
    self.t = self.t + dt
    if self.t >= DUR then
        self:clear()
        return
    end
    local p = self.t / DUR
    local env = Math:sin(p * Math.PI)
    local w = View.size.width
    local h = View.size.height
    local c = TINT[self.kind]
    self.draw:clear()
    self.draw:drawPolygon(
        {
            Vec2(-w / 2, -h / 2),
            Vec2(w / 2, -h / 2),
            Vec2(w / 2, h / 2),
            Vec2(-w / 2, h / 2)
        },
        Color(
            c.r,
            c.g,
            c.b,
            Math:floor(120 * env)
        )
    )
    local cy = h * 0.12
    do
        local i = 0
        while i < 3 do
            local pr = (p + i * 0.18) % 1
            local r = 60 + pr * Math:max(w, h) * 0.5
            local pts = {}
            do
                local k = 0
                while k <= 26 do
                    local a = k / 26 * Math.PI * 2
                    pts:push(Vec2(
                        Math:cos(a) * r,
                        Math:sin(a) * r + cy
                    ))
                    k = k + 1
                end
            end
            self.draw:drawPolygon(
                pts,
                Color(
                    c.r,
                    c.g,
                    c.b,
                    Math:floor(60 * env)
                ),
                2,
                Color(
                    255,
                    255,
                    255,
                    Math:floor(210 * env)
                )
            )
            i = i + 1
        end
    end
    if self.caption ~= nil then
        self.caption.color = Color(
            255,
            255,
            255,
            Math:floor(255 * env)
        )
    end
end
return ____exports
