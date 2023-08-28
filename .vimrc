" Copyright (c) 2023 hogedamari
" Released under the MIT license
" License notice:
" https://github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE

" Vim Configurations
" ==================

" --- Highlight ---
syntax on
let g:loaded_matchparen = 1
" --- end ---

" Filetype
filetype plugin indent on

set number
set showcmd
set title

" Status Line
set noruler    " disable "ruler"
set laststatus=2
" To get details, type "help statusline" or 
" see https://vim-jp.org/vimdoc-ja/options.html#'statusline'
set statusline=%m\ %f\ Pos:%l,%v(%p%%) 

" Tab
set expandtab
set tabstop=4
set shiftwidth=4

" Indent
set smartindent
set autoindent

set textwidth=0

" c.f. https://qiita.com/qtamaki/items/4da4ead3f2f9a525591a
set hidden

" if signcolumn=yes, then
" always display sign column (for vim-lsp)
set signcolumn=no

" https://vi.stackexchange.com/questions/2162/why-doesnt-the-backspace-key-work-in-insert-mode
set backspace=indent,eol,start
" --- end ---


" --- Color Schemes ---
set background=dark

" For syntax highlight in tmux
if &term == "tmux"
    set termguicolors
endif 

colorscheme desert
" --- end ---


" --- Misc ---
set writebackup
set swapfile
set wrapscan

set viminfo='100,<50,s10,h,n~/.viminfo
" Remenber last cursor position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" --- end ---


" --- Key Mapping ---
" --- end ---


" --- per-filetyep config ---
" overwrite global settings
augroup per_file_type_config
    au!
    au FileType vim call s:set_config_vim()
    au FileType c call s:set_config_c()
    au FileType python call s:set_config_python()
    au FileTYpe make call s:set_config_make()
    au FileTYpe sh call s:set_config_sh()
augroup END

function! s:set_config_vim()
    setlocal expandtab
    setlocal tabstop=4
    setlocal shiftwidth=4

    let b:comment_str = "\""
endfunction

function! s:set_config_c()
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4

    let b:comment_str = "//"
endfunction

function! s:set_config_python()
    setlocal expandtab
    setlocal tabstop=4
    setlocal shiftwidth=4

    let b:comment_str = "#"
endfunction

function! s:set_config_make()
    setlocal expandtab
    setlocal tabstop=4
    setlocal shiftwidth=4

    let b:comment_str = "#"
endfunction

function! s:set_config_sh()
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4

    let b:comment_str = "#"
endfunction
"  --- end ---
