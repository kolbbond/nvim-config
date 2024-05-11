" vim to neovim transition

" add original vim vimrc path
set runtimepath^=/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
"echo "test"

" load clipboard
set clipboard+=unnamedplus

" load our lua init
lua require('init')

" sourcing here does not run the commands?
" @hey, what's up with that?
source ~/.config/nvim/vim/colors.vim
source ~/.config/nvim/vim/pandoc.vim

" highlight stuff
" :set cursorline
":hi Cursor guifg=black guibg=red
" :set guicursor=n-v-c:block-Cursor/lCursor

