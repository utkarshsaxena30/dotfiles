local errorformat = '%E%f(%l\\,%c): %trror %m,%W%f(%l\\,%c): %tarning %m,%-G%.%#'

local function show_build_output(target, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, ('dotnet-build://%s/%d'):format(vim.fs.basename(target), vim.uv.hrtime()))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'log'
  vim.bo[buf].modifiable = false
  vim.cmd 'botright split'
  vim.api.nvim_win_set_buf(0, buf)
end

local function dotnet_build(target)
  if vim.fn.executable 'dotnet' ~= 1 then
    vim.notify('dotnet is not available', vim.log.levels.ERROR)
    return
  end

  if not target or not vim.uv.fs_stat(target) then
    vim.notify('Build target does not exist: ' .. tostring(target), vim.log.levels.ERROR)
    return
  end

  vim.notify('Building ' .. vim.fs.basename(target))

  vim.system({
    'dotnet',
    'build',
    target,
    '-nologo',
    '-clp:NoSummary',
    '-tl:off',
  }, { text = true }, function(result)
    vim.schedule(function()
      local output = (result.stdout or '') .. (result.stderr or '')
      local lines = vim.split(output, '\r?\n', { trimempty = true })

      vim.fn.setqflist({}, ' ', {
        title = 'dotnet build: ' .. vim.fs.basename(target),
        lines = lines,
        efm = errorformat,
      })

      local diagnostics = vim.fn.getqflist()
      if #diagnostics > 0 then
        vim.cmd.copen()
      elseif result.code == 0 then
        vim.cmd.cclose()
        vim.notify 'Build completed without compiler diagnostics'
      else
        vim.cmd.cclose()
        vim.notify('Build failed without parsed compiler diagnostics', vim.log.levels.ERROR)
        show_build_output(target, lines)
      end
    end)
  end)
end

vim.keymap.set('n', '<leader>mp', function()
  local buffer = vim.api.nvim_buf_get_name(0)
  local project = vim.fs.find(function(name) return name:match '%.csproj$' end, {
    upward = true,
    path = vim.fs.dirname(buffer),
  })[1]

  if not project then
    vim.notify('No .csproj found above the current file', vim.log.levels.ERROR)
    return
  end

  dotnet_build(project)
end, { desc = '[M]ake [P]roject' })

vim.keymap.set('n', '<leader>ms', function()
  local solution = vim.g.roslyn_nvim_selected_solution
  if not solution or solution == '' then
    vim.notify('No Roslyn solution selected; use :Roslyn target', vim.log.levels.ERROR)
    return
  end

  dotnet_build(solution)
end, { desc = '[M]ake [S]olution' })
