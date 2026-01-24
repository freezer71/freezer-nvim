return {
  "folke/snacks.nvim",

  ---@type snacks.Config
  opts = {
    explorer = { enabled = true },
    picker = {
      exclude = { -- add folder names here to exclude
        ".git",
        "node_modules",
        ".next"
      },
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
