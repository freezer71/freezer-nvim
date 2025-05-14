return {
  'rmagatti/auto-session',
  lazy = false,
	config = function()
    require('auto-session').setup {
        auto_restore_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
        suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    }
  end
}
