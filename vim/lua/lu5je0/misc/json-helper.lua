local M = {}
local cursor_utils = require('lu5je0.core.cursor')

-- 当前 buffer 内容是否能被 jq 解析（JSONC 的注释/尾逗号会让 jq 报错）
-- 用 jq empty 探测退出码，不走 shell 避免转义问题
local function jq_can_parse()
  if vim.fn.executable('jq') == 0 then
    return false
  end
  local json_string = table.concat(vim.api.nvim_buf_get_text(0, 0, 0, -1, -1, {}), '\n')
  vim.fn.system({ 'jq', 'empty' }, json_string)
  return vim.v.shell_error == 0
end

-- 有注释/尾逗号时：JsonFormat 用 prettier（保留注释），查询/重排类用 jqc（丢失注释）
local function jqc_available()
  return vim.fn.executable('jqc') == 1
end

local function prettier_available()
  return vim.fn.executable('prettier') == 1
end

-- 提示用户操作会丢注释，确认才继续（默认取消，安全优先）
local function confirm_comment_loss()
  local choice = vim.fn.confirm(
    'buffer 含注释/尾逗号，jq 无法解析，此操作将丢失注释。格式化可用 JsonFormat（保留注释）。',
    '&继续\n&取消', 2, '提示'
  )
  return choice == 1
end

function M.compress()
  if jq_can_parse() or not jqc_available() then
    vim.cmd(':%!jq -c')
  else
    vim.cmd(':%!jqc -c .')
  end
end

-- 格式化：jq 能解析则原路（规范化语义），否则 prettier jsonc 保留注释
function M.format()
  if jq_can_parse() then
    vim.cmd(':%!jq')
  elseif prettier_available() then
    vim.cmd(':%!prettier --parser jsonc')
  else
    vim.cmd(':%!jq')
  end
end

function M.path_copy()
  local path = require('jsonpath').get()
  
  print(path)
  vim.fn.setreg('*', path)
  vim.fn.setreg('"', path)
end

function M.jq(args)
  if jq_can_parse() then
    vim.cmd(string.format(':%%!jq \'%s\'', args))
  elseif jqc_available() and confirm_comment_loss() then
    vim.cmd(string.format(':%%!jqc \'%s\'', args))
  end
end

function M.extract()
  local path = require('jsonpath').get()
  if jq_can_parse() then
    vim.cmd(string.format(':%%!jq \'%s\'', path))
  elseif jqc_available() and confirm_comment_loss() then
    vim.cmd(string.format(':%%!jqc \'%s\'', path))
  end
end

local function process_json_keys()
  local jq_result = ''
  if not vim.b.__jq_result or vim.bo.modified then
    local json_string = table.concat(vim.api.nvim_buf_get_text(0, 0, 0, -1, -1, {}), '\n')
    local bin = jq_can_parse() and 'jq' or (jqc_available() and 'jqc' or 'jq')
    local jq = io.popen(string.format([[echo '%s' |
    %s '.. |
    if type == "object" then
      to_entries[] | [.key, if .value | type == "array" then "[]" else "" end] | join("")
    else
      empty
    end'  2>/dev/null |
    sort --uniq ]], json_string, bin))
    jq_result = jq:read('*a')
    jq:close()
    
    vim.b.__jq_result = jq_result
  else
    jq_result = vim.b.__jq_result
  end

  local keys = {}
  for s in jq_result:gmatch("[^\r\n]+") do
    s = string.sub(s, 2, -2)
    if s:match('%.') then
      s = ('"%s"'):format(s)
      -- todo fix s end with []
    end
    table.insert(keys, s)
  end
  return keys
end

local function jq_complete(text)
  local last_char = text:sub(-1, -1)
  if last_char == '[' then
    return { text .. ']' }
  end
  if last_char == ']' then
    return {}
  end

  local complete_text = ''
  for s in text:gmatch('%w+$') do
    complete_text = s
  end

  -- get json keys
  local json_keys = process_json_keys()

  -- match
  local words = {}
  for _, json_key in ipairs(json_keys) do
    if vim.startswith(json_key, complete_text) then
      table.insert(words, text .. json_key:sub(#complete_text + 1, -1))
    end
  end
  return words
end

function M.setup()
  vim.api.nvim_create_user_command('JsonCompress', function()
    M.compress()
  end, { force = true })
  
  vim.api.nvim_create_user_command('JsonExtract', function()
    M.extract()
  end, { force = true })
  
  vim.api.nvim_create_user_command('JsonCopyPath', function()
    M.path_copy()
  end, { force = true })

  vim.api.nvim_create_user_command('JsonFormat', function()
    cursor_utils.save_position()
    M.format()
    cursor_utils.goto_saved_position()
  end, { force = true })
  
  vim.api.nvim_create_user_command('JsonFixNonStringKey', function(args)
    local cmd = ':%!java -jar ~/.local/bin/json-hanlder-1.0.jar'
    if args.args then
      cmd = cmd .. ' ' .. args.args
    end
    vim.cmd(cmd)
    vim.cmd('Json')
  end, { force = true, nargs = '*' })
  
  vim.api.nvim_create_user_command('JsonSortByKey', function()
    if jq_can_parse() then
      vim.cmd('set ft=json')
      vim.cmd(':%!jq --sort-keys')
    elseif jqc_available() and confirm_comment_loss() then
      -- jqc 无 -S flag，用 filter 排序（顶层 key）；jq 的 --sort-keys 是递归排序，有差异
      vim.cmd('set ft=json')
      vim.cmd(':%!jqc \'to_entries | sort_by(.key) | from_entries\'')
    end
  end, { force = true })

  vim.api.nvim_create_user_command('Json', function()
    -- 记录格式化前是否为 jsonc（有注释/尾逗号），格式化后避免误设 ft=json
    local is_jsonc = not jq_can_parse()
    M.format()
    if vim.fn.line("$") < 10000 then
      vim.cmd(is_jsonc and 'set ft=jsonc' or 'set ft=json')
    end
  end, { force = true })

  vim.api.nvim_create_user_command('Jq', function(args)
    M.jq(args.args)
  end, { force = true, nargs = '*', complete = jq_complete })
end

return M
