-- So conform is a formatter manager, i.e., it updates the buffer with the changes recommended by the actual formatter, e.g., prettier, the LSP server, or syleua, etc.
-- If using a specific formatter - other than the LSP - the formatter's binary needs to be installed separately
vim.pack.add { gh 'stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- You can specify filetypes to autoformat on save here:
    local enabled_filetypes = {
      lua = true,
      python = true,
      javascript = true,
      javascriptreact = true,
      typescript = true,
      typescriptreact = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    else
      return nil
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
  },
  -- You can also specify external formatters in here.
  formatters_by_ft = {
    lua = { 'stylua' },
    -- rust = { 'rustfmt' },
    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use 'stop_after_first' to run the first available formatter from the list
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
  },
}

vim.keymap.set('n', '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

vim.keymap.set('x', '<leader>f', function()
  local mode = vim.api.nvim_get_mode().mode
  local start = vim.fn.getpos 'v'
  local finish = vim.fn.getpos '.'
  local start_row, start_col = start[2], start[3]
  local end_row, end_col = finish[2], finish[3]

  if start_row == end_row and end_col < start_col then
    start_col, end_col = end_col, start_col
  elseif end_row < start_row then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  if mode == 'V' then
    start_col = 1
    end_col = #vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
  end

  require('conform').format {
    async = true,
    range = {
      start = { start_row, start_col - 1 },
      ['end'] = { end_row, end_col - 1 },
    },
  }
end, { desc = '[F]ormat selection' })
