local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 5,["11"] = 5,["12"] = 5,["13"] = 5,["14"] = 5,["15"] = 5,["16"] = 5,["17"] = 6,["18"] = 6,["19"] = 6,["20"] = 8,["21"] = 9,["22"] = 12,["23"] = 13,["24"] = 14,["25"] = 15,["26"] = 34,["27"] = 34,["28"] = 34,["29"] = 57,["30"] = 38,["31"] = 39,["32"] = 40,["33"] = 43,["34"] = 44,["35"] = 45,["36"] = 51,["37"] = 51,["38"] = 52,["39"] = 52,["40"] = 53,["41"] = 53,["42"] = 54,["43"] = 54,["44"] = 55,["45"] = 55,["46"] = 58,["47"] = 58,["48"] = 58,["49"] = 58,["50"] = 58,["51"] = 58,["52"] = 58,["53"] = 58,["54"] = 58,["55"] = 58,["56"] = 58,["57"] = 58,["58"] = 63,["59"] = 64,["60"] = 65,["61"] = 67,["62"] = 68,["63"] = 70,["64"] = 71,["65"] = 74,["66"] = 75,["67"] = 75,["68"] = 75,["69"] = 76,["70"] = 77,["71"] = 75,["72"] = 75,["73"] = 79,["74"] = 79,["75"] = 79,["76"] = 80,["79"] = 81,["80"] = 82,["81"] = 79,["82"] = 79,["83"] = 84,["84"] = 84,["85"] = 84,["86"] = 85,["89"] = 86,["90"] = 84,["91"] = 84,["92"] = 57,["93"] = 96,["94"] = 96,["95"] = 96,["96"] = 96,["97"] = 96,["98"] = 97,["99"] = 97,["100"] = 97,["101"] = 97,["102"] = 97,["103"] = 98,["104"] = 98,["105"] = 98,["106"] = 98,["107"] = 98,["108"] = 99,["109"] = 99,["110"] = 99,["111"] = 99,["112"] = 99,["113"] = 102,["114"] = 103,["115"] = 104,["116"] = 104,["118"] = 102,["119"] = 107,["120"] = 108,["121"] = 108,["122"] = 109,["123"] = 109,["124"] = 110,["125"] = 110,["126"] = 111,["127"] = 112,["128"] = 107,["129"] = 115,["130"] = 117,["131"] = 115,["132"] = 122,["133"] = 124,["134"] = 127,["135"] = 127,["136"] = 127,["137"] = 128,["139"] = 131,["140"] = 134,["141"] = 134,["142"] = 134,["143"] = 135,["145"] = 138,["146"] = 139,["147"] = 140,["148"] = 141,["149"] = 142,["150"] = 142,["151"] = 142,["152"] = 142,["153"] = 142,["154"] = 142,["155"] = 142,["156"] = 143,["157"] = 144,["160"] = 147,["161"] = 122,["162"] = 150,["163"] = 151,["164"] = 152,["167"] = 153,["168"] = 154,["169"] = 154,["170"] = 154,["171"] = 154,["172"] = 154,["173"] = 154,["174"] = 154,["175"] = 155,["176"] = 156,["177"] = 150,["178"] = 159,["179"] = 160,["180"] = 159,["181"] = 167,["182"] = 168,["183"] = 169,["184"] = 170,["185"] = 170,["186"] = 170,["187"] = 170,["188"] = 173,["189"] = 174,["190"] = 177,["191"] = 178,["192"] = 179,["193"] = 180,["194"] = 183,["195"] = 184,["196"] = 185,["197"] = 186,["198"] = 188,["199"] = 189,["200"] = 167,["201"] = 192,["202"] = 193,["203"] = 194,["206"] = 195,["207"] = 193,["208"] = 197,["209"] = 197,["210"] = 197,["211"] = 198,["212"] = 198,["213"] = 198,["214"] = 198,["215"] = 198,["216"] = 198,["218"] = 200,["219"] = 200,["220"] = 200,["221"] = 201,["222"] = 201,["223"] = 201,["224"] = 201,["225"] = 201,["226"] = 201,["228"] = 192,["229"] = 205,["230"] = 205,["231"] = 205,["233"] = 206,["236"] = 207,["237"] = 208,["238"] = 208,["239"] = 208,["240"] = 208,["241"] = 208,["242"] = 208,["243"] = 208,["244"] = 208,["245"] = 208,["246"] = 208,["247"] = 208,["248"] = 208,["249"] = 208,["250"] = 209,["251"] = 209,["252"] = 209,["253"] = 209,["254"] = 209,["255"] = 209,["256"] = 209,["257"] = 210,["258"] = 210,["259"] = 210,["260"] = 210,["261"] = 210,["262"] = 212,["264"] = 213,["265"] = 213,["266"] = 214,["267"] = 215,["268"] = 216,["269"] = 217,["270"] = 218,["271"] = 218,["272"] = 218,["273"] = 218,["274"] = 217,["275"] = 219,["276"] = 219,["277"] = 219,["278"] = 219,["279"] = 217,["280"] = 217,["281"] = 217,["282"] = 217,["283"] = 213,["286"] = 205,["287"] = 226,["288"] = 226,["289"] = 230,["290"] = 231,["291"] = 233,["292"] = 234,["293"] = 236,["294"] = 237,["295"] = 238,["296"] = 239,["297"] = 230,["298"] = 242,["299"] = 244,["300"] = 245,["301"] = 246,["302"] = 247,["303"] = 248,["304"] = 249,["306"] = 251,["307"] = 251,["308"] = 251,["309"] = 251,["310"] = 251,["311"] = 242,["312"] = 254,["313"] = 255,["314"] = 256,["315"] = 257,["316"] = 258,["317"] = 259,["318"] = 260,["320"] = 262,["321"] = 263,["322"] = 263,["323"] = 263,["324"] = 263,["325"] = 263,["326"] = 263,["327"] = 254,["328"] = 268,["329"] = 269,["330"] = 270,["331"] = 271,["332"] = 270,["333"] = 273,["334"] = 274,["335"] = 274,["336"] = 274,["337"] = 274,["338"] = 274,["341"] = 276,["342"] = 276,["343"] = 276,["344"] = 276,["345"] = 276,["346"] = 276,["347"] = 276,["348"] = 276,["349"] = 276,["350"] = 276,["351"] = 277,["352"] = 277,["353"] = 277,["354"] = 277,["355"] = 277,["356"] = 277,["357"] = 277,["358"] = 277,["361"] = 279,["362"] = 268,["363"] = 282,["364"] = 283,["365"] = 284,["366"] = 286,["367"] = 287,["371"] = 291,["372"] = 292,["373"] = 293,["376"] = 296,["377"] = 297,["378"] = 282,["379"] = 300,["380"] = 301,["383"] = 302,["384"] = 303,["386"] = 300,["387"] = 307,["388"] = 308,["391"] = 309,["392"] = 310,["393"] = 311,["394"] = 312,["395"] = 313,["396"] = 314,["397"] = 315,["398"] = 316,["399"] = 316,["400"] = 317,["401"] = 317,["403"] = 318,["404"] = 307,["405"] = 321,["406"] = 322,["407"] = 323,["408"] = 324,["411"] = 325,["412"] = 326,["413"] = 327,["414"] = 328,["415"] = 329,["416"] = 330,["417"] = 321,["418"] = 333,["420"] = 334,["421"] = 335,["423"] = 336,["424"] = 336,["427"] = 337,["429"] = 338,["430"] = 338,["433"] = 339,["435"] = 340,["438"] = 341,["440"] = 342,["443"] = 343,["445"] = 344,["448"] = 345,["450"] = 346,["453"] = 347,["455"] = 348,["458"] = 349,["460"] = 350,["464"] = 352,["465"] = 333,["470"] = 90,["478"] = 93});
local ____exports = {}
local ____Dora = require("Dora")
local Color = ____Dora.Color
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Vec2 = ____Dora.Vec2
local View = ____Dora.View
local ____palette = require("core.palette")
local Palette = ____palette.Palette
local ink = ____palette.ink
local FONT = "sarasa-mono-sc-regular"
local HOLD_EPS = 12
local PAD_R = 46
local PAD_GAP = 8
local SIDE_MARGIN = 62
local BOTTOM_MARGIN = 64
____exports.TouchPad = __TS__Class()
local TouchPad = ____exports.TouchPad
TouchPad.name = "TouchPad"
function TouchPad.prototype.____constructor(self, parent)
    self.keyLabels = __TS__New(Map)
    self.ringDraws = __TS__New(Map)
    self.dirLabels = __TS__New(Map)
    self.layout = __TS__New(Map)
    self.dirLayout = __TS__New(Map)
    self.topLayout = __TS__New(Map)
    self.onAction = function()
    end
    self.onInteract = function()
    end
    self.onRewind = function()
    end
    self.onNote = function()
    end
    self.onRevive = function()
    end
    self.state = {
        left = false,
        right = false,
        up = false,
        down = false,
        jumpQueued = false,
        attackQueued = false,
        qiQueued = false,
        dashQueued = false,
        jumpHeld = false,
        attackHeld = false
    }
    self.root = Node(nil)
    self.root:addTo(parent)
    self.root.order = 900
    self.padDraw = DrawNode(nil)
    self.padDraw:addTo(self.root)
    self:buildButtons()
    self:relayout()
    self.root.touchEnabled = true
    self.root:slot(
        "TapBegan",
        function(____, touch)
            local p = self:toLocal(touch.location.x, touch.location.y)
            self:handleDown(touch.id, p.x, p.y)
        end
    )
    self.root:slot(
        "TapMoved",
        function(____, touch)
            if self.activePointer == nil or touch.id ~= self.activePointer.id then
                return
            end
            local p = self:toLocal(touch.location.x, touch.location.y)
            self:handleMove(p.x, p.y)
        end
    )
    self.root:slot(
        "TapEnded",
        function(____, touch)
            if self.activePointer == nil or touch.id ~= self.activePointer.id then
                return
            end
            self:handleUp()
        end
    )
