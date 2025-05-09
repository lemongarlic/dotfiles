local module = {
  name = 'terminal',
  desc = 'terminal-related commands',
  fn = function ()
    -- use esc to leave terminal
    vim.keymap.set('t', '<esc>', '<c-\\><c-n>G0')
    -- terminal system
    _G.__terminals__ = {}
    local term_list = {}
    local term_buf_ids = {}
    local last_term = ''
    local function autocomplete (_, cmd)
      local args = vim.split(cmd, ' ', { plain = true, trimempty = true })
      if #args == 1 then
        return vim.tbl_keys(_G.__terminals__)
      else
        return {}
      end
    end
    function _G.Tdelete (name)
      local job_id = _G.__terminals__[name]
      if job_id then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == 'terminal' and vim.b[buf].terminal_job_id == job_id then
            vim.api.nvim_buf_delete(buf, { force = true })
            vim.cmd'echo ""'
            return
          end
        end
      end
    end
    function _G.Tgo (name)
      local job_id = _G.__terminals__[name]
      if job_id then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == 'terminal' and vim.b[buf].terminal_job_id == job_id then
            vim.api.nvim_set_current_buf(buf)
            vim.cmd'echo ""'
            return
          end
        end
      end
      Tnew(name)
    end
    function _G.Tnew (name, cmd)
      if name and _G.__terminals__[name] then
        Tgo(name)
        return
      end
      if not name then
        name = vim.fn.printf('%08x', vim.fn.rand())
      end
      local index = 1
      while term_list[index] do
        index = index + 1
      end
      vim.cmd'terminal'
      term_list[index] = name
      Tname(name, true)
      Tsend(name, 'in ' .. name .. ' && exit')
      if not not cmd then
        Tsend(name, cmd)
        Tsend(name, 'clear')
      end
      vim.cmd'echo ""'
    end
    function _G.Tname (name, is_silent)
      if not name then
        print'Error: Usage is Tname term_name'
        return
      end
      if _G.__terminals__[name] then
        print('Error: A terminal named ' .. name .. ' already exists.')
        return
      end
      if vim.bo.buftype == 'terminal' then
        local job_id = vim.b.terminal_job_id
        local is_rename = false
        local index = -1
        if job_id then
          for stored_name, stored_job_id in pairs(_G.__terminals__) do
            if stored_job_id == job_id then
              for key, value in pairs(term_list) do
                if value == stored_name then
                  index = key
                  term_list[key] = name
                  vim.cmd('silent! !tmux rename-session -t ' .. stored_name .. ' ' .. name)
                end
              end
              _G.__terminals__[stored_name] = nil
              term_buf_ids[stored_name] = nil
              is_rename = true
              break
            end
          end
          _G.__terminals__[name] = job_id
          term_buf_ids[name] = vim.fn.bufnr()
          last_term = name
          local buf_id = vim.fn.bufnr'%'
          local augroup = 'term__' .. tostring(buf_id)
          vim.api.nvim_create_augroup(augroup, { clear = true })
          vim.api.nvim_create_autocmd('BufEnter', {
            group = augroup,
            buffer = buf_id,
            callback = function ()
              last_term = name
            end,
          })
          vim.api.nvim_create_autocmd('BufUnload', {
            group = augroup,
            buffer = buf_id,
            callback = function ()
              _G.__terminals__[name] = nil
              for key, value in pairs(term_list) do
                if value == name then
                  term_list[key] = nil
                end
              end
              if last_term == name then
                last_term = ''
              end
            end,
          })
          if not is_silent then
            if is_rename then
              print('Terminal ' .. index .. ' renamed to: ' .. name)
            else
              print('Terminal ' .. index .. ' name set to: ' .. name)
            end
          end
        else
          print'Error: Could not get terminal job ID.'
        end
      else
        print'Error: Not inside a terminal buffer.'
      end
    end
    function _G.Twhich ()
      if vim.bo.buftype ~= 'terminal' then
        print'Error: Current buffer is not a terminal.'
        return
      end
      local job_id = vim.b.terminal_job_id
      if not job_id then
        print'Error: Could not retrieve terminal job ID.'
        return
      end
      for name, stored_job_id in pairs(_G.__terminals__) do
        if stored_job_id == job_id then
          print(name)
          return
        end
      end
      print'Error: This terminal is not named.'
    end
    function _G.Tlist ()
      if vim.tbl_isempty(_G.__terminals__) then
        print'Error: No named terminals exist.'
        return
      end
      for index, name in pairs(term_list) do
        print(tostring(index) .. ': ' .. name)
      end
    end
    function _G.Tkill (name)
      local job_id = _G.__terminals__[name]
      if job_id then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == 'terminal' and vim.b[buf].terminal_job_id == job_id then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end
      vim.cmd('silent! !tk ' .. name)
      vim.cmd'echo ""'
    end
    function _G.Tsend (name, command)
      local job_id = _G.__terminals__[name]
      if job_id then
        vim.fn.chansend(job_id, command .. '\r')
      else
        Tnew(name)
        vim.defer_fn(function ()
          job_id = _G.__terminals__[name]
          if job_id then
            vim.fn.chansend(job_id, command .. '\r')
          end
        end, 500)
      end
      vim.cmd'echo ""'
    end
    function _G.Tcallback(name, command, expected, callback, timeout)
      timeout = timeout or 5
      local job_id = _G.__terminals__[name]
      local start_time = vim.loop.now()
      local function wait_for_output ()
        if not job_id then
          print('Error: Terminal ' .. name .. ' does not exist.')
          return
        end
        local bufnr = term_buf_ids[name]
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if line_count > 0 then
          local last_line = vim.api.nvim_buf_get_lines(bufnr, line_count - 1, line_count, false)[1]
          if last_line and string.find(last_line, expected, 1, true) then
            callback()
            return
          end
        end
        local elapsed_time = (vim.loop.now() - start_time) / 1000
        if elapsed_time >= timeout then
          vim.print('Error: Timeout waiting for expected output \'' .. expected .. '\'', vim.log.levels.WARN)
          return
        end
        vim.defer_fn(wait_for_output, 100)
      end
      if job_id then
        vim.defer_fn(wait_for_output, 500)
        vim.fn.chansend(job_id, command .. '\r')
      else
        Tnew(name)
        vim.defer_fn(function ()
          job_id = _G.__terminals__[name]
          if job_id then
            vim.defer_fn(wait_for_output, 500)
            vim.fn.chansend(job_id, command .. '\r')
          end
        end, 500)
      end
      vim.cmd 'echo ""'
    end
    function _G.Tnumber (index, opts)
      if not term_list[index] then
        print('Error: Terminal ' .. index .. ' does not exist.')
        return
      end
      local args = {}
      if opts and opts.args then
        args = vim.split(opts.args, ' ', { plain = true, trimempty = true })
      end
      if #args == 0 then
        _G.Tgo(term_list[index])
      else
        local command = table.concat(args, ' ')
        _G.Tsend(term_list[index], command)
      end
    end
    local last_non_terminal_buf = -1
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function ()
        vim.defer_fn(function ()
          local bufname = vim.api.nvim_buf_get_name(0)
          if vim.bo.buftype == 'terminal' then
            vim.cmd'norm G0'
          elseif vim.fn.filereadable(bufname) == 1 then
            last_non_terminal_buf = vim.api.nvim_get_current_buf()
          end
        end, 0)
      end,
    })
    function _G.Tswitch ()
      if vim.bo.buftype == 'terminal' then
        if last_non_terminal_buf ~= -1 and vim.api.nvim_buf_is_loaded(last_non_terminal_buf) then
          vim.api.nvim_set_current_buf(last_non_terminal_buf)
        end
      else
        if last_term and _G.__terminals__[last_term] then
          _G.Tgo(last_term)
        else
          print'Error: Previously opened terminal does not exist.'
        end
      end
    end
    vim.api.nvim_create_user_command('Tname', function (opts)
      _G.Tname(opts.args)
    end, { nargs = 1 })
    vim.api.nvim_create_user_command('Tkill', function (opts)
      _G.Tkill(opts.args)
    end, { nargs = 1, complete = autocomplete })
    vim.api.nvim_create_user_command('Twhich', function ()
      _G.Twhich()
    end, { nargs = 0 })
    vim.api.nvim_create_user_command('Tlist', function ()
      _G.Tlist()
    end, { nargs = 0 })
    vim.api.nvim_create_user_command('Tdelete', function (opts)
      _G.Tdelete(opts.args)
    end, { nargs = 1, complete = autocomplete })
    vim.api.nvim_create_user_command('T', function (opts)
      local args = vim.split(opts.args, ' ', { plain = true, trimempty = true })
      if #args < 1 then
        _G.Tnew()
        return
      end
      local name = args[1]
      if args[2] then
        local command = table.concat(vim.list_slice(args, 2), ' ')
        _G.Tsend(name, command)
      else
        if __terminals__[name] then
          _G.Tgo(name)
        else
          _G.Tnew(name)
        end
      end
    end, { nargs = '?', complete = autocomplete })
    vim.api.nvim_create_user_command('TT', function (opts)
      local args = {}
      if (opts) then
        args = vim.split(opts.args, ' ', { plain = true, trimempty = true })
      end
      if #args > 0 then
        if _G.__terminals__[last_term] then
          local command = table.concat(vim.list_slice(args, 1), ' ')
          _G.Tsend(last_term, command)
        else
          print'Error: Previously opened terminal does not exist.'
        end
      else
        _G.Tswitch()
      end
    end, { nargs = '?' })
    vim.api.nvim_create_user_command('TR', function (opts)
      local args = {}
      if (opts) then
        args = vim.split(opts.args, ' ', { plain = true, trimempty = true })
      end
      if #args > 0 then
        if _G.__terminals__[last_term] then
          local command = table.concat(vim.list_slice(args, 1), ' ')
          _G.Tsend(last_term, command)
          _G.Tgo(last_term)
        else
          print'Error: Previously opened terminal does not exist.'
        end
      else
        _G.Tswitch()
      end
    end, { nargs = '?' })
    for i = 1, 5 do
      vim.api.nvim_create_user_command('T' .. i, function (opts)
        _G.Tnumber(i, opts)
      end, { nargs = '?' })
    end
    local function terminal_execute (index)
      if not term_list[index] then
        print('Error: Terminal ' .. index .. ' does not exist.')
        return
      end
      vim.ui.input({ prompt = 'Run @ ' .. term_list[index] .. ': ', default = '', cancelreturn = nil }, function (cmd)
        if cmd and #cmd > 0 then
          _G.Tsend(term_list[index], cmd)
        end
      end)
    end
    local function terminal_execute_last ()
      if last_term and _G.__terminals__[last_term] then
        vim.ui.input({ prompt = 'Run @ ' .. last_term .. ': ', default = '', cancelreturn = nil }, function (cmd)
          if cmd and #cmd > 0 then
            _G.Tsend(last_term, cmd)
          end
        end)
      else
        print'Error: Previously opened terminal does not exist.'
      end
    end
    UseKeymap('terminal_add', function ()
      vim.ui.input({ prompt = 'Add terminal: ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          _G.Tnew(name)
        end
      end)
    end)
    UseKeymap('terminal_nu_add', function ()
      vim.ui.input({ prompt = 'Add nushell terminal: ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          _G.Tnew(name, 'nu')
        end
      end)
    end)
    UseKeymap('terminal_bash_add', function ()
      vim.ui.input({ prompt = 'Add bash terminal: ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          _G.Tnew(name, 'bash')
        end
      end)
    end)
    UseKeymap('terminal_rename', function ()
      if vim.bo.buftype ~= 'terminal' then
        print'Error: Not inside a terminal buffer.'
        return
      end
      vim.ui.input({ prompt = 'Rename terminal: ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          _G.Tname(name)
        end
      end)
    end)
    UseKeymap('terminal_quickadd', function () Tnew() end)
    UseKeymap('terminal_nu_quickadd', function () Tnew(nil, 'nu') end)
    UseKeymap('terminal_bash_quickadd', function () Tnew(nil, 'bash') end)
    UseKeymap('terminal_switch', function () Tswitch() end)
    -- UseKeymap('terminal_list', function () Tlist() end)
    UseKeymap('terminal_cancel', function ()
      if vim.bo.buftype ~= 'terminal' then
        print'Error: Not inside a terminal buffer.'
        return
      end
      vim.fn.chansend(vim.b.terminal_job_id, '\x03')
    end)
    UseKeymap('terminal_1', function () Tnumber(1) end)
    UseKeymap('terminal_2', function () Tnumber(2) end)
    UseKeymap('terminal_3', function () Tnumber(3) end)
    UseKeymap('terminal_4', function () Tnumber(4) end)
    UseKeymap('terminal_5', function () Tnumber(5) end)
    UseKeymap('terminal_execute_1', function () terminal_execute(1) end)
    UseKeymap('terminal_execute_2', function () terminal_execute(2) end)
    UseKeymap('terminal_execute_3', function () terminal_execute(3) end)
    UseKeymap('terminal_execute_4', function () terminal_execute(4) end)
    UseKeymap('terminal_execute_5', function () terminal_execute(5) end)
    UseKeymap('terminal_execute_last', function () terminal_execute_last() end)
    UseKeymap('terminal_kill', function ()
      vim.ui.input({ prompt = 'Kill terminal: ', default = '', cancelreturn = nil }, function (name)
        if name and #name > 0 then
          _G.Tkill(name)
        end
      end)
    end)
    vim.api.nvim_create_autocmd('TermOpen', {
      callback = function ()
        vim.api.nvim_buf_set_keymap(0, 'n', '<c-l>', 'i<c-l><c-\\><c-n>G0', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', '<m-d>', 'i<m-d><c-\\><c-n>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', '<m-u>', 'i<m-u><c-\\><c-n>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', '<c-r>', 'i<c-r>', { noremap = true, silent = true })
      end,
    })
  end,
}

return module

