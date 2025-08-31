# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Neovim plugin that tracks file history on a per-project basis. The plugin requires a `.nvim-file-history/` marker directory at the project root to enable tracking. History is saved to `history.txt` inside this directory.

## Architecture

The plugin consists of three main modules:

1. **init.lua** (`lua/nvim-file-history/init.lua`): Core functionality for tracking file visits, managing history persistence, and project detection
2. **telescope.lua** (`lua/nvim-file-history/telescope.lua`): Telescope picker integration for browsing file history with timestamps
3. **plugin/file-history.lua**: Auto-setup file that ensures the plugin is initialized

Key architectural decisions:
- Project roots are explicitly marked with `.nvim-file-history/` directory (no automatic detection)
- History is stored as simple timestamp|filepath format in `history.txt`
- Files are filtered based on patterns (oil://, .git/, node_modules/) and filetypes (help, NvimTree, etc.)
- Maximum history size is configurable (default: 20 files)

## Development Commands

Since this is a Neovim plugin, there are no build/test commands. Development workflow:
- Reload plugin in Neovim: `:lua package.loaded['nvim-file-history'] = nil; require('nvim-file-history').setup()`
- Test telescope picker: `:lua require('nvim-file-history.telescope').file_history_picker()`
- Check current project root: `:lua print(require('nvim-file-history').get_current_project())`

## Important Notes

- The plugin will not track history until a `.nvim-file-history/` directory exists at the project root
- History file (`history.txt`) is automatically excluded from being tracked in history
- Oil.nvim paths (oil://) are explicitly filtered out
- The plugin uses BufEnter and BufRead autocmds to track file visits