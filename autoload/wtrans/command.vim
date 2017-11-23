" Translate via wtrans command
" Version: 1.0.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:Dict = vital#wtrans#import('Data.Dict')
let s:OptionParser = vital#wtrans#import('OptionParser')
let s:parser = s:OptionParser.new()
call s:parser.on('--from=LANG', 'Specify language of source text')
call s:parser.on('--to=LANG', 'Specify language of result text')
call s:parser.on('--service=SERVICE', 'Specify a service to translate')
call s:parser.on(
\   '--output=PLACE',
\   'Specify the place to output a result [echomsg|buffer]',
\   'echomsg'
\ )

let s:bid = 0

function! wtrans#command#execute(arg, range, start_line, end_line, bang) abort
  let args = s:parser.parse(a:arg)
  if a:range
    let lines = getline(a:start_line, a:end_line)
    let text = wtrans#apply_filters(join(lines, "\n"))
  else
    let text = join(args.__unknown_args__, ' ')
  endif

  let options = s:Dict.pick(args, ['from', 'to', 'service'])

  if a:bang
    call wtrans#agent#stop()
  endif

  if args.output ==# 'echomsg'
    let result = wtrans#translate(text, options)
    for line in split(result, "\n")
      echomsg line
    endfor
  elseif args.output ==# 'buffer'
    let result = wtrans#translate(text, options)
    call wtrans#buffer#open_result('command', result)
  elseif args.output ==# 'interactive'
    let s:bid += 1
    call wtrans#buffer#open_source(s:bid, text, options)
  endif
endfunction

function! wtrans#command#complete(arglead, cmdline, cursorpos) abort
  return s:parser.complete(a:arglead, a:cmdline, a:cursorpos)
endfunction
