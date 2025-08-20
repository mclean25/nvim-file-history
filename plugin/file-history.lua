-- Optional auto-setup file
-- This file will run automatically when the plugin is loaded
-- Most users will configure this manually in their config, but this provides defaults

if vim.g.loaded_file_history then
  return
end
vim.g.loaded_file_history = 1

-- Only auto-setup if user hasn't called setup() manually
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Check if setup was already called
    local file_history = require('nvim-file-history')
    if not file_history.config then
      -- Setup with defaults if not already configured
      file_history.setup()
    end
  end,
  once = true,
})