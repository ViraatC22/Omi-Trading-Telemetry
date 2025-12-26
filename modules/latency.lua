local M = {}
local ok, time_sync = pcall(require, "time_sync")
local okhw, hw = pcall(require, "hw_tags")
function M.delta_ns(pinfo, engine_ns, correction_ns, tvb)
  local cap_ns
  if ok and time_sync then
    cap_ns = time_sync.corrected_cap_ns(pinfo)
  else
    local abs = pinfo.abs_ts
    local sec = math.floor(abs)
    local nsec = math.floor((abs - sec) * 1e9)
    cap_ns = sec * 1000000000 + nsec
  end
  local hw_ts = nil
  if okhw and hw then
    hw_ts = hw.ts_ns
  end
  if hw_ts and tvb then
    local h = hw_ts(tvb)
    if h then
      cap_ns = h
    end
  end
  local corr = correction_ns or 0
  return engine_ns - (cap_ns + corr)
end
function M.jitter_warn(treeitem, pinfo, delta_ns, threshold_ns)
  local th = threshold_ns or 1000000
  if math.abs(delta_ns) > th then
    pinfo.cols.info:append(" JITTER " .. tostring(delta_ns) .. "ns")
    local ok = pcall(function() treeitem:add_expert_info(PI_PROTOCOL, PI_WARN, "Latency Jitter " .. tostring(delta_ns) .. "ns") end)
    if not ok then
      treeitem:append_text(" [Latency Jitter " .. tostring(delta_ns) .. "ns]")
    end
  end
end
return M
