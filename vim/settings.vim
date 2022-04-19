set mouse=a
set hlsearch " 高亮搜索结果
set ignorecase
set incsearch " 每输入一个字符就跳转到对应的结果
set noerrorbells " 关闭错误响声
set splitbelow " 默认在下侧分屏
set splitright " 默认在右侧分屏
set nowrap " 默认不启用拆行
set autoindent
" set indentkeys=""
set number
set laststatus=2
set showtabline=2
set noshowmode
set fileformat=unix
" set cursorline
" 缩进
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set encoding=utf8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,utf-16,big5,ISO-8859,latin1
set foldmethod=manual
set foldlevelstart=99 " 打开文件默认不折叠
set termguicolors
set hidden
set updatetime=100
set signcolumn=yes:1

" make the backspace work like in most other programs
set backspace=indent,eol,start

" 彻底关闭bell
if has("gui") && has("win64")
    set visualbell t_vb=  "关闭visual bell
    au GuiEnter * set t_vb= "关闭beep
endif

" 补全时默认不选中
" set cot=noinsert,menuone
set completeopt=menu,menuone,noselect

set undofile

" 不显示启动界面
set shortmess=atI

set foldtext=misc#fold_text()

" 主题配置 {{{
set bg=dark
let g:edge_enable_italic = 0
let g:edge_disable_italic_comment = 1
colorscheme edge

" edge
hi! Folded guifg=#282c34 guibg=#5c6370

" StatusLine 左边
hi! StatusLine guibg=#5C6370
hi! StatusLineNC guibg=#5C6370

" leaderf
hi! FoldColumn guibg=none
" }}}

if has('wsl')
    let g:clipboard = {
          \   'name': 'win32yank',
          \   'copy': {
          \      '+': ['win32yank.exe', '-i', '--crlf'],
          \      '*': ['win32yank.exe', '-i', '--crlf'],
          \    },
          \   'paste': {
          \      '+': ['win32yank.exe', '-o', '--lf'],
          \      '*': ['win32yank.exe', '-o', '--lf'],
          \   },
          \   'cache_enabled': 1,
          \ }
endif

let g:loaded_2html_plugin = 1
let g:loaded_matchit = 1

if has('mac')
    let g:python3_host_prog = '/usr/local/bin/python3'
endif
