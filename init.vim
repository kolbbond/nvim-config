" vim to neovim transition

" add original vim vimrc path
set runtimepath^=/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" load clipboard
set clipboard+=unnamedplus

" load our lua init
lua require('init')
