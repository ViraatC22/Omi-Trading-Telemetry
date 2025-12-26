#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
struct {
  __uint(type, BPF_MAP_TYPE_HASH);
  __uint(max_entries, 1024);
  __type(key, __u16);
  __type(value, __u8);
} ports SEC(".maps");
SEC("xdp")
int xdp_prog(struct xdp_md *ctx) {
  void *data_end = (void *)(long)ctx->data_end;
  void *data = (void *)(long)ctx->data;
  unsigned char *p = data;
  if (p + 42 > (unsigned char *)data_end) return XDP_PASS;
  __u16 proto = (__u16)(p[12] << 8 | p[13]);
  if (proto != 0x0800) return XDP_PASS;
  unsigned char iphdrlen = (p[14] & 0x0F) * 4;
  if (p + 14 + iphdrlen + 8 > (unsigned char *)data_end) return XDP_PASS;
  __u8 ipproto = p[23];
  if (ipproto != 17) return XDP_PASS;
  __u16 dport = (__u16)(p[14 + iphdrlen + 2] << 8 | p[14 + iphdrlen + 3]);
  __u8 *allow = bpf_map_lookup_elem(&ports, &dport);
  if (!allow) return XDP_DROP;
  return XDP_PASS;
}
char LICENSE[] SEC("license") = "GPL";
