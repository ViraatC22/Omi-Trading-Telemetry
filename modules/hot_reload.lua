local M = {}
function M.reload_tcp(proto, port, path)
  local t = DissectorTable.get("tcp.port")
  local d = Dissector.get(proto.name)
  if d then
    t:remove(port, d)
  end
  dofile(path)
end
return M
