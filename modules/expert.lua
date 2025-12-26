local M = {}
function M.info(treeitem, pinfo, text)
  if treeitem and pinfo then
    pinfo.cols.info:append(" " .. text)
    local ok = pcall(function() treeitem:add_expert_info(PI_PROTOCOL, PI_NOTE, text) end)
    if not ok then
      treeitem:append_text(" [" .. text .. "]")
    end
  end
end
function M.warn(treeitem, pinfo, text)
  if treeitem and pinfo then
    pinfo.cols.info:append(" WARN " .. text)
    local ok = pcall(function() treeitem:add_expert_info(PI_PROTOCOL, PI_WARN, text) end)
    if not ok then
      treeitem:append_text(" [WARN " .. text .. "]")
    end
  end
end
function M.error(treeitem, pinfo, text)
  if treeitem and pinfo then
    pinfo.cols.info:append(" ERROR " .. text)
    local ok = pcall(function() treeitem:add_expert_info(PI_MALFORMED, PI_ERROR, text) end)
    if not ok then
      treeitem:append_text(" [ERROR " .. text .. "]")
    end
  end
end
return M
