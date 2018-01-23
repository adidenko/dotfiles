" Use different colorschemes for vim and vimdiff
set background=dark
if &diff
  " Use special diff scheme
  colorscheme diff
else
  " Use the Solarized Dark theme
  colorscheme solarized
endif
let g:solarized_termtrans=1

" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
" set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Make tabs as wide as two spaces
set tabstop=2
" Show “invisible” characters
" set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
" set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
" set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
" if exists("&relativenumber")
" 	set relativenumber
" 	au BufReadPost * set relativenumber
" endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

" Highlight trailing whitespaces
highlight ExtraWhitespace ctermbg=lightred guibg=lightred
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
filetype plugin indent on

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

" Saves validation template for list of params in @p register
function! PuppetValidate(pdict)
  let @p = ''
  if empty(a:pdict) | return | endif
  for pp in a:pdict.params
    if pp =~ '_path\|_file\|_dir'
      let tmppp = 'validate_absolute_path($::' . a:pdict.class . '::' . pp . ")\n"
    elseif pp =~ '_ip\|_cidr\|_network'
      let tmppp = 'validate_ip_address($::' . a:pdict.class . '::' . pp . ")\n"
    elseif pp =~ '_list\|_array'
      let tmppp = 'validate_array($::' . a:pdict.class . '::' . pp . ")\n"
    else
      let tmppp = 'validate_string($::' . a:pdict.class . '::' . pp . ")\n"
    endif
    let @p .= tmppp
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
nmap     <silent>       <c-p> vip<c-p><esc>

vnoremap <silent><expr> <c-o> YankAndValidate()
nmap     <silent>       <c-o> vip<c-o><esc>