end
function TouchPad.prototype.takeJump(self)
    local v = self.state.jumpQueued
    self.state.jumpQueued = false
    return v
end
function TouchPad.prototype.takeAttack(self)
    local v = self.state.attackQueued
    self.state.attackQueued = false
    return v
end
function TouchPad.prototype.takeQi(self)
    local v = self.state.qiQueued
    self.state.qiQueued = false
    return v
end
function TouchPad.prototype.takeDash(self)
    local v = self.state.dashQueued
    self.state.dashQueued = false
    return v
end
function TouchPad.prototype.setVisible(self, v)
    self.root.visible = v
    if not v then
        self:clearAll()
    end
end
function TouchPad.prototype.clearAll(self)
    self.state.left = false
    self.state.right = false
    self.state.up = false
    self.state.down = false
    self.state.jumpHeld = false
    self.state.attackHeld = false
    self.activePointer = nil
    self:refreshVisual()
end
function TouchPad.prototype.toLocal(self, viewX, viewY)
    return {x = viewX, y = viewY}
end
function TouchPad.prototype.buildButtons(self)
    local fight = {{"jump", "跳"}, {"attack", "攻"}, {"qi", "气"}, {"dash", "闪"}}
    for ____, ____value in ipairs(fight) do
        local key = ____value[1]
        local text = ____value[2]
        self:addLabel(key, text)
    end
    local tops = {{"interact", "E"}, {"rewind", "Q"}, {"note", "札"}, {"revive", "R"}}
    for ____, ____value in ipairs(tops) do
        local key = ____value[1]
        local text = ____value[2]
        self:addLabel(key, text)
    end
    for ____, dir in ipairs({"left", "right"}) do
        local lb = Label(nil, FONT, 30)
        if lb ~= nil then
            lb.text = dir == "left" and "◀" or "▶"
            lb.color = Color(
                nil,
                232,
                223,
                199,
                210
            )
            lb:addTo(self.root)
            self.dirLabels:set(dir, lb)
        end
    end
    self:drawAllRings()
