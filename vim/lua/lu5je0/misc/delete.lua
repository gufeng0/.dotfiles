local M = {}

function M.deleteLines()
  vim.cmd(":g/^$/d")
end

function M.deleteLines()
  local source = require('lu5je0.core.visual').get_visual_selection_as_string()
  source = require('lu5je0.misc.vim_escape').escape(source)
  vim.cmd(":g/" .. source  .. "/d")
end

function M.deleteAll()
  local source = require('lu5je0.core.visual').get_visual_selection_as_string()
  print("Selected Text: " .. source)
  source = require('lu5je0.misc.vim_escape').escape(source)
  local r = ":%s/" .. source .. "//g"
  vim.cmd(r)
end

function M.deleteImg()
  local source = require('lu5je0.core.visual').get_visual_selection_as_string()
  local text = require('lu5je0.misc.vim_escape').escape(source)
  local r = ":s/" .. text .. "//g"
  vim.cmd(r)

  source = string.sub(source, string.find(source, "%(.*%)"))
  source = string.sub(source, 2, string.len(source)-1)
  local path = vim.call('expand','%:h')
  local param = string.format(":!rm -rf %s/%s",path,source)
  vim.cmd(param)
end

return M
 
