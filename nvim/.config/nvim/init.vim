set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

call plug#begin('~/.local/share/nvim/plugged')
Plug 'romainl/Apprentice'
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'
Plug 'mxw/vim-jsx'
Plug 'w0rp/ale'
Plug 'leafgarland/typescript-vim'
Plug 'prettier/vim-prettier', { 'do': 'npm install' },
" Plug 'Shougo/deoplete.nvim' " https://github.com/Shougo/deoplete.nvim is deprecated, use ddc.vim instead
" Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
call plug#end()

" Bread and butter settings.
set autoread
set number
set bs=2
set ignorecase
set textwidth=80

" Default soft tabs, 2 spaces
set ts=2 sts=2 sw=2 expandtab

" Display invisibles (just barely)
set list
set listchars=tab:▸\ ,eol:¬

" Make tab completion behave more like the shell.
set wildmode=longest,list

" Make window splits behave as readers of English might expect
set splitbelow
set splitright

" Easier window movement
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"imap ‘   <Cmd>call codeium#CycleCompletions(1)<CR>
"imap “   <Cmd>call codeium#CycleCompletions(-1)<CR>
"nnoremap <leader>ci :CodeiumToggle<CR>

" Easier buffer movement
map <C-n> :bnext<CR>
map <C-p> :bprevious<CR>

" Clear search highlighting on ESC
nnoremap <esc> :noh<return><esc>

" Set colorscheme
set t_Co=256
color apprentice

set rtp+=/opt/local/share/fzf/vim

" Smoother inline linting: faster refreshes, no jank when errors detected
set updatetime=300
set signcolumn=yes

let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'css': ['prettier'],
\}
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'
let g:vim_json_syntax_conceal=0
let g:prettier#quickfix_enabled = 1
let g:prettier#autoformat = 0
let g:deoplete#enable_at_startup = 1
"let g:codeium_no_map_tab = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync
