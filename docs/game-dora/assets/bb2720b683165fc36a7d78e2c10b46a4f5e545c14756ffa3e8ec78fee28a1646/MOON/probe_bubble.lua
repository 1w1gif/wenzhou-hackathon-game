-- probe_bubble.lua — 气泡素材尺寸探针：读 assets/ui 两张 tilemap 尺寸写 test-results/bubble_dims.txt
-- entry 环境模块需显式 require；命令沙箱不可用，故由 enterEntryAsync 跑本文件
local Content = require("Content")
local Path = require("Path")
local Texture2D = require("Texture2D")
local root = nil
for i = 0, 7 do
  local p = Content.searchPaths[i]
  if p ~= nil and Content:exist(Path(p, ".agent")) then
    root = p
    break
  end
end
assert(root ~= nil, "project root not found in searchPaths")

local names = { "assets/ui/bubble_single.png", "assets/ui/bubble_multi.png" }
local lines = {}
for _, name in ipairs(names) do
  local tex = Texture2D(name)
  if tex == nil then
    lines[#lines + 1] = name .. " nil"
  else
    lines[#lines + 1] = name .. " " .. tex.width .. "x" .. tex.height
  end
end
local data = table.concat(lines, "\n")
assert(Content:save(Path(root, ".agent/test-results/bubble_dims.txt"), data), "save dims failed")
print("probe_bubble done: " .. data)