" Eclim Keybindings
nnoremap <silent> <buffer> <Leader>i :JavaImport<cr>
nnoremap <silent> <buffer> <Leader>o :JavaImportOrganize<cr>
nnoremap <silent> <buffer> <Leader>d :JavaDocSearch -x declarations<cr>
nnoremap <silent> <buffer> <cr> :JavaSearchContext<cr>
nnoremap <silent> <buffer> <Leader>c :JavaCorrect<cr>
nnoremap <silent> <buffer> <c-f> :%JavaFormat<cr>
nnoremap <silent> <buffer> <F6> :JavaRename<cr>

" Tags file
nnoremap <leader>tg :!ctags -R --language-force=java -f.tags<cr>
if filereadable(".tags")
  set tags=.tags
endif

" Below function doesn't work here because it creates autocmd on a file
" but this config file is read automatically only in Java file type.
" This autocmd should be in .vimrc if it should work

" This should really go into UltiSnips...

" Autocreate java class template
" autocmd BufNewFile *.java call InsertJavaPackage()
" function! InsertJavaPackage()
"   let filename = expand("%")
"   let filename = substitute(filename, "\.java$", "", "")
"   let dir = getcwd() . "/" . filename
"   let dir = substitute(dir, "^.*\/java\/", "", "")
"   let dir = substitute(dir, "\/[^\/]*$", "", "")
"   let dir = substitute(dir, "\/", ".", "g")
"   let filename = substitute(filename, "^.*\/", "", "")
"   let dir = "package " . dir . ";"
"   let result = append(0, dir)
"   let result = append(1, "")
"   let result = append(2, "public class " . filename . " {")
"   let result = append(4, "}")
" endfunction

