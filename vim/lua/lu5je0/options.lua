local o = vim.o
local g = vim.g

local has = function(feature)
  return vim.fn.has(feature) == 1
end

o.mouse = "a"
o.hlsearch = true
o.ignorecase = true
o.incsearch = true
o.splitbelow = true -- 默认在下侧分屏
o.splitright = true -- 默认在右侧分屏
o.shadafile = 'NONE'
o.wrap = true

o.completeopt = 'menu,menuone,noselect'

o.number = true
o.numberwidth = 3

o.laststatus = 2
o.showmode = false
-- o.cursorline = true
o.undofile = true
o.foldmethod = 'manual'
o.foldlevel = 99 -- 打开文件默认不折叠
o.hidden = true
o.updatetime = 100
o.signcolumn = 'yes:1'

-- encodeing
o.fileformat = 'unix'
o.fileencoding = 'utf-8'
o.fileencodings = 'ucs-bom,utf-8,gb18030,utf-16,big5,ISO-8859,latin1'

-- indent
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.autoindent = true
-- o.cmdheight = 0

-- 不显示启动界面
o.shortmess = o.shortmess .. 'I'
o.foldtext = 'misc#fold_text()'
o.showcmd = false

-- colorscheme
o.termguicolors = true
o.bg = 'dark'
vim.cmd.colorscheme('edge')
vim.api.nvim_set_hl(0, "StatusLine", { fg = '#c5cdd9', bg = '#1d2024' })
-- StatusLine 左边
-- vim.api.nvim_set_hl(0, "StatusLine", { fg = '#373943' })
-- vim.api.nvim_set_hl(0, "StatusLineNC", { fg = '#373943' })
o.statusline = " "

local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}

for _, plugin in pairs(default_plugins) do
  g["loaded_" .. plugin] = 1
end

if has('wsl') then
  g.clipboard = {
    name = 'win32yank',
    copy = {
      ['+'] = { 'win32yank.exe', '-i', '--crlf' },
      ['*'] = { 'win32yank.exe', '-i', '--crlf' },
    },
    paste = {
      ['+'] = { 'win32yank.exe', '-o', '--lf' },
      ['*'] = { 'win32yank.exe', '-o', '--lf' },
    },
    cache_enabled = 1,
  }
end

if has('mac') then
  vim.g.python3_host_prog = '/usr/bin/python3'
end

if has('gui') then
  vim.o.guifontwide = 'Microsoft YaHei UI'
end

local defer_options = {
  function()
    o.shadafile = vim.fn.stdpath('data') .. "/shada/main.shada"
    vim.cmd [[ silent! rsh ]]
  end,
  function()
    o.clipboard = 'unnamedplus'
    vim.cmd [[ packadd matchit ]]
  end
}
for delay, fn in ipairs(defer_options) do
  vim.defer_fn(fn, 2 * delay)
end
vim.g.ts_highlight_c = true
vim.g.ts_highlight_vim = true
vim.g.ts_highlight_lua = true
