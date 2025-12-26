local M = {}
local ok, ffi = pcall(require, "ffi")
if ok and ffi then
  function M.delta_ns(cap_ns, engine_ns, corr_ns)
    local corr = corr_ns or 0
    return engine_ns - (cap_ns + corr)
  end
else
  function M.delta_ns(cap_ns, engine_ns, corr_ns)
    local corr = corr_ns or 0
    return engine_ns - (cap_ns + corr)
  end
end
return M
