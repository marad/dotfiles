call plug#begin()

" General
Plug 'kien/ctrlp.vim'
source ~/.vim/config/plugin/ctrlp.vim

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'junegunn/vim-easy-align'
source ~/.vim/config/plugin/vim-easy-align.vim

Plug 'Shougo/neocomplete.vim'
source ~/.vim/config/plugin/neocomplete.vim

Plug 'itchyny/lightline.vim'
source ~/.vim/config/plugin/lightline.vim

" Usability
" Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-rooter'
Plug 'sirver/ultisnips'

" WebDev
Plug 'mattn/emmet-vim', { 'for': 'html' }
source ~/.vim/config/plugin/emmet.vim

" Clojure
Plug 'luochen1990/rainbow', { 'for': 'clojure' }
source ~/.vim/config/plugin/rainbow.vim
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'kovisoft/paredit', { 'for': 'clojure' }
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }

" Arduino
Plug 'jplaut/vim-arduino-ino', { 'for': 'ino' }

" Python
Plug 'klen/python-mode', { 'for': 'python' }

call plug#end()
