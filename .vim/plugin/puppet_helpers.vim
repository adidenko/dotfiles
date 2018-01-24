" Puppet functions

" Finds class name and parameters in visual block and returns them as a list
" them as a dict
function! PuppetParams()
  let res = {'class': '', 'params': []}

  " Find class name
  let selection = split(getreg(''), '\n')
  let classnames = map(selection,
        \ 'matchstr(v:val, ''^\s*class\s\+\zs\S\+\ze'')')
  call filter(classnames, '!empty(v:val)')

  " Find parameters
  let selection = split(getreg(''), '\n')
  let pparams = map(selection,
        \ 'matchstr(v:val, ''^\s\+$\zs\S\+\ze'')')
  call filter(pparams, '!empty(v:val)')

  if empty(classnames)
    let res.class = 'EMPTY'
  else
    let res.class = classnames[0]
  endif

  if empty(pparams)
    let res.params = ['EMPTY']
  else
    let res.params = pparams
  endif

  return res
endfunction

" Saves documentation template for list of params in @p register
function! PuppetDoc(pdict)
  let @p = ''
  if empty(a:pdict) | return | endif
  for pp in a:pdict.params
    let tmppp = '# [*' . pp . "*]\n#   Descr\n#\n"
    let @p .= tmppp
  endfor
endfunction

" Saves validation template for list of params in @o register
function! PuppetValidate(pdict)
  let @o = ''
  if empty(a:pdict) | return | endif
  if a:pdict.class == 'EMPTY'
    let cpp = ''
  else
    let cpp = '::' . a:pdict.class . '::'
  endif
  for pp in a:pdict.params
    if pp =~ '_path\|_file\|_dir'
      let tmppp = 'validate_absolute_path($' . cpp . pp . ")\n"
    elseif pp =~ '_ip\|_cidr\|_network'
      let tmppp = 'validate_ip_address($' . cpp . pp . ")\n"
    elseif pp =~ '_list\|_array'
      let tmppp = 'validate_array($' . cpp . pp . ")\n"
    else
      let tmppp = 'validate_string($' . cpp . pp . ")\n"
    endif
    let @o .= tmppp
  endfor
endfunction

" Yank visual block and doc params
function! YankAndDoc()
  return 'y'
        \ . ":call PuppetDoc(PuppetParams())\<CR>"
        \ . ":silent normal! gv\<CR>"
endfunction

" Yank visual block and validate params
function! YankAndValidate()
  return 'y'
        \ . ":call PuppetValidate(PuppetParams())\<CR>"
        \ . ":silent normal! gv\<CR>"
endfunction

" Puppet functions mapping
vnoremap <silent><expr> <c-p> YankAndDoc()
vnoremap <silent><expr> <c-o> YankAndValidate()

