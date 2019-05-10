".vimrc
" Thomas
"
" This file contains tips and ideas from a wide variety of sources. Since this is for personal use, I'm lazy about
" distributing credit.
"
" Thank you, everybody.
" 

" BASICS
" --------------------------
" Searches are case-insensitive. Use /searchstring/I to disable temporarily.
set ignorecase

" Need this for some plugins to work. Not sure what it does.
filetype plugin indent on

" Auto-indent facility
"set ai
"set cindent
set noexpandtab
set shiftwidth=2
set tabstop=2
"au FileType xml setlocal equalprg=xmllint\ --pretty\ 2\ --format\ --recover\ -\ 2>/dev/null

" AESTHEICS
" --------------------------
"let g:zenburn_high_Contrast = 1
"let g:zenburn_alternate_Visual = 1
colorscheme zenburn 


" Turn on line numbers by default
set number

" Turn off annoying error bells
set noerrorbells
set visualbell
set t_vb=

" Show tabs and trailing whitespace visually http://docs.google.com/View?docid=dfkkkxv5_65d5p3nk 
if (&termencoding == "utf-8") || has("gui_running")
  if v:version >= 700
    set list listchars=tab:»\ ,trail:·,extends:…,nbsp:‗
  else
    set list listchars=tab:»\ ,trail:·,extends:…
  endif
else
  if v:version >= 700
    set list listchars=tab:>\ ,trail:.,extends:>,nbsp:_
  else
    set list listchars=tab:>\ ,trail:.,extends:>
  endif
endif

if ((has('syntax') && (&t_Co > 2)) || has('gui_running'))
  syntax on
endif


" BASIC RECONFIGURATION
" -------------------------

" Remap jj to <esc>
inoremap jj <Esc>
nnoremap JJJJ <Nop>

" Set tabs to 2 characters
set shiftwidth=2
set softtabstop=2

" Keep all temporary and backupfiles in ~/.vim 
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

silent !mkdir -p ~/.vim/backup > /dev/null 2>&1
silent !mkdir -p ~/.vim/tmp > /dev/null 2>&1

" Enable nice big viminfo file
set viminfo='1000,f1,:1000,/1000
set history=500

" FUNCTION KEYS
" -------------------------
" F7 - Indent entire file
map <F7> mzgg=G'z<CR>

" F3 - Toggle highlight search 
set hlsearch!
nnoremap <F3> :set hlsearch!<CR>

" http://stackoverflow.com/a/1563552/792789
autocmd Filetype sh setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype vim setlocal ts=2 sw=2 expandtab
autocmd Filetype kivy setlocal ts=4 sw=4 expandtab
