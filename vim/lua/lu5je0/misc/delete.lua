local M = {}

function M.deleteLines()
  local source = vim.call('visual#visual_selection')
  source = require('lu5je0.misc.vim_escape').escape(source)
  vim.cmd(":g/" .. source  .. "/d")
end

function M.deleteAll()
  local source = vim.call('visual#visual_selection')
  source = require('lu5je0.misc.vim_escape').escape(source)
  local r = ":%s/" .. source .. "//g"
  vim.cmd(r)
end

function M.deleteImg()
  local source = vim.call('visual#visual_selection')
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
 
