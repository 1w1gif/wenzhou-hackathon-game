# Phaser 黑客松模板（温州小侦探）

一个最小可玩的 Phaser 3/4 + Vite 2D 收集游戏，作为黑客松通用模板。

## 运行

```bash
npm install
npm run dev
```

浏览器打开 http://localhost:5173

## 玩法

- 方向键或 WASD 移动
- 30 秒内收集 5 个鱼丸 → 胜利
- 碰到红色捣蛋鬼 → 失败
- 胜利/失败后可重新开始

## 文件结构

```text
src/
├── main.js               # 游戏配置和场景注册
└── scenes/
    ├── MenuScene.js      # 开始菜单
    ├── GameScene.js      # 核心玩法：移动/收集/障碍/倒计时
    └── ResultScene.js    # 胜利失败界面 + 重新开始
```

## 赛题公布后要改什么

1. `MenuScene.js`：改标题和说明文字
2. `GameScene.js`：改收集物数量、倒计时、颜色/图片、速度
3. `ResultScene.js`：改结算文字
4. 素材：目前用运行时生成的白色方块（`block` 纹理），把 `create(x, y, 'block')` 换成 `this.load.image` 加载的图片即可

## 构建

```bash
npm run build   # 产出 dist/，即最终提交的网页版本
```

## 团队协作（两台电脑）

```bash
git pull        # 开始工作前
# ...改代码...
git add . && git commit -m "..." && git push
```

- 队友 A 负责 `GameScene.js`（玩法）
- 队友 B 负责 `MenuScene/ResultScene`（UI）和素材
- 不要同时改同一个文件

### 已确认可协作的成员

- 蓝婷婷（1948959676@qq.com）— 2026-10-18 通过 README 测试提交验证推送链路，见下方"协作测试记录"

### 协作测试记录

| 时间 | 操作人 | 内容 |
|------|--------|------|
| 2026-10-18 | 蓝婷婷 | 首次推送测试：在 README 增加本节，验证 clone/pull/commit/push 全链路 |

## 注意

- npm 安装慢时加 `--registry=https://registry.npmmirror.com`
- 本机环境：Node v24.19.0、Phaser 4.2.1、Vite 8
