local module = {
  name = 'folding',
  desc = 'Config related to code folds.',
  plugins = {},
  fn = function ()
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldlevelstart = 99
    vim.opt.foldlevel = 99
  end,
}

return module

