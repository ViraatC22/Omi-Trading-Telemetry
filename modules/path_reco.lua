local p = Proto("omi_path", "OMI Path Recommendation")
local prefs = {
  stream_a_port = Pref.uint("Stream A Port", 0, "UDP port A"),
  stream_b_port = Pref.uint("Stream B Port", 0, "UDP port B")
}
p.prefs.stream_a_port = prefs.stream_a_port
p.prefs.stream_b_port = prefs.stream_b_port
local stats = { a = { cnt = 0 }, b = { cnt = 0 } }
local tap = Listener.new("udp", "")
function tap.packet(pinfo, tvb)
  local port = pinfo.src_port
  if port == p.prefs.stream_a_port then
    stats.a.cnt = stats.a.cnt + 1
  elseif port == p.prefs.stream_b_port then
    stats.b.cnt = stats.b.cnt + 1
  end
end
function tap.draw()
  local tw = new_text_window("Path Recommendation")
  local reco = "A"
  if stats.b.cnt < stats.a.cnt then reco = "B" end
  tw:set("Recommended path " .. reco)
end
register_postdissector(p)
