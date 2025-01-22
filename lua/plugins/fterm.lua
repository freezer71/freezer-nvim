return {
  "https://github.com/numToStr/FTerm.nvim",
  config = function()
    require("FTerm").setup {
      cmd        = "powershell.exe",
      border     = 'double',
      dimensions = {
        height = 0.5,
        width = 0.5,
      },
    } -- use defaults
  end,
}
