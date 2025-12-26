#!/usr/bin/env bash
set -euo pipefail
PCAP="${1:-}"
SCRIPT="${2:-}"
if [ -z "$PCAP" ] || [ -z "$SCRIPT" ]; then
  echo "usage: headless_runner.sh <pcap> <script.lua>"
  exit 1
fi
tshark -X "lua_script:$SCRIPT" -r "$PCAP" -V
