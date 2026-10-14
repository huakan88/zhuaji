import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:maokangji/core/config/app_config.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/domain/reminders/reminder_planner.dart';
import 'package:maokangji/services/cloud/cloud_bridge.dart';
import 'package:maokangji/services/photo_store.dart';
import 'package:zhuaji_sync/zhuaji_sync.dart';

void main() {
  test('schema upgrades are ordered and idempotent in the plan', () {
    expect(upgradesFrom(1, 5), [2, 3, 4, 5]);
    expect(upgradesFrom(3, 5), [4, 5]);
    expect(upgradesFrom(4, 5), [5]);
    expect(upgradesFrom(5, 5), isEmpty);
  });

  test('a saved vaccine is queued for sync and can be pushed', () async {
    final db = AppDatabase.memory();
    final repo = DriftCareRepository(db);
    addTearDown(repo.close);
    final catId = await repo.upsertCat(
      const CatDraft(
        name: '橘座',
        sex: CatSex.male,
        neutered: true,
        goal: CareGoal.maintain,
      ),
    );
    await repo.upsertVaccine(
      VaccineDraft(
        catId: catId,
        name: '猫三联',
        givenOn: DateTime.utc(2026, 10, 12),
      ),
    );
    final pending = await repo.pendingSync();
    expect(pending.last.entity, 'vaccines');
    expect(jsonDecode(pending.last.payload)['name'], '猫三联');

    final transport = _FakeTransport({
      'accepted': ['vaccines:${pending.last.recordKey}'],
      'changes': [
        {
          'entity': 'vaccines',
          'id': pending.last.recordKey,
          'updatedAt': '2026-10-12T01:00:00.000Z',
          'deviceId': 'server',
          'payload': {'name': '旧记录'},
        },
      ],
    });
    final bridge = CloudBridge(
      config: const AppConfig(baseUrlOverride: 'http://127.0.0.1:8094'),
      repo: repo,
      transport: transport,
    );
    await repo.setSetting('cloudToken', 'token');
    await bridge.syncQuietly();
    final left = await repo.pendingSync();
    expect(left.where((row) => row.entity == 'vaccines'), isEmpty);
    expect(await repo.setting('syncCursor'), '2026-10-12T01:00:00.000Z');
  });

  test(
    'an older remote change does not drop a newer local outbox row',
    () async {
      final local = SyncRecord(
        entity: 'weights',
        id: '9',
        updatedAt: DateTime.utc(2026, 10, 12, 4),
        deviceId: 'phone',
        payload: const {'weightKg': 4.4},
      );
      final remote = SyncRecord(
        entity: 'weights',
        id: '9',
        updatedAt: DateTime.utc(2026, 10, 12, 3),
        deviceId: 'other',
        payload: const {'weightKg': 3.1},
      );
      expect(
        incomingWins(
          incomingUpdatedAt: remote.updatedAt,
          incomingDeviceId: remote.deviceId,
          storedUpdatedAt: local.updatedAt,
          storedDeviceId: local.deviceId,
        ),
        isFalse,
      );
    },
  );

  test('stored photos shrink the long edge', () {
    final source = img.Image(width: 2000, height: 1000);
    img.fill(source, color: img.ColorRgb8(180, 120, 90));
    final bytes = img.encodeJpg(source, quality: 90);
    final stored = compressStoredPhoto(bytes);
    final decoded = img.decodeJpg(stored)!;
    expect(decoded.width, 1280);
    expect(decoded.height, 640);
    expect(stored.length, lessThan(bytes.length));
  });

  test('past one-shot reminders are not scheduled', () {
    final now = DateTime(2026, 10, 12, 10);
    final items = [
      PlannedNotification(
        id: 1,
        when: now.subtract(const Duration(hours: 1)),
        title: '过了',
        body: '',
        channel: ReminderChannel.health,
      ),
      PlannedNotification(
        id: 2,
        when: now.add(const Duration(hours: 1)),
        title: '还没到',
        body: '',
        channel: ReminderChannel.food,
      ),
      PlannedNotification(
        id: 3,
        when: now.subtract(const Duration(days: 1)),
        title: '每天',
        body: '',
        channel: ReminderChannel.health,
        repeatsDaily: true,
      ),
    ];
    final kept = schedulable(items, now, limit: 60);
    expect(kept.map((item) => item.id), [3, 2]);
  });

  test('api base url follows the environment override', () {
    expect(const AppConfig().apiBaseUrl, 'http://10.0.2.2:8094');
    expect(
      const AppConfig(env: AppEnv.prod).apiBaseUrl,
      'https://api.zhuaji.local',
    );
    expect(
      const AppConfig(baseUrlOverride: 'http://127.0.0.1:8094/').apiBaseUrl,
      'http://127.0.0.1:8094',
    );
    expect(parseAppEnv('staging'), AppEnv.staging);
  });
}

class _FakeTransport implements CloudTransport {
  _FakeTransport(this.body);

  final Map<String, Object?> body;

  @override
  Future<Map<String, Object?>?> get(String path, {String? token}) async {
    return body;
  }

  @override
  Future<Map<String, Object?>?> post(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) async {
    return this.body;
  }
}
