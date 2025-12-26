local p = Proto("omi_arbitration", "OMI Arbitration")
local prefs = {
  seq_field = Pref.string("Sequence Field", "nasdaq.ise.topcomboquotefeed.itch.v1.0.sequence", "Fully-qualified field name to extract sequence"),
  stream_a_port = Pref.uint("Stream A Port", 0, "UDP port for Stream A"),
  stream_b_port = Pref.uint("Stream B Port", 0, "UDP port for Stream B"),
  latency_ns_warn = Pref.uint("Latency Warn ns", 1000000, "Warn if A/B delta exceeds threshold")
}
p.prefs.seq_field = prefs.seq_field
p.prefs.stream_a_port = prefs.stream_a_port
p.prefs.stream_b_port = prefs.stream_b_port
p.prefs.latency_ns_warn = prefs.latency_ns_warn
local seq_getter = nil
local function set_getter(name)
  local ok, f = pcall(Field.new, name)
  if ok and f then
    seq_getter = f
  end
end
function p.prefs_changed()
  set_getter(p.prefs.seq_field)
end
set_getter(p.prefs.seq_field)
local tap = Listener.new("udp", "")
local seen = {}
local function key(seq)
  return tostring(seq)
end
local function now_ns(pinfo)
  local abs = pinfo.abs_ts
  local s = math.floor(abs)
  local ns = math.floor((abs - s) * 1e9)
  return s * 1000000000 + ns
end
function tap.packet(pinfo, tvb)
  if not seq_getter then
    return
  end
  local seq_f = seq_getter()
  if not seq_f then
    return
  end
  local seq_val = tonumber(tostring(seq_f))
  if not seq_val then
    return
  end
  local port = pinfo.src_port
  local ns = now_ns(pinfo)
  local k = key(seq_val)
  local entry = seen[k] or {}
  if port == p.prefs.stream_a_port and not entry.a_ns then
    entry.a_ns = ns
    entry.a_num = pinfo.number
  elseif port == p.prefs.stream_b_port and not entry.b_ns then
    entry.b_ns = ns
    entry.b_num = pinfo.number
  end
  if entry.a_ns and entry.b_ns and not entry.reported then
    local delta = entry.b_ns - entry.a_ns
    local warn = p.prefs.latency_ns_warn
    local msg = "A/B delta " .. tostring(delta) .. "ns"
    if math.abs(delta) > warn then
      msg = msg .. " Stream Recovery Event"
    end
    pinfo.cols.info:append(" " .. msg)
    entry.reported = true
  end
  seen[k] = entry
end
function tap.reset()
  seen = {}
end
register_postdissector(p)
