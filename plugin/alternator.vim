" alternator.vim - Alternate C/C++ header/source
" Maintainer: Luka Markušić
" Version:    0.0.1

if exists('g:loaded_alternator_plugin')
    finish
endif
let g:loaded_alternator_plugin = 1

if !exists('g:alternator_header_extensions')
    let g:alternator_header_extensions = [ 'h', 'hpp', 'tpp' ]
endif

if !exists('g:alternator_source_extensions')
    let g:alternator_source_extensions = [ 'c', 'cpp' ]
endif

function! s:Alternate()
    let l:all_extensions = g:alternator_header_extensions + g:alternator_source_extensions

    let l:filename  = expand( '%:t:r' )
    let l:extension = expand( '%:e'   )
    let l:extension_index = index( l:all_extensions, extension )
    if ( l:extension_index >= 0 )
        for i in range( l:extension_index + 1, l:extension_index + len( l:all_extensions ) - 1 )
            let l:searching_file = printf( '%s.%s', l:filename, l:all_extensions[ i % len( l:all_extensions ) ] )
            let l:matches = expand( '**/' . l:searching_file )
            if ( l:matches ==# '**/' . l:searching_file )
                continue
            endif

            let l:split_matches = split( l:matches, '\n' )
            if len( l:split_matches ) > 1
                echom 'More than one match found:'
                let l:i = 0
                for file in l:split_matches
                    echom printf( '%d: %s', l:i, file )
                    let i = l:i + 1
                endfor

                while v:true
                    echom 'Which file do you want to open? '
                    let l:file_index = nr2char(getchar())
                    if ( l:file_index < len( l:split_matches ) )
                        execute 'edit ' . l:split_matches[ l:file_index ]
                        return
                    else
                        echom 'Index out of range'
                    endif
                endwhile
            endif

            if ( filereadable( fnameescape( l:matches ) ) )
                execute 'edit ' . fnameescape( l:matches )
                return
            endif
            continue
        endfor
    else
        echom 'Cannot find a pair for ' . expand( '%:p' )
    endif
endfunction

command! -nargs=0 Alternate call s:Alternate()
