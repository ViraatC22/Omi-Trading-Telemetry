local M = {}
function M.starts_with_magic(tvb, offset, bytes)
  if tvb:len() - offset < #bytes then
    return false
  end
  for i = 1, #bytes do
    if tvb(offset + i - 1, 1):uint() ~= bytes[i] then
      return false
    end
  end
  return true
end
function M.probable_ascii(tvb, offset, length)
  if tvb:len() - offset < length then
    return false
  end
  for i = 0, length - 1 do
    local v = tvb(offset + i, 1):uint()
    if v < 32 or v > 126 then
      return false
    end
  end
  return true
end
return M
