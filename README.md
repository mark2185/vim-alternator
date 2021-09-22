# vim-alternator

                 _   _ _                        _             ~
                /_\ | | |_ ___ _ __ _ __   __ _| |_ ___  _ __ ~
               //_\\| | __/ _ \ '__| '_ \ / _` | __/ _ \| '__|~
              /  _  \ | ||  __/ |  | | | | (_| | || (_) | |   ~
              \_/ \_/_|\__\___|_|  |_| |_|\__,_|\__\___/|_|   ~

                  Alternating between headers, source files, 
           template implementations and others with blazing speed!


## Usage
Just call `:Alternate` and the window will open
a matching source/header file to the currently opened one.

## Commands
Alternate
* looks for a file with the same name, but a different extension
* it cycles through all the extensions, starting from the current buffer's extension

## Mappings
The only mapping this plugin provides is:
 `<Plug>(Alternate)`

## Configuration
The file extensions the plugin looks for are stored in the
following arrays:
```
g:alternator_header_extensions
g:alternator_source_extensions
```

Default values are as follows:
```vim
let g:alternator_header_extensions = [ '.h', '.hpp', '.tpp', '.ipp' ]
let g:alternator_source_extensions = [ '.c', '.cpp'                 ]
```

If there are some folders you do not want to scan,
the array `g:alternator_blacklist_folders` holds such folder names.

Default value is: 
```
[ 'node_modules', '.git' ]
```

## Bonus

If you have `fd` in your path, it will be used instead of vim's `findfile`.
