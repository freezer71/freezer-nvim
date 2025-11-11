vim.api.nvim_create_user_command('BuildRunJava', function()
  local file = vim.fn.expand('%:p')
  local class = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  -- Crée la commande complète
  local cmd = string.format("javac '%s' && java -cp '%s' %s", file, dir, class)

  -- Ouvre un terminal dans Neovim (split horizontal)
  vim.cmd("split | terminal")
  vim.cmd(string.format("call chansend(b:terminal_job_id, '%s\\n')", cmd))
end, {})
