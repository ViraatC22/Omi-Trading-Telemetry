#!/usr/bin/env python3
import os, glob, json, hashlib
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
gold_dir = os.path.join(root, "test", "gold")
metadata_path = os.path.join(root, "metadata.json")
checksums = {}
for path in glob.glob(os.path.join(gold_dir, "*.txt")):
    name = os.path.basename(path)
    with open(path, "rb") as f:
        data = f.read()
    sha = hashlib.sha256(data).hexdigest()
    checksums[name] = sha
meta = {}
if os.path.exists(metadata_path):
    with open(metadata_path, "r", encoding="utf-8") as f:
        try:
            meta = json.load(f)
        except Exception:
            meta = {}
meta["gold_checksums"] = checksums
with open(metadata_path, "w", encoding="utf-8") as f:
    json.dump(meta, f, indent=2, sort_keys=True)
print(metadata_path)
