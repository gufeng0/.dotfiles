local M = {}

M.setup = function()
  local setup = {
    plugins = {
      marks = true, -- shows a list of your marks on ' and `
      registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false, -- adds help for operators like d, y, ...
        motions = false, -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = false, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = false, -- bindings for prefixed with g
      },
      spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
    },
    icons = {
      breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
      separator = '➜', -- symbol used between a key and it's label
      group = '+', -- symbol prepended to a group
    },
    window = {
      border = 'single', -- none, single, double, shadow
      position = 'bottom', -- bottom, top
      margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
      height = { min = 1, max = 10 }, -- min and max height of the columns
      width = { min = 20, max = 80 }, -- min and max width of the columns
      spacing = 2, -- spacing between columns
    },
    triggers = { '<leader>', '<c-w>', 'z' },
    -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
  }

  local n_mappings = {
    ['1'] = 'which_key_ignore',
    ['2'] = 'which_key_ignore',
    ['3'] = 'which_key_ignore',
    ['4'] = 'which_key_ignore',
    ['5'] = 'which_key_ignore',
    ['6'] = 'which_key_ignore',
    ['7'] = 'which_key_ignore',
    ['8'] = 'which_key_ignore',
    ['9'] = 'which_key_ignore',
    ['0'] = 'BufferLinePick',
    ['q'] = 'close buffer',
    ['Q'] = 'exit vim',
    ['u'] = 'undotree',
    ['i'] = { ':AerialToggle!<cr>', 'aerial' },
    ['n'] = { ':noh<cr>', 'no highlight' },
    ['d'] = { '<c-^>', 'buffer switch' },
    ['e'] = { 'file explorer' },
    ['a'] = { ':call Calc()<cr>', 'calcultor' },
    ['/'] = { ':call eregex#toggle()<cr>', 'eregex toggle' },
    ['<space>'] = 'diagnostic',
    w = {
      name = '+windows',
      ['n'] = { ':vnew<cr>', 'vnew' },
      ['N'] = { ':new<cr>', 'new' },
      ['s'] = { ':vsplit<cr>', 'vspilt' },
      ['S'] = { ':split<cr>', 'spilt' },
      ['q'] = { ':only<cr>', 'break window' },
      ['m'] = { ':BufferLinePickSplit<cr>', 'spilit with' },
      ['p'] = { ':BufferLinePick<cr>', 'buffer pick' },
      ['u'] = { '<c-w>x', 'buffer pick' },
    },
    W = {
      name = '+workspace',
      a = 'add workspace folder',
      r = 'remove workspace folder',
      l = 'list workspace folder',
    },
    p = {
      name = 'Packer',
      w = { '<cmd>PackerCompile profile=true<cr><cmd>PackerProfile<cr>', 'profile' },
      s = { '<cmd>PackerSync<cr>', 'sync' },
      c = { '<cmd>PackerCompile<cr>', 'compile' },
      i = { '<cmd>PackerInstall<cr>', 'install' },
      u = { '<cmd>PackerUpdate<cr>', 'update' },
      d = { '<cmd>PackerClean<cr>', 'clean' },
    },
    c = {
      name = '+code',
      r = 'rename-variable',
      c = 'code-action',
      e = 'setloclist',
      f = 'code-formatting',
      n = {
        name = '+naming case',
        s = { 'snake_case' },
        S = { 'snake_case(WORD)' },
        k = { 'kebab-case' },
        K = { 'kebab-case(WORD)' },
        p = { 'PascalCase' },
        P = { 'PascalCase(WORD)' },
        c = { 'camelCase' },
        C = { 'camelCase(WORD)' },
      },
    },
    t = {
      name = '+tab',
      o = { ':call buffer#CloseOtherBuffers()<cr>', 'close-other-buffers' },
      n = { ':enew<cr>', 'new-buffer' },
      t = { ':TSBufToggle highlight<cr>', 'toggle treesitter highlight' },
    },
    f = {
      name = '+search/files',

      -- fuzzy search
      C = 'colorscheme',
      f = 'file',
      s = 'recall',
      r = 'rg',
      l = 'line',
      n = 'filetype',
      b = 'buffer',
      m = 'mru',
      h = 'help',
      j = 'junk-list',

      q = { ":echom 'detecting' | GuessLang<cr>", 'GuessLang' },
      e = { 'locate-file' },
      W = { ':SudaWrite<cr>', 'sudo-write' },
      d = { 'dir .dotfiles' },
      p = { 'dir packer' },
      w = { ':w<cr>', 'write' },
      J = { ':SaveAsJunkFile<cr>', 'new-junk-file' },
      x = {
        name = '+encoding',
        a = { ':set ff=unix<cr>', '2unix' },
        b = { ':set ff=dos<cr>', '2dos' },
        u = { ':set fileencoding=utf8<cr>', 'convert to utf8' },
        g = { ':set fileencoding=GB18030<cr>', 'convert to gb18030' },
      },
    },
    x = {
      name = '+text',
      r = { function() require('lu5je0.misc.replace').n_replace() end, 'replace word' },
      u = 'escape unicode',
      U = 'unescape unicode',
      h = 'url encode',
      H = 'url decode',
      c = { 'g<c-g>', 'count in the selection region' },
      m = { [[:%s/\r$//<cr>]], 'remove ^M' },
      z = '繁体转简体',
      Z = '简体转繁体',
    },
    s = {
      name = '+translate',
      s = 'translate popup',
      a = 'say it',
      r = 'translate replace',
      c = 'translate',
    },
    v = {
      name = '+vim',
      v = { ':edit ' ..
          vim.api.nvim_eval('$HOME') ..
          '/.dotfiles/vim/init.lua | :cd ' .. vim.api.nvim_eval('$HOME') .. '/.dotfiles/vim <cr>', 'edit init.lua' },
      s = 'toggle signcolumn',
      S = { ':set signcolumn=yes | echo "set signcolumn=yes"<cr>', 'set signcolumn=yes' },
      c = 'toggle case insensitive',
      n = 'toggle number',
      d = 'toggle diff',
      p = 'toggle paste',
      w = 'toggle wrap',
      m = 'toggle mouse',
      i = 'toggle-save-last-ime',
      h = 'toggle hexedit',
      l = 'toggle cursorline',
      f = 'toggle fold column',
      F = {
        name = '+foldmethod',
        m = { ':set fdm=manual | echo "set fdm = manual"<cr>', 'manual' },
        s = { ':set fdm=sytanx | echo "set fdm = sytanx"<cr>', 'sytanx' },
        e = { ':set fdm=expr | echo "set fdm = expr"<cr>', 'expr' },
        i = { ':set fdm=indent | echo "set fdm = indent"<cr>', 'indent' },
        n = { ':set fdm=marker | echo "set fdm = marker"<cr>', 'marker' },
        d = { ':set fdm=diff | echo "set fdm = diff"<cr>', 'diff' },
      },
    },
    r = {
      name = '+run',
      r = 'run',
      d = 'debug',
      s = {":lua require('lu5je0.misc.code-runner').run_curl()<cr>","curl"}
    },
    g = {
      name = '+git',
      a = 'stage buffer',
      r = 'unstage buffer',
      h = 'stage hunk',
      H = 'undo stage hunk',
      u = 'reset hunk',
      g = 'preview hunk',
      A = { ':Git add -A<cr>', 'add all' },
      b = { ':Git blame<cr>', 'blame' },
      B = { ':Git blame<cr>', 'blame line' },
      C = { ':Gread<cr>', 'git checkout -- current file' },
      d = { ':Git diff<cr>', 'diff' },
      D = { ':Git diff --cached<cr>', 'diff --cached' },
      v = { ':Gvdiffsplit!<cr>', 'gvdiffsplit' },
      l = { ':Flogsplit<cr>', 'git log in repository' },
      s = { ':Floggit<cr>', 'Floggit' },
      L = { function() require('lu5je0.ext.fugitive').current_file_logs() end, 'show changs on current file' },
      i = { ':Gist -l<cr>', 'gist' },
    },
  }

  local n_opts = {
    mode = 'n', -- NORMAL mode
    prefix = '<leader>',
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
  }

  local x_mappings = {
    x = {
      name = '+text',
      c = { 'g<c-g>', 'count in the selection region' },
      b = { 'base64' },
      B = { 'unbase64' },
      h = { 'http encode' },
      H = { 'http decode' },
      s = { 'text escape' },
      r = { ":lua require('lu5je0.misc.replace').v_replace()<cr>", 'replace' },
    },
    s = {
      name = '+translate',
    },
    f = {
      name = '+search/files',
      f = { ":lua require('lu5je0.ext.leaderf').visual_leaderf('file')<cr>", 'file' },
      r = { ":lua require('lu5je0.ext.leaderf').visual_leaderf('rg')<cr>", 'rg' },
    },
    c = {
      name = '+code',
      f = 'range formatting',
      n = {
        name = '+naming case',
        s = { 'snake_case' },
        k = { 'kebab-case' },
        p = { 'PascalCase' },
        c = { 'camelCase' },
      },
    },
    d = {
      n = {":lua require('lu5je0.misc.delete').deleteNullLines()<cr>","delete null lines"},
      l = {":lua require('lu5je0.misc.delete').deleteLines()<cr>","delete lines"},
      a = {":lua require('lu5je0.misc.delete').deleteAll()<cr>","delete all"},
      i = {":lua require('lu5je0.misc.delete').deleteImg()<cr>","delete img"}
    },
    g = {
      name = '+git',
      l = { ":lua require('lu5je0.ext.fugitive').lines_changes()<cr>", 'show changs on select lines' },
    },
  }

  local x_opts = {
    mode = 'x', -- VISUAL mode
    prefix = '<leader>',
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
  }

  local wk = require('which-key')
  wk.setup(setup)

  wk.register(n_mappings, n_opts)
  wk.register(x_mappings, x_opts)
end

return M
