# dotfiles

这是一个个人开发环境仓库，用来统一管理作者在不同平台上的 Shell、Neovim、终端、窗口管理、JetBrains Vim 键位、SSH、系统服务以及一批日常辅助脚本。

它不是一个传统意义上的应用服务、Web 项目、SDK 或类库，而是一套“把开发环境本身纳入版本管理”的工程化配置集合。这个仓库的目标不是提供某个单一功能，而是把作者长期使用的工作流完整固化下来，让一台新机器可以较快恢复到熟悉的开发状态。

---

## 1. 这个项目本质上是做什么的

这个仓库的核心用途，可以概括成一句话：

**把个人开发环境当成一个项目来维护。**

也就是说，作者不是把配置分散写在系统各处，而是把这些内容集中放进仓库：

- Shell 入口和命令行习惯
- Neovim 的插件、映射、自定义命令和语言支持
- tmux、kitty、alacritty、wezterm 等终端层配置
- macOS 的 Hammerspoon 窗口管理
- JetBrains 的 IdeaVim 键位体系
- SSH 配置和部分系统服务配置
- 一些辅助脚本、小工具和平台相关二进制

这样做的收益是：

1. **新环境恢复更快**
   换电脑、重装系统、切换 WSL 或 Linux 主机时，不需要重新手配整套环境。

2. **多平台行为尽量一致**
   macOS、Linux、WSL、Termux、Windows 协作场景下，尽量保留同一套操作习惯。

3. **工作流可持续演进**
   配置不只是“能用就行”，而是像维护代码一样持续迭代、回滚、同步和整理。

4. **编辑器、终端、Shell 之间形成统一体验**
   这个仓库最明显的特点之一，是大量工具都围绕 Vim/Vi 风格进行对齐，而不是各自独立设计。

---

## 2. 这个项目解决了哪些问题

### 2.1 统一分散的系统配置

常见的 dotfiles 问题是：
- 配置散落在 `~/.zshrc`、`~/.config/nvim`、`~/.tmux.conf`、`~/.ssh/config` 等多个位置
- 每台机器手动改动后，彼此很难同步
- 某些平台上的特殊处理容易忘掉

这个仓库通过把这些内容集中到 `~/.dotfiles` 下，再由安装脚本统一链接到用户目录，解决了这类问题。

### 2.2 把“搭环境”变成可重复执行的流程

仓库中的 `scripts/setup.sh` 不只是一个简单的安装脚本，它承担的是“把仓库接入系统环境”的职责。它会按需：

- 安装部分系统依赖
- 建立软链接
- 复制一些配置文件到用户目录
- 初始化 tmux 插件管理器
- 接入 Neovim、zsh、kitty、alacritty、Hammerspoon、SSH 等配置

这意味着：

- 这个仓库是配置的**源头**
- 用户目录中的很多配置只是指向它的链接
- 修改仓库内容，本质上就是在修改正在使用的环境

### 2.3 在多种运行环境里保留相同的习惯

从仓库中的平台分支判断可以看出，这套配置显式考虑了：

- macOS
- GNU/Linux
- WSL
- Android / Termux
- Windows 协作场景
- SSH 远程会话
- kitty / GUI / Neovide 等不同终端或界面形态

项目并不追求“所有平台完全一样”，而是追求：

**在承认平台差异的前提下，把高频使用体验做得尽量一致。**

例如：
- 剪贴板会按 macOS / WSL / SSH / kitty 分别接入不同实现
- Git 在 WSL 的 Windows 路径下会切换到 `git.exe`
- 不同平台会注入不同 PATH 和别名
- GUI/Neovide 与终端版 Neovim 的字体和输入法行为不同

---

## 3. 整个项目的运行模型

这个仓库的运行方式不是“启动一个程序”，而是“多个工具在启动时共同读取这里的配置”。

可以把它理解为下面这条链路：

