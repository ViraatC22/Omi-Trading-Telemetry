# Omi Intelligence Platform

A high-performance, agentic network telemetry and dissection platform for ultra‑low latency trading. Built on Wireshark Lua 5.4, it fuses kernel‑level filtering, nanosecond time sync, resilient desegmentation, and headless orchestration to deliver deterministic, actionable insights across venues and clouds.

## 🚀 Performance Highlights

- Latency: nanosecond‑level capture correction with PTP and hardware ingress timestamps
- Ingestion: XDP/eBPF pre‑filter drops non‑essential traffic before user space
- Desegmentation: explicit PDU sizing for segmented/fragmented protocols (SBE/FIX hybrids)
- Memory: zero‑copy tendency via LuaJIT FFI typed reads with pure‑Lua fallback
- Orchestration: headless workflows, synthetic replay, CI stability checks

## 🏗️ Architecture Overview

### Core Design Principles

**Determinism & Single‑Pass**
- Post‑dissectors apply in a deterministic order with predictable behavior
- Preference‑driven configuration supports safe, runtime overrides

**Time Synchronization & Hardware Tags**
- `time_sync.lua` applies hardware/PTP offsets to `pinfo.abs_ts`
- `hw_tags.lua` reads embedded ingress timestamps; `latency.lua` prefers hardware time when present

**Resilient Framing**
- `tcp_reassembly.lua` enforces complete PDUs via `desegment_len` and segmented headers
- Multi‑message packet handling for high‑congestion market events

**Agentic & Compliance**
- Surveillance patterns and Expert Infos integrated with `computed.lua` fields
- ZKP notarization for privacy‑preserving audits plus XAI explanations for defense

### System Components

#### 1. Capture Ingress & Pre‑Filter (`tools/ebpf/xdp_filter.c`)
- UDP port allowlist drop at XDP to reduce user‑space load
- Loader script `tools/ebpf/load_xdp.sh` compiles and attaches to the interface

#### 2. TCP Desegmentation (`modules/tcp_reassembly.lua`)
- Explicit PDU sizing with `pinfo.desegment_len`
- Segmented header parsing and multi‑message iteration

#### 3. Dual‑Stream Arbitration (`modules/arbitration.lua`)
- Tracks matching sequences across A/B streams
- Measures arrival delta and flags “Stream Recovery Event”

#### 4. Latency & Jitter (`modules/latency.lua`, `modules/time_sync.lua`, `modules/hw_tags.lua`)
- Hardware/PTP‑aware deltas versus engine time
- Threshold‑based jitter warnings in Info/Expert Infos

#### 5. Order Book Reconstruction (`modules/order_book.lua`)
- Projected BBO with aggregate volume
- Sequence‑aware stale state and rendered subtree

#### 6. Surveillance Patterns (`modules/surveillance.lua`, `modules/expert.lua`)
- Spoofing/layering heuristics and Expert Info annotations
- Exposes `surveillance.get(symbol)` for computed filters

#### 7. Compliance & ZKP (`modules/compliance.lua`, `modules/zkp.lua`)
- Compliance subtree plus NDJSON summaries
- Ledger notarization via hashes for privacy‑preserving proofs

#### 8. TSDB Streaming (`modules/taps_tsdb.lua`)
- Streams symbol/price/size to UDP/TCP endpoints or `tsdb.ndjson`
- Configurable field extractors and transport

#### 9. LLM Context Export (`modules/llm_export.lua`)
- Natural‑language “intent” strings alongside structured summaries
- AI‑ready NDJSON for downstream analytics

#### 10. Agentic Actions (`modules/actions_tap.lua`)
- Emits JSON signals on anomalies, optional kill‑switch behavior

#### 11. Global Sync (`modules/global_sync.lua`)
- Ingests remote metadata via UDP and applies correction factors
- Builds a unified global order timeline

#### 12. Heuristic Auto‑Discovery (`modules/auto_discovery.lua`)
- Version labeling via configurable fields and base name

#### 13. Computed Filters & Columns (`modules/computed.lua`)
- `omi.packet_gap_ms` and `omi.spoofing` for power‑user filters/columns

#### 14. Visual Taps (`modules/taps_heatmap.lua`, `modules/taps_market.lua`)
- TextWindow heatmaps and market summaries

#### 15. Developer Productivity (`modules/hot_reload.lua`, `modules/buffer_utils.lua`, `modules/compat_luajit.lua`)
- Fast reloads, typed raw reads, and native Lua 5.4 bitwise ops

## 🏛️ Professional Production Components

### Market Replay (Digital Twin) (`tools/replay/replay.py`, `tools/synth_from_json.sh`)
**Real‑World Validation**
- Simulate hypothetical orders against historic snapshots
- Generate synthetic PCAPs for regression and scenario testing

### Performance Monitoring (`tools/profiler.sh`)
**Load‑Path Inspection**
- `tshark`‑based profiling for jitter hotspots and decode costs
- Integrates with CI regressions for stability tracking

### Global Orchestration (`modules/global_sync.lua`)
**Multi‑Venue Timeline**
- Aggregate distributed metadata and align across regions/clouds

