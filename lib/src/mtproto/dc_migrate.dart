import '../tg/tg.dart';
import 'client.dart';

extension DcMigration on MtpClient {
  Future<MtpClient> exportToDc(int targetDcId) async {
    final sub = MtpClient(
      appId: appId,
      appHash: appHash,
      dcId: targetDcId,
      ipv6: ipv6,
      timeout: timeout,
      sessionFile: null,
    );

    try {
      if (targetDcId == dcId) {
        sub.copyAuthFrom(this);
        await sub.connect();
        return sub;
      }

      await sub.connect();

      final exported = await invoke(
        AuthExportAuthorizationRequest(dcId: targetDcId),
      );
      final eAuth = exported as AuthExportedAuthorizationObj;

      await sub.invoke(
        AuthImportAuthorizationRequest(id: eAuth.id, bytes: eAuth.bytes),
      );

      return sub;
    } catch (e) {
      try {
        await sub.close();
      } catch (_) {}
      rethrow;
    }
  }
}
