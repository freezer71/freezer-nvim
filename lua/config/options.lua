-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- La config des diagnostics est dans lua/plugins/lsp.lua (LazyVim l'écraserait ici)

vim.o.ttimeoutlen = 10

-- Langues du correcteur (LazyVim l'active sur markdown, text et gitcommit)
vim.opt.spelllang = { "fr", "en" }
