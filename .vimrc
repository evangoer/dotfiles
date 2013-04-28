syntax on

" Detect filetypes, set indent style and plugins
if has("autocmd")
    filetype indent on
    filetype plugin on
endif

" Bread and butter settings.
set autoread
set encoding=utf-8
set number
set bs=2
set ignorecase 

" Always convert tabs to 4 spaces. 
set expandtab
set tabstop=4
set shiftwidth=4

" Display invisibles (just barely)
set list
set listchars=tab:▸\ ,eol:¬
let g:solarized_visibility="low"

" Make tab completion behave more like the shell.
set wildmode=longest,list

" Make window splits behave as readers of English might expect.
set splitbelow
set splitright

" Use solarized, with hack for OS X 10.6 terminals that lack 256 colors 
if $TERM=="xterm-color"
    color desert
else
    set t_Co=256
    set background=dark
    color solarized
endif 
