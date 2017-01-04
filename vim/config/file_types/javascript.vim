" Create mapping to generate the mapping for running test on current file
" It generates the command :nnoremap <c-z> :!node [spec-file]<cr>
nnoremap <s-z> :nnoremap <c-z> :!node <c-r>=substitute(substitute(expand('%'), "^src", "app", "g"), ".coffee$", ".js", "g")<cr><s-<>cr<s->>

