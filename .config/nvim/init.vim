if &compatible
 set nocompatible
endif

let $CACHE = expand('~/.cache')
if !($CACHE->isdirectory())
  call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
  let s:dir = 'dein.vim'->fnamemodify(':p')
  if !(s:dir->isdirectory())
    let s:dir = $CACHE .. '/dein/repos/github.com/Shougo/dein.vim'
    if !(s:dir->isdirectory())
      execute '!git clone https://github.com/Shougo/dein.vim' s:dir
    endif
  endif
  execute 'set runtimepath^='
        \ .. s:dir->fnamemodify(':p')->substitute('[/\\]$', '', '')
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#load_toml('~/.config/nvim/dein.toml', {'lazy': 0})
  call dein#load_toml('~/.config/nvim/dein_lazy.toml', {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif


let g:netrw_dirhistmax=0
set encoding=utf-8
set number
set cursorline
set list
set clipboard+=unnamedplus
set inccommand=split
set shellcmdflag=-ic

set tabstop=2
set shiftwidth=2
set expandtab
set conceallevel=0

inoremap <C-f> <esc>
tnoremap <silent> <esc> <C-\><C-n>

" replace selection with last yanked text without overwriting the yank register
xnoremap p "_dP

command! Q q!

autocmd ColorScheme * hi LineNr guibg=#2a2e34 guifg=#aebbc5
autocmd ColorScheme * hi CursorLineNr guibg=#658494 guifg=#2a2e34
set background=dark
set termguicolors
let g:quantum_black=1
colorscheme quantum
syntax on
