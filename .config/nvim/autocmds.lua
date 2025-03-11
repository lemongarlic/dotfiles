DefAutocmd({
  autosave = {
    event = { 'FocusLost', 'BufLeave' },
    pattern = '*',
    desc = 'Auto-save all buffers with existing files.',
  },
  no_auto_comments = {
    event = { 'FileType' },
    pattern = '*',
    desc = 'Prevents automatic comments from being added on new lines.',
  },
})

