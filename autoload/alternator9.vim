vim9script

var old_wildignore = ''

def Enumerate( input: list< string > ): list< string >
    var result = []
    for i in range( 1, len( input ) )
        add( result, printf( '%d: %s', i, input[ i -  1 ] ) )
    endfor
    return result
enddef

def UpdateWildignore(): void
    old_wildignore = &wildignore
    const wildignore_pattern = g:alternator_blacklist_folders[:]
        ->filter( 'stridx( &wildignore, v:val ) == -1' )
        ->map(( _, v ) => printf( "**/%s/**", v ) )
        ->join( ',' )
    if empty( &wildignore )
        &wildignore = wildignore_pattern
    elseif !empty( wildignore_pattern )
        &wildignore = printf( '%s,%s', &wildignore, wildignore_pattern )
    endif
enddef

def FindFiles( filename: string ): list< string >
    if executable( 'fd' ) == 1
        return systemlist( printf( 'fd %s .', filename ) )
    else
        return findfile( filename, '**', -1 )
    endif
enddef

export def alternator9#alternate(): void
    UpdateWildignore()

    const all_extensions: list< string > = g:alternator_header_extensions + g:alternator_source_extensions

    const filename  = expand( '%:t:r' )
    const extension = expand( '%:e'   )
    var idx = index( all_extensions, extension )

    if idx < 0
        echom printf( 'Extension %s not supported', extension )
        return
    endif

    for i in range( idx + 1, idx + len( all_extensions ) - 1 )
        const searching_file = printf( '%s.%s', filename, all_extensions[ i % len( all_extensions ) ] )
        const matches = FindFiles( searching_file )
        var file_index = 0
        if !empty( matches )
            if len( matches ) > 1
                const usr_input: number = inputlist( ['Which file do you want to open?'] + Enumerate( matches ) )
                if usr_input == 0 || usr_input == -1
                    &wildignore = old_wildignore
                    return
                endif

                file_index = usr_input - 1
                if file_index < 0 || file_index > len( matches ) - 1
                    echo "\nIndex out of bounds"
                    &wildignore = old_wildignore
                    return
                endif
            endif
            try 
                const match  = matches[ file_index ]
                const buf_nr = bufnr( match )
                if buf_nr != -1
                    execute 'buffer ' .. buf_nr
                else
                    execute 'edit ' .. match
                endif
            catch
                echom 'This should not occur'
            endtry

            &wildignore = old_wildignore
            return
        endif
    endfor
enddef
