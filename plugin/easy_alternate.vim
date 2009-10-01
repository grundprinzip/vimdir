" This plugin is a copy and merge from the already existing
" alternate file plugin, but compared to existing one this
" one is much simpler and may not feed your needs. 
"
" Basically it does not work with given search paths, but uses
" the internally VIM function expand to search in directories below as well
"
" The following Key Mappings are defined
"
" A - find alternate
" AT - as above, but in a new tab
" AS - as above, but split horizontally
" AV - as above, but split vertically
"
" In addition there is find alternate file under cursor with the 
" same commands but an I instead of A
"
" If the VIM built in <g-f> does not work for you because the directory
" structure is not usefull for VIM you can use
"
" FUC or FUCT as a replacement. In additon there are shorter 
" mappings defined for
"
" \at for AT
" \an for AN
" \fu for FUCT
"
" Have Fun!
" Martin Grund <grundprinzip@gmail.com>
" September 2009

if exists("loaded_easy_alternate")
    finish
endif

let loaded_easy_alternate = 1
let alternateRelativeFiles = 0
let alternateExtensionsDict = {}

" Add extensions for the files
let alternateExtensionsDict["h"] = "c,cpp,cxx,cc,CC"
let alternateExtensionsDict["c"] = "h"
let alternateExtensionsDict["cpp"] = "h,hpp"

" Function : GetNthItemFromList (PRIVATE)
" Purpose  : Support reading items from a comma seperated list
"            Used to iterate all the extensions in an extension spec
"            Used to iterate all path prefixes
" Args     : list -- the list (extension spec, file paths) to iterate
"            n -- the extension to get
" Returns  : the nth item (extension, path) from the list (extension 
"            spec), or "" for failure
" Author   : Michael Sharpe <feline@irendi.com>
" History  : Renamed from GetNthExtensionFromSpec to GetNthItemFromList
"            to reflect a more generic use of this function. -- Bindu
function! <SID>GetNthItemFromList(list, n) 
   let itemStart = 0
   let itemEnd = -1
   let pos = 0
   let item = ""
   let i = 0
   while (i != a:n)
      let itemStart = itemEnd + 1
      let itemEnd = match(a:list, ",", itemStart)
      let i = i + 1
      if (itemEnd == -1)
         if (i == a:n)
            let itemEnd = strlen(a:list)
         endif
         break
      endif
   endwhile 
   if (itemEnd != -1) 
      let item = strpart(a:list, itemStart, itemEnd - itemStart)
   endif
   return item 
endfunction

" Function : FindOrCreateBuffer (PRIVATE)
" Purpose  : searches the buffer list (:ls) for the specified filename. If
"            found, checks the window list for the buffer. If the buffer is in
"            an already open window, it switches to the window. If the buffer
"            was not in a window, it switches to that buffer. If the buffer did
"            not exist, it creates it.
" Args     : filename (IN) -- the name of the file
"            doSplit (IN) -- indicates whether the window should be split
"                            ("v", "h", "n", "v!", "h!", "n!", "t", "t!") 
"            findSimilar (IN) -- indicate weather existing buffers should be
"                                prefered
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
" History  : + bufname() was not working very well with the possibly strange
"            paths that can abound with the search path so updated this
"            slightly.  -- Bindu
"            + updated window switching code to make it more efficient -- Bindu
"            Allow ! to be applied to buffer/split/editing commands for more
"            vim/vi like consistency
"            + implemented fix from Matt Perry
function! <SID>FindOrCreateBuffer(fileName, doSplit, findSimilar)
  " Check to see if the buffer is already open before re-opening it.
  let FILENAME = escape(a:fileName, ' ')
  let bufNr = -1
  let lastBuffer = bufnr("$")
  let i = 1
  if (a:findSimilar) 
     while i <= lastBuffer
       if <SID>EqualFilePaths(expand("#".i.":p"), a:fileName)
         let bufNr = i
         break
       endif
       let i = i + 1
     endwhile

     if (bufNr == -1)
        let bufName = bufname(a:fileName)
        let bufFilename = fnamemodify(a:fileName,":t")

        if (bufName == "")
           let bufName = bufname(bufFilename)
        endif

        if (bufName != "")
           let tail = fnamemodify(bufName, ":t")
           if (tail != bufFilename)
              let bufName = ""
           endif
        endif
        if (bufName != "")
           let bufNr = bufnr(bufName)
           let FILENAME = bufName
        endif
     endif
  endif

  if (g:alternateRelativeFiles == 1)                                            
        let FILENAME = fnamemodify(FILENAME, ":p:.")
  endif

  let splitType = a:doSplit[0]
  let bang = a:doSplit[1]
  if (bufNr == -1)
     " Buffer did not exist....create it
     let v:errmsg=""
     if (splitType == "h")
        silent! execute ":split".bang." " . FILENAME
     elseif (splitType == "v")
        silent! execute ":vsplit".bang." " . FILENAME
     elseif (splitType == "t")
        silent! execute ":tab split".bang." " . FILENAME
     else
        silent! execute ":e".bang." " . FILENAME
     endif
     if (v:errmsg != "")
        echo v:errmsg
     endif
  else

     " Find the correct tab corresponding to the existing buffer
     let tabNr = -1
     " iterate tab pages
     for i in range(tabpagenr('$'))
        " get the list of buffers in the tab
        let tabList =  tabpagebuflist(i + 1)
        let idx = 0
        " iterate each buffer in the list
        while idx < len(tabList)
           " if it matches the buffer we are looking for...
           if (tabList[idx] == bufNr)
              " ... save the number
              let tabNr = i + 1
              break
           endif
           let idx = idx + 1
        endwhile
        if (tabNr != -1)
           break
        endif
     endfor
     " switch the the tab containing the buffer
     if (tabNr != -1)
        execute "tabn ".tabNr
     endif

     " Buffer was already open......check to see if it is in a window
     let bufWindow = bufwinnr(bufNr)
     if (bufWindow == -1) 
        " Buffer was not in a window so open one
        let v:errmsg=""
        if (splitType == "h")
           silent! execute ":sbuffer".bang." " . FILENAME
        elseif (splitType == "v")
           silent! execute ":vert sbuffer " . FILENAME
        elseif (splitType == "t")
           silent! execute ":tab sbuffer " . FILENAME
        else
           silent! execute ":buffer".bang." " . FILENAME
        endif
        if (v:errmsg != "")
           echo v:errmsg
        endif
     else
        " Buffer is already in a window so switch to the window
        execute bufWindow."wincmd w"
        if (bufWindow != winnr()) 
           " something wierd happened...open the buffer
           let v:errmsg=""
           if (splitType == "h")
              silent! execute ":split".bang." " . FILENAME
           elseif (splitType == "v")
              silent! execute ":vsplit".bang." " . FILENAME
           elseif (splitType == "t")
              silent! execute ":tab split".bang." " . FILENAME
           else
              silent! execute ":e".bang." " . FILENAME
           endif
           if (v:errmsg != "")
              echo v:errmsg
           endif
        endif
     endif
  endif
