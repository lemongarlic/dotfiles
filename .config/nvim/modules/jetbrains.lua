local module = {
  name = 'jetbrains',
  desc = 'Keybinds for JetBrains IDEs.',
  fn = function ()
    UseKeymap('open_idea', function ()
      local file_path = vim.fn.expand'%:p'
      local line = vim.fn.line'.'
      local col = vim.fn.col'.'
      local windows_path = vim.fn.system{ 'wslpath', '-w', file_path }:gsub('\n', '')
      local command = string.format(
        'silent! !powershell.exe idea --line %d --column %d "%s"',
        line,
        col,
        windows_path
      )
      vim.cmd(command)
    end)
    -- TODO: need a way to select the solution and possibly format the path
    -- UseKeymap('open_rider', function ()
    --   vim.cmd'rider64.exe --line <line_number> <path_to_solution.sln> <path_to_file.cs>'
    -- end)
  end,
}

return module

