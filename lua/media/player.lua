local util = require("media.util")

local M = {}

local icons = {
  play = vim.fn.nr2char(0xf04b),
  pause = vim.fn.nr2char(0xf04c),
  music = vim.fn.nr2char(0xf075a),
  volume = vim.fn.nr2char(0xf057e),
  mute = vim.fn.nr2char(0xf0581),
  loop = vim.fn.nr2char(0xf0456),
}

local ROWS = 6 -- title, artist, gap, progress, gap, controls
local observed = { "time-pos", "duration", "pause", "volume", "mute", "metadata", "media-title", "loop-file", "speed" }

---@class media.Player
---@field file string
---@field buf number
---@field win number
---@field sock string mpv IPC socket
---@field proc? vim.SystemObj
---@field pipe? uv.uv_pipe_t
---@field timer uv.uv_timer_t
---@field canvas media.Canvas
---@field props table<string, any> observed mpv properties
---@field dirty? boolean
local player ---@type media.Player?
local opening ---@type table? token of the latest open request

local function highlights()
  for name, link in pairs({ Played = "Special", Knob = "Title", Track = "NonText", Icon = "Special", Muted = "Comment" }) do
    vim.api.nvim_set_hl(0, "MediaPlayer" .. name, { link = link, default = true })
  end
end

--- Sends a command to mpv
---@param ... any
local function send(...)
  local p = player
  if p and p.pipe and not p.pipe:is_closing() then
    p.pipe:write(vim.json.encode({ command = { ... } }) .. "\n")
  end
end

---@param p media.Player
---@param tries number
local function connect(p, tries)
  local pipe = assert(vim.uv.new_pipe(false))
  pipe:connect(p.sock, function(err)
    if player ~= p or err then
      pipe:close()
      if player == p and tries > 0 then
        vim.defer_fn(function()
          connect(p, tries - 1)
        end, 50)
      end
      return
    end
    p.pipe = pipe
    local pending = ""
    pipe:read_start(function(_, data)
      if not data then
        return
      end
      pending = pending .. data
      for line in pending:gmatch("([^\n]*)\n") do
        local ok, msg = pcall(vim.json.decode, line, { luanil = { object = true, array = true } })
        if ok and type(msg) == "table" and msg.event == "property-change" then
          p.props[msg.name] = msg.data
          p.dirty = true
        end
      end
      pending = pending:match("[^\n]*$")
    end)
    for i, name in ipairs(observed) do
      send("observe_property", i, name)
    end
  end)
end

