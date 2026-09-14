local util = require("media.util")

local M = {}

local videos = { mp4 = true, mov = true, avi = true, mkv = true, webm = true }

---@param file string
local function is_video(file)
  return videos[vim.fn.fnamemodify(file, ":e"):lower()] == true
end

local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

---@param w number
---@param h number
local function dimensions(w, h)
  local g = gcd(w, h)
  local ratio = (w / g <= 32 and h / g <= 32) and ("%d:%d"):format(w / g, h / g) or ("%.2f:1"):format(w / h)
  local mp = w * h >= 1e5 and ("%.1f MP"):format(w * h / 1e6) or nil
  return util.join(" · ", ("%d × %d px"):format(w, h), ratio, mp)
end

---@param value? string EXIF rational like "18/10"
local function rational(value)
  local a, b = (value or ""):match("^%s*(%-?%d+)/(%d+)")
  if a and tonumber(b) ~= 0 then
    return tonumber(a) / tonumber(b)
  end
  return tonumber(value)
end

---@param value? string EXIF GPS coordinate like "48/1, 51/1, 2436/100"
---@param ref? string
local function coordinate(value, ref)
  local parts = vim.split(value or "", ",%s*")
  local deg = rational(parts[1])
  return deg and ("%.5f°%s"):format(deg + (rational(parts[2]) or 0) / 60 + (rational(parts[3]) or 0) / 3600, ref or "")
end

---@alias media.viewer.add fun(label: string, value?: string|number|false)

---@param exif table<string, string>
---@param add media.viewer.add
local function exif_info(exif, add)
  local make, model = exif.Make, exif.Model
  if make and model and model:lower():find(make:lower(), 1, true) == 1 then
    make = nil -- the model usually already contains the brand
  end
  add("Camera", util.join(" ", make, model))
  add("Lens", exif.LensModel)
  add("Taken", exif.DateTimeOriginal and (exif.DateTimeOriginal:gsub("^(%d+):(%d+):(%d+)", "%1-%2-%3")))
  local exposure, fnumber, focal = rational(exif.ExposureTime), rational(exif.FNumber), rational(exif.FocalLength)
  local iso = exif.PhotographicSensitivity or exif.ISOSpeedRatings
  add(
    "Exposure",
    util.join(
      " · ",
      exposure and (exposure < 1 and ("1/%d s"):format(math.floor(1 / exposure + 0.5)) or ("%g s"):format(exposure)),
      fnumber and ("f/%g"):format(math.floor(fnumber * 10 + 0.5) / 10),
      iso and ("ISO " .. iso),
      focal and ("%g mm"):format(focal)
    )
  )
  if exif.GPSLatitude and exif.GPSLongitude then
    add(
      "Location",
      util.join(", ", coordinate(exif.GPSLatitude, exif.GPSLatitudeRef), coordinate(exif.GPSLongitude, exif.GPSLongitudeRef))
    )
  end
end

---@param file string
---@param add media.viewer.add
---@param done fun()
local function image_info(file, add, done)
  local format = "%m|%w|%h|%[colorspace]|%z|%A|%x|%y|%U|%Q|%[icc:description]\\n%[EXIF:*]"
  vim.system({ "magick", "identify", "-ping", "-format", format, file .. "[0]" }, { text = true }, function(r)
    vim.schedule(function()
      local lines = vim.split(r.stdout or "", "\n", { trimempty = true })
      local f = vim.split(lines[1] or "", "|", { plain = true })
      if #f >= 11 then
        local w, h = tonumber(f[2]), tonumber(f[3])
        add("Format", f[1])
        add("Dimensions", w and h and dimensions(w, h))
        add("Color", util.join(" · ", f[4], f[5] ~= "" and (f[5] .. "-bit"), (f[6] == "Blend" or f[6] == "True") and "alpha"))
        add("Profile", f[11])
        if f[9] ~= "Undefined" and tonumber(f[7]) then
          local unit = f[9] == "PixelsPerCentimeter" and "px/cm" or "dpi"
          add("Density", ("%g × %g %s"):format(tonumber(f[7]), tonumber(f[8]) or 0, unit))
        end
        add("Quality", f[1] == "JPEG" and tonumber(f[10]) and f[10])
      end
      local exif = {} ---@type table<string, string>
      for i = 2, #lines do
        local key, value = lines[i]:match("^exif:([^=]+)=(.*)$")
        if key then
          exif[key] = vim.trim(value)
        end
      end
      exif_info(exif, add)

      local ext = vim.fn.fnamemodify(file, ":e"):lower()
      if ext ~= "gif" and ext ~= "webp" then
        return done()
      end
      vim.system({ "magick", "identify", "-ping", "-format", "%n\\n", file }, { text = true }, function(frames)
        vim.schedule(function()
          local n = tonumber((frames.stdout or ""):match("^(%d+)"))
          add("Frames", n and n > 1 and n)
          done()
        end)
      end)
    end)
  end)
