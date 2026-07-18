import 'dart:typed_data';

abstract class Transport {
  Future<void> connect();
  Future<void> writeMsg(Uint8List data, {bool quickAck});
  Future<Uint8List> readMsg();
  Future<void> close();
  bool get isConnected;
  DateTime get lastReadAt;
}
