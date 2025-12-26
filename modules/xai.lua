local M = {}
function M.explain(pattern, metrics)
  if pattern == "layering" then
    local corr = metrics and metrics.corr or 0
    local seq = metrics and metrics.seq or 0
    return "Sequence of orders matches layering template with correlation " .. tostring(corr) .. " and count " .. tostring(seq)
  elseif pattern == "spoofing" then
    local ratio = metrics and metrics.ratio or 0
    return "Cancel/Add ratio " .. tostring(ratio) .. " exceeds threshold indicating spoofing behavior"
  else
    return "Pattern " .. tostring(pattern) .. " flagged with metrics"
  end
end
return M
