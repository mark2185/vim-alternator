" alternator.vim - Alternate C/C++ header/source
" Maintainer: Luka Markušić

let s:old_wildignore = &wildignore

let s:cache = {}

function! s:enumerate( list ) abort
    let l:result = deepcopy( a:list )
    for i in range( 1, len( l:result ) )
        let l:result[ i - 1 ] = printf('%d: %s', i, l:result[ i -  1 ])
    endfor
    return result
endfunction

function! s:updateWildignore() abort
    let s:wildignore = &wildignore
    let l:wildignore_pattern = join( map( deepcopy( g:alternator_blacklist_folders ), { -> printf( "**/%s/**", v:val ) } ), ',' )
    if empty(&wildignore)
        let &wildignore = l:wildignore_pattern
    else
        let &wildignore .= ',' . l:wildignore_pattern
    endif
endfunction

function! alternator#alternate( bang ) abort
    silent call s:updateWildignore()

    "if a:bang
    "    let s:cache = {}
    "endif

    let l:all_extensions = g:alternator_header_extensions + g:alternator_source_extensions

    let l:filename  = expand( '%:t:r' )
    let l:extension = expand( '%:e'   )
    let l:idx = index( l:all_extensions, extension )

    if l:idx < 0
        echom printf('Extension %s not supported', l:extension)
        return
    endif

    " let s:cache[ l:filename ] = {}
    " let s:cache[ l:filename ][ l:extension ] = [ expand("%") ]
    " echom string(s:cache)

    for i in range( l:idx + 1, l:idx + len( l:all_extensions ) - 1 )
        let l:searching_file = printf( '%s.%s', l:filename, l:all_extensions[ i % len( l:all_extensions ) ] )

        " TODO: search buffers too somehow
        " let l:buffer_matches = ?

        let l:matches = findfile( l:searching_file, '**', -1 )
        if !empty( l:matches )
            if len( l:matches ) > 1
                let l:file_index = inputlist( ['Which file do you want to open?'] + s:enumerate( l:matches ) ) - 1
                if l:file_index == -1
                    return
                endif
                if l:file_index < 0 || l:file_index > len( l:matches ) - 1
                    echo "\nIndex out of bounds"
                    return
                endif
            endif

            silent execute 'edit ' . l:matches[ get( l:, 'file_index', 0 ) ]

            let &wildignore = s:wildignore
            return
        endif
    endfor

    echom 'Cannot find a pair for ' . expand( '%:p' )
endfunction
