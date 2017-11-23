" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_wtrans')
  finish
endif
let g:loaded_wtrans = 1

if exists('g:wtrans#preload') && g:wtrans#preload
  call wtrans#agent#get()
endif

command! -range=0 -nargs=* -bang -complete=customlist,wtrans#command#complete
\   Wtrans call wtrans#command#execute(<q-args>, <count>, <line1>, <line2>, <bang>0)

augroup plugin-wtrans
  autocmd!
  autocmd BufReadCmd wtrans://source/* call wtrans#buffer#init_source()
  autocmd BufReadCmd wtrans://result/* call wtrans#buffer#init_result()
  autocmd TextChanged,InsertLeave,CursorHoldI wtrans://source/*
  \       call wtrans#buffer#translate(expand('<amatch>'))
augroup END
