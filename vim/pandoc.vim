" vim functions to run pandoc compilation
" idea from https://github.com/EntilZha/pandoc-viewer
" @hey, add a continue if compile is success and a 
" pause if error

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
    "@hey look at :silent exec "!command"
         execute "!pandoc -s -i " .. s:fpathmd .. " -o " 
                \ .. s:fpathpdf 

    
endfunction
function! PandocCompileLatex()
    silent execute "w"
    silent !clear
    "silent execute "!pandoc -s -i

    " construct our files 
    let s:fpath = split(expand('%:t'), ".tex")
    let s:fpathmd = s:fpath[0] .. '.tex'
    let s:fpathpdf = s:fpath[0] .. '.pdf'
    "let s:fpath = expand('<sfile>:p')

    " debug 
    echo "compiling " .. s:fpathmd .. " to " .. s:fpathpdf

    " pandoc compile
    "@hey look at :silent exec "!command"
         execute "!pandoc -s -i " .. s:fpathmd .. " -o " 
                \ .. s:fpathpdf 

    
endfunction

nnoremap <leader>pc :call PandocCompile()<cr>
nnoremap <leader>pct :call PandocCompileLatex()<cr>
