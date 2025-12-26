local p = Proto("omi_global", "OMI Global Sync")
local prefs = {
  listen_port = Pref.uint("Listen Port", 10000, "Port to ingest remote metadata"),
  correction_ns = Pref.uint("Correction ns", 0, "Global correction factor")
}
p.prefs.listen_port = prefs.listen_port
p.prefs.correction_ns = prefs.correction_ns
local ok, socket = pcall(require, "socket")
local srv = nil
if ok and socket then
  srv = socket.udp()
  srv:setsockname("0.0.0.0", p.prefs.listen_port)
  srv:settimeout(0)
end
local timeline = {}
local function add(ts, sym, seq, dc)
  table.insert(timeline, { ts = ts, sym = sym, seq = seq, dc = dc })
end
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  if srv then
    local data = srv:receive()
    if data then
      local ts, sym, seq, dc = string.match(data, "([^,]+),([^,]+),([^,]+),([^,]+)")
      if ts then add(tonumber(ts) + (p.prefs.correction_ns / 1e9), sym, seq, dc) end
    end
  end
end
register_postdissector(p)
