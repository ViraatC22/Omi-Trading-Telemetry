#!/usr/bin/env bash
set -euo pipefail
PCAP="${1:-}"
SCRIPT="${2:-}"
if [ -z "$PCAP" ] || [ -z "$SCRIPT" ]; then
  echo "usage: profiler.sh <pcap> <lua_script>"
  exit 1
fi
/usr/bin/time -p tshark -X "lua_script:$SCRIPT" -r "$PCAP" -q >/dev/null
