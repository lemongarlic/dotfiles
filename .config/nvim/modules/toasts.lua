local module = {
  name = 'toasts',
  desc = 'toast windows',
  dependencies = {},
  plugins = {},
  fn = function ()
    vim.cmd'command! -nargs=1 Toast lua Toast(<q-args>)'
    function _G.Toast (message, time)
      if not time then
        time = 1500
      end
      local buf = vim.api.nvim_create_buf(false, true)
      local len = 0
      local height = 1
      if type(message) == 'string' then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { ' ' .. message })
        len = #message
      else
        for i, msg in ipairs(message) do
          vim.api.nvim_buf_set_lines(buf, i - 1, -1, false, { ' ' .. msg })
          if #message[i] > len then
            len = #message[i]
          end
        end
        height = #message
      end
      local ui = vim.api.nvim_list_uis()[1]
      local width = ui.width
      local win_width = len + 2
      local win_height = height
      local col = width - win_width - 5
      local row = 1
      local win = vim.api.nvim_open_win(buf, false, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        col = col,
        row = row,
        focusable = false,
        style = 'minimal',
        border = 'rounded',
      })
      vim.defer_fn(function ()
        vim.api.nvim_win_close(win, true)
      end, time)
    end
end
}

return module

