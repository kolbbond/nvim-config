" custom vim config file
" 240127 - 
" 240405 - @hey, move this to nvim?

autocmd FileType vim setlocal fileformat=unix
set fileformat=unix

" set colorscheme
:colorscheme desert
":colorscheme koehler

" line numbers
:set number
:set relativenumber

" to remove auto comment on new line
" :set paste
:set formatoptions-=r
:set formatoptions-=o
:set formatoptions-=cro
autocmd BufNewFile,BufRead * setlocal formatoptions-=r
autocmd BufNewFile,BufRead * setlocal formatoptions-=o

" so we can copy paste from clipboard
if !has('nvim')
:	set clipboard=unnamed
end

" tabstop \t 
:set tabstop=4

" length for TAB and BS
" 0 = tabstop, -1 = shiftwidth
:set softtabstop=0

" length for <<, >>
:set shiftwidth=0

" auto indent
:set autoindent
:set cpoptions+=I

" smart indent
:set smartindent

" language specific plugins
:filetype plugin indent on

" remaps
"		- center line after moving
nnoremap n nzz
nnoremap N Nzz
"nnoremap <S-{> <S-{>zz
"nnoremap <S-}> <S-}>zz
nnoremap { {zz
nnoremap } }zz


" insert and esc
" just map capslock to esc instead
" inoremap <special> jk <esc>2l
" inoremap kj <esc>
" inoremap jj <esc>l
" inoremap kk <esc>l

" remap in command mode
cnoremap <expr> <C-K> wildmenumode() ? '<C-P>' : '<Up>'
cnoremap <expr> <C-J> wildmenumode() ? '<C-N>' : '<Down>'

" remap esc and caps lock
au BufEnter * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
au BufLeave * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Caps_Lock'

autocmd FileType vim setlocal fileformat=unix
set fileformat=unix


