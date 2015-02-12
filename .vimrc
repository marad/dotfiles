" This is Marcin Radoszewski's .vimrc file
" See other dotfiles at https://github.com/marad/dotfiles

let mapleader=","
let g:mapleader=","

set autoread
set hidden
set history=1000
set sw=2 sts=2
"set number
set hlsearch
set incsearch
set showmatch
set ignorecase smartcase

set expandtab
set shiftwidth=2
set softtabstop=2
set smartindent
set clipboard=unnamedplus

"set winwidth=79
set wildmode="list:longest"
set wildmenu
set wildignore=*.class,*.o,*~,*.pyc,*/target/*

set backspace=eol,start,indent
set magic

set scrolloff=2
set gdefault " set default /g on substitutions

filetype plugin on
filetype plugin indent on
syntax on

" Insert current filename base dir after pressing %% in command mode
cnoremap %% <C-R>=expand('%:h').'/'<cr>

" Create mapping to generate the mapping for running test on current file
" It generates the command :nnoremap <c-z> :!node [spec-file]<cr>
nnoremap <s-z> :nnoremap <c-z> :!node <c-r>=substitute(substitute(expand('%'), "^src", "app", "g"), ".coffee$", ".js", "g")<cr><s-<>cr<s->>

nnoremap \ :CtrlPBuffer<cr>
nnoremap ; :
nnoremap <leader>w :w!<cr>

nnoremap ,, :bp<cr>
nnoremap ,. :bn<cr>

" Create new file in currently opened file's direcotry
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Fix space
nnoremap <space> i<space><esc>l
vnoremap < <gv
vnoremap > >gv

" Setup folding
"set foldmethod=indent
"set foldlevel=99
"set foldenable
nnoremap <leader><f1> :set foldlevel=0<cr>
nnoremap <leader><f2> :set foldlevel=1<cr>
nnoremap <leader><f3> :set foldlevel=2<cr>
nnoremap <leader><f4> :set foldlevel=3<cr>
nnoremap <leader><f5> :set foldlevel=4<cr>
nnoremap <leader><f6> :set foldlevel=6<cr>
nnoremap <leader><f7> :set foldlevel=7<cr>
nnoremap <leader><f8> :set foldlevel=8<cr>
nnoremap <leader><f9> :set foldlevel=999<cr>

" let g:airline#extensions#tabline#enable = 1
""""""""""""""""""""""""""""""""""""""""""""""""
" Setup CTRL-P plugin
""""""""""""""""""""""""""""""""""""""""""""""""
"let g:ctrlp_custom_ignore = 'node_modules'
"let g:ctrlp_custom_ignore = 'app/\|node_modules\|.js$\|.map$'


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
  "set guifont=Monofur\ for\ Powerline\ 13
  set guioptions-=m " Get rid of the menu
  set guioptions-=T " Get rid of the toolbar
  set guioptions-=L " Get rid of the toolbar
  set guioptions-=r " Get rid of the toolbar

  " Map <C-m> to toggle menubar
  nnoremap <C-w>m :if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>

  set cursorline
  set background=dark
  colorscheme solarized

  let g:airline#extensions#tabline#enabled = 1
  let g:airline_powerline_fonts = 1
  let g:Powerline_symbols = 'fancy'

  function! AirlineInit()
    let g:airline_section_a = airline#section#create(['mode', ' ', 'branch'])
    let g:airline_section_b = airline#section#create(['filetype'])
    let g:airline_section_c = airline#section#create(['%t'])
    " let g:airline_section_x = airline#section#create(['%P'])
    let g:airline_section_y = airline#section#create(['%p%%'])
    let g:airline_section_z = airline#section#create(['%l', ' ', '%c'])
  endfunction
  autocmd VimEnter * call AirlineInit()
else
  set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
  set t_Co=256
  set background=dark
  color grb256
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

""""""""""""""""""""""""""""""""""""""""""""""""
" CoffeeScript - switch to alternative file
" switches between coffee / js files
""""""""""""""""""""""""""""""""""""""""""""""""
function! FindMapping(operation)
  let l:path = substitute(substitute(substitute(expand('%'), "^src", "app", "g"), "js$", "map", "g"), "coffee$", "map", "g")
  let l:line = line(".")
  let l:column = col(".")
  "echo "Getting " . a:operation . " position for position " . l:line . "/" . l:column
  let l:out = system("bash sourcemap ". l:path ." ". a:operation ." ". l:line ." ". l:column)
  "echo "Position is " . l:out
  return split(l:out)
endfunction

function! NodeSwitch()
  let l:path = expand('%')
  if match(l:path, "^src/.*coffee$") >= 0
    let l:open = substitute(substitute(l:path, "^src", "app", "g"), ".coffee$", ".js", "g")
    let l:mapping = FindMapping('target')
    exec "e " . l:open
    call cursor(l:mapping[0], l:mapping[1])
  endif
  if match(l:path, "^app/.*js$") >= 0
    let l:open = substitute(substitute(l:path, "^app", "src", "g"), ".js$", ".coffee", "g")
    let l:mapping = FindMapping('source')
    exec "e " . l:open
    call cursor(l:mapping[0], l:mapping[1])
  endif
endfunction

nnoremap <leader>s :call NodeSwitch()<cr>
"nnoremap <leader>s :call FindMapping("target")<cr>

"autocmd BufWritePost *.coffee silent make -m

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TAGS FILE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>tg :!ctags -R --language-force=java -f.tags<cr>

if filereadable(".tags")
  set tags=.tags
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AUTOCMDS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Autocreate java class template
autocmd BufNewFile *.java call InsertJavaPackage()
function! InsertJavaPackage()
  let filename = expand("%")
  let filename = substitute(filename, "\.java$", "", "")
  let dir = getcwd() . "/" . filename
  let dir = substitute(dir, "^.*\/java\/", "", "")
  let dir = substitute(dir, "\/[^\/]*$", "", "")
  let dir = substitute(dir, "\/", ".", "g")
  let filename = substitute(filename, "^.*\/", "", "")
  let dir = "package " . dir . ";"
  let result = append(0, dir)
  let result = append(1, "")
  let result = append(2, "public class " . filename . " {")
  let result = append(4, "}")
endfunction

" Auto trim trailing whitespace on exit
autocmd BufWritePre *.js :%s/\s\+$//e
autocmd BufWritePre *.coffee :%s/\s\+$//e
autocmd BufWritePre *.java :%s/\s\+$//e
autocmd BufWritePre *.jsp :%s/\s\+$//e
autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

autocmd BufWritePost *.coffee silent make! -m

if filereadable("~/.vimrc_local")
  source ~/.vimrc_local
endif

