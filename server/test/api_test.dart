import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:zhuaji_api/src/api.dart';
import 'package:zhuaji_api/src/store.dart';

void main() {
  const secret = 'test-secret';
  late MemoryStore store;
  late Handler api;

  setUp(() {
    store = MemoryStore();
    api = buildApi(store, jwtSecret: secret, devAuth: true, wechatMock: true);
  });

  test('phone login then create a cat and reject an older weight', () async {
    final requested = await call(api, 'POST', '/v1/auth/phone/request', {
      'phone': '13800138000',
    });
    expect(requested.statusCode, 200);
    final code = jsonDecode(requested.body)['devCode'];

    final logged = await call(api, 'POST', '/v1/auth/phone/verify', {
      'phone': '13800138000',
      'code': code,
    });
    expect(logged.statusCode, 200);
    final token = jsonDecode(logged.body)['token'] as String;

    final created = await call(api, 'POST', '/v1/cats', {
      'id': 'cat-1',
      'name': '橘座',
      'deviceId': 'phone-a',
    }, token: token);
    expect(created.statusCode, 201);

    final listed = await call(api, 'GET', '/v1/cats', null, token: token);
    final items = jsonDecode(listed.body)['items'] as List;
    expect(items.single['payload']['name'], '橘座');

    final first = await call(api, 'POST', '/v1/weights', {
      'id': 'w-1',
      'weightKg': 4.4,
      'deviceId': 'phone-a',
      'updatedAt': '2026-10-12T02:00:00.000Z',
    }, token: token);
    expect(first.statusCode, 201);

    final older = await call(api, 'POST', '/v1/weights', {
      'id': 'w-1',
      'weightKg': 3.0,
      'deviceId': 'phone-b',
      'updatedAt': '2026-10-12T01:00:00.000Z',
    }, token: token);
    expect(older.statusCode, 409);

    final pulled = await call(
      api,
      'GET',
      '/v1/sync/pull?since=2026-10-12T00:00:00.000Z',
      null,
      token: token,
    );
    final changes = jsonDecode(pulled.body)['changes'] as List;
    final weight = changes.singleWhere((row) => row['entity'] == 'weights');
    expect(weight['payload']['weightKg'], 4.4);
  });

  test('sync push skips an older tombstone', () async {
    final token = await login(api);
    final pushed = await call(api, 'POST', '/v1/sync/push', {
      'deviceId': 'phone-a',
      'changes': [
        {
          'entity': 'vaccines',
          'id': 'v-1',
          'updatedAt': '2026-10-12T03:00:00.000Z',
          'deviceId': 'phone-a',
          'payload': {'name': '猫三联'},
        },
        {
          'entity': 'vaccines',
          'id': 'v-1',
          'updatedAt': '2026-10-12T02:00:00.000Z',
          'deviceId': 'phone-b',
          'deletedAt': '2026-10-12T02:00:00.000Z',
          'payload': {},
        },
      ],
    }, token: token);
    final body = jsonDecode(pushed.body);
    expect(body['accepted'], ['vaccines:v-1']);
    expect(body['skipped'], ['vaccines:v-1']);
    final pulled = await call(api, 'GET', '/v1/sync/pull', null, token: token);
    final changes = jsonDecode(pulled.body)['changes'] as List;
    final vaccine = changes.singleWhere((row) => row['id'] == 'v-1');
    expect(vaccine['deletedAt'], isNull);
    expect(vaccine['payload']['name'], '猫三联');
  });

  test('presign and vendor push stay behind the token', () async {
    final denied = await call(api, 'POST', '/v1/uploads/presign', {
      'filename': 'a.jpg',
    });
    expect(denied.statusCode, 401);
    final token = await login(api);
    final signed = await call(api, 'POST', '/v1/uploads/presign', {
      'filename': '橘座.jpg',
      'contentType': 'image/jpeg',
    }, token: token);
    final upload = jsonDecode(signed.body);
    expect(upload['provider'], 'oss-mock');
    expect(upload['method'], 'PUT');
    expect('${upload['uploadUrl']}', contains('signature=dev'));

    final push = await call(api, 'POST', '/v1/devices/push', {
      'vendor': 'huawei',
      'token': 'hw-1',
    }, token: token);
    expect(jsonDecode(push.body)['channel'], 'reserved');
    final unknown = await call(api, 'POST', '/v1/devices/push', {
      'vendor': 'sms',
      'token': 'x',
    }, token: token);
    expect(unknown.statusCode, 400);
  });

  test('a newer barcode correction replaces the older one', () async {
    final created = await call(
      api,
      'PUT',
      '/v1/shared-barcodes/6958862134620',
      {
        'brand': '麦富迪',
        'name': '三文鱼双拼',
        'spec': '2千克',
        'ingredients': '',
        'contributorId': 'dev-a',
        'createdAt': '2026-10-01T00:00:00.000Z',
        'updatedAt': '2026-10-01T00:00:00.000Z',
      },
    );
    expect(created.statusCode, 200);
    expect(jsonDecode(created.body)['applied'], isTrue);

    final older = await call(api, 'PUT', '/v1/shared-barcodes/6958862134620', {
      'brand': '错品牌',
      'name': '旧名字',
      'spec': '1千克',
      'contributorId': 'dev-b',
      'updatedAt': '2026-09-01T00:00:00.000Z',
    });
    expect(older.statusCode, 200);
    final kept = jsonDecode(older.body) as Map<String, Object?>;
    expect(kept['applied'], isFalse);
    expect(kept['brand'], '麦富迪');
    expect(kept['createdAt'], '2026-10-01T00:00:00.000Z');

    final newer = await call(api, 'PUT', '/v1/shared-barcodes/06958862134620', {
      'brand': '麦富迪',
      'name': '三文鱼双拼全价全期猫粮',
      'spec': '2千克',
      'ingredients': '三文鱼',
      'contributorId': 'dev-c',
      'createdAt': '2026-10-20T00:00:00.000Z',
      'updatedAt': '2026-10-15T00:00:00.000Z',
    });
    expect(newer.statusCode, 200);
    final fixed = jsonDecode(newer.body) as Map<String, Object?>;
    expect(fixed['applied'], isTrue);
    expect(fixed['name'], '三文鱼双拼全价全期猫粮');
    expect(fixed['createdAt'], '2026-10-01T00:00:00.000Z');
    expect(fixed['updatedAt'], '2026-10-15T00:00:00.000Z');
    expect(fixed.containsKey('cat'), isFalse);

    final tie = await call(api, 'PUT', '/v1/shared-barcodes/6958862134620', {
      'brand': '并列',
      'name': '字典序更小',
      'spec': '2千克',
      'contributorId': 'dev-a',
      'updatedAt': '2026-10-15T00:00:00.000Z',
    });
    expect(jsonDecode(tie.body)['applied'], isFalse);
    expect(jsonDecode(tie.body)['name'], '三文鱼双拼全价全期猫粮');
    expect(jsonDecode(tie.body)['ingredients'], '三文鱼');
    final laterId = await call(
      api,
      'PUT',
      '/v1/shared-barcodes/6958862134620',
      {
        'brand': '并列',
        'name': '字典序更大',
        'spec': '2千克',
        'contributorId': 'dev-d',
        'updatedAt': '2026-10-15T00:00:00.000Z',
      },
    );
    expect(jsonDecode(laterId.body)['applied'], isTrue);
    expect(jsonDecode(laterId.body)['contributorId'], 'dev-d');
    expect(jsonDecode(laterId.body)['createdAt'], '2026-10-01T00:00:00.000Z');

    final read = await call(
      api,
      'GET',
      '/v1/shared-barcodes/6958862134620',
      null,
    );
    expect(jsonDecode(read.body)['name'], '字典序更大');
    expect(jsonDecode(read.body)['ingredients'], '');

    final junk = await call(api, 'PUT', '/v1/shared-barcodes/abc', {
      'brand': '麦富迪',
      'name': '三文鱼',
      'spec': '2千克',
      'contributorId': 'dev-a',
      'updatedAt': '2026-10-15T00:00:00.000Z',
    });
    expect(junk.statusCode, 400);

    final locked = buildApi(
      MemoryStore(),
      jwtSecret: secret,
      shareKey: 'share-secret',
    );
    final denied = await call(
      locked,
      'GET',
      '/v1/shared-barcodes/6958862134620',
      null,
    );
    expect(denied.statusCode, 401);
    final allowed = await call(
      locked,
      'GET',
      '/v1/shared-barcodes/6958862134620',
      null,
      token: 'share-secret',
    );
    expect(allowed.statusCode, 404);
  });

  test('wechat stays a reserved endpoint until mock is on', () async {
    final closed = buildApi(MemoryStore(), jwtSecret: secret);
    final blocked = await call(closed, 'POST', '/v1/auth/wechat', {
      'code': 'abc',
    });
    expect(blocked.statusCode, 501);
    final opened = await call(api, 'POST', '/v1/auth/wechat', {'code': 'abc'});
    expect(opened.statusCode, 200);
  });
}

Future<String> login(Handler api) async {
  final requested = await call(api, 'POST', '/v1/auth/phone/request', {
    'phone': '13900139000',
  });
  final code = jsonDecode(requested.body)['devCode'];
  final logged = await call(api, 'POST', '/v1/auth/phone/verify', {
    'phone': '13900139000',
    'code': code,
  });
  return jsonDecode(logged.body)['token'] as String;
}

Future<({int statusCode, String body})> call(
  Handler api,
  String method,
  String path,
  Map<String, Object?>? body, {
  String? token,
}) async {
  final response = await api(
    Request(
      method,
      Uri.parse('http://localhost$path'),
      body: body == null ? null : jsonEncode(body),
      headers: {
        if (body != null) 'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      },
    ),
  );
  return (statusCode: response.statusCode, body: await response.readAsString());
}
