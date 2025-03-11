local config = vim.fn.stdpath'config'

-- run module prerequisites
dofile(config .. '/api.lua')
dofile(config .. '/autocmds.lua')
dofile(config .. '/keymaps.lua')

-- register custom plugins
_G.CustomPlugins = {
  -- {
  --   dependencies = { 'nvim-telescope/telescope.nvim' },
  --   dir = '~/dev/notes-old',
  --   options = { debug = true },
  -- },
  {
    dependencies = { 'nvim-telescope/telescope.nvim' },
    dir = '~/dev/notes',
    options = { debug = true },
  },
}

-- load normal modules
Load(config .. '/modules')

-- load contextual modules
-- Load'~/.context/nvim'

-- initialize modules
Init()

