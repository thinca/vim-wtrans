" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if !exists('g:wtrans#command')
  let g:wtrans#command = has('win32') ? 'wtrans.cmd' : 'wtrans'
endif

if !exists('g:wtrans#source_filters')
  let g:wtrans#source_filters = []
endif


function! wtrans#translate(text, ...) abort
  let options = a:0 ? a:1 : {}
  let params = {
  \   'sourceText': a:text,
  \ }
  if has_key(options, 'from')
    let params.fromLang = options.from
  endif
  if has_key(options, 'to')
    let params.toLang = options.to
  endif
  if has_key(options, 'service')
    let params.pageName = options.service
  endif
  if has_key(options, 'callback')
    return wtrans#agent#call('translate', params, options.callback)
  endif

  let id = wtrans#agent#call('translate', params)
  let response = wtrans#agent#read(id)
  if has_key(response, 'result')
    let result = response.result
    return result.resultText
  elseif has_key(response, 'error')
    let e = response.error
    throw printf('wtrans: command error: %d: %s: %s',
    \            e.code, e.message, string(e.data))
  endif
endfunction

function! wtrans#apply_filters(text) abort
  let text = a:text
  for l:Filter in g:wtrans#source_filters
    let text = call(l:Filter, [text])
  endfor
  return text
endfunction
