import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/features/pantry/scan_page.dart';
import 'package:maokangji/services/barcode_share.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  test(
    'an empty code stays on the phone and does not ask the network',
    () async {
      final calls = <String>[];
      final looked = await lookupBarcode(
        '   ',
        fetch: (call) async {
          calls.add(call.uri.toString());
          return const BarcodeResponse(200, '{}');
        },
      );
      expect(looked.found, isFalse);
      expect(looked.offline, isFalse);
      expect(calls, isEmpty);

      final database = AppDatabase.memory();
      final controller = _controller(database);
      expect(await scanDestination(controller, ''), '/confirm');
      expect(await scanDestination(controller, '  '), '/confirm');
      await controller.init();
      controller.barcodeFetch = (_) async {
        fail('an empty code must not ask the public chain');
      };
      controller.shareClient = _HangShare();
      final record = await controller.resolveBarcode('   ');
      expect(record.found, isFalse);
      expect(record.offline, isFalse);
      await database.close();
    },
  );

  test('a public timeout is a miss the page can recover from', () async {
    final record = await lookupBarcode(
      '6970000000000',
      fetch: (_) async {
        throw TimeoutException('slow');
      },
    );
    expect(record.found, isFalse);
    expect(record.offline, isTrue);
  });

  test('a hung share server falls through to the built-in list', () async {
    final database = AppDatabase.memory();
    final controller = _controller(database);
    await controller.init();
    controller.shareLookupTimeout = const Duration(milliseconds: 30);
    controller.shareClient = _HangShare();
    controller.barcodeFetch = (_) async {
      fail('built-in hit must not ask the public chain');
    };
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.source, 'local');
    expect(record.brand, '麦富迪');
    await database.close();
  });

  test('no share URL keeps the correction on this phone', () async {
    final database = AppDatabase.memory();
    final controller = _controller(database);
    await controller.init();
    controller.share = const BarcodeShare();
    await controller.saveFood(
      const FoodDraft(
        brand: '自记',
        name: '原来的名字',
        spec: '2千克',
        foodForm: FoodForm.dry,
        storageMethod: '阴凉干燥，封好袋口。',
        afterOpenDays: 30,
      ),
      barcode: '6958862134620',
    );
    var asked = 0;
    await controller.rememberUserBarcode(
      code: '6958862134620',
      brand: '自记',
      name: '只在手机',
      spec: '2千克',
      ask: () async {
        asked += 1;
        return true;
      },
    );
    expect(asked, 0);
    expect(controller.shareEnabled, isFalse);
    controller.barcodeFetch = (_) async {
      fail('a saved correction must not ask the public chain');
    };
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.source, 'user');
    expect(record.name, '只在手机');
    await database.close();
  });

  test('a broken catalog still opens and a library code still hits', () async {
    final database = AppDatabase.memory();
    final repo = DriftCareRepository(database);
    await repo.setSetting('barcodeCatalog', '{');
    await repo.setSetting(
      'barcodeRevisions',
      jsonEncode({
        '6958862134620': {'updatedAt': 'not-a-date', 'name': 12},
      }),
    );
    final controller = AppController(
      repo: repo,
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await controller.init();
    expect(controller.barcodeCatalog, isEmpty);
    controller.barcodeFetch = (_) async {
      fail('a local hit must not ask the public chain');
    };
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.source, 'local');
    expect(record.brand, '麦富迪');
    await database.close();
  });

  test('one bad catalog row does not drop the rows beside it', () async {
    final database = AppDatabase.memory();
    final repo = DriftCareRepository(database);
    await repo.setSetting(
      'barcodeCatalog',
      jsonEncode({
        '3182550799669': {
          'code': '3182550799669',
          'found': true,
          'brand': 'Royal Canin',
          'name': 'Neutered Satiety Balance',
          'quantity': '12 kg',
          'source': 'openpetfoodfacts',
        },
        'bad': 'not-a-record',
      }),
    );
    final controller = AppController(
      repo: repo,
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await controller.init();
    expect(
      controller.cachedBarcode('3182550799669')?.name,
      'Neutered Satiety Balance',
    );
    await database.close();
  });

  test(
    'a share miss does not let an old cache hide the built-in row',
    () async {
      final database = AppDatabase.memory();
      final controller = _controller(database);
      await controller.init();
      await controller.saveBarcodeRecord(
        const BarcodeRecord(
          code: '6958862134620',
          found: true,
          brand: '旧缓存',
          name: '不该再挡住内置表',
          quantity: '1千克',
          ingredients: '',
          nutrients: [],
          source: 'share',
        ),
      );
      controller.shareClient = _MissShare();
      controller.barcodeFetch = (_) async {
        fail('built-in hit must not ask the public chain');
      };
      final record = await controller.resolveBarcode('6958862134620');
      expect(record.source, 'local');
      expect(record.brand, '麦富迪');
      expect(controller.cachedBarcode('6958862134620'), isNull);
      await database.close();
    },
  );

  test('camera permission denial keeps a written way forward', () {
    expect(
      scanCameraMessage(MobileScannerErrorCode.permissionDenied),
      contains('没有相机权限'),
    );
    expect(
      scanCameraMessage(MobileScannerErrorCode.unsupported),
      contains('选品牌'),
    );
    expect(scanCameraMessage(null), '相机没打开。可以手输条码，或选品牌。');
  });
}

AppController _controller(AppDatabase database) {
  return AppController(
    repo: DriftCareRepository(database),
    notifications: NoopNotificationService(),
    recognizer: const MockCoatBreedRecognizer(),
  );
}

class _HangShare implements BarcodeShareClient {
  @override
  Future<ShareConfig> config() async => ShareConfig.speaking;

  @override
  Future<ShareAnswer> lookup(String code) => Completer<ShareAnswer>().future;

  @override
  Future<ShareAnswer> submit(BarcodeRecord record) async {
    return const ShareAnswer(ShareStatus.miss);
  }
}

class _MissShare implements BarcodeShareClient {
  @override
  Future<ShareConfig> config() async => ShareConfig.speaking;

  @override
  Future<ShareAnswer> lookup(String code) async {
    return const ShareAnswer(ShareStatus.miss);
  }

  @override
  Future<ShareAnswer> submit(BarcodeRecord record) async {
    return const ShareAnswer(ShareStatus.miss);
  }
}
