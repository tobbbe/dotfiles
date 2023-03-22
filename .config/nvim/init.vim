set number
set relativenumber

nmap ö :

" clone git repos into the path
call plug#begin('~/.vim/plugged')
" Plug 'projekt0n/github-nvim-theme'
" Plug 'neovim/nvim-lspconfig'
Plug '/opt/homebrew/opt/fzf'
call plug#end()

" colorscheme github_dark_default

let g:fzf_action = {
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit'
      \ }
let g:fzf_preview_window = 'right:60%'
nnoremap <c-p> :FZF<cr>
" remap cmd+p https://www.dfurnes.com/notes/binding-command-in-iterm

lua << END
local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then return end

local protocol = require('vim.lsp.protocol')

-- TypeScript
nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" }
}

END