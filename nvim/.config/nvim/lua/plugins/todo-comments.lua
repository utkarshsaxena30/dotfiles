-- Highlight todo, notes, etc in comments
-- TODO: example
-- NOTE: example
-- HACK: example
-- FIX: example
-- WARNING: example
vim.pack.add { gh 'folke/todo-comments.nvim' }
require('todo-comments').setup { signs = false }
