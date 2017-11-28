" Map , key to be a leader key
let mapleader=","
let g:mapleader=","

" Whitespaces
set sw=4 sts=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

" Searching
set hlsearch
set incsearch
set showmatch
set ignorecase smartcase

set clipboard=unnamedplus
set autoread
set history=1000
set hidden
"set number

" completion menu
set wildmenu
set wildmode="list:longest"
set wildignore=*.class,*.o,*~,*.pyc,*/target/*

" pattern matching
set magic
set gdefault " set default /g on substitutions

" other
set backspace=eol,start,indent
set scrolloff=2
"set winwidth=79
set noswapfile
set nobackup
set nowritebackup

filetype plugin indent on
syntax on

set inccommand=nosplit
