# .dotfiles 全按键说明 + 插件说明

## 领导键
- `<leader>`：默认 `, `（所有 `<leader>` 按键）

---

## 1. 通用与移动按键

| 按键              | 功能                     | 模式   |
|-------------------|--------------------------|--------|
| `H` / `L`         | 行首 / 行尾              | x/n/o  |
| `^` / `$`         | 行首 / 行尾              | n      |
| `Ctrl + j/k/h/l`  | 上下左右切换窗口        | n      |
| `Ctrl + b`        | 上一个窗口              | n      |
| `Ctrl + w + o`    | 关闭其他窗口            | n      |
| `Ctrl + w +` / `-` | 窗口大小调整            | n      |
| `Ctrl + w + <` / `>` | 窗口宽度调整          | n      |

---

## 2. 文本操作

| 按键                  | 功能                     | 模式   |
|-----------------------|--------------------------|--------|
| `Ctrl + c`            | 复制选区                | x      |
| `Ctrl + v`            | 粘贴                    | n      |
| `<leader>xx`          | 外部命令执行            | n      |
| `Ctrl + a` / `Ctrl + x` | 布尔值切换              | n      |
| `m`                   | 选择最后插入的文本      | n      |
| `<leader>fs`          | 切换到 `~/.dotfiles`    | n      |
| `<leader>ft`          | 切换到 `~/test`         | n      |

---

## 3. 选项切换

| 按键              | 功能                     | 模式   |
|-------------------|--------------------------|--------|
| `<leader>vn`      | 切换行号                | n      |
| `<leader>vp`      | 切换粘贴模式            | n      |
| `<leader>vm`      | 切换鼠标模式            | n      |
| `<leader>vl`      | 切换光标线              | n      |
| `<leader>vf`      | 切换折叠列              | n      |
| `<leader>vd`      | 窗口差异视图            | n      |
| `<leader>vh`      | 切换十六进制编辑        | n      |
| `<leader>vc`      | 切换忽略大小写          | n      |
| `<leader>vw`      | 切换 wrap 选项          | n      |

---

## 4. 插件相关按键说明

### telescope
- `<`：进入搜索（默认）

### nvim-tree
- `<leader>e`：打开/关闭文件树
- `<leader>fe`：快速打开文件树

### vim-calc
- `<leader>a`：计算器

### vim-textobj-parameter
- `ia` / `aa`：参数对象

### substitute.nvim
- `cx` / `gr`：替换操作

### nvim-surround
- `cs` / `ys` / `ds`：surround 相关

### comment.nvim
- `gc` / `gcc`：注释/取消注释

### toggleterm.nvim
- `<m-i>` / `<d-i>`：切换终端

### vim-visual-multi
- `<c-n>` / `<m-n>`：多光标

### vim-translator
- `<leader>sa` / `<leader>ss`：翻译

### undotree
- `<leader>u`：打开/关闭撤销树

### which-key
- `<leader>` / `<space>`：打开 which-key

### HighStr.nvim
- `<leader>my` / `mg` / `mr` / `mb` / `mc`：高亮相关

### outline.nvim
- `<leader>d` / `<leader>fd`：大纲视图

### spectre.nvim
- `<leader>xr` / `<leader>xf`：搜索替换

### profile.nvim
- `<leader>pp`：启动/停止性能分析

### flash.nvim
- `t`：快速跳转
- `S`：Treesitter 跳转
- `r`：远程跳转

### blame.nvim
- `<leader>gb`：Git Blame

### fundo
- 无特殊按键

### bigfile
- 无特殊按键

### render-markdown
- 无特殊按键

### md-img-paste.vim
- `<leader>pd` / `<leader>pc`：粘贴图片到 markdown

### zoxide
- 无特殊按键（z 插件）

---

**说明**：
- 所有按键均在 `vim/lua/lu5je0/mappings.lua` 统一管理。
- 插件按键通常通过 `keys = { ... }` 定义。
- 部分插件有自定义扩展（`ext/` 文件夹）。

需要我把某个插件的按键单独列成表格吗？