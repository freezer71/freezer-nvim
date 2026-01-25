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
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