1. **仓库提供配置源文件**
2. **安装脚本把这些文件接入到用户环境**
3. **不同程序启动时，读取它们对应的配置入口**
4. **配置代码再根据当前平台和上下文选择具体行为**

例如：

- 登录 shell 时读取 `zshrc`
- 打开 Neovim 时读取 `vim/init.lua`
- 打开 tmux 时读取 `tmux/tmux.conf`
- 打开 kitty 时读取 `kitty/kitty.conf`
- 在 macOS 启动 Hammerspoon 时读取 `hammerspoon/init.lua`
- 在 JetBrains 中启用 IdeaVim 时读取 `ideavimrc`

因此，这个仓库并不是“一份配置文件”，而是一组围绕日常开发工具协同工作的入口集合。

---

## 4. 安装层：项目如何把自己接入系统

### 4.1 主入口：`scripts/setup.sh`

`scripts/setup.sh` 是整个仓库的安装入口。它负责把 repo 内的内容连接到实际使用环境中。

从它的行为看，setup 阶段主要做这几件事：

- 询问是否开启 HTTP 代理
- 在 Linux 上按需安装 apt 依赖
- 配置 pip 镜像
- 建立或复制常用配置到用户目录
- 安装 tmux 插件管理器 TPM
- 接入 Neovim、zsh、tmux、kitty、alacritty、Hammerspoon、SSH 等配置
- 安装 pip/npm 层面的额外依赖

被接入的目标大致包括：

- `~/.zshrc`
- `~/.ideavimrc`
- `~/.tmux.conf`
- `~/.config/nvim`
- `~/.config/kitty/kitty.conf`
- `~/.config/alacritty/alacritty.yml`
- `~/.ssh/config`
- `~/.gitconfig`
- `~/.pip/pip.conf`
- `~/.aria2/aria2.conf`
- `~/.hammerspoon`

这说明该项目的“安装”并不是构建产物，而是把工作环境整体挂载到系统上。

### 4.2 依赖安装脚本

项目中还包含几类配套脚本：

- `scripts/install-debian-base-packages.sh`
  安装 Linux 下的基础开发工具，如 `neovim`、`zsh`、`ripgrep`、`tmux`、`nodejs`、`python3` 等。

- `scripts/apt-requirements.sh`
  安装一批作者常用系统工具，例如 `fzf`、`docker`、`docker-compose`。

- `scripts/pip3-requirements.sh`
  安装 Python 侧工具，如 `pynvim`、`neovim-remote`、`autopep8` 等。

- `scripts/npm-requirements.sh`
  安装全局 npm 工具，如 `curlconverter`、`sql-formatter`。

这几部分说明：这个仓库不仅保存“配置文本”，也保存“让配置真正跑起来所需的依赖入口”。

---

## 5. Neovim：仓库中最核心、最像“主程序”的部分

在整个仓库中，`vim/` 是最复杂、最系统化的一块。相比其他目录，它更像一个真正具有内部架构的程序。

### 5.1 启动入口

Neovim 的入口是 `vim/init.lua`。

启动流程大致是：

1. 启用 `vim.loader`
2. 检查并引导 `lazy.nvim`
3. 将 `lazy.nvim` 加入 runtime path
4. 顺序加载一组核心模块：
   - `lu5je0.options`
   - `lu5je0.mappings`
   - `lu5je0.plugins`
   - `lu5je0.ext-loader`
   - `lu5je0.commands`
   - `lu5je0.autocmds`
   - `lu5je0.filetype`
5. 最后执行 `functions.vim`

这里可以看出，作者把 Neovim 配置按职责拆分，而不是把所有逻辑堆进一个大文件。

### 5.2 模块分层

`vim/lua/lu5je0/` 大体可以分成几层：

- `core/`：编辑器基础能力和通用设施
- `ext/`：插件整合与扩展层
- `misc/`：各种独立的小功能和工具型模块
- `lang/`：语言相关逻辑

这是比较清晰的“平台层 + 业务层 + 工具层”式划分。

#### `core/` 更偏基础设施

