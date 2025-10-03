-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        dartls = {},
        prismals = {},
        html = {
          filetypes = { "html", "htmldjango" }, -- tu peux adapter si besoin
          init_options = {
            provideFormatter = true, -- active le formateur intégré
          },
        },
        tailwindcss = {},
        tsserver = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
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
        cssls = {
          filetypes = { "css", "scss", "less" },
          settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
          },
        },

        intelephense = {
          filetypes = { "php" },
          -- root_dir = require("lspconfig.util").root_pattern("composer.json", ".git"),
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000, -- autorise fichiers jusqu’à ~5Mo
              },
              diagnostics = {
                enable = true,
              },
            },
          },
        },
      },
    },
  },
}
