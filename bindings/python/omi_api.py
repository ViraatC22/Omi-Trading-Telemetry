class OmiApi:
    def __init__(self):
        self.endpoint = None
    def connect_tsdb(self, host, port, proto="udp"):
        self.endpoint = (host, port, proto)
    def stream_event(self, sym, price, size, ts):
        return {"ts": ts, "sym": sym, "price": price, "size": size}
    def correlate_order(self, a_id, b_id):
        return {"a": a_id, "b": b_id}
    def decode_pcap(self, path, script):
        return {"pcap": path, "script": script}
    def configure_time(self, hardware_offset_ns, ptp_error_ns):
        return {"hw": hardware_offset_ns, "ptp": ptp_error_ns}
