local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("n", "<C-b>", ":NvimTreeToggle<CR>")

map("n", "<C-q>", ":NvimTreeFocus<CR>")
map("t", "<ESC>", "<C-\\><C-n>")

map("n", "<C-e>", ":Telescope find_files<CR>")
map("n", "<c-f>", ":Telescope live_grep<CR>")

map("", "<Tab>", ":BufferLineCycleNext<CR>")
map("", "<S-Tab>", ":BufferLineCyclePrev<CR>")
map("", "<A-w>", ":%bd<CR>")

map("n", "<A-j>", ":m +1<CR>")
map("n", "<A-k>", ":m -2<CR>")
map("n", "<C-W>", ":bd<CR>")

map('n', 'dd', '"_dd', { noremap = true })
