local path_width = 40

local function shorten_path(bufnr)
  local filename = vim.fn.bufname(bufnr)
  local relative = vim.fn.fnamemodify(filename, ':~:.')
  return vim.fn.pathshorten(relative)
end

local function fit_path(path)
  if vim.fn.strdisplaywidth(path) > path_width then
    local start = 0
    local chars = vim.fn.strchars(path)

    while start < chars and vim.fn.strdisplaywidth(vim.fn.strcharpart(path, start)) > path_width - 1 do
      start = start + 1
    end

    path = '…' .. vim.fn.strcharpart(path, start)
  end

  return path .. string.rep(' ', math.max(0, path_width - vim.fn.strdisplaywidth(path)))
end

_G.dotfiles_quickfix_text = function(info)
  local items

  if info.quickfix == 1 then
    items = vim.fn.getqflist({
      id = info.id,
      items = 1,
    }).items
  else
    items = vim.fn.getloclist(info.winid, {
      id = info.id,
      items = 1,
    }).items
  end

  local lines = {}

  for index = info.start_idx, info.end_idx do
    local item = items[index]
    local path = fit_path(shorten_path(item.bufnr))
    local position = item.lnum > 0 and string.format('%d:%d', item.lnum, item.col) or ''
    local text = (item.text or ''):gsub('[\r\n\t]', ' ')

    lines[#lines + 1] = string.format('%s │ %8s │ %s', path, position, text)
  end

  return lines
end

vim.o.quickfixtextfunc = 'v:lua.dotfiles_quickfix_text'

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Configure quickfix and location-list windows',
  group = vim.api.nvim_create_augroup('quickfix-window', { clear = true }),
  pattern = 'qf',
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.cursorline = true
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})
