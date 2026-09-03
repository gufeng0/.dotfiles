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
-- silent! avoids E516 (no buffers deleted) noise in headless smoke runs
-- QuitPre 里的 `silent! bd` 会删掉当前窗口的 buffer；在 diffview 视图内时这会
-- 打断 diffview 的布局（窗口 buffer 被换/删），进而中断 :qa 的关闭序列——
-- 表现为 ":qa 退不出去"。有 diffview 视图存在时跳过该清理逻辑（用 Lua 闭包，
-- 避免 vimscript 里 require 的兼容问题；diffview 未加载时不影响原行为）。
do
  local function quitpre_cleanup()
    local ok_loaded, lib = pcall(require, 'diffview.lib')
    if ok_loaded and lib and #lib.views > 0 then
      return -- diffview 视图存在：跳过 buffer 清理，避免打断 :qa
    end
    if vim.bo.filetype == 'qf' then
      return
    end
    if vim.bo.buftype == '' then
      pcall(vim.cmd, 'silent! bd 2')
    else
      pcall(vim.cmd, 'silent! bd')
    end
  end
  vim.api.nvim_create_autocmd('QuitPre', {
    group = vim.api.nvim_create_augroup('lu5je0_quitpre_bd', { clear = true }),
    callback = quitpre_cleanup,
  })
end
