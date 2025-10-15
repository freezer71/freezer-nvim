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
          filetypes = { "html", "htmldjango" },
          init_options = {
            provideFormatter = true,
          },
        },
        tailwindcss = {},
        ts_ls = {
          cmd = { "typescript-language-server", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
        },
        lua_ls = {
          filetypes = "lua",
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        gopls = {
          filetypes = { "go" },
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
                maxSize = 5000000,
              },
              diagnostics = {
                enable = true,
              },
            },
          },
        },
        jdtls = {
          filetypes = { "java" },
          settings = {
            java = {
              configuration = {
                runtimes = {
                  {
                    name = "JavaSE-25",
                    path = "/usr/lib/jvm/default/",
                    default = true,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
}
