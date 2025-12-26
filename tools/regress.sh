#!/usr/bin/env bash
set -euo pipefail
SCRIPTPATH="${1:-}"
PCAP_DIR="${2:-test/pcaps}"
GOLD_DIR="${3:-test/gold}"
OUT_DIR="${4:-test/output}"
mkdir -p "$OUT_DIR"
if [ -z "$SCRIPTPATH" ]; then
  echo "usage: regress.sh <lua_script> [pcap_dir] [gold_dir] [out_dir]"
  exit 1
fi
status=0
for p in "$PCAP_DIR"/*; do
  name="$(basename "$p")"
  out="$OUT_DIR/$name.txt"
  gold="$GOLD_DIR/$name.txt"
  tshark -X "lua_script:$SCRIPTPATH" -r "$p" -V >"$out"
  if [ -f "$gold" ]; then
    if ! diff -u "$gold" "$out" >/dev/null; then
      echo "diff: $name"
      status=1
    fi
  else
    echo "missing gold: $name"
    status=1
  fi
done
exit $status
