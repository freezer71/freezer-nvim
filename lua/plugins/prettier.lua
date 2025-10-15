return {
  "MunifTanjim/prettier.nvim",
  config = function()
    require("prettier").setup({
      bin = "prettierd", -- or `'prettierd'` (v0.23+)
      filetypes = {
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "less",
        "markdown",
        "scss",
        "typescript",
        "typescriptreact",
        "yaml",
        "svelte",
        "vue",
      },
    })
  end,
}
