---@diagnostic disable: unused-local

local dotfiles_dir = vim.env.DOTFILES_DIR
if dotfiles_dir == nil or dotfiles_dir == '' then
  error('[lu5je0.filetype] DOTFILES_DIR is not set. Export DOTFILES_DIR=<path to dotfiles repo> before starting nvim')
end

vim.filetype.add {
  extension = {
    -- zsh = 'zsh',
  },
  filename = {
    ['.bashrc'] = 'bash',
    ['.zshrc'] = 'bash',
    ['zshrc'] = 'bash',
    ['bashrc'] = 'bash',
    ['.ohmyenv'] = 'bash',
    ['crontab'] = 'crontab',
    ['kitty.conf'] = 'config',
    ['aria2.conf'] = 'dosini',
    ['requirements.txt'] = function(path, bufnr)
      vim.schedule(function()
        vim.bo[bufnr].commentstring='#%s'
      end)
      return 'text'
    end
  },
  pattern = {
    ['.*.tmux.conf'] = 'tmux',
    ['.*.zsh'] = 'bash',
    ['.*/ssh/config'] = 'sshconfig',
    ['.*/' .. dotfiles_dir .. '/services/.*'] = 'systemd',
  },
}
