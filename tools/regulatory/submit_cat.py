#!/usr/bin/env python3
import sys, json, urllib.request
def main():
  if len(sys.argv) < 4:
    print("usage: submit_cat.py <summary.json> <api_url> <token>")
    sys.exit(1)
  with open(sys.argv[1], "r") as f:
    data = json.load(f)
  req = urllib.request.Request(sys.argv[2], data=json.dumps(data).encode("utf-8"), headers={"Authorization":"Bearer "+sys.argv[3], "Content-Type":"application/json"})
  try:
    with urllib.request.urlopen(req) as resp:
      print(resp.read().decode("utf-8"))
  except Exception as e:
    print("error", e)
    sys.exit(1)
if __name__ == "__main__":
  main()
