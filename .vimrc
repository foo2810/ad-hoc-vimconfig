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
set wildmenu

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

" signcolumn depends on vim v7.4.2201 or newer
" 95ec9d6a6 (tag: v7.4.2201) patch 7.4.2201
" Problem:    The sign column disappears when the last sign is deleted.
" Solution:   Add the 'signcolumn' option. (Christian Brabandt)
if exists("&signcolumn")
    " if signcolumn=yes, then
    " always display sign column (for vim-lsp)
    set signcolumn=no
endif

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
vmap <C-_> <esc>:call g:Toggle_Comment()<CR>
nmap <C-_> v<esc>:call g:Toggle_Comment()<CR>

" Remove trailing blanks: Map Ctrl + L
vmap <C-L> <esc>:call g:Remember_current_pos_visual_mode()<CR>:'<,'>s/\s*$//g<CR>:noh<CR>:call g:Return_remembered_pos("start")<CR>
nmap <C-L> <esc>:call g:Remember_current_pos_visual_mode()<CR>ggv<S-G>:s/\s*$//g<CR>:noh<CR>:call g:Return_remembered_pos("start")<CR>
" --- end ---


" --- Toggle Comments ---
function! g:Toggle_Comment_Pre() abort
    let l:pos_begin = getpos("'<")
    let l:pos_last = getpos("'>")
    let b:tc_row_start = l:pos_begin[1]
    let b:tc_row_end = l:pos_last[1]

    let l:lines = getline(b:tc_row_start, b:tc_row_end)
    let l:comment_str_len = strlen(b:comment_str)

    let b:tc_min_col = 1000000000
    let b:tc_uncomment = 1

    for line_num in range(b:tc_row_start, b:tc_row_end)
        let l:line_idx = line_num - b:tc_row_start
        let l:line = l:lines[l:line_idx]

        " ignore line not include characters without white space
        if l:line =~ '^\s*$'
            continue
        endif

        if b:tc_min_col == 1 && !b:tc_uncomment
            break
        endif

        " matchstrpos() depends on vim v7.4.1685 or newer
        " 7fed5c18f (tag: v7.4.1685) patch 7.4.1685 Problem:
        "    There is no easy way to get all the information about a match.
        "    Solution:   Add matchstrpos(). (Ozaki Kiichi)
        " let l:ret = matchstrpos(l:line, '\S')
        " let l:head_col = l:ret[2]
        " let l:head_idx = l:head_col - 1
        " let l:head = line[l:head_idx:l:head_idx+l:comment_str_len-1]

        let l:head_col = match(l:line, '\S') + 1
        let l:head_idx = l:head_col - 1
        let l:head = l:line[l:head_idx : l:head_idx+l:comment_str_len-1]

        " b:comment_str = "//" does not work as expected
        if l:head !~ b:comment_str
            let b:tc_uncomment = 0
        endif

        if exists("b:tc_min_col")
            if l:head_col < b:tc_min_col
                let b:tc_min_col = l:head_col
            endif
        else
            let b:tc_min_col = l:head_col
        endif
    endfor
endfunction

function! g:Toggle_Comment_Uncomment() abort
    " execute() depends on vim v7.4.2008 or newer
    " 79815f1ec (tag: v7.4.2008) patch 7.4.2008
    " Problem:    evalcmd() has a confusing name.
    " Solution:   Rename to execute().  Make silent optional.  Support a list of commands.
    " call execute("". b:tc_row_start . "," . b:tc_row_end . 's/^\(\s*\)' . escape(b:comment_str, '/') . '\s\?/\1/g')

    execute printf('%d,%ds/^\(\s*\)\(%s\)\?\s\?/\1/', b:tc_row_start, b:tc_row_end, escape(b:comment_str, '^$.*[]/~\'))

endfunction

function! g:Toggle_Comment_Comment() abort
    let l:lines = getline(b:tc_row_start, b:tc_row_end)

    for line_num in range(b:tc_row_start, b:tc_row_end)
        let l:cur_line = l:lines[line_num-b:tc_row_start]

        " ignore line not include characters without white space
        if l:cur_line =~ '^\s*$'
            continue
        endif

        if b:tc_min_col > 1
            let l:new_line = printf("%s%s %s", l:cur_line[:b:tc_min_col-2], b:comment_str, l:cur_line[b:tc_min_col-1:])
        elseif b:tc_min_col == 1
            let l:new_line = printf("%s %s", b:comment_str, l:cur_line)
        else
            throw "THIS IS BUG: b:tc_min_col must be more than 1 (set comment)"
        endif
        call setline(l:line_num, l:new_line)
    endfor
endfunction

function! g:Toggle_Comment() abort
    if !exists("b:comment_str")
        echo "Not supported file type"
        return
    endif

    call g:Toggle_Comment_Pre()

    if b:tc_uncomment
        call g:Toggle_Comment_Uncomment()
    else
        call g:Toggle_Comment_Comment()
    endif
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
    au FileType cpp call s:set_config_c()
    au FileType rust call s:set_config_rust()
    au FileType python call s:set_config_python()
    au FileTYpe make call s:set_config_make()
    au FileTYpe sh call s:set_config_sh()
    au FileTYpe perl call s:set_config_perl()
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

function! s:set_config_rust()
    setlocal expandtab
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
    setlocal noexpandtab
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

function! s:set_config_perl()
    setlocal noexpandtab
    setlocal tabstop=4
    setlocal shiftwidth=4

    let b:comment_str = "#"
endfunction
"  --- end ---

" ======== END ========
