local p = Proto("omi_predict", "OMI Predict")
local prefs = {
  window = Pref.uint("Window Seconds", 10, "Prediction window"),
  warn_ns = Pref.uint("Warn ns", 1000000, "Warn threshold")
}
p.prefs.window = prefs.window
p.prefs.warn_ns = prefs.warn_ns
local bins = {}
local function add(sec, val)
  bins[sec] = (bins[sec] or 0) + val
end
local function avg()
  local total = 0
  local count = 0
  for k, v in pairs(bins) do
    total = total + v
    count = count + 1
  end
  if count == 0 then return 0 end
  return total / count
end
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  local sec = math.floor(pinfo.abs_ts)
  add(sec, 1)
end
function tap.draw()
  local a = avg()
  if a > p.prefs.warn_ns then
    local tw = new_text_window("Predictive Alert")
    tw:set("Expected jitter exceedance based on recent load")
  end
end
register_postdissector(p)
