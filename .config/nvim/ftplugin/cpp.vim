" compile and run
nnoremap <buffer> <C-e> :w<CR> :te g++ -std=gnu++17 -O3 -Wall -Wshadow -DLOCAL % && echo "Done" && ./a.out && rm a.out<CR>

" copy
" WSL
if system('uname -a | egrep [Mm]icrosoft') != ''
  nnoremap <buffer> <C-w> :w<CR> :! oj-bundle % \| win32yank.exe -i<CR><CR>
" Linux
else
  nnoremap <buffer> <C-w> :w<CR> :! oj-bundle % \| xclip -selection c<CR><CR>
endif

" ccls
" https://github.com/MaskRay/ccls/wiki/Project-Setup#ccls-file
echo system("echo '/usr/bin/gcc\n-std=gnu++17\n-I/home/toof/working/library/src\n' > .ccls")
