set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

call plug#begin('~/.local/share/nvim/plugged')
Plug 'romainl/Apprentice'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'w0rp/ale'
call plug#end()

" Bread and butter settings.
set autoread
set number
set bs=2
set ignorecase
set textwidth=80

" Default soft tabs, 4 spaces
set ts=4 sts=4 sw=4 expandtab

" Display invisibles (just barely)
set list
set listchars=tab:▸\ ,eol:¬

" Make window splits behave as readers of English might expect
set splitbelow
set splitright

" Easier window movement
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Set colorscheme
set t_Co=256
color apprentice