end

---@param file string
---@param add media.viewer.add
---@param done fun()
local function video_info(file, add, done)
  local cmd = { "ffprobe", "-v", "error", "-show_format", "-show_streams", "-of", "json", file }
  vim.system(cmd, { text = true }, function(r)
    vim.schedule(function()
      local ok, data = pcall(vim.json.decode, r.stdout or "", { luanil = { object = true, array = true } })
      if not ok or type(data) ~= "table" then
        return done()
      end
      local format, streams = data.format or {}, data.streams or {}
      local video = vim.tbl_filter(function(s)
        return s.codec_type == "video" and not (s.disposition and s.disposition.attached_pic == 1)
      end, streams)[1]
      local audio = vim.tbl_filter(function(s)
        return s.codec_type == "audio"
      end, streams)[1]

      add("Format", format.format_long_name)
      add("Duration", tonumber(format.duration) and util.format_time(tonumber(format.duration)))
      if video then
        local num, den = (video.avg_frame_rate or ""):match("^(%d+)/(%d+)$")
        local fps = num and tonumber(den) > 0 and tonumber(num) / tonumber(den)
        add("Dimensions", video.width and video.height and dimensions(video.width, video.height))
        add("Video", util.join(" · ", video.codec_name, fps and ("%g fps"):format(math.floor(fps * 100 + 0.5) / 100), video.pix_fmt))
      end
      if audio then
        local rate = tonumber(audio.sample_rate)
        add("Audio", util.join(" · ", audio.codec_name, rate and ("%g kHz"):format(rate / 1000), audio.channel_layout))
      end
      local bitrate = tonumber(format.bit_rate)
      if bitrate then
        add("Bitrate", bitrate >= 1e6 and ("%.1f Mb/s"):format(bitrate / 1e6) or ("%d kb/s"):format(math.floor(bitrate / 1000)))
      end
      done()
    end)
  end)
end

---@param file string
---@param info {[1]: string, [2]: string}[]
---@return media.Row[]
local function rows(file, info)
  local stat = vim.uv.fs_stat(file)
  local items = vim.list_extend(vim.deepcopy(info), {
    { "File size", stat and util.human_size(stat.size) },
    { "Modified", util.modified(file) },
  })
  local ret = { { { vim.fn.fnamemodify(file, ":t"), "Title" }, center = true }, { center = true } }
  vim.list_extend(ret, util.info_rows(items))
  ret[#ret + 1] = { center = true }
  ret[#ret + 1] = { { "o", "Special" }, { is_video(file) and " play in mpv" or " open externally", "Comment" }, center = true }
  return ret
end

---@param file string
function M.open_external(file)
  if is_video(file) and vim.fn.executable("mpv") == 1 then
    vim.system({ "mpv", "--", file }, { detach = true })
  else
    vim.ui.open(file)
  end
end

--- Takes over a snacks image buffer: centered image with the file metadata below
---@param buf number
function M.attach(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  -- only real files: snacks picker previews use image buffers too
  if vim.bo[buf].buftype ~= "" or vim.fn.filereadable(file) == 0 then
    return
  end
  local img = Snacks.image.image.new(file) -- the image snacks is loading for its default placement
  local function valid()
    return vim.api.nvim_buf_is_valid(buf)
  end
  -- replace the default top-left placement only once it's ready: a placement closed while loading
  -- keeps clearing the image extmarks, and its spinner timer needs a tick to notice it's done
  util.wait_image(img, function()
    if img:failed() then
      return -- snacks shows the conversion error
    end
    vim.defer_fn(function()
      if valid() then
        M.show(buf, file)
      end
    end, 150)
  end, valid)
end

---@param buf number
---@param file string
function M.show(buf, file)
  Snacks.image.placement.clean(buf)
  -- the loading spinner of the default placement isn't removed once the image is ready
  vim.api.nvim_buf_clear_namespace(buf, Snacks.image.placement.ns, 0, -1)
  local canvas = util.canvas(buf, { align = "block" })
  if vim.fn.fnamemodify(file, ":e"):lower() == "pdf" then
    return require("media.pdf").attach(buf, file, canvas)
  end
  local info = {} ---@type {[1]: string, [2]: string}[]
  canvas.rows = rows(file, info)
  canvas:render()
  canvas:set_image(file)

  local function add(label, value)
    if value and value ~= "" then
      info[#info + 1] = { label, tostring(value) }
    end
  end
  local fetch = is_video(file) and video_info or image_info
  fetch(file, add, function()
    if vim.api.nvim_buf_is_valid(buf) then
      canvas.rows = rows(file, info)
      canvas:render()
    end
  end)

  vim.keymap.set("n", "o", function()
    M.open_external(file)
  end, { buffer = buf, nowait = true, desc = "Open externally" })
end

return M
