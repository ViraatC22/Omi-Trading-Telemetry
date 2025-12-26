API Overview

- Stream: send symbol, price, size, ts
- Correlate: link order ids across protocols
- Latency: provide corrected capture and engine deltas
- Arbitration: publish A/B arrival deltas
- Compliance: emit summaries with tags

Formats

- NDJSON lines with fields ts,symbol,side,price,size,seq,tags
