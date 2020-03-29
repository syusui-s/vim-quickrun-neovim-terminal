" quickrun: runner/neovim_terminal: Runs by terminal feature.
" Version: 0.1.0
" Maintainer: Shusui MOYATANI <syusui.s|at|gmail.com>
" License: zlib License
" Original Author: thinca (https://github.com/thinca)
"
" This code is originally from <https://github.com/thinca/vim-quickrun/blob/master/autoload/quickrun/runner/terminal.vim>.

let s:VT = g:quickrun#V.import('Vim.ViewTracer')

let s:is_win = g:quickrun#V.Prelude.is_windows()
let s:runner = {
\   'config': {
\     'opener': 'vnew',
\     'into': 0,
\   },
\ }


function! s:runner.validate() abort
  if !has('nvim')
    throw 'Needs +terminal feature.'
  endif
  if !s:is_win && !executable('sh')
    throw 'Needs "sh" on other than MS Windows.'
  endif
endfunction

function! s:runner.init(session) abort
  let a:session.config.outputter = 'null'
endfunction

function! s:runner.run(commands, input, session) abort
  let cmd = join(a:commands, ' && ')
  if a:input !=# ''
    let inputfile = a:session.tempname()
    call writefile(split(a:input, "\n", 1), inputfile, 'b')
    let cmd = printf('(%s) < %s', cmd, inputfile)
  endif
  let cmd_arg = s:is_win ? printf('cmd.exe /c (%s)', cmd)
  \                      : ['sh', '-c', cmd]
  let options = {
  \   'on_exit': self._job_on_exit,
  \ }

  let self._key = a:session.continue()
  let prev_window = s:VT.trace_window()
  execute self.config.opener
  let self._jobid = termopen(cmd_arg, options)
  let self._bufnr = bufnr('')
  if !self.config.into
    call s:VT.jump(prev_window)
  endif
endfunction

function! s:runner.sweep() abort
  " a job should exist if _jobid exists
  if has_key(self, '_jobid')
    while jobwait([self._jobid], 0)[0] == -1
      call jobstop(self._jobid)
    endwhile
    if bufexists(self._bufnr)
      exec printf('bdelete! %d', self._bufnr)
    endif
  endif
endfunction

function! s:runner._job_on_exit(jobid, exit_status, event) abort
  if has_key(self, '_job_exited')
    call quickrun#session(self._key, 'finish', a:exit_status)
  else
    let self._job_exited = a:exit_status
  endif
endfunction

function! quickrun#runner#neovim_terminal#new() abort
  return deepcopy(s:runner)
endfunction
