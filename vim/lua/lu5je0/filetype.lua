---@diagnostic disable: unused-local

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
    ['.*/.dotfiles/services/.*'] = 'systemd',
  },
}
