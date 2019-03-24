call plug#begin()

" General
Plug 'junegunn/fzf.vim'
let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
nnoremap <C-p> :Files<CR>
nnoremap \ :Buffers<CR>
nnoremap L :Lines<CR>
"nnoremap <C-m> :Marks<CR>
nnoremap <leader>t :RustTest -- --nocapture<CR>

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
nnoremap <c-\> :NERDTreeToggle<cr>


Plug 'junegunn/vim-easy-align'
source ~/.vim/config/plugin/vim-easy-align.vim

source ~/.vim/config/plugin/notes.vim

Plug 'embear/vim-localvimrc'
let g:localvimrc_name=[".lvimrc", "project.vim"]

" Usability
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-rooter'
Plug 'sirver/ultisnips'

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

Plug 'milkypostman/vim-togglelist'
nmap <script> <silent> <leader>l :call ToggleLocationList()<CR>
nmap <script> <silent> <leader>q :call ToggleQuickfixList()<CR>

Plug 'neomake/neomake'

call plug#end()

call neomake#configure#automake('w')
