local module = {
  name = 'tabs',
  desc = 'Functionality related to vim tabs.',
  fn = function ()
    -- Tab names
    local tab_manager = {
      tab_name_map = {},
      name_tab_map = {},
    }

    local function update_tab_mappings ()
      local tabs = vim.api.nvim_list_tabpages()
      local new_tab_name_map = {}
      local new_name_tab_map = {}
      for _, tab in ipairs(tabs) do
        local name = tab_manager.tab_name_map[tab] or ''
        if name and #name > 0 then
          new_tab_name_map[tab] = name
          new_name_tab_map[name] = tab
        end
      end
      tab_manager.tab_name_map = new_tab_name_map
      tab_manager.name_tab_map = new_name_tab_map
    end

    function tab_manager.assign_name (tab_handle, name)
      local old_name = tab_manager.tab_name_map[tab_handle]
      if old_name then
        tab_manager.name_tab_map[old_name] = nil
      end
      tab_manager.tab_name_map[tab_handle] = name
      tab_manager.name_tab_map[name] = tab_handle
      vim.cmd'redrawtabline'
    end

    function tab_manager.get_tab_by_name (name)
      return tab_manager.name_tab_map[name]
    end

    function tab_manager.get_name_by_tab (tab_handle)
      return tab_manager.tab_name_map[tab_handle]
    end

    vim.api.nvim_create_user_command('TabName', function (opts)
      tab_manager.assign_name(vim.api.nvim_get_current_tabpage(), opts.args)
    end, { nargs = 1 })

    vim.api.nvim_create_autocmd({ 'TabNew', 'TabClosed', 'WinEnter' }, {
      callback = function () vim.schedule(update_tab_mappings) end,
    })

    update_tab_mappings()

    -- Tab line
    vim.o.tabline = '%!v:lua.TabLine()'
    function TabLine ()
      local s = ''
      for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if i == vim.fn.tabpagenr() then
          s = s .. '%#TabLineSel#'
        else
          s = s .. '%#TabLine#'
        end
        s = s .. ' ' .. i
        local name = tab_manager.tab_name_map[tab]
        if name and #name > 0 then
          s = s .. ':' .. name .. ' '
        else
          s = s .. ' '
        end
      end
      s = s .. '%#TabLineFill#'
      return s
    end

    -- Keymaps
    UseKeymap('vim_tab_quickadd', function () vim.cmd'tabnew' end)
    UseKeymap('vim_tab_add', function ()
      vim.ui.input({ prompt = 'Add tab: ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          vim.cmd'tabnew'
          tab_manager.assign_name(vim.api.nvim_get_current_tabpage(), name)
        else
          print'Error: No tab name given'
        end
      end)
    end)
    UseKeymap('vim_tab_close', function () vim.cmd'tabclose' end)
    UseKeymap('vim_tab_only', function () vim.cmd'tabonly' end)
    UseKeymap('vim_tab_move_left', function () vim.cmd'tabm -1' end)
    UseKeymap('vim_tab_move_right', function () vim.cmd'tabm +1' end)
    UseKeymap('vim_tab_move_first', function () vim.cmd'tabm 0' end)
    UseKeymap('vim_tab_move_last', function () vim.cmd'tabm $' end)
    UseKeymap('vim_tab_name', function ()
      local page = vim.api.nvim_get_current_tabpage()
      local existing = tab_manager.tab_name_map[page]
      local prompt = 'Name tab: '
      if existing then
        prompt = 'Rename tab: '
      end
      vim.ui.input({ prompt = prompt, default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          tab_manager.assign_name(page, name)
        else
          print'Error: No tab name given'
        end
      end)
    end)
  end
}

return module


