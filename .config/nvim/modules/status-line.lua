local module = {
  name = 'status-line',
  desc = 'configures the status line',
  dependencies = { 'git', 'terminal' },
  plugins = {},
}

local excluded_buftypes = { 'prompt', 'terminal' }
local excluded_filetypes = { 'aerial', 'aerial-nav', 'gitcommit', 'workspaces', 'harpoon', 'minifiles' }

_G.__statusline__ = {}

function _G.__statusline__.RenderStatusLeft ()
  local statusline = ''

  -- buffer name
  statusline = statusline .. _G.__statusline__.GetBufferName()

  -- return early for some buffers
  if vim.api.nvim_buf_get_name(0) == '/home/user/.local/share/nvim/scratch.txt' then
    return statusline
  end

  -- exclude certain buffers
  for _, bt in ipairs(excluded_buftypes) do
    if vim.bo.buftype == bt then
      return statusline
    end
  end
  for _, ft in ipairs(excluded_filetypes) do
    if vim.bo.filetype == ft then
      return statusline
    end
  end

  -- modified status
  if vim.bo.modified then
    statusline = statusline .. ' [+]'
  end

  -- git status
  local git_branch = vim.b.gitsigns_head or ''
  if git_branch ~= '' then
    statusline = statusline .. ' <' .. git_branch .. '>'
  end
  statusline = statusline .. ' ' .. (vim.b.gitsigns_status or '')

  return statusline
end

function _G.__statusline__.RenderStatusRight ()
  if vim.b.note_type then
    return 'markdown'
  end
  if vim.bo.filetype == '' and vim.bo.buftype == '' then
    return ''
  end
  if vim.bo.filetype == 'TelescopePrompt' then
    return 'telescope'
  end
  if vim.bo.filetype == 'workspaces' then
    return 'workspaces'
  end
  if vim.bo.filetype == 'harpoon' then
    return 'harpoon'
  end
  if vim.bo.filetype == 'aerial' then
    return 'aerial'
  end
  if vim.bo.filetype == 'aerial-nav' then
    return 'aerial-nav'
  end
  if vim.bo.filetype == 'minifiles' then
    return 'minifiles'
  end
  if vim.bo.buftype == 'terminal' then
    return 'terminal'
  end

  local statusline = ''

  -- exclude certain buffers
  for _, bt in ipairs(excluded_buftypes) do
    if vim.bo.buftype == bt then
      return statusline
    end
  end
  for _, ft in ipairs(excluded_filetypes) do
    if vim.bo.filetype == ft then
      return statusline
    end
  end

  -- column
  local col = vim.fn.col'.'
  statusline = statusline .. col

  -- percentage through buffer
  local percent = math.floor((vim.fn.line'.' / vim.fn.line'$') * 100)
  statusline = statusline .. ' ' .. percent .. '% '

  -- buffer language
  local lang = vim.bo.filetype ~= '' and vim.bo.filetype or vim.bo.buftype
  statusline = statusline .. lang

  return statusline
end

function _G.__statusline__.GetBufferName ()
  if vim.api.nvim_buf_get_name(0) == '/home/user/.local/share/nvim/scratch.txt' then
    return 'scratchpad'
  end
  if vim.bo.filetype == 'workspaces' then
    return ''
  end
  if vim.bo.filetype == 'harpoon' then
    return ''
  end
  -- FIXME: get actual model
  if vim.bo.filetype == 'codecompanion' then
    return 'gpt-4o'
  end
  if vim.bo.buftype == 'terminal' then
    local job_id = vim.b.terminal_job_id
    if job_id then
      for name, stored_job_id in pairs(_G.__terminals__) do
        if stored_job_id == job_id then
          return name
        end
      end
    end
  end
  local full_path = vim.fn.expand'%:p'
  local notes_dir = vim.fn.expand'~/notes'
  if full_path:sub(1, #notes_dir) == notes_dir then
    return full_path:sub(#notes_dir + 2)
  end
  return vim.fn.expand'%f'
end

local function render ()
  vim.opt.statusline = '%{v:lua.__statusline__.RenderStatusLeft()}%=%{v:lua.__statusline__.RenderStatusRight()}'
end

module.fn = function ()
  -- hide command
  vim.o.showcmd = true
  -- use a global statusline
  vim.cmd'set laststatus=3'
  -- render status
  render()
end

return module

