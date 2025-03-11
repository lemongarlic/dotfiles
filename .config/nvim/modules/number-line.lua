local module = {
  name = 'number-line',
  desc = 'configuration for number line',
  plugins = {},
  fn = function ()
    local nu = true
    local rnu = false
    local sc = 'yes'
    local function apply_on_leave ()
      if vim.bo.filetype == 'text'
        or vim.bo.filetype == 'markdown'
        or vim.bo.filetype == 'org'
        or vim.bo.filetype == 'help'
        or vim.bo.filetype == 'man'
      then
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = 'no'
      end
    end
    local function apply_on_enter ()
      if vim.bo.buftype == 'terminal'
        or vim.bo.filetype == 'minifiles'
        or vim.bo.filetype == 'aerial-nav'
      then
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = 'no'
      elseif vim.b.note_type then
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = 'no'
      elseif vim.bo.filetype == 'workspaces' or vim.bo.filetype == 'aerial' then
        vim.opt.number = true
        vim.opt.relativenumber = false
        vim.opt.signcolumn = 'no'
      elseif vim.bo.filetype == 'text'
        or vim.bo.filetype == 'markdown'
        or vim.bo.filetype == 'org'
        or vim.bo.filetype == 'help'
        or vim.bo.filetype == 'man'
      then
        vim.opt.number = true
        vim.opt.relativenumber = false
        vim.opt.signcolumn = 'no'
      elseif vim.api.nvim_win_get_config(0).relative ~= '' then
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = 'no'
      else
        vim.opt.number = nu
        vim.opt.relativenumber = rnu
        vim.opt.signcolumn = sc
      end
    end
    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
      callback = function () apply_on_leave() end,
    })
    vim.api.nvim_create_autocmd({
      'TermOpen',
      'WinEnter',
      'BufEnter',
      'BufCreate',
      'BufWinEnter',
      'VimResized',
      'VimEnter',
    }, { callback = function () apply_on_enter() end })
    UseKeymap('vim_signcolumn', function ()
      if vim.o.signcolumn == 'yes' then
        sc = 'no'
        apply_on_enter()
        print'signcolumn OFF'
      else
        sc = 'yes'
        apply_on_enter()
        print'signcolumn ON'
      end
    end)
    UseKeymap('vim_number_line', function ()
      if vim.wo.number then
        nu = false
        apply_on_enter()
        print'number line OFF'
      else
        nu = true
        apply_on_enter()
        print'number line ON'
      end
    end)
    UseKeymap('vim_relative_number_line', function ()
      if vim.wo.relativenumber then
        rnu = false
        apply_on_enter()
        print'relative number line OFF'
      else
        rnu = true
        apply_on_enter()
        print'relative number line ON'
      end
    end)
  end,
}

return module

