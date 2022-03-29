local M = {}
local visual_utils = require('utils.visual-utils')

local function is_contain_space(var_name)
  return var_name:match(' ') ~= nil
end

local function split(var_name)
  var_name = var_name:gsub('(%S)(%u)', '%1_%2'):lower()
  local tokens = {}
  for token in string.gmatch(var_name, '[a-zA-Z]+') do
    table.insert(tokens, token)
  end
  return tokens
end

local function get_var_name(word_mode)
  local var_name = nil
  if vim.api.nvim_get_mode()['mode'] == 'v' then
    var_name = visual_utils.selected_text()
  else
    if word_mode == 'WORD' then
      var_name = vim.fn.expand('<cWORD>')
    else
      var_name = vim.fn.expand('<cword>')
    end
  end
  return var_name
end

local function replace_var(var_name)
  visual_utils.visual_replace(var_name)
end

local function base_convert(convert_strategy_fn, word_mode)
  local var_name = get_var_name(word_mode)
  if not is_contain_space(var_name) then
    local tokens = split(var_name)
    var_name = convert_strategy_fn(tokens)
    if vim.api.nvim_get_mode()['mode'] == 'n' then
      if word_mode == 'WORD' then
        vim.cmd('norm viW')
      else
        vim.cmd('norm viw')
      end
    end
    replace_var(var_name)
  end
end

local function vim_add_repeat(case_type, word_mode)
  local cmd = [[call repeat#set("\<plug>(ConvertTo%s%s)", 1)]]
  cmd = cmd:format(case_type, word_mode)
  vim.cmd(cmd)
end

M.convert_to_camel = function(word_mode)
  base_convert(function(tokens)
    local var_name = ''
    for i, token in ipairs(tokens) do
      if i == 1 then
        var_name = var_name .. token
      else
        var_name = var_name .. token:gsub('^%l', string.upper)
      end
    end
    return var_name
  end, word_mode)

  vim_add_repeat('Camel', word_mode)
end

M.convert_to_snake = function(word_mode)
  base_convert(function(tokens)
    local var_name = ''
    for i, token in ipairs(tokens) do
      if i == 1 then
        var_name = var_name .. token
      else
        var_name = var_name .. '_' .. token
      end
    end
    return var_name
  end, word_mode)

  vim_add_repeat('Snake', word_mode)
end

M.convert_to_pascal = function(word_mode)
  base_convert(function(tokens)
    local var_name = ''
    for _, token in ipairs(tokens) do
      var_name = var_name .. token:gsub('^%l', string.upper)
    end
    return var_name
  end, word_mode)

  vim_add_repeat('Pascal', word_mode)
end

M.convert_to_kebab = function(word_mode)
  base_convert(function(tokens)
    local var_name = ''
    for i, token in ipairs(tokens) do
      if i == 1 then
        var_name = var_name .. token
      else
        var_name = var_name .. '-' .. token
      end
    end
    return var_name
  end, word_mode)

  vim_add_repeat('Kebab', word_mode)
end

M.mappings = function()
  vim.cmd([[
  map <plug>(ConvertToCamelWORD) <cmd>lua require('misc.var_naming_converter').convert_to_camel('WORD')<cr>
  map <plug>(ConvertToCamelword) <cmd>lua require('misc.var_naming_converter').convert_to_camel('word')<cr>

  map <plug>(ConvertToSnakeWORD) <cmd>lua require('misc.var_naming_converter').convert_to_snake('WORD')<cr>
  map <plug>(ConvertToSnakeword) <cmd>lua require('misc.var_naming_converter').convert_to_snake('word')<cr>

  map <plug>(ConvertToPascalWORD) <cmd>lua require('misc.var_naming_converter').convert_to_pascal('WORD')<cr>
  map <plug>(ConvertToPascalword) <cmd>lua require('misc.var_naming_converter').convert_to_pascal('word')<cr>

  map <plug>(ConvertToKebabWORD) <cmd>lua require('misc.var_naming_converter').convert_to_kebab('WORD')<cr>
  map <plug>(ConvertToKebabword) <cmd>lua require('misc.var_naming_converter').convert_to_kebab('word')<cr>
  ]])
end
return M
