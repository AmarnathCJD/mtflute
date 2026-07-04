class DcOption {
  final int id;
  final String ipv4;
  final String ipv6;
  final int port;

  const DcOption({
    required this.id,
    required this.ipv4,
    required this.ipv6,
    this.port = 443,
  });
}

const defaultDcOptions = [
  DcOption(
    id: 1,
    ipv4: '149.154.175.53',
    ipv6: '2001:0b28:f23d:f001:0000:0000:0000:000a',
    port: 443,
  ),
  DcOption(
    id: 2,
    ipv4: '149.154.167.51',
    ipv6: '2001:067c:04e8:f002:0000:0000:0000:000a',
    port: 443,
  ),
  DcOption(
    id: 3,
    ipv4: '149.154.175.100',
    ipv6: '2001:0b28:f23d:f003:0000:0000:0000:000a',
    port: 443,
  ),
  DcOption(
    id: 4,
    ipv4: '149.154.167.91',
    ipv6: '2001:067c:04e8:f004:0000:0000:0000:000a',
    port: 443,
  ),
  DcOption(
    id: 5,
    ipv4: '91.108.56.130',
    ipv6: '2001:0b28:f23f:f005:0000:0000:0000:000a',
    port: 443,
  ),
];

String getDcAddress(int dcId, {bool ipv6 = false}) {
  final dc = defaultDcOptions.firstWhere(
    (d) => d.id == dcId,
    orElse: () => defaultDcOptions[1],
  );
  final ip = ipv6 ? dc.ipv6 : dc.ipv4;
  return '$ip:${dc.port}';
}

int dcIdFromAddress(String addr) {
  final host = addr.split(':').first;
  for (final dc in defaultDcOptions) {
    if (dc.ipv4 == host || dc.ipv6 == host) return dc.id;
  }
  return 2;
}
