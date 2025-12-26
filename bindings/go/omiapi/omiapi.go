package omiapi
type Endpoint struct{ Host string; Port int; Proto string }
type OmiApi struct{ Endpoint *Endpoint }
func New() *OmiApi { return &OmiApi{} }
func (o *OmiApi) ConnectTSDB(host string, port int, proto string) { o.Endpoint = &Endpoint{Host: host, Port: port, Proto: proto} }
func (o *OmiApi) StreamEvent(sym string, price float64, size int, ts float64) map[string]interface{} {
	return map[string]interface{}{"ts": ts, "sym": sym, "price": price, "size": size}
}
func (o *OmiApi) CorrelateOrder(a string, b string) map[string]string { return map[string]string{"a": a, "b": b} }
func (o *OmiApi) DecodePcap(path string, script string) map[string]string { return map[string]string{"pcap": path, "script": script} }
func (o *OmiApi) ConfigureTime(hardwareOffsetNs int64, ptpErrorNs int64) map[string]int64 {
	return map[string]int64{"hw": hardwareOffsetNs, "ptp": ptpErrorNs}
}
