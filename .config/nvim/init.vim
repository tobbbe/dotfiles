call plug#begin('~/.local/share/nvim/plugged')

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 0

Plug 'jkramer/vim-checkbox', { 'for': 'markdown' }

call plug#end()


filetype plugin on
set omnifunc=syntaxcomplete#Complete

set tabstop=4
set softtabstop=4 noexpandtab
set shiftwidth=4

" https://github.com/Shougo/deoplete.nvim/issues/432<Paste>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

:imap jj <Esc>
:autocmd InsertLeave * silent! update
let mapleader = "\<space>"
nnoremap <Leader>w :w<CR>
nnoremap <Leader>e :E<CR>
nnoremap <esc> :noh<return><esc>
nnoremap <F6> :w<CR>
