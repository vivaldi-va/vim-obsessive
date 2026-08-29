" File:         plugin/obsessive.vim
" Description:  Builds upon vim-obsession, centralising session storage
" Maintainer:   Zaccary Price <https://zaccary.me/>
" Version:      1.0

if exists('g:loaded_obsess') || &compatible
  finish
endif
let g:loaded_obsess = 1

function! s:obsessive_normalise_dir(dir)
  return substitute(a:dir, '/\?$', '/', '')
endfunction

function! s:get_root()
  return fnamemodify(getcwd(), ':t')
endfunction

function! s:get_dir()
  let l:dir = s:obsessive_normalise_dir(expand(g:obsessive#dir)) . fnamemodify(getcwd(), ':t')
  return l:dir
endfunction

function! s:remove_session_dir(session) abort
  if empty(a:session)
    return
  endif

  let l:dir = fnamemodify(a:session, ':p:h')
  let l:root = s:obsessive_normalise_dir(expand(g:obsessive#dir))

  " Refuse to touch anything outside the session root.
  if stridx(l:dir . '/', l:root) != 0 || l:dir . '/' ==# l:root
    return
  endif

  if delete(l:dir, 'd') != 0
    echohl WarningMsg
    echomsg 'obsessive: kept ' . l:dir . ' (not empty)'
    echohl NONE
  endif
endfunction


function! Obsess(bang) abort
  " Obsess!
  if a:bang
    let l:session = get(g:, 'this_obsession', v:this_session)
    silent! Obsession!
    let v:this_session = ''
    call s:remove_session_dir(l:session)
    echo 'Obsession session removed: ' . s:get_root()
    return
  endif

  " if an existing session is running suspend it
  if !empty(ObsessionStatus())
    silent! Obsession
    echo 'Obsession session paused: ' . s:get_root()
    return
  endif

  let l:dir = s:get_dir()
  call mkdir(l:dir, 'p')
  let l:file = SessionFile()

  if filereadable(l:file)
    call SessionRestore()
    return
  endif

  silent! execute 'Obsession' fnameescape(l:dir)
  echo 'Starting obsession session for: ' . s:get_root()
endfunction

function! SessionFile() abort
  let l:dir = s:get_dir()
  return l:dir . '/Session.vim'
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
    echohl WarningMsg
    echo 'Session already exists for ' . s:get_root()
    echohl NONE
    return
  endif

  silent! %bwipeout
  execute 'source' fnameescape(l:file)
  echo 'Session restored: ' . s:get_root()
endfunction


command! -bang Obsess call Obsess(<bang>0)
command! ObsessRestore call SessionRestore()
nnoremap <leader>sr :call SessionRestore()<CR>


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

if g:obsessive#airline_enabled == 1
  augroup AirlineObsess
    autocmd!
    autocmd User AirlineAfterInit call s:airline_obsess_init()
  augroup END

  if v:vim_did_enter && exists('*airline#parts#define_function')
    call s:airline_obsess_init()
  endif
endif
