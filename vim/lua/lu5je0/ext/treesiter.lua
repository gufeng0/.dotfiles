local treesitter = require('nvim-treesitter')

local ts_filetypes = {
  'json', 'python', 'java', 'bash', 'go', 'vim', 'lua',
  'rust', 'toml', 'yaml', 'markdown', 'http', 'typescript',
  'javascript', 'sql', 'html', 'json5', 'jsonc', 'regex',
  'vue', 'css', 'dockerfile', 'comment', 'vimdoc', 'query'
}

require('nvim-treesitter.configs').setup {
  -- Modules and its options go here
  prefer_git = true,
  ensure_installed = ts_filetypes,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = false,
  },
  indent = {
    enable = false
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = false,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@comment.outer",
        ["ic"] = "@comment.outer",
        -- You can also use captures from other query groups like `locals.scm`
        -- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      include_surrounding_whitespace = false,
    },
  },
}
--
-- incremental select
treesitter.define_modules {
  incremental_select = {
    enable = true,
    attach = function()
      vim.cmd([[
      xmap <buffer> <silent> v <esc>m':lua require'nvim-treesitter.incremental_selection'.node_incremental()<CR>
      xmap <buffer> <silent> V <esc>:lua require'nvim-treesitter.incremental_selection'.node_decremental()<CR>
      "  highlights
      hi TSPunctBracket guifg=#ABB2BF
      hi @constructor.lua guifg=#ABB2BF
      ]])
    end,
    detach = function()
      vim.cmd([[
      silent! xunmap <buffer> v
      silent! xunmap <buffer> V
      ]])
    end
  }
}
