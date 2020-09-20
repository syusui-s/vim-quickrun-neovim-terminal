vim-quickrun-neovim-terminal: neovim terminal runner plugin
===

A [vim-quickrun](https://github.com/thinca/vim-quickrun) runner plugin
which enable you to run a program with [neovim's terminal feature](https://neovim.io/doc/user/nvim_terminal_emulator.html).

* Interacitive
    * can give inputs to running program.
* Asynchronous running
    * can edit a code while running.

config
---

* `runner/neovim_terminal/opener`
    * terminal buffer will be created with this  (default: vnew, see `|opening-window|`)
* `runner/neovim_terminal/into`
    * switch into terminal buffer if true. (0 to false, 1 to true, default: 0)

Example:

```vim
let g:quickrun_config = {}

" Global default
let g:quickrun_config._ = {
  \ 'runner': 'neovim_terminal',
  \ 'runner/neovim_terminal/opener': 'vnew',
  \ }
```

TODO
---
* [ ] Set buffer title

LICENSE
---
zlib license
