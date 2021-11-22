lua require('impatient')
lua require('plugins')
lua require('commands')

runtime settings.vim

if has("gui")
    runtime gvim.vim
endif

runtime functions.vim

runtime mappings.vim
runtime misc.vim
runtime runner.vim
runtime autocmd.vim

call timer_start(0, 'LoadPlug')
function! LoadPlug(timer) abort
    if has("mac")
        let g:python3_host_prog  = '/usr/local/bin/python3'
    endif
    runtime im.vim
    silent! PackerLoad coc.nvim
    silent! PackerLoad vim-textobj-parameter

    if has("wsl")
        silent! PackerLoad im-switcher.nvim
    endif
    set clipboard=unnamed

    map <silent> <leader>e :NvimTreeToggle<cr>
    map <silent> <leader>fe :lua require("core/nvim-tree").locate_file()<cr>
endfunction
