import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:zhuaji_sync/zhuaji_sync.dart';

import 'jwt.dart';
import 'store.dart';

const entities = {'cats', 'weights', 'vaccines', 'deworms', 'visits', 'pantry'};

const pushVendors = {
  'xiaomi',
  'huawei',
  'honor',
  'oppo',
  'vivo',
  'apns',
  'fcm',
};

Handler buildApi(
  ApiStore store, {
  required String jwtSecret,
  bool devAuth = true,
  bool wechatMock = false,
}) {
  final router = Router();

  router.get('/healthz', (Request request) {
    return jsonOk({'ok': true});
  });

  router.post('/v1/auth/phone/request', (Request request) async {
    final body = await readJson(request);
    final phone = body['phone'];
    if (phone is! String || !RegExp(r'^1\d{10}$').hasMatch(phone)) {
      return jsonError(400, 'phone_invalid');
    }
    final code = devAuth
        ? phone.substring(phone.length - 4)
        : '${DateTime.now().millisecond % 1000000}'.padLeft(6, '0');
    await store.saveCode(phone, code);
    return jsonOk({'sent': true, if (devAuth) 'devCode': code});
  });

  router.post('/v1/auth/phone/verify', (Request request) async {
    final body = await readJson(request);
    final phone = body['phone'];
    final code = body['code'];
    if (phone is! String || code is! String) {
      return jsonError(400, 'phone_invalid');
    }
    final ok = await store.consumeCode(phone, code);
    if (!ok) return jsonError(401, 'code_rejected');
    final user = await store.userByPhone(phone);
    return jsonOk({
      'token': signJwt({'sub': user.id}, jwtSecret),
      'user': {'id': user.id, 'phone': user.phone},
    });
  });

  router.post('/v1/auth/wechat', (Request request) async {
    final body = await readJson(request);
    final code = body['code'];
    if (code is! String || code.isEmpty) return jsonError(400, 'code_required');
    if (!wechatMock) {
      return jsonError(
        501,
        'wechat_not_configured',
        message: '微信登录接口已留出，尚未接开放平台',
      );
    }
    final user = await store.userByWechat('mock-$code');
    return jsonOk({
      'token': signJwt({'sub': user.id}, jwtSecret),
      'user': {'id': user.id, 'wechatOpenId': user.wechatOpenId},
    });
  });

  for (final entity in entities) {
    router.get('/v1/$entity', (Request request) async {
      final userId = request.context['userId']! as String;
      final rows = await store.list(userId, entity);
      return jsonOk({
        'items': [for (final row in rows) row.toJson()],
      });
    });
    router.post('/v1/$entity', (Request request) async {
      final saved = await _upsert(store, request, entity);
      if (saved is Response) return saved;
      return jsonOk((saved as SyncRecord).toJson(), status: 201);
    });
  }

  router.post('/v1/sync/push', (Request request) async {
    final userId = request.context['userId']! as String;
    final body = await readJson(request);
    final deviceId = body['deviceId'];
    final changes = body['changes'];
    if (deviceId is! String || deviceId.isEmpty || changes is! List) {
      return jsonError(400, 'sync_invalid');
    }
    final accepted = <String>[];
    final skipped = <String>[];
    for (final raw in changes) {
      if (raw is! Map) continue;
      final record = _recordFrom(Map<String, Object?>.from(raw), deviceId);
      if (record == null || !entities.contains(record.entity)) {
        skipped.add('${raw['entity']}:${raw['id']}');
        continue;
      }
      final ok = await store.save(userId, record);
      (ok ? accepted : skipped).add('${record.entity}:${record.id}');
    }
    return jsonOk({'accepted': accepted, 'skipped': skipped});
  });

  router.get('/v1/sync/pull', (Request request) async {
    final userId = request.context['userId']! as String;
    final sinceRaw = request.url.queryParameters['since'];
    final since = sinceRaw == null || sinceRaw.isEmpty
        ? null
        : DateTime.tryParse(sinceRaw)?.toUtc();
    final rows = await store.changesSince(userId, since);
    return jsonOk({
      'changes': [for (final row in rows) row.toJson()],
    });
  });

  router.post('/v1/uploads/presign', (Request request) async {
    final userId = request.context['userId']! as String;
    final body = await readJson(request);
    final name = (body['filename'] as String?)?.trim();
    final contentType = (body['contentType'] as String?) ?? 'image/jpeg';
    final safe = (name == null || name.isEmpty) ? 'photo.jpg' : name;
    final key = 'cats/$userId/${DateTime.now().microsecondsSinceEpoch}-$safe';
    return jsonOk({
      'provider': 'oss-mock',
      'method': 'PUT',
      'uploadUrl': 'https://oss-mock.local/$key?signature=dev',
      'publicUrl': 'https://cdn.example.com/$key',
      'headers': {'Content-Type': contentType},
      'expiresIn': 600,
    });
  });

  router.post('/v1/devices/push', (Request request) async {
    final userId = request.context['userId']! as String;
    final body = await readJson(request);
    final vendor = body['vendor'];
    final token = body['token'];
    if (vendor is! String || !pushVendors.contains(vendor)) {
      return jsonError(400, 'vendor_unknown');
    }
    if (token is! String || token.isEmpty)
      return jsonError(400, 'token_required');
    await store.savePush(
      userId: userId,
      vendor: vendor,
      token: token,
      updatedAt: DateTime.now().toUtc(),
    );
    return jsonOk({'accepted': true, 'vendor': vendor, 'channel': 'reserved'});
  });

  final pipeline = Pipeline()
      .addMiddleware(_cors)
      .addMiddleware(
        (inner) =>
            (request) => _guard(inner, request, jwtSecret),
      )
      .addHandler(router.call);
  return pipeline;
}

