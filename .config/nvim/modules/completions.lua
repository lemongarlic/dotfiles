local module = {
  name = 'completions',
  desc = 'setup autocompletion suggestions',
  dependencies = { 'intellisense' },
  plugins = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
  },
  fn = function ()
    local cmp = require'cmp'

    -- setup nvim-cmp
    cmp.setup{
      snippet = {
        expand = function (args)
          -- vim.fn['vsnip#anonymous'](args.body)
          -- require('luasnip').lsp_expand(args.body)
          -- require('snippy').expand_snippet(args.body)
          -- vim.fn['UltiSnips#Anon'](args.body)
          vim.snippet.expand(args.body)
        end,
      },
      window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert{
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-space>'] = cmp.mapping.complete(),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<cr>'] = cmp.mapping.confirm{ select = true },
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' },
        -- { name = 'luasnip' },
        -- { name = 'ultisnips' },
        -- { name = 'snippy' },
      }, {
        { name = 'buffer' },
      })
    }
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      }
    })
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
        -- Fixes freezing when entering !
        { name = 'cmdline', keyword_pattern = [[\!\@<!\w*]] },
      }),
      matching = {
        disallow_symbol_nonprefix_matching = false,
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = false,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
      },
    })

    -- setup nvim-cmp capabilities
    local capabilities = require'cmp_nvim_lsp'.default_capabilities()
    require'lspconfig'['ts_ls'].setup{ capabilities = capabilities }
    require'lspconfig'['lua_ls'].setup{ capabilities = capabilities }
    require'lspconfig'['pyright'].setup{ capabilities = capabilities }
    require'lspconfig'['html'].setup{ capabilities = capabilities }

    -- disable autocompletions in ex mode
    local was_enabled = cmp.get_config().enabled
    vim.api.nvim_create_autocmd('CmdlineEnter', {
      callback = function ()
        if vim.fn.mode(1):sub(1, 2) == 'cv' then
          was_enabled = cmp.get_config().enabled
          cmp.setup{ enabled = false }
          cmp.close()
        end
      end,
    })
    vim.api.nvim_create_autocmd('CmdlineLeave', {
      callback = function () cmp.setup{ enabled = was_enabled } end,
    })

    -- keymaps
    UseKeymap('toggle_completions', function ()
      local is_enabled = cmp.get_config().enabled
      local is_cmd_mode = vim.fn.mode(1):sub(1, 1) == 'c'
      cmp.setup{ enabled = not is_enabled }
      if is_enabled then
        if not is_cmd_mode then
          print'completions OFF'
        end
        cmp.close()
      else
        if not is_cmd_mode then
          print'completions ON'
        end
      end
    end)
  end,
}

return module

