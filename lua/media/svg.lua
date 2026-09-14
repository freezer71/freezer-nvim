local util = require("media.util")

local M = {}

local dir = util.cache .. "/svg"

---@class media.svg.Preview
---@field buf? number preview buffer
---@field win? number preview window
---@field canvas? media.Canvas
---@field timer uv.uv_timer_t
---@field hash? string content of the latest render
---@field image? string
---@field files table<string, boolean> rendered images, deleted when the preview closes
---@field disabled? boolean
---@field closing? boolean
local previews = {} ---@type table<number, media.svg.Preview>

---@param src number
---@param text string
---@param status media.Row
local function rows(src, text, status)
  local svg = text:match("<svg[^>]*>") or ""
  local w, h = svg:match('%swidth="([^"]*)"'), svg:match('%sheight="([^"]*)"')
  local ret = {
    { { vim.fn.fnamemodify(vim.api.nvim_buf_get_name(src), ":t"), "Title" }, center = true },
    status,
    { center = true },
  }
  return vim.list_extend(
    ret,
    util.info_rows({
      { "Size", w and h and (w .. " × " .. h) },
      { "viewBox", svg:match('%sviewBox="([^"]*)"') },
      { "File size", util.human_size(#text) },
    })
  )
end

---@param src number
function M.render(src)
  local state = previews[src]
  if not (state and state.canvas and state.win and vim.api.nvim_win_is_valid(state.win)) then
    return
  end
  local text = table.concat(vim.api.nvim_buf_get_lines(src, 0, -1, false), "\n")
  local hash = vim.fn.sha256(text):sub(1, 16)
  if hash == state.hash then
    return
  end
  state.hash = hash
  local cells = vim.api.nvim_win_get_width(state.win)
  local width = math.max(256, math.min(2048, cells * Snacks.image.terminal.size().cell_width))
  local png = ("%s/%s-%d.png"):format(dir, hash, width)
  local start = vim.uv.hrtime()

  ---@param err? string
  ---@param cached? boolean
  local function show(err, cached)
    if state.hash ~= hash or not state.canvas then
      return -- a newer version is being rendered
    end
    local ms = math.floor((vim.uv.hrtime() - start) / 1e6)
    local status = err
        and { { "✗ ", "DiagnosticError" }, { util.truncate((err:gsub("%s+", " ")), cells - 6), "DiagnosticError" }, center = true }
      or { { "✓ ", "DiagnosticOk" }, { cached and "rendered" or ("rendered in %d ms"):format(ms), "Comment" }, center = true }
    state.canvas.rows = rows(src, text, status)
    state.canvas:render()
    if not err then
      state.files[png] = true
      if state.image ~= png then
        state.image = png
        state.canvas:set_image(png) -- the last valid render stays visible while the SVG is invalid
      end
    end
  end

  if vim.uv.fs_stat(png) then
    return show()
  end
  vim.fn.mkdir(dir, "p")
  local cmd = { "rsvg-convert", "--width", tostring(width), "--keep-aspect-ratio", "--background-color", "white", "-o", png }
  vim.system(cmd, { stdin = text, text = true }, function(r)
    vim.schedule(function()
      if r.code ~= 0 then
        os.remove(png)
      end
      local err = vim.trim(r.stderr or "")
      show(r.code ~= 0 and (err ~= "" and err or "rsvg-convert failed") or nil)
    end)
  end)
end

---@param src number
---@param ms number
function M.schedule(src, ms)
  local state = previews[src]
  if state then
    state.timer:stop()
    state.timer:start(ms, 0, function()
      vim.schedule(function()
        M.render(src)
      end)
    end)
  end
end

---@param src number
function M.open(src)
  local state = previews[src]
  local src_win = vim.fn.bufwinid(src)
  if not state or state.disabled or src_win == -1 or (state.win and vim.api.nvim_win_is_valid(state.win)) then
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "svgpreview"
  local win = vim.api.nvim_open_win(buf, false, { split = "right", win = src_win })
  Snacks.util.wo(win, {
    number = false,
    relativenumber = false,
    signcolumn = "no",
    foldcolumn = "0",
    statuscolumn = "",
    cursorline = false,
    list = false,
    spell = false,
    wrap = false,
    winfixbuf = true,
  })
  state.buf, state.win, state.hash, state.image = buf, win, nil, nil
  state.canvas = util.canvas(buf, { align = "block" })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      state.disabled = state.disabled or not state.closing -- closed by hand: stays closed until toggled
      state.buf, state.win, state.canvas, state.image, state.closing = nil, nil, nil, nil, nil
      for file in pairs(state.files) do
        os.remove(file)
      end
      state.files = {}
    end,
  })
  M.render(src)
end

---@param src number
function M.close(src)
  local state = previews[src]
  if state and state.win and vim.api.nvim_win_is_valid(state.win) then
    state.closing = true
    pcall(vim.api.nvim_win_close, state.win, true)
  end
end

---@param src number
function M.toggle(src)
  local state = previews[src]
  if not state then
    return
  end
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close(src)
    state.disabled = true
  else
    state.disabled = false
    M.open(src)
  end
end

--- Deletes the rendered previews
function M.cleanup()
  for _, state in pairs(previews) do
    for file in pairs(state.files) do
      os.remove(file)
    end
    state.files = {}
  end
end

--- Live preview of an SVG buffer in a split next to it
---@param src number
function M.attach(src)
  if vim.bo[src].buftype ~= "" or previews[src] then
    return
  end
  if vim.fn.executable("rsvg-convert") == 0 then
    return Snacks.notify.warn("`rsvg-convert` is required for the SVG preview (`brew install librsvg`)")
  end
  previews[src] = { timer = assert(vim.uv.new_timer()), files = {} }

  local group = vim.api.nvim_create_augroup("media.svg." .. src, { clear = true })
  local function on(events, callback)
    vim.api.nvim_create_autocmd(events, { group = group, buffer = src, callback = callback })
  end
  on({ "TextChanged", "TextChangedI", "TextChangedP" }, function()
    M.schedule(src, 150)
  end)
  on("BufWinEnter", function()
    vim.schedule(function()
      M.open(src)
    end)
  end)
  on("BufWinLeave", function()
    vim.schedule(function()
      if vim.fn.bufwinid(src) == -1 then
        M.close(src)
      end
    end)
  end)
  -- don't leave the preview as the last window when quitting the SVG
  on("QuitPre", function()
    local state = previews[src]
    local current = vim.api.nvim_get_current_win()
    local others = vim.tbl_filter(function(win)
      return win ~= current and win ~= (state and state.win) and vim.api.nvim_win_get_config(win).relative == ""
    end, vim.api.nvim_tabpage_list_wins(0))
    if #others == 0 then
      M.close(src)
    end
  end)
  on({ "BufWipeout", "BufDelete" }, function()
    M.close(src)
    local state = previews[src]
    previews[src] = nil
    if state and not state.timer:is_closing() then
      state.timer:stop()
      state.timer:close()
    end
    vim.schedule(function()
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end)
  end)

  vim.keymap.set("n", "<leader>cp", function()
    M.toggle(src)
  end, { buffer = src, desc = "Toggle SVG Preview" })
  vim.schedule(function()
    M.open(src)
  end)
end

return M
