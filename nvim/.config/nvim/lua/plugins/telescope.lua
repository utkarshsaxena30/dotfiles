-- Telescope is a fuzzy finder. Though I've read about others like fzf-lua which are evidently more performative, I'm going to stick this with now until I run into issues with the speed.
-- NOTE: I might look into other fuzzy finders later on, if I have some time on my hands

-- Two important keymaps to use while in Telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- Telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!
---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}

if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

vim.pack.add(telescope_plugins)

require('telescope').setup {
  defaults = {
    path_display = { 'truncate' }, -- Without this option, long path names only displayed the initial file path, which was useless as it was much of the same for a lot of files in a deeply nested directory
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'

require('config.keymaps').setup_picker {
  help_tags = builtin.help_tags,
  keymaps = builtin.keymaps,
  find_files = builtin.find_files,
  builtin = builtin.builtin,
  grep_word = builtin.grep_string,
  grep_visual = builtin.grep_string,
  live_grep = builtin.live_grep,
  diagnostics = builtin.diagnostics,
  resume = builtin.resume,
  oldfiles = builtin.oldfiles,
  commands = builtin.commands,
  buffers = builtin.buffers,
  current_buffer = function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end,
  open_buffers = function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  neovim_files = function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end,
  lsp_references = builtin.lsp_references,
  lsp_implementations = builtin.lsp_implementations,
  lsp_definitions = builtin.lsp_definitions,
  lsp_document_symbols = builtin.lsp_document_symbols,
  lsp_workspace_symbols = builtin.lsp_dynamic_workspace_symbols,
  lsp_type_definitions = builtin.lsp_type_definitions,
}
