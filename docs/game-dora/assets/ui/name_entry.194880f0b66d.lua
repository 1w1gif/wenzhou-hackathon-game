local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 3,["7"] = 3,["8"] = 3,["9"] = 3,["10"] = 3,["11"] = 3,["12"] = 3,["13"] = 4,["14"] = 4,["15"] = 5,["16"] = 5,["17"] = 5,["18"] = 7,["19"] = 10,["20"] = 11,["21"] = 12,["22"] = 13,["24"] = 15,["25"] = 10,["26"] = 17,["28"] = 20,["29"] = 21,["30"] = 22,["31"] = 23,["33"] = 25,["34"] = 20,["36"] = 29,["37"] = 30,["39"] = 31,["40"] = 31,["41"] = 32,["42"] = 33,["44"] = 31,["47"] = 36,["48"] = 29,["49"] = 39,["50"] = 39,["51"] = 39,["52"] = 51,["53"] = 52,["54"] = 53,["55"] = 54,["56"] = 55,["57"] = 56,["58"] = 57,["59"] = 58,["60"] = 59,["61"] = 60,["62"] = 61,["63"] = 62,["64"] = 63,["65"] = 64,["66"] = 65,["67"] = 66,["68"] = 67,["69"] = 67,["70"] = 67,["71"] = 67,["72"] = 67,["73"] = 67,["74"] = 67,["75"] = 67,["76"] = 67,["77"] = 69,["78"] = 70,["79"] = 71,["80"] = 72,["81"] = 73,["82"] = 74,["83"] = 75,["84"] = 76,["85"] = 77,["86"] = 78,["88"] = 80,["89"] = 81,["90"] = 82,["91"] = 83,["92"] = 84,["93"] = 85,["94"] = 86,["95"] = 87,["97"] = 90,["98"] = 91,["99"] = 92,["100"] = 93,["101"] = 94,["102"] = 95,["103"] = 96,["105"] = 99,["106"] = 100,["107"] = 101,["108"] = 102,["111"] = 105,["112"] = 106,["113"] = 107,["115"] = 101,["116"] = 111,["117"] = 112,["118"] = 113,["120"] = 115,["121"] = 116,["122"] = 117,["123"] = 118,["124"] = 119,["126"] = 121,["127"] = 111,["128"] = 51,["129"] = 125,["130"] = 126,["131"] = 127,["132"] = 128,["133"] = 129,["134"] = 130,["135"] = 131,["136"] = 132,["137"] = 125,["138"] = 135,["139"] = 136,["140"] = 137,["141"] = 138,["142"] = 139,["143"] = 140,["144"] = 135,["145"] = 143,["146"] = 144,["147"] = 143,["148"] = 148,["149"] = 149,["152"] = 152,["153"] = 153,["154"] = 154,["155"] = 155,["156"] = 156,["157"] = 157,["158"] = 158,["160"] = 160,["161"] = 161,["162"] = 162,["163"] = 163,["164"] = 164,["166"] = 166,["167"] = 167,["168"] = 168,["170"] = 148,["171"] = 172,["172"] = 173,["173"] = 174,["175"] = 176,["176"] = 172,["177"] = 180,["178"] = 181,["179"] = 182,["182"] = 185,["183"] = 186,["184"] = 186,["185"] = 186,["186"] = 186,["187"] = 186,["188"] = 186,["189"] = 180});
local ____exports = {}
local ____Dora = require("Dora")
local Color = ____Dora.Color
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Vec2 = ____Dora.Vec2
local View = ____Dora.View
local ____tech_ui = require("ui.tech_ui")
local makeTechPanel = ____tech_ui.makeTechPanel
local ____archive = require("core.archive")
local DEFAULT_NAME = ____archive.DEFAULT_NAME
local sanitizeName = ____archive.sanitizeName
local FONT = "assets/font/DialogFont.ttf"
local function makeText(size)
    local lb = Label(FONT, size)
    if lb == nil then
        lb = Label("sarasa-mono-sc-regular", size)
    end
    return lb
end
local NAME_MAX = 12
--- 删去字符串最后一个 UTF-8 字符（Lua 字符串按字节处理）
local function deleteLastChar(s)
    local i = #s - 1
    while i > 0 and s:charCodeAt(i) & 192 == 128 do
        i = i - 1
    end
    return i <= 0 and "" or s:substring(0, i)
end
--- 统计 UTF-8 字符数
local function charCount(s)
    local n = 0
    do
        local i = 0
        while i < #s do
            if s:charCodeAt(i) & 192 ~= 128 then
                n = n + 1
            end
            i = i + 1
        end
    end
    return n
