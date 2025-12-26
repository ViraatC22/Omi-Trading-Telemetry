local M = {}
local function fmt(v, places)
  return string.format("%." .. tostring(places) .. "f", v)
end
function M.scale_int(value, scale)
  local places = 0
  if scale == 1 then
    places = 0
  else
    local p = 0
    local s = scale
    while s > 1 do
      s = s / 10
      p = p + 1
    end
    places = p
  end
  return value / scale, places
end
function M.add_scaled(treeitem, label, value, scale)
  local scaled, places = M.scale_int(value, scale)
  local text = label .. ": " .. fmt(scaled, places)
  local ok = pcall(function() treeitem:set_text(text) end)
  if not ok then
    treeitem:append_text(" " .. text)
  end
end
return M
