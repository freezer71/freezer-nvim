-- Complète l'extra lazyvim.plugins.extras.lang.java (installation de jdtls, root, workspace)
return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    -- Ajouter les JAR du dossier jar/ du projet au classpath
    opts.jdtls = function(config)
      local root = config.root_dir or vim.fn.getcwd()
      local jars = vim.fn.glob(root .. "/jar/**/*.jar", true, true)
      return vim.tbl_deep_extend("force", config, {
        settings = { java = { project = { referencedLibraries = jars } } },
      })
    end
  end,
}
