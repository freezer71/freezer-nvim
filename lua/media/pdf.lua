local util = require("media.util")

local M = {}

---@param date? string ISO date from `pdfinfo -isodates`
local function format_date(date)
  local day, time = (date or ""):match("^(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d)")
  return day and (day .. " " .. time) or date
end

---@param size? string like "595.276 x 841.89 pts (A4)"
local function page_size(size)
  local w, h, rest = (size or ""):match("^([%d.]+) x ([%d.]+) pts(.*)$")
  if not w then
    return size
  end
  local function mm(pts)
    return math.floor(tonumber(pts) * 25.4 / 72 + 0.5)
  end
  return ("%d × %d mm%s"):format(mm(w), mm(h), rest)
end

---@param file string
---@param done fun(info: table<string, string>)
local function pdfinfo(file, done)
  if vim.fn.executable("pdfinfo") == 0 then
    Snacks.notify.warn("`pdfinfo` is required to browse PDF pages (`brew install poppler`)")
    return done({})
  end
  vim.system({ "pdfinfo", "-isodates", file }, { text = true }, function(r)
    vim.schedule(function()
      local info = {} ---@type table<string, string>
      for line in (r.stdout or ""):gmatch("[^\n]+") do
        local key, value = line:match("^([^:]+):%s*(.-)%s*$")
        if key and value ~= "" then
          info[key] = value
        end
      end
      done(info)
    end)
  end)
end

--- PDF viewer: one centered page at a time, with the document metadata
---@param buf number
---@param file string
---@param canvas media.Canvas
function M.attach(buf, file, canvas)
  local page, pages, info, show_info = 1, nil, {}, true ---@type number, number?, table<string, string>, boolean

  ---@param n number
  local function src(n)
    return ("%s#page=%d"):format(file, n)
  end

  local function render()
    local rows = {
      { { vim.fn.fnamemodify(file, ":t"), "Title" }, center = true },
      {
        { "‹", page > 1 and "Special" or "NonText", "prev" },
        { ("   Page %d / %s   "):format(page, pages or "?") },
        { "›", page < (pages or 1) and "Special" or "NonText", "next" },
        center = true,
      },
    }
    if show_info then
      local stat = vim.uv.fs_stat(file)
      local encrypted = info.Encrypted and info.Encrypted ~= "no" and "encrypted"
      rows[#rows + 1] = { center = true }
      vim.list_extend(
        rows,
        util.info_rows({
          { "Title", info.Title },
          { "Author", info.Author },
          { "Subject", info.Subject },
          { "Page size", page_size(info["Page size"]) },
          { "Created", format_date(info.CreationDate) },
          { "Software", util.join(" · ", info.Creator, info.Producer) },
          { "PDF", util.join(" · ", info["PDF version"] and ("version " .. info["PDF version"]), encrypted) },
          { "File size", stat and util.human_size(stat.size) },
          { "Modified", util.modified(file) },
        })
      )
    end
    rows[#rows + 1] = { center = true }
    rows[#rows + 1] = {
      { "←/→", "Special" },
      { " page   ", "Comment" },
      { "gg/G", "Special" },
      { " first/last   ", "Comment" },
      { "i", "Special" },
      { " info   ", "Comment" },
      { "o", "Special" },
      { " open externally", "Comment" },
      center = true,
    }
    canvas.rows = rows
    canvas:render()
  end

  -- render the neighbour pages ahead, so that flipping pages is instant
  local function prefetch()
    for _, n in ipairs({ page + 1, page - 1 }) do
      if n >= 1 and n <= (pages or 1) then
        Snacks.image.image.new(src(n))
      end
    end
  end

  ---@param n number
  local function go(n)
    n = math.max(1, math.min(n, pages or 1))
    if n == page and canvas.pending then
      return
    end
    page = n
    canvas:set_image(src(page))
    render()
    prefetch()
  end

  local function map(lhs, rhs, desc)
    for _, key in ipairs(type(lhs) == "table" and lhs or { lhs }) do
      vim.keymap.set("n", key, rhs, { buffer = buf, nowait = true, silent = true, desc = desc })
    end
  end
  map({ "<Right>", "l", "n", "j", "<Down>", "<PageDown>", "<ScrollWheelDown>" }, function()
    go(page + vim.v.count1)
  end, "Next page")
  map({ "<Left>", "h", "p", "k", "<Up>", "<PageUp>", "<BS>", "<ScrollWheelUp>" }, function()
    go(page - vim.v.count1)
  end, "Previous page")
  map("gg", function()
    go(1)
  end, "First page")
  map("G", function()
    go(vim.v.count > 0 and vim.v.count or pages or 1)
  end, "Last page (or [count]G)")
  map("i", function()
    show_info = not show_info
    render()
  end, "Toggle info")
  map("o", function()
    require("media.viewer").open_external(file)
  end, "Open externally")
  map({ "<LeftMouse>", "<2-LeftMouse>" }, function()
    local id = canvas:click()
    if id == "next" then
      go(page + 1)
    elseif id == "prev" then
      go(page - 1)
    end
  end, "Click")

  go(1)
  pdfinfo(file, function(result)
    if vim.api.nvim_buf_is_valid(buf) then
      info, pages = result, tonumber(result.Pages)
      render()
      prefetch()
    end
  end)
end

return M
