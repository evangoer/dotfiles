syntax on

" Detect filetypes & set indent style, plugins, filetype overrides
if has("autocmd")
    filetype indent on
    filetype plugin on
    autocmd Filetype ruby setlocal ts=2 sts=2 sw=2 expandtab
endif

" Bread and butter settings.
set autoread
set encoding=utf-8
set number
set bs=2
set ignorecase

" Default soft tabs, 4 spaces.
set ts=4 sts=4 sw=4 expandtab

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

" http://technotales.wordpress.com/2010/03/31/preserve-a-vim-function-that-keeps-your-state/
function! Preserve(command)
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" strip whitespace from EOL, preserving state
nmap _$ :call Preserve("%s/\\s\\+$//e")
