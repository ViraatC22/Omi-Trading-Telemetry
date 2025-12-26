local p = Proto("omi_market_map", "OMI Market Map")
local prefs = {
  order_id_field_a = Pref.string("Order ID Field A", "", "Client Order ID field name for Protocol A"),
  order_id_field_b = Pref.string("Order ID Field B", "", "Client Order ID field name for Protocol B")
}
p.prefs.order_id_field_a = prefs.order_id_field_a
p.prefs.order_id_field_b = prefs.order_id_field_b
local geta = nil
local getb = nil
local function set_field(name)
  if name and #name > 0 then
    local ok, f = pcall(Field.new, name)
    if ok and f then
      return f
    end
  end
  return nil
end
function p.prefs_changed()
  geta = set_field(p.prefs.order_id_field_a)
  getb = set_field(p.prefs.order_id_field_b)
end
geta = set_field(p.prefs.order_id_field_a)
getb = set_field(p.prefs.order_id_field_b)
local map = {}
function p.dissector(tvb, pinfo, tree)
  local id = nil
  if geta then
    local f = geta()
    if f then
      id = tostring(f)
      map[id] = { src = "A", num = pinfo.number }
    end
  end
  if getb then
    local f = getb()
    if f then
      id = tostring(f)
      local a = map[id]
      if a then
        local subtree = tree:add(p, tvb)
        subtree:add(string.format("Correlated Order %s A:%s B:%s", id, tostring(a.num), tostring(pinfo.number)))
        pinfo.cols.info:append(" Correlated " .. id)
      end
    end
  end
end
register_postdissector(p)
