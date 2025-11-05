return {
  "mfussenegger/nvim-jdtls",
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") ..
                              package.config:sub(1,1) .. "jdtls-workspace" ..
                              package.config:sub(1,1) .. project_name
        local os_name = vim.loop.os_uname().sysname

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
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", vim.fn.stdpath("data") .. package.config:sub(1,1) ..
                   "mason" .. package.config:sub(1,1) ..
                   "packages" .. package.config:sub(1,1) ..
                   "jdtls" .. package.config:sub(1,1) ..
                   "plugins/org.eclipse.equinox.launcher_1.7.100.v20251014-1222.jar",
            "-configuration", vim.fn.stdpath("data") .. package.config:sub(1,1) ..
                              "mason" .. package.config:sub(1,1) ..
                              "packages" .. package.config:sub(1,1) ..
                              "jdtls/config_" .. (os_name == "Windows_NT" and "win" or os_name == "Linux" and "linux" or "mac"),
            "-data", workspace_dir,
          },
          root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
          settings = { java = {} },
          init_options = { bundles = {} },
        }

        require("jdtls").start_or_attach(config)
      end,
    })
  end,
}
