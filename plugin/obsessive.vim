" File:         plugin/obsessive.vim
" Description:  Builds upon vim-obsession, centralising session storage
" Maintainer:   Zaccary Price <https://zaccary.me/>
" Version:      1.0

if exists('g:loaded_obsess') || &compatible
  finish
endif
let g:loaded_obsess = 1

let g:obsessive_dir = '~/.nvim/session'

function! Obsess(bang) abort
  " Obsess!
  if a:bang
    Obsession!
    return
  endif

  " if an existing session is running suspend it
  if !empty(ObsessionStatus())
    Obsession
    return
  endif

  let l:dir = expand('~/.nvim/session/') . fnamemodify(getcwd(), ':t')
  call mkdir(l:dir, 'p')
  execute 'Obsession' fnameescape(l:dir)
endfunction

function! SessionFile() abort
  return expand('~/.nvim/session/') . fnamemodify(getcwd(), ':t') . '/Session.vim'
endfunction

function! SessionRestore() abort
  let l:file = SessionFile()

  if !filereadable(l:file)
    echohl WarningMsg
    echomsg 'No session for ' . fnamemodify(getcwd(), ':t')
    echohl NONE
    return
  endif

  if !empty(filter(getbufinfo({'buflisted': 1}), 'v:val.changed'))
    echohl WarningMsg
    echomsg 'Unsaved changes; not restoring'
    echohl NONE
    return
  endif

  if exists('g:this_obsession')
    Obsession
  endif

  silent! %bwipeout
  execute 'source' fnameescape(l:file)
endfunction

nnoremap <leader>sr :call SessionRestore()<CR>

command! -bang Obsess call Obsess(<bang>0)


" Obsess Airline status
function! ObsessSessionStatus() abort
  if exists('g:this_obsession')
    return '● ' . fnamemodify(g:this_obsession, ':h:t')
  elseif !empty(v:this_session)
    return '◯ ' . fnamemodify(v:this_session, ':h:t')
  endif
  return ''
endfunction

function! s:airline_obsess_init() abort
  if get(s:, 'airline_done', 0)
    return
  endif

  let s:airline_done = 1

  if g:airline#extensions#obsession#enabled == 1
    echohl WarningMsg
    echomsg 'Airline Obsession extension is enabled, this may cause conflicts'
    echohl NONE
  endif


  call airline#parts#define_function('obsess', 'ObsessSessionStatus')
  let g:airline_section_y = airline#section#create_right(['obsess', 'ffenc'])
endfunction

augroup AirlineObsess
  autocmd!
  autocmd User AirlineAfterInit call s:airline_obsess_init()
augroup END

if v:vim_did_enter && exists('*airline#parts#define_function')
  call s:airline_obsess_init()
endif
