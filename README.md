Omi Intelligence Platform (Wireshark Lua Dissector Suite)

Overview

- Cross-platform Lua 5.4 dissectors and analytics for common binary exchange protocols
- Moves beyond passive observation to active intelligence with arbitration, surveillance, compliance and agentic actions
- Modular architecture for performance, time-sync accuracy and enterprise orchestration

Quick Start

- Windows plugins: %APPDATA%\Wireshark\plugins\
- macOS plugins: ~/Library/Application Support/Wireshark/Plugins
- Linux plugins: /usr/share/wireshark/plugins
- Place generated dissector scripts (Script.Dissector.lua) into your plugins directory
- Decode As…: When multiple dissectors exist, use Analyze → Decode As… to select the correct protocol
- Lua 5.4: Wireshark 4.4 ships Lua 5.4; the suite uses native bitwise ops (& | ~ << >>) and avoids legacy bitop

Core Features

- Dual-Stream Arbitration (A/B)
  - Module: modules/arbitration.lua
  - Tracks identical sequences across redundant UDP streams and flags “Stream Recovery Event”
  - Measures A/B arrival delta to expose path imbalances
- Multi-Stage TCP Desegmentation
  - Module: modules/tcp_reassembly.lua
  - Explicit PDU sizing with desegment_len and segmented header handling for SBE/FIX hybrids
- Precision Time Sync & Hardware Tags
  - Modules: modules/time_sync.lua, modules/hw_tags.lua, modules/latency.lua
  - Corrects capture time via hardware/PTP offsets; prefers hardware ingress timestamps for sub-µs jitter
- Latency & Jitter Analytics
  - Module: modules/latency.lua
  - Computes deltas between capture vs engine timestamps; warns on jitter over thresholds
- Order Book Reconstruction
  - Module: modules/order_book.lua
  - Maintains projected BBO, volume and stale-state tracking based on sequence gaps; renders subtree
- Surveillance-Ready Expert Infos
  - Modules: modules/surveillance.lua, modules/expert.lua
  - Flags spoofing/layering-like patterns; integrates with computed fields and XAI explanations
- Compliance & JSON Export
  - Modules: modules/compliance.lua, modules/json_export.lua
  - Adds a “Compliance” subtree and exports structured summaries for downstream AI tooling
- Agentic TSDB Streaming
  - Module: modules/taps_tsdb.lua
  - Streams symbol/price/size to InfluxDB/Kdb+ endpoints via UDP/TCP or logs to tsdb.ndjson
- LLM-Ready Contextual Export
  - Module: modules/llm_export.lua
  - Adds natural-language intent (momentum vs mean-reversion and timing context) in NDJSON output
- Computed Display Filters & Columns
  - Module: modules/computed.lua
  - Fields: omi.packet_gap_ms, omi.spoofing for power-user filters and columns
  - Doc: docs/POWER_USERS.md with spread, bitrate and delta recipes
- Heuristic Auto Version Discovery
  - Module: modules/auto_discovery.lua
  - Labels protocol version in packet list via a configurable version field and base name
- Visual Taps & Dashboards
  - Modules: modules/taps_heatmap.lua, modules/taps_market.lua
  - TextWindow heatmaps and market summaries for real-time visualization
- Hot Reload
  - Module: modules/hot_reload.lua
  - Rapid reloading without full Wireshark restart to accelerate generator iteration

Enterprise Tooling

- Synthetic PCAP Generator
  - Tool: tools/synth_from_json.sh
  - Converts JSON hex packets to PCAP via text2pcap for “clean room” verification
- Regression & Metadata
  - Tools: tools/regress.sh, tools/gen_metadata.py, tools/update_checksums.py
  - Builds metadata.json catalog and tracks gold outputs via SHA-256 checksums
- CI Pipeline
  - Workflow: .github/workflows/ci.yml
  - Syntax load checks, metadata generation, synthetic PCAP creation and malformed scan; scheduled daily
- eBPF/XDP Pre-Filter
  - Tools: tools/ebpf/xdp_filter.c, tools/ebpf/load_xdp.sh
  - Kernel-level drop of low-value traffic by UDP port allowlist for high line rates
- Digital Twin Replay
  - Tool: tools/replay/replay.py
  - Emits synthetic injections compatible with synth_from_json.sh to replay hypothetical orders
- Agentic Actions
  - Module: modules/actions_tap.lua
  - Sends JSON to external agents when anomalies are detected; optional kill-switch behavior
- Global Sync Orchestration
  - Module: modules/global_sync.lua
  - Ingests remote metadata via UDP and aligns into a unified global timeline
- Hardware Ingest API
  - Modules/Docs: modules/hw_ingest.lua, docs/HARDWARE_API.md
  - Standardizes vendor NDJSON log format and annotates captures
- Regulatory Workflows
  - Docs/Tools: docs/REGULATORY_WORKFLOW.md, tools/regulatory/submit_cat.py
  - Prepares CAT/MiFID summaries and submits via secure APIs with XAI explanations
- Headless Library Mode
  - Docs/Tools: docs/LIBRARY_MODE.md, tools/headless_runner.sh
  - Runs dissectors without a GUI for dashboard integration and automation
- Bindings
  - Python: bindings/python/omi_api.py
  - Go: bindings/go/omiapi/omiapi.go
  - Stream events, correlate orders, decode PCAPs, and configure timing via stable APIs
- Rust & Wasm Roadmap
  - Crate: rust/omi-core
  - Docs: docs/RUST_MIGRATION.md, docs/WASM.md
  - Move hot paths to Rust with FFI and explore cloud-native decode via WebAssembly

Usage Examples

- Load a dissector headlessly:
  - `bash tools/headless_runner.sh test/synth/sample.pcap <Script.Dissector.lua>`
- Generate synthetic PCAP from JSON:
  - `bash tools/synth_from_json.sh test/synth/sample.json test/synth/sample.pcap`
- Stream to TSDB:
  - Configure `OMI TSDB` prefs for `symbol/price/size` fields and `host/port`, then run capture
- Apply power-user columns:
  - `omi.packet_gap_ms`, `frame.len * 8`, `nasdaq.bbo.askprice - nasdaq.bbo.bidprice`
- Decrypt TLS control-plane:
  - `bash tools/decrypt/run_tls.sh <pcap> <Script.Dissector.lua> <keylog.txt>`
- Attach XDP pre-filter:
  - `bash tools/ebpf/load_xdp.sh <iface>`

Protocols & Catalog

- Use `python3 tools/gen_metadata.py` to build `metadata.json` catalog from README protocol table
- Nightly CI updates gold checksums via `tools/update_checksums.py` and runs malformed scans
- Many protocols auto-discover version; otherwise use Analyze → Decode As… for manual selection

Development

- Report dissection errors with minimal captures and specification references
- Production captures are required for verification; share safely where permitted
- The repository is source-generated; propose changes via issues for generator updates

Security & Zero-Trust Forensics

- ETP Workflow: docs/ETP_WORKFLOW.md with TLS key log integration via `tshark`
- Insider Threat: modules/insider.lua monitors heartbeat bursts and low-size order leakage patterns

Predictive Microstructure

- Predictive alerts: modules/predict.lua raises early warnings based on recent load patterns
- Path recommendations: modules/path_reco.lua surfaces A/B stream guidance; extend with arbitration deltas

Explainability

- XAI: modules/xai.lua generates human-readable explanations for patterns (layering, spoofing) using contextual metrics

Disclaimer

- Similarities to existing people, places and/or protocols are incidental
- Use in accordance with applicable laws, exchange rules and organizational policies
