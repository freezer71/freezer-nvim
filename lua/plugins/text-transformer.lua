return {
  "chenasraf/text-transform.nvim",
  -- Le plugin dort jusqu'à ce que tu appuies sur une de ces touches :
  keys = {
    { "<leader>Cc", "<cmd>TtCamel<CR>", mode = { "n", "v" }, desc = "To camelCase" },
    { "<leader>Cs", "<cmd>TtSnake<CR>", mode = { "n", "v" }, desc = "To snake_case" },
    { "<leader>Cp", "<cmd>TtPascal<CR>", mode = { "n", "v" }, desc = "To PascalCase" },
    { "<leader>Cu", "<cmd>TtConst<CR>", mode = { "n", "v" }, desc = "To CONST_CASE" },
    { "<leader>Cd", "<cmd>TtDot<CR>", mode = { "n", "v" }, desc = "To dot.case" },
    { "<leader>Ck", "<cmd>TtKebab<CR>", mode = { "n", "v" }, desc = "To kebab-case" },
    { "<leader>Ct", "<cmd>TtTitle<CR>", mode = { "n", "v" }, desc = "To Title Case" },
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    popup_type = "select", -- popup via snacks au lieu de telescope
  },
}
