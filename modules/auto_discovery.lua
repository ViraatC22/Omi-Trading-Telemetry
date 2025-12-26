local p = Proto("omi_auto", "OMI Auto Discovery")
local prefs = {
  enable = Pref.bool("Enable Auto Discovery", true, "Enable heuristic selection and version labeling"),
  version_field = Pref.string("Version Field", "", "Field name that carries version"),
  base_name = Pref.string("Base Name", "", "Base protocol name label")
}
p.prefs.enable = prefs.enable
p.prefs.version_field = prefs.version_field
p.prefs.base_name = prefs.base_name
local getv = nil
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
  getv = set_field(p.prefs.version_field)
end
getv = set_field(p.prefs.version_field)
function p.dissector(tvb, pinfo, tree)
  if not p.prefs.enable then
    return
  end
  local vf = getv and getv()
  if vf and p.prefs.base_name and #tostring(vf) > 0 then
    pinfo.cols.protocol = p.prefs.base_name .. "_v" .. tostring(vf)
  end
end
register_postdissector(p)
