vim.pack.add { gh 'seblyng/roslyn.nvim' }

-- Roslyn-specific Neovim integration for large, multi-solution repositories.
require('roslyn').setup {
  -- Let Roslyn watch project files instead of duplicating that work in Neovim.
  filewatching = 'roslyn',

  -- Search beyond the nearest parent directories for solution targets.
  broad_search = true,

  -- Ignore solutions belonging to dependencies or generated build output.
  ignore_target = function(target)
    return target:find('/node_modules/', 1, true) ~= nil
      or target:find('\\node_modules\\', 1, true) ~= nil
      or target:find('/bin/', 1, true) ~= nil
      or target:find('\\bin\\', 1, true) ~= nil
      or target:find('/obj/', 1, true) ~= nil
      or target:find('\\obj\\', 1, true) ~= nil
  end,
}
