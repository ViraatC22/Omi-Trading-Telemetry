local p = Proto("omi_actions", "OMI Actions")
local prefs = {
  host = Pref.string("Host", "127.0.0.1", "Agent host"),
  port = Pref.uint("Port", 9090, "Agent port"),
  proto = Pref.string("Proto", "udp", "udp or tcp"),
  jitter_ns = Pref.uint("Jitter Threshold ns", 1000000, "Threshold for action"),
  kill_switch = Pref.bool("Kill Switch", false, "Enable kill switch action")
}
p.prefs.host = prefs.host
p.prefs.port = prefs.port
p.prefs.proto = prefs.proto
p.prefs.jitter_ns = prefs.jitter_ns
p.prefs.kill_switch = prefs.kill_switch
local sock = nil
local mode = "file"
local function setup_socket()
  local ok, socket = pcall(require, "socket")
  if ok and socket then
    mode = "socket"
    if p.prefs.proto == "udp" then
      sock = socket.udp()
      sock:settimeout(0)
    else
      sock = socket.tcp()
      sock:settimeout(0)
      sock:connect(p.prefs.host, p.prefs.port)
    end
  else
    mode = "file"
  end
end
setup_socket()
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  local info = tostring(pinfo.cols.info)
  if info and string.find(info, "JITTER") then
    if mode == "socket" and sock then
      local line = string.format("{\"type\":\"jitter\",\"kill\":%s}", tostring(p.prefs.kill_switch))
      if p.prefs.proto == "udp" then
        sock:sendto(line, p.prefs.host, p.prefs.port)
      else
        sock:send(line)
      end
    end
  end
end
register_postdissector(p)
