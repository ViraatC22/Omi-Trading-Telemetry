local M = {}
function M.define_prefs(proto, defs)
  for name, d in pairs(defs) do
    if d.type == "uint" then
      proto.prefs[name] = Pref.uint(name, d.default, d.description or "")
    elseif d.type == "string" then
      proto.prefs[name] = Pref.string(name, d.default or "", d.description or "")
    elseif d.type == "bool" then
      proto.prefs[name] = Pref.bool(name, d.default or false, d.description or "")
    end
  end
end
function M.get(proto, name)
  return proto.prefs[name]
end
return M
