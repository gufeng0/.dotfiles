local M = {}

local config_file = vim.fn.stdpath('data') .. '/nvim.env.json'

local cache = {}

local function read_file(filename)
  local f = io.open(filename, 'r')
  if f == nil then
    return '{}'
  end
  local content = f:read('*all')
  f:close()
  return content
end

local function write_file(filename, content)
  local f = assert(io.open(filename, 'w+'))
  f:write(content)
  f:close()
end

function M.get(name, default)
  if cache[name] then
    return cache[name]
  end

  local value = vim.fn.json_decode(read_file(config_file))[name]
  if value == nil or value == "" then
    value = default
  end
  cache[name] = value
  return value
end

function M.set(name, value)
  local json = vim.fn.json_decode(read_file(config_file))
  json[name] = value
  write_file(config_file, vim.fn.json_encode(json))

  cache[name] = nil
end

return M
