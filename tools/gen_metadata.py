#!/usr/bin/env python3
import re, json, os
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
readme = os.path.join(root, "README.md")
items = []
with open(readme, "r", encoding="utf-8") as f:
    for line in f:
        if line.startswith("|[") and line.count("|") >= 7:
            cols = [c.strip() for c in line.strip().split("|")[1:-1]]
            org = re.sub(r"\[|\].*", "", cols[0])
            division = cols[1]
            data = cols[2]
            protocol = cols[3]
            version = re.sub(r"\[|\].*", "", cols[4])
            date = cols[5]
            size = cols[6]
            testing = cols[7]
            items.append({
                "organization": org,
                "division": division,
                "data": data,
                "protocol": protocol,
                "version": version,
                "date": date,
                "size": size,
                "testing": testing
            })
out = os.path.join(root, "metadata.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump({"protocols": items}, f, indent=2)
print(out)
