" alternator.vim - Alternate C/C++ header/source
" Maintainer: Luka Markušić

function! s:updateWildignore() abort
    let s:wildignore = &wildignore
    let l:wildignore_pattern = deepcopy( g:alternator_blacklist_folders )
                \ ->filter( 'stridx( &wildignore, v:val ) == -1' )
                \ ->map( { -> printf( "**/%s/**", v:val ) } )
                \ ->join( ',' )
    if empty(&wildignore)
        let &wildignore = l:wildignore_pattern
    elseif !empty( l:wildignore_pattern )
        let &wildignore .= ',' . l:wildignore_pattern
    endif
endfunction

function! s:findFiles( filename ) abort
    if executable( 'fd' ) == 1
        return systemlist( printf( 'fd --color=never --glob %s .', a:filename ) )
    else
        return findfile( a:filename, '**', -1 )
    endif
endfunction

function! alternator#alternate() abort
    if &modified && !&hidden
        echo "No write since last change, cannot alternate!"
        return
    endif

    let l:all_extensions = g:alternator_header_extensions + g:alternator_source_extensions

    const buffer_name  = expand( '%:t' )
    let l:extension = ''
    let l:filename  = ''
    let l:len_max = -1
    for ext in l:all_extensions
        " echom 'Checking for... ' .. ext
        let l:filename = substitute( l:buffer_name, ext .. '$', '', '' )
        let l:length = len( l:buffer_name ) - len( l:filename )
        if l:length > l:len_max
            " echom 'This is better!'
            let l:len_max = l:length
            let l:extension = l:ext
        endif
    endfor
    let l:filename = substitute( l:buffer_name, l:extension .. '$', '', '' )

    let l:idx = index( l:all_extensions, l:extension )

    if l:idx < 0
        echom printf('Extension %s not supported', l:extension)
        return
    endif

    silent call s:updateWildignore()

    for i in range( l:idx + 1, l:idx + len( l:all_extensions ) - 1 )
        let l:searching_file = printf( '%s%s', l:filename, l:all_extensions[ i % len( l:all_extensions ) ] )
        let l:matches = s:findFiles( l:searching_file )
        if !empty( l:matches )
            if len( l:matches ) > 1
                let l:usr_input = inputlist(
                    \[ 'Which file do you want to open?' ]
                    \ + deepcopy( matches )->map({ index, file -> printf( '%d: %s', index + 1, file ) } ) )
                if l:usr_input == 0 || l:usr_input == -1
                    let &wildignore = s:wildignore
                    return
                endif
                let l:file_index = l:usr_input - 1
                if l:file_index < 0 || l:file_index > len( l:matches ) - 1
                    echo "\nIndex out of bounds"
                    let &wildignore = s:wildignore
                    return
                endif
            endif

            let l:match  = l:matches[ get( l:, 'file_index', 0 ) ] 
            let l:buf_nr = bufnr( l:match ) 
            if l:buf_nr != -1
                execute 'buffer ' . l:buf_nr
            else
                execute 'edit ' . l:match
            endif

            let &wildignore = s:wildignore
            return
        endif
    endfor

    echom 'Cannot find a pair for ' . expand( '%:p' )
endfunction
