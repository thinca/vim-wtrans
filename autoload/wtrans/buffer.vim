" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:BufferManager = vital#wtrans#import('Vim.BufferManager')

let s:managers = {}

if !exists('g:wtrans#buffer#config')
  let g:wtrans#buffer#config = {}
endif

function! wtrans#buffer#init_source() abort
  setlocal buftype=nofile
  setlocal noreadonly nobuflisted nomodeline
endfunction

function! wtrans#buffer#init_result() abort
  setlocal buftype=nofile
  setlocal readonly nomodifiable nobuflisted nomodeline
endfunction

function! wtrans#buffer#open_source(bid, text, options) abort
  let manager = s:get_manager('source/' . a:bid)
  call manager.open('wtrans://source/' . a:bid, g:wtrans#buffer#config)
  if a:text !=# ''
    call s:set_text_to_buffer(a:text)
    doautocmd TextChanged
  endif
endfunction

function! wtrans#buffer#open_result(bid, text) abort
  let cur_win_id = win_getid()
  let manager = s:get_manager('result/' . a:bid)
  call manager.open('wtrans://result/' . a:bid, g:wtrans#buffer#config)
  setlocal noreadonly modifiable
  call s:set_text_to_buffer(a:text)
  setlocal readonly nomodifiable
  call win_gotoid(cur_win_id)
endfunction

function! wtrans#buffer#translate(path) abort
  let bid = matchstr(a:path, '^wtrans://source/\zs.*')
  let text = join(getline(1, '$'), "\n")
  if text !~# '\S'
    return
  endif
  let options = {
  \   'callback': {response -> s:open_response(bid, response)},
  \ }
  call wtrans#translate(text, options)
endfunction

function! s:open_response(bid, response) abort
  if has_key(a:response, 'result')
    let result = a:response.result.resultText
  else
    let result = 'ERROR: ' . string(a:response.error)
  endif
  call wtrans#buffer#open_result(a:bid, result)
endfunction

function! s:get_manager(bid) abort
  if !has_key(s:managers, a:bid)
    let s:managers[a:bid] = s:BufferManager.new()
  endif
  return s:managers[a:bid]
endfunction

function! s:set_text_to_buffer(text) abort
  silent % delete _
  silent 1 put =a:text
  silent 1 delete _
endfunction