例如：
- 窗口、缓冲区、文件树
- 按键辅助
- 光标、视觉选择等基础行为

这类模块通常不直接代表某个插件，而是为其他模块提供基础能力。

#### `ext/` 更偏插件集成层

这里对应的是“把第三方插件接进工作流”，比如：
- `toggleterm.nvim`
- `gitsigns.nvim`
- `telescope.nvim`
- `nvim-tree`
- `blink.cmp`
- `which-key.nvim`
- `oil.nvim`
- `undotree`
- `visual-multi`
- `Comment.nvim`

也就是说，插件并不是孤立存在，而是通过 `ext/` 转化成符合作者习惯的行为。

#### `misc/` 更像个人工具箱

这个目录中放了很多作者长期沉淀下来的“编辑器内能力”，例如：
- 编码转换
- 命名风格转换
- 时间/时间机器功能
- 格式化能力
- 剪贴板实现
- 环境记忆
- 文本处理
- 运行代码
- JSON 处理

它们很多不是第三方插件原生提供的，而是作者自己的工作流积累。

---

## 6. Neovim 里最关键的设计：不只是插件懒加载，还有自定义功能懒加载

### 6.1 `plugins.lua`：插件注册中心

`vim/lua/lu5je0/plugins.lua` 是插件层的主入口。

这里定义了大量插件的：
- 加载时机（`event` / `cmd` / `keys`）
- 依赖关系
- 配置入口
- 某些插件的锁定或版本策略

这部分是典型的 `lazy.nvim` 用法，但它并不是这个项目最特别的地方。

### 6.2 `ext-loader.lua`：自定义能力的延迟加载器

这个项目比较有特点的一点，是 `vim/lua/lu5je0/ext-loader.lua`。

它自己实现了一层“内部模块懒加载”机制，支持基于：

- 命令触发
- 按键触发
- 事件触发

来加载作者自己写的模块。

这意味着：

- 懒加载的不只是插件
- 仓库内部自定义功能也按需加载
- 配置启动阶段可以保持较轻量
- 很多“不是每次都要用到”的功能，直到真正触发才初始化

这让整个 Neovim 配置从“静态配置集合”变成了“具备按需激活能力的系统”。

### 6.3 通过这层懒加载器接入的能力

从 `ext-loader.lua` 中可以看到，一些功能就是通过这套机制接入的，例如：

- IME/输入法相关处理
- JSON 辅助能力
- junkfile 功能
- 格式化系统
- 变量命名风格转换
- 代码运行器
- quit prompt

这说明作者在架构上把“常驻基础配置”和“按需功能模块”区分得比较清楚。

---

## 7. Neovim 中的几个重要子系统

### 7.1 环境检测与平台适配：`options.lua`

`vim/lua/lu5je0/options.lua` 是这套配置非常关键的一个文件。

它不仅设置普通 editor option，还统一封装了环境感知逻辑。比如：
- `gui`
- `wsl`
- `ssh_client`
- `kitty`

这些特性会影响：

- GUI 字体和 Neovide 行为
- 剪贴板接入方式
- SSH 下是否使用 OSC52
- macOS / WSL 下的特殊逻辑
- Python host 的选择

这意味着这个文件并不是“纯样式配置”，而是 **Neovim 运行环境的分发中心**。

### 7.2 文件类型识别：`filetype.lua`

`vim/lua/lu5je0/filetype.lua` 针对这个 dotfiles 仓库做了额外识别，比如：

- `zshrc` / `.zshrc` 识别为 shell
- `kitty.conf` 识别为 config
- `ssh/config` 识别为 sshconfig
- `services/*` 识别为 systemd
- `*.tmux.conf` 识别为 tmux

这个文件的价值在于：

**作者不仅在使用编辑器，还在让编辑器更好地理解“这个仓库本身”。**

### 7.3 自动命令：`autocmds.lua`

这里定义了很多全局编辑行为，例如：

