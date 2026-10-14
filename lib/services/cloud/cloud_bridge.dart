import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:zhuaji_sync/zhuaji_sync.dart';

import '../../core/config/app_config.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/drift_care_repository.dart';

/// Pushes the local outbox and pulls newer server rows.
///
/// Without `cloudToken` this does nothing. Network failures are logged and
/// the phone keeps the rows it already saved.
class CloudBridge {
  CloudBridge({required this.config, required this.repo, this.transport});

  final AppConfig config;
  final DriftCareRepository repo;
  final CloudTransport? transport;

  Future<void> syncQuietly() async {
    try {
      final token = await repo.setting('cloudToken');
      if (token == null || token.isEmpty) return;
      final client = transport ?? HttpCloudTransport(config.apiBaseUrl);
      await pushPending(client, token);
      await pullNewer(client, token);
    } catch (error, stack) {
      debugPrint('同步跳过：$error\n$stack');
    }
  }

  Future<void> pushPending(CloudTransport client, String token) async {
    final pending = await repo.pendingSync();
    if (pending.isEmpty) return;
    final deviceId = await repo.ensureDeviceId();
    final changes = [for (final row in pending) outboxRecord(row).toJson()];
    final response = await client.post('/v1/sync/push', {
      'deviceId': deviceId,
      'changes': changes,
    }, token: token);
    final accepted = response?['accepted'];
    if (accepted is! List) return;
    final acceptedKeys = accepted.map((item) => '$item').toSet();
    final done = [
      for (final row in pending)
        if (acceptedKeys.contains('${row.entity}:${row.recordKey}')) row.id,
    ];
    await repo.ackSync(done);
  }

  Future<void> pullNewer(CloudTransport client, String token) async {
    final since = await repo.setting('syncCursor') ?? '';
    final response = await client.get(
      since.isEmpty ? '/v1/sync/pull' : '/v1/sync/pull?since=$since',
      token: token,
    );
    final changes = response?['changes'];
    if (changes is! List) return;
    final pending = await repo.pendingSync();
    var cursor = since;
    for (final raw in changes) {
      if (raw is! Map) continue;
      final remote = SyncRecord.fromJson(Map<String, Object?>.from(raw));
      SyncOutboxRow? local;
      for (final row in pending) {
        if (row.entity == remote.entity && row.recordKey == remote.id) {
          local = row;
          break;
        }
      }
      if (local != null &&
          !incomingWins(
            incomingUpdatedAt: remote.updatedAt,
            incomingDeviceId: remote.deviceId,
            storedUpdatedAt: local.updatedAt,
            storedDeviceId: local.deviceId,
          )) {
        continue;
      }
      if (local != null) {
        await repo.ackSync([local.id]);
      }
      if (remote.updatedAt.toUtc().toIso8601String().compareTo(cursor) > 0) {
        cursor = remote.updatedAt.toUtc().toIso8601String();
      }
    }
    if (cursor != since) await repo.setSetting('syncCursor', cursor);
  }
}

SyncRecord outboxRecord(SyncOutboxRow row) {
  final payload = jsonDecode(row.payload);
  return SyncRecord(
    entity: row.entity,
    id: row.recordKey,
    updatedAt: row.updatedAt.toUtc(),
    deviceId: row.deviceId,
    deletedAt: row.op == 'delete' ? row.updatedAt.toUtc() : null,
    payload: payload is Map ? Map<String, Object?>.from(payload) : const {},
  );
}

abstract class CloudTransport {
  Future<Map<String, Object?>?> post(
    String path,
    Map<String, Object?> body, {
    String? token,
  });

  Future<Map<String, Object?>?> get(String path, {String? token});
}

class HttpCloudTransport implements CloudTransport {
  HttpCloudTransport(this.baseUrl, {HttpClient? client})
    : _client = client ?? HttpClient();

  final String baseUrl;
  final HttpClient _client;

  @override
  Future<Map<String, Object?>?> post(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) {
    return _send('POST', path, token: token, body: body);
  }

  @override
  Future<Map<String, Object?>?> get(String path, {String? token}) {
    return _send('GET', path, token: token);
  }

  Future<Map<String, Object?>?> _send(
    String method,
    String path, {
    String? token,
    Map<String, Object?>? body,
  }) async {
    final request = await _client
        .openUrl(method, Uri.parse('$baseUrl$path'))
        .timeout(const Duration(seconds: 4));
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close().timeout(const Duration(seconds: 4));
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 300 || text.isEmpty) return null;
    final decoded = jsonDecode(text);
    if (decoded is! Map) return null;
    return Map<String, Object?>.from(decoded);
  }
}
