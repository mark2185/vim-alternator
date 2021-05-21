" alternator.vim - Alternate C/C++ header/source
" Maintainer: Luka Markušić

if exists('g:loaded_alternator_plugin')
    finish
endif
let g:loaded_alternator_plugin = 1

let g:alternator_header_extensions = get( g:, 'alternator_header_extensions', [ 'h', 'hpp', 'tpp', 'ipp' ] )
let g:alternator_source_extensions = get( g:, 'alternator_source_extensions', [ 'c', 'cpp',              ] )
let g:alternator_blacklist_folders = get( g:, 'alternator_blacklist_folders', [ 'node_modules', '.git'   ] )

command! -nargs=0 Alternate call alternator#alternate()
