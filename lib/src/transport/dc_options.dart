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

const testDcOptions = [
  DcOption(
    id: 1,
    ipv4: '149.154.175.10',
    ipv6: '2001:0b28:f23d:f001:0000:0000:0000:000e',
    port: 443,
  ),
  DcOption(
    id: 2,
    ipv4: '149.154.167.40',
    ipv6: '2001:067c:04e8:f002:0000:0000:0000:000e',
    port: 443,
  ),
  DcOption(
    id: 3,
    ipv4: '149.154.175.117',
    ipv6: '2001:0b28:f23d:f003:0000:0000:0000:000e',
    port: 443,
  ),
];

/// Returns `host:port`. IPv6 hosts are bracketed so the port is unambiguous
/// and [dcHostPort] can split them back apart.
String getDcAddress(int dcId, {bool ipv6 = false, bool testMode = false}) {
  final table = testMode ? testDcOptions : defaultDcOptions;
  final dc = table.firstWhere(
    (d) => d.id == dcId,
    orElse: () => table[table.length > 1 ? 1 : 0],
  );
  if (ipv6) return '[${dc.ipv6}]:${dc.port}';
  return '${dc.ipv4}:${dc.port}';
}

/// Splits a `host:port` (or `[ipv6]:port`) address into its host and port.
(String host, int port) dcHostPort(String addr) {
  if (addr.startsWith('[')) {
    final end = addr.indexOf(']');
    final host = addr.substring(1, end);
    final port = int.parse(addr.substring(end + 2));
    return (host, port);
  }
  final idx = addr.lastIndexOf(':');
  return (addr.substring(0, idx), int.parse(addr.substring(idx + 1)));
}

int dcIdFromAddress(String addr) {
  final (host, _) = dcHostPort(addr);
  for (final dc in defaultDcOptions) {
    if (dc.ipv4 == host || dc.ipv6 == host) return dc.id;
  }
  return 2;
}
