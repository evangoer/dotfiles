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
Plug 'Shougo/deoplete.nvim'
call plug#end()

" Bread and butter settings.
set autoread
set number
set bs=2
set ignorecase
set textwidth=80

" Default soft tabs, 4 spaces
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

" Clear search highlighting on ESC
nnoremap <esc> :noh<return><esc>

" Set colorscheme
set t_Co=256
color apprentice

let g:python3_host_prog = '/opt/local/bin/python'  " Python 3
let g:vim_json_syntax_conceal=0
let g:prettier#quickfix_enabled = 1
let g:prettier#autoformat = 0
let g:deoplete#enable_at_startup = 1
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync
