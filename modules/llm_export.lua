local json = require "json_export"
local M = {}
local function intent(ctx)
  local s = ctx.symbol or ""
  local side = ctx.side or ""
  local sz = ctx.size or 0
  local pr = ctx.price or 0
  local last = ctx.last_price or pr
  local delta = pr - last
  local ms = ctx.delta_ms or 0
  if side == "buy" and delta < 0 then
    return string.format("This is a %d-share limit buy for %s placed %dms after a price drop, suggesting mean-reversion.", sz, s, ms)
  elseif side == "sell" and delta > 0 then
    return string.format("This is a %d-share limit sell for %s placed %dms after a price rise, suggesting momentum.", sz, s, ms)
  else
    return string.format("This is a %d-share %s order for %s at %s with neutral context.", sz, side, s, tostring(pr))
  end
end
function M.summary(ctx)
  local obj = {
    ts = ctx.ts,
    symbol = ctx.symbol,
    side = ctx.side,
    price = ctx.price,
    size = ctx.size,
    bbo = ctx.bbo,
    seq = ctx.seq,
    intent = intent(ctx),
    tags = ctx.tags
  }
  return json.encode(obj)
end
return M
