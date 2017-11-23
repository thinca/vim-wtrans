" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

function! wtrans#filter#split_a_word(text) abort
  if a:text =~# '\_s'
    return a:text
  endif
  let s = a:text
  let s = substitute(s, '\(\l\)\(\u\)', '\1 \2', 'g')
  let s = substitute(s, '[_-]', ' ', 'g')
  let s = substitute(s, '\u\{2,}', '\0 ', 'g')
  let s = substitute(s, '\s\+', ' ', 'g')
  let s = substitute(tolower(s), '^\s*\|\s*$', '', 'g')
  let s = substitute(s, '[^.]\zs\n', '', 'g')
  return s
endfunction

function! wtrans#filter#shrink_whitespace(text) abort
  return substitute(a:text, '\_[[:space:]]\+', ' ', 'g')
endfunction

function! wtrans#filter#remove_commentstring(text) abort
  if empty(&l:commentstring)
    return a:text
  endif
  let comment = printf('\V' . &l:commentstring, '\v(.{-})\V')
  return substitute(a:text, comment, '\1', 'g')
endfunction

function! wtrans#filter#remove_help_marks(text) abort
  if &filetype ==# 'help'
    return substitute(a:text, '[*|]', '', 'g')
  endif
  return a:text
endfunction
