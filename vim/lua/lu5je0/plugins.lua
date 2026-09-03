local nvim_colorizer_ft = { 'vim', 'lua', 'css', 'conf', 'tmux', 'bash' }
local has_ssh_client = vim.fn.has('ssh_client') == 1

local disabled_plugins = {
  "2html_plugin",
  "editorconfig",
  "getscript",
  "getscriptPlugin",
  "logipat",
  "man",
  "matchit",
  "netrw",
  "netrwFileHandlers",
  "netrwPlugin",
  "netrwSettings",
  "rplugin",
  "rrhelper",
  "spellfile",
  "spellfile_plugin",
  -- "zip",
  -- "zipPlugin",
  -- "gzip",
  -- "tar",
  -- "tarPlugin",
  "tohtml",
  "tutor",
  "vimball",
  "vimballPlugin",
}

if not has_ssh_client then
  table.insert(disabled_plugins, 'osc52')
end

local opts = {
  concurrency = 20,
  performance = {
    rtp = {
      disabled_plugins = disabled_plugins,
    },
  },
}

require("lazy").setup({
  {
    'sainnhe/edge',
    lazy = true,
    init = function()
      vim.g.edge_better_performance = 1
      vim.g.edge_enable_italic = 0
      vim.g.edge_disable_italic_comment = 1
      vim.cmd.colorscheme('edge')
      vim.api.nvim_set_hl(0, "StatusLine", { fg = '#c5cdd9', bg = '#23262b' })
      vim.api.nvim_set_hl(0, "Folded", { fg = '#282c34', bg = '#5c6370' })
      vim.api.nvim_set_hl(0, "MatchParen", { fg = '#ffef28', bg = '#414550'})
      
      vim.g.edge_loaded_file_types = { 'NvimTree' }
      
      -- local bg = '#2c2e34'
      -- vim.cmd(string.gsub([[
      -- " hi NvimTreeNormal guibg=%s
      -- " hi NvimTreeNormalNC guibg=%s
      -- " hi NvimTreeEndOfBuffer guifg=%s
      --
      -- hi VertSplit guifg=#27292d guibg=bg
      -- hi NvimTreeVertSplit guifg=bg guibg=bg
      --
      -- hi NvimTreeWinSeparator guibg=%s guifg=%s
      -- ]], '%%s', bg))
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lu5je0.ext.lualine')
    end,
    event = 'VeryLazy',
  },

  -- treesiter
  {
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      init = function()
        -- nvim>=0.12 passes captures to query handlers as TSNode[] lists, but
        -- the archived nvim-treesitter master handlers expect a bare TSNode
        -- (all=false). Wrap only handlers registered from nvim-treesitter
        -- source trees so legacy directives keep working.
        local ok, query = pcall(require, 'vim.treesitter.query')
        if not ok then
          return
        end
        local function first_node(nodes)
          return type(nodes) == 'table' and nodes[1] or nodes
        end
        local function wrap_add(orig)
          return function(name, handler, opts)
            local src = debug.getinfo(2, 'S').source or ''
            if src:find('nvim-treesitter', 1, true) then
              local all = type(opts) == 'table' and opts.all or false
              if not all then
                local legacy = handler
                handler = function(match, ...)
                  local norm = {}
                  for id, nodes in pairs(match) do
                    norm[id] = first_node(nodes)
                  end
                  return legacy(norm, ...)
                end
              end
            end
            return orig(name, handler, opts)
          end
        end
        query.add_predicate = wrap_add(query.add_predicate)
        query.add_directive = wrap_add(query.add_directive)
      end,
      config = function()
        require("nvim-treesitter.install").prefer_git = true
        require('lu5je0.ext.treesiter')
      end,
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects'
      },
      event = 'VeryLazy'
    },
    -- {
    --   "ThePrimeagen/refactoring.nvim",
    --   config = function()
    --     require('lu5je0.ext.refactoring').setup()
    --   end,
    --   keys = { { mode = { 'n', 'x' }, '<leader>c' } },
    -- },
    {
      'm-demare/hlargs.nvim',
      config = function()
        require('hlargs').setup {
          -- flash.nvim 5000
          hl_priority = 4999,
        }
      end,
      dependencies = {
        'nvim-treesitter/nvim-treesitter'
      },
      event = 'LspAttach'
    },
    {
      'phelipetls/jsonpath.nvim',
      ft = { 'json', 'jsonc' }
    },
  },

  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
    config = function()
      require('lu5je0.ext.repeat').setup()
    end
  },
  {
    'aklt/plantuml-syntax',
    ft = 'plantuml'
  },
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gvdiffsplit', 'Gstatus', 'Gclog', 'Gread' },
    config = function()
      require('lu5je0.ext.fugitive').setup()
    end
  },
  {
    -- git 状态实时标记：signcolumn='no' 下用 numhl 着色行号表达增删改，零布局侵入
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup {
        signcolumn = false,
        numhl = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          delay = 500,
          virt_text_pos = 'eol',
          ignore_blank_line = true,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, lhs, rhs, desc, extra)
            local o = { buffer = bufnr, silent = true, desc = 'gitsigns: ' .. desc }
            if extra then
              for k, v in pairs(extra) do o[k] = v end
            end
            vim.keymap.set(mode, lhs, rhs, o)
          end
          map('n', ']g', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, 'next hunk', { expr = true })
          map('n', '[g', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, 'prev hunk', { expr = true })
          map('n', '<leader>gS', gs.stage_hunk, 'stage hunk')
          map('n', '<leader>gU', gs.undo_stage_hunk, 'undo stage hunk')
          map('n', '<leader>gR', gs.reset_hunk, 'reset hunk')
          map('v', '<leader>gS', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, 'stage hunk')
          map('v', '<leader>gR', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, 'reset hunk')
          map('n', '<leader>gP', gs.preview_hunk, 'preview hunk')
          map({ 'o', 'x' }, 'ig', ':<C-U>Gitsigns select_hunk<CR>', 'hunk textobj')
        end,
      }
    end
  },
  {
    'rbong/vim-flog',
    cmd = { 'Flogsplit', 'Floggit', 'Flog' },
    keys = { { mode = 'n', '<leader>gL' }, { mode = 'x', '<leader>gl' } },
    dependencies = {
      'tpope/vim-fugitive',
    },
    config = function()
      if vim.fn.has('kitty') == 1 then
        vim.g.flog_enable_extended_chars = true
      end
      vim.cmd [[
      augroup flog
      autocmd FileType floggraph nmap <buffer> <leader>q ZZ
      augroup END
      ]]
    end
  },
  {
    -- sindrets 原版 2024-06 起停更，用活跃维护的 fork（新增 diff1_inline 单窗口布局等）
    'dlyongemallo/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewRefresh' },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = 'diff2_horizontal' }, -- 左右并排
        merge_tool = { layout = 'diff3_horizontal' },
        file_history = { layout = 'diff2_horizontal' },
      },
      file_panel = {
        win_config = { position = 'left', width = 35 },
      },
    },
    config = function(_, opts)
      local lib = require('diffview.lib')
      local diffview = require('diffview')

      -- fork@43e60bca 的 actions.close 是 emit 存根、按了没反应，统一走 :DiffviewClose 同款路径；
      -- 并兜底清理 teardown 漏掉的 diffview:// 占位缓冲、摘除临时挂的 q 映射
      local q_armed = {} -- [bufnr]=挂载前备份的 q 映射（无则为 false）：我们临时挂过 q 的真实文件 buffer
      -- 两个函数互相引用，需先声明 local 再赋值，否则会退化成全局查找（nil）
      local disarm_q
      local close_all_views

      disarm_q = function()
        for b, backup in pairs(q_armed) do
          if vim.api.nvim_buf_is_valid(b) then
            -- 只摘我们挂的 q（按回调身份识别），用户原有的 buffer-local q 保留
            for _, km in ipairs(vim.api.nvim_buf_get_keymap(b, 'n')) do
              if km.lhs == 'q' and km.callback == close_all_views then
                pcall(vim.keymap.del, 'n', 'q', { buffer = b })
                break
              end
            end
            -- 挂载前若覆盖了用户自己的 q，这里恢复
            if backup then
              local rhs = backup.callback or backup.rhs
              if rhs then
                pcall(vim.keymap.set, backup.mode, backup.lhs, rhs, backup.opts)
              end
            end
          end
          q_armed[b] = nil
        end
      end

      close_all_views = function()
        -- close() 会从 lib.views 删除元素，所以先复制 view 列表，避免遍历时漏项；
        -- 逐个 pcall：单个 view 关闭过程中的异常（如用户 autocmd 报错）不能中断其余 view
        local views = {}
        for _, view in ipairs(lib.views) do
          views[#views + 1] = view
        end
        for _, view in ipairs(views) do
          local tabpage = view.tabpage
          if tabpage and vim.api.nvim_tabpage_is_valid(tabpage) then
            -- 僵尸布局兜底：外部代码（如 close_buffer 的 bp+bd!）杀掉布局窗口
            -- 显示的 buffer 后，窗口会残留一个空 [No Name]，布局不再完整但
            -- tabpage 还在。先让 view 重建/校验布局，再走正常关闭，否则
            -- tabclose 可能因布局窗口状态异常失败，view 永远留在 lib.views。
            pcall(function()
              if view.ensure_layout then
                view:ensure_layout()
              end
            end)
            local ok, closed = pcall(diffview.close, tabpage, { force = false })
            if ok and closed == false then
              -- 有未保存的 stage buffer：拒绝关闭。整批中止、保留其余 view，
              -- 保存后再次按 q 即可全部退出（不 force，避免丢数据）
              return
            end
          else
            -- teardown 漏掉的僵尸 view（tabpage 已死/nil）：close() 对无效 tabpage
            -- 是 no-op 且不会摘除，这里手动摘除，否则 lib.views 永远清不干净
            lib.dispose_view(view)
          end
        end

        -- 关闭过程中可能残留 tabpage 已失效的 view（close 中途异常等），统一摘除
        local stale = {}
        for _, view in ipairs(lib.views) do
          if not view.tabpage or not vim.api.nvim_tabpage_is_valid(view.tabpage) then
            stale[#stale + 1] = view
          end
        end
        for _, view in ipairs(stale) do
          lib.dispose_view(view)
        end

        -- 有未保存的 stage buffer 时 close() 会拒绝退出，不要误删仍在使用的 buffer
        if #lib.views == 0 then
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) and vim.fn.bufname(b):match('^diffview://') then
              pcall(vim.api.nvim_buf_delete, b, { force = true })
            end
          end
          disarm_q()
        end
      end

      -- 追加到默认 keymaps 尾部。不能用 opts.keymaps：lazy 列表按索引合并，会顶掉默认第一项
      local q_entry = { 'n', 'q', close_all_views, { desc = 'Close all Diffviews' } }
      local defaults_keymaps = require('diffview.config').defaults.keymaps
      for _, ctx in ipairs({ 'view', 'file_panel', 'file_history_panel' }) do
        if defaults_keymaps[ctx] then
          table.insert(defaults_keymaps[ctx], q_entry)
        end
      end

      -- diff 右栏对工作区文件直接用真实文件 buffer，keymaps.view 绑不到它；
      -- 视图打开期间用 WinEnter 给这类窗口临时挂 q，视图关闭时统一摘除
      local aug = vim.api.nvim_create_augroup('lu5je0_diffview_q', { clear = true })
      vim.api.nvim_create_autocmd('WinEnter', {
        group = aug,
        callback = function()
          if not lib.get_current_view() then
            return
          end
          local bufnr = vim.api.nvim_win_get_buf(0)
          if vim.fn.bufname(bufnr):match('^diffview://') then
            return -- diffview 自有 buffer 已有 view 上下文绑定
          end
          if not q_armed[bufnr] then
            -- 挂载前若有用户自己的 buffer-local q（如 :tab split 后新 tab 的初始
            -- buffer 就是用户的文件），先备份；摘除时恢复，避免覆盖后丢映射
            local backup
            for _, km in ipairs(vim.api.nvim_buf_get_keymap(bufnr, 'n')) do
              if km.lhs == 'q' and km.callback ~= close_all_views then
                backup = {
                  mode = 'n',
                  lhs = 'q',
                  rhs = km.rhs or '',
                  callback = km.callback,
                  opts = {
                    buffer = bufnr,
                    desc = km.desc,
                    silent = km.silent == 1 or km.silent == true,
                    noremap = km.noremap == 1 or km.noremap == true,
                    nowait = km.nowait == 1 or km.nowait == true,
                    expr = km.expr == 1 or km.expr == true,
                  },
                }
                break
              end
            end
            q_armed[bufnr] = backup or false -- 注意：存 nil 会删掉键，摘除时就会漏掉这个 buffer
            vim.keymap.set('n', 'q', close_all_views, { buffer = bufnr, desc = 'Close all Diffviews', nowait = true })
          end
        end,
      })
      -- 用 :DiffviewClose 等其他方式退出时也要摘除临时映射
      opts.hooks = opts.hooks or {}
      local user_view_closed = opts.hooks.view_closed
      opts.hooks.view_closed = function(...)
        -- view_closed 触发时 lib.views 尚未摘除当前 view，延迟到 close() 完成后判断
        vim.schedule(function()
          if #lib.views == 0 then
            disarm_q()
          end
        end)
        if user_view_closed then
          user_view_closed(...)
        end
      end

      diffview.setup(opts)
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    -- config = function()
    --   require('nvim-web-devicons').setup {
    --     override = {
    --       xml = {
    --         icon = '󰈛',
    --         color = '#e37933',
    --         name = 'Xml',
    --       },
    --     },
    --     default = true,
    --   }
    -- end,
    lazy = true
  },

  {
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.7',
    config = function()
      require('lu5je0.ext.telescope').setup()
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    keys = { ',' }
  },

  {
    'akinsho/bufferline.nvim',
    config = function()
      require('lu5je0.ext.bufferline')
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- priority = 9999,
    -- event = 'VeryLazy'
  },
  {
    'nvim-tree/nvim-tree.lua',
    -- just lock，in case of break changes
    -- commit = 'd52fdeb0a300ac42b9cfa65ae0600a299f8e8677',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('lu5je0.ext.nvimtree').setup()
    end,
    cmd = { 'NvimTreeOpen' },
    event = { 'CursorHold', 'CursorHoldI' },
    keys = { '<leader>e', '<leader>fe' },
  },
  {
    'theniceboy/vim-calc',
    config = function()
      vim.keymap.set('n', '<leader>a', vim.fn.Calc)
    end,
    keys = { '<leader>a' }
  },
  -- {
  --   'rootkiter/vim-hexedit',
  --   ft = 'bin',
  -- },
  {
    'sgur/vim-textobj-parameter',
    dependencies = { 'kana/vim-textobj-user' },
    init = function()
      vim.g.vim_textobj_parameter_mapping = 'a'
    end,
    keys = { { mode = 'x', 'ia' }, { mode = 'o', 'ia' }, { mode = 'x', 'aa' }, { mode = 'o', 'aa' },
      { mode = 'n', 'cxia' }, { mode = 'n', 'cxaa' } }
  },
  {
    "gbprod/substitute.nvim",
    config = function()
      require('lu5je0.ext.substitute')
    end,
    keys = { { mode = 'n', 'cx' }, { mode = 'x', 'gr' }, { mode = 'n', 'gr' } }
  },
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup {
        move_cursor = false
      }
    end,
    keys = { { mode = 'n', 'cs' }, { mode = 'n', 'cS' }, { mode = 'n', 'ys' }, { mode = 'n', 'ds' }, { mode = 'x', 'S' } }
  },
  -- {
  --   'othree/eregex.vim',
  --   init = function()
  --     vim.g.eregex_default_enable = 0
  --   end,
  --   cmd = 'S',
  --   keys = {
  --     { mode = 'n', "<leader>/", "<cmd>call eregex#toggle()<cr>", desc = "EregexToggle" },
  --   },
  -- },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('lu5je0.ext.comment').setup()
    end,
    keys = { { mode = 'x', 'gc' }, { mode = 'n', 'gc' }, { mode = 'n', 'gcc' }, { mode = 'n', 'gC' } }
  },
  {
    'akinsho/toggleterm.nvim',
    branch = 'main',
    config = function()
      require('lu5je0.ext.terminal').setup()
    end,
    keys = { { mode = { 'i', 'n' }, '<m-i>' }, { mode = { 'i', 'n' }, '<d-i>' }, { mode = { 'n' }, '<leader>go' } }
  },
  {
    'mg979/vim-visual-multi',
    init = function()
      vim.g.VM_maps = {
        ['Select Cursor Down'] = '<m-n>',
        ['Remove Region'] = '<c-p>',
        ['Skip Region'] = '<c-x>',
        ['VM-Switch-Mode'] = 'v',
      }
    end,
    config = function()
      require('lu5je0.ext.vim-visual-multi').setup()
    end,
    keys = { { mode = { 'n', 'x' }, '<c-n>' }, { mode = { 'n', 'x' }, '<m-n>' } },
  },

  {
    'lu5je0/vim-translator',
    config = function()
      vim.g.translator_proxy_url = 'http://127.0.0.1:1080'
      require('lu5je0.ext.vim-translator')
    end,
    keys = { { mode = 'x', '<leader>sa' }, { mode = 'x', '<leader>ss' }, { mode = 'n', '<leader>ss' },
      { mode = 'n', '<leader>sa' } }
  },

  {
    'dstein64/vim-startuptime',
    init = function()
      vim.g.startuptime_tries = 20
    end,
    config = function()
      vim.cmd("let $NEOVIM_MEASURE_STARTUP_TIME = 'TRUE'")
    end,
    cmd = { 'StartupTime' },
  },

  {
    'mbbill/undotree',
    keys = { '<leader>u' },
    config = function()
      vim.g.undotree_WindowLayout = 3
      vim.g.undotree_SetFocusWhenToggle = 1

      local function undotree_toggle()
        if vim.bo.filetype ~= 'undotree' and vim.bo.filetype ~= 'diff' then
          local winnr = vim.fn.bufwinnr(0)
          vim.cmd('UndotreeToggle')
          vim.cmd(winnr .. ' wincmd w')
          vim.cmd('UndotreeFocus')
        else
          vim.cmd('UndotreeToggle')
        end
      end

      vim.keymap.set('n', '<leader>u', undotree_toggle, {})
    end,
  },

  {
    'folke/which-key.nvim',
    config = function()
      require('lu5je0.ext.whichkey').setup()
    end,
    commit = 'af4ded85542d40e190014c732fa051bdbf88be3d',
    keys = { '<leader>', '<space>' },
  },

  {
    'Pocco81/HighStr.nvim',
    config = function()
      require('lu5je0.ext.highstr')
    end,
    keys = {
      { mode = { 'v' },      '<leader>my' },
      { mode = { 'v' },      '<leader>mg' },
      { mode = { 'v' },      '<leader>mr' },
      { mode = { 'v' },      '<leader>mb' },
      { mode = { 'v', 'n' }, '<leader>mc' }
    }
  },

  {
    'dstein64/nvim-scrollview',
    config = function()
      require('lu5je0.ext.scrollview').setup()
    end,
    event = { 'VeryLazy' }
  },

  -- {
  --   'lewis6991/satellite.nvim',
  --   config = function()
  --     require('lu5je0.ext.satellite').setup()
  --   end,
  --   event = { 'WinScrolled' }
  -- },

  -- nvim-cmp
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      'windwp/nvim-autopairs',
      {
        'L3MON4D3/LuaSnip',
        config = function()
          require('lu5je0.ext.luasnip').setup()
        end
      },
    },

    -- use a release tag to download pre-built binaries
    -- 锁定 1.x：v1.10 是 1.x 最终版，v2 含破坏性变更（需 blink.lib），
    -- 避免将来 Lazy update 自动跳到 v2 导致配置报错
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',
    
    config = function()
      require('lu5je0.ext.blink').setup()
    end,
    
    -- opts_extend = { "sources.default" },
    event = 'InsertEnter',
  },

  {
    'stevearc/oil.nvim',
    config = function()
      require("oil").setup {
        buf_options = {
          buflisted = true
        },
        columns = {
          -- "icon",
          -- "size",
          -- "mtime",
        },
        use_default_keymaps = false,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["gs"] = "actions.change_sort",
          ["g."] = "actions.toggle_hidden",
          ["-"] = "actions.parent",
        }
      }
    end,
    cmd = 'Oil'
  },

  {
    'MunifTanjim/nui.nvim',
    lazy = true
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    config = function()
      require('lu5je0.ext.nvim-ufo')
    end,
    -- 打开文件即加载（BufWinEnter 时 ufo attach，foldmethod=manual 会被窗口局部 expr 覆盖）
    event = 'BufReadPost'
  },

  {
    'nat-418/boole.nvim',
    config = function()
      require('boole').setup {
        mappings = { },
        -- User defined loops
        additions = {
          -- {'Foo', 'Bar'},
        },
        allow_caps_additions = {
          -- enable → disable
          -- Enable → Disable
          -- ENABLE → DISABLE
          { 'enable', 'disable' },
        }
      }
      vim.keymap.set('n', '<c-a>', require('lu5je0.core.cursor').wapper_fn_for_solid_guicursor(function()
        vim.cmd('Boole increment')
      end))
        
      vim.keymap.set('n', '<c-x>', require('lu5je0.core.cursor').wapper_fn_for_solid_guicursor(function()
        vim.cmd('Boole decrement')
      end))
    end,
    keys = { '<c-a>', '<c-x>' }
  },
  -- {
  --   "smjonas/live-command.nvim",
  --   config = function()
  --     require("live-command").setup {
  --       commands = {
  --         Norm = { cmd = "norm" },
  --       },
  --     }
  --   end,
  --   event = { 'CmdlineEnter' }
  -- },
  -- {
  --   'AckslD/messages.nvim',
  --   config = function()
  --     require("messages").setup {
  --       post_open_float = function(_)
  --         vim.cmd [[
  --         au! BufLeave * ++once lua vim.cmd(":q")
  --         set number
  --         ]]
  --         vim.fn.cursor { 99999, 0 }
  --       end
  --     }
  --   end,
  --   cmd = 'Messages',
  -- },

  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('lu5je0.ext.indent-blankline')
    end,
    event = 'VeryLazy'
  },

  -- {
  --   'nvimdev/indentmini.nvim',
  --   config = function()
  --     require("indentmini").setup {
  --       char = '▏'
  --     }
  --     vim.cmd.highlight('IndentLine guifg=#373C44')
  --     vim.cmd.highlight('IndentLineCurrent guifg=#373C44')
  --   end,
  --   event = 'VeryLazy'
  -- },

  -- lsp
  {
    {
      'mason-org/mason.nvim',
      config = function()
        require("mason").setup()
      end,
      event = 'VeryLazy'
    },
    {
      'mason-org/mason-lspconfig.nvim',
      config = function()
        require('mason-lspconfig').setup {
          ensure_installed = {}
        }
      end,
      event = 'VeryLazy',
      dependencies = {
        'mason-org/mason.nvim',
        {
          'neovim/nvim-lspconfig',
          config = function()
            require('lu5je0.ext.lspconfig.lsp').setup()
          end,
        },
      }
    },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          "luvit-meta/library",
        },
      },
      lazy = true,
      dependencies = {
        { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
      }
    },
    {
      'SmiteshP/nvim-navic',
      config = function()
        require('nvim-navic').setup {
          depth_limit = 10,
          depth_limit_indicator = "..",
        }
      end,
      event = { 'LspAttach' }
    },
    {
      "saecki/live-rename.nvim",
      event = { 'LspAttach' },
      config = function()
        vim.keymap.set("n", "<leader>cr", require("live-rename").rename)
      end
    },
    {
      "aznhe21/actions-preview.nvim",
      keys = {
        {
          mode = { "v", "n" },
          "<leader>cc",
          function()
            require("actions-preview").code_actions()
          end,
          desc = "actions-preview"
        },
      },
    },
    {
      'hedyhli/outline.nvim',
      config = function()
        require('lu5je0.ext.symbols-outline').setup()
      end,
      cmd = { 'Outline' },
      keys = { { mode = { 'n' }, '<leader>d' }, { mode = { 'n' }, '<leader>fd' } }
    },
    {
      "dnlhc/glance.nvim",
      config = function()
        require('lu5je0.ext.glance').setup()
      end,
      event = { 'LspAttach' }
    },
    {
      'RRethy/vim-illuminate',
      config = function()
        require('lu5je0.ext.lspconfig.illuminate')
      end,
      dependencies = {
        'neovim/nvim-lspconfig'
      },
      event = { 'CursorHold', 'LspAttach' }
    },
    {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      config = function()
        require('lsp_signature').setup {
          hint_enable = false,
          floating_window = false,
          toggle_key = '<c-p>',
          max_height = 10,
          max_width = 70,
          toggle_key_flip_floatwin_setting = true,
          handler_opts = {
            border = "single"
          }
        }

        vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
          group = vim.api.nvim_create_augroup('lsp_signature.nvim', { clear = true }),
          pattern = '*',
          callback = function(_)
            _LSP_SIG_CFG.floating_window=false
          end,
        })
      end
    },
    -- 诊断/引用/符号的统一列表视图（替代逐个 [d ]d 跳转）
    {
      'folke/trouble.nvim',
      cmd = 'Trouble',
      opts = {},
      keys = {
        { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
        { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
        { '<leader>xl', '<cmd>Trouble lsp_references toggle<cr>', desc = 'LSP References (Trouble)' },
      },
    },
  },

  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
    event = 'InsertEnter'
  },
  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup {
        filetypes = nvim_colorizer_ft,
        user_default_options = {
          names = false,
          mode = "virtualtext"
        }
      }
    end,
    ft = nvim_colorizer_ft,
  },
  {
    'lambdalisue/suda.vim',
    cmd = { 'SudaRead', 'SudaWrite' },
  },
  {
    'iamcco/markdown-preview.nvim',
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    config = function()
      vim.g.mkdp_auto_close = 0
      vim.cmd('command MarkdownPreview call mkdp#util#open_preview_page()')
      vim.cmd('command MarkdownPreviewStop call mkdp#util#stop_preview()')
      vim.g.mkdp_filetypes = { "markdown", "plantuml" }
      
      if os.getenv('KITTY_LISTEN_ON') ~= nil then
        vim.g.mkdp_browserfunc='OpenMarkdownPreview'
        vim.cmd [[
        function OpenMarkdownPreview(url)
          execute "silent ! kitty @ launch --location=split --cwd=current awrit " . a:url
          execute "silent ! kitten @ action --match id:1 next_window"
        endfunction
        ]]
      end
    end,
    cmd = { "MarkdownPreview" },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio'
    },
    config = function()
      require('lu5je0.ext.dap').setup()
    end,
    keys = { '<F10>', '<S-F10>' },
  },
  {
    'jbyuki/one-small-step-for-vimkind',
    config = function()
      vim.api.nvim_create_user_command('LuaDebug', function()
        require("osv").launch({ port = 8086 })
      end, { force = true })
    end,
    cmd = 'LuaDebug'
  },

  {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      vim.o.foldcolumn = '0'
      require("statuscol").setup({
        -- configuration goes here, for example:
        ft_ignore = { 'NvimTree', 'undotree', 'diff', 'Outline', 'dapui_scopes', 'dapui_breakpoints', 'dapui_repl' },
        bt_ignore = { 'terminal' },
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          {
            sign = { name = { "DapBreakpoint" }, maxwidth = 2, colwidth = 2, auto = true },
            click = "v:lua.ScSa"
          },
          -- {
          --   sign = { name = { ".*" }, maxwidth = 1, colwidth = 0, auto = false, wrap = true },
          --   click = "v:lua.ScSa",
          --   condition = { function(args)
          --     return vim.wo[args.win].number
          --     -- return vim.wo[args.win].signcolumn ~= 'no'
          --   end }
          -- },
          {
            text = { builtin.lnumfunc, " " },
            condition = { true, builtin.not_empty },
            click = "v:lua.ScLa",
          }
        },
      })
    end,
    event = 'VeryLazy'
  },

  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    config = function()
      require("lu5je0.ext.edgy").setup()
    end
  },

  -- {
  --   'akinsho/git-conflict.nvim',
  --   version = "*",
  --   config = true,
  --   event = 'VeryLazy'
  -- },

  {
    'nvim-pack/nvim-spectre',
    config = function()
      require('lu5je0.ext.spectre').setup()
    end,
    cmd = 'Spectre',
    -- event = 'VeryLazy'
    keys = { { mode = { 'x' }, '<leader>xr' }, { mode = 'n', '<leader>xf' } },
  },

  {
    'stevearc/profile.nvim',
    -- https://ui.perfetto.dev/
    config = function()
      local function toggle_profile()
        local prof = require("profile")
        if prof.is_recording() then
          prof.stop()
          vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
            if filename then
              prof.export(filename)
              vim.notify(string.format("Wrote %s", filename))
            end
          end)
        else
          print('profile started')
          prof.start("*")
        end
      end
      vim.keymap.set("", "<leader>pp", toggle_profile)
    end,
    keys = { { mode = { 'n' }, '<leader>pp' } }
  },

  {
    "folke/flash.nvim",
    keys = { { mode = { 'n', 'x' }, 't' }, { mode = { 'n' }, 'S' }, { mode = { 'o' }, 'r' } },
    config = function()
      require('flash').setup {
        search = { multi_window = false },
        modes = { char = { enabled = false }, search = { enabled = false } },
        prompt = { enabled = false },
        highlight = { priority = 9999 }
      }
      vim.keymap.set({ 'n', 'x' }, 't', require("flash").jump)
      -- vim.keymap.set('n','s', require("flash").jump)
      -- vim.keymap.set('x','t', require("flash").jump)
      vim.keymap.set('n', 'S', require("flash").treesitter)
      vim.keymap.set('o', 'r', require("flash").remote)
      vim.api.nvim_create_user_command('FlashSearchToggle', function() require("flash").toggle() end, {})
    end
  },

  {
    "FabijanZulj/blame.nvim",
    cmd = "BlameToggle",
    config = function()
      require('blame').setup {
        width = 35,
      }
    end,
    keys = {
      { mode = 'n', "<leader>gb", ":BlameToggle window<cr>", desc = "ToggleGitBlame" },
    },
  },

  {
    'kevinhwang91/nvim-fundo',
    dependencies = 'kevinhwang91/promise-async',
    build = function() require('fundo').install() end,
    config = function()
      vim.o.undofile = true
      require('fundo').setup()
    end,
    event = 'BufReadPre'
  },

  {
    "LunarVim/bigfile.nvim",
    config = function()
      require('lu5je0.ext.big-file').setup()
    end,
    event = 'BufReadPre'
  },
  
  {
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    config = function()
        -- code = {
        --     -- Turn on / off code block & inline code rendering
        --     enabled = true,
        --     -- Turn on / off any sign column related rendering
        --     sign = true,
        --     -- Determines how code blocks & inline code are rendered:
        --     --  none:     disables all rendering
        --     --  normal:   adds highlight group to code blocks & inline code, adds padding to code blocks
        --     --  language: adds language icon to sign column if enabled and icon + name above code blocks
        --     --  full:     normal + language
        --     style = 'full',
        --     -- Determines where language icon is rendered:
        --     --  right: right side of code block
        --     --  left:  left side of code block
        --     position = 'left',
        --     -- Amount of padding to add around the language
        --     -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        --     language_pad = 0,
        --     -- Whether to include the language name next to the icon
        --     language_name = true,
        --     -- A list of language names for which background highlighting will be disabled
        --     -- Likely because that language has background highlights itself
        --     disable_background = { 'diff' },
        --     -- Width of the code block background:
        --     --  block: width of the code block
        --     --  full:  full width of the window
        --     width = 'full',
        --     -- Amount of margin to add to the left of code blocks
        --     -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        --     -- Margin available space is computed after accounting for padding
        --     left_margin = 0,
        --     -- Amount of padding to add to the left of code blocks
        --     -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        --     left_pad = 0,
        --     -- Amount of padding to add to the right of code blocks when width is 'block'
        --     -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        --     right_pad = 0,
        --     -- Minimum width to use for code blocks when width is 'block'
        --     min_width = 0,
        --     -- Determins how the top / bottom of code block are rendered:
        --     --  thick: use the same highlight as the code body
        --     --  thin:  when lines are empty overlay the above & below icons
        --     border = 'thin',
        --     -- Used above code blocks for thin border
        --     above = '▄',
        --     -- Used below code blocks for thin border
        --     below = '▀',
        --     -- Highlight for code blocks
        --     highlight = 'RenderMarkdownCode',
        --     -- Highlight for inline code
        --     highlight_inline = 'RenderMarkdownCodeInline',
        --     -- Highlight for language, overrides icon provider value
        --     highlight_language = nil,
        -- },
      require('render-markdown').setup {
        win_options = {
          -- See :h 'conceallevel'
          conceallevel = {
            -- Used when not being rendered, get user setting
            default = 0,
            -- Used when being rendered, concealed text is completely hidden
            rendered = 0,
          },
        }
      }
    end,
  },

  {
    'shuaixiaomi/md-img-paste.vim',
    config = function ()
      vim.cmd([[
      autocmd FileType markdown nmap <buffer><silent> <leader>pd :call mdip#MarkdownClipboardImage("d")<CR>
      autocmd FileType markdown nmap <buffer><silent> <leader>pc :call mdip#MarkdownClipboardImage("c")<CR>
      let g:mdip_imgdir = 'image'
      " let g:mdip_imgname = 'image'
      ]])
    end
  },

}, opts)
