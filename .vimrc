execute pathogen#infect()

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
set textwidth=80

" Default soft tabs, 4 spaces.
set ts=4 sts=4 sw=4 expandtab

" Display invisibles (just barely)
set list
set listchars=tab:▸\ ,eol:¬

" Make tab completion behave more like the shell.
set wildmode=longest,list

" Make window splits behave as readers of English might expect.
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

" syntastic: beginner settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
