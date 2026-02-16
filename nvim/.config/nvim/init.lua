-- Bread and butter settings.
vim.opt.autoread = true
vim.opt.number = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.ignorecase = true
vim.opt.textwidth = 80

-- Default soft tabs, 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Display invisibles (just barely)
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', eol = '¬' }

-- Make tab completion behave more like the shell.
vim.opt.wildmode = 'longest,list'

-- Make window splits behave as readers of English might expect
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Easier window movement
vim.keymap.set('', '<C-h>', '<C-w>h')
vim.keymap.set('', '<C-j>', '<C-w>j')
vim.keymap.set('', '<C-k>', '<C-w>k')
vim.keymap.set('', '<C-l>', '<C-w>l')

-- Easier buffer movement
vim.keymap.set('', '<C-n>', '<cmd>bnext<CR>')
vim.keymap.set('', '<C-p>', '<cmd>bprevious<CR>')

-- Clear search highlighting on ESC
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Smoother inline linting: faster refreshes, no jank when errors detected
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'

