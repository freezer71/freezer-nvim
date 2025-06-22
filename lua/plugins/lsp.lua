-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        tsserver = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        gopls = {
          -- Configuration optionnelle pour Go
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
