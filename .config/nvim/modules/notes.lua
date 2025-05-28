local module = {
  name = 'notes',
  desc = 'Note-taking utilities',
  dependencies = { 'search', 'files' },
  -- plugins = {
  --   'meanderingprogrammer/render-markdown.nvim',
  -- },
  fn = function ()
    local dir = vim.fn.expand'~/notes'
    -- require'notes'.setup()
    UseKeymap('notes_explore', function () require'mini.files'.open(dir, false) end)
    UseKeymap('notes_grep', function () require'telescope.builtin'.live_grep{ cwd = '~/notes' } end)
    -- UseKeymap('notes_add', function () Notes.api.open() end)
    -- UseKeymap('notes_search', function () Notes.api.notes() end)
    -- UseKeymap('notes_inbox', function () Notes.api.inbox() end)
    -- UseKeymap('notes_toggle', function () Notes.api.toggle() end)
    -- UseKeymap('notes_undo', function () Notes.api.undo() end)
    -- UseKeymap('notes_bookmark_1', function () Notes.api.bookmarks.add(1) end)
    -- UseKeymap('notes_bookmark_2', function () Notes.api.bookmarks.add(2) end)
    -- UseKeymap('notes_bookmark_3', function () Notes.api.bookmarks.add(3) end)
    -- UseKeymap('notes_bookmark_4', function () Notes.api.bookmarks.add(4) end)
    -- UseKeymap('notes_bookmark_5', function () Notes.api.bookmarks.add(5) end)
    -- UseKeymap('notes_delete_bookmark_1', function () Notes.api.bookmarks.remove(1) end)
    -- UseKeymap('notes_delete_bookmark_2', function () Notes.api.bookmarks.remove(2) end)
    -- UseKeymap('notes_delete_bookmark_3', function () Notes.api.bookmarks.remove(3) end)
    -- UseKeymap('notes_delete_bookmark_4', function () Notes.api.bookmarks.remove(4) end)
    -- UseKeymap('notes_delete_bookmark_5', function () Notes.api.bookmarks.remove(5) end)
    -- UseKeymap('notes_goto_bookmark_1', function () Notes.api.bookmarks.go(1) end)
    -- UseKeymap('notes_goto_bookmark_2', function () Notes.api.bookmarks.go(2) end)
    -- UseKeymap('notes_goto_bookmark_3', function () Notes.api.bookmarks.go(3) end)
    -- UseKeymap('notes_goto_bookmark_4', function () Notes.api.bookmarks.go(4) end)
    -- UseKeymap('notes_goto_bookmark_5', function () Notes.api.bookmarks.go(5) end)
    -- UseKeymap('notes_bookmarks', function () Notes.api.bookmarks.list() end)
  end
}

return module

