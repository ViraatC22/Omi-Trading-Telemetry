#!/usr/bin/env bash
set -euo pipefail
PCAP="${1:-}"
SCRIPT="${2:-}"
KEYLOG="${3:-}"
if [ -z "$PCAP" ] || [ -z "$SCRIPT" ] || [ -z "$KEYLOG" ]; then
  echo "usage: run_tls.sh <pcap> <script.lua> <keylog.txt>"
  exit 1
fi
tshark -o tls.keylog_file:"$KEYLOG" -X "lua_script:$SCRIPT" -r "$PCAP" -V
