#!/usr/bin/env bash
set -euo pipefail
PCAP="${1:-wireshark-lua/test/synth/sample.pcap}"
SCRIPT="${2:-wireshark-lua/Nasdaq/Nasdaq.Equities.TotalView.Itch.v4.1.Script.Dissector.lua}"
OUT="$(mktemp)"
tshark -X "lua_script:$SCRIPT" -r "$PCAP" -V >"$OUT"
if grep -q "Malformed" "$OUT"; then
  echo "malformed detected"
  rm -f "$OUT"
  exit 1
fi
rm -f "$OUT"
echo "ok"
