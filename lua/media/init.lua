local M = {}

M.audio = { "mp3", "wav", "flac", "ogg", "m4a", "aac", "opus", "aiff" }

function M.setup()
  local group = vim.api.nvim_create_augroup("media", { clear = true })

  -- audio can't be rendered in a buffer: play it in a floating player instead of showing the binary
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = group,
    pattern = "*." .. table.concat(M.audio, ",*."),
    callback = function(ev)
      local file = vim.api.nvim_buf_get_name(ev.buf)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          Snacks.bufdelete(ev.buf)
        end
        require("media.player").open(file)
      end)
    end,
  })

  -- images and videos rendered by snacks.image: center them and show their metadata
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "image",
    callback = function(ev)
      require("media.viewer").attach(ev.buf)
    end,
  })

  -- snacks renders the images referenced in documents inline (<img src>, url(), imports…):
  -- keep it for markdown & co, but it's too noisy in web code
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    callback = function(ev)
      vim.b[ev.buf].snacks_image_attached = true -- makes snacks skip the buffer
    end,
  })

  -- SVG: edit the code with a live preview next to it
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    pattern = "*.svg",
    callback = function(ev)
      require("media.svg").attach(ev.buf)
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if package.loaded["media.player"] then
        require("media.player").close()
      end
      if package.loaded["media.svg"] then
        require("media.svg").cleanup()
      end
    end,
  })
end

return M
