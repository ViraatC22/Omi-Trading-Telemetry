local p = Proto("omi_insider", "OMI Insider Threat")
local prefs = {
  heartbeat_field = Pref.string("Heartbeat Field", "", "Field name for heartbeat indicator"),
  order_size_field = Pref.string("Order Size Field", "", "Field name for order size"),
  leak_threshold = Pref.uint("Leak Threshold", 10, "Low-size orders per minute threshold")
}
p.prefs.heartbeat_field = prefs.heartbeat_field
p.prefs.order_size_field = prefs.order_size_field
p.prefs.leak_threshold = prefs.leak_threshold
local hb_get = nil
local sz_get = nil
local function set_field(name)
  if name and #name > 0 then
    local ok, f = pcall(Field.new, name)
    if ok and f then
      return f
    end
  end
  return nil
end
function p.prefs_changed()
  hb_get = set_field(p.prefs.heartbeat_field)
  sz_get = set_field(p.prefs.order_size_field)
end
hb_get = set_field(p.prefs.heartbeat_field)
sz_get = set_field(p.prefs.order_size_field)
local counts = { hb = 0, low = 0, last_sec = nil }
function p.dissector(tvb, pinfo, tree)
  local sec = math.floor(pinfo.abs_ts)
  if counts.last_sec ~= sec then
    counts.hb = 0
    counts.low = 0
    counts.last_sec = sec
  end
  local hb = hb_get and hb_get()
  if hb then
    counts.hb = counts.hb + 1
  end
  local sz = sz_get and sz_get()
  if sz then
    local v = tonumber(tostring(sz)) or 0
    if v > 0 and v <= p.prefs.leak_threshold then
      counts.low = counts.low + 1
    end
  end
  if counts.hb > 100 or counts.low > 20 then
    local subtree = tree:add(p, tvb)
    subtree:add(string.format("Insider Suspect hb:%s low:%s", tostring(counts.hb), tostring(counts.low)))
    pinfo.cols.info:append(" Insider Suspect")
  end
end
register_postdissector(p)
