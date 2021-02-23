" alternator.vim - Alternate C/C++ header/source
" Maintainer: Luka Markušić
" Version:    0.0.4

if exists('g:loaded_alternator_plugin')
    finish
endif
let g:loaded_alternator_plugin = 1

let g:alternator_header_extensions = get( g:, 'alternator_header_extensions', [ 'h', 'hpp', 'tpp', 'ipp' ] )
let g:alternator_source_extensions = get( g:, 'alternator_source_extensions', [ 'c', 'cpp',              ] )

command! -nargs=0 Alternate call alternator#alternate()
