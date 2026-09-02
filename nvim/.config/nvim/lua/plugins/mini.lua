--  A collection of various small independent plugins/modules
--  This contains a lot of useful stuff, like the surround or a/i text objects, and much much more. I will need to spend some time going through the documentation for these
vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- TODO: add nerd font
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
  MiniIcons.mock_nvim_web_devicons()
end

require('mini.pairs').setup {
  mappings = {
    ['`'] = false,
  },
}

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup {
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()

-- File explorer: browse/edit the filesystem as a set of columns.
--  Opens focused on the current file (or cwd if the buffer is unnamed).
--  You can rename/create/delete by editing the listing and confirming.
require('mini.files').setup()
vim.keymap.set('n', '<leader>e', function()
  -- Toggle: close if already open, otherwise open at the current file.
  if not MiniFiles.close() then
    local buf_name = vim.api.nvim_buf_get_name(0)
    local path = buf_name ~= '' and buf_name or vim.uv.cwd()
    MiniFiles.open(path)
  end
end, { desc = 'File [E]xplorer (mini.files)' })

-- TODO: configure status line
local statusline = require 'mini.statusline'
-- Set `use_icons` to true if you have a Nerd Font
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

vim.keymap.set('n', '<leader>bd', require('mini.bufremove').delete)
