" This is Marcin Radoszewski's .vimrc file
" See other dotfiles at https://github.com/marad/dotfiles

" Basic configuration
source ~/.vim/config/base.vim
source ~/.vim/config/keys.vim

" Configure plugins
source ~/.vim/config/plugin/ctrlp.vim
source ~/.vim/config/plugin/emmet.vim
source ~/.vim/config/plugin/eclim.vim
source ~/.vim/config/plugin/neocomplete.vim

" Setup look & feel
if has('gui_running')
    source ~/.vim/config/gui.vim
else
    source ~/.vim/config/terminal.vim
endif

" Install plugins
call pathogen#infect()

" Auto trim trailing whitespace on save
autocmd BufWritePre *.md :%s/\s\+$//e
autocmd BufWritePre *.java :%s/\s\+$//e
autocmd BufWritePre *.js :%s/\s\+$//e
autocmd BufWritePre *.coffee :%s/\s\+$//e
autocmd BufWritePre *.jsp :%s/\s\+$//e
autocmd BufWritePre *.html :%s/\s\+$//e

" Load FileType-specific settings
autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
autocmd FileType java source ~/.vim/config/file_types/java.vim
autocmd FileType markdown source ~/.vim/config/file_types/markdown.vim
autocmd FileType javascript source ~/.vim/config/file_types/javascript.vim
autocmd FileType coffee source ~/.vim/config/file_types/coffee.vim

" Jump to last cursor position unless it's invalid or in an event handler
augroup moveCursorToLastPosition
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \  exe "normal g`\"" |
    \ endif
augroup END

if filereadable("~/.vimrc_local")
  source ~/.vimrc_local
endif

