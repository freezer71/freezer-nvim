return {
  {
    "gbprod/phpactor.nvim",
    ft = "php",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- If the update/install notification doesn't show properly,
      -- you should also add here UI plugins like "folke/noice.nvim" or "stevearc/dressing.nvim"
    },
    keys = {
      { "<leader>cp", "<cmd>PhpActor<CR>", ft = "php", desc = "Phpactor menu" },
      { "<leader>cg", "<cmd>PhpActor generate_accessor<CR>", ft = "php", desc = "Generate getter/setter" },
    },
    opts = {
      -- you're options goes here
    },
  },
}