end
function TouchPad.prototype.addLabel(self, key, text)
    local lb = Label(nil, FONT, key == "jump" and 30 or 26)
    if lb == nil then
        return
    end
    lb.text = text
    lb.color = Color(
        nil,
        232,
        223,
        199,
        215
    )
    lb:addTo(self.root)
    self.keyLabels:set(key, lb)
end
function TouchPad.prototype.buttonCenter(self, sizeW, sizeH)
    return {rightX = sizeW - SIDE_MARGIN, bottomY = BOTTOM_MARGIN, topY = sizeH - 70}
end
function TouchPad.prototype.relayout(self)
    local w = View.size.width
    local h = View.size.height
    local ____temp_0 = self:buttonCenter(w, h)
    local rightX = ____temp_0.rightX
    local bottomY = ____temp_0.bottomY
    local topY = ____temp_0.topY
    self.dirLayout:set("left", {x = SIDE_MARGIN, y = bottomY})
    self.dirLayout:set("right", {x = SIDE_MARGIN + PAD_R * 2 + PAD_GAP, y = bottomY})
    self.layout:set("jump", {x = rightX, y = bottomY + PAD_R * 2 + PAD_GAP})
    self.layout:set("attack", {x = rightX - PAD_R * 2 - PAD_GAP, y = bottomY})
    self.layout:set("qi", {x = rightX + PAD_R * 2 + PAD_GAP, y = bottomY})
    self.layout:set("dash", {x = rightX, y = bottomY})
    self.topLayout:set("interact", {x = w - SIDE_MARGIN, y = topY})
    self.topLayout:set("rewind", {x = w - SIDE_MARGIN - PAD_R * 2 - PAD_GAP, y = topY})
    self.topLayout:set("note", {x = w - SIDE_MARGIN - (PAD_R * 2 + PAD_GAP) * 2, y = topY})
    self.topLayout:set("revive", {x = w / 2, y = h * 0.35})
    self:placeLabels()
    self:drawAllRings()
