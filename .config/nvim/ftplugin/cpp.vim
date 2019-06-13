nnoremap <buffer> <C-e> :te g++ -O2 -Wall % && echo "OK" && ./a.out && rm a.out<CR>

" cquery config
" http://kutimoti.hatenablog.com/entry/2018/06/09/165225
let filename = expand('%:p')
echo system('echo ''[{"directory": "/home/kutimoti/contest","command": "/usr/bin/c++  ' . filename . ' -std=c++1y","file": "' . filename . '"}]'' > compile_commands.json')
