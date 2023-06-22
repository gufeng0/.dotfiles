local M = {}

local group = vim.api.nvim_create_augroup('big-file', { clear = true })

local function disable(features, buf_nr, max_size)
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
  if ok and stats then
    for _, v in ipairs(features) do
      if type(v) == "function" then
        if stats.size > max_size then
          v(buf_nr)
        end
      elseif type(v) == "table" then
        if stats.size > v.size then
          v[1](buf_nr)
        end
      end
    end
  end
end

function M.setup(config)
  config = vim.tbl_deep_extend('force', {
    size = 1024 * 1024, -- 1000 KB
    features = {}
  }, config)

  if #config.features == 0 then
    return
  end

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    pattern = '*',
    callback = function(arg)
      disable(config.features, arg.buf, config.size)
    end,
  })
end

return M
