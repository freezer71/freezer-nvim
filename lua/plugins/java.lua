return {
  "mfussenegger/nvim-jdtls",
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data")
          .. package.config:sub(1, 1)
          .. "jdtls-workspace"
          .. package.config:sub(1, 1)
          .. project_name
        local os_name = vim.loop.os_uname().sysname

        -- Récupérer tous les JAR dans workspace/jar/**
        local jar_dir = vim.fn.getcwd() .. "/jar"
        local jars = vim.fn.glob(jar_dir .. "/**.jar", true, true)

        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-jar",
            vim.fn.stdpath("data")
              .. package.config:sub(1, 1)
              .. "mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.100.v20251014-1222.jar",
            "-configuration",
            vim.fn.stdpath("data")
              .. package.config:sub(1, 1)
              .. "mason/packages/jdtls/config_"
              .. (os_name == "Windows_NT" and "win" or os_name == "Linux" and "linux" or "mac"),
            "-data",
            workspace_dir,
          },
          root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
          settings = {
            java = {
              -- Ajouter les JAR du projet au classpath
              project = {
                referencedLibraries = jars,
              },
            },
          },
          init_options = { bundles = {} },
        }

        require("jdtls").start_or_attach(config)
      end,
    })
  end,
}
