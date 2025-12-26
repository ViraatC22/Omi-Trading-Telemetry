local function escape(s)
  s = s:gsub("\\", "\\\\")
  s = s:gsub("\"", "\\\"")
  s = s:gsub("\n", "\\n")
  s = s:gsub("\r", "\\r")
  return s
end
local function encode_value(v)
  local t = type(v)
  if t == "string" then
    return "\"" .. escape(v) .. "\""
  elseif t == "number" then
    return tostring(v)
  elseif t == "boolean" then
    return v and "true" or "false"
  elseif t == "table" then
    local parts = {}
    local is_array = (#v > 0)
    if is_array then
      for i = 1, #v do
        table.insert(parts, encode_value(v[i]))
      end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      for k, val in pairs(v) do
        table.insert(parts, "\"" .. escape(k) .. "\":" .. encode_value(val))
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  else
    return "null"
  end
end
local M = {}
function M.encode(obj)
  return encode_value(obj)
end
return M
