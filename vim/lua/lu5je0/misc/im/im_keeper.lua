local M = {}

local group = vim.api.nvim_create_augroup('im-keeper', { clear = true })

local function switch_to_en()
  if M.os == 'mac' then
    require('lu5je0.misc.im.mac.im').switch_to_en()
  elseif M.os == 'win' then
    require('lu5je0.misc.im.win.im').disable_ime()
  end
end

local focus_gained = true
local function keep_normal_mode_with_abc_im()
  local timer = vim.loop.new_timer()

  timer:start(0, M.interval, vim.schedule_wrap(function()
    if focus_gained then
      if vim.api.nvim_get_mode().mode == 'n' then
        switch_to_en()
        -- print('switch_to_en when focus_gained')
      end
    end
  end))
  
  vim.api.nvim_create_autocmd('FocusLost', {
    group = group,
    pattern = { '*' },
    callback = function()
      focus_gained = false
    end
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    pattern = { '*' },
    callback = function()
      focus_gained = true
    end
  })
end

local function switch_normal_mode_on_focus_gained()
  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    pattern = { '*' },
    callback = function()
      if vim.api.nvim_get_mode().mode == 'n' then
        switch_to_en()
      end
    end
  })
end

M.setup = function(config)
  config = vim.tbl_deep_extend('force', {
    mac = false,
    win = false,
    keep = false,
    focus_gained = true,
    interval = 1000
  }, config)
  M.interval = config.interval
  
  if vim.fn.has('mac') == 1 then
    M.os = 'mac'
  elseif vim.fn.has('wsl') == 1 then
    M.os = 'win'
  end
  
  if (config.mac and M.os == 'mac') or (config.win and M.os == 'win') then
    if config.keep then
      keep_normal_mode_with_abc_im()
    elseif config.focus_gained then
      switch_normal_mode_on_focus_gained()
    end
  end
end

return M
