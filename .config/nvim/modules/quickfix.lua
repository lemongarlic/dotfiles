local module = {
  name = 'quickfix',
  desc = 'quickfix list improvement',
  dependencies = { 'intellisense' },
  plugins = {
    'kevinhwang91/nvim-bqf',
    'stevearc/quicker.nvim',
    'romainl/vim-qf',
  },
  fn = function ()
    require'quicker'.setup()
    require'bqf'.setup{
      func_map = {
        split = '_',
        vsplit = '|',
        pscrollup = '',
        pscrolldown = '',
        prevfile = '<c-p>',
        nextfile = '<c-n>',
        prevhist = '<',
        nexthist = '>',
      },
    }
    vim.cmd[[com! QFReverse call setqflist(reverse(getqflist()))]]
    UseKeymap('qf_reverse', function () vim.cmd'QFReverse' end)
    UseKeymap('qf_toggle', function ()
        for _, win in ipairs(vim.fn.getwininfo()) do
          if win.quickfix == 1 then
            vim.cmd'cclose'
            return
          end
        end
        vim.cmd'copen'
        vim.cmd'wincmd J'
        vim.cmd'wincmd p'
    end)
    UseKeymap('qf_open', function ()
      local qf_open = false
      for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
          qf_open = true
          vim.api.nvim_set_current_win(win.winid)
          break
        end
      end
      if not qf_open then
        vim.cmd'copen'
      end
    end)
    UseKeymap('qf_close', function ()
      vim.cmd[[
        copen
        wincmd c
      ]]
    end)
    UseKeymap('qf_next', function () pcall(vim.cmd, 'cn') end)
    UseKeymap('qf_previous', function () pcall(vim.cmd, 'cp') end)
    UseKeymap('qf_first', function () vim.cmd'cfirst' end)
    UseKeymap('qf_last', function () vim.cmd'clast' end)
    UseKeymap('qf_add', function ()
      vim.fn.setqflist({
        {
          filename = vim.fn.expand'%',
          lnum = vim.fn.line'.',
          col = vim.fn.col'.',
          text = vim.fn.getline'.',
        },
      }, 'a')
      vim.cmd'copen'
      vim.cmd'wincmd p'
    end)
    UseKeymap('qf_diagnostics', function ()
      local bufnr = vim.api.nvim_get_current_buf()
      local diagnostics = vim.diagnostic.get(bufnr)
      local items = {}
      for _, diag in ipairs(diagnostics) do
        table.insert(items, {
          bufnr = bufnr,
          lnum = diag.lnum + 1,
          col = diag.col + 1,
          text = diag.message,
          type = diag.severity == vim.diagnostic.severity.ERROR and 'E' or 'W',
        })
      end
      vim.fn.setqflist(items, 'r')
      vim.cmd'copen'
    end)
    UseKeymap('qf_all_diagnostics', function ()
      vim.diagnostic.setqflist{ open = false }
      vim.cmd'copen'
    end)
    UseKeymap('qf_clear', function ()
      vim.fn.setqflist{}
      vim.cmd'cclose'
    end)
    UseKeymap('qf_go', function ()
      vim.cmd'cc'
    end)
    UseKeymap('qf_delete', function ()
      local qf_was_selected = false
      local qf_win_id = nil
      for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
          qf_win_id = win.winid
          if vim.api.nvim_get_current_win() == qf_win_id then
            qf_was_selected = true
          end
          break
        end
      end
      local index = vim.fn.getqflist{ idx = 0 }.idx
      vim.cmd'copen'
      if #vim.fn.getqflist() == 1 then
        vim.fn.setqflist{}
      else
        vim.api.nvim_command'normal! dd'
        vim.cmd'w'
      end
      if #vim.fn.getqflist() > 0 then
        local new_index = math.min(index, #vim.fn.getqflist())
        vim.fn.setqflist({}, 'r', { idx = new_index })
        vim.cmd('cc ' .. new_index)
        if not qf_was_selected then
          vim.cmd'wincmd p'
        end
      else
        vim.cmd 'cclose'
      end
      if #vim.fn.getqflist() == 0 then
        vim.cmd'cclose'
      elseif not qf_was_selected then
        vim.cmd'wincmd p'
      end
    end)
    UseKeymap('qf_focus', function ()
      if vim.bo.filetype == 'qf' then
        vim.cmd'wincmd p'
      else
        vim.cmd'copen'
      end
    end)
  end
}

return module