Future<Object> _upsert(ApiStore store, Request request, String entity) async {
  final userId = request.context['userId']! as String;
  final body = await readJson(request);
  final deviceId = body['deviceId'];
  if (deviceId is! String || deviceId.isEmpty)
    return jsonError(400, 'device_required');
  final id = body['id'] is String && (body['id'] as String).isNotEmpty
      ? body['id'] as String
      : newId(entity);
  final updatedAt =
      DateTime.tryParse('${body['updatedAt'] ?? ''}')?.toUtc() ??
      DateTime.now().toUtc();
  final payload = Map<String, Object?>.from(body)..remove('deviceId');
  payload['id'] = id;
  final record = SyncRecord(
    entity: entity,
    id: id,
    updatedAt: updatedAt,
    deviceId: deviceId,
    payload: payload,
  );
  final ok = await store.save(userId, record);
  if (!ok) return jsonError(409, 'conflict_older');
  return record;
}

SyncRecord? _recordFrom(Map<String, Object?> raw, String fallbackDevice) {
  final entity = raw['entity'];
  final id = raw['id'];
  final updatedAt = DateTime.tryParse('${raw['updatedAt'] ?? ''}');
  if (entity is! String || id is! String || updatedAt == null) return null;
  final payload = raw['payload'];
  return SyncRecord(
    entity: entity,
    id: id,
    updatedAt: updatedAt.toUtc(),
    deviceId: raw['deviceId'] is String
        ? raw['deviceId']! as String
        : fallbackDevice,
    deletedAt: raw['deletedAt'] == null
        ? null
        : DateTime.tryParse('${raw['deletedAt']}')?.toUtc(),
    payload: payload is Map ? Map<String, Object?>.from(payload) : const {},
  );
}

Future<Response> _guard(Handler inner, Request request, String secret) async {
  final path = request.url.path;
  if (path == 'healthz' || path.startsWith('v1/auth/')) {
    return inner(request);
  }
  final header = request.headers['authorization'] ?? '';
  if (!header.startsWith('Bearer ')) return jsonError(401, 'unauthorized');
  final claims = verifyJwt(header.substring(7), secret);
  final userId = claims?['sub'];
  if (userId is! String || userId.isEmpty)
    return jsonError(401, 'unauthorized');
  return inner(request.change(context: {'userId': userId}));
}

Middleware get _cors => (inner) {
  return (request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: _corsHeaders);
    }
    final response = await inner(request);
    return response.change(headers: _corsHeaders);
  };
};

const _corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'authorization, content-type, x-device-id',
  'access-control-allow-methods': 'GET, POST, OPTIONS',
};

Future<Map<String, Object?>> readJson(Request request) async {
  final text = await request.readAsString();
  if (text.isEmpty) return const {};
  final decoded = jsonDecode(text);
  if (decoded is! Map) return const {};
  return Map<String, Object?>.from(decoded);
}

Response jsonOk(Object body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Response jsonError(int status, String code, {String? message}) {
  return jsonOk({
    'error': code,
    if (message != null) 'message': message,
  }, status: status);
}
