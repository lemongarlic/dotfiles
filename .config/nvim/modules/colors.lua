local module = {
  name = 'colors',
  desc = 'defines colorscheme and highlighting',
  dependencies = { 'search' },
  plugins = {
    'brenoprata10/nvim-highlight-colors',

    -- themes
    'pbrisbin/vim-colors-off',
    'rose-pine/neovim',
    'slugbyte/lackluster.nvim',
    'rebelot/kanagawa.nvim',
    'shaunsingh/nord.nvim',
    'mofiqul/vscode.nvim',
    'killitar/obscure.nvim',
    'catppuccin/nvim',
    'sainnhe/everforest',
    'marko-cerovac/material.nvim',
    'olimorris/onedarkpro.nvim',
    'ellisonleao/gruvbox.nvim',
    'sainnhe/gruvbox-material',
    'craftzdog/solarized-osaka.nvim',
    'tiagovla/tokyodark.nvim',
    'loctvl842/monokai-pro.nvim',
    'maxmx03/solarized.nvim',
    'mofiqul/dracula.nvim',
    'lettertwo/laserwave.nvim',
    'ntbbloodbath/doom-one.nvim',
    'projekt0n/github-nvim-theme',
    'ribru17/bamboo.nvim',
    'olivercederborg/poimandres.nvim',
    'scottmckendry/cyberdream.nvim',
    'alexvzyl/nordic.nvim',
    'bluz71/vim-nightfly-colors',
    'maxmx03/fluoromachine.nvim',
    'dgox16/oldworld.nvim',
    'edeneast/nightfox.nvim',
    'honamduong/hybrid.nvim',
    'sainnhe/sonokai',
    'sainnhe/edge',
    'shatur/neovim-ayu',
    'cpwrs/americano.nvim',
    'dgox16/oldworld.nvim',
  },
  fn = function ()
    -- Fix colors
    vim.cmd'set termguicolors'

    -- Enable color code highlighting
    require'nvim-highlight-colors'.setup{}

    -- Minimum LineNr brightness
    local function hex_to_rgb (hex)
      local r = tonumber(hex:sub(2, 3), 16)
      local g = tonumber(hex:sub(4, 5), 16)
      local b = tonumber(hex:sub(6, 7), 16)
      return r, g, b
    end
    local function rgb_to_brightness (r, g, b)
      return 0.299 * r + 0.587 * g + 0.114 * b
    end
    local function ensure_min_brightness (group, min_brightness)
      local color = vim.api.nvim_get_hl(0, { name = group }).fg
      if color then
        local hex_color = string.format('#%06x', color)
        local r, g, b = hex_to_rgb(hex_color)
        local brightness = rgb_to_brightness(r, g, b)
        if brightness < min_brightness then
          local scale = min_brightness / brightness
          r = math.min(255, math.floor(r * scale))
          g = math.min(255, math.floor(g * scale))
          b = math.min(255, math.floor(b * scale))
          vim.api.nvim_set_hl(0, group, { fg = string.format('#%02x%02x%02x', r, g, b) })
        end
      end
    end

    -- My override colors
    local function override_colors ()
      vim.cmd'hi FlashCurrent    guibg=#ff69b4 guifg=#000000'
      vim.cmd'hi FlashLabel      guibg=#cccccc guifg=#000000'
      vim.cmd'hi IncSearch       guibg=#ff69b4 guifg=#000000'
      vim.cmd'hi Search          guibg=#aabbff guifg=#000000'
      vim.cmd'hi FlashMatch      guibg=#aabbff guifg=#000000'
      vim.cmd'set cursorline'
      vim.cmd'highlight clear CursorLine'
      ensure_min_brightness('LineNr', 100)
    end

    -- My color scheme
    local function colors ()
      vim.cmd'hi clear'
      if vim.fn.exists'syntax_on' then
        vim.cmd'syntax reset'
      end
      vim.cmd'color off'
      -- vim.cmd'hi StatusLine      guibg=#1b1d1e'
      vim.cmd'hi StatusLine      guibg=#ffffff guifg=#000000'
      vim.cmd'hi Normal          guibg=NONE    guifg=#cccccc'
      vim.cmd'hi String                        guifg=#b7bdf8'
      vim.cmd'hi Comment                       guifg=#828a9a'
      vim.cmd'hi Boolean                       guifg=#c6a0f6'
      vim.cmd'hi Number                        guifg=#8aadf4'
      vim.cmd'hi @lsp.type.enum                guifg=#ffffff'
      vim.cmd'hi @lsp.type.variable            guifg=#ffffff'
      vim.cmd'hi @lsp.type.class               guifg=#ffffff'
      vim.cmd'hi @lsp.type.function            guifg=#ffffff'
      vim.cmd'hi @lsp.type.parameter           guifg=#f5a97f'
      vim.cmd'hi @lsp.type.type                guifg=#7dc4e4'
      vim.cmd'hi @lsp.type.typeParameter       guifg=#a6da95'
      vim.cmd'hi Keyword                       guifg=#ed8796'
      vim.cmd'hi GitSignsAdd                   guifg=#a6da95'
      vim.cmd'hi GitSignsChange                guifg=#7dc4e4'
      vim.cmd'hi GitSignsDelete                guifg=#ed8796'
      vim.cmd'hi DiagnosticError               guifg=#ed8796'
      vim.cmd'hi DiagnosticWarn                guifg=#f5a97f'
      vim.cmd'hi DiagnosticInfo                guifg=#7dc4e4'
      vim.cmd'hi DiagnosticHint                guifg=#b7bdf8'
      vim.cmd'hi CursorLineNr                  guifg=#ffffff'
      vim.cmd'hi clear CursorLine'
      vim.fn.delete(vim.fn.stdpath'data' .. '/colorscheme.lua')
      override_colors()
    end
    vim.api.nvim_create_user_command('Colors', colors, {})

    -- Load persisted theme
    local persisted_scheme = vim.fn.stdpath'data' .. '/colorscheme.lua'
    if vim.fn.filereadable(persisted_scheme) == 1 then
      dofile(persisted_scheme)
    else
      colors()
    end
    override_colors()

    -- Persist theme function
    local function persist_colorscheme(scheme)
      local config_file = vim.fn.stdpath'data' .. '/colorscheme.lua'
      local file = io.open(config_file, 'w')
      if file then
        file:write('vim.cmd\'color ' .. scheme .. '\'')
        file:close()
      end
      override_colors()
    end

    -- Keymaps
    local telescope = require'telescope.builtin'
    local actions = require'telescope.actions'
    local action_state = require'telescope.actions.state'
    UseKeymap(
      'search_color_schemes',
      function ()
        telescope.colorscheme{
          attach_mappings = function ()
            actions.select_default:replace(function (prompt_bufnr)
              local selection = action_state.get_selected_entry().value
              vim.cmd('color ' .. selection)
              persist_colorscheme(selection)
              actions.close(prompt_bufnr)
            end)
            return true
          end,
        }
      end
    )
  end,
}

return module

