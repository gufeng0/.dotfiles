# .dotfiles 项目功能整理说明

## 项目概述
这是一个个人开发环境配置仓库，核心目标是**把作者长期使用的 Shell、Neovim、Tmux、终端、桌面管理、SSH 等工作流统一管理**，并通过 `scripts/setup.sh` 自动接入系统环境。新机器或重装系统时，一键恢复完整开发环境。

## 主要功能模块

### 1. Shell (Zsh)
- `zshrc` 主入口文件
- `platform.sh` 平台适配（macOS / WSL / Linux / Termux）
- `functions.sh` 常用函数（自动激活 `.env` 虚拟环境等）
- `git.sh`、`proxy.sh`、`vi-mode` 等扩展
- 自定义别名、vi-mode 增强、Powerlevel10k 等

### 2. Neovim（最核心部分）
- 插件管理中心 `plugins.lua`（包含大量常用插件）
- 自定义模块系统（`ext-loader.lua` + `core/`、`ext/`、`misc/`、`lang/`）
- 核心功能：
  - 语言检测（Node + vscode-languagedetection）
  - 文本处理（编码转换、Markdown 包装、Cron 解析等）
  - 格式化系统（LSP + 外部工具优先级切换）
  - 剪贴板与 IME 适配（macOS/WSL/SSH）
  - 代码运行器、JSON 处理、时间机器等工具
  - 键位映射（`mappings.lua`）

### 3. 终端与窗口管理
- **Tmux**：`tmux/tmux.conf`（vi 风格、pane 切换、TPM）
- **Kitty / Alacritty / WezTerm**：配置文件
- **Hammerspoon**：macOS 窗口尺寸/位置控制

### 4. 其他配置
- SSH 配置（`ssh/config` + `config.d/*`）
- 系统服务（`services/`）
- 辅助工具（`bin/` + `submodule/`）
- Maven、Git 相关配置

## 安装方式
```bash
bash ~/.dotfiles/scripts/setup.sh
```

## 平台支持
- macOS
- WSL
- Linux
- Termux（Android）

这个仓库本质上是一个**长期沉淀的工作流闭环配置**，不是单纯的配置合集，而是作者完整开发环境的工程化管理。

---

**更新时间**：2026-08-05

如果需要更详细的模块说明或某部分功能的深入说明，请告诉我！