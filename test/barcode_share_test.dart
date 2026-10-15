import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/services/barcode_share.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

void main() {
  test(
    'a shared row beats the built-in list and hides the public chain',
    () async {
      final database = AppDatabase.memory();
      final controller = _controller(database);
      await controller.init();
      final share = _MemoryShare();
      controller.shareClient = share;
      share.rows['6958862134620'] = _share(
        '6958862134620',
        name: '共享里的双拼粮',
        updatedAt: DateTime.utc(2026, 10, 15),
      );
      controller.barcodeFetch = (_) async {
        fail('a shared hit must not ask the public chain');
      };
      final record = await controller.resolveBarcode('6958862134620');
      expect(record.source, 'share');
      expect(record.brand, '麦富迪');
      expect(record.name, '共享里的双拼粮');
      expect(record.updatedAt, DateTime.utc(2026, 10, 15));
      await database.close();
    },
  );

  test('a food saved on this phone beats a newer shared row', () async {
    final database = AppDatabase.memory();
    final controller = _controller(database);
    await controller.init();
    await controller.saveFood(
      const FoodDraft(
        brand: '自记',
        name: '我改过的名字',
        spec: '500克',
        foodForm: FoodForm.dry,
        storageMethod: '阴凉干燥，封好袋口。',
        afterOpenDays: 30,
      ),
      barcode: '6958862134620',
    );
    final share = _MemoryShare();
    controller.shareClient = share;
    share.rows['6958862134620'] = _share(
      '6958862134620',
      name: '别人更新的名字',
      updatedAt: DateTime.utc(2026, 12, 1),
    );
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.source, 'user');
    expect(record.name, '我改过的名字');
    await database.close();
  });

  test('a share outage falls back to the built-in list', () async {
    final database = AppDatabase.memory();
    final controller = _controller(database);
    await controller.init();
    controller.shareClient = _MemoryShare()..fail = true;
    controller.barcodeFetch = (_) async {
      fail('built-in hit must not ask the public chain');
    };
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.source, 'local');
    expect(record.brand, '麦富迪');
    await database.close();
  });

  test('the first answer is stored, and a decline does not upload', () async {
    final database = AppDatabase.memory();
    var now = DateTime.utc(2026, 10, 15, 8);
    final controller = _controller(database, clock: () => now);
    await controller.init();
    final share = _MemoryShare();
    controller.share = const BarcodeShare(baseUrl: 'https://share.example');
    controller.shareClient = share;
    var asked = 0;
    await controller.rememberUserBarcode(
      code: '6958862134620',
      brand: '自记',
      name: '第一次',
      spec: '2千克',
      ask: () async {
        asked += 1;
        return false;
      },
    );
    expect(asked, 1);
    expect(share.submitted, 0);
    final shown = await controller.resolveBarcode('064992280178');
    expect(shown.source, 'local');
    now = DateTime.utc(2026, 10, 16, 8);
    await controller.rememberUserBarcode(
      code: '6958862134620',
      brand: '自记',
      name: '第二次',
      spec: '2千克',
      ask: () async {
        asked += 1;
        return true;
      },
    );
    expect(asked, 1);
    expect(share.submitted, 0);
    await database.close();
  });

  test(
    'an accepted correction uploads and a later one keeps createdAt',
    () async {
      final database = AppDatabase.memory();
      var now = DateTime.utc(2026, 10, 1, 8);
      final controller = _controller(database, clock: () => now);
      await controller.init();
      final share = _MemoryShare();
      controller.share = const BarcodeShare(baseUrl: 'https://share.example');
      controller.shareClient = share;
      await controller.saveFood(
        const FoodDraft(
          brand: '自记',
          name: '第一次',
          spec: '2千克',
          foodForm: FoodForm.dry,
          storageMethod: '阴凉干燥，封好袋口。',
          afterOpenDays: 30,
        ),
        barcode: '6901234500004',
      );
      await controller.rememberUserBarcode(
        code: '6901234500004',
        brand: '自记',
        name: '第一次',
        spec: '2千克',
        ingredients: '鸡',
        imageUrl: '/data/pack.jpg',
        ask: () async => true,
      );
      expect(share.submitted, 1);
      expect(share.rows['6901234500004']?.imageUrl, isNull);
      expect(share.rows['6901234500004']?.contributorId, startsWith('dev-'));
      now = DateTime.utc(2026, 10, 15, 8);
      await controller.rememberUserBarcode(
        code: '6901234500004',
        brand: '自记',
        name: '修正后',
        spec: '1.5千克',
        ask: () async => false,
      );
      final row = share.rows['6901234500004']!;
      expect(row.name, '修正后');
      expect(row.createdAt, DateTime.utc(2026, 10, 1, 8));
      expect(row.updatedAt, DateTime.utc(2026, 10, 15, 8));
      final shown = await controller.resolveBarcode('6901234500004');
      expect(shown.source, 'user');
      expect(shown.name, '修正后');
      expect(shown.updatedAt, DateTime.utc(2026, 10, 15, 8));
      expect(shown.ingredients, '鸡');
      await database.close();
    },
  );

  test('a failed submit stays queued until the server is ready', () async {
    final database = AppDatabase.memory();
    var now = DateTime.utc(2026, 10, 15, 8);
    final controller = _controller(database, clock: () => now);
    await controller.init();
    final share = _FlakyShare();
    controller.share = const BarcodeShare(baseUrl: 'https://share.example');
    controller.shareClient = share;
    await controller.rememberUserBarcode(
      code: '6901234500004',
      brand: '自记',
      name: '离线',
      spec: '2千克',
      ask: () async => true,
    );
    expect(share.submitted, 1);
    expect(controller.shareQueue, hasLength(1));
    final stored = await controller.repo.setting('barcodeShareQueue');
    expect(stored, contains('6901234500004'));
    expect(stored, contains('自记'));
    expect(stored, isNot(contains('橘座')));
    expect(await controller.flushBarcodeShare(), 0);
    expect(share.submitted, 1);

    now = now.add(const Duration(seconds: 31));
    share.fail = false;
    expect(await controller.flushBarcodeShare(), 1);
    expect(controller.shareQueue, isEmpty);
    expect(share.rows['6901234500004']?.name, '离线');
    expect(share.rows['6901234500004']?.contributorId, startsWith('dev-'));
    await database.close();
  });

  test(
    'a config that is not ready keeps the queue and does not submit',
    () async {
      final database = AppDatabase.memory();
      final controller = _controller(database);
      await controller.init();
      final share = _FlakyShare()..ready = false;
      controller.share = const BarcodeShare(baseUrl: 'https://share.example');
      controller.shareClient = share;
      await controller.rememberUserBarcode(
        code: '6958862134620',
        brand: '麦富迪',
        name: '还没发出去',
        spec: '2千克',
        ask: () async => true,
      );
      expect(share.submitted, 0);
      expect(controller.shareQueue, hasLength(1));
      expect(await controller.flushBarcodeShare(), 0);
      expect(share.submitted, 0);

      share.ready = true;
      share.fail = false;
      final due = controller.shareQueue.single.nextAttemptAt!;
      controller.shareQueue = [
        SharePending(
          code: controller.shareQueue.single.code,
          brand: controller.shareQueue.single.brand,
          name: controller.shareQueue.single.name,
          spec: controller.shareQueue.single.spec,
          ingredients: controller.shareQueue.single.ingredients,
          contributorId: controller.shareQueue.single.contributorId,
          createdAt: controller.shareQueue.single.createdAt,
          updatedAt: controller.shareQueue.single.updatedAt,
          nextAttemptAt: due.subtract(const Duration(minutes: 1)),
        ),
      ];
      expect(await controller.flushBarcodeShare(), 1);
      expect(share.rows['6958862134620']?.name, '还没发出去');
      await database.close();
    },
  );

  test('the config payload is the shared-barcode contract', () {
    final parsed = ShareConfig.fromJson({
      'contract': 'shared-barcodes',
      'version': 1,
      'enabled': true,
    });
    expect(parsed.ready, isTrue);
    expect(
      ShareConfig.fromJson({'contract': 'other', 'version': 1, 'enabled': true})
          .ready,
      isFalse,
    );
    expect(ShareConfig.offline.ready, isFalse);
  });
}

