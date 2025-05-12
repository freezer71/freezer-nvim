return {
  'rmagatti/auto-session',
  lazy = false,
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
  },
	config = function()
    require('auto-session').setup {
        auto_restore_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
    }
  end
  -- setup = ()=>
}
