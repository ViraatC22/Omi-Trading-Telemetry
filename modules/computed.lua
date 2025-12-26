local p = Proto("omi_computed", "OMI Computed")
local f_gap = ProtoField.uint32("omi.packet_gap_ms", "Packet Gap ms", base.DEC)
local f_spoof = ProtoField.bool("omi.spoofing", "Spoofing Suspect")
p.fields = { f_gap, f_spoof }
local last_ts = nil
local sym_get = nil
local ok, surv = pcall(require, "surveillance")
local function set_field(name)
  if name and #name > 0 then
    local ok, f = pcall(Field.new, name)
    if ok and f then
      return f
    end
  end
  return nil
end
p.prefs.symbol_field = Pref.string("Symbol Field", "", "Field name for symbol")
function p.prefs_changed()
  sym_get = set_field(p.prefs.symbol_field)
end
function p.dissector(tvb, pinfo, tree)
  local subtree = tree:add(p, tvb)
  local gap = 0
  if last_ts then
    local ms = (pinfo.abs_ts - last_ts) * 1000.0
    gap = math.floor(ms)
  end
  last_ts = pinfo.abs_ts
  subtree:add(f_gap, gap)
  local spo = false
  if ok and surv and sym_get then
    local sym = sym_get()
    if sym then
      local s = surv.get and surv.get(tostring(sym))
      if s and s.adds > 0 and s.cancels / s.adds > 0.8 then
        spo = true
      end
    end
  end
  subtree:add(f_spoof, spo)
end
register_postdissector(p)
