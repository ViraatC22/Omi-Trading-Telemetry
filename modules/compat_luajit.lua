local M = {}
local ok, bit = pcall(require, "bit")
if ok and bit then
  M.band = bit.band
  M.bor = bit.bor
  M.lshift = bit.lshift
else
  function M.band(a, b)
    local r = 0
    local bitval = 1
    while a > 0 or b > 0 do
      local abit = a % 2
      local bbit = b % 2
      if abit == 1 and bbit == 1 then
        r = r + bitval
      end
      bitval = bitval * 2
      a = math.floor(a / 2)
      b = math.floor(b / 2)
    end
    return r
  end
  function M.bor(a, b)
    local r = 0
    local bitval = 1
    while a > 0 or b > 0 do
      local abit = a % 2
      local bbit = b % 2
      if abit == 1 or bbit == 1 then
        r = r + bitval
      end
      bitval = bitval * 2
      a = math.floor(a / 2)
      b = math.floor(b / 2)
    end
    return r
  end
  function M.lshift(a, n)
    return a * (2 ^ n)
  end
end
return M
