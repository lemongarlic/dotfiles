local module = {
  name = 'files',
  desc = 'file browsing',
  dependencies = { 'search' },
  plugins = {
    { 'echasnovski/mini.files', version = false },
  },
  fn = function ()
    local files = require'mini.files'
    files.setup{
      content = { prefix = function () end },
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 60,
      },
      options = {
        use_as_default_explorer = false,
      },
    }
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'minifiles',
      callback = function (event)
        local opts = { buffer = event.buf, noremap = true, silent = true }
        vim.keymap.set('n', '<esc>', function () files.close() end, opts)
        vim.keymap.set('n', '<cr>', function ()
          local count = vim.v.count
          if count == 0 then
            files.go_in()
          else
            local max_line = vim.api.nvim_buf_line_count(0)
            local line = math.min(count, max_line)
            vim.api.nvim_win_set_cursor(0, { line, 0 })
            files.go_in()
          end
          files.close()
        end, { buffer = event.buf, noremap = true, silent = true })
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesWindowUpdate',
      callback = function ()
        vim.wo.number = true
      end,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
      pattern = '*',
      callback = function ()
        if vim.bo.filetype == 'minifiles' then
          vim.wo.number = false
        end
      end,
    })
    local function create_temp_file (extension, filetype)
      local timestamp = os.date'%Y%m%d-%H%M%S'
      local filepath = string.format('/tmp/%s.%s', timestamp, extension)
      vim.cmd('e ' .. filepath)
      vim.bo.filetype = filetype
    end
    UseKeymap('empty_file', function () create_temp_file('txt', 'text') end)
    UseKeymap('empty_json_file', function () create_temp_file('json', 'json') end)
    UseKeymap('empty_lua_file', function () create_temp_file('lua', 'lua') end)
    UseKeymap('empty_vim_file', function () create_temp_file('vim', 'vim') end)
    UseKeymap('empty_ts_file', function () create_temp_file('ts', 'typescript') end)
    UseKeymap('empty_tsx_file', function () create_temp_file('tsx', 'typescriptreact') end)
    UseKeymap('empty_python_file', function () create_temp_file('py', 'python') end)
    UseKeymap('empty_go_file', function () create_temp_file('go', 'go') end)
    UseKeymap('empty_fish_file', function () create_temp_file('fish', 'fish') end)
    UseKeymap('empty_nushell_file', function () create_temp_file('nu', 'nu') end)
    UseKeymap('empty_markdown_file', function () create_temp_file('md', 'markdown') end)
    UseKeymap('empty_sh_file', function ()
      create_temp_file('sh', 'sh')
      vim.api.nvim_feedkeys('i#!/bin/sh\n\n', 'n', false)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
    end)
    UseKeymap('empty_bash_file', function ()
      create_temp_file('sh', 'bash')
      vim.api.nvim_feedkeys('i#!/bin/bash\n\n', 'n', false)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
    end)
    UseKeymap('empty_sql_file', function () create_temp_file('sql', 'sql') end)
    UseKeymap('empty_graphql_file', function () create_temp_file('graphql', 'graphql') end)
    UseKeymap('search_config', function () require'telescope.builtin'.find_files{ cwd = '~/.config' } end)
    UseKeymap('search_vim_modules', function () require'telescope.builtin'.find_files{ cwd = '~/.config/nvim/modules' } end)
    UseKeymap('open_config_browser', function () files.open('~/.config', false) end)
    UseKeymap('open_config_vim_api', function () vim.cmd'e ~/.config/nvim/api.lua' end)
    UseKeymap('open_config_vim_autocmds', function () vim.cmd'e ~/.config/nvim/autocmds.lua' end)
    UseKeymap('open_config_vim_init', function () vim.cmd'e ~/.config/nvim/init.lua' end)
    UseKeymap('open_config_vim_keymaps', function () vim.cmd'e ~/.config/nvim/keymaps.lua' end)
    UseKeymap('open_config_vim_modules', function () files.open('~/.config/nvim/modules', false) end)
    UseKeymap('open_dev_browser', function () files.open('~/dev', false) end)
    UseKeymap('open_file_browser', function ()
      if vim.bo.buftype == 'terminal' then
        files.open(vim.fn.getcwd(), false)
      else
        files.open(vim.api.nvim_buf_get_name(0), false)
      end
    end)
    UseKeymap('open_home_browser', function () files.open('~', false) end)
    UseKeymap('open_persistent_file_browser', function () files.open(vim.fn.getcwd()) end)
    UseKeymap('open_project_browser', function () files.open(vim.fn.getcwd(), false) end)
    UseKeymap('open_root_browser', function () files.open('/', false) end)
    UseKeymap('open_temp_browser', function () files.open('/tmp', false) end)
    UseKeymap('reload_file', function ()
      local winview = vim.fn.winsaveview()
      vim.cmd'e'
      vim.fn.winrestview(winview)
    end)
  end
}

return module

