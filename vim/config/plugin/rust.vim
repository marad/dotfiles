" Vim Rust Plugin
let g:rustfmt_autosave = 1

" Racer Rust Plugin
let g:racer_experimental_completer = 1
let g:racer_insert_paren = 1
"let g:racer_cmd = "/usr/bin/racer"

au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
au FileType rust nmap K <Plug>(rust-doc)
