vim.loader.enable()
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local core_modules = {
  'lu5je0.options',
  'lu5je0.mappings',
  'lu5je0.plugins',
  'lu5je0.ext-loader',
  'lu5je0.commands',
  'lu5je0.autocmds',
  'lu5je0.filetype',
}

for _, module in ipairs(core_modules) do
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify('Error loading ' .. module .. '\n\n' .. err)
  end
end

vim.cmd('runtime functions.vim')

-- Fix E37 / E162 (unnamed buffers when quitting)
vim.cmd [[
  autocmd QuitPre * if &filetype != 'qf' | if empty(&buftype) | bd 2 | else | bd | endif | endif
]]
