-- Setup nvim-cmp.
local cmp = require('cmp')

vim.g.vsnip_snippet_dir = "~/.dotfiles/vim/vsnip"

local comfirm = function(fallback)
  if cmp.visible() then
    if vim.fn['UltiSnips#CanExpandSnippet']() == 1 and cmp.get_selected_entry() == cmp.core.view:get_first_entry() then
      vim.fn['UltiSnips#ExpandSnippet']()
    else
      local entry = cmp.get_selected_entry()
      local label = entry.completion_item.label
      local indent_change_items = {
        'endif', 'end', 'else', 'elif', 'elseif .. then', 'elseif', 'else .. then~',
        'endfor', 'endfunction', 'endwhile', 'endtry', 'except', 'catch'
      }
      if table.find(indent_change_items, label) then
        cmp.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert})
        local indent = vim.fn.indent('.')
        local cmd = [[
        function! CmpLineFormat(timer) abort
          let c = getpos(".")
          let indent_num = indent('.')
          norm ==
          if indent('.') != indent_num
            call cursor(c[1], c[2] - 2)
          else
            call cursor(c[1], c[2])
          endif
        endfunction
        call timer_start(0, 'CmpLineFormat')
        ]]
        cmd = cmd:format(indent, label)
        vim.cmd(cmd)
      else
        cmp.confirm({ select = true })
      end
    end
  elseif vim.fn['UltiSnips#CanExpandSnippet']() == 1 then
    vim.fn['UltiSnips#ExpandSnippet']()
  else
    fallback()
  end
end

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  -- experimental = {
  --   native_menu = true,
  --   -- ghost_text = true
  -- },
  mapping = {
    ['<c-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<c-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<c-n>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ['<up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ['<c-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<c-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<cr>'] = cmp.mapping(comfirm, { "i", "s" }),
    ["<tab>"] = cmp.mapping(comfirm, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = 'ultisnips' }, -- For ultisnips users.
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })

local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

cmp.setup {
  formatting = {
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      -- Source
      vim_item.menu = ({
        buffer = "[B]",
        nvim_lsp = "[L]",
        ultisnips = "[U]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return vim_item
    end
  },
}

vim.cmd[[
" gray
highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
" blue
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
" light blue
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
" pink
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
" front
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4

" Jump forward or backward
imap <expr> <c-k> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<c-k>'
smap <expr> <c-k> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<c-k>'
imap <expr> <c-j>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<c-j>'
smap <expr> <c-j>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<c-j>'
" imap <c-p> <cmd>lua vim.lsp.buf.signature_help()<CR>
]]
