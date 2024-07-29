local ext_loader_group = vim.api.nvim_create_augroup('ext_loader_group', { clear = true })

local function lazy_load(opts)
  if opts and opts.keys then
    for _, key in ipairs(opts.keys) do
      for _, mode in ipairs(key.mode) do
        local lhs = key[1]
        vim.keymap.set(mode, lhs, function()
          vim.keymap.del(mode, lhs)
          opts.config()
          require('lu5je0.core.keys').feedkey(lhs)
        end)
      end
    end
  end
  if opts and opts.commands then
    for _, cmd in ipairs(opts.commands) do
      vim.api.nvim_create_user_command(cmd, function(event)
        local command = {
          cmd = cmd,
          bang = event.bang or nil,
          mods = event.smods,
          args = event.fargs,
          count = event.count >= 0 and event.range == 0 and event.count or nil,
        }
        if event.range == 1 then
          command.range = { event.line1 }
        elseif event.range == 2 then
          command.range = { event.line1, event.line2 }
        end
        vim.api.nvim_del_user_command(cmd)
        
        
        opts.config()
        
        local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
        command.nargs = info.nargs
        if event.args and event.args ~= "" and info.nargs and info.nargs:find("[1?]") then
          command.args = { event.args }
        end
        vim.cmd(command)
      end, {
        bang = true,
        range = true,
        nargs = "*",
        -- complete = function(_, line)
        --   self:_load(cmd)
        --   -- NOTE: return the newly loaded command completion
        --   return vim.fn.getcompletion(line, "cmdline")
        -- end,
      })
    end
  end
  
  if opts and opts.events then
    for _, event in ipairs(opts.events) do
      vim.api.nvim_create_autocmd(event, {
        group = ext_loader_group,
        once = true,
        pattern = { '*' },
        callback = function(_)
          opts.config()
        end
      })
    end
  end
end

-- im
lazy_load({
  config = function()
    if vim.fn.has('gui') == 0 and not vim.g.neovide then
      if vim.fn.has('wsl') == 1 then
        require('lu5je0.misc.im.win.im').setup()
      elseif vim.fn.has('mac') == 1 then
        require('lu5je0.misc.im.mac.im').setup()
      end
    end
  end,
  events = { 'InsertEnter' },
  keys = {
    { mode = { 'n' }, '<leader>vi' },
  }
})

-- require('lu5je0.misc.im.im_keeper').setup({
--   mac = {
--     keep = false,
--     interval = 1000,
--     focus_gained = true,
--   },
--   win = {
--     keep = false,
--     interval = 1000,
--     focus_gained = true,
--   }
-- })

-- json-helper
lazy_load({
  config = function()
    require('lu5je0.misc.json-helper').setup()
  end,
  commands = { 'Json' }
})

-- snippets
-- require('lu5je0.core.snippets').setup()

-- formatter
lazy_load({
  config = function()
    local formatter = require('lu5je0.misc.formatter.formatter')
    formatter.setup {
      format_priority = {
        [{ 'javascript' }] = { formatter.FORMAT_TOOL_TYPE.LSP, formatter.FORMAT_TOOL_TYPE.EXTERNAL },
        [{ 'json' }] = { formatter.FORMAT_TOOL_TYPE.EXTERNAL, formatter.FORMAT_TOOL_TYPE.LSP },
        [{ 'bash', 'sh', 'python', 'yaml' }] = { formatter.FORMAT_TOOL_TYPE.EXTERNAL, formatter.FORMAT_TOOL_TYPE.LSP },
      },
      external_formatter = {
        json = {
          format = function()
            vim.cmd [[ JsonFormat ]]
          end,
          range_format = function()
          end,
        },
        sql = {
          format = function()
            vim.cmd(':%!sql-formatter -l mysql')
          end,
          range_format = function()
          end,
        },
        [{ 'bash', 'sh' }] = {
          format = function()
            vim.cmd(':%!shfmt -i ' .. vim.bo.shiftwidth)
          end,
          range_format = function()
          end,
        },
        [{ 'python' }] = {
          format = function()
            vim.cmd(':%!black -q -')
          end,
          range_format = function()
          end,
        },
        html = {
          format = function()
            vim.cmd(':%!prettier --parser html')
          end,
          range_format = function()
            vim.cmd(":'<,'>%!prettier --parser html")
          end,
        },
        [{ 'xml' }] = {
          format = function()
            vim.cmd(':%!xmllint - --format')
          end,
          range_format = function()
          end,
        },
        [{ 'yaml' }] = {
          format = function()
            vim.cmd(':%!prettier --parser yaml')
          end,
          range_format = function()
            vim.cmd(":'<,'>%!prettier --parser yaml")
          end,
        },
        [{ 'markdown' }] = {
          format = function()
            vim.cmd(':%!prettier --parser markdown')
          end,
          range_format = function()
            vim.cmd(":'<,'>%!prettier --parser markdown")
          end,
        },
        [{ 'javascript' }] = {
          format = function()
            vim.cmd(':%!prettier --parser babel')
          end,
          range_format = function()
            vim.cmd(":'<,'>%!prettier --parser babel")
          end,
        }
      }
    }
  end,
  keys = {
    { mode = { 'n', 'x' }, '<leader>cf' },
  },
})

-- var-naming-converter
lazy_load({
  config = function()
    require('lu5je0.misc.var-naming-converter').key_mapping()
  end,
  keys = {
    { mode = { 'x', 'n' }, '<leader>cnc' },
    { mode = { 'n' },      '<leader>cnC' },

    { mode = { 'x', 'n' }, '<leader>cns' },
    { mode = { 'n' },      '<leader>cnS' },

    { mode = { 'x', 'n' }, '<leader>cnk' },
    { mode = { 'n' },      '<leader>cnK' },

    { mode = { 'x', 'n' }, '<leader>cnp' },
    { mode = { 'n' },      '<leader>cnP' },
  },
})

-- code-runner
lazy_load({
  config = function()
    require('lu5je0.misc.code-runner').key_mapping()
  end,
  keys = {
    { mode = { 'n' }, '<leader>rr' },
    { mode = { 'n' }, '<leader>rd' },
  },
})

-- quit-prompt
lazy_load({
  config = function()
    require('lu5je0.misc.quit-prompt').setup()
  end,
  keys = {
    { mode = { 'n' }, '<leader>q' },
    { mode = { 'n' }, '<leader>Q' },
  }
})

-- require('lu5je0.misc.dirbuf-hijack').setup()
require('lu5je0.misc.oil-hijack').setup()

-- require('lu5je0.misc.file-scope-highlight').file_handlers = {
--   json = function(ns_id)
--     vim.api.nvim_set_hl(ns_id, '@boolean', { fg = '#deb974' })
--     vim.api.nvim_set_hl(ns_id, '@number', { fg = '#6cb6eb' })
--   end,
-- }

lazy_load({
  config = function()
    require('lu5je0.misc.redir')
  end,
  commands = { 'Redir', "Messages" }
})

-- base64
lazy_load({
  config = function()
    require('lu5je0.misc.base64').create_command()
  end,
  commands = { 'Base64Decode', 'Base64Encode' }
})

-- timestamp
lazy_load({
  config = function()
    require('lu5je0.misc.gmt').create_command()
  end,
  commands = { 'TimestampToggle' }
})
