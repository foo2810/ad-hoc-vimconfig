" Copyright (c) 2023 hogedamari
" Released under the MIT license
" License notice:
" https://github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE

" ======== Vim Configurations ========

" --- Editor Options (global) ---

" Highlight
syntax on
let g:loaded_matchparen = 1

" Filetype
filetype plugin indent on

"  View
set number
set showcmd
set title

" Status Line
set noruler    " disable "ruler"
set laststatus=2
" To get details, type "help statusline" or
" see https://vim-jp.org/vimdoc-ja/options.html#'statusline'
set statusline=%m\ %f\ <%{&filetype}>\ Pos:%l,%v(%p%%)

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


" --- Color Schemes (global) ---
set background=dark

" For syntax highlight in tmux
if &term == "tmux"
    set termguicolors
endif

colorscheme desert
" --- end ---


" --- Misc (global) ---
set writebackup
set swapfile
set wrapscan

set viminfo='100,<50,s10,h,n~/.viminfo

" Remenber last cursor position
augroup post_read
    au!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END
" --- end ---


" --- Key Mapping (global) ---
" Toggle Comments: Map Ctrl + /
vmap <C-_> <esc>`<:call g:Toggle_Comment()<CR>
nmap <C-_> v<esc>`<:call g:Toggle_Comment()<CR>

" Remove trailing blanks: Map Ctrl + L
vmap <C-L> <esc>:call g:Remember_current_pos_visual_mode()<CR>:'<,'>s/\s*$//g<CR>:noh<CR>:call g:Return_remembered_pos("start")<CR>
nmap <C-L> <esc>:call g:Remember_current_pos_visual_mode()<CR>ggv<S-G>:s/\s*$//g<CR>:noh<CR>:call g:Return_remembered_pos("start")<CR>
" --- end ---


" --- Toggle Comments ---
function! g:Toggle_Comment() abort
    " last position of visual mode
    let l:pos_begin = getpos('.')
    let [b:tc_vraw_begin, b:tc_vcol_begin] = [l:pos_begin[1], l:pos_begin[2]]

    " start position of visual mode
    let l:pos_last = getpos("'>")
    let [b:tc_vraw_last, b:tc_vcol_last] = [l:pos_last[1], l:pos_last[2]]

    " move cursor to begin position of visual area
    call cursor(b:tc_vraw_begin, b:tc_vcol_begin)

    let l:n_lines= abs(b:tc_vraw_last - b:tc_vraw_begin + 1)

    " check first non-blank character and kind of the character
    let b:tc_min_col = 1000000000
    let b:tc_uncomment = 1     " uncomment if all lines are comments
    if l:n_lines >= 2
        call feedkeys("_:call g:Toggle_Comment_Iter()\<CR>j\<esc>")
        for i in range(l:n_lines - 2)
            call feedkeys("_:call g:Toggle_Comment_Iter()\<CR>j\<esc>")
        endfor
        call feedkeys("_:call g:Toggle_Comment_Iter()\<CR>\<esc>")
        call feedkeys(":call g:Toggle_Comment_Enditer()\<CR>\<esc>")
    elseif l:n_lines == 1
        call feedkeys("_:call g:Toggle_Comment_Iter()\<CR>j\<esc>")
        call feedkeys(":call g:Toggle_Comment_Enditer()\<CR>\<esc>")
    else
        throw "THIS IS BUG: the number of target lines must be more than 1"
    endif

endfunction

function! g:Toggle_Comment_Iter()
    let l:comment_str_len = strlen(b:comment_str)
    let l:str = getline('.')[col('.')-1:col('.')+l:comment_str_len-1]
    let l:pos = getpos(".")

    " ignore line not include characters without white space
    if getline('.') =~ '^\s*$'
        return
    endif

    " b:comment_str = "//" does not work as expected
    if l:str !~ b:comment_str
        let b:tc_uncomment = 0
    endif

    if exists("b:tc_min_col")
        if l:pos[2] < b:tc_min_col
            let b:tc_min_col = l:pos[2]
        endif
    else
        let b:tc_min_col = l:pos[2]
    endif
endfunction

function! g:Toggle_Comment_Enditer()
    for i in range(b:tc_vraw_begin, b:tc_vraw_last)
        call cursor(i, b:tc_min_col)
        let l:comment_str_len = strlen(b:comment_str)
        let l:cur_line = getline('.')
        let l:str = l:cur_line[col('.')-1:col('.')+l:comment_str_len-1]

        if b:tc_uncomment
            " b:comment_str = "//" does not work as expected
            if l:str =~ b:comment_str
                let l:new_line = substitute(l:cur_line, ''.b:comment_str.'\s\?', '', "")
                call setline(i, l:new_line)
            endif
        else
            call cursor(i, 1)

            " ignore line not include characters without white space
            if getline('.') !~ '^\s*$'
                if b:tc_min_col > 1
                    let l:new_line = l:cur_line[:b:tc_min_col-2] . b:comment_str . " " . l:cur_line[b:tc_min_col-1:]
                elseif b:tc_min_col == 1
                    let l:new_line = b:comment_str . " " . l:cur_line
                else
                    throw "THIS IS BUG: b:tc_min_col must be more than 1 (set comment)"
                endif
                call setline(i, l:new_line)
            endif
        endif
    endfor
    call cursor(b:tc_vraw_last, b:tc_min_col)
endfunction
" --- end ---


" --- Remove trailing blanks ---
function! g:Remember_current_pos_visual_mode() abort
    " last position of visual mode
    let l:pos_begin = getpos('.')
    let [b:rcp_vraw_begin, b:rcp_vcol_begin] = [l:pos_begin[1], l:pos_begin[2]]

    " start position of visual mode
    let l:pos_last = getpos("'>")
    let [b:rcp_vraw_last, b:rcp_vcol_last] = [l:pos_last[1], l:pos_last[2]]
endfunction

function! g:Return_remembered_pos(whence) abort
    if a:whence == "start"
        call cursor(b:rcp_vraw_begin, b:rcp_vcol_begin)
    elseif a:whence == "end"
        call cursor(b:rcp_vraw_last, b:rcp_vcol_last)
    else
        throw "Error: invalid whence, \"" . a:whence . "\""
    endif
endfunction
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

" ======== END ========
