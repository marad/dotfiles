""""""""""""""""""""""""""""""""""""""""""""""""
" Setup editor
""""""""""""""""""""""""""""""""""""""""""""""""
"set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 11
"set guifont=Monofur\ for\ Powerline\ 13
set guifont=Iosevka\ 12
set guioptions-=m " Get rid of the menu
set guioptions-=T " Get rid of the toolbar
set guioptions-=L " Get rid of the toolbar
set guioptions-=r " Get rid of the toolbar

" Map <C-m> to toggle menubar
nnoremap <C-w>m :if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>

set cursorline
set background=dark
"colorscheme solarized
colorscheme oxeded

"""""""""""""""""""""""""""""""""""""""""""""""
" Setup air-line plugin
""""""""""""""""""""""""""""""""""""""""""""""""
set laststatus=2
let g:airline_powerline_fonts=1

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
