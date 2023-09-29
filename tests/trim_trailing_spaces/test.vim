" Copyright (c) 2023 hogedamari
" Released under the MIT license
" License notice:
" https:#github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE

let s:test_name = "test_trim_trailing_spaces"
let s:sample_code_dir = "sample_codes"

let s:log_file = "test.log"
call writefile([""], s:log_file)
function! s:log_test(msgs)
    call writefile(a:msgs, s:log_file, "a")
endfunction

let s:pass = 0
let s:fail = 0
let s:cnt_test = 0
function! s:run_testcase(test_func_name, test_desc)
    try
        let s:cnt_test = s:cnt_test + 1
        call s:log_test([printf("Test %d: %s", s:cnt_test, a:test_desc)])
    catch /.*/
        call s:log_test(["Error(run_testcase): ".v:exception." in ".v:throwpoint])
    endtry

    let l:test_status = -1
    try
        let l:test_status = eval(printf("%s()", a:test_func_name))
    catch /.*/
        call s:log_test(["Error(run_testcase): "."uncaught exception, ".v:exception." in ".v:throwpoint])
    endtry

    if l:test_status == 0
        let s:pass = s:pass + 1
        call s:log_test(["Status: PASS"])
    else
        let s:fail = s:fail + 1
        call s:log_test(["Status: FAIL"])
    endif

    try
        call s:log_test([
            \ printf("End Test %d", s:cnt_test),
            \ "=================================================="
            \ ])
    catch /.*/
        call s:log_test(["Error(run_testcase): ".v:exception." in ".v:throwpoint])
    endtry
endfunction

let s:wfile = "test.out"
function! s:prep_test_common()
    set nomore
    set noswapfile
    execute("%bdelete")
endfunction

function! s:post_test_common()
    call system(printf("rm -f %s", s:wfile))
endfunction

function! s:trim_trailing_spaces_and_comp(test_id, start_line, n_lines, base_file, ref_file)
    execute(printf("e %s", a:base_file))

    " Move cursor and type normal cmds
    cal cursor(a:start_line, 1)

    if a:n_lines >= 0
        let l:ncmd = printf("v%s", repeat("j", a:n_lines-1))
        execute("normal " . l:ncmd)
    endif

    try
        " see "help: normal"
        execute("normal \<C-L>")
        execute("normal \<esc>")
        execute("w!" . s:wfile)
        execute("e!")
    catch /.*/
        call s:log_test([printf("Error(test%d): %s in %s", a:test_id, v:exception, v:throwpoint)])
        return 1
    endtry

    let l:diff_out = system(printf("diff -u --color=never %s %s",
        \ s:wfile,
        \ a:ref_file
        \ ))
    let l:diff_out = split(l:diff_out, "\n")
    if v:shell_error != 0
        call s:log_test([printf("Fail(test%d): diff fail", a:test_id)]+l:diff_out)
        return 1
    endif

    return 0
endfunction

function! s:test_trim_trailing_spaces(test_id, start_line, n_lines, base_file, ref_file)
    call s:prep_test_common()
    call s:log_test(["Testing triming trailing spaces"])
    let l:ret = s:trim_trailing_spaces_and_comp(a:test_id, a:start_line, a:n_lines, a:base_file, a:ref_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif

    return 0
endfunction


function! s:test1_entire_file()
    let l:base_file = s:sample_code_dir . "/text_sample.txt"
    let l:ref_file = s:sample_code_dir . "/text_sample_test1.txt"
    return s:test_trim_trailing_spaces(1, 1, -1, l:base_file, l:ref_file)
endfunction

function! s:test2_visual_multiple_lines()
    let l:base_file = s:sample_code_dir . "/text_sample.txt"
    let l:ref_file = s:sample_code_dir . "/text_sample_test2.txt"
    return s:test_trim_trailing_spaces(2, 2, 9, l:base_file, l:ref_file)
endfunction

function! s:test3_visual_single_line()
    let l:base_file = s:sample_code_dir . "/text_sample.txt"
    let l:ref_file = s:sample_code_dir . "/text_sample_test3.txt"
    return s:test_trim_trailing_spaces(3, 4, 1, l:base_file, l:ref_file)
endfunction

" function! s:test4_normal_single_line()
"     let l:base_file = s:sample_code_dir . "/text_sample.txt"
"     let l:ref_file = s:sample_code_dir . "/text_sample_test4.txt"
"     return s:test_trim_trailing_spaces(4, 4, ?, l:base_file, l:ref_file)
" endfunction


call s:run_testcase("s:test1_entire_file", "Trim trailing spaces for an entire file")
call s:run_testcase("s:test2_visual_multiple_lines", "Trim trailing spaces in selected multiple lines in visual mode")
call s:run_testcase("s:test3_visual_single_line", "Trim trailing spaces in selected single line in visual mode")
" call s:run_testcase("s:test4_normal_single_line", "")

call s:log_test([printf("PASS: %d", s:pass), printf("FAIL: %d", s:fail)])

if s:fail > 0
    " exit with error status
    cq!
endif

" exit on success
qall!

