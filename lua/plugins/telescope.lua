return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = {
          'nvim-lua/plenary.nvim',
          { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
          "nvim-tree/nvim-web-devicons"
      },
      config = function()
        local telescope = require("telescope")
        telescope.setup({
            defaults = {
                file_ignore_patterns = {
                    "node_modules",
                    ".git",
                    "dist",
                    "build",
                    ".idea"
                }
            },
             mappings = {
                i = {
                    ["<Enter>"] = "file_tab",
                },
                n = {
                    ["<Enter>"] = "file_vsplit",
                }
            },
        })
        telescope.load_extension("fzf")
      end
}
