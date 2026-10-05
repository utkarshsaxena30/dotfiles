vim.pack.add { gh 'lewis6991/gitsigns.nvim' }

local function changed_files_text(info)
  local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
  local lines = {}

  for index = info.start_idx, info.end_idx do
    local filename = vim.api.nvim_buf_get_name(items[index].bufnr)
    lines[#lines + 1] = vim.fn.fnamemodify(filename, ':~:.')
  end

  return lines
end

local function open_changed_files()
  require('gitsigns').setqflist('all', { open = false }, function(err)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    local seen = {}
    local files = {}

    for _, item in ipairs(vim.fn.getqflist()) do
      local filename = vim.api.nvim_buf_get_name(item.bufnr)
      if filename ~= '' and not seen[filename] then
        seen[filename] = true
        files[#files + 1] = {
          bufnr = item.bufnr,
          lnum = 1,
          col = 1,
        }
      end
    end

    vim.fn.setqflist({}, ' ', {
      title = 'Git changed files',
      items = files,
      quickfixtextfunc = changed_files_text,
    })

    if #files > 0 then
      vim.cmd.copen()
    else
      vim.cmd.cclose()
      vim.notify 'No changed files'
    end
  end)
end

require('gitsigns').setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
  attach_to_untracked = true,
  current_line_blame = true,
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk' })

    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function() gitsigns.diffthis '@' end, { desc = 'git [D]iff against last commit' })
    map('n', '<leader>hQ', open_changed_files, { desc = 'git changed files [Q]uickfix list' })
    map('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)' })
    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff' })
    -- Text object
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
  end,
}
