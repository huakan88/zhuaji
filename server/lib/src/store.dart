import 'dart:convert';
import 'dart:math';

import 'package:postgres/postgres.dart';
import 'package:zhuaji_sync/zhuaji_sync.dart';

class ApiUser {
  const ApiUser({required this.id, this.phone, this.wechatOpenId});

  final String id;
  final String? phone;
  final String? wechatOpenId;
}

abstract class ApiStore {
  Future<void> saveCode(String phone, String code);
  Future<bool> consumeCode(String phone, String code);
  Future<ApiUser> userByPhone(String phone);
  Future<ApiUser> userByWechat(String openId);
  Future<List<SyncRecord>> list(String userId, String entity);
  Future<bool> save(String userId, SyncRecord incoming);
  Future<List<SyncRecord>> changesSince(String userId, DateTime? since);
  Future<void> savePush({
    required String userId,
    required String vendor,
    required String token,
    required DateTime updatedAt,
  });
}

String newId(String prefix) {
  final clock = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final salt = Random().nextInt(1 << 32).toRadixString(16);
  return '$prefix-$clock$salt';
}

class MemoryStore implements ApiStore {
  final _codes = <String, String>{};
  final _users = <String, ApiUser>{};
  final _records = <String, SyncRecord>{};
  final _pushes = <String, String>{};

  Map<String, String> get pushes => _pushes;

  @override
  Future<void> saveCode(String phone, String code) async {
    _codes[phone] = code;
  }

  @override
  Future<bool> consumeCode(String phone, String code) async {
    if (_codes[phone] != code) return false;
    _codes.remove(phone);
    return true;
  }

  @override
  Future<ApiUser> userByPhone(String phone) async {
    for (final user in _users.values) {
      if (user.phone == phone) return user;
    }
    final user = ApiUser(id: newId('usr'), phone: phone);
    _users[user.id] = user;
    return user;
  }

  @override
  Future<ApiUser> userByWechat(String openId) async {
    for (final user in _users.values) {
      if (user.wechatOpenId == openId) return user;
    }
    final user = ApiUser(id: newId('usr'), wechatOpenId: openId);
    _users[user.id] = user;
    return user;
  }

  String _key(String userId, String entity, String id) => '$userId|$entity|$id';

  @override
  Future<List<SyncRecord>> list(String userId, String entity) async {
    return [
      for (final entry in _records.entries)
        if (entry.key.startsWith('$userId|$entity|') && !entry.value.isDeleted)
          entry.value,
    ];
  }

  @override
  Future<bool> save(String userId, SyncRecord incoming) async {
    final key = _key(userId, incoming.entity, incoming.id);
    if (keepRecord(_records[key], incoming) != incoming) return false;
    _records[key] = incoming;
    return true;
  }

  @override
  Future<List<SyncRecord>> changesSince(String userId, DateTime? since) async {
    final rows = [
      for (final entry in _records.entries)
        if (entry.key.startsWith('$userId|')) entry.value,
    ];
    if (since == null) return rows;
    return [
      for (final row in rows)
        if (row.updatedAt.toUtc().isAfter(since.toUtc())) row,
    ];
  }

  @override
  Future<void> savePush({
    required String userId,
    required String vendor,
    required String token,
    required DateTime updatedAt,
  }) async {
    _pushes['$userId|$vendor|$token'] = updatedAt.toUtc().toIso8601String();
  }
}

class PostgresStore implements ApiStore {
  PostgresStore(this._db);

  final Connection _db;

  static Future<PostgresStore> open(String databaseUrl) async {
    final uri = Uri.parse(databaseUrl);
    final conn = await Connection.open(
      Endpoint(
        host: uri.host,
        port: uri.hasPort ? uri.port : 5432,
        database: uri.pathSegments.isEmpty ? 'zhuaji' : uri.pathSegments.first,
        username: uri.userInfo.split(':').first,
        password: uri.userInfo.contains(':')
            ? Uri.decodeComponent(uri.userInfo.split(':').sublist(1).join(':'))
            : null,
      ),
    );
    final store = PostgresStore(conn);
    await store._migrate();
    return store;
  }

  Future<void> _migrate() async {
    const statements = [
      '''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        phone TEXT UNIQUE,
        wechat_open_id TEXT UNIQUE,
        created_at TIMESTAMPTZ NOT NULL
      )
      ''',
      '''
      CREATE TABLE IF NOT EXISTS phone_codes (
        phone TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL
      )
      ''',
      '''
      CREATE TABLE IF NOT EXISTS records (
        user_id TEXT NOT NULL REFERENCES users(id),
        entity TEXT NOT NULL,
        record_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL,
        deleted_at TIMESTAMPTZ,
        device_id TEXT NOT NULL,
        PRIMARY KEY (user_id, entity, record_id)
      )
      ''',
      '''
      CREATE TABLE IF NOT EXISTS push_tokens (
        user_id TEXT NOT NULL REFERENCES users(id),
        vendor TEXT NOT NULL,
        token TEXT NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL,
        PRIMARY KEY (user_id, vendor, token)
      )
      ''',
    ];
    for (final sql in statements) {
      await _db.execute(sql);
    }
  }

  @override
  Future<void> saveCode(String phone, String code) async {
    await _db.execute(
      Sql.named(
        'INSERT INTO phone_codes (phone, code, created_at) VALUES (@phone, @code, @created_at) '
        'ON CONFLICT (phone) DO UPDATE SET code = EXCLUDED.code, created_at = EXCLUDED.created_at',
      ),
      parameters: {
        'phone': phone,
        'code': code,
        'created_at': DateTime.now().toUtc(),
      },
    );
  }