AppController _controller(AppDatabase database, {DateTime Function()? clock}) {
  return AppController(
    repo: DriftCareRepository(database),
    notifications: NoopNotificationService(),
    recognizer: const MockCoatBreedRecognizer(),
    clock: clock,
  );
}

BarcodeRecord _share(
  String code, {
  required String name,
  required DateTime updatedAt,
}) {
  return BarcodeRecord(
    code: code,
    found: true,
    brand: '麦富迪',
    name: name,
    quantity: '2千克',
    ingredients: '',
    nutrients: const [],
    source: 'share',
    updatedAt: updatedAt,
    createdAt: DateTime.utc(2026, 10, 1),
    contributorId: 'dev-remote',
  );
}

class _MemoryShare implements BarcodeShareClient {
  final rows = <String, BarcodeRecord>{};

  @override
  Future<ShareConfig> config() async => ShareConfig.speaking;
  var submitted = 0;
  var fail = false;

  @override
  Future<ShareAnswer> lookup(String code) async {
    if (fail) return const ShareAnswer(ShareStatus.failed);
    final row = rows[code];
    if (row == null) return const ShareAnswer(ShareStatus.miss);
    return ShareAnswer(ShareStatus.hit, row);
  }

  @override
  Future<ShareAnswer> submit(BarcodeRecord record) async {
    submitted += 1;
    final previous = rows[record.code];
    final created = previous?.createdAt ?? record.createdAt;
    final next = BarcodeRecord(
      code: record.code,
      found: true,
      brand: record.brand,
      name: record.name,
      quantity: record.quantity,
      ingredients: record.ingredients,
      nutrients: const [],
      source: 'share',
      imageUrl: record.imageUrl,
      createdAt: created,
      updatedAt: record.updatedAt,
      contributorId: record.contributorId,
    );
    rows[record.code] = next;
    return ShareAnswer(ShareStatus.hit, next);
  }
}

class _FlakyShare implements BarcodeShareClient {
  var fail = true;
  var ready = true;
  var submitted = 0;
  final rows = <String, BarcodeRecord>{};

  @override
  Future<ShareConfig> config() async {
    return ready ? ShareConfig.speaking : ShareConfig.offline;
  }

  @override
  Future<ShareAnswer> lookup(String code) async {
    return const ShareAnswer(ShareStatus.miss);
  }

  @override
  Future<ShareAnswer> submit(BarcodeRecord record) async {
    submitted += 1;
    if (fail) return const ShareAnswer(ShareStatus.failed);
    rows[record.code] = record;
    return ShareAnswer(ShareStatus.hit, record);
  }
}