end
function TouchPad.prototype.placeLabels(self)
    local function put(____, lb, pos, r)
        if lb == nil or pos == nil then
            return
        end
        lb.position = Vec2(nil, pos.x, pos.y + r * 0.36)
    end
    for ____, ____value in __TS__Iterator(self.keyLabels) do
        local key = ____value[1]
        local lb = ____value[2]
        put(
            nil,
            lb,
            self.layout:get(key) or self.topLayout:get(key),
            PAD_R
        )
    end
    for ____, ____value in __TS__Iterator(self.dirLabels) do
        local dir = ____value[1]
        local lb = ____value[2]
        put(
            nil,
            lb,
            self.dirLayout:get(dir),
            PAD_R
        )
    end
end
function TouchPad.prototype.drawRing(self, d, pos, active, radius)
    if radius == nil then
        radius = PAD_R
    end
    if d == nil or pos == nil then
        return
    end
    d:clear()
    local fill = active and ink(
        nil,
        168,
        197,
        188,
        80
    ) or ink(
        nil,
        30,
        37,
        36,
        96
    )
    local ring = active and Palette.moonCyan or ink(
        nil,
        232,
        223,
        199,
        130
    )
    d:drawDot(
        Vec2(nil, pos.x, pos.y),
        radius,
        fill
    )
    local seg = 36
    do
        local i = 0
        while i < seg do
            local a0 = i / seg * math.pi * 2
            local a1 = (i + 1) / seg * math.pi * 2
            local r0 = radius - 2
            d:drawSegment(
                Vec2(
                    nil,
                    pos.x + math.cos(a0) * r0,
                    pos.y + math.sin(a0) * r0
                ),
                Vec2(
                    nil,
                    pos.x + math.cos(a1) * r0,
                    pos.y + math.sin(a1) * r0
                ),
                2.5,
                ring
            )
            i = i + 1
        end
    end
end
function TouchPad.prototype.drawAllRings(self)
end
function TouchPad.prototype.refreshVisual(self)
    local st = self.state
    self:drawRingDir("left", st.left)
    self:drawRingDir("right", st.right)
    self:drawRingAct("jump", st.jumpHeld)
    self:drawRingAct("attack", st.attackHeld)
    self:drawRingAct("qi", st.qiQueued)
    self:drawRingAct("dash", st.dashQueued)
end
function TouchPad.prototype.drawRingDir(self, dir, active)
    local d = self.ringDraws:get(dir) or nil
    if d == nil then
        d = DrawNode(nil)
        d:addTo(self.root)
        d.order = -1
        self.ringDraws:set(dir, d)
    end
    self:drawRing(
        d,
        self.dirLayout:get(dir),
        active
    )
