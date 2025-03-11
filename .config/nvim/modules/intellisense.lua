local module = {
  name = 'intellisense',
  desc = 'configures LSPs and treesitter',
  dependencies = { 'commands' },
  plugins = {
    {
      'nvimtools/none-ls.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'wansmer/treesj',
        'stevearc/aerial.nvim',
      },
      build = ':TSUpdate',
      event = { 'BufReadPre', 'BufNewFile' },
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        { 'folke/lazydev.nvim', ft = 'lua' },
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',
        'ray-x/lsp_signature.nvim',
      },
    },
  },
  fn = function ()
    _G.__intellisense__ = {}
    vim.g.diagnostics_active = true
    local treesitter_configs = require'nvim-treesitter.configs'
    treesitter_configs.setup{
      modules = {},
      ignore_install = {},
      sync_install = true,
      auto_install = true,
      ensure_installed = {
        'bash',
        'css',
        'dockerfile',
        'fish',
        'gitignore',
        'go',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'org',
        'python',
        'query',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      highlight = { enable = true },
      indent = { enable = false },
      fold = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- ['<c-a>'] = { query = '@assignment.outer', desc = 'Select outer assignment' },
            -- ['<c-i>'] = { query = '@assignment.inner', desc = 'Select inner assignmment' },
            -- ['<c-h>'] = { query = '@assignment.lhs', desc = 'Select left assignment' },
            -- ['<c-l>'] = { query = '@assignment.rhs', desc = 'Select right assignment' },
            ['aa'] = { query = '@parameter.outer', desc = 'Select outer [a]rgument' },
            ['ia'] = { query = '@parameter.inner', desc = 'Select inner [a]rgument' },
            ['ai'] = { query = '@conditional.outer', desc = 'Select outer [i]f' },
            ['ii'] = { query = '@conditional.inner', desc = 'Select inner [i]f' },
            -- ['al'] = { query = '@loop.outer', desc = 'Select outer [l]oop' },
            -- ['il'] = { query = '@loop.inner', desc = 'Select inner [l]oop' },
            ['ac'] = { query = '@call.outer', desc = 'Select outer [c]all' },
            ['ic'] = { query = '@call.inner', desc = 'Select inner [c]all' },
            ['af'] = { query = '@function.outer', desc = 'Select outer [f]unction' },
            ['if'] = { query = '@function.inner', desc = 'Select inner [f]unction' },
            ['ad'] = { query = '@class.outer', desc = 'Select outer class [d]efinition' },
            ['id'] = { query = '@class.inner', desc = 'Select inner class [d]efinition' },
            ['ab'] = { query = '@block.outer', desc = 'Select outer [b]lock' },
            ['ib'] = { query = '@block.inner', desc = 'Select inner [b]lock' },
            ['ak'] = { query = '@comment.outer', desc = 'Select outer comment' },
            ['ik'] = { query = '@comment.inner', desc = 'Select inner comment' },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']a'] = { query = '@parameter.outer', desc = 'Next [a]rgument' },
            [']b'] = { query = '@block.outer', desc = 'Next [b]lock' },
            [']c'] = { query = '@call.outer', desc = 'Next [c]all' },
            [']f'] = { query = '@function.outer', desc = 'Next [f]unction' },
            [']d'] = { query = '@class.outer', desc = 'Next class [d]efinition' },
            [']i'] = { query = '@conditional.outer', desc = 'Next [i]f' },
            -- [']l'] = { query = '@loop.outer', desc = 'Next [l]oop' },
            [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next [s]cope' },
            [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
            [']k'] = { query = '@comment.outer', desc = 'Next comment' },
          },
          goto_next_end = {
            [']A'] = { query = '@parameter.outer', desc = 'Next argument end' },
            [']B'] = { query = '@block.outer', desc = 'Next block end' },
            [']C'] = { query = '@call.outer', desc = 'Next call end' },
            [']F'] = { query = '@function.outer', desc = 'Next function end' },
            [']D'] = { query = '@class.outer', desc = 'Next class definition end' },
            [']I'] = { query = '@conditional.outer', desc = 'Next if end' },
            -- [']L'] = { query = '@loop.outer', desc = 'Next loop end' },
            [']K'] = { query = '@comment.outer', desc = 'Next comment' },
          },
          goto_previous_start = {
            ['[a'] = { query = '@parameter.outer', desc = 'Prev argument start' },
            ['[b'] = { query = '@block.outer', desc = 'Prev [b]lock start' },
            ['[c'] = { query = '@call.outer', desc = 'Prev [c]all' },
            ['[f'] = { query = '@function.outer', desc = 'Prev [f]unction start' },
            ['[d'] = { query = '@class.outer', desc = 'Prev class [d]efinition start' },
            ['[i'] = { query = '@conditional.outer', desc = 'Prev [i]f start' },
            -- ['[l'] = { query = '@loop.outer', desc = 'Prev [l]oop start' },
            ['[k'] = { query = '@comment.outer', desc = 'Prev comment' },
          },
          goto_previous_end = {
            ['[A'] = { query = '@parameter.outer', desc = 'Prev argument end' },
            ['[B'] = { query = '@block.outer', desc = 'Prev block end' },
            ['[C'] = { query = '@call.outer', desc = 'Prev function call end' },
            ['[F'] = { query = '@function.outer', desc = 'Prev method end' },
            ['[D'] = { query = '@class.outer', desc = 'Prev class end' },
            ['[I'] = { query = '@conditional.outer', desc = 'Prev conditional end' },
            -- ['[L'] = { query = '@loop.outer', desc = 'Prev loop end' },
            ['[K'] = { query = '@comment.outer', desc = 'Prev comment end' },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<m-n>'] = '@function.inner',
            ['<c-n>'] = '@parameter.inner',
          },
          swap_previous = {
            ['<m-p>'] = '@function.inner',
            ['<c-p>'] = '@parameter.inner',
          },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            -- FIXME: implement
            -- init_selection = '<c-space>',
            -- node_incremental = '<c-space>',
            -- scope_incremental = false,
            -- node_decremental = '<bs>',
          },
        },
        lsp_interop = {
          enable = true,
          border = 'rounded',
          floating_preview_opts = {},
          peek_definition_code = {
            ['<leader>df'] = { query = '@function.outer', desc = 'Preview outer [f]unction' },
            ['<leader>dk'] = { query = '@class.outer', desc = 'Preview outer [c]lass' },
          },
        },
      },
    }
    local ts_repeat_move = require'nvim-treesitter.textobjects.repeatable_move'
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)
    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ 'x', 'n', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
    local gs = require'gitsigns'
    local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
    vim.keymap.set({ 'n', 'x', 'o' }, ']h', next_hunk_repeat)
    vim.keymap.set({ 'n', 'x', 'o' }, '[h', prev_hunk_repeat)
    require'aerial'.setup{
      post_jump_cmd = 'norm! zt',
      manage_folds = false,
      link_folds_to_tree = false,
      link_tree_to_folds = false,
      float = {
        border = 'rounded',
        relative = 'editor',
        override = function (config)
          config.title = 'Symbols'
          local width = vim.o.columns
          local height = vim.o.lines
          if width < 75 then
            config.width = math.floor(width * 0.9)
            config.height = math.floor((height - 3) * 0.9)
          else
            config.width = math.min(50, math.ceil(width * 0.8))
            config.height = math.min(15, math.ceil(height * 0.8))
          end
          config.row = math.floor(((vim.o.lines - config.height) / 2) - 1)
          config.col = math.floor((vim.o.columns - config.width) / 2)
          return config
        end,
      },
    }
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function ()
        vim.defer_fn(function ()
          if vim.bo.filetype == 'aerial' then
            vim.cmd'Z'
          end
        end, 1)
      end
    })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'aerial',
      callback = function (event)
        vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', ':bd!<cr>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd!<cr>', { noremap = true, silent = true })
        vim.keymap.set('n', '<cr>', function ()
          if vim.v.count == 0 then
            vim.cmd('AerialGo ' .. vim.api.nvim_win_get_cursor(0)[1])
          else
            vim.cmd('AerialGo ' .. vim.v.count)
          end
        end, { buffer = event.buf, noremap = false, silent = true })
      end,
    })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'aerial-nav',
      callback = function ()
        vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', ':bd!<cr>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd!<cr>', { noremap = true, silent = true })
      end,
    })
    UseKeymap('toggle_outline', function () vim.cmd'AerialToggle float' end)

    -- lsp
    require'mason'.setup()
    require'mason-lspconfig'.setup()
    require'lazydev'.setup()
    local servers = {
      lua_ls = {},
      html = {
        filetypes = {
          'html',
          'twig',
          'hbs',
        },
      },
      ts_ls = {},
      pyright = {},
      cssls = {},
      gopls = {},
      -- clangd = {},
    }
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require'cmp_nvim_lsp'.default_capabilities(capabilities)
    local mason_lspconfig = require'mason-lspconfig'
    mason_lspconfig.setup{ ensure_installed = vim.tbl_keys(servers) }
    local function on_attach (_, bufnr)
      if vim.b[bufnr].diagnostics_disabled or vim.g.diagnostics_disabled then
        vim.diagnostic.disable(bufnr)
      end
    end
    mason_lspconfig.setup_handlers{
      function (server_name)
        require'lspconfig'[server_name].setup{
          capabilities = capabilities,
          on_attach = on_attach,
          settings = servers[server_name],
          filetypes = (servers[server_name] or {}).filetypes,
        }
      end,
    }
    require'lspconfig'.ts_ls.setup{}
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
    vim.diagnostic.config{
      float = { border = 'rounded' },
    }
    require'lsp_signature'.setup()
    vim.keymap.set(
      { 'i' },
      '<c-e>',
      function () require'lsp_signature'.toggle_float_win() end,
      { silent = true, noremap = true }
    )
    -- local null = require'null-ls'
    -- null.setup{
    --   sources = {
    --     null.builtins.formatting.stylua,
    --     null.builtins.diagnostics.eslint,
    --     null.builtins.completion.spell,
    --   },
    -- }
    UseKeymap('show_diagnostics', function () vim.diagnostic.open_float() end)
    UseKeymap('goto_definition', function () vim.lsp.buf.definition() end)
    UseKeymap('goto_type_definition', function () vim.lsp.buf.type_definition() end)
    UseKeymap('goto_implementation', function () vim.lsp.buf.implementation() end)
    UseKeymap('toggle_diagnostics', function () ToggleDiagnostics(true) end)
    UseKeymap('toggle_lsp', function () ToggleLSP() end)
    UseKeymap('rename', function ()
      local current_name = vim.fn.expand'<cword>'
      vim.ui.input({ prompt = 'Rename ' .. current_name .. ': ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          vim.lsp.buf.rename(name)
          vim.cmd'echo ""'
        end
      end)
    end)
  end,
}

function _G.ToggleLSP ()
  local clients = vim.lsp.get_active_clients() or {}
  if vim.tbl_isempty(clients) then
    vim.cmd'LspStart'
    print'lsp ON'
  else
    vim.cmd'LspStop'
    print'lsp OFF'
  end
end

function _G.ToggleDiagnostics (is_global)
  local vars, bufnr, cmd
  if is_global then
    vars = vim.g
    bufnr = nil
  else
    vars = vim.b
    bufnr = 0
  end
  vars.diagnostics_disabled = not vars.diagnostics_disabled
  if vars.diagnostics_disabled then
    cmd = 'disable'
    print'diagnostics OFF'
  else
    cmd = 'enable'
    print'diagnostics ON'
  end
  vim.schedule(function () vim.diagnostic[cmd](bufnr) end)
end

return module

