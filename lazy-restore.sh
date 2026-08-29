dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
git checkout -- "$dotfiles_dir/vim/lazy-lock.json"
nvim --headless +":lua vim.cmd('Lazy! restore') require('lazy').load({ plugins = { 'nvim-treesitter' }, opt = { force = true } }); vim.cmd('TSUpdateSync all')" +qa
