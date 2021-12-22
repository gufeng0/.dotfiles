require('impatient')
require('enhance')
require('plugins')
require('commands')

vim.cmd[[
runtime settings.vim

if has("gui")
    runtime gvim.vim
endif

runtime functions.vim
runtime mappings.vim
runtime misc.vim
runtime runner.vim
runtime autocmd.vim
if has("mac")
    runtime im.vim
endif

call timer_start(0, 'LoadPlug')
function! LoadPlug(timer) abort
    if has("mac")
        let g:python3_host_prog = '/usr/local/bin/python3'
    endif
    " silent! PackerLoad coc.nvim
    silent! PackerLoad vim-textobj-parameter
    silent! PackerLoad indent-blankline.nvim
    silent! PackerLoad nvim-lspconfig
    silent! PackerLoad nvim-cmp
    silent! PackerLoad nvim-autopairs
    silent! PackerLoad null-ls.nvim

    if has("wsl")
        silent! PackerLoad im-switcher.nvim
    endif
    set clipboard=unnamed
endfunction
]]
