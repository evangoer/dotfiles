-- Bread and butter settings.
vim.g.mapleader = ' '
vim.opt.autoread = true
vim.opt.number = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.textwidth = 80
vim.opt.hidden = true -- (explicit default)

-- Recovery
vim.opt.swapfile = false -- not useful once in 20 years
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('data') .. '/undo'

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

-- GUI
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.termguicolors = true

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

-- Quicker write, quit, vsplit
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>')
vim.keymap.set('n', '<leader>vs', '<cmd>vsp<CR>')

-- Smoother inline linting: faster refreshes, no jank when errors detected
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'

local Plug = vim.fn['plug#']
vim.call('plug#begin', vim.fn.stdpath('data') .. '/plugged')
Plug('rebelot/kanagawa.nvim') -- Colorscheme
Plug('neovim/nvim-lspconfig')
Plug('saghen/blink.cmp', { ['tag'] = 'v1.*' }) -- Completion (pin v1; v2 needs a separate blink.lib plugin)
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' }) -- Syntax highlighting
Plug('nvim-treesitter/nvim-treesitter-textobjects') 
Plug('ibhagwan/fzf-lua') -- Fuzzy finding
Plug('stevearc/conform.nvim') -- Formatting and linting
Plug('lewis6991/gitsigns.nvim')
-- TODO: try Plug('windwp/nvim-autopairs')
-- TODO: try Plug('folke/which-key.nvim')
-- TODO: try Plug('folke/todo-comments.nvim')
-- TODO: try Plug('mfussenegger/nvim-dap') + Plug('rcarriga/nvim-dap-ui')
vim.call('plug#end')

vim.cmd('colorscheme kanagawa-dragon')

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

-- Diagnostics
vim.diagnostic.config({
  virtual_text = { severity = vim.diagnostic.severity.ERROR },
  signs = true,
  underline = true,
  float = { border = 'rounded' },
})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Diagnostic float' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

-- LSP keybindings
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover info' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })

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

require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map('n', ']c', function() gs.nav_hunk('next') end, 'Next hunk')
    map('n', '[c', function() gs.nav_hunk('prev') end, 'Prev hunk')

    -- Stage / undo / reset
    map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
    map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
    map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage selection')
    map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset selection')
    map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
    map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
    map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')

    -- Preview / blame / diff
    map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
    map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
    map('n', '<leader>hB', gs.toggle_current_line_blame, 'Toggle line blame')
    map('n', '<leader>hd', gs.diffthis, 'Diff against index')
  end,
})
