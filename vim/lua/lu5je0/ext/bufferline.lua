local M = {}

-- _G.belong_tab_map = {}
-- local group = vim.api.nvim_create_augroup('tab_belong_group', { clear = true })
--
-- vim.api.nvim_create_autocmd({ 'BufEnter' }, {
--   group = group,
--   callback = function()
--     local buf_number = vim.api.nvim_get_current_buf()
--     if vim.fn.buflisted(buf_number) ~= 1 then
--       return
--     end
--     local buf_key = tostring(buf_number)
--     local set = _G.belong_tab_map[buf_key]
--     if set == nil then
--       _G.belong_tab_map[buf_key] = {}
--       set = _G.belong_tab_map[buf_key]
--     end
--     set[tostring(vim.api.nvim_get_current_tabpage())] = ''
--   end,
-- })
--
-- vim.api.nvim_create_autocmd({ 'BufDelete' }, {
--   group = group,
--   callback = function()
--     local buf_number = vim.api.nvim_get_current_buf()
--     if vim.fn.buflisted(buf_number) ~= 1 then
--       return
--     end
--     local buf_key = tostring(buf_number)
--     if _G.belong_tab_map[buf_key] ~= nil then
--       _G.belong_tab_map[buf_key] = nil
--     end
--   end,
-- })

local bl = require('bufferline')
bl.setup {
  options = {
    numbers = function(opts)
      return string.format('%s', opts.raise(opts.ordinal))
    end,
    offsets = {
      {
        filetype = 'dbui',
        text = 'DBUI',
        highlight = 'Directory',
        text_align = 'center',
      },
      {
        filetype = 'dapui_scopes',
        text = 'DEBUG',
        highlight = 'Directory',
        text_align = 'center',
      },
      {
        filetype = 'fern',
        text = 'Fern',
        highlight = 'NvimTreeNormal',
        text_align = 'center',
      },
      {
        filetype = 'neo-tree',
        text = 'NeoTree',
        highlight = 'Normal',
        text_align = 'center',
      },
      {
        filetype = 'NvimTree',
        text = 'NvimTree',
        highlight = 'NvimTreeNormal',
        text_align = 'center',
        -- padding = 1
      },
      {
        filetype = 'vista',
        text = 'Vista',
        highlight = 'Directory',
        text_align = 'center',
      },
    },
    max_name_length = 12,
    custom_filter = function(buf_number, buf_numbers)
      if vim.bo[buf_number].filetype == 'fugitive' then
        return false
      end
      return true
    end,
    -- custom_filter = function(buf_number, buf_numbers)
    --   local buf_key = tostring(buf_number)
    --   local tab_key = tostring(vim.api.nvim_get_current_tabpage())
    --   if _G.belong_tab_map[buf_key] == nil then
    --     return true
    --   end
    --   if _G.belong_tab_map[buf_key][tab_key] ~= nil then
    --     return true
    --   end
    --   return false
    -- end,
  },
  highlights = {
    buffer_selected = {
      gui = "bold"
    },
  },
}

vim.cmd([[
nnoremap <silent><leader>0 <cmd>BufferLinePick<cr>
]])

for i = 1, 9, 1 do
  vim.keymap.set('n', '<leader>' .. i, function() bl.go_to_buffer(i, true) end)
end

-- vim.cmd('nmap <leader>to :BufferLineCloseLeft<cr>:BufferLineCloseRight<cr>')

vim.keymap.set('n', '<leader>to', function()
  vim.cmd [[
  BufferLineCloseLeft
  BufferLineCloseRight
  ]]
  vim.cmd('norm :<cr>')
end)

vim.keymap.set('n', '<leader>th', function()
  vim.cmd [[ BufferLineCloseLeft ]]
  vim.cmd('norm :<cr>')
end)

vim.keymap.set('n', '<leader>tl', function()
  vim.cmd [[ BufferLineCloseRight ]]
  vim.cmd('norm :<cr>')
end)

return M
