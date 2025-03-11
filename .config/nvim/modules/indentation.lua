local module = {
  name = 'indentation',
  desc = 'sets indentation rules',
  plugins = {
    'gpanders/editorconfig.nvim',
    'tpope/vim-sleuth',
  },
  fn = function ()
    vim.cmd'filetype indent on'
    vim.opt.smartindent = true
    vim.opt.autoindent = true
    vim.opt.cindent = true
    vim.opt.expandtab = true
    vim.o.shiftwidth = 2
    vim.o.tabstop = 2
    -- FIXME: use UseKeymap
    vim.api.nvim_set_keymap('i', '<cr>', 'v:lua.__smart_newline__()', { noremap = true, expr = true, silent = true })
    -- indent line
    UseKeymap('indent_line', function ()
      local mode = vim.api.nvim_get_mode().mode
      if mode:match'^v' then
        vim.cmd'norm ='
      else
        vim.cmd'norm =='
      end
    end)
    -- indent all
    UseKeymap('indent_all', function ()
      local winview = vim.fn.winsaveview()
      vim.cmd'norm ggvG='
      vim.fn.winrestview(winview)
    end)
  end
}

local pairs = {
  ['{'] = '}',
  ['['] = ']',
  ['('] = ')',
  ['<'] = '>',
}

_G.__smart_newline__ = function ()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local char_before = line:sub(col, col)
  local char_after = line:sub(col + 1, col + 1)
  if pairs[char_before] == char_after then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
    vim.schedule(function ()
      local current_indent = vim.fn.indent(row)
      local new_indent = current_indent + vim.bo.shiftwidth
      local before_cursor = line:sub(1, col)
      local after_cursor = line:sub(col + 2)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before_cursor })
      vim.api.nvim_buf_set_lines(0, row, row, false, {
        string.rep(' ', new_indent),
        string.rep(' ', current_indent) .. char_after .. after_cursor
      })
      vim.api.nvim_win_set_cursor(0, { row + 1, new_indent })
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i<end>', true, false, true), 'n', false)
    end)
    return ''
  end
  if char_before == '[' or char_before == '<' then
    return vim.api.nvim_replace_termcodes('<cr><tab>', true, false, true)
  else
    return vim.api.nvim_replace_termcodes('<cr>', true, false, true)
  end
end

return module

