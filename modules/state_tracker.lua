local conversations = {}
local p = Proto("omi_state", "OMI State")
local f_total = ProtoField.uint32("omi_state.total", "Total Packets", base.DEC)
local f_gaps = ProtoField.uint32("omi_state.tcp_seq_gaps", "TCP Seq Gaps", base.DEC)
local f_lastseq = ProtoField.uint32("omi_state.last_tcp_seq", "Last TCP Seq", base.DEC)
p.fields = { f_total, f_gaps, f_lastseq }
local function key(pinfo)
  return tostring(pinfo.src) .. ":" .. tostring(pinfo.src_port) .. "->" .. tostring(pinfo.dst) .. ":" .. tostring(pinfo.dst_port)
end
function p.dissector(tvb, pinfo, tree)
  local k = key(pinfo)
  local s = conversations[k]
  if not s then
    s = { total = 0, gaps = 0, lastseq = nil }
    conversations[k] = s
  end
  s.total = s.total + 1
  if pinfo.seq then
    if s.lastseq and pinfo.seq > s.lastseq and pinfo.seq ~= s.lastseq + 1 then
      s.gaps = s.gaps + 1
    end
    s.lastseq = pinfo.seq
  end
  local subtree = tree:add(p, tvb)
  subtree:add(f_total, s.total)
  subtree:add(f_gaps, s.gaps)
  if s.lastseq then
    subtree:add(f_lastseq, s.lastseq)
  end
end
register_postdissector(p)
