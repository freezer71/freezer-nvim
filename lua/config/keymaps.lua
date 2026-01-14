-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
function Map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

Map("n", "<C-a>", "ggVG")
Map("", "<leader><leader>", Snacks.picker.files,{desc = "Open file picker"})

-- NORMAL MODE: déplacer une ligne
Map("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down" })
Map("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up" })
Map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
Map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- VISUAL MODE: déplacer un bloc
Map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
Map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
Map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
Map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Terminal mode: exit terminal mode
-- Map("t", "<Esc>", "<C-\\><C-n>")
Map("", "<A-ù>", "<cmd>FloatermToggle<cr>", { desc = "Toggle Floaterm" })
Map("t", "<A-ù>", "<cmd>FloatermToggle<cr>", { desc = "Toggle Floaterm" })
