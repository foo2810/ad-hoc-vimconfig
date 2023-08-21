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

" --- Editor Options ---
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
set background=light

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

