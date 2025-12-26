local p = Proto("omi_zkp", "OMI ZKP")
local prefs = {
  org = Pref.string("Org", "", "Organization id"),
  ledger = Pref.string("Ledger Path", "ledger.ndjson", "Ledger output path")
}
p.prefs.org = prefs.org
p.prefs.ledger = prefs.ledger
local function sha(s)
  local ok, openssl = pcall(require, "openssl")
  if ok and openssl then
    return openssl.digest.digest("sha256", s)
  else
    local sum = 0
    for i = 1, #s do sum = (sum + string.byte(s, i)) % 4294967295 end
    return tostring(sum)
  end
end
local function write(path, line)
  local f = io.open(path, "a")
  if f then f:write(line .. "\n") f:flush() f:close() end
end
local M = {}
function M.notarize(summary)
  local org = p.prefs.org or ""
  local led = p.prefs.ledger or "ledger.ndjson"
  local h = sha(summary)
  local line = string.format("{\"org\":\"%s\",\"hash\":\"%s\"}", org, h)
  write(led, line)
end
register_postdissector(p)
return M
