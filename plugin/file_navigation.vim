" Author: Martin Grund <grundprinzip@gmail.com> 
" Version: 1

if (exists("g:loaded_file_navigation") && g:loaded_file_navigation)
    finish
endif

let g:loaded_file_navigation = 1

" Store the list of opened files in prev direction
" for later usage in forward nav
let g:file_nav_list = []
let g:current_idx = -1

function! GetPreviousFile()

    let highest = histnr("cmd")
    let current = ""

    " Find the next entry that starts with e
    while highest > 0 
        let current = histget("cmd", highest)
        
        if stridx(current, "e ") == 0  && current != 'e ' . bufname('%')
            break
        endif
        let highest -= 1
    endwhile

    " Now execute this again

    call insert(g:file_nav_list, 'e '.bufname('%'))
    call histdel("cmd", highest)
    execute current
endfunction

function! GetNextFile()
    if len(g:file_nav_list) > 0
        let current = remove(g:file_nav_list, -1)
        call histadd("cmd", current)
        execute current
    endif
endfunction


" Map the good keys
nmap <silent> \b :call GetPreviousFile()<CR>
nmap <silent> \n :call GetNextFile()<CR>
