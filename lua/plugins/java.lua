return {
  "mfussenegger/nvim-jdtls",
  config = function()
    -- On ne démarre JDTLS que pour des fichiers Java
    if vim.bo.filetype ~= "java" then
      return
    end

    -- Détecte le dossier racine du projet
    local root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw" }) or vim.fn.getcwd()

    -- 🚫 Ne pas lancer sur les projets Flutter
    -- On vérifie si un pubspec.yaml (typique d'un projet Flutter/Dart) existe
    if vim.fn.filereadable(root_dir .. "/pubspec.yaml") == 1 then
      return
    end

    -- Maintenant on peut démarrer JDTLS
    require("jdtls").start_or_attach({
      name = "jdtls",
      cmd = { "jdtls" },
      root_dir = root_dir,
      settings = {
        java = {},
      },
      -- init_options = {
      --   bundles = {},
      -- },

    })
  end,
}
