# nvim-file-history

A Neovim plugin that tracks file history per project and provides breadcrumb-style navigation through Telescope.

What's unique about this plugin is it's project-scoped history. You place a `.nvim-file-history/` marker file 
at the root of your project, and then it tracks all files you open in that project.

<img width="3024" height="1894" alt="CleanShot 2025-08-19 at 21 00 46@2x" src="https://github.com/user-attachments/assets/51016b35-e818-4e02-a9f0-20c08e322c5e" />

## ✨ Features

- **Explicit project-scoped history**: Tracks file visits per project using a `.nvim-file-history/` marker directory
- **Persistent across sessions**: History is saved to `history.txt` inside `.nvim-file-history/` in your project root
- **Telescope integration**: Beautiful UI for browsing history and breadcrumbs
- **Smart filtering**: Excludes temp files, git directories, and special buffers
- **Time-aware**: Shows when files were last visited
- **Oil.nvim integration**: Automatically excludes `oil://` paths
- **Single history file**: One history file per project, no fragmentation

## 📦 Installation

### Lazy.nvim

```lua
{
  'yourusername/nvim-file-history',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    local file_history = require('nvim-file-history')
    local telescope_integration = require('nvim-file-history.telescope')
    
    file_history.setup({
      max_history_size = 100,
      exclude_patterns = {
        '%.git/',
        'node_modules/',
        '%.cache/',
        '/tmp/',
        '^oil:/',  -- Exclude oil.nvim paths
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
    })
    
    -- Keybindings
    vim.keymap.set('n', '<leader>b', telescope_integration.file_history_picker, { desc = 'File [B]ack history' })
    
    -- Commands
    vim.api.nvim_create_user_command('FileHistory', telescope_integration.file_history_picker, {})
  end
}
```

### Packer.nvim

```lua
use {
  'yourusername/nvim-file-history',
  requires = { 'nvim-telescope/telescope.nvim' },
  config = function()
    -- Same configuration as above
  end
}
```

## 🚀 Usage

### Initial Setup

**Important**: You must create a `.nvim-file-history/` file at your project root for the plugin to work:

This file tells the plugin where the root of your project is so that it knows the context of which history to 
care about and which files to track.

```bash
# Navigate to your project root
cd /path/to/your/project

# Create the marker file
mkdir .nvim-file-history
```

The plugin will show a warning if this file is not found and will not track history until you create it.

### Keybindings (Default)

- `<leader>b` - Open file history picker (all files in project history)

### Commands

- `:FileHistory` - Open full file history

### How it works

1. **Project setup**: Create a `.nvim-file-history/` file at your project root
2. **Automatic tracking**: Every time you open a file (`BufEnter`/`BufRead`), it's added to history
3. **Project detection**: Looks for `.nvim-file-history/` file to determine project root
4. **Smart exclusions**: Filters out temporary files, node_modules, .git, oil:// paths, etc.
5. **Persistent storage**: History saved to `.nvim-file-history` in project root

## ⚙️ Configuration

### Custom Configuration Example

```lua
require('nvim-file-history').setup({
  max_history_size = 50,                     -- Track fewer files
  history_file = '.my-buffer-history',       -- Custom filename
  exclude_patterns = {
    '%.git/',
    'node_modules/',
    '^/tmp/',
    'target/',                              -- Rust build dir
    'dist/',                                -- Build outputs
  },
  exclude_filetypes = {
    'help',
    'terminal',
    'qf',                                   -- Quickfix
  }
})
```

## 🎯 Use Cases

1. **Session recovery**: Reopen nvim and see your recent file trail
2. **Code exploration**: When diving deep into references, see your breadcrumb trail
3. **Project context**: Quickly return to recently viewed files in current project
4. **Cross-session continuity**: History persists between nvim sessions
5. **Explicit project boundaries**: You control exactly where history is tracked by placing the marker file

## 💡 Why `.nvim-file-history/`?

This approach eliminates common issues with automatic project detection:

- **No fragmentation**: Prevents multiple history files in subdirectories
- **Explicit control**: You decide exactly where your project boundaries are
- **No guesswork**: No complex logic trying to detect project roots
- **Predictable behavior**: Always creates exactly one history file per project

## 🔧 API

### Core Functions

```lua
local file_history = require('nvim-file-history')

-- Setup the plugin
file_history.setup(opts)

-- Get current history for the project
local history = file_history.get_history()

-- Get current project root
local project = file_history.get_current_project()
```

### Telescope Integration

```lua
local telescope_integration = require('nvim-file-history.telescope')

-- Open file history picker
telescope_integration.file_history_picker(opts)
```

## 🎨 Telescope UI

- **Time stamps**: Shows "2m ago", "1h ago", "3d ago" for each file
- **Relative paths**: Shows project-relative paths for cleaner display
- **File preview**: Full file preview in telescope
- **Quick navigation**: Press Enter to open file
- **Smart highlighting**: Different colors for file paths and timestamps

## 📝 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- Built on top of [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Inspired by IDE breadcrumb navigation patterns
