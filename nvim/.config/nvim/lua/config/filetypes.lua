vim.filetype.add {
  extension = {
    targets = 'xml',
    runsettings = 'xml',
    resx = 'xml',
    ruleset = 'xml',
    config = 'xml',
    Config = 'xml',
    globalconfig = 'editorconfig',
    kql = 'kusto',
  },
  pattern = {
    ['.*/charts/.*/templates/.*%.ya?ml'] = 'helm',
    ['.*/charts/.*%.tpl'] = 'helm',
    ['.*appsettings.*%.json'] = 'jsonc',
  },
}

vim.treesitter.language.register('json', 'jsonc')