  @override
  Future<bool> consumeCode(String phone, String code) async {
    final result = await _db.execute(
      Sql.named(
        'DELETE FROM phone_codes WHERE phone = @phone AND code = @code RETURNING phone',
      ),
      parameters: {'phone': phone, 'code': code},
    );
    return result.isNotEmpty;
  }

  @override
  Future<ApiUser> userByPhone(String phone) async {
    final found = await _db.execute(
      Sql.named(
        'SELECT id, phone, wechat_open_id FROM users WHERE phone = @phone',
      ),
      parameters: {'phone': phone},
    );
    if (found.isNotEmpty) return _user(found.first.toColumnMap());
    final user = ApiUser(id: newId('usr'), phone: phone);
    await _insertUser(user);
    return user;
  }

  @override
  Future<ApiUser> userByWechat(String openId) async {
    final found = await _db.execute(
      Sql.named(
        'SELECT id, phone, wechat_open_id FROM users WHERE wechat_open_id = @open_id',
      ),
      parameters: {'open_id': openId},
    );
    if (found.isNotEmpty) return _user(found.first.toColumnMap());
    final user = ApiUser(id: newId('usr'), wechatOpenId: openId);
    await _insertUser(user);
    return user;
  }

  Future<void> _insertUser(ApiUser user) {
    return _db.execute(
      Sql.named(
        'INSERT INTO users (id, phone, wechat_open_id, created_at) '
        'VALUES (@id, @phone, @wechat, @created_at)',
      ),
      parameters: {
        'id': user.id,
        'phone': user.phone,
        'wechat': user.wechatOpenId,
        'created_at': DateTime.now().toUtc(),
      },
    );
  }

  ApiUser _user(Map<String, dynamic> row) {
    return ApiUser(
      id: row['id'] as String,
      phone: row['phone'] as String?,
      wechatOpenId: row['wechat_open_id'] as String?,
    );
  }

  SyncRecord _record(Map<String, dynamic> row) {
    final payload = jsonDecode(row['payload'] as String);
    return SyncRecord(
      entity: row['entity'] as String,
      id: row['record_id'] as String,
      updatedAt: (row['updated_at'] as DateTime).toUtc(),
      deviceId: row['device_id'] as String,
      deletedAt: (row['deleted_at'] as DateTime?)?.toUtc(),
      payload: Map<String, Object?>.from(payload as Map),
    );
  }

  @override
  Future<List<SyncRecord>> list(String userId, String entity) async {
    final result = await _db.execute(
      Sql.named(
        'SELECT entity, record_id, payload, updated_at, deleted_at, device_id '
        'FROM records WHERE user_id = @user_id AND entity = @entity AND deleted_at IS NULL',
      ),
      parameters: {'user_id': userId, 'entity': entity},
    );
    return [for (final row in result) _record(row.toColumnMap())];
  }

  @override
  Future<bool> save(String userId, SyncRecord incoming) async {
    final existing = await _db.execute(
      Sql.named(
        'SELECT entity, record_id, payload, updated_at, deleted_at, device_id '
        'FROM records WHERE user_id = @user_id AND entity = @entity AND record_id = @id',
      ),
      parameters: {
        'user_id': userId,
        'entity': incoming.entity,
        'id': incoming.id,
      },
    );
    if (existing.isNotEmpty) {
      final stored = _record(existing.first.toColumnMap());
      if (keepRecord(stored, incoming) != incoming) return false;
    }
    await _db.execute(
      Sql.named(
        'INSERT INTO records (user_id, entity, record_id, payload, updated_at, deleted_at, device_id) '
        'VALUES (@user_id, @entity, @id, @payload, @updated_at, @deleted_at, @device_id) '
        'ON CONFLICT (user_id, entity, record_id) DO UPDATE SET '
        'payload = EXCLUDED.payload, updated_at = EXCLUDED.updated_at, '
        'deleted_at = EXCLUDED.deleted_at, device_id = EXCLUDED.device_id',
      ),
      parameters: {
        'user_id': userId,
        'entity': incoming.entity,
        'id': incoming.id,
        'payload': jsonEncode(incoming.payload),
        'updated_at': incoming.updatedAt.toUtc(),
        'deleted_at': incoming.deletedAt?.toUtc(),
        'device_id': incoming.deviceId,
      },
    );
    return true;
  }

  @override
  Future<List<SyncRecord>> changesSince(String userId, DateTime? since) async {
    final result = since == null
        ? await _db.execute(
            Sql.named(
              'SELECT entity, record_id, payload, updated_at, deleted_at, device_id '
              'FROM records WHERE user_id = @user_id',
            ),
            parameters: {'user_id': userId},
          )
        : await _db.execute(
            Sql.named(
              'SELECT entity, record_id, payload, updated_at, deleted_at, device_id '
              'FROM records WHERE user_id = @user_id AND updated_at > @since',
            ),
            parameters: {'user_id': userId, 'since': since.toUtc()},
          );
    return [for (final row in result) _record(row.toColumnMap())];
  }

  @override
  Future<void> savePush({
    required String userId,
    required String vendor,
    required String token,
    required DateTime updatedAt,
  }) {
    return _db.execute(
      Sql.named(
        'INSERT INTO push_tokens (user_id, vendor, token, updated_at) '
        'VALUES (@user_id, @vendor, @token, @updated_at) '
        'ON CONFLICT (user_id, vendor, token) DO UPDATE SET updated_at = EXCLUDED.updated_at',
      ),
      parameters: {
        'user_id': userId,
        'vendor': vendor,
        'token': token,
        'updated_at': updatedAt.toUtc(),
      },
    );
  }
}
