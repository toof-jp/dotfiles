" compile and run
nnoremap <buffer> <C-e> :w<CR> :te g++ -std=gnu++17 -I /home/toof/working/library -O3 -Wall -Wshadow -DLOCAL % && echo "Done" && ./a.out && rm a.out<CR><CR>

" copy
nnoremap <buffer> <C-w> :w<CR> :! oj-bundle -I /home/toof/working/library % \| pbcopy<CR><CR>

" ccls
" https://github.com/MaskRay/ccls/wiki/Project-Setup#ccls-file
echo system("echo '/usr/bin/gcc\n-std=gnu++17\n-I/home/toof/working/library\n' > .ccls")
