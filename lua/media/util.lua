local M = {}

M.cache = vim.fn.stdpath("cache") .. "/media"

---@param bytes number
function M.human_size(bytes)
  local units, i = { "B", "KB", "MB", "GB" }, 1
  while bytes >= 1024 and i < #units do
    bytes, i = bytes / 1024, i + 1
  end
  return (i == 1 and "%d %s" or "%.1f %s"):format(bytes, units[i])
end

---@param seconds? number
function M.format_time(seconds)
  seconds = math.max(0, math.floor(seconds or 0))
  local h, m, s = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60
  return h > 0 and ("%d:%02d:%02d"):format(h, m, s) or ("%02d:%02d"):format(m, s)
end

---@param file string
function M.modified(file)
  local stat = vim.uv.fs_stat(file)
  return stat and os.date("%Y-%m-%d %H:%M", stat.mtime.sec) or nil
end

--- Joins the non-empty values
---@param sep string
---@param ... any
function M.join(sep, ...)
  local ret = {} ---@type string[]
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if value and value ~= "" then
      ret[#ret + 1] = tostring(value)
    end
  end
  return table.concat(ret, sep)
end

---@param text string
---@param width number
function M.truncate(text, width)
  if vim.api.nvim_strwidth(text) <= width then
    return text
  end
  return vim.fn.strcharpart(text, 0, math.max(0, width - 1)) .. "…"
end

---@alias media.Chunk {[1]: string, [2]?: string, [3]?: string} text, highlight group, clickable area id
---@alias media.Row media.Chunk[]|{center?: boolean}

--- Label/value rows with right-aligned labels. Items without a value are skipped.
---@param items {[1]: string, [2]?: string|false}[]
---@return media.Row[]
function M.info_rows(items)
  items = vim.tbl_filter(function(item)
    return item[2] and item[2] ~= ""
  end, items)
  local width = 0
  for _, item in ipairs(items) do
    width = math.max(width, vim.api.nvim_strwidth(item[1]))
  end
  return vim.tbl_map(function(item)
    local label = (" "):rep(width - vim.api.nvim_strwidth(item[1])) .. item[1]
    return { { label, "Comment" }, { "  " }, { tostring(item[2]) } }
  end, items)
end

--- Hides the cursor and pins it (and the view) to the top, so that the buffer behaves like a UI instead of text
---@param buf number
function M.lock_cursor(buf)
  local group = vim.api.nvim_create_augroup("media.cursor." .. buf, { clear = true })
  local saved ---@type string?

  local function hide()
    if saved or vim.api.nvim_get_current_buf() ~= buf then
      return
    end
    local float = vim.api.nvim_win_get_config(0).relative ~= ""
    local bg = vim.api.nvim_get_hl(0, { name = float and "NormalFloat" or "Normal", link = false }).bg
    vim.api.nvim_set_hl(0, "MediaHiddenCursor", { fg = bg, bg = bg, blend = 100, nocombine = true })
    saved = vim.go.guicursor
    -- thin cursor in the background color, only in normal/visual modes so that the cmdline keeps its cursor
    local hidden = "n-v-ve-o-sm:ver1-MediaHiddenCursor"
    vim.go.guicursor = saved == "" and hidden or (saved .. "," .. hidden)
  end

  local function show()
    if saved then
      vim.go.guicursor, saved = saved, nil
    end
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, { group = group, buffer = buf, callback = hide })
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, { group = group, buffer = buf, callback = show })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function()
      show()
      vim.schedule(function()
        pcall(vim.api.nvim_del_augroup_by_id, group)
      end)
    end,
  })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = buf,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      if cursor[1] ~= 1 or cursor[2] ~= 0 then
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function()
      for id in pairs(vim.v.event) do
        local win = tonumber(id)
        if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_win_call(win, function()
            vim.fn.winrestview({ topline = 1, leftcol = 0 })
          end)
        end
      end
    end,
  })
  hide()
end

local ns = vim.api.nvim_create_namespace("media.canvas")

