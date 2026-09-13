-- LazyVim gère mason, mason-lspconfig, les keymaps LSP et l'installation des serveurs :
-- on se contente d'étendre ses opts. lua_ls et jsonls sont déjà configurés par LazyVim.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false, -- désactive le texte en ligne classique
        virtual_lines = true, -- active les virtual lines sous la ligne
      },
      servers = {
        ts_ls = {}, -- TypeScript / JavaScript
        pyright = {}, -- Python
        cssls = {}, -- CSS
        html = { -- HTML avec CSS/JS intégré
          filetypes = { "html", "htmldjango", "ejs" },
          settings = {
            html = {
              format = { enable = true },
              hover = { documentation = true, references = true },
              suggest = { html5 = true },
              validate = true,
              autoClosingTags = true,
              css = true,
              javascript = true,
            },
          },
        },
        emmet_language_server = {}, -- requis par nvim-emmet
        twiggy_language_server = {},
        tailwindcss = {}, -- TailwindCSS
        gopls = {}, -- Go
        prismals = {}, -- Prisma
        svelte = {}, -- Svelte
        intelephense = { -- PHP
          filetypes = { "php", "htmldjango" },
          root_markers = { ".git", "composer.json" },
          settings = {
            intelephense = {
              environment = { phpVersion = "8.3" },
              files = { maxSize = 500000 },
              stubs = {
                "bcmath",
                "Core",
                "superglobals",
                "curl",
                "date",
                "dom",
                "fileinfo",
                "filter",
                "gd",
                "hash",
                "iconv",
                "json",
                "mbstring",
                "mongodb",
                "mysqli",
                "openssl",
                "pcre",
                "PDO",
                "phar",
                "posix",
                "reflection",
                "session",
                "SimpleXML",
                "sockets",
                "spl",
                "standard",
                "tokenizer",
                "xml",
                "zip",
                "zlib",
              },
            },
          },
        },
      },
    },
  },
}
