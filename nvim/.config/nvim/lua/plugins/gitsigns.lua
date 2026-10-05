vim.pack.add { gh 'lewis6991/gitsigns.nvim' }

local changed_files_namespace = vim.api.nvim_create_namespace 'git-changed-files'

local function changed_files_text(info)
  local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
  local lines = {}

  for index = info.start_idx, info.end_idx do
    local item = items[index]
    local status = item.user_data.git_status
    local filename = vim.api.nvim_buf_get_name(item.bufnr)
    lines[#lines + 1] = ('%s  %s'):format(status, vim.fn.fnamemodify(filename, ':~:.'))
  end

  return lines
end

local function highlight_changed_files()
  local quickfix = vim.fn.getqflist { title = 1, items = 1, winid = 1 }
  if quickfix.title ~= 'Git changed files' or quickfix.winid == 0 then return end

  local buf = vim.api.nvim_win_get_buf(quickfix.winid)
  vim.api.nvim_buf_clear_namespace(buf, changed_files_namespace, 0, -1)

  for index, item in ipairs(quickfix.items) do
    local highlight = item.user_data.git_status == 'D' and 'DiffDelete' or 'DiffAdd'
    vim.api.nvim_buf_add_highlight(buf, changed_files_namespace, highlight, index - 1, 0, -1)
  end
end

local function open_changed_files()
  vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }, function(root_result)
    local root = vim.trim(root_result.stdout or '')
    if root_result.code ~= 0 or root == '' then
      vim.schedule(function() vim.notify('Not inside a Git repository', vim.log.levels.ERROR) end)
      return
    end

    vim.system({ 'git', '-C', root, 'status', '--porcelain=v1', '-z', '--untracked-files=all' }, { text = true }, function(status_result)
      vim.schedule(function()
        if status_result.code ~= 0 then
          vim.notify(vim.trim(status_result.stderr or 'Unable to read Git status'), vim.log.levels.ERROR)
          return
        end

        local files = {}
        local entries = vim.split(status_result.stdout or '', '\0', { plain = true, trimempty = true })
        local index = 1

        while index <= #entries do
          local entry = entries[index]
          local git_status = entry:sub(1, 2)
          local path = entry:sub(4)

          if git_status:find('R', 1, true) or git_status:find('C', 1, true) then index = index + 1 end

          local status
          if git_status == '??' or git_status:find('A', 1, true) then
            status = 'A'
          elseif git_status:find('D', 1, true) then
            status = 'D'
          else
            status = 'M'
          end

          files[#files + 1] = {
            filename = vim.fs.joinpath(root, path),
            lnum = 1,
            col = 1,
            user_data = { git_status = status },
          }
          index = index + 1
        end

        vim.fn.setqflist({}, ' ', {
          title = 'Git changed files',
          items = files,
          quickfixtextfunc = changed_files_text,
        })

        if #files > 0 then
          vim.cmd.copen()
          highlight_changed_files()
        else
          vim.cmd.cclose()
          vim.notify 'No changed files'
        end
      end)
    end)
  end)
end

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = 'quickfix',
  callback = function() vim.schedule(highlight_changed_files) end,
})

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
