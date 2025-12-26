Hardware Integration API

- Vendors emit UDP NDJSON lines with fields ts,symbol,seq,ingress_ns
- OMI ingests and aligns timestamps via global sync and hw tags
