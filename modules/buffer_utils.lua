local M = {}
local ok, ffi = pcall(require, "ffi")
function M.raw(tvb)
  return tvb:raw()
end
if ok and ffi then
  ffi.cdef[[
    typedef unsigned char u8;
  ]]
  function M.u8(raw, offset)
    local p = ffi.cast("const u8*", raw)
    return tonumber(p[offset])
  end
  function M.u16be(raw, offset)
    local p = ffi.cast("const u8*", raw)
    return p[offset] * 256 + p[offset + 1]
  end
  function M.u32be(raw, offset)
    local p = ffi.cast("const u8*", raw)
    return ((p[offset] * 256 + p[offset + 1]) * 256 + p[offset + 2]) * 256 + p[offset + 3]
  end
else
  function M.u8(raw, offset)
    return string.byte(raw, offset + 1)
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
end
function M.slice(raw, offset, length)
  return string.sub(raw, offset + 1, offset + length)
end
return M
