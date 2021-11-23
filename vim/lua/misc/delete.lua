local M = {}

function M.deleteLines()
  vim.cmd(":g/" .. vim.call('visual#visual_selection') .. "/d")
end

function M.deleteNullLines()
  vim.cmd(":g/^$/d")
end

function M.deleteAll()
  source = vim.call('visual#visual_selection')
  source = string.gsub(source, "\\","\\\\")
  vim.cmd(":g/".. source .. "/d")
end


return M

