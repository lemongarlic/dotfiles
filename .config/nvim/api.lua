_G.__registry__ = {}
_G.__modules__ = {}
_G.__prefixes__ = {}
_G.__keymaps__ = {}
_G.__autocmds__ = {}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazy_path = vim.fn.stdpath'data' .. '/lazy/lazy.nvim'
local fns = {}

_G.Load = function (path)
  path = vim.fn.expand(path)
  local scan = vim.loop.fs_scandir(path)
  if not scan then
    return
  end
  while true do
    local file = vim.loop.fs_scandir_next(scan)
    if not file then break end
    if file:match'%.lua$' then
      local full_file_path = path .. '/' .. file
      local chunk = loadfile(full_file_path)
      if chunk then
        local result = chunk()
        if result and not result.desc then
          print('Module at ' .. full_file_path .. ' is missing a description and was not loaded.')
          return
        end
        if result and result.name then
          _G.__registry__[result.name] = result
          table.insert(_G.__modules__, result)
        else
          print('Module at ' .. full_file_path .. ' is missing a name and was not loaded.')
        end
      else
        print('Failed to load ', full_file_path)
      end
    end
  end
end

_G.Init = function ()
  local loaded = {}
  for _, module in ipairs(_G.__modules__) do
    local module_name = module.name
    if not loaded[module_name] then
      local stack = { module_name }
      while #stack > 0 do
        local current = stack[#stack]
        local current_module = _G.__registry__[current]
        if not current_module then
          print('Module ' .. current .. ' not found!')
          table.remove(stack)
        else
          local all_dependencies_loaded = true
          if current_module.dependencies then
            for _, dependency in ipairs(current_module.dependencies) do
              if not loaded[dependency] then
                all_dependencies_loaded = false
                table.insert(stack, dependency)
              end
            end
          end
          if all_dependencies_loaded then
            if current_module.fn then
              table.insert(fns, current_module.fn)
            end
            if current_module.plugins then
              for _, plugin in ipairs(current_module.plugins) do
                table.insert(_G.CustomPlugins, plugin)
              end
            end
            loaded[current] = true
            table.remove(stack)
          end
        end
      end
    end
  end
  if not vim.loop.fs_stat(lazy_path) then
    vim.fn.system{
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable',
      lazy_path,
    }
  end
  vim.opt.rtp:prepend(lazy_path)
  if not _G.__load_plugins_once__ then
    require'lazy'.setup(_G.CustomPlugins)
  end
  _G.__load_plugins_once__ = true
  for _, fn in ipairs(fns) do
    fn()
  end
end

_G.DefPrefix = function (prefixes)
  for name, definition in pairs(prefixes) do
    if not definition[1] or not definition.desc then
      error('Missing required prefix options for ' .. name)
    end
    _G.__prefixes__[name] = definition
  end
end

_G.UseKeymap = function (name, fn, buffer)
  local map_info = __keymaps__[name]
  if not map_info then
    error('No keymap found for name: ' .. name)
    return
  end
  for _, mode in ipairs(map_info.mode) do
    vim.keymap.set(mode, map_info[1], fn, { desc = map_info.desc, silent = true, noremap = true, buffer = buffer or nil })
  end
end

_G.DefKeymap = function (keymaps)
  for name, definition in pairs(keymaps) do
    local keys = definition[1]
    local mode = definition.mode
    local desc = definition.desc
    local prefix = definition.prefix
    if prefix then
      local prefix_def = _G.__prefixes__[prefix]
      if not prefix_def then
        error('No prefix found for ' .. prefix)
      end
      keys = prefix_def[1] .. keys
    end
    _G.__keymaps__[name] = {
      [1] = keys,
      mode = mode,
      desc = desc,
    }
  end
end

_G.DefAutocmd = function (name_or_table, opts)
    if type(name_or_table) == 'table' then
      for name, definition in pairs(name_or_table) do
        if not definition.event or not definition.desc then
          error('Missing required autocmd options for ' .. name)
        end
        __autocmds__[name] = definition
      end
    else
      if not opts or not opts.event or not opts.desc then
        error('Missing required autocmd options for ' .. name_or_table)
      end
      __autocmds__[name_or_table] = opts
    end
end

_G.UseAutocmd = function (name, fn)
    local autocmd_info = _G.__autocmds__[name]
    if not autocmd_info then
      error('No autocmd found for name ' .. name)
      return
    end
    local events = autocmd_info.event
    if type(events) == 'string' then
      events = { events }
    end
    for _, event in ipairs(events) do
      vim.api.nvim_create_autocmd(event, {
        pattern = autocmd_info.pattern,
        callback = fn,
        desc = autocmd_info.desc,
      })
    end
end

