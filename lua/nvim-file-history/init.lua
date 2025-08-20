local M = {}

M.config = {
  max_history_size = 20,
  history_file = '.nvim-file-history',
  exclude_patterns = {
    '%.git/',
    'node_modules/',
    '%.cache/',
    '/tmp/',
    '^oil:/',
  },
  exclude_filetypes = {
    'help',
    'NvimTree',
    'neo-tree',
    'telescope',
    'lazy',
    'mason',
    'oil',
  }
}

local state = {
  current_project = nil,
  history = {},
  history_file_path = nil,
}

local function get_project_root()
  local current_dir = vim.fn.expand('%:p:h')
  
  if current_dir == '' then
    current_dir = vim.fn.getcwd()
  end
  
  local function find_root(path)
    if vim.fn.filereadable(path .. '/.nvim-file-history-root') == 1 then
      return path
    end
    
    local parent = vim.fn.fnamemodify(path, ':h')
    if parent == path then
      return nil  -- Reached filesystem root, no marker found
    end
    
    return find_root(parent)
  end
  
  return find_root(current_dir)
end

local function should_exclude_file(filepath)
  if not filepath or filepath == '' then
    return true
  end
  
  for _, pattern in ipairs(M.config.exclude_patterns) do
    if string.match(filepath, pattern) then
      return true
    end
  end
  
  local filetype = vim.bo.filetype
  for _, ft in ipairs(M.config.exclude_filetypes) do
    if filetype == ft then
      return true
    end
  end
  
  return false
end

local function load_history()
  if not state.history_file_path then
    return
  end
  
  local file = io.open(state.history_file_path, 'r')
  if not file then
    state.history = {}
    return
  end
  
  local content = file:read('*all')
  file:close()
  
  state.history = {}
  for line in content:gmatch('[^\r\n]+') do
    local timestamp, filepath = line:match('(%d+)|(.+)')
    if timestamp and filepath then
      table.insert(state.history, {
        timestamp = tonumber(timestamp),
        filepath = filepath,
        relative_path = vim.fn.fnamemodify(filepath, ':~:.')
      })
    end
  end
end

local function save_history()
  if not state.history_file_path then
    return
  end
  
  local file = io.open(state.history_file_path, 'w')
  if not file then
    return
  end
  
  for _, entry in ipairs(state.history) do
    file:write(entry.timestamp .. '|' .. entry.filepath .. '\n')
  end
  
  file:close()
end

local function add_to_history(filepath)
  if should_exclude_file(filepath) then
    return
  end
  
  -- Don't add to history if no project root is found
  if not state.current_project then
    return
  end
  
  local absolute_path = vim.fn.fnamemodify(filepath, ':p')
  local timestamp = os.time()
  
  for i, entry in ipairs(state.history) do
    if entry.filepath == absolute_path then
      table.remove(state.history, i)
      break
    end
  end
  
  table.insert(state.history, 1, {
    timestamp = timestamp,
    filepath = absolute_path,
    relative_path = vim.fn.fnamemodify(absolute_path, ':~:.')
  })
  
  if #state.history > M.config.max_history_size then
    table.remove(state.history)
  end
  
  save_history()
end

local function update_project()
  local project_root = get_project_root()
  
  if not project_root then
    -- Show helpful error message when no .nvim-breadcrumbs-root file is found
    vim.notify(
      "File History: No .nvim-file-history-root file found.\n" ..
      "Please create an empty .nvim-file-history-root file at your project root to enable file history tracking.\n" ..
      "Example: touch /path/to/your/project/.nvim-file-history-root",
      vim.log.levels.WARN
    )
    return
  end
  
  if state.current_project ~= project_root then
    state.current_project = project_root
    state.history_file_path = project_root .. '/' .. M.config.history_file
    load_history()
  end
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  
  local group = vim.api.nvim_create_augroup('FileHistory', { clear = true })
  
  vim.api.nvim_create_autocmd({'BufEnter', 'BufRead'}, {
    group = group,
    callback = function()
      local filepath = vim.fn.expand('%:p')
      if filepath and filepath ~= '' then
        update_project()
        add_to_history(filepath)
      end
    end,
  })
  
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      save_history()
    end,
  })
end

function M.get_history()
  return state.history or {}
end

function M.get_current_project()
  return state.current_project
end

return M