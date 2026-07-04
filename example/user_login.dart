import 'dart:io';
import 'package:mtflute/mtflute.dart';

const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';

Future<String> _ask(String prompt) async {
  stdout.write(prompt);
  return stdin.readLineSync()?.trim() ?? '';
}

Future<void> main() async {
  final client = MtpClient(
    appId: _appId,
    appHash: _appHash,
    sessionFile: 'user.session',
  );

  await client.login(codeCallback: _ask, passwordCallback: _ask);

  final me = await client.getMe();
  if (me is UserObj) {
    print(
      '\n✓ Logged in as ${me.firstName} ${me.lastName ?? ''} (id=${me.id}, phone=${me.phone})',
    );
  }

  await client.close();
}
