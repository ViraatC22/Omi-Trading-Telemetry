Omi Intelligence Platform (HFT Network Telemetry & Dissection Suite)

Overview

- Cross-platform Lua 5.4 dissectors and analytics for binary exchange protocols
- Agentic AI integrations: surveillance, compliance, actions, and export for LLMs/TSDBs
- Modular architecture optimized for performance, time-sync accuracy, and headless orchestration

Performance Highlights

- Latency accuracy: nanosecond-level capture correction with PTP and hardware ingress timestamps
- Ingestion control: XDP/eBPF pre-filter to reduce non-essential traffic before user space
- Desegmentation robustness: explicit PDU sizing for fragmented/segmented protocols
- Zero-copy tendency: LuaJIT FFI typed reads on `tvb:raw()` with pure-Lua fallback
- Headless scalability: CI, synthetic replay, and server-oriented workflows for enterprise use

Architecture Overview

- Core Design Principles
  - Deterministic single-pass post-dissectors for predictable UI/runtime behavior
  - Preference-driven configuration for safe, production overrides at runtime
  - Minimal allocations in hot paths; reuse buffers and typed reads where feasible
- Time Model
  - `time_sync.lua` applies hardware and PTP offsets to `pinfo.abs_ts`
  - `hw_tags.lua` extracts embedded hardware timestamps and `latency.lua` prefers them when present
- Data Model
  - Book state and surveillance patterns are maintained per-symbol with sequence-aware staleness
  - Compliance snapshots and NDJSON summaries flow to external systems without heavy transformation
- Orchestration
  - Headless runners, bindings, and global sync aggregate distributed metadata into unified timelines

System Components

1. Capture Ingress & Pre-Filter
   - `tools/ebpf/xdp_filter.c`, `tools/ebpf/load_xdp.sh` drop low-value traffic by UDP port allowlist
2. TCP Desegmentation
   - `modules/tcp_reassembly.lua` enforces complete PDUs (`desegment_len`) and segmented headers
3. Dual-Stream Arbitration (A/B)
   - `modules/arbitration.lua` measures arrival deltas and flags “Stream Recovery Event”
4. Latency & Jitter Engine
   - `modules/latency.lua`, `modules/time_sync.lua`, `modules/hw_tags.lua` compute deltas and jitter
5. Order Book Reconstruction
   - `modules/order_book.lua` renders a projected BBO and flags stale-state on sequence gaps
6. Surveillance Patterns
   - `modules/surveillance.lua`, `modules/expert.lua` detect spoofing/layering with Expert Infos
7. Compliance & ZKP
   - `modules/compliance.lua`, `modules/zkp.lua` create snapshots and notarize summaries to a ledger
8. TSDB Streaming
   - `modules/taps_tsdb.lua` streams symbol/price/size via UDP/TCP or logs NDJSON to `tsdb.ndjson`
9. LLM Context Export
   - `modules/llm_export.lua` emits natural-language intents alongside structured summaries
10. Agentic Actions
   - `modules/actions_tap.lua` triggers external agents on anomalies with optional kill-switch
11. Global Sync
   - `modules/global_sync.lua` ingests remote timelines and applies correction factors
12. Heuristic Discovery
   - `modules/auto_discovery.lua` labels protocol versions via configured fields
13. Computed Filters & Columns
   - `modules/computed.lua` exposes `omi.packet_gap_ms` and `omi.spoofing` for display filters
14. Visual Taps
   - `modules/taps_heatmap.lua`, `modules/taps_market.lua` TextWindows for live dashboards
15. Developer Productivity
   - `modules/hot_reload.lua`, `modules/buffer_utils.lua`, `modules/compat_luajit.lua` performance/dev helpers

Professional Production Components

- Digital Twin Replay
  - `tools/replay/replay.py` + `tools/synth_from_json.sh` simulate hypothetical orders against historic snapshots
- Performance Monitoring
  - `tools/profiler.sh` and `tshark`-based profiles for load-path inspection
- Global Orchestration
  - `modules/global_sync.lua` aggregates multi-site timelines into one view
- Regulatory Reporters
  - `docs/REGULATORY_WORKFLOW.md`, `tools/regulatory/submit_cat.py` for CAT/MiFID pipeline stubs

Build & Install

- Prerequisites
  - Wireshark 4.4+ with Lua 5.4
  - `tshark`, `text2pcap`, optional `lua-socket`, `clang` for eBPF builds
