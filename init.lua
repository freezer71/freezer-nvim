vim.o.shell = "fish"
-- vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"

vim.o.shellquote = ""
vim.o.shellxquote = ""

require("configs.lazy")
require("mappings")
require("snippets")

vim.o.tabstop = 2      -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 2  -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 2   -- Number of spaces inserted when indenting
vim.wo.relativenumber = true
vim.wo.number = true
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
