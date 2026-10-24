local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 4,["6"] = 4,["7"] = 4,["8"] = 4,["9"] = 4,["10"] = 4,["11"] = 4,["12"] = 6,["13"] = 7,["15"] = 10,["16"] = 11,["17"] = 10,["21"] = 19,["22"] = 20,["23"] = 21,["24"] = 22,["25"] = 22,["26"] = 22,["27"] = 22,["28"] = 22,["29"] = 22,["30"] = 23,["31"] = 24,["32"] = 25,["33"] = 25,["34"] = 25,["35"] = 25,["36"] = 26,["37"] = 26,["38"] = 26,["39"] = 26,["40"] = 26,["41"] = 26,["42"] = 27,["43"] = 28,["44"] = 29,["45"] = 30,["46"] = 31,["47"] = 32,["48"] = 33,["49"] = 34,["50"] = 35,["53"] = 38,["54"] = 19});
local ____exports = {}
local ____Dora = require("Dora")
local Color = ____Dora.Color
local DrawNode = ____Dora.DrawNode
local Node = ____Dora.Node
local Sprite = ____Dora.Sprite
local Texture2D = ____Dora.Texture2D
local Vec2 = ____Dora.Vec2
____exports.TECH_FRAME_PATH = "assets/ui/tech/frame_brackets.png"
____exports.TECH_BTN_PATH = "assets/ui/tech/button.png"
--- 科技青点缀色（回退描边/高亮可用）
function ____exports.techAccent()
    return Color(96, 200, 255, 255)
end
--- 建一块科技风面板（局部坐标 (0,0)=面板中心）：
-- 半透明暗底（不挡背景）+ 细青描边 + 四角角框贴图；角框缺失时保留纯描边框。
-- 先于内容创建调用，后续 addTo 的标签/列表自然盖在面板之上。
function ____exports.makeTechPanel(parent, w, h)
    local holder = Node()
    holder:addTo(parent)
    local full = {
        Vec2(-w / 2, -h / 2),
        Vec2(w / 2, -h / 2),
        Vec2(w / 2, h / 2),
        Vec2(-w / 2, h / 2)
    }
    local fill = DrawNode()
    fill:addTo(holder)
    fill:drawPolygon(
        full,
        Color(7, 11, 20, 150)
    )
    fill:drawPolygon(
        full,
        Color(0, 0, 0, 0),
        1.5,
        Color(96, 200, 255, 130)
    )
    local tex = Texture2D(____exports.TECH_FRAME_PATH)
    if tex ~= nil then
        local frame = Sprite(tex)
        if frame ~= nil then
            frame.anchor = Vec2(0.5, 0.5)
            frame.position = Vec2(0, 0)
            frame.scaleX = w / tex.width
            frame.scaleY = h / tex.height
            frame:addTo(holder)
        end
    end
    return holder
end
return ____exports
