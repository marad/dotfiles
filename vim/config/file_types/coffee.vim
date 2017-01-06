" Compile CoffeeScript file to JS on save
autocmd BufWritePost *.coffee silent make! -m

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
