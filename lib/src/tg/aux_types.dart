import '../tl/tl_decoder.dart';
import '../tl/tl_encoder.dart';
import 'registry.dart';
import 'types.dart';

/// Wrapper for a top-level `Vector<T>` RPC response — the outer Vector CRC
/// (0x1cb5c415) doesn't map to a TL type of its own, so we surface it here so
/// callers can `if (r is VectorResult) ...` on RPC results.
class VectorResult extends TlObject {
  final List<TlObject> list;
  VectorResult(this.list);

  @override
  int get crc => 0x1cb5c415;

  @override
  void encode(TlEncoder e) {
    throw UnsupportedError('VectorResult is decode-only');
  }

  static VectorResult decode(TlDecoder d) {
    final n = d.readUint32();
    final out = <TlObject>[];
    for (var i = 0; i < n; i++) {
      out.add(decodeObject(d));
    }
    return VectorResult(out);
  }
}

/// Wrapper for a `Bool` RPC response — servers return `boolTrue` / `boolFalse`
/// bare CRCs, which callers surface via `if (r is BoolValue) return r.value`.
class BoolValue extends TlObject {
  final bool value;
  BoolValue(this.value);

  static const int trueCrc = 0x997275b5;
  static const int falseCrc = 0xbc799737;

  @override
  int get crc => value ? trueCrc : falseCrc;

  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }

  static BoolValue decode(int crc) {
    return BoolValue(crc == trueCrc);
  }
}
