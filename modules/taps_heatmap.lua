local win = nil
local bins = {}
local function ensure()
  if not win then
    win = new_text_window("Latency Heatmap")
  end
end
local function render()
  ensure()
  local lines = {}
  for k, v in pairs(bins) do
    table.insert(lines, tostring(k) .. " " .. tostring(v))
  end
  table.sort(lines)
  win:set(table.concat(lines, "\n"))
end
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  local sec = math.floor(pinfo.abs_ts)
  bins[sec] = (bins[sec] or 0) + 1
end
function tap.draw()
  render()
end
function tap.reset()
  bins = {}
  render()
end
