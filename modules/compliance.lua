local M = {}
function M.add(tree, fields)
  local subtree = tree:add(Proto("omi_compliance", "Compliance"), tree)
  for k, v in pairs(fields or {}) do
    subtree:add(string.format("%s: %s", k, tostring(v)))
  end
end
return M
