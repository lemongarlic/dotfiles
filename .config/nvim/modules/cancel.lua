local module = {
  name = 'cancel',
  desc = 'defines a universal clear and cancel keymap.',
  plugins = {},
  fn = function ()
    -- helpers
    local function is_floating_window (win_id)
      local config = vim.api.nvim_win_get_config(win_id or 0)
      return config.relative ~= ''
    end

    -- keymaps
    UseKeymap('soft_cancel', function ()
      vim.cmd'noh'
      vim.cmd'echo ""'
    end)
    UseKeymap('cancel', function ()
      local a = vim.api.nvim_buf_get_name(0)
      local b = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      local is_nofile = vim.bo.buftype == 'nofile'
      local is_floating = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).relative ~= ''
      local is_org_roam_select = a:find'org%-roam%-select'
      local is_diagnostics = b and b:find'Diagnostics:'

      -- close command window
      if vim.fn.getcmdwintype() ~= '' then
        vim.cmd'wincmd c'
      -- workspaces
      elseif vim.bo.filetype == 'workspaces' then
        vim.cmd'bd!'
      -- terminal
      elseif vim.bo.buftype == 'terminal' then
        if is_floating_window(0) then
          vim.cmd'wincmd c'
        else
          vim.api.nvim_feedkeys('i\x03\x1c\x0eG0', 'n', true)
        end
      -- close lsp info window
      elseif vim.bo.filetype == 'markdown' and is_nofile then
        vim.api.nvim_win_close(0, true)
      -- close telescope window
      elseif vim.bo.filetype == 'TelescopePrompt' then
        vim.cmd'bd!'
      -- close harpoon window
      elseif vim.bo.filetype == 'harpoon' then
        vim.api.nvim_win_close(0, true)
      -- close quickfix window
      elseif vim.bo.buftype == 'quickfix' then
        vim.cmd'wincmd c'
      -- close help window
      elseif vim.bo.buftype == 'help' and vim.fn.winnr'$' > 1 then
        vim.cmd'wincmd c'
      elseif vim.bo.filetype == 'man' and vim.fn.winnr'$' > 1 then
        vim.cmd'wincmd c'
      -- close netrw buffer
      elseif vim.bo.filetype == 'netrw' then
        vim.cmd'bd'
      -- close undotree
      elseif vim.bo.filetype == 'undotree' then
        vim.api.nvim_win_close(0, true)
      -- close org-roam-select window
      elseif is_org_roam_select then
        vim.cmd'bd!'
      -- close lsp diagnostics window
      elseif is_nofile and b and is_diagnostics then
        vim.api.nvim_win_close(0, true)
      -- close mini.files window
      elseif vim.bo.filetype == 'minifiles' then
        require'mini.files'.close()
      -- close peek definition window
      elseif vim.bo.buftype == 'nofile' and is_floating then
        vim.api.nvim_win_close(0, true)
      -- close scratchpad
      elseif vim.api.nvim_buf_get_name(0) == vim.fn.expand'~/.local/share/nvim/scratch.txt' then
        _G.ScratchpadClose()
      -- close lsp info window
      elseif vim.fn.mode(1):sub(1, 1) == 'n' then
        vim.api.nvim_feedkeys('lh', 'n', false)
      end

      -- clear search highlights
      vim.cmd'noh'

      -- clear prompt
      vim.cmd'echo ""'

      -- press esc
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<esc>', true, false, true),
        'n',
        true
      )
    end)
  end
}

return module