end
function TouchPad.prototype.drawRingAct(self, key, active)
    local d = self.ringDraws:get(key)
    if d == nil then
        d = DrawNode(nil)
        d:addTo(self.root)
        d.order = -1
        self.ringDraws:set(key, d)
    end
    local radius = key == "revive" and PAD_R + 14 or PAD_R
    self:drawRing(
        d,
        self.layout:get(key) or self.topLayout:get(key),
        active,
        radius
    )
end
function TouchPad.prototype.hitTest(self, x, y)
    local hitR = PAD_R + 18
    local function near(____, pos)
        return pos ~= nil and (x - pos.x) * (x - pos.x) + (y - pos.y) * (y - pos.y) <= hitR * hitR
    end
    for ____, dir in ipairs({"left", "right"}) do
        if near(
            nil,
            self.dirLayout:get(dir)
        ) then
            return {zone = "dir", dir = dir}
        end
    end
    for ____, key in ipairs({
        "jump",
        "attack",
        "qi",
        "dash",
        "interact",
        "rewind",
        "note",
        "revive"
    }) do
        if near(
            nil,
            self.layout:get(key)
        ) or near(
            nil,
            self.topLayout:get(key)
        ) then
            return {zone = key}
        end
    end
    return {zone = "dirNone"}
end
function TouchPad.prototype.handleDown(self, id, x, y)
    local hit = self:hitTest(x, y)
    if hit.zone == "dirNone" then
        if x < View.size.width / 2 then
            self:onInteract()
        end
        return
    end
    if hit.zone == "dir" then
        self.activePointer = {id = id, startX = x, zone = "dir"}
        self:applyDir(x)
        return
    end
    self.activePointer = {id = id, startX = x, zone = hit.zone}
    self:fireAction(hit.zone)
end
function TouchPad.prototype.handleMove(self, x, y)
    if self.activePointer == nil then
        return
    end
    if self.activePointer.zone == "dir" then
        self:applyDir(x)
    end
end
function TouchPad.prototype.handleUp(self)
    if self.activePointer == nil then
        return
    end
    local zone = self.activePointer.zone
    self.activePointer = nil
    if zone == "dir" then
        self.state.left = false
        self.state.right = false
        self.state.up = false
        self.state.down = false
    elseif zone == "jump" then
        self.state.jumpHeld = false
    elseif zone == "attack" then
        self.state.attackHeld = false
    end
    self:refreshVisual()
end
function TouchPad.prototype.applyDir(self, x)
    local leftPos = self.dirLayout:get("left")
    local rightPos = self.dirLayout:get("right")
    if leftPos == nil or rightPos == nil then
        return
    end
    local mid = (leftPos.x + rightPos.x) / 2
    self.state.left = x < mid - HOLD_EPS
    self.state.right = x > mid + HOLD_EPS
    self.state.up = false
    self.state.down = false
    self:refreshVisual()
end
function TouchPad.prototype.fireAction(self, key)
    repeat
        local ____switch73 = key
        local ____cond73 = ____switch73 == "jump"
        if ____cond73 then
            self.state.jumpQueued = true
            self.state.jumpHeld = true
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "attack"
        if ____cond73 then
            self.state.attackQueued = true
            self.state.attackHeld = true
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "qi"
        if ____cond73 then
            self.state.qiQueued = true
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "dash"
        if ____cond73 then
            self.state.dashQueued = true
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "interact"
        if ____cond73 then
            self:onInteract()
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "rewind"
        if ____cond73 then
            self:onRewind()
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "note"
        if ____cond73 then
            self:onNote()
            break
        end
        ____cond73 = ____cond73 or ____switch73 == "revive"
        if ____cond73 then
            self:onRevive()
            break
        end
    until true
    self:refreshVisual()
end
__TS__SetDescriptor(
    TouchPad.prototype,
    "pad",
    {get = function(self)
        return self.state
    end},
    true
)
__TS__SetDescriptor(
    TouchPad.prototype,
    "rootNode",
    {get = function(self)
        return self.root
    end},
    true
)
return ____exports
