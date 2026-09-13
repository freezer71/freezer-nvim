-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Déplacer une ligne / un bloc avec les flèches (réutilise <A-j>/<A-k> de LazyVim)
map({ "n", "i", "v" }, "<A-Down>", "<A-j>", { remap = true, desc = "Move Down" })
map({ "n", "i", "v" }, "<A-Up>", "<A-k>", { remap = true, desc = "Move Up" })

map({ "n", "t" }, "<A-ù>", "<cmd>FloatermToggle<cr>", { desc = "Toggle Floaterm" })

map("n", "<C-S-s>", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<C-S-h>", "<cmd>split<CR>", { desc = "Horizontal split" })
