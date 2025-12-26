local M = {}
local patterns = {}
function M.record(order_event)
  local sym = order_event.symbol
  if not sym then
    return
  end
  local p = patterns[sym] or { bids = 0, offers = 0, cancels = 0, adds = 0, last_price = nil }
  if order_event.type == "add" then
    p.adds = p.adds + 1
  elseif order_event.type == "cancel" then
    p.cancels = p.cancels + 1
  elseif order_event.type == "bid" then
    p.bids = p.bids + 1
  elseif order_event.type == "offer" then
    p.offers = p.offers + 1
  elseif order_event.type == "trade" then
    p.last_price = order_event.price
  end
  patterns[sym] = p
end
function M.evaluate(treeitem, pinfo, symbol)
  local p = patterns[symbol]
  if not p then
    return
  end
  local ratio = 0
  if p.adds > 0 then
    ratio = p.cancels / p.adds
  end
  if ratio > 0.8 and (p.bids + p.offers) > 10 then
    pinfo.cols.info:append(" Spoofing Pattern Suspect")
    local ok = pcall(function() treeitem:add_expert_info(PI_PROTOCOL, PI_WARN, "Spoofing/LAYERING pattern suspected") end)
    if not ok then
      treeitem:append_text(" [Spoofing suspected]")
    end
  end
end
function M.get(symbol)
  return patterns[symbol]
end
return M
