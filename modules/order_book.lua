local M = {}
local books = {}
function M.get(symbol)
  local b = books[symbol]
  if not b then
    b = { bid = nil, ask = nil, vol = 0, seq = nil, stale = false }
    books[symbol] = b
  end
  return b
end
function M.seq(b, seq)
  if b.seq and seq and seq > b.seq and seq ~= b.seq + 1 then
    b.stale = true
  end
  b.seq = seq
end
function M.quote(symbol, side, price, size)
  local b = M.get(symbol)
  if side == "B" then
    b.bid = { price = price, size = size }
  elseif side == "A" then
    b.ask = { price = price, size = size }
  end
end
function M.trade(symbol, price, size)
  local b = M.get(symbol)
  b.vol = b.vol + (size or 0)
end
function M.render(tree, symbol)
  local b = M.get(symbol)
  local t = tree:add(Proto("omi_book", "Projected Book State"), tree)
  if b.bid then
    t:add(string.format("Bid %s x %s", tostring(b.bid.price), tostring(b.bid.size)))
  end
  if b.ask then
    t:add(string.format("Ask %s x %s", tostring(b.ask.price), tostring(b.ask.size)))
  end
  t:add(string.format("Volume %s", tostring(b.vol)))
  if b.stale then
    t:add("Stale State")
  end
end
return M
