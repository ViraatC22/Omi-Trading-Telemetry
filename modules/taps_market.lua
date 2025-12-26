local stats = {}
local win = nil
local function ensure_window()
  if not win then
    win = new_text_window("Market Summary")
  end
end
local function render()
  ensure_window()
  local lines = {}
  for sym, s in pairs(stats) do
    table.insert(lines, sym .. " " .. tostring(s.last or 0) .. " " .. tostring(s.vol or 0) .. " " .. tostring(s.count or 0))
  end
  table.sort(lines)
  win:set(table.concat(lines, "\n"))
end
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  local sym = pinfo.cols.info and tostring(pinfo.cols.info) or ""
  if sym and #sym > 0 then
    local s = stats[sym] or { last = 0, vol = 0, count = 0 }
    s.count = s.count + 1
    stats[sym] = s
  end
end
function tap.draw()
  render()
end
function tap.reset()
  stats = {}
  render()
end
return { stats = stats }
