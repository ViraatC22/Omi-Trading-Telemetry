#!/usr/bin/env bash
set -euo pipefail
JSON="${1:-}"
OUT="${2:-synth.pcap}"
TMP="$(mktemp)"
if [ -z "$JSON" ]; then
  echo "usage: synth_from_json.sh <json> [out.pcap]"
  exit 1
fi
python3 - "$JSON" > "$TMP" << 'PY'
import sys, json
f = open(sys.argv[1], 'r')
data = json.load(f)
for pkt in data.get('packets', []):
    ts = pkt.get('timestamp', 0)
    hexs = pkt.get('hex', '')
    print("%d.%06d %s" % (int(ts), int((ts-int(ts))*1e6), hexs))
PY
text2pcap "$TMP" "$OUT" >/dev/null
rm -f "$TMP"
echo "$OUT"
