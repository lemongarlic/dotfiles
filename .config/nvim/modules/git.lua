local module = {
  name = 'git',
  desc = 'git operations and decorations',
  plugins = {
    'tpope/vim-fugitive',
    'lewis6991/gitsigns.nvim',
  },
  fn = function ()
    require'gitsigns'.setup()
  end,
}

return module

