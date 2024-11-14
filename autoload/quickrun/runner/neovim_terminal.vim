" quickrun: runner/neovim_terminal: Runs by terminal feature.
" Version: 0.2.0
" Maintainer: Shusui MOYATANI <syusui.s|at|gmail.com>
" License: zlib License
" Original Author: thinca (https://github.com/thinca)
"
" This code is originally from <https://github.com/thinca/vim-quickrun/blob/master/autoload/quickrun/runner/terminal.vim>.

let s:is_win = has('win32')
let s:runner = {
\   'config': {
\     'name': 'default',
\     'opener': 'vnew',
\     'into': 0,
\   },
\ }

let s:wins = {}

function! s:runner.validate() abort
  if !has('nvim')
    throw 'Needs +nvim feature.'
  endif
  if !s:is_win && !executable('sh')
    throw 'Needs "sh" on other than MS Windows.'
  endif
endfunction

function! s:runner.init(session) abort
  let a:session.config.outputter = 'null'
endfunction

function! s:runner.run(commands, input, session) abort
  let command = join(a:commands, ' && ')
  if a:input !=# ''
    let inputfile = a:session.tempname()
    call writefile(split(a:input, "\n", 1), inputfile, 'b')
    let command = printf('(%s) < %s', command, inputfile)
  endif
  let cmd_arg = s:is_win ? printf('cmd.exe /c (%s)', command)
  \                      : ['sh', '-c', command]
  let options = {
  \   'on_exit': self._job_exit_cb,
  \ }

  let self._key = a:session.continue()
  let prev_winid = win_getid()

  let jumped = s:goto_last_win(self.config.name)
  if !jumped
    execute self.config.opener
    let s:wins[self.config.name] += [win_getid()]
  endif
  " use termopen instead of term_start (neovim)
  let self._jobid = termopen(cmd_arg, options)
  let self._bufnr = bufnr('')
  setlocal bufhidden=wipe
  if !self.config.into
    call win_gotoid(prev_winid)
  endif
endfunction

function! s:runner.sweep() abort
  " a job should exist if _jobid exists (neovim)
  if has_key(self, '_jobid')
    while jobwait([self._jobid], 0)[0] == -1
      call jobstop(self._jobid)
    endwhile
    " delete buffer if exist (neovim)
    if bufexists(self._bufnr)
      exec printf('bdelete! %d', self._bufnr)
    endif
  endif
endfunction

function! s:runner._job_exit_cb(jobid, exit_status, event) abort
  if has_key(self, '_job_exited')
    call quickrun#session#call(self._key, 'finish', a:exit_status)
  else
    let self._job_exited = a:exit_status
  endif
endfunction

function s:goto_last_win(name) abort
  if !has_key(s:wins, a:name)
    let s:wins[a:name] = []
  endif

  " sweep
  call filter(s:wins[a:name], 'win_id2tabwin(v:val)[0] != 0')

  for win_id in s:wins[a:name]
    let winnr = win_id2win(win_id)
    if winnr
      call win_gotoid(win_id)
      return 1
    endif
  endfor
  return 0
endfunction

function! quickrun#runner#neovim_terminal#new() abort
  return deepcopy(s:runner)
endfunction
