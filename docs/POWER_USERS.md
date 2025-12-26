Power User Columns

- Spread: nasdaq.bbo.askprice - nasdaq.bbo.bidprice
- Packet Gap ms: omi.packet_gap_ms
- Spoofing Suspect: omi.spoofing
- Price Delta: nasdaq.lastprice - nasdaq.bidprice
- Bitrate: frame.len * 8

Display Filters

- omi.spoofing == 1
- omi.packet_gap_ms > 5
- tcp.port == 12345 and omi.packet_gap_ms > 1
