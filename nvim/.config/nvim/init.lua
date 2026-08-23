do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = true
end

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
require 'config.options'

-- ============================================================
-- SECTION 2: KEYMAPS
-- basic keymaps
-- ============================================================
require 'config.keymaps'

-- ============================================================
-- SECTION 3: AUTOCOMMANDS
-- basic keymaps
-- ============================================================
require 'config.autocmds'

-- Native quickfix and location-list presentation
require 'config.quickfix'

-- ============================================================
-- SECTION 4: PLUGIN MANAGER SETUP
-- build hooks, global helper functions
-- ============================================================
-- We're using vim.pack for plugin management, which is built into neovim
-- This module sets up some basic autocommands for plugin install & update lifecycle events
require 'plugins.setup'

-- ============================================================
-- SECTION 5: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  require 'plugins.guess-indent'
  require 'plugins.gitsigns'
  require 'plugins.which-key'
  require 'plugins.colorschemes'
  require 'plugins.todo-comments'
  require 'plugins.mini'
end

-- ============================================================
-- SECTION 6: SEARCH & NAVIGATION
-- Telescope setup and autocommands
-- ============================================================
do
  require 'plugins.telescope'
end

-- ============================================================
-- SECTION 7: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  require 'plugins.lsp'
end

-- ============================================================
-- SECTION 8: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  require 'plugins.conform'
end

-- ============================================================
-- SECTION 9: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  require 'plugins.blink-cmp'
end

-- ============================================================
-- SECTION 10: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  require 'plugins.treesitter'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
