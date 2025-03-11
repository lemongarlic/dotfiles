local module = {
  name = 'search',
  desc = 'fuzzy finders',
  plugins = {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'natecraddock/telescope-zf-native.nvim'
      },
    },
    {
      'prochri/telescope-all-recent.nvim',
      dependencies = {
        'nvim-telescope/telescope.nvim',
        'kkharji/sqlite.lua',
        -- 'stevearc/dressing.nvim',
      },
      opts = {},
    }
  },
  fn = function ()
    require'telescope'.setup{
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
          height = 0.475,
          width = 9999,
          anchor = 'S',
          anchor_padding = 0,
          prompt_position = 'bottom',
          preview_width = 0.4,
          preview_cutoff = 60,
        },
      },
    }
    require'telescope'.load_extension'zf-native'
    require'telescope-all-recent'.setup{
      default = { sorting = 'frecency' },
      pickers = {
        pickers = { disable = true },
        builtin = { disable = true },
        planets = { disable = true },
      },
    }
    local telescope = require'telescope.builtin'
    UseKeymap('search_oldfiles', function () telescope.oldfiles() end)
    UseKeymap('search_files', function ()
      if vim.bo.buftype == 'terminal' then
        telescope.find_files{ cwd = vim.fn.getcwd() }
      else
        telescope.find_files()
      end
    end)
    UseKeymap('search_live_grep', function () telescope.live_grep() end)
    UseKeymap('search_help', function () telescope.help_tags() end)
    UseKeymap('search_man', function () telescope.man_pages() end)
    UseKeymap('search_buffers', function () telescope.buffers() end)
    UseKeymap('search_symbols', function () telescope.lsp_document_symbols() end)
    UseKeymap('search_references', function () telescope.lsp_references() end)
    UseKeymap('search_diagnostics', function () telescope.diagnostics() end)
    UseKeymap('search_command_history', function () telescope.command_history() end)
    UseKeymap('search_vim_grep', function () telescope.live_grep{ cwd = '~/.config/nvim' } end)
    UseKeymap('search_grep', function ()
      telescope.current_buffer_fuzzy_find()
    end)
    -- UseKeymap('search_workspace_diagnostics', function () fzf.diagnostics_workspace() end)
    -- UseKeymap('search_code_actions', function () fzf.lsp_code_actions() end)
    -- UseKeymap('search_given', function ()
    --   require'telescope.builtin'.find_files{ cwd = '~/notes' }
    -- end)
  end
}

return module

