local p = Proto("omi_hw_ingest", "OMI Hardware Ingest")
local prefs = {
  port = Pref.uint("UDP Port", 12000, "Port to ingest hardware logs")
}
p.prefs.port = prefs.port
local ok, socket = pcall(require, "socket")
local srv = nil
if ok and socket then
  srv = socket.udp()
  srv:setsockname("0.0.0.0", p.prefs.port)
  srv:settimeout(0)
end
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  if srv then
    local data = srv:receive()
    if data then
      pinfo.cols.info:append(" HW " .. data)
    end
  end
end
register_postdissector(p)
