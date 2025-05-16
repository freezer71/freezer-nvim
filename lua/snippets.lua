local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local filetypes = { "javascript", "typescript", "typescriptreact" }

for _, ft in ipairs(filetypes) do
  ls.add_snippets(ft, {
    s("log", {
      t("console.log("),
      i(1),
      t(");"),
    }),
  })
end
