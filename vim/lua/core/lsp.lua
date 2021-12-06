local M = {}

M.servers = {
  "sumneko_lua", "pyright", "jsonls", "bashls", "vimls"
}

M.on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gu', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gn', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('i', '<c-p>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>cc', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gb', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>ce', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<leader>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  buf_set_keymap('n', '<leader><space>', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
end

M.lua_setting = {
  Lua = {
    -- completion = {
    --   callSnippet = "Replace",
    -- },
    runtime = {
      -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      version = "LuaJIT",
    },
    workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
        },
        maxPreload = 100000,
        preloadFileSize = 10000
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {"vim"},
    },
    telemetry = { enable = false }
  }
}

function M.setup()

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.documentationFormat = {
      "markdown", "plaintext"
  }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport =
      true
  capabilities.textDocument.completion.completionItem.tagSupport = {
      valueSet = {1}
  }
  capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {"documentation", "detail", "additionalTextEdits"}
  }

  -- diagnostic
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      virtual_text = false,
      signs = true,
      update_in_insert = true,
    }
  )
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- lsp_signature
  require "lsp_signature".setup({
    floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
    floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
    -- will set to true when fully tested, set to false will use whichever side has more space
    -- this setting will be helpful if you do not want the PUM and floating win overlap
    hint_enable = false, -- virtual hint enable
    timer_interval = 100000,
    handler_opts = {
      border = "single"   -- double, rounded, single, shadow, none
    },
    always_trigger = false,
    toggle_key = '<c-p>' -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
  })
  vim.cmd[[
    augroup clean_signature
      autocmd!
      autocmd BufEnter * silent! autocmd! Signature InsertEnter | silent! autocmd! Signature CursorHoldI
    augroup END
  ]]


  local installer = require("nvim-lsp-installer")

  for _, lang in pairs(M.servers) do
      local ok, server = installer.get_server(lang)
      if ok then
          if not server:is_installed() then
              print("Installing " .. lang)
              server:install()
          end
      end
  end

  -- Register a handler that will be called for all installed servers.
  installer.on_server_ready(function(server)
    local opts = {}

    if server.name == "sumneko_lua" then
      opts.settings = M.lua_setting
    end
    opts.capabilities = capabilities
    opts.on_attach = M.on_attach
    server:setup(opts)
  end)

end

return M
