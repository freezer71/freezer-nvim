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
          exclude = {
            "**/node_modules/**",
            "**/.git/**",
            "**/.next/**",
            "**/dist/**",
            "**/build/**",
            "**/.turbo/**",
            "**/.cache/**",
            "**/coverage/**",
            "*.bru",
          },
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
