if &compatible
 set nocompatible
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

set tabstop=2
set shiftwidth=2
set expandtab

tnoremap <silent> <esc> <C-\><C-n>

autocmd ColorScheme * hi LineNr guibg=#2a2e34 guifg=#aebbc5
autocmd ColorScheme * hi CursorLineNr guibg=#658494 guifg=#2a2e34
set background=dark
set termguicolors
let g:quantum_black=1
colorscheme quantum
syntax on
