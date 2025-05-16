local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("n", "<C-q>", ":NvimTreeToggle<CR>")
map("n", "<C-a>", ":NvimTreeFocus<CR>")

map("t", "<ESC>", "<C-\\><C-n>")

map("n", "<C-e>", ":Telescope find_files<CR>")
map("n", "<c-f>", ":Telescope live_grep<CR>")

map("", "<Tab>", ":BufferLineCycleNext<CR>")
map("", "<S-Tab>", ":BufferLineCyclePrev<CR>")
map("", "<A-w>", ":%bd<CR>")
map("", "<C-z>", ":undo<CR>")
map("", "<C-y>", ":redo<CR>")

map("", "<C-s>", ":vsplit<CR>:TmuxNavigateLeft<CR>")
map("", "<A-s>", ":split<CR>:TmuxNavigateLeft<CR>")

map("n", "<A-j>", ":m +1<CR>")
map("n", "<A-k>", ":m -2<CR>")
map("n", "<c-w>", ":close<cr>")

map('n', 'dd', '"_dd', { noremap = true })

-- map("i", "<log>", ":close<cr>")

