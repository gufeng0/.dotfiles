local M = {}

function M.escape(text)
  text = vim.call('fnameescape',text)
  text = string.gsub(text, "/", "\\/")
  return text
end

return M
