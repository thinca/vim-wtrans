" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

function! wtrans#agent#is_running() abort
  return exists('s:wtrans_job') && job_status(s:wtrans_job) ==# 'run'
endfunction

function! wtrans#agent#get() abort
  if !exists('s:wtrans_job')
    call s:init_job()
  endif
  return s:wtrans_job
endfunction

function! wtrans#agent#stop() abort
  if wtrans#agent#is_running()
    call job_stop(s:wtrans_job)
  endif
  unlet! s:wtrans_job
endfunction

function! wtrans#agent#call(method, params, ...) abort
  let job = wtrans#agent#get()
  let id = s:next_id()
  let request = {
  \   'jsonrpc': '2.0',
  \   'id': id,
  \   'method': a:method,
  \   'params': a:params,
  \ }
  let s:sending_requests[id] = request
  if a:0
    let s:callbacks[id] = a:1
  endif
  call ch_sendraw(job, json_encode(request) . "\n")
  return id
endfunction

function! wtrans#agent#_errors() abort
  return s:errors
endfunction

function! wtrans#agent#read(id) abort
  if has_key(s:buffered_messages, a:id)
    return remove(s:buffered_messages, a:id)
  endif
  call s:validate_job()
  if !has_key(s:sending_requests, a:id)
    throw 'wtrans: A request has not sent: ' . a:id
  endif
  while 1
    let line = ch_readraw(s:wtrans_job, {'timeout': 10000})
    let response = s:receive_message(line, 0)
    if response.id == a:id
      return response
    endif
  endwhile
endfunction

function! s:next_id() abort
  let s:current_id += 1
  return s:current_id
endfunction

function! s:init_job() abort
  let s:current_id = 0
  let s:buffered_messages = {}
  let s:sending_requests = {}
  let s:callbacks = {}
  let s:errors = []
  let s:wtrans_job = job_start(
  \   [g:wtrans#command, '--interactive', '--protocol', 'json'],
  \   {
  \     'mode': 'nl',
  \     'timeout': 10000,
  \     'out_cb': function('s:on_out'),
  \     'err_cb': function('s:on_err'),
  \     'exit_cb': function('s:on_exit'),
  \   }
  \ )
endfunction

function! s:on_out(_ch, message) abort
  call s:receive_message(a:message, 1)
endfunction

function! s:on_err(_ch, message) abort
  call add(s:errors, a:message)
endfunction

function! s:on_exit(_job, _status) abort
  unlet! s:wtrans_job
endfunction

function! s:receive_message(message, buffering) abort
  let response = json_decode(a:message)
  call remove(s:sending_requests, response.id)
  " TODO: Error JSON
  if has_key(s:callbacks, response.id)
    call s:callbacks[response.id](response)
  elseif a:buffering
    let s:buffered_messages[response.id] = response
  endif
  return response
endfunction

function! s:validate_job() abort
  if !wtrans#agent#is_running()
    throw 'wtrans: Agent is not running'
  endif
endfunction
