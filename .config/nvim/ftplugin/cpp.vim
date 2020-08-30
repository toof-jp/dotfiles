" compile and run
nnoremap <buffer> <C-e> :w<CR> :te g++ -std=gnu++17 -O2 -Wall -Wshadow -DLOCAL % && echo "OK" && ./a.out && rm a.out<CR>
" copy
" WSL
if system('uname -a | egrep [Mm]icrosoft') != ''
  nnoremap <buffer> <C-w> :w<CR> :! oj-bundle % \| win32yank.exe -i<CR><CR>
" Linux
else
  nnoremap <buffer> <C-w> :w<CR> :! oj-bundle % \| xclip -selection c<CR><CR>
endif

" ccls config
" https://github.com/MaskRay/ccls/wiki/Customization#compile_commandsjson-file
let filename = expand('%:p')
echo system('echo ''[{"directory": "/home/toof/working/cp","command": "/usr/bin/gcc ' . filename . ' -std=gnu++17","file": "' . filename . '"}]'' > compile_commands.json')
