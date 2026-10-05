local map = vim.keymap.set
local M = {}

-- Equivalent to :update or :up
-- Different from :w or :write as it only flushes buffer to disk if there are changes
map('n', '<leader>w', '<cmd>update<CR>', {
  desc = '[W]rite buffer',
})

map('n', '<leader>wa', '<cmd>wall<CR>', {
  desc = '[W]rite [A]ll buffers',
})

map('n', '<leader>qq', '<cmd>quit<CR>', {
  desc = '[Q]uit window',
})

map('n', '<leader>qa', '<cmd>quitall<CR>', {
  desc = '[Q]uit [A]ll',
})

map('n', '<leader><Tab>', '<cmd>edit #<CR>', {
  desc = 'Switch to alternate file',
})

map('n', '<leader>h<Tab>', '<cmd>botright sbuffer #<CR>', {
  desc = 'Open alternate file in [H]orizontal split',
})

map('n', '<leader>v<Tab>', '<cmd>botright vertical sbuffer #<CR>', {
  desc = 'Open alternate file in [V]ertical split',
})

-- Clear highlights on search when pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

if vim.fn.has 'win32' == 1 then map('n', '<leader>tt', '<cmd>botright split | terminal pwsh -NoLogo<CR>', {
  desc = '[T]erminal pwsh',
}) end

-- Disable arrow keys in normal mode
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- This does not work for now, but I'm going to let it be
map('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
map('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
map('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
map('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })

---@param picker table<string, function>
function M.setup_picker(picker)
  map('n', '<leader>sh', picker.help_tags, { desc = '[S]earch [H]elp' })
  map('n', '<leader>sk', picker.keymaps, { desc = '[S]earch [K]eymaps' })
  map('n', '<leader>sf', picker.find_files, { desc = '[S]earch [F]iles' })
  map('n', '<leader>ss', picker.builtin, { desc = '[S]earch [S]elect picker' })
  map('n', '<leader>sw', picker.grep_word, { desc = '[S]earch current [W]ord' })
  map('x', '<leader>sw', picker.grep_visual, { desc = '[S]earch selected [W]ord' })
  map('n', '<leader>sg', picker.live_grep, { desc = '[S]earch by [G]rep' })
  map('n', '<leader>sd', picker.diagnostics, { desc = '[S]earch [D]iagnostics' })
  map('n', '<leader>sr', picker.resume, { desc = '[S]earch [R]esume' })
  map('n', '<leader>s.', picker.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  map('n', '<leader>sc', picker.commands, { desc = '[S]earch [C]ommands' })
  map('n', '<leader><leader>', picker.buffers, { desc = '[ ] Find existing buffers' })

  -- Override the default picker behavior when searching the current buffer.
  map('n', '<leader>/', picker.current_buffer, { desc = '[/] Fuzzily search in current buffer' })

  -- Search only inside files which are already open in Neovim.
  map('n', '<leader>s/', picker.open_buffers, { desc = '[S]earch [/] in Open Files' })

  -- Shortcut for searching your Neovim configuration files.
  map('n', '<leader>sn', picker.neovim_files, { desc = '[S]earch [N]eovim files' })

  -- Add picker-based LSP keymaps when an LSP attaches to a buffer.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('picker-lsp-attach', { clear = true }),
    callback = function(event)
      local opts = { buffer = event.buf }

      -- Find references for the word under your cursor.
      map('n', 'grr', picker.lsp_references, vim.tbl_extend('force', opts, { desc = '[G]oto [R]eferences' }))

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      map('n', 'gri', picker.lsp_implementations, vim.tbl_extend('force', opts, { desc = '[G]oto [I]mplementation' }))

      -- Jump to the definition of the word under your cursor.
      -- To jump back, press <C-t>.
      map('n', 'grd', picker.lsp_definitions, vim.tbl_extend('force', opts, { desc = '[G]oto [D]efinition' }))

      -- Fuzzy find all symbols in the current document.
      map('n', 'gO', picker.lsp_document_symbols, vim.tbl_extend('force', opts, { desc = 'Open Document Symbols' }))

      -- Fuzzy find all symbols in the current workspace.
      map('n', 'gW', picker.lsp_workspace_symbols, vim.tbl_extend('force', opts, { desc = 'Open Workspace Symbols' }))

      -- Jump to the definition of the type of the word under your cursor.
      map('n', 'grt', picker.lsp_type_definitions, vim.tbl_extend('force', opts, { desc = '[G]oto [T]ype Definition' }))
    end,
  })
end

return M