- 关闭自动注释续行
- 打开文件后恢复上次光标位置
- yank 高亮
- 根据模式切换 `Visual` 高亮样式
- 为 help buffer 提供更贴合当前窗口的打开逻辑

这些内容体现的是“交互体验层”的打磨，而不只是功能堆叠。

### 7.4 按键系统：`mappings.lua`

`vim/lua/lu5je0/mappings.lua` 定义了大量操作习惯，包括：

- 光标移动和窗口切换
- 选区搜索
- 路径切换
- 行为开关（wrap、number、mouse、ignorecase 等）
- 快速文本操作
- 调用语言检测
- 与 terminal、buffer、window 的协作

这说明作者不是简单接受默认键位，而是围绕自己的操作流重组了编辑行为。

### 7.5 自定义命令系统：`commands.lua`

这个文件里定义了大量编辑器内命令，例如：

- `Sum`
- `CronParser`
- `QrCodeEncode`
- `RemoveOldfiles`
- `CurlConvert`
- `FileEncodingReload`
- `UnicodeEncode` / `UnicodeDecode`
- `UrlEncode` / `UrlDecode`
- `HtmlEncode` / `HtmlDecode`
- `MarkdownLink`
- `MarkdownBold`
- `Escape`

这些命令有个共同点：

**它们把平时可能要切到 shell 或网页工具里完成的工作，拉回到了编辑器内部。**

这使得 Neovim 在这个仓库里，不只是代码编辑器，还是一个文本处理工作台。

---

## 8. 格式化系统：支持 LSP 与外部工具的优先级切换

`vim/lua/lu5je0/misc/formatter/formatter.lua` 说明作者没有把格式化完全交给某一个插件或某一种方案，而是做了一个统一入口。

它的特点是：

1. 提供统一的 `format` / `range format` 调用方式
2. 能判断当前缓冲区挂载的 LSP 是否支持格式化
3. 能根据 filetype 在 **LSP** 和 **外部工具** 之间按优先级选择
4. 能保存并恢复光标位置，减少格式化过程对编辑体验的干扰

在 `ext-loader.lua` 中还能看到外部工具映射，比如：

- `shfmt`：shell
- `black`：Python
- `prettier`：HTML / YAML / Markdown / JavaScript
- `sql-formatter`：SQL
- `xmllint`：XML

这类设计的价值是：

- 不同语言不必强行统一到同一种格式化机制
- 作者可以根据语言选择更顺手或更稳定的方案
- 统一快捷键入口，但底层保留差异化实现

---

## 9. 终端集成：编辑器和 shell 不是割裂的

### 9.1 `toggleterm` 是 Neovim 内部终端基础设施

`vim/lua/lu5je0/ext/terminal.lua` 负责接入 `toggleterm.nvim`。

这部分不仅仅是“能打开一个终端”，它实际上定义了：

- 终端打开/关闭映射
- 终端方向（horizontal / vertical / float）
- 终端窗口和普通窗口之间的切换方式
- terminal mode 的保持策略
- lazygit 的集成入口

因此，terminal 在这里是工作流的一部分，而不是插件摆设。

### 9.2 代码运行器：在编辑器内直接运行当前文件

`vim/lua/lu5je0/misc/code-runner.lua` 提供了基于 filetype 的运行逻辑。

它会根据当前文件类型执行不同命令，例如：

- Lua：`luajit` 或 `luafile %`
- C：`gcc` 后运行产物
- JavaScript：`node`
- TypeScript：`bun`
- Go：`go run`
- Python：`python3`
- Rust：`cargo run`
- Shell：`bash`
- Markdown：`MarkdownPreview`

而这些命令不是直接塞进当前 shell，而是通过 terminal 模块发送到 Neovim 内部终端执行。

说明这套配置已经把“编辑 → 运行 → 查看结果”串成了闭环。

---

## 10. 剪贴板与输入法：这套配置非常重视跨环境编辑体验

这是这个仓库比较有辨识度的一块。

### 10.1 macOS 剪贴板：自定义 FFI 封装

