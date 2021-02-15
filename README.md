# vim-alternator
Alternating between C/C++ source and header files

## Key features
Call `:Alternate` to switch between C/C++ header and source files.

If there are more matching files, it will go in a cycle, e.g. `Core.hpp -> Core.tpp -> Core.c -> Core.cpp`

If you want to change the header extensions, use the `g:alternator_header_extensions` variable.

Same goes for `g:alternator_source_extensions`

Defaults:
```
let g:alternator_header_extensions = [ 'h', 'hpp', 'tpp', 'ipp' ]
let g:alternator_source_extensions = [ 'c', 'cpp' ]
```
