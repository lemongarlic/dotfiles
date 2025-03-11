local module = {
  name = 'ai',
  desc = 'LLM plugins',
  plugins = {
    {
      'olimorris/codecompanion.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
      config = true,
    }
  },
  fn = function ()
    local codecompanion = require'codecompanion'
    local last_win = vim.api.nvim_get_current_win()
    local layout = nil
    UseKeymap('ai_chat', function ()
      local current_tab = vim.api.nvim_get_current_tabpage()
      local current_buf = vim.api.nvim_get_current_buf()
      local windows = vim.api.nvim_tabpage_list_wins(current_tab)
      local is_open = false
      for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
        if filetype == 'codecompanion' then
          is_open = true
          vim.api.nvim_win_close(win, true)
          if buf == current_buf then
            vim.api.nvim_set_current_win(last_win)
          end
          if layout then
            vim.cmd(layout)
            layout = nil
          end
        end
      end
      if not is_open then
        layout = vim.fn.winrestcmd()
        last_win = vim.api.nvim_get_current_win()
        vim.cmd'CodeCompanionChat'
        vim.cmd'wincmd H'
        vim.api.nvim_win_set_width(0, math.min(53, math.ceil(vim.o.columns / 2)))
      end
    end)
    UseKeymap('ai_inline', function () vim.cmd'CodeCompanion' end)
    local function auth ()
      local key_path = vim.fn.stdpath'data' .. '/openai_api_key.txt'
      if vim.fn.filereadable(key_path) ~= 1 then
        return
      end
      local api_key = vim.fn.readfile(key_path)[1]
      codecompanion.setup{
        strategies = {
          chat = {
            adapter = 'openai',
          },
          inline = {
            adapter = 'openai',
          },
        },
        adapters = {
          openai = function ()
            return require'codecompanion.adapters'.extend('openai', {
              env = {
                api_key = api_key,
              },
              schema = {
                model = {
                  default = 'gpt-4o',
                },
              },
            })
          end,
        },
      }
    end
    vim.api.nvim_create_user_command('SaveOpenAIAPIKey', function()
      local api_key = vim.fn.input'Enter your OpenAI API key: '
      local key_path = vim.fn.stdpath'data' .. '/openai_api_key.txt'
      vim.fn.writefile({ api_key }, key_path)
      auth()
    end, {})
    auth()
  end,
}

return module

