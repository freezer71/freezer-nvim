return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
mason_lspconfig.setup({
  ensure_installed = {
    "html",
    "cssls",
    "tailwindcss",
    "lua_ls",
    "emmet_ls",
    "pyright",
    "tsserver", -- au lieu de "ts_ls"
    "gopls",
    "python",
    "rust_analyzer",
  },
  automatic_installation = true,
})
	end,
}
