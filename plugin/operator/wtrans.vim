" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_operator_wtrans')
  finish
endif
let g:loaded_operator_wtrans = 1

try
  call operator#user#define('wtrans-buffer', 'operator#wtrans#buffer')
  call operator#user#define('wtrans-echomsg', 'operator#wtrans#echomsg')
  call operator#user#define('wtrans-replace', 'operator#wtrans#replace')
catch /^Vim\%((\a\+)\)\=:E117/
  " vim-operator-user not found.
endtry
