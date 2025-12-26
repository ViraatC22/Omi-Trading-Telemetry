local p = Proto("omi_time", "OMI Time")
local prefs = {
  hardware_offset_ns = Pref.uint("Hardware Offset ns", 0, "PTP/Hardware timestamp correction"),
  ptp_error_ns = Pref.uint("PTP Error ns", 0, "PTP error margin")
}
p.prefs.hardware_offset_ns = prefs.hardware_offset_ns
p.prefs.ptp_error_ns = prefs.ptp_error_ns
local hw = 0
local ptp = 0
function p.prefs_changed()
  hw = p.prefs.hardware_offset_ns
  ptp = p.prefs.ptp_error_ns
end
local M = {}
function M.corrected_cap_ns(pinfo)
  local abs = pinfo.abs_ts
  local s = math.floor(abs)
  local ns = math.floor((abs - s) * 1e9)
  local cap = s * 1000000000 + ns
  return cap - (hw + ptp)
end
register_postdissector(p)
return M
