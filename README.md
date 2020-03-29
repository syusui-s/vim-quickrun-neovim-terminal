vim-quickrun-neovim-terminal: Quickrun runner plugin for neovim terminal
===

This is a [thinca/vim-quickrun](https://github.com/thinca/vim-quickrun) runner plugin
which supports [neovim's terminal feature](https://neovim.io/doc/user/nvim_terminal_emulator.html).

* You can give some inputs to a running program because the neovim terminal is interactive.
* You can edit a code while running because the neovim terminal is asynchronous.

config
---

* opener: terminal buffer will be created with this  (default: vnew, see `|opening-window|`)
* into: switch into terminal buffer if true. (0 to false, 1 to true, default: 0)


TODO
---
* [ ] Set buffer title

LICENSE
---
zlib license
