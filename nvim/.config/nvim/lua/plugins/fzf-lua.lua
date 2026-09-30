vim.pack.add { gh 'ibhagwan/fzf-lua' }

local fzf = require 'fzf-lua'

fzf.setup {
  ui_select = {},
  keymap = {
    builtin = {
      true,
      ['<C-d>'] = 'preview-page-down',
      ['<C-u>'] = 'preview-page-up',
    },
    fzf = {
      true,
      ['ctrl-d'] = 'preview-page-down',
      ['ctrl-u'] = 'preview-page-up',
    },
  },
  winopts = {
    path_shorten = 1,
  },
  files = {
    formatter = 'path.filename_first',
  },
  grep = {
    formatter = 'path.filename_first',
  },
}

require('config.keymaps').setup_picker {
  help_tags = fzf.helptags,
  keymaps = fzf.keymaps,
  find_files = fzf.files,
  builtin = fzf.builtin,
  grep_word = fzf.grep_cword,
  grep_visual = fzf.grep_visual,
  live_grep = fzf.live_grep,
  diagnostics = fzf.diagnostics_workspace,
  resume = fzf.resume,
  oldfiles = fzf.oldfiles,
  commands = fzf.commands,
  buffers = fzf.buffers,
  current_buffer = function() fzf.blines { previewer = false } end,
  open_buffers = function()
    fzf.live_grep {
      grep_open_files = true,
      prompt = 'Live Grep in Open Files> ',
    }
  end,
  neovim_files = function() fzf.files { cwd = vim.fn.stdpath 'config', follow = true } end,
  lsp_references = fzf.lsp_references,
  lsp_implementations = fzf.lsp_implementations,
  lsp_definitions = fzf.lsp_definitions,
  lsp_document_symbols = fzf.lsp_document_symbols,
  lsp_workspace_symbols = fzf.lsp_live_workspace_symbols,
  lsp_type_definitions = fzf.lsp_typedefs,
}
