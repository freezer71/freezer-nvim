-- Configuration complète LSP avec Mason
return {
  -- Mason : gestion des serveurs
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-LSPConfig : pont Mason <-> LSP
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "cssls",
          "html",
          "jsonls",
          -- "dartls",
          "tailwindcss",
          "gopls",
          "intelephense",
        },

        automatic_installation = true,
      })
    end,
  },

  -- nvim-lspconfig : configuration des serveurs
  {
    "neovim/nvim-lspconfig",
    -- dependencies ={
    --   "telescopic-plugins/telescope.nvim",
    -- },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local on_attach = function(_, bufnr)
      end

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
        tsserver = {}, -- TypeScript / JavaScript
        pyright = {},  -- Python
        cssls = {},    -- CSS
        html = {       -- HTML avec CSS/JS intégré
          filetypes = { "html", "htmldjango" },
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
        jsonls = {},      -- JSON
        dartls = {},      -- Dart / Flutter
        tailwindcss = {}, -- TailwindCSS
        gopls = {},       -- Go
        -- jdtls= {
        --   -- filetypes = { "java" },
        -- },
        intelephense = { -- PHP
          filetypes = { "php", "htmldjango" },
          root_markers = { ".git", "composer.json" },
          settings = {
            intelephense = {
              files = { maxSize = 5000000 },
              stubs = {
                "apache",
                "bcmath",
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

      local function on_list(options)
        vim.fn.setqflist({}, ' ', options)
        vim.cmd.cfirst()
      end
      map("n", "gd", function () vim.lsp.buf.definition({on_list = on_list}) end, { desc = "Go to definition", unpack(opts) })
      map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation", unpack(opts) })
      map("n", "gr", vim.lsp.buf.references, { desc = "List references", unpack(opts) })
      map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol", unpack(opts) })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", unpack(opts) })
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format code", unpack(opts) })
    end,
  },
}
