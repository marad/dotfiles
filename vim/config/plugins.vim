call plug#begin()

" General
Plug 'kien/ctrlp.vim'
source ~/.vim/config/plugin/ctrlp.vim

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'junegunn/vim-easy-align'
source ~/.vim/config/plugin/vim-easy-align.vim

" Plug 'Shougo/neocomplete.vim'
" source ~/.vim/config/plugin/neocomplete.vim

source ~/.vim/config/plugin/notes.vim

" Plug 'itchyny/lightline.vim'
" source ~/.vim/config/plugin/lightline.vim

Plug 'embear/vim-localvimrc'
let g:localvimrc_name=[".lvimrc", "project.vim"]

" Usability
" Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-rooter'
" Plug 'sirver/ultisnips'

" WebDev
Plug 'mattn/emmet-vim', { 'for': 'html' }
source ~/.vim/config/plugin/emmet.vim

" Clojure & Racket
" Plug 'luochen1990/rainbow'
" source ~/.vim/config/plugin/rainbow.vim
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'kovisoft/paredit', { 'for': ['clojure', 'scheme', 'racket'] }
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }
Plug 'wlangstroth/vim-racket', { 'for': 'racket' }

" Arduino
Plug 'jplaut/vim-arduino-ino', { 'for': 'ino' }

" Python
Plug 'klen/python-mode', { 'for': 'python' }
source ~/.vim/config/plugin/pymode.vim

" Rust
Plug 'vim-syntastic/syntastic'
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'
source ~/.vim/config/plugin/rust.vim

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

call plug#end()