`vim/lua/lu5je0/misc/clipboard/mac.lua` 通过 FFI 加载 `vim/lib/liblibclipboard.dylib`，给 Neovim 提供更直接的系统剪贴板读写能力。

这说明作者不满足于默认 provider，而是为了性能或行为一致性，自己接了一层本地库。

### 10.2 WSL 剪贴板：异步同步到 Windows

`vim/lua/lu5je0/misc/clipboard/wsl.lua` 使用 `win32yank.exe`：

- 从 Neovim 向 Windows 剪贴板同步内容
- 在窗口重新获得焦点时从 Windows 拉取最新剪贴板
- 用队列方式处理多次复制，避免同步冲突

这套实现非常明确地说明：这个仓库不是把 WSL 当成“勉强可用”的兼容环境，而是认真把它纳入主要开发场景之一。

### 10.3 SSH / kitty 场景：使用 OSC52

在 `options.lua` 里还能看到：
- SSH 下会根据是否处于 kitty 环境选择不同 clipboard 策略
- 会使用 OSC52 实现远程会话复制

这意味着即使在远程环境中，作者也在追求“复制粘贴尽可能无缝”。

### 10.4 输入法切换

在 `options.lua` 和 `ext-loader.lua` 中还能看到和 IME 有关的逻辑，尤其是：
- GUI/Neovide 下插入模式与命令行模式的输入法开关
- macOS / WSL 场景下的输入法保持或切换

这类细节说明该项目服务的是长期高频编辑使用，而不是一次性配置。

---

## 11. 语言与文本辅助：Neovim 被扩展成了内容处理平台

### 11.1 自动语言识别

`vim/lua/lu5je0/ext/language-detect.lua` 会调用：

- `vim/node/lanuagedetection.mjs`
- `@vscode/vscode-languagedetection`

它会读取当前缓冲区内容，用模型推断语言，再映射到 Neovim 的 filetype。

这个能力说明作者有“面对未知文本快速识别类型”的需求，而不是完全依赖扩展名。

### 11.2 编码、格式、文本结构转换

从 `commands.lua` 可以看到，大量能力是围绕“文本内容本身”展开的：

- 编码转换
- URL/HTML/Unicode 转换
- Curl 命令转换
- Markdown 文本包装
- Cron 表达式解析

这让编辑器不只面向代码，也面向配置、命令、脚本、文档和半结构化文本。

---

## 12. Shell：命令行是整个工作环境的外壳

### 12.1 `zshrc` 是 Shell 主入口

这个仓库中的命令行主入口是 `zshrc`。

它会：
- 初始化 `zinit`
- 引入 Oh My Zsh 的部分库与插件
- 加载本仓库里的本地 zsh 脚本
- 启用 Powerlevel10k
- 启用 vi-mode
- 设置 PATH、alias 和环境变量

这说明 Shell 层不是孤立的，而是整个项目的统一外壳。

### 12.2 `zsh/` 目录的职责分工

比较重要的文件包括：

- `zsh/platform.sh`：平台差异处理
- `zsh/functions.sh`：常用函数和辅助命令
- `zsh/proxy.sh`：代理相关逻辑
- `zsh/vi-mode.zsh`：vi 模式增强
- `zsh/vi-im-switch.zsh`：输入法相关行为
- `zsh/p10k.zsh`：Powerlevel10k 配置

### 12.3 平台感知很强

`zsh/platform.sh` 中可以看到明显的平台分支：

- macOS：`pbcopy` / `pbpaste`、`open`、GNU coreutils、Homebrew 路径等
- WSL：`git.exe`、`win32yank.exe`、`powershell.exe`、Windows Explorer 等
- Linux：按架构注入不同二进制目录
- Android：Termux 场景处理

也就是说，Shell 本身就是这个项目跨平台适配的重要一层。

### 12.4 自动激活本地 Python 虚拟环境

`zsh/functions.sh` 中的 `chpwd()` 会在切换目录时检查当前目录下是否有 `./.env`，并自动激活其中的虚拟环境；离开该目录后再自动退出。

