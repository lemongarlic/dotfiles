local module = {
  name = 'neovide',
  desc = 'neovide-specific configuration',
  fn = function ()
    if vim.g.neovide then
      vim.o.guifont = "ComicCodeLigatures Nerd Font:h13:b"
      vim.o.linespace = -8
    end
  end,
}

return module

