vim.api.nvim_create_user_command('BuildRunJava', function()
  -- Récupère le chemin complet du fichier actuel
  local file = vim.fn.expand('%:p')
  local class = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')

  -- Commandes Java
  local compile_cmd = string.format("javac %s", file)
  local run_cmd = string.format("java -cp %s %s", dir, class)

  -- Ouvre un terminal dans un split et exécute la commande
  vim.cmd("vsplit | terminal")
  vim.cmd(string.format("call chansend(b:terminal_job_id, '%s && %s\\n')", compile_cmd, run_cmd))
end, {})