--- A buffer that shows an optional centered image with centered rows of text below it
---@class media.Canvas
---@field buf number
---@field rows media.Row[]
---@field align "center"|"block" center each row, or center all rows as one left-aligned block
---@field max_image? {width?: number, height?: number}
---@field placement? snacks.image.Placement
---@field hits {lnum: number, from: number, to: number, id: string}[] clickable areas (display columns)
---@field geometry? string
---@field pending? string
local Canvas = {}
Canvas.__index = Canvas

---@param buf number
---@param opts? {align?: "center"|"block", max_image?: {width?: number, height?: number}}
function M.canvas(buf, opts)
  opts = opts or {}
  local self = setmetatable({
    buf = buf,
    rows = {},
    hits = {},
    align = opts.align or "center",
    max_image = opts.max_image,
  }, Canvas)
  vim.bo[buf].modifiable = false
  M.lock_cursor(buf)
  local group = vim.api.nvim_create_augroup("media.canvas." .. buf, { clear = true })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized", "BufWinEnter" }, {
    group = group,
    callback = vim.schedule_wrap(function()
      if vim.api.nvim_buf_is_valid(buf) then
        self:render()
      else
        pcall(vim.api.nvim_del_augroup_by_id, group)
      end
    end),
  })
  return self
end

---@return number?
function Canvas:win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == self.buf then
      return win
    end
  end
end

--- Calls `cb` once the image is converted (or failed to)
---@param img snacks.Image
---@param cb fun()
---@param valid fun(): boolean stops waiting when it returns false
function M.wait_image(img, cb, valid)
  local start = vim.uv.hrtime()
  local function check()
    if not valid() then
      return
    elseif img:ready() or img:failed() then
      return cb()
    end
    vim.defer_fn(check, vim.uv.hrtime() - start > 1e9 and 100 or 20)
  end
  check()
end

--- Shows an image above the rows. The previous image stays visible until the new one is ready.
---@param src string
function Canvas:set_image(src)
  self.pending = src
  -- only place converted images: a snacks placement closed while loading keeps clearing the image extmarks
  M.wait_image(Snacks.image.image.new(src), function()
    if self.placement then
      self.placement:close()
    end
    self.geometry = nil
    self.placement = Snacks.image.placement.new(self.buf, src, {
      conceal = true,
      auto_resize = true,
      on_update_pre = function(p)
        self:layout(p)
      end,
    })
    self:render()
  end, function()
    return self.pending == src and vim.api.nvim_buf_is_valid(self.buf)
  end)
end

function Canvas:render()
  if not vim.api.nvim_buf_is_valid(self.buf) then
    return
  end
  local p = self.placement
  if p and p.img:failed() then
    return -- snacks shows the conversion error
  end
  if self:layout(p) and p and p:ready() then
    p:update()
  end
end

