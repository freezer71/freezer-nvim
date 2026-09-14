local magick = {
  -- whole pages for the PDF viewer: the default trims the margins
  pdf = { "-density", 192, "{src}[{page}]", "-background", "white", "-alpha", "remove" },
}
-- ImageMagick extracts video frames through ffmpeg with a webp intermediate by default,
-- but Homebrew's ffmpeg has no webp encoder: use pam instead
for _, ext in ipairs({ "mp4", "mov", "avi", "mkv", "webm" }) do
  local args = { "-define", "video:intermediate-format=pam", "{src}[0]", "-scale", "1920x1080>" }
  magick[ext], magick[ext:upper()] = args, args
end

return {
  "folke/snacks.nvim",

  ---@type snacks.Config
  opts = {
    -- render images, video first frames and PDFs in buffers (Kitty graphics protocol, needs ImageMagick)
    image = {
      enabled = true,
      convert = { magick = magick },
    },
    explorer = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          exclude = {
            "**/node_modules/**",
            "**/.git/**",
            "**/.next/**",
            "**/dist/**",
            "**/build/**",
            "**/.turbo/**",
            "**/.cache/**",
            "**/coverage/**",
            "*.bru",
          },
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
