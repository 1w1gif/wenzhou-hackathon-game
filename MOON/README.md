# MOON —— 《衍月·八相》Dora SSR 像素版

## 运行

- 用 Dora SSR 编辑器打开本目录（`MOON/MOON/`），入口为 `init.lua`（由 `init.ts` 编译）。
- 运行时引擎提供 `require("Dora")`，无需额外依赖。

## 构建（改完 TS 必须重新编译！）

```bash
cd MOON            # 仓库内 MOON/（package.json 所在层）
npm install        # 已装过可跳过
npm run build      # TS -> Lua，输出到 MOON/MOON/ 各目录
npm run typecheck  # 仅类型检查
```

> 历史教训：`ui/dialog.ts` 曾修过"选项对话卡死"但没有重新编译，
> 运行的 `dialog.lua` 仍是旧逻辑，导致第一个选项剧情必然卡死。
> 任何 TS 改动都要 `npm run build` 后再测。

## 工具链说明

- 编译器：typescript-to-lua（tstl 1.37），配置在 `MOON/tsconfig.json`。
- `MOON/Dora.d.ts` 是手写的运行时类型桩（只覆盖项目用到的 API），
  `Dora` 模块在 tstl 中通过 `noResolvePaths` 跳过解析，运行时由引擎提供。
- `lualib_bundle.lua` 是 tstl 生成的 TS 运行时库，随 `init.lua` 一同加载。

## 已修复的问题（2026-10-20 打磨）

P0（打不通流程）：
1. 选项对话卡死：`dialog.ts` 的修复这次真正编译进了 `dialog.lua`。
2. `gate_workshop` 死门：2 层这扇门原本无任何机关可开，现由灯笼谜题完成时一并开启。
3. 推石方向传死值 0：推石机关此前永远推不动，现读取玩家实际移动方向。
4. 对峙沈砚位置：Boss 战后沈砚站在 5 层高度而装置在 6 层，"放下剑"无法达成；
   现在对峙时他站在观星台地面（`TOPS[6]`）。
5. 回溯清空信任：`loopAdvance` 原本把信任归零，导致信任永远攒不够 4；
   现在信任跨周目保留（这正是多周目设计的意义）。
6. 观测者剧情断线：`story_observer_1/2` 无触发器，现接入 5 层两处。
7. `story_arrow` 无法重触发：加 `repeatCd` 冷却机制（8 秒），回溯后可再选挡箭。

P1（体验）：
- HUD 右上新增"砚·信任 x / 4"，满信任变青色。
- 对峙开打切 `conflict` BGM，回溯结束回 `wuxia`。
- N 键也可打开引月札（文案与按键终于一致）。
- 死亡画面提示按 R 复活。
- 副标题错字"把她救回来"→"把他救回来"（救的是沈砚）。
- 坠落虚空时无敌帧不再吞掉扣血；删除永远触发不到的 `y<-240` 双重判定。

P2（手感/卫生）：
- 序章开始 0.15s 内不响应跳过键（防止"按空格开始"直接跳过序章）。
- `beginLoop` 兜底防双触发；st0/st1 剧情触发区不再重叠。
- 手札检查点显示层名（"悬空工坊·悬空工坊"式友好名）而非内部 id。
- 清理死代码：`rewindTimeline`、`attackChainCd` 恒真式。

## 待办（后续素材包到位后）

- dash 音效独立（现与 sword 共用 `sfx-sword-draw.mp3`，见 `game/audio.ts` 注释）。
- 潜行系统：`stealthAlert/sneakBonus` 状态已留在账本里，但无对应玩法。
- `assets/bg/`、`assets/tiles/` 的视差背景与瓦片集大部分未接入渲染。
