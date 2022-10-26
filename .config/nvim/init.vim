set number
set relativenumber

" clone git repos into the path
call plug#begin('~/.vim/plugged')
Plug 'projekt0n/github-nvim-theme'
Plug '/usr/local/opt/fzf'
call plug#end()

colorscheme github_dark_default

let g:fzf_action = {
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit'
      \ }
let g:fzf_preview_window = 'right:60%'
nnoremap <c-p> :FZF<cr>
" remap cmd+p https://www.dfurnes.com/notes/binding-command-in-iterm