local p = Proto("omi_tsdb", "OMI TSDB")
local prefs = {
  host = Pref.string("Host", "127.0.0.1", "TSDB host"),
  port = Pref.uint("Port", 8089, "TSDB port"),
  proto = Pref.string("Proto", "udp", "udp or tcp"),
  symbol_field = Pref.string("Symbol Field", "", "Field name for symbol"),
  price_field = Pref.string("Price Field", "", "Field name for price"),
  size_field = Pref.string("Size Field", "", "Field name for size")
}
p.prefs.host = prefs.host
p.prefs.port = prefs.port
p.prefs.proto = prefs.proto
p.prefs.symbol_field = prefs.symbol_field
p.prefs.price_field = prefs.price_field
p.prefs.size_field = prefs.size_field
local sock = nil
local mode = "file"
local host, port, proto = p.prefs.host, p.prefs.port, p.prefs.proto
local sym_get, price_get, size_get = nil, nil, nil
local function set_field(name)
  if name and #name > 0 then
    local ok, f = pcall(Field.new, name)
    if ok and f then
      return f
    end
  end
  return nil
end
local function setup_socket()
  local ok, socket = pcall(require, "socket")
  if ok and socket then
    mode = "socket"
    if proto == "udp" then
      sock = socket.udp()
      sock:settimeout(0)
    else
      sock = socket.tcp()
      sock:settimeout(0)
      sock:connect(host, port)
    end
  else
    mode = "file"
  end
end
function p.prefs_changed()
  host = p.prefs.host
  port = p.prefs.port
  proto = p.prefs.proto
  sym_get = set_field(p.prefs.symbol_field)
  price_get = set_field(p.prefs.price_field)
  size_get = set_field(p.prefs.size_field)
  setup_socket()
end
sym_get = set_field(p.prefs.symbol_field)
price_get = set_field(p.prefs.price_field)
size_get = set_field(p.prefs.size_field)
setup_socket()
local out = io.open("tsdb.ndjson", "a")
local tap = Listener.new("frame", "")
function tap.packet(pinfo, tvb)
  local sym = sym_get and sym_get()
  local price = price_get and price_get()
  local size = size_get and size_get()
  if not sym or not price then
    return
  end
  local s = tostring(sym)
  local pr = tonumber(tostring(price))
  local sz = size and tonumber(tostring(size)) or 0
  local ts = pinfo.abs_ts
  local line = string.format("{\"ts\":%.6f,\"sym\":\"%s\",\"price\":%s,\"size\":%s}\n", ts, s, tostring(pr), tostring(sz))
  if mode == "socket" and sock then
    if proto == "udp" then
      sock:sendto(line, host, port)
    else
      sock:send(line)
    end
  else
    out:write(line)
    out:flush()
  end
end
register_postdissector(p)
