local M = {}

local function osc52_copy_fallback(lines)
  local text = table.concat(lines, '\n')
  local encoded = vim.base64.encode(text)
  vim.api.nvim_chan_send(2, string.format('\027]52;c;%s\027\\', encoded))
end

function M.setup()
  vim.o.clipboard = 'unnamedplus'

  local ok, osc52 = pcall(require, 'vim.ui.clipboard.osc52')
  if ok then
    vim.g.clipboard = {
      name = 'osc52',
      copy = {
        ['+'] = osc52.copy('+'),
        ['*'] = osc52.copy('*'),
      },
      paste = {
        ['+'] = osc52.paste('+'),
        ['*'] = osc52.paste('*'),
      },
    }
    return
  end

  local copy = function(lines)
    osc52_copy_fallback(lines)
  end

  vim.g.clipboard = {
    name = 'osc52-fallback',
    copy = {
      ['+'] = copy,
      ['*'] = copy,
    },
    paste = {
      ['+'] = function()
        return 0
      end,
      ['*'] = function()
        return 0
      end,
    },
  }
end

return M
