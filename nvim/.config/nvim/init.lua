-- Bread and butter settings.
vim.g.mapleader = ' '
vim.opt.autoread = true
vim.opt.number = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.textwidth = 80
vim.opt.hidden = true -- (explicit default)

-- Base search
vim.opt.ignorecase = true -- /word matches: word WORD Word
vim.opt.smartcase = true --  /WoRd matches: WoRd
vim.opt.incsearch = true -- show all matches incrementally
vim.opt.hlsearch = true -- highlight matches (explicit default)

-- Default soft tabs, 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Display invisibles (just barely)
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', eol = '¬' }

-- Make tab completion behave more like the shell.
vim.opt.wildmode = 'list:longest,full'

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

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.local/share/nvim/plugged')
Plug('romainl/Apprentice') -- Colorscheme
Plug('neovim/nvim-lspconfig')
Plug('saghen/blink.cmp') -- Completion
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' }) -- Syntax highlighting
Plug('nvim-treesitter/nvim-treesitter-textobjects') 
Plug('ibhagwan/fzf-lua') -- Fuzzy finding
Plug('stevearc/conform.nvim') -- Formatting and linting
vim.call('plug#end')

vim.cmd('colorscheme apprentice')

require('blink.cmp').setup({
  fuzzy = { implementation = 'lua' },
  keymap = {
    preset = 'super-tab',
    ['<CR>'] = { 'accept', 'fallback' },
  },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets' },
  },
  completion = {
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
})

-- LSP: shared capabilities from blink.cmp, applied to all servers
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})
vim.lsp.config('ts_ls', {
  init_options = {
    tsserver = {
      path = vim.fn.expand('~/.local/share/mise/installs/npm-typescript/latest/lib/node_modules/typescript'),
    },
  },
})
vim.lsp.enable({ 'ts_ls', 'pyright', 'ruff' })

-- Treesitter: highlighting and indent are built into nvim 0.11.
-- Install parsers with :TSInstall <lang> (e.g. :TSInstall javascript python lua)

-- Textobjects
require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
})
local ts_select = require('nvim-treesitter-textobjects.select')
vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer') end)
vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner') end)
vim.keymap.set({ 'x', 'o' }, 'ac', function() ts_select.select_textobject('@class.outer') end)
vim.keymap.set({ 'x', 'o' }, 'ic', function() ts_select.select_textobject('@class.inner') end)

-- fzf-lua (fuzzy finding)
local fzf = require('fzf-lua')
fzf.setup({
  grep = {
    -- Search hidden files (dotfiles), but still skip .git/
    rg_opts = '--hidden --glob "!.git/" --column --line-number --no-heading --color=always --smart-case --max-columns=4096',
  },
})
vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fs', fzf.lsp_document_symbols, { desc = 'Document symbols' })

require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    javascriptreact = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    python = { 'ruff_format' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