endfunction

" Function : EqualFilePaths (PRIVATE)
" Purpose  : Compares two paths. Do simple string comparison anywhere but on
"            Windows. On Windows take into account that file paths could differ
"            in usage of separators and the fact that case does not matter.
"            "c:\WINDOWS" is the same path as "c:/windows". has("win32unix") Vim
"            version does not count as one having Windows path rules.
" Args     : path1 (IN) -- first path
"            path2 (IN) -- second path
" Returns  : 1 if path1 is equal to path2, 0 otherwise.
" Author   : Ilya Bobir <ilya@po4ta.com>
function! <SID>EqualFilePaths(path1, path2)
  if has("win16") || has("win32") || has("win64") || has("win95")
    return substitute(a:path1, "\/", "\\", "g") ==? substitute(a:path2, "\/", "\\", "g")
  else
    return a:path1 == a:path2
  endif
endfunction

" Function  : Find the alternate file for the given file
" Author    : Martin Grund <grundprinzip@gmail.com>
function! GetAlternateFile(file_name, how_open)

    let extension = expand(a:file_name. ":e")
    let base_name = expand(a:file_name. ":t:r")

    if (has_key(g:alternateExtensionsDict, extension))

        let ext_spec = g:alternateExtensionsDict[extension]
        let file_list = []

        let n = 1
        let done = 0
        while (!done)
            let ext = <SID>GetNthItemFromList(ext_spec, n)
            if (ext != "")
                " Found an extension, now check if file exists
                let expand_key =  "**/" . base_name . "." . ext
                let current_file = expand(expand_key)
                if (current_file != expand_key)
                    echo current_file
                    call add(file_list, current_file)
                endif
            else
                let done = 1
            endif
            let n = n + 1
        endwhile

        " Check if we have more than one file
        if (len(file_list) == 1)
            call <SID>FindOrCreateBuffer(file_list[0], a:how_open, 1)      
        elseif (len(file_list) == 0)
            echo "Couldn't find alternate file"
        endif
        
    endif
endfunction

function! GetAlternateFileUnderCursor(how_open)
    let cursorFile = expand("<cfile>")
    call GetAlternateFile(cursorFile, a:how_open)
endfunction

function! SimpleFindFileUnderCursor(how_open)
    let expand_key = "**/<cfile>:t"
    let expanded = expand(expand_key)
    if (expanded != expand_key)
        call <SID>FindOrCreateBuffer(expanded, a:how_open)
    else
        echo "Could not find file!"
    endif
endfunction

comm! -nargs=? -bang A call GetAlternateFile("%", "n<bang>")
comm! -nargs=? -bang AT call GetAlternateFile("%", "t<bang>")
comm! -nargs=? -bang AS call GetAlternateFile("%", "h<bang>")
comm! -nargs=? -bang AV call GetAlternateFile("%", "v<bang>")

comm! -nargs=? -bang IH call GetAlternateFileUnderCursor("n<bang>")
comm! -nargs=? -bang IHS call GetAlternateFileUnderCursor("h<bang>")
comm! -nargs=? -bang IHV call GetAlternateFileUnderCursor("v<bang>")
comm! -nargs=? -bang IHT call GetAlternateFileUnderCursor("t<bang>")


comm! -nargs=? -bang FUC call SimpleFindFileUnderCursor("n<bang>")
comm! -nargs=? -bang FUCT call SimpleFindFileUnderCursor("t<bang>")

nmap <Leader>fu :FUCT<CR>
nmap <Leader>at :AT<CR>
nmap <Leader>an :A<CR>
