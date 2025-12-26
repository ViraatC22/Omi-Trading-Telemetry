local M = {}
function M.raw(tvb)
  return tvb:raw()
end
function M.u8(raw, offset)
  local a = string.byte(raw, offset + 1)
  return a
end
function M.u16be(raw, offset)
  local a = string.byte(raw, offset + 1)
  local b = string.byte(raw, offset + 2)
  return a * 256 + b
end
function M.u32be(raw, offset)
  local a = string.byte(raw, offset + 1)
  local b = string.byte(raw, offset + 2)
  local c = string.byte(raw, offset + 3)
  local d = string.byte(raw, offset + 4)
  return ((a * 256 + b) * 256 + c) * 256 + d
end
function M.slice(raw, offset, length)
  return string.sub(raw, offset + 1, offset + length)
end
return M
