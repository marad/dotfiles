" Convert markdown to HTML
nnoremap <leader>md :%! markdown<cr>
vnoremap <leader>md :%! markdown<cr>

" Reformat paragraph
nnoremap <leader>r vipJ0gqap
"nnoremap <leader>r vipgq
"nnoremap <leader>r gqap

" Check spelling (english)
setlocal spell spelllang=en_us

" Setup proper paragraph auto formatting
"setlocal formatoptions=w2tq tw=100 nosi

" Convert current file to HTML and save to /tmp/markdown.html on save
" autocmd BufWritePost *.md silent ! markdown % > /tmp/markdown.html