- Install Paths
  - Windows: `%APPDATA%\Wireshark\plugins\`
  - macOS: `~/Library/Application Support/Wireshark/Plugins`
  - Linux: `/usr/share/wireshark/plugins`
- Installation
  - Place generated dissectors (Script.Dissector.lua) into your plugins directory
  - Use Analyze → Decode As… when multiple dissectors exist for the same port

Execution

- Headless capture decode
  - `bash tools/headless_runner.sh <pcap> <Script.Dissector.lua>`
- Synthetic PCAP generation
  - `bash tools/synth_from_json.sh test/synth/sample.json test/synth/sample.pcap`
- TLS decryption workflow
  - `bash tools/decrypt/run_tls.sh <pcap> <Script.Dissector.lua> <keylog.txt>`
- XDP pre-filter attach
  - `bash tools/ebpf/load_xdp.sh <iface>`
- TSDB stream
  - Configure `OMI TSDB` prefs and run capture; inspect `tsdb.ndjson` or your endpoint

Performance & Benchmarking

- Profiling
  - `bash tools/profiler.sh <pcap> <Script.Dissector.lua>`
- Regression
  - `bash tools/regress.sh <Script.Dissector.lua> <pcaps_dir> <gold_dir> <output_dir>`
- CI Stability
  - `.github/workflows/ci.yml` runs syntax load checks, metadata generation, synthetic PCAPs, and malformed scans on a schedule

Project Structure

- `modules/` core analytics and taps (arbitration, latency, book, surveillance, compliance, actions, discovery, computed)
- `tools/` synthetic generation, replay, profiling, regression, decrypt, eBPF, headless runner, regulatory submitter
- `bindings/` Python and Go API skeletons for enterprise integrations
- `rust/omi-core/` Rust crate for hot-path migration and future FFI/Wasm builds
- `docs/` product launch, API spec, library mode, hardware integration/certification, regulatory, Rust/Wasm, power user filters

Production Deployment

- Kernel pre-filter
  - Attach XDP to reduce user-space load on high line-rate captures
- TLS control-plane decrypt
  - Use key log integration to analyze encrypted sessions as part of zero-trust workflows
- Global timelines
  - Ingest distributed metadata and align captures with correction factors and PTP offsets

Configuration Options

- Time Sync
  - Hardware offset ns, PTP error ns preferences in `OMI Time`
- Hardware Tags
  - Timestamp offset, endianness, unit preferences in `OMI Hardware Tags`
- TSDB Tap
  - Host, port, proto, and field names for symbol/price/size in `OMI TSDB`
- Arbitration
  - Sequence field and stream ports in `OMI Arbitration`
- Auto Discovery
  - Enable and configure version/base name in `OMI Auto Discovery`
- Actions Tap
  - Host/port/proto and kill-switch preference in `OMI Actions`
- Insider & Predict
  - Heartbeat/order-size fields and thresholds in `OMI Insider`; window/thresholds in `OMI Predict`

Testing & Validation

- Synthetic verification
  - Generate PCAPs, run regressions, and compare outputs to gold references
- Nightly CI
  - Scheduled pipeline updates metadata, verifies checksums, and fails on “Malformed”
- Reporting issues
  - Include protocol/version, minimal capture, and specification references

Troubleshooting

- Dissector selection
  - Use Decode As… for ports shared by multiple protocols
- Lua version
  - Ensure Wireshark uses Lua 5.4; remove third-party bitop references
- Socket streaming
  - Install `lua-socket` if TSDB/agent taps are not streaming
- Hardware timestamps
  - Verify offset/unit/endianness preferences for embedded tags

Monitoring & Observability

- Live dashboards
  - Heatmap and market TextWindows for fast visual checks
- Metrics & exports
  - TSDB streams and NDJSON summaries feed external monitoring stacks
- Explainability
  - `xai.lua` provides human-readable reasons for flagged patterns

Related Documentation

- `docs/PRODUCT_LAUNCH.md` branding and licensing tiers
- `docs/API_SPEC.md` NDJSON field formats and contracts
- `docs/HARDWARE_API.md` vendor ingestion guidelines
- `docs/DISSECTION_SERVER.md` headless server architecture sketch

Contributing

- Source-generated repository; propose changes via issues with rationale and examples
- Share production captures responsibly where permitted for protocol verification

License

- MIT-style licensing recommended; ensure compliance with your organizational policies

Disclaimer

- Similarities to existing people, places and/or protocols are incidental
- Use in accordance with applicable laws, exchange rules, and organizational policies
