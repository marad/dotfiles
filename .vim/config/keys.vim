
" Configure common abbreviations (UNPOPULAR!)
cnoreabbrev wqq w<bar>:quit
cnoreabbrev qq :quit
cnoreabbrev wq w<bar>bd
cnoreabbrev q bd

" Save faster!
nnoremap <leader>w :w!<cr>

" Navigate through buffers
nnoremap ,, :bp<cr>
nnoremap ,. :bn<cr>

" Increase/Decrease indent witn < and > keys
vnoremap < <gv
vnoremap > >gv
nnoremap > >>
nnoremap < <<

" Split window navigation
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" Navigate naturally within wrapped lines
nnoremap j gj
nnoremap k gk

" Switch to last opened buffer
nnoremap <c-e> :e#<cr>

" Insert current filename base dir after pressing %% in command mode
cnoremap %% <C-R>=expand('%:h').'/'<cr>

" Open file in current file's direcotry
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Map \ to show opened buffers with ctrlp plugin
nnoremap \ :CtrlPBuffer<cr>

" Toggle NERD Tree plugin
nnoremap <c-\> :NERDTreeToggle<cr>

