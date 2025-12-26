local M = {}
function M.desegment_needed(pinfo, needed)
  pinfo.desegment_offset = 0
  pinfo.desegment_len = needed
end
function M.ensure_complete(tvb, pinfo, total_len)
  local have = tvb:len()
  if have < total_len then
    M.desegment_needed(pinfo, total_len - have)
    return false
  end
  return true
end
function M.iterate_messages(tvb, pinfo, header_len_fn, total_len_fn, on_message)
  local offset = 0
  while offset < tvb:len() do
    local hlen = header_len_fn(tvb, offset)
    if tvb:len() - offset < hlen then
      M.desegment_needed(pinfo, hlen - (tvb:len() - offset))
      return offset
    end
    local tlen = total_len_fn(tvb, offset)
    if tvb:len() - offset < tlen then
      M.desegment_needed(pinfo, tlen - (tvb:len() - offset))
      return offset
    end
    on_message(tvb(offset, tlen), offset, tlen)
    offset = offset + tlen
  end
  return offset
end
return M
