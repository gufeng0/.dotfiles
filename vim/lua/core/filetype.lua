require('filetype').setup({
  overrides = {
    extensions = {
      -- Set the filetype of *.pn files to potion
      zsh = 'sh',
    },
    literal = {
      -- Set the filetype of files named "MyBackupFile" to lua
      ['.bashrc'] = 'sh',
      ['.zshrc'] = 'sh',
      ['zshrc'] = 'sh',
      ['bashrc'] = 'sh',
      ['.ohmyenv'] = 'sh',
      ['*tmux.conf'] = 'tmux',
      ['tmux.conf'] = 'tmux',
    },
    complex = {
      -- Set the filetype of any full filename matching the regex to gitconfig
      ['/etc/profile'] = 'sh', -- Included in the plugin
    },
    -- -- The same as the ones above except the keys map to functions
    -- function_extensions = {
    --     ["cpp"] = function()
    --         vim.bo.filetype = "cpp"
    --         -- Remove annoying indent jumping
    --         vim.bo.cinoptions = vim.bo.cinoptions .. "L0"
    --     end,
    --     ["pdf"] = function()
    --         vim.bo.filetype = "pdf"
    --         -- Open in PDF viewer (Skim.app) automatically
    --         vim.fn.jobstart(
    --             "open -a skim " .. '"' .. vim.fn.expand("%") .. '"'
    --         )
    --     end,
    -- },
    -- function_literal = {
    --     Brewfile = function()
    --         vim.cmd("syntax off")
    --     end,
    -- },
    -- function_complex = {
    --     ["*.math_notes/%w+"] = function()
    --         vim.cmd("iabbrev $ $$")
    --     end,
    -- },
    shebang = {
      -- Set the filetype of files with a bash shebang to sh
      bash = 'sh',
      zsh = 'sh',
      python3 = 'python'
    },
  },
})