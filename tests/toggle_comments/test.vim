" Copyright (c) 2023 hogedamari
" Released under the MIT license
" License notice:
" https:#github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE

let s:test_name = "test_toggle_comment"
let s:sample_code_dir = "sample_codes"

let s:log_file = "test.log"
call writefile([""], s:log_file)
function! s:log_test(msgs)
    call writefile(a:msgs, s:log_file, "a")

    " let l:tty = "/dev/" . system("ps --no-headers -o %y " . getpid())
    " silent call system(printf("echo -e \"%s\" > %s", join(a:msgs, "\n"), l:tty))
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
        call s:log_test([printf("End Test %d", s:cnt_test), "=================================================="])
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

function! s:toggle_comment_and_comp(start_line, n_lines, base_file, ref_file)
    execute(printf("e %s", a:base_file))

    " Move cursor and type normal cmds
    cal cursor(a:start_line, 1)

    if a:n_lines >= 0
        let l:ncmd = printf("v%s", repeat("j", a:n_lines-1))
        execute("normal " . l:ncmd)
    endif

    try
        " see "help: normal"
        execute("normal \<C-_>")
        execute("normal \<esc>")
        execute("w!" . s:wfile)
        execute("e!")
    catch /.*/
        call s:log_test([printf("Error: %s in %s", v:exception, v:throwpoint)])
        return 1
    endtry

    let l:diff_out_raw = system(printf("diff -u --color=never %s %s", s:wfile, a:ref_file))
    let l:diff_out = split(l:diff_out_raw, "\n")
    if v:shell_error != 0
        call s:log_test(["Fail: not match with expected output"]+l:diff_out)
        return 1
    endif

    return 0
endfunction

function! s:test_toggle_comment(start_line, n_lines, base_file, ref_file)
    call s:prep_test_common()
    call s:log_test(["Testing comment out"])
    let l:ret = s:toggle_comment_and_comp(a:start_line, a:n_lines, a:base_file, a:ref_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif

    call s:prep_test_common()
    call s:log_test(["Testing uncomment"])
    let l:ret = s:toggle_comment_and_comp(a:start_line, a:n_lines, a:ref_file, a:base_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif

    call s:post_test_common()
    return 0
endfunction


function! s:test1_visual_same_level_level1()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test1_w_comment.c"
    return s:test_toggle_comment(10, 2, l:base_file, l:ref_file)
endfunction

function! s:test2_visual_same_level_level_gt2()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test2_w_comment.c"
    return s:test_toggle_comment(16, 2, l:base_file, l:ref_file)
endfunction

function! s:test3_visual_diff_level()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test3_w_comment.c"
    return s:test_toggle_comment(15, 3, l:base_file, l:ref_file)
endfunction

function! s:test4_visual_mix()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test4_w_comment.c"
    return s:test_toggle_comment(14, 4, l:base_file, l:ref_file)
endfunction

function! s:test5_visual_no_space()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test5_uncommented.c"

    call s:prep_test_common()
    let l:ret = s:toggle_comment_and_comp(19, 3, l:base_file, l:ref_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif
    return 0
endfunction

function! s:test6_visual_blank_line()
    let l:base_file = s:sample_code_dir . "/c_sample.c"

    call s:prep_test_common()
    let l:ret = s:toggle_comment_and_comp(12, 2, l:base_file, l:base_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif
    return 0
endfunction

function! s:test7_normal_level1()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test7_w_comment.c"
    return s:test_toggle_comment(10, -1, l:base_file, l:ref_file)
endfunction

function! s:test8_normal_level_gt2()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test8_w_comment.c"
    return s:test_toggle_comment(16, -1, l:base_file, l:ref_file)
endfunction

function! s:test9_normal_no_space()
    let l:base_file = s:sample_code_dir . "/c_sample.c"
    let l:ref_file = s:sample_code_dir . "/c_sample_test9_uncommented.c"

    call s:prep_test_common()
    let l:ret = s:toggle_comment_and_comp(19, -1, l:base_file, l:ref_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif
    return 0
endfunction

function! s:test10_normal_blank_line()
    let l:base_file = s:sample_code_dir . "/c_sample.c"

    call s:prep_test_common()
    let l:ret = s:toggle_comment_and_comp(12, -1, l:base_file, l:base_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif
    return 0
endfunction

function! s:test11_unsupported_filetype()
    let l:base_file = s:sample_code_dir . "/text_sample.txt"

    call s:prep_test_common()
    let l:ret = s:toggle_comment_and_comp(5, 3, l:base_file, l:base_file)
    call s:post_test_common()
    if l:ret != 0
        return l:ret
    endif
    return 0
endfunction


" load .vimrc
try
    execute "source " . "../../.vimrc"
    execute "e!"
catch /.*/
    call s:log_test([printf("Error: Failed to load .vimrc at %s: %s", v:exception, v:throwpoint)])
    cq!
endtry

" load plugins
" let s:plug_path = ".vim/plugin/xxx.vim"
" try
"     execute "source " . s:plug_path
" catch /.*/
"     call s:log_test([printf("Error: Failed to load plugin (%s) at %s: %s", plug_path, v:exception, v:throwpoint)])
"     cq!
" endtry

call s:run_testcase("s:test1_visual_same_level_level1", "Toggling comment in same level lines: level1, visual mode")
call s:run_testcase("s:test2_visual_same_level_level_gt2", "Toggling comment in same level lines: level greater than 2, visual mode")
call s:run_testcase("s:test3_visual_diff_level", "Toggling comment in different level lines: visual mode")
call s:run_testcase("s:test4_visual_mix", "Toggling comment in mixed commented and uncommented lines: visual mode")
call s:run_testcase("s:test5_visual_no_space", "Toggling comment in comment line without a single space between comment str and non-whitespace character: visual mode")
call s:run_testcase("s:test6_visual_blank_line", "Toggling comment in blank lines: visual mode")

call s:run_testcase("s:test7_normal_level1", "Toggling comment: level1, normal mode")
call s:run_testcase("s:test8_normal_level_gt2", "Toggling comment: level greater than 2, normal mode")
call s:run_testcase("s:test9_normal_no_space", "Toggling comment in comment line without a single space between comment str and non-whitespace character: normal mode")
call s:run_testcase("s:test10_normal_blank_line", "Toggling comment in blank lines: visual mode")

call s:run_testcase("s:test11_unsupported_filetype", "Toggling comment in unsupported file type")

call s:log_test([printf("PASS: %d", s:pass), printf("FAIL: %d", s:fail)])

if s:fail > 0
    " exit with error status
    cq!
endif

" exit on success
qall!

