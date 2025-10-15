return {
  "barrett-ruth/live-server.nvim",
  -- lazy = false,
  build = "npm i -g live-server",
  -- cmd = { "LiveServerStart", "LiveServerStop" },
  config = function()
    require("live-server").setup({
      ignore_files = { "README.md", ".git/*", "node_modules/*" }, -- Ignore specific files or directories
      cmd = { "LiveServerStart", "LiveServerStop" },
    })
    local map = vim.keymap.set
    map("n", "ls", "<cmd> LiveServerStart<cr>")
    map("n", "ld", "<cmd> LiveServerStop<cr>")
  end,
}
