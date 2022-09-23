local M = {}

local devicons = require('nvim-web-devicons')

local function create_popup(msg)
  local Popup = require('nui.popup')
  local event = require('nui.utils.autocmd').event

  local width = 55
  local popup_options = {
    enter = true,
    border = {
      style = 'single',
      highlight = 'Fg',
      text = {
        -- top = 'Exiting',
        -- top_align = 'center',
      },
    },
    highlight = 'Normal:Normal',
    position = {
      row = '45%',
      col = '48%',
    },
    relative = 'editor',
    size = {
      width = width,
      height = 2 + #msg.text,
    },
    opacity = 1,
    zindex = 100,
  }

  local popup = Popup(popup_options)

  local opts = { noremap = true, nowait = true, buffer = popup.bufnr }
  vim.keymap.set('n', '<esc>', function()
    popup:unmount()
  end, opts)

  vim.keymap.set('n', 'q', function()
    popup:unmount()
  end, opts)

  vim.keymap.set('n', '<c-c>', function()
    popup:unmount()
  end, opts)

  vim.keymap.set('n', '<cr>', function()
    popup:unmount()
  end, opts)

  vim.keymap.set('n', 'n', function()
    popup:unmount()
  end, opts)

  vim.keymap.set('n', '<leader>Q', function() end, opts)

  vim.keymap.set('n', 'y', function()
    vim.cmd('qa!')
  end, opts)

  vim.keymap.set('n', 's', function()
    vim.cmd('wqa!')
  end, opts)

  vim.fn.win_execute(popup.winid, 'set ft=confirm')

  local function text_align_center(text)
    text = string.rep(' ', math.floor((width - #text) / 2)) .. text
    return text
  end

  local function get_extension(filename)
    return filename:match(".+%.(%w+)$")
  end

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { text_align_center(msg.title) })

  local title_group
  if #msg.text == 0 then
    title_group = 'Green'
  else
    title_group = 'Red'
  end

  vim.api.nvim_buf_add_highlight(popup.bufnr, -1, title_group, 0, 0, -1)
  for i, filename in ipairs(msg.text) do
    local icon, hi_group = devicons.get_icon(filename, get_extension(filename), {})
    vim.api.nvim_buf_set_lines(popup.bufnr, i, i + 1, false, { ' ' .. icon .. ' ' .. filename })
    vim.api.nvim_buf_add_highlight(popup.bufnr, -1, hi_group, i, 1, 5)
  end
  vim.api.nvim_buf_set_lines(popup.bufnr, #msg.text + 1, #msg.text + 2, false, { text_align_center(msg.choice) })

  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(popup.bufnr, 'readonly', true)

  -- unmount component when cursor leaves buffer
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  popup:mount()
  vim.fn.cursor { 99, 99 }
end

local function exit_vim_with_dialog()
  local unsave_buffers = {}

  for _, buffer in ipairs(vim.fn.getbufinfo { bufloaded = 1, buflisted = 1 }) do
    if buffer.changed == 1 then
      table.insert(unsave_buffers, buffer)
    end
  end

  local content = { title = '', choice = '', text = {} }
  if #unsave_buffers ~= 0 then
    content.title = 'The change of the following buffers will be discarded.'

    for _, buffer in ipairs(unsave_buffers) do
      local filename = vim.fn.fnamemodify(buffer.name, ':t')
      if filename == '' then
        filename = '[No Name] '
      end
      table.insert(content.text, filename)
    end

    content.choice = '[N]o, (Y)es, (S)ave ALl'
  else
    content.title = 'Exit vim?'
    content.choice = '[N]o, (Y)es: '
  end

  create_popup(content)
end

local function exit_vim_by_comfirm()
  local unsave_buffers = {}

  for _, buffer in ipairs(vim.fn.getbufinfo { bufloaded = 1, buflisted = 1 }) do
    if buffer.changed == 1 then
      table.insert(unsave_buffers, buffer)
    end
  end

  local msg = nil
  local options = '&No\n&Yes'

  if #unsave_buffers ~= 0 then
    msg = 'The change of the following buffers will be discarded.'
    for _, buffer in ipairs(unsave_buffers) do
      local name = require('nvim-web-devicons').get_icon(buffer.name, string.split(buffer.name, '.')[-1]) ..
          ' ' .. vim.fn.fnamemodify(buffer.name, ':t')
      if name == '' then
        name = '[No Name] ' .. buffer.bufnr
      end
      msg = msg .. '\n' .. name
    end

    options = options .. '\n&Save All'
  else
    msg = 'Exit vim?'
  end

  local confirm_value = vim.fn.confirm(msg, options)
  if confirm_value == 1 then
    return
  elseif confirm_value == 2 then
    vim.cmd('qa!')
  elseif confirm_value == 3 then
    vim.cmd('wqa!')
  end
end

M.close_buffer = function()
  local valid_buffers = require('lu5je0.core.buffers').valid_buffers()
  local cur_buf_nr = vim.api.nvim_get_current_buf()

  local txt_window_cnt = 0
  for _, v in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if table.contain(valid_buffers, vim.api.nvim_win_get_buf(v)) then
      txt_window_cnt = txt_window_cnt + 1
    end
  end

  -- 如果在非text window下，直接quit
  if txt_window_cnt ~= 0 and not table.contain(valid_buffers, cur_buf_nr) then
    vim.cmd("q")
    return
  end

  -- 如果编辑过buffer，则需要确认
  if vim.bo.modified and txt_window_cnt == 1 then
    local confirm_result = vim.fn.confirm("Close without saving?", "&No\n&Yes")
    if confirm_result ~= 2 then
      return
    end
  end

  -- 一个tab页中有两个以上的buffer时，直接quit
  if txt_window_cnt > 1 then
    vim.cmd("q")
  else
    vim.cmd("bp")
    vim.cmd("bd! " .. cur_buf_nr)
  end
end

M.exit = exit_vim_with_dialog

return M
