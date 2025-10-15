return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
  },
  config = function()
    local map = vim.keymap.set
    map("n", "fR", "<cmd> FlutterRun <cr>")
    map("n", "fe", "<cmd> FlutterEmulators<cr>")
    map("n", "fr", "<cmd> FlutterRestart <cr>")
    map("n", "fo", "<cmd> FlutterOutlineToggle <cr>")
    map("n", "fl", "<cmd> FlutterLogToggle <cr>")

    require("flutter-tools").setup({})
  end,
}
