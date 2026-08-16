-- Takes a look at the first few hundred lines of the buffer to guess the indentation used, and then updates the buffer options to match that intelligently
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }

require('guess-indent').setup {}