这是一种非常典型的“把重复动作自动化”的 dotfiles 设计。

---

## 13. 终端与窗口管理：统一多窗口工作流

### 13.1 tmux

`tmux/tmux.conf` 体现的是一套偏 Vim 风格的 tmux 使用习惯：

- 复制模式按键偏 vi
- pane 切换与窗口切换做了快捷键优化
- 支持当前目录分屏
- 接入 TPM 插件管理器
- 使用 `tmux/tmuxline/` 中的主题配置

这说明 tmux 在作者的工作流里是核心工具之一。

### 13.2 kitty

`kitty/kitty.conf` 里能看到很多与 tmux 习惯呼应的设计：

- `ctrl+b` 风格的组合按键
- 新窗口、拆分、切换标签页、重载配置等操作
- `allow_remote_control` 与剪贴板相关设置

kitty 在这个项目里不是“另一个独立终端”，更像是 tmux 工作流在 GUI terminal 里的延伸。

### 13.3 Hammerspoon

`hammerspoon/init.lua` 主要负责 macOS 下的窗口尺寸和位置控制。

它的特点是：
- 提供最大化、居中、左右半屏、3/4 居中等布局
- 对 WezTerm / kitty 之类应用做了特殊尺寸处理
- 提供跨屏移动逻辑

这说明作者在 macOS 桌面层也追求“稳定且可预测的窗口布局”。

### 13.4 alacritty / wezterm / win / termux

这些目录说明该仓库覆盖的不只是一个终端：

- `alacritty/`：不同平台下的 Alacritty 配置
- `wezterm/`：WezTerm 相关配置
- `win/`：Windows / WSL 协作脚本
- `termux/`：Android / Termux 配置

因此，这个项目更像“终端生态配置集合”，而不是单一终端主题仓库。

---

## 14. JetBrains 支持：让 IDE 尽量继承同一套编辑习惯

`ideavimrc` 说明作者的工作流并不局限于 Neovim，也会使用 JetBrains IDE，但希望尽量保留统一的 Vim 使用体验。

这里配置了很多映射，包括：

- 搜索与导航
- 代码重构与意图动作
- 运行 / 调试 /编译
- Git 和历史查看
- 标签页与窗口切换
- EasyMotion、surround、NERDTree 等相关行为

这说明这个仓库追求的是：

**无论是在 Neovim 还是 JetBrains，核心操作手感尽量一致。**

---

## 15. 辅助脚本和工具箱：不仅是配置，还有实用命令集合

### 15.1 `bin/` 目录

`bin/` 目录里不只是 shell 脚本，还包含：

- 包装脚本
- 小型 Python 工具
- 网络/系统辅助命令
- 平台特定二进制

例如：
- `bin/fetch_subs`：字幕下载工具入口
- `bin/py-http-server.py`：简单 HTTP 服务
- `bin/git-https2ssh.py`：Git URL 转换
- `bin/qrencode-kitty`：终端二维码输出
- `bin/speedtest-neovim`：速度测试相关工具
- `bin/wd`：路径/目录相关工具

### 15.2 `submodule/` 目录

`submodule/` 中是一些相对独立的小工具集合，`bin/` 中的脚本会对它们进行包装调用。

比如：
- `submodule/fetch-subs/`：字幕下载工具

这说明作者把“外部独立工具”和“自己日常命令入口”做了层次区分。

---

## 16. 系统与网络配置：这个仓库也承担部分运维职责

### 16.1 systemd 服务

`services/` 目录中存放 systemd 单元文件，说明这个仓库不仅配置交互式工具，也保存部分系统级运行配置。

例如这里可以看到：
- rclone 挂载相关服务
- WSL / SMB 挂载相关服务

这进一步说明该仓库是“完整工作环境仓库”，而不是单纯的 shell/vim 仓库。

### 16.2 SSH 配置

