".vimrc

" https://github.com/junegunn/vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Reload .vimrc and :PlugInstall to install plugins.
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'sheerun/vim-polyglot'
Plug 'vim-airline/vim-airline'
call plug#end()

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


" BASIC RECONFIGURATION
" -------------------------

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
" none

" http://stackoverflow.com/a/1563552/792789
autocmd Filetype sh setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype vim setlocal ts=2 sw=2 expandtab
autocmd Filetype kivy setlocal ts=4 sw=4 expandtab
