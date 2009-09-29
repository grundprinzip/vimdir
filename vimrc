filetype plugin on
filetype indent on

let g:Tex_ViewRule_ps = ''
let g:Tex_ViewRule_pdf = ''
let g:Tex_ViewRule_dvi = ''

let g:Tex_UseMakefile = 0

let g:tex_flavor='latex'

set gfn=Inconsolaita:h14.00

" Completion Settings
filetype on
filetype plugin on
set nocp
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#CompleteCpp

"set tags+=~/.vim/tags/cpp
"set tags+=~/.vim/tags/boost

" build tags of your own project with CTRL+F12
map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_MayCompleteDot = 1
let OmniCpp_MayCompleteArrow = 1
let OmniCpp_MayCompleteScope = 1
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

" The Window Size
set lines=50
set columns=90

syntax on
set number
set ts=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
" Tell vim to remember certain things when we exit
"  '10 : marks will be remembered for up to 10 previously edited files
"  "100 : will save up to 100 lines for each register
"  :20 : up to 20 lines of command-line history will be remembered
"  % : saves and restores the buffer list
"  n... : where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

" when we reload, tell vim to restore the cursor to the saved position
augroup JumpCursorOnEdit
 au!
  autocmd BufReadPost *
   \ if expand("<afile>:p:h") !=? $TEMP |
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
     \ let JumpCursorOnEdit_foo = line("'\"") |
      \ let b:doopenfold = 1 |
       \ if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
        \ let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
         \ let b:doopenfold = 2 |
          \ endif |
           \ exe JumpCursorOnEdit_foo |
            \ endif |
             \ endif
              " Need to postpone using "zv" until after reading the modelines.
               autocmd BufWinEnter *
                \ if exists("b:doopenfold") |
                 \ exe "normal zv" |
                  \ if(b:doopenfold > 1) |
                   \ exe "+".1 |
                    \ endif |
                     \ unlet b:doopenfold |
                      \ endif
                      augroup END
" Make sure by default search is incasesensitve
set ignorecase
set smartcase
set incsearch
