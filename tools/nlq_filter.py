#!/usr/bin/env python3
import re, sys
def gen(text):
  t = text.lower()
  ms = 200
  if m := re.search(r"(\d+)\s*micro", t):
    ms = int(m.group(1)) / 1000.0
  side = "S"
  if "sell" in t: side = "S"
  if "buy" in t: side = "B"
  return f'omi.packet_gap_ms > {int(ms)} && nasdaq.side == "{side}"'
def main():
  if len(sys.argv) < 2:
    print("usage: nlq_filter.py <text>")
    sys.exit(1)
  print(gen(sys.argv[1]))
if __name__ == "__main__":
  main()
