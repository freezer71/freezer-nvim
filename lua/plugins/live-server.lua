return {
  "barrett-ruth/live-server.nvim",
  build = "npm i -g live-server",
  cmd = { "LiveServerStart", "LiveServerStop" }, -- Charge sur la commande :LiveServer...
  keys = { -- Charge sur les raccourcis
    { "<leader>ls", "<cmd>LiveServerStart<cr>", desc = "Start Live Server" },
    { "<leader>lp", "<cmd>LiveServerStop<cr>", desc = "Stop Live Server" },
  },
  config = function()
    require("live-server").setup({
      ignore_files = { "README.md", ".git/*", "node_modules/*" },
      -- Note: cmd ici sert à la config interne du plugin, pas au chargement lazy
      cmd = { "LiveServerStart", "LiveServerStop" },
    })
  end,
}
