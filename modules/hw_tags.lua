local p = Proto("omi_hw_tags", "OMI Hardware Tags")
local prefs = {
  offset = Pref.uint("Timestamp Offset", 0, "Byte offset for hardware timestamp"),
  big_endian = Pref.bool("Big Endian", true, "Endianness of timestamp"),
  unit_ns = Pref.bool("Unit ns", true, "Timestamp unit is nanoseconds")
}
p.prefs.offset = prefs.offset
p.prefs.big_endian = prefs.big_endian
p.prefs.unit_ns = prefs.unit_ns
local off = 0
local be = true
local nsunit = true
function p.prefs_changed()
  off = p.prefs.offset
  be = p.prefs.big_endian
  nsunit = p.prefs.unit_ns
end
local M = {}
function M.ts_ns(tvb)
  if off <= 0 or tvb:len() < off + 8 then
    return nil
  end
  local v
  if be then
    v = tvb(off, 8):uint64():tonumber()
  else
    v = tvb(off, 8):le_uint64():tonumber()
  end
  if nsunit then
    return v
  else
    return v * 1000
  end
end
register_postdissector(p)
return M
