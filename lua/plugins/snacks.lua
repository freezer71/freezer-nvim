return {
  "folke/snacks.nvim",

  ---@type snacks.Config
  opts = {
    explorer = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { "node_modules", "*.bru" },
        },
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { "node_modules", "*.bru" },
        },
      },
    },
  },
}
