local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  return
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')

local file_history = require('nvim-file-history')

local M = {}

local function format_time_ago(timestamp)
  local now = os.time()
  local diff = now - timestamp
  
  if diff < 60 then
    return string.format('%ds ago', diff)
  elseif diff < 3600 then
    return string.format('%dm ago', math.floor(diff / 60))
  elseif diff < 86400 then
    return string.format('%dh ago', math.floor(diff / 3600))
  else
    return string.format('%dd ago', math.floor(diff / 86400))
  end
end

local function make_display(entry)
  local relative_path = entry.relative_path
  local time_ago = format_time_ago(entry.timestamp)
  local display_string = string.format('%-50s %s', relative_path, time_ago)
  
  return display_string, {
    {
      {0, #relative_path},
      'TelescopeResultsIdentifier'
    },
    {
      {#relative_path + 1, #display_string},
      'TelescopeResultsComment'
    }
  }
end

function M.file_history_picker(opts)
  opts = opts or {}
  
  local history = file_history.get_history()
  local current_project = file_history.get_current_project()
  
  if not current_project then
    vim.notify(
      "File History: No .nvim-file-history-root file found.\n" ..
      "Please create an empty .nvim-file-history-root file at your project root to enable file history tracking.\n" ..
      "Example: touch /path/to/your/project/.nvim-file-history-root",
      vim.log.levels.WARN
    )
    return
  end
  
  if #history == 0 then
    vim.notify('No file history found for current project', vim.log.levels.INFO)
    return
  end
  
  pickers.new(opts, {
    prompt_title = string.format('File History (%s)', vim.fn.fnamemodify(current_project or '', ':t')),
    finder = finders.new_table({
      results = history,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.relative_path,
          path = entry.filepath,
          timestamp = entry.timestamp,
          relative_path = entry.relative_path,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = conf.file_previewer(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection.path))
        end
      end)
      
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.notify('Would delete: ' .. selection.relative_path, vim.log.levels.INFO)
        end
      end)
      
      return true
    end,
  }):find()
end



return M