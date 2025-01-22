return {
  -- amongst your other plugins
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require('toggleterm').setup({
        size = 20,           -- Taille du terminal (en lignes ou colonnes)
        -- open_mapping = [[<c-\>]], -- Raccourci pour ouvrir/fermer ToggleTerm
        hide_numbers = true, -- Cache le numéro des lignes dans le terminal
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,       -- Luminosité du terminal (1 à 3)
        start_in_insert = true,   -- Démarre en mode Insert
        insert_mappings = true,   -- Autorise les raccourcis en mode Insert
        terminal_mappings = true, -- Active les mappings pour le terminal
        persist_size = true,
        direction = 'float',      -- Peut être 'horizontal', 'vertical', 'tab' ou 'float'
        close_on_exit = true,     -- Ferme le terminal quand le processus se termine
        shell = vim.o.shell,      -- Utilise le shell par défaut
        float_opts = {
          border = 'curved',      -- Bordure : 'single', 'double', 'shadow', 'curved', etc.
          winblend = 3,
        },
      })
      -- require("toggleterm").setup({
      -- 	direction = 'float',
      -- })
    end
  },
  -- or
}
