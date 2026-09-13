return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart", -- Charge uniquement sur les fichiers .dart
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Raccourcis locaux aux buffers dart
    keys = {
      { "<leader>FR", "<cmd>FlutterRun<cr>", ft = "dart", desc = "Flutter Run" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", ft = "dart", desc = "Flutter Emulators" },
      { "<leader>Fr", "<cmd>FlutterRestart<cr>", ft = "dart", desc = "Flutter Restart" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", ft = "dart", desc = "Flutter Outline" },
      { "<leader>Fl", "<cmd>FlutterLogToggle<cr>", ft = "dart", desc = "Flutter Logs" },
    },
    opts = {
      -- flutter_path = "/Users/tharsan/fvm/versions/stable/bin/flutter",
    },
  },
  { "folke/which-key.nvim", opts = { spec = { { "<leader>F", group = "flutter" } } } },
}
