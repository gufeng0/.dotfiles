local wezterm = require('wezterm');
local mux = wezterm.mux

local is_win = string.find(wezterm.target_triple, 'windows')
local is_mac = string.find(wezterm.target_triple, 'apple')

-- "Thin"
-- "ExtraLight"
-- "Light"
-- "DemiLight"
-- "Book"
-- "Regular"
-- "Medium"
-- "DemiBold"
-- "Bold"
-- "ExtraBold"
-- "Black"
-- "ExtraBlack".
local font = (function()
  local r = {}
  if is_win then
    r.text_font = wezterm.font("JetBrainsMonoNL Nerd Font Mono",
      { weight = "Medium", stretch = "Normal", style = "Normal" })
    r.tab_bar_font_size = 10.0
  elseif is_mac then
    r.text_font = wezterm.font("JetBrainsMonoNL Nerd Font Mono", { weight = "DemiBold", stretch = "Normal", style = "Normal" })
    r.tab_bar_font_size = 11.5
  end
  return r
end)()

local config = {
  -- initial_cols = 155,
  -- initial_rows = 50,
  -- for keymap alt t
  default_prog = (function(args)
    if is_win then
      return { "wsl", "--cd", "~" }
    end
  end)(),
  color_scheme = "Gruvbox Dark (Gogh)",
  use_resize_increments = true,
  -- ./wezterm.exe ls-fonts --list-system
  font = font.text_font,
  window_frame = {
    font_size = font.tab_bar_font_size,
    active_titlebar_bg = "#2C2E34",
    inactive_titlebar_bg = "#2C2E34",
  },
  
  -- tab bar在上面
  -- hide_tab_bar_if_only_one_tab = false,
  -- use_fancy_tab_bar = true,
  -- tab_bar_at_bottom = false,
  -- window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  -- integrated_title_button_style = "Windows",
  -- integrated_title_button_color = "auto",
  -- integrated_title_button_alignment = "Right",
  
  -- tab bar在下面
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  -- max_fps = 120,
  -- window_background_opacity = 0.992,
  -- text_background_opacity = 0.9,
  colors = {
    tab_bar = {
      active_tab = {
        bg_color = "#2C2E34",
        fg_color = "#c0c0c0",
        intensity = "Normal",
        underline = "None",
        italic = false,
        strikethrough = false,
      },
      inactive_tab = {
        bg_color = "#2C2E34",
        fg_color = "#808080",
      },
      new_tab = {
        bg_color = "#2C2E34",
        fg_color = "#808080",
      },
    },
  },
  font_size = (function()
    if is_mac then
      return 14.5
    elseif is_win then
      return 11.5
    end
  end)(),
}

if is_mac then
  config.cursor_thickness = '0.06cell'
end

-- config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }
-- config.keys = {
--   { key = "h", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Left" } },
--   { key = "l", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Right" } },
--   { key = "k", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Up" } },
--   { key = "j", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Down" } },
--   { key = "o", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Prev" } },
--   ---@diagnostic disable-next-line: unused-local
--   {
--     key = "v",
--     mods = "LEADER",
--     action = wezterm.action_callback(function(win, pane)
--       wezterm.log_info(wezterm.target_triple)
--     end)
--   },
--   -- { key = "o", mods = "LEADER", action = "ActivateLastTab" },
--   { key = "x",  mods = "LEADER", action = wezterm.action { CloseCurrentPane = { confirm = true } } },
--   { key = "\"", mods = "LEADER", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
--   { key = "c",  mods = "LEADER", action = wezterm.action { SpawnTab = "DefaultDomain" } },
--   { key = "n",  mods = "LEADER", action = wezterm.action { ActivateTabRelative = 1 } },
--   { key = "t",  mods = "ALT",    action = wezterm.action { SpawnTab = "DefaultDomain" } },
-- }

local mod_key
if is_mac then
  mod_key = 'SHIFT|CMD'
elseif is_win then
  mod_key = 'SHIFT|ALT'
end

config.keys = {
  { key = '%', mods = mod_key, action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '"', mods = mod_key, action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = "o", mods = mod_key, action = wezterm.action { ActivatePaneDirection = "Prev" } },
  { key = 'c', mods = mod_key, action = wezterm.action { SpawnTab = "DefaultDomain" } },
  { key = 't', mods = 'ALT', action = wezterm.action { SpawnTab = "DefaultDomain" } },
  { key = 't', mods = 'CMD', action = wezterm.action { SpawnTab = "DefaultDomain" } },
  { key = 'l', mods = mod_key, action = wezterm.action { ActivatePaneDirection = "Right" } },
  { key = 'n', mods = mod_key, action = wezterm.action { ActivateTabRelative = 1 } },
  { key = 'h', mods = mod_key, action = wezterm.action { ActivatePaneDirection = "Left" } },
  { key = 'k', mods = mod_key, action = wezterm.action { ActivatePaneDirection = "Up" } },
  { key = 'j', mods = mod_key, action = wezterm.action { ActivatePaneDirection = "Down" } },
  { key = 'x', mods = mod_key, action = wezterm.action { CloseCurrentPane = { confirm = true } } },
  { key = 'l', mods = mod_key, action = wezterm.action.ShowDebugOverlay },
  ---@diagnostic disable-next-line: unused-local
  { key = 'q', mods = mod_key, action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_tab()
    end),
  },
  ---@diagnostic disable-next-line: unused-local
  { key = '!', mods = mod_key, action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_window()
    end),
  },
  {
    key = 'r',
    mods = mod_key,
    action = wezterm.action.ReloadConfiguration,
  },
}

config.skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
  'nu',
  'cmd.exe',
  'pwsh.exe',
  'powershell.exe',
}
config.window_close_confirmation = 'NeverPrompt'

wezterm.on('gui-startup', function(cmd)
  if is_win then
    if cmd then
      mux.spawn_window { width = 119, height = 45, args = { "wsl", "--cd", cmd.cwd } }
    else
      mux.spawn_window { width = 119, height = 45, args = { "wsl", "--cd", "~" } }
    end
  end
end)

return config
