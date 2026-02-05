return {
  "chenasraf/text-transform.nvim",
  version = "*", -- or: tag = "stable"
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  config = function()
    require('text-transform').setup({
      vim.keymap.set({ "n", "v" }, "<leader>Cc", ":TtCamel<CR>", { silent = true, desc = "To camelCase" });
      vim.keymap.set({ "n", "v" }, "<leader>Cs", ":TtSnake<CR>", { silent = true, desc = "To snake_case" });
      vim.keymap.set({ "n", "v" }, "<leader>Cp", ":TtPascal<CR>", { silent = true, desc = "To PascalCase" });
      vim.keymap.set({ "n", "v" }, "<leader>Cc", ":TtConst<CR>", { silent = true, desc = "To CONST_CASE" });
      vim.keymap.set({ "n", "v" }, "<leader>Cd", ":TtDot<CR>", { silent = true, desc = "To dot.case" });
      vim.keymap.set({ "n", "v" }, "<leader>Ck", ":TtKebab<CR>", { silent = true, desc = "To kebab-case" });
      vim.keymap.set({ "n", "v" }, "<leader>Ct", ":TtTitle<CR>", { silent = true, desc = "To Title Case" });
    })
  end,
}

