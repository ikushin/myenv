
set encoding=utf-8
set ignorecase
set smartcase
set nowrap
autocmd BufWritePre * :%s/\s\+$//ge
set nowrapscan

