local M = {}

function M.deleteLines()
  vim.cmd(":g/" .. vim.call('visual#visual_selection') .. "/d")
end

function M.deleteNullLines()
  vim.cmd(":g/^$/d")
end

return M

