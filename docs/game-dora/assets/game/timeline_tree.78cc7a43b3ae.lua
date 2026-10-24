local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 5,["8"] = 5,["10"] = 24,["11"] = 24,["12"] = 24,["13"] = 37,["14"] = 38,["15"] = 39,["16"] = 40,["17"] = 41,["18"] = 42,["19"] = 42,["20"] = 42,["21"] = 42,["22"] = 42,["23"] = 42,["24"] = 42,["25"] = 42,["26"] = 50,["27"] = 51,["28"] = 52,["29"] = 37,["30"] = 56,["31"] = 57,["32"] = 58,["35"] = 61,["36"] = 62,["37"] = 62,["38"] = 62,["40"] = 62,["42"] = 62,["43"] = 63,["44"] = 64,["45"] = 64,["46"] = 64,["47"] = 64,["48"] = 64,["49"] = 64,["50"] = 64,["51"] = 64,["52"] = 72,["53"] = 73,["54"] = 74,["55"] = 75,["56"] = 76,["57"] = 77,["59"] = 56,["60"] = 82,["61"] = 83,["62"] = 84,["65"] = 87,["66"] = 87,["67"] = 87,["68"] = 87,["69"] = 87,["70"] = 87,["71"] = 87,["72"] = 87,["73"] = 95,["74"] = 96,["75"] = 97,["76"] = 98,["77"] = 99,["79"] = 82,["80"] = 104,["81"] = 105,["82"] = 106,["85"] = 109,["86"] = 110,["87"] = 111,["88"] = 112,["90"] = 104,["91"] = 117,["92"] = 118,["95"] = 121,["96"] = 122,["97"] = 123,["98"] = 124,["100"] = 117,["101"] = 129,["102"] = 130,["105"] = 133,["106"] = 129,["107"] = 137,["108"] = 138,["109"] = 137,["110"] = 142,["111"] = 143,["112"] = 142,["113"] = 147,["114"] = 148,["115"] = 149,["116"] = 147,["117"] = 152,["119"] = 153,["120"] = 153,["121"] = 154,["122"] = 155,["124"] = 153,["127"] = 158,["128"] = 152,["129"] = 162,["130"] = 163,["131"] = 164,["132"] = 165,["133"] = 166,["134"] = 167,["135"] = 167,["136"] = 167,["138"] = 167,["140"] = 167,["142"] = 169,["143"] = 162});
local ____exports = {}
local ____tree_overlay = require("ui.tree_overlay")
local TreeOverlay = ____tree_overlay.TreeOverlay
--- 时空树系统：纯数据 + 轻量浮层控制，读档回溯由游戏层通过 onJumpTo 对接
____exports.TreeSystem = __TS__Class()
local TreeSystem = ____exports.TreeSystem
TreeSystem.name = "TreeSystem"
function TreeSystem.prototype.____constructor(self, rootVia)
    self.seq = 1
    self.noKill = false
    self.rewindCount = 0
    self.nodes = {}
    local root = {
        id = "tn0",
        parent = "",
        via = rootVia,
        phase = 0,
        depth = 0,
        abandoned = false
    }
    self.nodes:push(root)
    self.currentId = root.id
    self.overlay = nil
end
function TreeSystem.prototype.addChoice(self, via)
    local cur = self:findById(self.currentId)
    if cur == nil then
        return
    end
    local parentId = cur.parent
    local ____temp_0
    if parentId == "" then
        ____temp_0 = nil
    else
        ____temp_0 = self:findById(parentId)
    end
    local parent = ____temp_0
    local parentDepth = parent ~= nil and parent.depth or 0
    local node = {
        id = "tn" .. "" .. tostring(self.seq),
        parent = parentId,
        via = via,
        phase = (parentDepth + 1) % 8,
        depth = parentDepth + 1,
        abandoned = false
    }
    self.seq = self.seq + 1
    cur.abandoned = true
    self.nodes:push(node)
    self.currentId = node.id
    if self.onNodeAdded ~= nil then
        self:onNodeAdded(node.id)
    end
end
function TreeSystem.prototype.extend(self, via)
    local cur = self:findById(self.currentId)
    if cur == nil then
        return
    end
    local node = {
        id = "tn" .. "" .. tostring(self.seq),
        parent = cur.id,
        via = via,
        phase = (cur.depth + 1) % 8,
        depth = cur.depth + 1,
        abandoned = false
    }
    self.seq = self.seq + 1
    self.nodes:push(node)
    self.currentId = node.id
    if self.onNodeAdded ~= nil then
        self:onNodeAdded(node.id)
    end
end
function TreeSystem.prototype.jumpTo(self, id)
    local node = self:findById(id)
    if node == nil then
        return
    end
    self.currentId = id
    self.rewindCount = self.rewindCount + 1
    if self.overlay ~= nil and self.overlay:isOpen() then
        self.overlay:close()
    end
end
function TreeSystem.prototype.handleKey(self, key)
    if self.overlay == nil then
        return
    end
    if key == "T" then
        self.overlay:toggle(self)
    elseif key == "Escape" and self.overlay:isOpen() then
        self.overlay:close()
    end
end
function TreeSystem.prototype.attachTo(self, parent)
    if self.overlay ~= nil then
        return
    end
    self.overlay = __TS__New(TreeOverlay, parent)
end
function TreeSystem.prototype.isOverlayOpen(self)
    return self.overlay ~= nil and self.overlay:isOpen()
end
function TreeSystem.prototype.setStats(self, noKill)
    self.noKill = noKill
end
function TreeSystem.prototype.getStats(self)
    local noKillText = self.noKill and "达成" or "未达成"
    return (((("共 " .. tostring(#self.nodes)) .. " 条枝 · 回溯 ") .. tostring(self.rewindCount)) .. " 次 · 不杀：") .. noKillText
end
function TreeSystem.prototype.findById(self, id)
    do
        local i = 0
        while i < #self.nodes do
            if self.nodes[i + 1].id == id then
                return self.nodes[i + 1]
            end
            i = i + 1
        end
    end
    return nil
end
function TreeSystem.prototype.currentChain(self)
    local chain = {}
    local cur = self:findById(self.currentId)
    while cur ~= nil do
        chain:unshift(cur.id)
        local ____temp_1
        if cur.parent == "" then
            ____temp_1 = nil
        else
            ____temp_1 = self:findById(cur.parent)
        end
        cur = ____temp_1
    end
    return chain
end
return ____exports
