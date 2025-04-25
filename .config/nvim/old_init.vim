let mapleader = " "
nnoremap <leader>t :echo "Leader key works!"<CR>

nmap ö :

set number
set relativenumber

" clone git repos into the path
call plug#begin()
" Plug 'projekt0n/github-nvim-theme'
Plug '/opt/homebrew/opt/fzf'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
call plug#end()

" colorscheme github_dark_default

nnoremap <leader>fo <cmd>Telescope buffers<cr>

let g:fzf_action = {
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit'
      \ }
let g:fzf_preview_window = 'right:60%'
" remap cmd+p https://www.dfurnes.com/notes/binding-command-in-iterm
" nnoremap <c-p> :FZF<cr>
nnoremap <c-p> <cmd>Telescope find_files<cr>

lua << END



END