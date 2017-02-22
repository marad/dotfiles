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

Plug 'embear/vim-localvimrc'
let g:localvimrc_name=[".lvimrc", "project.vim"]

" Usability
" Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-rooter'
Plug 'sirver/ultisnips'
source ~/.vim/config/plugin/ultisnips.vim


" WebDev
Plug 'mattn/emmet-vim', { 'for': 'html' }
source ~/.vim/config/plugin/emmet.vim

" Clojure & Racket
Plug 'luochen1990/rainbow'
source ~/.vim/config/plugin/rainbow.vim
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'typedclojure/vim-typedclojure', { 'for': 'clojure' }
Plug 'kovisoft/paredit', { 'for': ['clojure', 'scheme', 'racket'] }
source ~/.vim/config/plugin/paredit.vim
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }
Plug 'gregspurrier/vim-midje', { 'for': 'clojure' }
" Plug 'gberenfield/cljfold.vim', { 'for': 'clojure' }
Plug 'wlangstroth/vim-racket', { 'for': 'racket' }

" Arduino
Plug 'jplaut/vim-arduino-ino', { 'for': 'ino' }

" Python
Plug 'klen/python-mode', { 'for': 'python' }
source ~/.vim/config/plugin/pymode.vim

" Org-Mode
Plug 'jceb/vim-orgmode', { 'for': 'org' }

Plug 'itchyny/calendar.vim'
source ~/.vim/config/plugin/calendar.vim

Plug 'vim-scripts/SyntaxRange'

call plug#end()
