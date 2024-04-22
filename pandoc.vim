" vim functions to run pandoc compilation
" idea from https://github.com/EntilZha/pandoc-viewer

function! PandocCompile()
    silent execute "w"
    silent !clear
    "silent execute "!pandoc -s -i

    " construct our files 
    let s:fpath = split(expand('%:t'), ".md")
    let s:fpathmd = s:fpath[0] .. '.md'
    let s:fpathpdf = s:fpath[0] .. '.pdf'
    "let s:fpath = expand('<sfile>:p')

    " debug 
    echo "compiling " .. s:fpathmd .. " to " .. s:fpathpdf

    " pandoc compile
    silent execute "!pandoc -s -i " .. s:fpathmd .. " -o " 
                \ .. s:fpathpdf

    
endfunction

nnoremap <leader>pc :call PandocCompile()<cr>