--- Writes the rows to the buffer and positions the image.
--- Only the rows are rewritten when the geometry didn't change, so that the image isn't redrawn.
---@param p? snacks.image.Placement
---@return boolean changed whether the whole layout changed
function Canvas:layout(p)
  local win = self:win()
  if not win then
    return false
  end
  local W, H = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
  local R = #self.rows
  local gap = R > 0 and 1 or 0

  local img ---@type snacks.image.Size?
  if p and p:ready() then
    local max = self.max_image or {}
    p.opts.max_width = math.max(1, math.min(W - 4, max.width or W))
    p.opts.max_height = math.max(1, math.min(H - R - gap - 2, max.height or H))
    img = Snacks.image.util.fit(p.img.file, { width = p.opts.max_width, height = p.opts.max_height }, { info = p.img.info })
    if not (img.width < math.huge and img.height < math.huge) then
      -- the terminal doesn't report its size in pixels: drop the image so that the rows stay usable
      img = nil
      vim.schedule(function()
        if self.placement == p then
          p:close()
          self.placement, self.geometry = nil, nil
          self:render()
        end
      end)
    end
  end

  -- the first image row is drawn on the anchor line, the other ones as virtual lines
  local top = math.max(0, math.floor((H - (img and img.height + gap or 0) - R) / 2))
  local first = top + (img and 1 + gap or 0) -- 0-based line of the first row

  local widths, block = {}, 0 ---@type number[], number
  for i, row in ipairs(self.rows) do
    local text = {} ---@type string[]
    for _, chunk in ipairs(row) do
      text[#text + 1] = chunk[1]
    end
    widths[i] = vim.api.nvim_strwidth(table.concat(text))
    if not row.center then
      block = math.max(block, widths[i])
    end
  end

  local lines, hls = {}, {} ---@type string[], {[1]: number, [2]: number, [3]: number, [4]: string}[]
  self.hits = {}
  for i, row in ipairs(self.rows) do
    local centered = self.align == "center" or row.center
    local pad = math.max(0, math.floor((W - (centered and widths[i] or block)) / 2))
    local parts, col, dcol = { (" "):rep(pad) }, pad, pad
    for _, chunk in ipairs(row) do
      local text, width = chunk[1], vim.api.nvim_strwidth(chunk[1])
      if chunk[2] and #text > 0 then
        hls[#hls + 1] = { first + i - 1, col, col + #text, chunk[2] }
      end
      if chunk[3] then
        local last = self.hits[#self.hits]
        if last and last.id == chunk[3] and last.lnum == first + i and last.to == dcol then
          last.to = dcol + width -- adjacent chunks with the same id form one area
        else
          self.hits[#self.hits + 1] = { lnum = first + i, from = dcol, to = dcol + width, id = chunk[3] }
        end
      end
      parts[#parts + 1] = text
      col, dcol = col + #text, dcol + width
    end
    lines[i] = table.concat(parts)
  end

  local geometry = table.concat({ W, H, R, top, img and img.width or 0, img and img.height or 0 }, ":")
  local changed = geometry ~= self.geometry or vim.api.nvim_buf_line_count(self.buf) < first
  self.geometry = geometry
  if changed then
    for _ = 1, first do
      table.insert(lines, 1, "")
    end
    if img and p then
      p.opts.pos = { top + 1, math.floor((W - img.width) / 2) }
      p._state = nil -- force the placement to render again
    end
  end

  vim.bo[self.buf].modifiable = true
  vim.api.nvim_buf_set_lines(self.buf, changed and 0 or first, -1, false, lines)
  vim.bo[self.buf].modifiable = false
  vim.bo[self.buf].modified = false
  vim.api.nvim_buf_clear_namespace(self.buf, ns, changed and 0 or first, -1)
  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(self.buf, ns, hl[1], hl[2], { end_col = hl[3], hl_group = hl[4] })
  end
  return changed
end

--- Clickable area at a buffer line and display column
---@param lnum number 1-based
---@param col number 0-based display column
---@return string? id, number offset, number width
function Canvas:hit(lnum, col)
  for _, hit in ipairs(self.hits) do
    if hit.lnum == lnum and col >= hit.from and col < hit.to then
      return hit.id, col - hit.from, hit.to - hit.from
    end
  end
  return nil, 0, 0
end

--- Handles a mouse click: returns the clicked area, or focuses the clicked window when it's outside of the canvas
---@return string? id, number offset, number width
function Canvas:click()
  local mouse = vim.fn.getmousepos()
  local win = self:win()
  if mouse.winid ~= win then
    if mouse.winid ~= 0 and vim.api.nvim_win_get_config(mouse.winid).focusable ~= false then
      vim.api.nvim_set_current_win(mouse.winid)
      pcall(vim.api.nvim_win_set_cursor, mouse.winid, { math.max(1, mouse.line), math.max(0, mouse.column - 1) })
    end
    return nil, 0, 0
  end
  -- getmousepos() window columns include the border: measure from the start of the line instead
  local origin = vim.fn.screenpos(win, mouse.line, 1)
  return self:hit(mouse.line, mouse.screencol - origin.col)
end

return M
