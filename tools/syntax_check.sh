#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
while IFS= read -r -d '' f; do
  if ! tshark -X "lua_script:$f" -r /dev/null -q >/dev/null 2>&1; then
    echo "syntax error: $f"
    fail=1
  fi
done < <(find "$ROOT" -name "*Script.Dissector.lua" -print0)
exit $fail
