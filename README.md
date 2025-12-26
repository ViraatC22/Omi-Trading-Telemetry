Omi Intelligence Platform
HFT Network Telemetry & Dissection Suite
Overview

Omi Intelligence Platform (OMI) is a high-performance, cross-platform telemetry and protocol dissection framework for high-frequency trading (HFT) networks. It combines deterministic Lua 5.4 dissectors, nanosecond-accurate time correction, and agentic AI integrations to enable deep inspection, reconstruction, and analysis of exchange traffic at scale.

OMI is designed for production deployment, headless orchestration, and regulatory-grade observability, bridging packet-level truth with higher-order analytics, compliance, and AI-assisted reasoning.

Key Capabilities

Cross-platform Lua 5.4 dissectors and analytics for binary exchange protocols

Agentic AI integrations for surveillance, compliance, actions, and LLM/TSDB export

Modular architecture optimized for:

Ultra-low latency

Time-sync accuracy

Headless and CI-driven workflows

Performance Highlights

Latency accuracy
Nanosecond-level capture correction using PTP and hardware ingress timestamps

Ingestion control
XDP/eBPF pre-filtering drops non-essential traffic before user space

Robust desegmentation
Explicit PDU sizing for fragmented and segmented protocols

Zero-copy tendency
LuaJIT FFI typed reads on tvb:raw() with pure-Lua fallback

Headless scalability
CI, synthetic replay, and server-oriented workflows for enterprise use

Architecture Overview
Core Design Principles

Deterministic, single-pass post-dissectors for predictable runtime behavior

Preference-driven configuration for safe production overrides

Minimal allocations in hot paths; reuse buffers and typed reads wherever possible

Time Model

time_sync.lua
Applies hardware and PTP offsets to pinfo.abs_ts

hw_tags.lua
Extracts embedded hardware timestamps

latency.lua
Prefers hardware timestamps when present, with safe fallback logic

Data Model

Per-symbol order book state with sequence-aware staleness detection

Surveillance patterns maintained independently of visualization

Compliance snapshots and NDJSON summaries exported without heavy transformation

Orchestration

Headless runners and bindings

Global synchronization aggregates distributed metadata into unified timelines

System Components

Capture Ingress & Pre-Filter
tools/ebpf/xdp_filter.c, tools/ebpf/load_xdp.sh
→ Drops low-value traffic by UDP port allowlist

TCP Desegmentation
modules/tcp_reassembly.lua
→ Enforces complete PDUs and segmented headers

Dual-Stream Arbitration (A/B)
modules/arbitration.lua
→ Measures arrival deltas and flags Stream Recovery Events

Latency & Jitter Engine
modules/latency.lua, modules/time_sync.lua, modules/hw_tags.lua

Order Book Reconstruction
modules/order_book.lua
→ Projected BBO with stale-state detection

Surveillance Patterns
modules/surveillance.lua, modules/expert.lua
→ Spoofing, layering, and expert annotations

Compliance & ZKP
modules/compliance.lua, modules/zkp.lua
→ Snapshots and ledger-ready summaries

TSDB Streaming
modules/taps_tsdb.lua
→ UDP/TCP streams or NDJSON logs (tsdb.ndjson)

LLM Context Export
modules/llm_export.lua
→ Natural-language intents + structured summaries

Agentic Actions
modules/actions_tap.lua
→ External agent triggers with kill-switch support

Global Sync
modules/global_sync.lua
→ Multi-site timeline aggregation

Heuristic Discovery
modules/auto_discovery.lua
→ Protocol version labeling

Computed Filters & Columns
modules/computed.lua
→ omi.packet_gap_ms, omi.spoofing, etc.

Visual Taps
modules/taps_heatmap.lua, modules/taps_market.lua
→ Live TextWindow dashboards

Developer Productivity
Hot reload, buffer utilities, LuaJIT compatibility helpers

Professional Production Components

Digital Twin Replay
tools/replay/replay.py, tools/synth_from_json.sh

Performance Monitoring
tools/profiler.sh, tshark-based profiling

Global Orchestration
Unified multi-site timeline alignment

Regulatory Reporters
CAT / MiFID pipeline stubs

Build & Install
Prerequisites

Wireshark 4.4+ with Lua 5.4

tshark, text2pcap

Optional: lua-socket, clang (for eBPF)

Install Paths

Windows
%APPDATA%\Wireshark\plugins\

macOS
~/Library/Application Support/Wireshark/Plugins

Linux
/usr/share/wireshark/plugins

Installation

Place generated dissectors (Script.Dissector.lua) into the plugins directory

Use Analyze → Decode As… if multiple dissectors share a port

Execution
Headless Decode
bash tools/headless_runner.sh <pcap> <Script.Dissector.lua>

Synthetic PCAP Generation
bash tools/synth_from_json.sh test/synth/sample.json test/synth/sample.pcap

TLS Decryption
bash tools/decrypt/run_tls.sh <pcap> <Script.Dissector.lua> <keylog.txt>

XDP Pre-Filter
bash tools/ebpf/load_xdp.sh <iface>

TSDB Streaming

Configure OMI TSDB preferences and inspect tsdb.ndjson or your endpoint.

Performance & Benchmarking

Profiling

bash tools/profiler.sh <pcap> <Script.Dissector.lua>


Regression

bash tools/regress.sh <Script.Dissector.lua> <pcaps_dir> <gold_dir> <output_dir>


CI Stability
.github/workflows/ci.yml validates syntax, metadata, synthetic PCAPs, and malformed input handling.

Project Structure
modules/    Core analytics, taps, surveillance, compliance
tools/      Replay, profiling, regression, decrypt, eBPF
bindings/   Python and Go integration skeletons
rust/       omi-core hot-path crate (future FFI/Wasm)
docs/       Product, API, hardware, regulatory documentation

Production Deployment

Kernel-level XDP filtering for high line-rate captures

TLS control-plane decryption for zero-trust analysis

Global timeline alignment using PTP and correction factors

Configuration Options

OMI Time – hardware offset & PTP error (ns)

OMI Hardware Tags – offset, unit, endianness

OMI TSDB – host, port, protocol, field mapping

OMI Arbitration – sequence fields, stream ports

OMI Auto Discovery – protocol labeling

OMI Actions – agent endpoints and kill-switch

OMI Insider / Predict – thresholds and windows

Testing & Validation

Synthetic PCAP verification against gold references

Nightly CI with checksum validation and malformed scans

Issue reports should include protocol/version and minimal capture

Troubleshooting

Use Decode As… for shared ports

Ensure Wireshark runs Lua 5.4

Install lua-socket for streaming taps

Verify timestamp offsets and endianness for hardware tags

Monitoring & Observability

Live heatmap and market dashboards

TSDB + NDJSON feeds for external observability stacks

Explainability via xai.lua human-readable reasoning

Related Documentation

docs/PRODUCT_LAUNCH.md

docs/API_SPEC.md

docs/HARDWARE_API.md

docs/DISSECTION_SERVER.md

Contributing

This is a source-generated repository.
Propose changes via issues with clear rationale and examples.
Share production captures responsibly and lawfully.

License

MIT-style licensing recommended.
Ensure compliance with organizational and regulatory requirements.

Disclaimer

Similarities to existing people, exchanges, or protocols are incidental

Use in accordance with applicable laws, exchange rules, and internal policies
