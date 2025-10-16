-- Configuration LuaSnip (snippets)
return {
  "L3MON4D3/LuaSnip",
  version = "*",
  dependencies = {
    "rafamadriz/friendly-snippets", -- collection de snippets
  },
  config = function()
    local luasnip = require("luasnip")
    require("luasnip.loaders.from_vscode").lazy_load() -- charge friendly-snippets
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })
  end,
}
