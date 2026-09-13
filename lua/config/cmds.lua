vim.api.nvim_create_user_command("BuildRunJava", function()
  vim.cmd("update")
  local file = vim.fn.expand("%:p")
  local class = vim.fn.expand("%:t:r")
  local dir = vim.fn.expand("%:p:h")

  -- Crée la commande complète
  local cmd = string.format(
    "javac %s && java -cp %s %s",
    vim.fn.shellescape(file),
    vim.fn.shellescape(dir),
    vim.fn.shellescape(class)
  )

  -- Ouvre un terminal dans Neovim (split horizontal)
  vim.cmd("split | terminal")
  vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\n")
end, {})
