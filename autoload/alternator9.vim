vim9script

var old_wildignore = ''

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

def ResetWildignore(): void
enddef

def FindMatches( filename: string, directory: string ): list< string >
    if executable( 'fd' ) == 1
        return systemlist( printf( 'fd --color=never --glob %s %s', filename, directory ) )
    else
        return findfile( filename, directory .. '/**', -1 )
    endif
enddef

def ChooseMatch( matches: list< string > ): number
    const usr_input: number = inputlist(
            [ 'Which file do you want to open?' ]
            + deepcopy( matches )
        -> map( ( index, file ) => printf( '%d: %s', index + 1, file ) ) )
    if usr_input == 0 || usr_input == -1
        return -1
    endif

    const match_index = usr_input - 1
    if match_index < 0 || match_index > len( matches ) - 1
        echo "\nIndex out of bounds"
        return -1
    endif

    return match_index
enddef

def OpenMatch( match: string ): void
    const buf_nr = bufnr( match )
    if buf_nr != -1
        execute 'buffer ' .. buf_nr
    else
        execute 'edit ' .. match
    endif
enddef

# TODO: find in pwd, and if there are no matches search in %:h
export def Alternate(): void
    if index( [ 'c', 'cpp' ], &ft ) == -1
        echom printf( 'Filetype "%s" not supported! Only c and cpp are supported!', &ft )
        return
    endif

    if &modified && !&hidden
        echo "No write since last change, cannot alternate!"
        return
    endif

    const all_extensions: list< string > = g:alternator_header_extensions + g:alternator_source_extensions

    const buffer_name  = expand( '%:t' )
    var extension = ''
    var filename  = ''
    var len_max = -1
    for ext in all_extensions
        # echom 'Checking for... ' .. ext
        filename = substitute( buffer_name, ext .. '$', '', '' )
        const length = len( buffer_name ) - len( filename )
        if length > len_max
            # echom 'This is better!'
            len_max = length
            extension = ext
        endif
    endfor
    filename = substitute( buffer_name, extension .. '$', '', '' )

    var idx = index( all_extensions, extension )
    if idx < 0
        echom printf( 'Extension %s not supported', extension )
        return
    endif

    UpdateWildignore()

    for i in range( idx + 1, idx + len( all_extensions ) - 1 )
        const searching_file = printf( '%s%s', filename, all_extensions[ i % len( all_extensions ) ] )
        const matches = FindMatches( searching_file, getcwd() )
        if empty( matches )
            continue
        elseif len( matches ) == 1
            OpenMatch( matches[ 0 ] )
            ResetWildignore()
            return
        else
            const match_index = ChooseMatch( matches )
            if match_index != -1 
                OpenMatch( matches[ match_index ] )
            endif
            ResetWildignore()
            return
        endif
    endfor

    for i in range( idx + 1, idx + len( all_extensions ) - 1 )
        const searching_file = printf( '%s%s', filename, all_extensions[ i % len( all_extensions ) ] )
        const matches = FindMatches( searching_file, expand( "%:h" ) )
        if empty( matches )
            continue
        elseif len( matches ) == 1
            OpenMatch( matches[ 0 ] )
            ResetWildignore()
            return
        else
            const match_index = ChooseMatch( matches )
            if match_index != -1 
                OpenMatch( matches[ match_index ] )
            endif
            ResetWildignore()
            return
        endif
    endfor

    ResetWildignore()
    echom 'Cannot find a pair for ' .. expand( '%:p' )
enddef
