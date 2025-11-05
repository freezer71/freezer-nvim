-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
-- Configuration globale du diagnostic LSP
vim.diagnostic.config({
  virtual_text = false, -- désactive le texte en ligne classique
  virtual_lines = true, -- active les virtual lines sous la ligne
})
