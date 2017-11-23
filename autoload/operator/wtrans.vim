" Operators for wtrans
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

function! operator#wtrans#buffer(type) abort
  let result = s:translate_range(a:type)
  call wtrans#buffer#open_result('operator', result)
endfunction

function! operator#wtrans#replace(type) abort
  let result = s:translate_range(a:type)
  call s:set_range(a:type, result)
endfunction

function! operator#wtrans#echomsg(type) abort
  let result = s:translate_range(a:type)
  for line in split(result, "\n")
    echomsg line
  endfor
endfunction

function! s:translate_range(type) abort
  let text = wtrans#apply_filters(s:get_range(a:type))
  echo 'During translation...'
  let result = wtrans#translate(text)
  echo ''
  return result
endfunction

function! s:get_range(type) abort
  let vc = operator#user#visual_command_from_wise_name(a:type)

  let save_sel = &selection
  let save_clipboard = &clipboard
  set selection=inclusive clipboard=

  let save_reg = getreg('"')
  let save_reg_type = getregtype('"')
  execute 'silent normal! `[' . vc . '`]""y'
  let selected = @"
  call setreg('"', save_reg, save_reg_type)

  let &selection = save_sel
  let &clipboard = save_clipboard

  return selected
endfunction

function! s:set_range(type, text) abort
  let vc = operator#user#visual_command_from_wise_name(a:type)

  let save_sel = &selection
  let save_clipboard = &clipboard
  set selection=inclusive clipboard=

  let save_reg = getreg('"')
  let save_reg_type = getregtype('"')
  let @" = a:text
  execute 'silent normal! `[' . vc . '`]p'
  call setreg('"', save_reg, save_reg_type)

  let &selection = save_sel
  let &clipboard = save_clipboard
endfunction
