local module = {
  name = 'undo',
  desc = 'undo related config',
  plugins = {
    {
      'jiaoshijie/undotree',
      dependencies = 'nvim-lua/plenary.nvim',
    }
  },
  fn = function ()
    local undotree = require'undotree'
    undotree.setup()
    UseKeymap('undotree', function ()
      undotree.toggle()
    end)
  end
}

return module