function M.render()
  local p = player
  if not (p and vim.api.nvim_win_is_valid(p.win)) then
    return
  end
  local props, meta = p.props, {} ---@type table<string, any>, table<string, string>
  for key, value in pairs(props.metadata or {}) do
    meta[key:lower()] = value
  end
  local width = vim.api.nvim_win_get_width(p.win) - 4

  local pos, duration = props["time-pos"] or 0, props.duration or 0
  local elapsed, total = util.format_time(pos), util.format_time(duration)
  local icon = props.pause and icons.play or icons.pause
  local bar = math.max(10, width - vim.api.nvim_strwidth(icon .. "  " .. elapsed .. " ") - #total - 1)
  local done = duration > 0 and math.floor(math.min(1, pos / duration) * (bar - 1) + 0.5) or 0

  local volume = math.floor(props.volume or 100)
  local level = math.floor(math.min(volume, 100) / 10 + 0.5)
  local muted = props.mute or volume == 0
  local loop = props["loop-file"] and props["loop-file"] ~= "no"
  local speed = props.speed or 1

  p.canvas.rows = {
    { { util.truncate(meta.title or props["media-title"] or vim.fn.fnamemodify(p.file, ":t"), width), "Title" } },
    { { util.truncate(util.join(" — ", meta.artist, meta.album), width), "Comment" } },
    {},
    {
      { icon, "MediaPlayerIcon", "pause" },
      { "  " },
      { elapsed, "Comment" },
      { " " },
      { ("━"):rep(done), "MediaPlayerPlayed", "seek" },
      { "●", "MediaPlayerKnob", "seek" },
      { ("─"):rep(bar - done - 1), "MediaPlayerTrack", "seek" },
      { " " },
      { total, "Comment" },
    },
    {},
    {
      { muted and icons.mute or icons.volume, muted and "MediaPlayerMuted" or "MediaPlayerIcon", "mute" },
      { " " },
      { ("━"):rep(level), muted and "MediaPlayerMuted" or "MediaPlayerPlayed", "volume" },
      { ("─"):rep(10 - level), "MediaPlayerTrack", "volume" },
      { (" %3d%%"):format(volume), "Comment" },
      { "     " },
      { icons.loop .. " loop", loop and "MediaPlayerIcon" or "Comment", "loop" },
      { "     " },
      { ("%.2g×"):format(speed), speed ~= 1 and "MediaPlayerIcon" or "Comment", "speed" },
    },
  }
  p.canvas:render()
end

local function click()
  local p = player
  if not p then
    return
  end
  local id, offset, width = p.canvas:click()
  if id == "seek" then
    send("seek", offset / math.max(1, width - 1) * 100, "absolute-percent")
  elseif id == "volume" then
    send("set_property", "volume", math.floor((offset + 1) / width * 100 + 0.5))
  elseif id == "pause" then
    send("cycle", "pause")
  elseif id == "mute" then
    send("cycle", "mute")
  elseif id == "loop" then
    send("cycle-values", "loop-file", "inf", "no")
  elseif id == "speed" then
    send("set_property", "speed", 1)
  end
end

---@param buf number
local function keymaps(buf)
  local function map(lhs, rhs, desc)
    for _, key in ipairs(type(lhs) == "table" and lhs or { lhs }) do
      vim.keymap.set("n", key, rhs, { buffer = buf, nowait = true, silent = true, desc = desc })
    end
  end
  local function cmd(...)
    local args = { ... }
    return function()
      send(unpack(args))
    end
  end
  map({ "<Space>", "p", "<CR>" }, cmd("cycle", "pause"), "Play/Pause")
  map({ "<Left>", "h" }, cmd("seek", -5), "Back 5s")
  map({ "<Right>", "l" }, cmd("seek", 5), "Forward 5s")
  map({ "<S-Left>", "H" }, cmd("seek", -30), "Back 30s")
  map({ "<S-Right>", "L" }, cmd("seek", 30), "Forward 30s")
  map({ "<Up>", "k", "+", "=", "<ScrollWheelUp>" }, cmd("add", "volume", 5), "Volume up")
  map({ "<Down>", "j", "-", "<ScrollWheelDown>" }, cmd("add", "volume", -5), "Volume down")
  map("m", cmd("cycle", "mute"), "Mute")
  map("r", cmd("cycle-values", "loop-file", "inf", "no"), "Loop")
  map("[", cmd("multiply", "speed", 1 / 1.1), "Slower")
  map("]", cmd("multiply", "speed", 1.1), "Faster")
  map("<BS>", cmd("set_property", "speed", 1), "Normal speed")
  for i = 0, 9 do
    map(tostring(i), cmd("seek", i * 10, "absolute-percent"), ("Jump to %d%%"):format(i * 10))
  end
  map({ "q", "<Esc>" }, M.close, "Stop")
  map({ "<LeftMouse>", "<2-LeftMouse>", "<LeftDrag>" }, click, "Click")
  -- it's a UI, not text
  map({ "i", "a", "o", "I", "A", "O", "v", "V", "<C-v>", "x", "d", "c", "s", "u" }, "<Nop>")
end

---@param file string
---@param cover? string
local function start(file, cover)
  highlights()
  local cover_h = cover and math.max(4, math.min(12, vim.o.lines - ROWS - 12)) or 0
  local width = math.min(70, vim.o.columns - 4)
  local height = ROWS + (cover and cover_h + 1 or 0) + 2
  local footer = " ␣ pause · ←/→ seek · ↑/↓ volume · m mute · r loop · q quit "

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "mediaplayer"
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = (" %s  Now Playing "):format(icons.music),
    title_pos = "center",
    footer = vim.api.nvim_strwidth(footer) + 2 <= width and footer or nil,
    footer_pos = vim.api.nvim_strwidth(footer) + 2 <= width and "center" or nil,
  })
  vim.wo[win].winfixbuf = true

  ---@type media.Player
  local p = {
    file = file,
    buf = buf,
    win = win,
    sock = vim.fn.tempname() .. ".sock",
    props = {},
    timer = assert(vim.uv.new_timer()),
    canvas = util.canvas(buf, { max_image = cover and { height = cover_h } or nil }),
  }
  player = p
  p.proc = vim.system({ "mpv", "--no-video", "--no-terminal", "--input-ipc-server=" .. p.sock, "--", file }, {}, function(r)
    vim.schedule(function()
      if player == p then
        if r.code ~= 0 then
          Snacks.notify.error(("mpv exited with code %d"):format(r.code), { title = "Media Player" })
        end
        M.close() -- playback ended
      end
    end)
  end)
  connect(p, 60)
  p.timer:start(100, 100, function()
    if player == p and p.dirty then
      p.dirty = false
      vim.schedule(M.render)
    end
  end)

  keymaps(buf)
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      if player == p then
        vim.schedule(M.close) -- the window was closed by hand
      end
    end,
  })
  M.render()
  if cover then
    p.canvas:set_image(cover)
  end
end

--- Plays an audio file in a floating player
---@param file string
function M.open(file)
  if vim.fn.executable("mpv") == 0 then
    return Snacks.notify.warn("`mpv` is required to play audio files (`brew install mpv`)")
  end
  M.close()
  local token = {}
  opening = token
  local cover = ("%s/covers/%s.png"):format(util.cache, vim.fn.sha256(file):sub(1, 16))
  if vim.uv.fs_stat(cover) then
    return start(file, cover)
  end
  vim.fn.mkdir(vim.fs.dirname(cover), "p")
  vim.system({ "ffmpeg", "-y", "-loglevel", "error", "-i", file, "-an", "-frames:v", "1", cover }, {}, function(r)
    vim.schedule(function()
      if r.code ~= 0 then
        os.remove(cover) -- no embedded cover art
      end
      if opening == token then
        start(file, r.code == 0 and cover or nil)
      end
    end)
  end)
end

--- Stops the playback and closes the player
function M.close()
  opening = nil
  local p = player
  if not p then
    return
  end
  player = nil
  p.timer:stop()
  if not p.timer:is_closing() then
    p.timer:close()
  end
  if p.pipe and not p.pipe:is_closing() then
    p.pipe:close()
  end
  if p.proc then
    pcall(p.proc.kill, p.proc, 15)
  end
  if vim.api.nvim_win_is_valid(p.win) then
    pcall(vim.api.nvim_win_close, p.win, true)
  end
  os.remove(p.sock)
end

return M
