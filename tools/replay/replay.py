#!/usr/bin/env python3
import json, sys, time
def load_state(path):
  with open(path, "r") as f:
    return json.load(f)
def inject_order(state, symbol, side, price, size):
  now = time.time()
  evt = {"timestamp": now, "hex": "00"}
  return {"packets":[evt]}
def main():
  if len(sys.argv) < 5:
    print("usage: replay.py <state.json> <symbol> <side> <price> <size>")
    sys.exit(1)
  state = load_state(sys.argv[1])
  out = inject_order(state, sys.argv[2], sys.argv[3], float(sys.argv[4]), int(sys.argv[5]))
  print(json.dumps(out))
if __name__ == "__main__":
  main()
