" alternator.vim - Alternate C/C++ header/source
" Maintainer: Luka Markušić

let s:old_wildignore = &wildignore

function! s:enumerate( list ) abort
    let l:result = deepcopy( a:list )
    for i in range( 1, len( l:result ) )
        let l:result[ i - 1 ] = printf( '%d: %s', i, l:result[ i -  1 ] )
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

function! alternator#alternate() abort
    silent call s:updateWildignore()

    let l:all_extensions = g:alternator_header_extensions + g:alternator_source_extensions

    let l:filename  = expand( '%:t:r' )
    let l:extension = expand( '%:e'   )
    let l:idx = index( l:all_extensions, extension )

    if l:idx < 0
        echom printf('Extension %s not supported', l:extension)
        return
    endif

    for i in range( l:idx + 1, l:idx + len( l:all_extensions ) - 1 )
        let l:searching_file = printf( '%s.%s', l:filename, l:all_extensions[ i % len( l:all_extensions ) ] )
        let l:matches = findfile( l:searching_file, '**', -1 )
        if !empty( l:matches )
            if len( l:matches ) > 1
                let l:usr_input = inputlist( ['Which file do you want to open?'] + s:enumerate( l:matches ) )
                if l:usr_input == 0 || l:usr_input == -1
                    return
                endif
                let l:file_index = l:usr_input - 1
                if l:file_index < 0 || l:file_index > len( l:matches ) - 1
                    echo "\nIndex out of bounds"
                    return
                endif
            endif

            try
                execute 'edit ' . l:matches[ get( l:, 'file_index', 0 ) ]
            catch
            endtry

            let &wildignore = s:wildignore
            return
        endif
    endfor

    echom 'Cannot find a pair for ' . expand( '%:p' )
endfunction