### Regulatory Workflows (`docs/REGULATORY_WORKFLOW.md`, `tools/regulatory/submit_cat.py`)
**Compliance Pipeline**
- Prepare CAT/MiFID summaries and submit via secure APIs
- Pair with XAI to explain flagged activities

## 🛠️ Build & Install

### Prerequisites
- Wireshark 4.4+ (Lua 5.4)
- `tshark`, `text2pcap`, optional `lua‑socket`
- `clang` for eBPF builds (XDP)

### Installation
- Windows plugins: `%APPDATA%\\Wireshark\\plugins\\`
- macOS plugins: `~/Library/Application Support/Wireshark/Plugins`
- Linux plugins: `/usr/share/wireshark/plugins`
- Place generated dissectors (`Script.Dissector.lua`) into your plugins directory
- Use Analyze → Decode As… to select a protocol when ports overlap

### Compilation (eBPF)
```bash
clang -O2 -g -target bpf -c tools/ebpf/xdp_filter.c -o tools/ebpf/xdp_filter.o
sudo ip link set dev <iface> xdp obj tools/ebpf/xdp_filter.o sec xdp
```

## ▶️ Execution

```bash
# Headless decode
bash tools/headless_runner.sh <pcap> <Script.Dissector.lua>

# Synthetic PCAP generation
bash tools/synth_from_json.sh test/synth/sample.json test/synth/sample.pcap

# TLS decryption workflow
bash tools/decrypt/run_tls.sh <pcap> <Script.Dissector.lua> <keylog.txt>

# XDP pre-filter attach
bash tools/ebpf/load_xdp.sh <iface>
```

## 📊 Performance & Benchmarking

- Profiling: `bash tools/profiler.sh <pcap> <Script.Dissector.lua>`
- Regression: `bash tools/regress.sh <Script.Dissector.lua> <pcaps_dir> <gold_dir> <output_dir>`
- CI: Scheduled pipeline runs syntax loads, metadata generation, synthetic PCAPs, and malformed scans

## 🏛️ Project Structure

```
wireshark-lua/
├── modules/                 # arbitration, latency, book, surveillance, compliance, actions, discovery, computed, visual taps
├── tools/                   # synth/replay/profiler/regress/decrypt/ebpf/headless/regulatory
├── bindings/                # Python and Go API skeletons
├── rust/omi-core/           # Rust crate for hot-path migration and future FFI/Wasm
├── docs/                    # product launch, API spec, library mode, hardware API/cert, regulatory, Rust/Wasm, power users
└── .github/workflows/ci.yml # nightly CI with malformed scan
```

## ⚙️ Production Deployment

- Kernel pre‑filter: attach XDP to reduce user‑space load
- TLS decrypt: integrate key logs for zero‑trust control‑plane analysis
- Global timelines: align distributed captures via correction factors and PTP offsets

## 🔧 Configuration Options

- Time Sync: hardware offset ns, PTP error ns in `OMI Time`
- Hardware Tags: timestamp offset, endianness, unit in `OMI Hardware Tags`
- TSDB Tap: host, port, proto, and field names in `OMI TSDB`
- Arbitration: sequence field and stream ports in `OMI Arbitration`
- Auto Discovery: enable and version/base name in `OMI Auto Discovery`
- Actions Tap: host/port/proto and kill‑switch in `OMI Actions`
- Insider & Predict: heartbeat/order‑size fields and thresholds in `OMI Insider`; window/thresholds in `OMI Predict`

## 🧪 Testing & Validation

- Synthetic verification: generate PCAPs, run regressions, compare gold outputs
- Nightly CI: updates metadata, verifies checksums, fails on “Malformed”
- Reporting: include protocol/version, minimal capture, and specification references

## 🐛 Troubleshooting

- Dissector selection: use Decode As… when multiple protocols share ports
- Lua version: ensure Wireshark 4.4 (Lua 5.4) and remove legacy bitop usage
- Socket streaming: install `lua‑socket` if taps don’t emit
- Hardware timestamps: verify offset/unit/endianness preferences

## 📈 Monitoring & Observability

- Live dashboards: heatmap and market TextWindows
- Metrics & exports: TSDB streams and NDJSON summaries
- Explainability: `xai.lua` produces human‑readable reasons for flags

## 🔗 Related Documentation

- `docs/PRODUCT_LAUNCH.md` branding & licensing tiers
- `docs/API_SPEC.md` NDJSON contracts
- `docs/HARDWARE_API.md` vendor ingestion guidelines
- `docs/DISSECTION_SERVER.md` headless server architecture

## 🤝 Contributing

- Source‑generated repository; propose changes via issues with rationale and examples
- Share production captures responsibly where permitted for verification

## 📄 License

- MIT‑style licensing recommended; ensure organizational compliance

## ⚠️ Disclaimer

- Similarities to existing people, places and/or protocols are incidental
- Use in accordance with applicable laws, exchange rules, and organizational policies

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

- Licensed under the GNU General Public License v3.0 (GPL-3.0); ensure compliance with its copyleft requirements and your organizational policies

Disclaimer

- Similarities to existing people, places and/or protocols are incidental
- Use in accordance with applicable laws, exchange rules, and organizational policies
