local module = {
  name = 'vim',
  desc = 'general settings',
  dependencies = { 'commands' },
  plugins = {
    -- 'airblade/vim-rooter',
    -- 'karb94/neoscroll.nvim',
  },
  fn = function ()
    -- use utf-8 encoding
    vim.cmd'set encoding=utf-8'

    -- use unix style line endings
    vim.cmd'set fileformat=unix'

    -- use perl regex
    vim.cmd[[
    nnoremap / /\v
    nnoremap ? ?\v
    ]]

    -- do not line break
    vim.wo.linebreak = false

    -- set highlight on search
    vim.o.hlsearch = true

    -- disable automatic new line
    vim.o.fixendofline = false

    -- enable mouse mode
    vim.o.mouse = 'a'

    -- sync clipboard between OS and nvim
    vim.o.clipboard = 'unnamedplus'

    -- enable break indent
    vim.o.breakindent = true

    -- recovery
    vim.opt.backup = true
    vim.opt.swapfile = false
    vim.opt.backupdir = vim.fn.expand'~/.local/share/nvim/backup//'
    vim.opt.directory = vim.fn.expand'~/.local/share/nvim/swap//'
    vim.opt.undolevels = 100000
    if vim.fn.has'persistent_undo' == 1 then
      vim.opt.undofile = true
      vim.opt.undodir = vim.fn.expand'~/.local/share/nvim/undo//'
    end

    -- case-insensitive searching
    vim.o.ignorecase = true
    vim.o.smartcase = true

    -- decrease update time
    vim.o.updatetime = 1
    vim.o.timeoutlen = 1
    vim.o.ttimeoutlen = 1

    -- set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'

    -- disable key sequence timeouts
    vim.o.timeout = false
    vim.o.ttimeout = false

    -- enable GUI terminal colors
    vim.o.termguicolors = true

    -- hide fill characters
    vim.opt.fillchars = { eob = ' ' }

    -- set number line width to 1
    vim.opt.numberwidth = 1

    -- hide concealed text
    vim.opt.conceallevel = 2
    -- vim.opt.concealcursor = 'nc'

    -- max scrollback size
    vim.opt.scrollback = 100000

    -- linebreak when wrapping is on
    vim.wo.linebreak = true

    -- incremental search preview
    vim.cmd'set inccommand=split'

    -- ensure path includes subdirectories
    vim.o.path = vim.o.path .. '**'

    -- disable netrw banner
    vim.g.netrw_banner = 0

    -- wrapping
    local wrap = false
    local function apply_wrap ()
      if vim.bo.filetype == 'terminal' then
        vim.opt.wrap = false
        vim.opt.linebreak = false
      elseif vim.bo.filetype == 'text' or vim.bo.filetype == 'markdown' or vim.bo.filetype == 'org' then
        vim.opt.wrap = true
        vim.opt.linebreak = true
      else
        vim.opt.wrap = wrap
        vim.opt.linebreak = wrap
      end
    end
    vim.api.nvim_create_autocmd({
      'TermOpen',
      'WinEnter',
      'BufEnter',
      'BufCreate',
      'BufWinEnter',
      'VimResized',
      'VimEnter',
    }, { callback = function () apply_wrap() end })
    UseKeymap('vim_wrap', function ()
      if vim.wo.wrap then
        print'wrap OFF'
        wrap = false
        apply_wrap()
      else
        print'wrap ON'
        wrap = true
        apply_wrap()
      end
    end)

    -- textobject for current line between whitespace
    vim.api.nvim_set_keymap('x', 'il', ':<c-u>norm! ^vg_<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('o', 'il', ':<c-u>norm! ^vg_<cr>', { noremap = true, silent = true })

    -- textobject for left / right of assignment
    -- vim.api.nvim_set_keymap('x', '-', ':<c-u>norm! ^vt=h<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('o', '-', ':<c-u>norm! ^vt=h<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('x', '=', ':<c-u>norm! ^t=lllvg_<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('o', '=', ':<c-u>norm! ^t=lllvg_<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('x', '_', ':<c-u>norm! ^vt:<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('o', '_', ':<c-u>norm! ^vt:<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('x', '+', ':<c-u>norm! ^t:lllvg_<cr>', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('o', '+', ':<c-u>norm! ^t:lllvg_<cr>', { noremap = true, silent = true })

    -- split management
    vim.cmd'set splitright'
    vim.cmd'set splitbelow'
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<c-w>s', '<c-\\><c-n>:new<cr>', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<c-w>v', '<c-\\><c-n>:vnew<cr>', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-s>', '<c-\\><c-n>:new<cr>', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-v>', '<c-\\><c-n>:vnew<cr>', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-q>', '<c-\\><c-n><c-w>q', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-b>', '<c-\\><c-n><c-w>=', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-o>', '<c-\\><c-n><c-w>o', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-x>', '<c-\\><c-n><c-w>x', { silent = true })
    vim.keymap.set({ 't', 'i', 'x', 'n' }, '<m-r>', '<c-\\><c-n><c-w>r', { silent = true })
    vim.keymap.set({ 't', 'i', 'x' }, '<m-h>', '<c-\\><c-n><c-w>h', { silent = true })
    vim.keymap.set({ 't', 'i', 'x' }, '<m-j>', '<c-\\><c-n><c-w>j', { silent = true })
    vim.keymap.set({ 't', 'i', 'x' }, '<m-k>', '<c-\\><c-n><c-w>k', { silent = true })
    vim.keymap.set({ 't', 'i', 'x' }, '<m-l>', '<c-\\><c-n><c-w>l', { silent = true })

    UseKeymap('vim_kill_buffers', function ()
      vim.cmd'%bd!'
      vim.cmd'echo ""'
    end)
    UseKeymap('vim_delete_buffer', function ()
      local saved_buf = vim.api.nvim_get_current_buf()
      vim.cmd'bprevious'
      vim.api.nvim_buf_delete(saved_buf, { force = true })
      vim.cmd'echo ""'
    end)
    UseKeymap('vim_only_buffer', function ()
      local saved_pos = vim.fn.winsaveview()
      vim.cmd'%bd!|e#|bd!#'
      vim.fn.winrestview(saved_pos)
    end)
    UseKeymap('vim_previous_buffer', function () vim.cmd'b#' end)
    UseKeymap('select_last_paste', function () vim.cmd'norm! `[v`]' end)
    UseKeymap('select_last_insert', function () vim.cmd'norm! `[v`]h' end)
    UseKeymap('vim_source', function ()
      local persistence = require'persistence'
      if persistence then
        persistence.save()
      end
      local path = vim.fn.stdpath'config'
      vim.cmd('so ' .. path .. '/init.lua')
      vim.cmd'nohlsearch'
      print'init.lua loaded'
    end)
    -- FIXME: add vim_eval_line: <leader>vE
    -- FIXME: UseKeymap for this
    vim.api.nvim_set_keymap('v', '<leader>ve', ":'<,'>so<cr>", { noremap = true, silent = true })
    UseKeymap('vim_eval', function ()
      local saved_pos = vim.fn.winsaveview()
      local filetype = vim.fn.expand'%:e'
      if filetype == 'lua' or filetype == 'vim' then
        vim.cmd'so %'
        vim.cmd'nohlsearch'
        vim.fn.winrestview(saved_pos)
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes('<esc>', true, false, true),
          'n',
          false
        )
      else
        print('Error: Unsupported filetype for sourcing (' .. filetype .. ')')
      end
    end)
    UseKeymap('goto_mark', function ()
      vim.api.nvim_feedkeys('`', 'n', true)
    end)
    UseKeymap('select_between_space', function () vim.cmd'norm! v^og_o' end)
    UseKeymap('select_all', function () vim.cmd'norm! ggVGo' end)
    UseKeymap('vim_spell_check', function ()
      if vim.wo.spell then
        print'spell check OFF'
        vim.wo.spell = false
      else
        print'spell check ON'
        vim.wo.spell = true
      end
    end)
    UseKeymap('cant_close_vim', function ()
      vim.cmd':qa!'
    end)
    UseKeymap('yank_filename', function ()
      vim.cmd'let @+ = expand("%")'
    end)
    UseKeymap('window_left', function () vim.cmd'wincmd h' end)
    UseKeymap('window_down', function () vim.cmd'wincmd j' end)
    UseKeymap('window_up', function () vim.cmd'wincmd k' end)
    UseKeymap('window_right', function () vim.cmd'wincmd l' end)
    -- UseKeymap('vim_quick_delete', function () vim.api.nvim_feedkeys('dd', 'n', true) end)
    UseKeymap('kill_tmux', function () vim.cmd'!tmux -L main kill-session -t main' end)
    UseKeymap('exit_tmux', function () vim.cmd'!tmux -L main detach' end)
    UseKeymap('smart_center', function () vim.cmd'Z' end)
  end
}

return module

