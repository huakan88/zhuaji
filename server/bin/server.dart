import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;

import 'package:zhuaji_api/src/api.dart';
import 'package:zhuaji_api/src/store.dart';

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final secret = Platform.environment['JWT_SECRET'] ?? 'dev-secret-change-me';
  final databaseUrl = Platform.environment['DATABASE_URL'];
  final devAuth = (Platform.environment['AUTH_DEV'] ?? '1') != '0';
  final wechatMock = Platform.environment['WECHAT_MOCK'] == '1';
  final shareKey = Platform.environment['BARCODE_SHARE_KEY'] ?? '';
  final store = databaseUrl == null || databaseUrl.isEmpty
      ? MemoryStore()
      : await PostgresStore.open(databaseUrl);
  final server = await io.serve(
    buildApi(
      store,
      jwtSecret: secret,
      devAuth: devAuth,
      wechatMock: wechatMock,
      shareKey: shareKey,
    ),
    InternetAddress.anyIPv4,
    port,
  );
  stdout.writeln('肉垫本 API http://${server.address.host}:${server.port}');
}
