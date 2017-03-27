call plug#begin()

" General
Plug 'kien/ctrlp.vim'
source ~/.vim/config/plugin/ctrlp.vim

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'junegunn/vim-easy-align'
source ~/.vim/config/plugin/vim-easy-align.vim

" Plug 'Shougo/neocomplete.vim'
" source ~/.vim/config/plugin/neocomplete.vim

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

" Rust Lang
Plug 'cespare/vim-toml', { 'for' : 'toml' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'racer-rust/vim-racer', { 'for': 'rust' }
set hidden
let g:racer_cmd = "/home/local/ALLEGROGROUP/marcin.radoszewski/.cargo/bin/racer"
let g:racer_experimental_completer = 1
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

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

Plug 'tpope/vim-surround'

" Common Lisp
Plug 'kovisoft/slimv', { 'for': 'lisp' }
source ~/.vim/config/plugin/slimv.vim

call plug#end()
