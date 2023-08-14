local M = {}

function M.convert(language)
  if not language or language == "" then
    language = "python"
  end
  local cmd = string.format(
    [[
    :%%!curlconverter --language %s -
    set ft=%s
    ]],
    language,
    language
  )

  vim.cmd(cmd)
end

return M
