-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "ö", ":", { noremap = true })
-- vim.keymap.set("n", "<c-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set('i', '<C-c>', '<Esc>"+yiwA', { noremap = true, silent = true })
vim.keymap.set('i', '<C-v>', '<C-o>"+p', { noremap = true, silent = true })
vim.keymap.set('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })
vim.keymap.set('i', '<C-S-z>', '<C-o><C-r>', { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

