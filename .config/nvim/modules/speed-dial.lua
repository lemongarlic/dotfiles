local module = {
  name = 'speed-dial',
  desc = 'quick lists',
  dependencies = { 'files' },
  plugins = {
    {
      'theprimeagen/harpoon',
      branch = 'harpoon2',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
  },
}

module.fn = function ()
  local harpoon = require'harpoon'
  harpoon:setup()
  UseKeymap('speed_dial_add', function () harpoon:list():add() end)
  UseKeymap('speed_dial_select', function () harpoon.ui:toggle_quick_menu(harpoon:list()) end)
  UseKeymap('speed_dial_1', function () harpoon:list():select(1) end)
  UseKeymap('speed_dial_2', function () harpoon:list():select(2) end)
  UseKeymap('speed_dial_3', function () harpoon:list():select(3) end)
  UseKeymap('speed_dial_4', function () harpoon:list():select(4) end)
  UseKeymap('speed_dial_5', function () harpoon:list():select(5) end)
  UseKeymap('speed_dial_prev', function () harpoon:list():prev() end)
  UseKeymap('speed_dial_next', function () harpoon:list():next() end)
  UseKeymap('speed_dial_clear', function () harpoon:list():clear() end)
end

return module

