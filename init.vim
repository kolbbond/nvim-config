" vim to neovim transition

" add original vim vimrc path
set runtimepath^=/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" load clipboard
set clipboard+=unnamedplus

" highlight Cursor guibg=#000000 ctermbg=black
" highlight Cursor ctermfg=black ctermbg=black cterm=bold guifg=black guibg=yellow gui=bold
" @hey add this to a command in colors
:set cursorline
":highlight CursorLineNr guifg="#000000"
hi Cursor guifg=black guibg=red
set guicursor=n-v-c:block-Cursor/lCursor

" load our lua init
lua require('init')
