local M = {}

local scrollview = require('scrollview')

-- -- hack mouse handle
-- local handle_mouse = scrollview.handle_mouse
-- scrollview.handle_mouse = function(button)
--   if timer then
--     timer:stop()
--     timer = nil
--   end
--   handle_mouse(button)
-- end

local last_line_nr = nil
function M.begin_timer(enable_cmd, disable_cmd, refresh_cmd)
  local visible_duration = 1500
  local timer = nil

  local function show(params)
    if vim.api.nvim_get_current_buf() ~= params.buf then
      return
    end
    local current_last_line_nr = vim.fn.line("w$")
    if last_line_nr == current_last_line_nr then
      return
    end
    last_line_nr = current_last_line_nr

    if timer then
      timer:stop()
    end
    
    vim.cmd('silent! ' .. enable_cmd)
    
    -- 搜索时不自动隐藏
    if vim.v.hlsearch == 1 then
      return
    end
    
    timer = vim.defer_fn(function()
      if vim.bo.buftype == 'nofile' and vim.bo.filetype == 'vim' then
        return
      end
      ---@diagnostic disable-next-line: param-type-mismatch
      local ok, err = pcall(vim.cmd, 'silent!' .. disable_cmd)
      if not ok then
        print(err)
      end
    end, visible_duration)
  end

  local satellite_group = vim.api.nvim_create_augroup('satellite_group', { clear = true })
  vim.api.nvim_create_autocmd({ 'WinScrolled', 'CmdlineEnter' }, {
    group = satellite_group,
    pattern = { '*' },
    callback = show,
  })

  -- vim.api.nvim_create_autocmd('User', {
  --   group = satellite_group,
  --   pattern = 'FoldChanged',
  --   callback = function()
  --     vim.cmd(refresh_cmd)
  --   end,
  -- })

  -- vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave', 'BufWinLeave', 'FocusLost', 'QuitPre' }, {
  --   group = satellite_group,
  --   pattern = { '*' },
  --   callback = function()
  --     vim.cmd("SatelliteDisable")
  --     -- scrollbar.clear()
  --   end,
  -- })
end

function M.setup()
  scrollview.setup {
    -- excluded_filetypes = { 'nerdtree' , 'NvimTree'},
    current_only = true,
    winblend = 85,
    winblend_gui = 85,
    base = 'right',
    column = 1,
    on_startup = 0,
    signs_max_per_row = 2,
    byte_limit = 2 * 1024 * 1024,
    line_limit = 10000,
    -- signs_on_startup = { 'conflicts', 'search', '' },
    overflow = 'right',
    diagnostics_error_symbol = "·",
    diagnostics_warn_symbol = "·",
    diagnostics_hint_symbol = "·",
  }
  vim.cmd[[
  " Link ScrollView highlight to Pmenu highlight
  " highlight link ScrollView CursorLine

  " Specify custom highlighting for ScrollView
  highlight ScrollView guibg=LightCyan guifg=NONE
  ]]
  
  vim.keymap.set('n', '<tab>', function()
    if vim.g.scrollview_enabled then
      vim.cmd('ScrollViewDisable')
      return
    end
    
    vim.cmd('ScrollViewEnable')
    vim.defer_fn(function()
      vim.cmd('ScrollViewDisable')
    end, 3000)
  end, { nowait = true })
  -- M.begin_timer('ScrollViewEnable', 'ScrollViewDisable', 'ScrollViewRefresh')
end

return M