`ssh/config` 里：
- 使用 `Include config.d/*`
- 对 GitHub / gist.github.com 指定 `ssh.github.com:443`

这属于比较典型的“把网络访问策略和开发习惯一起版本化”的做法。

---

## 17. 这个仓库的设计风格

从整体结构上看，这个项目有几个很鲜明的风格：

### 17.1 强个人化，但不是随意堆砌

它显然是为作者本人服务的：
- 有明确的路径假设
- 有平台偏好
- 有固定键位习惯
- 有较强的 Vim 化倾向

但它并不是简单的“杂乱个人备份”，而是有明显结构化整理的：
- 安装层和配置层分离
- Neovim 内部有模块化设计
- 平台差异被集中到特定位置处理
- 插件能力和自定义能力有不同层次

### 17.2 偏向工作流闭环，而不是单点优化

仓库更关注的是“整段开发过程是否顺手”，而不是只优化某个工具：

- Shell 负责入口和环境
- Neovim 负责编辑和文本处理
- terminal 负责运行代码和命令
- tmux/kitty 负责多窗口组织
- IdeaVim 保持 IDE 中的连续性
- Hammerspoon 补足桌面窗口控制

### 17.3 非常强调环境感知

无论是 zsh 还是 Neovim，这个项目都不是假设“所有环境都一样”，而是显式根据：
- 操作系统
- 是否 WSL
- 是否 SSH
- 是否 kitty
- 是否 GUI

来改变行为。

这是一套典型的“长期使用后不断打补丁、最后沉淀成体系”的配置。

---

## 18. 适用场景

这个项目最适合的场景包括：

- 新电脑初始化时恢复原有工作环境
- 在多台机器之间同步一套统一的命令行和编辑器习惯
- 在 macOS / Linux / WSL 之间维持尽量一致的操作体验
- 长期沉淀个人键位、终端、编辑器、脚本和系统服务配置
- 将常用小工具和环境适配逻辑一起纳入版本管理

如果把它看成一个产品，它的用户画像非常明确：

**它首先服务于作者本人，是作者长期开发工作流的基础设施仓库。**

---

## 19. 使用方式

### 19.1 初始化

```bash
git clone https://github.com/lu5je0/.dotfiles.git ~/.dotfiles
bash ~/.dotfiles/scripts/setup.sh
```

### 19.2 Node 依赖

根目录的 `package.json` 不是一个普通 Node 项目，它主要是为了给：

- `vim/node/lanuagedetection.mjs`

提供 `@vscode/vscode-languagedetection` 依赖。

因此，如果相关功能需要使用，应执行：

```bash
npm install
```

### 19.3 Neovim 插件恢复

如果改动了 Neovim 插件声明或 lockfile，可以使用：

```bash
bash ~/.dotfiles/lazy-restore.sh
```

这个脚本会恢复 `vim/lazy-lock.json`，并通过 headless Neovim 执行 `Lazy! restore` 和 Treesitter 更新。

---

## 20. 维护这个仓库时要知道的事

1. **它没有传统意义上的 build / test / lint 体系**
   这不是应用仓库，所以没有 root 级别的标准构建流程。

2. **修改仓库内容通常就是在修改真实运行中的配置**
   因为很多文件会被软链接到用户目录。

3. **平台假设很多，修改时要注意上下文**
   仓库中有明显的 macOS、WSL、Linux、Windows 协作路径假设。

4. **Neovim 的很多功能依赖外部命令**
   比如 `shfmt`、`black`、`prettier`、`sql-formatter`、`xmllint` 等。

5. **它的价值在于“各部分一起工作”**
   单独看某个文件可能只是普通配置，但组合起来是一整套持续优化过的开发环境。

---

## 21. 一句话总结

这是一个围绕 Vim/Vi 工作流构建的、跨平台的个人 dotfiles 仓库。它通过安装脚本把 Shell、Neovim、tmux、终端、IDE 键位、窗口管理、系统服务和若干辅助工具统一接入系统环境，用来长期维护作者完整的开发工作流。