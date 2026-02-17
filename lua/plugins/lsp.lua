return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason", -- Charge uniquement quand tu tapes :Mason
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Charge uniquement à l'ouverture d'un fichier
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
        automatic_enable = false,
        ensure_installed = {
          "gopls",
          "lua_ls",
          "ts_ls",
          "pyright",
          "cssls",
          "html",
          "jsonls",
          "tailwindcss",
          "intelephense",
          "prismals",
          "emmet_language_server",
          "svelte",
          "twiggy_language_server",
        },
      })
    end,
  },
  -- nvim-lspconfig : configuration des serveurs
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Charge uniquement à l'ouverture d'un fichier
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local on_attach = function(_, _) end

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        tsserver = {
          filetypes = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
            "html",
            "htmldjango",
            "ejs",
          },
        }, -- TypeScript / JavaScript
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
        twiggy_language_server = {},
        jsonls = {}, -- JSON
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
      }

      for name, cfg in pairs(servers) do
        cfg.capabilities = vim.tbl_deep_extend("force", cfg.capabilities or {}, capabilities)
        cfg.on_attach = cfg.on_attach or on_attach
        lspconfig[name].setup(cfg)
      end

      local opts = { noremap = true, silent = true }
      local map = vim.keymap.set

      -- Correction: require("snacks") doit être chargé ici ou passé en global,
      -- mais il est plus sûr de le protéger avec un pcall ou de le charger si nécessaire.
      local snacks = require("snacks")

      map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation", unpack(opts) })
      map("n", "gd", snacks.picker.lsp_definitions, { desc = "Go to definition", unpack(opts) })
      map("n", "gr", snacks.picker.lsp_references, { desc = "List references", unpack(opts) })
      map("n", "gi", snacks.picker.lsp_implementations, { desc = "List implementation", unpack(opts) })
      map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol", unpack(opts) })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", unpack(opts) })
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format code", unpack(opts) })
    end,
  },
}
