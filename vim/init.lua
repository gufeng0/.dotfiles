if not pcall(require, 'impatient') then
  vim.notify('impatient fail')
end
require('lu5je0.plugins')
require('lu5je0.enhance')
require('lu5je0.commands')
require('lu5je0.patch')
require('lu5je0.mappings')
require('lu5je0.autocmds')
require('lu5je0.filetype')

vim.cmd([[
runtime settings.vim
runtime functions.vim
runtime mappings.vim
runtime misc.vim
runtime autocmd.vim
if has("mac")
  runtime im.vim
endif
]])

if vim.fn.has('wsl') == 1 then
  table.insert(_G.defer_plugins, 'im-switcher.nvim')
end

for _, plugin in ipairs(_G.defer_plugins) do
  vim.schedule(function()
    vim.cmd('PackerLoad ' .. plugin)
  end)
end

vim.defer_fn(function()
  vim.o.clipboard = 'unnamedplus'
  vim.cmd('packadd matchit')
end, 10)
