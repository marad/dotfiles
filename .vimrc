set syntax=on
set sw=2 sts=2
set number
set hlsearch

set expandtab
set shiftwidth=2
set softtabstop=2
set smartindent
set clipboard=unnamedplus

filetype plugin indent on

cnoremap %% <C-R>=expand('%:h').'/'<cr>

" let g:airline#extensions#tabline#enable = 1
""""""""""""""""""""""""""""""""""""""""""""""""
" Setup CTRL-P plugin
""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_custom_ignore = '/node_modules/'

if has('gui_running')
  """""""""""""""""""""""""""""""""""""""""""""""
  " Setup air-line plugin
  """"""""""""""""""""""""""""""""""""""""""""""""
  set laststatus=2
  let g:airline_powerline_fonts=1

  """"""""""""""""""""""""""""""""""""""""""""""""
  " Setup editor
  """"""""""""""""""""""""""""""""""""""""""""""""
  set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10
  set guioptions-=m " Get rid of the menu
  set guioptions-=T " Get rid of the toolbar

  set background=dark
  colorscheme solarized

endif
""""""""""""""""""""""""""""""""""""""""""""""""
" Custom Auto commands
""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrcEx
  " Clear all autocmds in group
  autocmd!

  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \  exe "normal g`\"" |
    \ endif
  " For python set tabs to 4 spaces
  autocmd FileType python set sw=4 sts=4 et

  " autocmd FileType coffee let g:ctrlp_custom_ignore = '*.js' et

  autocmd BufRead,BufNewFile *.ino set filetype=c
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""
" Split window navigation
""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l


""""""""""""""""""""""""""""""""""""""""""""""""
" Install plugins
""""""""""""""""""""""""""""""""""""""""""""""""
call pathogen#infect()
