@Tags(['live'])
library;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/transport/tcp_transport.dart';
import 'package:mtflute/src/transport/transport_mode.dart';
import 'package:mtflute/src/mtproto/handshake.dart';
import 'package:mtflute/src/mtproto/messages.dart';

void main() {
  test(
    'connect to DC2 and generate auth key',
    () async {
      final transport = TcpTransport(
        host: '149.154.167.51',
        port: 443,
        modeVariant: TransportModeVariant.abridged,
        timeout: const Duration(seconds: 15),
      );

      await transport.connect();
      expect(transport.isConnected, true);

      Future<Uint8List> sendAndReceive(Uint8List request) async {
        final serialized = serializeUnencrypted(request, _genMsgId());
        await transport.writeMsg(serialized);
        final response = await transport.readMsg();
        final msg = deserializeUnencrypted(response);
        return msg.msg;
      }

      final result = await performHandshake(
        sendAndReceive: sendAndReceive,
        dcId: 2,
      );

      expect(result.authKey.length, 256);
      expect(result.authKeyHash.length, 8);
      expect(result.serverTime, greaterThan(0));

      print('Auth key generated successfully!');
      print('  Key length: ${result.authKey.length} bytes');
      print(
        '  Key hash: ${result.authKeyHash.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
      );
      print('  Server salt: ${result.serverSalt}');
      print('  Server time: ${result.serverTime}');

      await transport.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}

int _msgIdCounter = 0;

int _genMsgId() {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  _msgIdCounter++;
  return (now << 32) | (_msgIdCounter << 2);
}