end
____exports.NameEntry = __TS__Class()
local NameEntry = ____exports.NameEntry
NameEntry.name = "NameEntry"
function NameEntry.prototype.____constructor(self, parent)
    self.openFlag = false
    self.buf = ""
    self.caretT = 0
    self.caretVisible = true
    self.onConfirm = nil
    self.onCancel = nil
    self.root = Node()
    self.root:addTo(parent)
    self.root.visible = false
    local w = View.size.width
    local h = View.size.height
    local hw = w / 2
    local hh = h / 2
    local bg = DrawNode()
    bg:addTo(self.root)
    bg:drawPolygon(
        {
            Vec2(-hw, -hh),
            Vec2(hw, -hh),
            Vec2(hw, hh),
            Vec2(-hw, hh)
        },
        Color(0, 0, 0, 200)
    )
    local pw = 560
    local ph = 300
    makeTechPanel(self.root, pw, ph)
    local title = makeText(26)
    if title ~= nil then
        title.text = "刻下旅人之名"
        title.anchor = Vec2(0.5, 0.5)
        title.position = Vec2(0, 84)
        title.color = Color(255, 255, 255, 255)
        title:addTo(self.root)
    end
    self.bufDraw = DrawNode()
    self.bufDraw:addTo(self.root)
    self.bufLb = makeText(34)
    if self.bufLb ~= nil then
        self.bufLb.anchor = Vec2(0.5, 0.5)
        self.bufLb.position = Vec2(0, 12)
        self.bufLb.color = Color(255, 255, 255, 255)
        self.bufLb:addTo(self.root)
    end
    local hint2 = makeText(15)
    if hint2 ~= nil then
        hint2.text = ("名字将随你的时空树一起留入仓库（留空则名为「" .. DEFAULT_NAME) .. "」）"
        hint2.anchor = Vec2(0.5, 0.5)
        hint2.position = Vec2(0, -66)
        hint2.color = Color(255, 255, 255, 255)
        hint2:addTo(self.root)
    end
    self.inputNode = Node()
    self.inputNode:addTo(self.root)
    self.inputNode:onTextInput(function(text)
        if not self.openFlag or text == nil then
            return
        end
        if charCount(self.buf .. text) <= NAME_MAX then
            self.buf = self.buf .. text
            self:renderBuf()
        end
    end)
    self.inputNode:schedule(function(dt)
        if not self.openFlag then
            return false
        end
        self.caretT = self.caretT + dt
        if self.caretT >= 0.5 then
            self.caretT = 0
            self.caretVisible = not self.caretVisible
            self:drawCaret()
        end
        return false
    end)
end
function NameEntry.prototype.open(self, prefill, onConfirm, onCancel)
    self.openFlag = true
    self.buf = sanitizeName(prefill, NAME_MAX)
    self.onConfirm = onConfirm
    self.onCancel = onCancel
    self.root.visible = true
    self.inputNode:attachIME()
    self:renderBuf()
end
function NameEntry.prototype.close(self)
    self.openFlag = false
    self.root.visible = false
    self.inputNode:detachIME()
    self.onConfirm = nil
    self.onCancel = nil
end
function NameEntry.prototype.isOpen(self)
    return self.openFlag
end
function NameEntry.prototype.handleKey(self, key)
    if not self.openFlag then
        return
    end
    if key == "Return" then
        local name = sanitizeName(self.buf, NAME_MAX)
        local finalName = name == "" and DEFAULT_NAME or name
        local cb = self.onConfirm
        self:close()
        if cb ~= nil then
            cb(finalName)
        end
    elseif key == "Escape" then
        local cb = self.onCancel
        self:close()
        if cb ~= nil then
            cb()
        end
    elseif key == "BackSpace" then
        self.buf = deleteLastChar(self.buf)
        self:renderBuf()
    end
end
function NameEntry.prototype.renderBuf(self)
    if self.bufLb ~= nil then
        self.bufLb.text = self.buf
    end
    self:drawCaret()
end
function NameEntry.prototype.drawCaret(self)
    self.bufDraw:clear()
    if not self.openFlag or not self.caretVisible or self.bufLb == nil then
        return
    end
    local x = self.bufLb.width * 0.5 + 6
    self.bufDraw:drawSegment(
        Vec2(x, -6),
        Vec2(x, 30),
        1.5,
        Color(255, 255, 255, 220)
    )
end
return ____exports
