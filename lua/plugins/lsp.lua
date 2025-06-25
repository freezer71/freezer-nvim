-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        tsserver = {
          filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
          root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git"),
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                unreachable = true,
              },
              staticcheck = true,
            },
          },
        },
      },
    },
  },
}
