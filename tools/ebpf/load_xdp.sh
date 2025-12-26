#!/usr/bin/env bash
set -euo pipefail
IFACE="${1:-eth0}"
OBJ="wireshark-lua/tools/ebpf/xdp_filter.o"
clang -O2 -g -target bpf -c wireshark-lua/tools/ebpf/xdp_filter.c -o "$OBJ"
sudo ip link set dev "$IFACE" xdp obj "$OBJ" sec xdp
