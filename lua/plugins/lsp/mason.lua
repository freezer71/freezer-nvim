return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
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
        automatic_enable = {
          "cssls",
          "tailwindcss",
          "lua_ls",
          "emmet_ls",
          "pyright",
          "gopls",
          "typescript", "html", "typescriptreact", "typescript.tsx"
        }
    })
	end,
}
