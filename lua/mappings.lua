local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-q>", ":NvimTreeFocus<CR>")
map("n", "<C-b>", ":NvimTreeToggle<CR>")

map("t", "<ESC>", "<C-\\><C-n>")

map("n", "<C-e>", ":Telescope find_files<CR>")

map("", "<Tab>", ":BufferLineCycleNext<CR>")
map("", "<S-Tab>", ":BufferLineCyclePrev<CR>")
map("", "<A-w>", ":%bd<CR>")

map("n", "<A-j>", ":m +1<CR>")
map("n", "<A-k>", ":m -2<CR>")
map("n", "<C-W>", ":bd<CR>")
