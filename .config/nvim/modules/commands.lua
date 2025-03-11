local module = {
  name = 'commands',
  desc = 'useful command line utilities',
  plugins = {},
  fn = function ()
    -- :Z
    vim.api.nvim_create_user_command('Z', function ()
      vim.cmd[[
      let topline = max([min([line('.') - winheight(0) / 2, line('$') - winheight(0) + 1]), 1])
      call winrestview({'topline': topline})
      ]]
    end, { range = true })

    -- :[range]V
    vim.api.nvim_create_user_command('V', function (opts)
      local start_line = opts.line1
      local end_line = opts.line2 or start_line
      vim.cmd('norm ' .. start_line .. 'G0V' .. end_line .. 'G$')
    end, { range = true })

    -- :Messages
    vim.api.nvim_create_user_command('Messages', function ()
      local buffer = vim.api.nvim_create_buf(false, true)
      vim.bo[buffer].filetype = 'text'
      local messages = vim.split(vim.fn.execute('messages', 'silent'), '\n')
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, messages)
      vim.api.nvim_set_current_buf(buffer)
      vim.cmd'silent! norm! G'
    end, { nargs = 0 })
    UseKeymap('vim_messages', function () vim.cmd'Messages' end)

    -- :KillAllBuffers
    vim.api.nvim_create_user_command('KillAllBuffers', function ()
      vim.cmd'bufdo! bwipeout!'
    end, { nargs = 0 })

    -- :WhereAmI
    vim.api.nvim_create_user_command('WhereAmI', function ()
      vim.cmd("echo expand('%:p')")
    end, { nargs = 0 })

    -- :Delete
    vim.api.nvim_create_user_command('Delete', function ()
      vim.cmd'exec "silent !rm %" | bdelete!'
    end, { nargs = 0 })
    UseKeymap('vim_delete_file', function () vim.cmd'Delete' end)

    -- :Rename
    local function autocomplete ()
      return { vim.fn.expand'%:t', vim.fn.expand'%:p' }
    end
    vim.api.nvim_create_user_command('Rename', function (args)
      local current_file = vim.fn.expand'%:p'
      local current_dir = vim.fn.fnamemodify(current_file, ':h')
      local new_name = args.args
      local new_path
      if vim.fn.isdirectory(new_name) == 1 or new_name:sub(1, 1) == '/' then
        new_path = new_name
      else
        new_path = current_dir .. '/' .. new_name
      end
      local escaped_new_path = vim.fn.fnameescape(new_path)
      vim.cmd('saveas ' .. escaped_new_path)
      vim.cmd('silent !rm ' .. vim.fn.fnameescape(current_file))
      vim.cmd('bdelete! ' .. vim.fn.bufnr(current_file))
      vim.cmd('edit ' .. escaped_new_path)
    end, {
      nargs = 1,
      complete = autocomplete,
    })
  end,
}

return module

