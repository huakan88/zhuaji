import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/features/pantry/scan_page.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';

void main() {
  test('EAN-13, EAN-8 and UPC-A check digits', () {
    expect(hasGtinChecksum('6958862134620'), isTrue);
    expect(hasGtinChecksum('96385074'), isTrue);
    expect(hasGtinChecksum('036000291452'), isTrue);
    expect(hasGtinChecksum('6901234500004'), isTrue);
    expect(gtinCheckDigit('6958862134620'), 0);
    expect(isRetailBarcode('6958862134621'), isFalse);
    expect(isRetailBarcode('6900000000000'), isFalse);
    expect(isRetailBarcode('6900000000007'), isTrue);
    expect(isGtinLength('12345'), isFalse);
    expect(manualBarcodeError(''), '写上包装上的数字');
    expect(manualBarcodeError('12345'), '需要 8、12、13 或 14 位');
    expect(manualBarcodeError('6958862134621'), '校验没通过，再对一下末位');
    expect(manualBarcodeError('6901111222233'), '校验没通过，再对一下末位');
    expect(manualBarcodeError('6901111222233', known: true), isNull);
    expect(manualBarcodeError('6958 8621 34620'), isNull);
  });

  test(
    'a bad check digit does not lock the camera, a second read is dropped',
    () {
      final session = ScanSession();
      expect(session.take(''), isNull);
      expect(session.take('   '), isNull);
      expect(session.handled, isFalse);
      expect(session.take('6958862134621'), isNull);
      expect(session.handled, isFalse);
      expect(session.take('6901111222233'), isNull);
      expect(session.take('6958862134620'), '6958862134620');
      expect(session.take('036000291452'), isNull);
      expect(session.take('96385074'), isNull);
      final saved = ScanSession();
      expect(
        saved.take('6901111222233', keepInvalid: (_) => true),
        '6901111222233',
      );
      expect(saved.handled, isTrue);
      expect(saved.take('6958862134620'), isNull);
    },
  );

  test('a 69 barcode opens the prefilled bag page, not lookup', () async {
    final database = AppDatabase.memory();
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await controller.init();
    controller.barcodeFetch = (_) async {
      fail('a 69 local hit must not ask the public chain');
    };
    expect(isRetailBarcode('6958862134620'), isTrue);
    final record = await controller.resolveBarcode('6958862134620');
    expect(record.source, 'local');
    expect(record.brand, '麦富迪');
    expect(record.name, '三文鱼双拼全价全期猫粮');
    final route = await scanDestination(controller, '6958862134620');
    final product = controller.findBarcode('6958862134620');
    expect(product, isNotNull);
    expect(product!.brand, '麦富迪');
    expect(product.name, '三文鱼双拼全价全期猫粮');
    expect(route, '/confirm?code=6958862134620&product=${product.id}');
    expect(route.contains('/lookup'), isFalse);
    await database.close();
  });

  test('a QR or product link follows the barcode inside it', () async {
    final database = AppDatabase.memory();
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await controller.init();
    controller.barcodeFetch = (_) async {
      fail('a local code inside a QR must not ask the public chain');
    };
    final session = ScanSession();
    const link =
        'https://id.gs1.org/01/06958862134620/10/LOT9?17=270412&11=251012';
    expect(session.take(link), link);
    final fromLink = await scanDestination(controller, link);
    final product = controller.findBarcode('6958862134620');
    expect(product!.name, '三文鱼双拼全价全期猫粮');
    expect(fromLink, contains('/confirm?'));
    expect(fromLink, contains('product=${product.id}'));
    expect(fromLink, contains(Uri.encodeComponent(link)));
    expect(fromLink.contains('/lookup'), isFalse);

    final fromPage = await scanDestination(
      controller,
      'https://shop.example.com/item/6958862134620',
    );
    expect(fromPage, '/confirm?code=6958862134620&product=${product.id}');

    expect(
      await scanDestination(controller, 'https://id.gs1.org/01/06900000000007'),
      '/lookup?code=6900000000007',
    );
    expect(
      await scanDestination(controller, '(11)251012(17)270412(10)LOT9'),
      '/confirm?code=${Uri.encodeComponent('(11)251012(17)270412(10)LOT9')}',
    );
    expect(
      await scanDestination(controller, 'https://example.com/not-a-product'),
      '/confirm',
    );
    await database.close();
  });

  testWidgets('scan offers torch, typed entry, and a way back', (tester) async {
    final database = AppDatabase.memory();
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
    );
    await controller.init();
    await boot(tester, controller, location: '/scan');

    expect(find.text('相机没开'), findsOneWidget);
    expect(find.byTooltip('手电筒'), findsOneWidget);
    expect(find.text('手输条码'), findsOneWidget);
    expect(find.text('拍包装识别'), findsOneWidget);
    expect(find.text('选品牌'), findsOneWidget);

    for (final label in ['手电筒', '返回', '拍包装识别', '自己添加', '手输条码', '选品牌']) {
      final finder = label == '手电筒' || label == '返回'
          ? find.byTooltip(label)
          : find.widgetWithText(
              label == '选品牌' ? TextButton : FilledButton,
              label,
            );
      final button = label == '自己添加' || label == '手输条码'
          ? find.widgetWithText(OutlinedButton, label)
          : finder;
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
    }

    await tester.tap(find.byTooltip('手电筒'));
    await frames(tester);
    expect(find.text('条形码、二维码都能扫'), findsOneWidget);

    await tester.tap(find.text('手输条码'));
    await frames(tester);
    expect(find.text('包装上的数字'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await frames(tester);
    expect(find.text('包装上的数字'), findsNothing);

    await tester.tap(find.text('手输条码'));
    await frames(tester);
    await tester.enterText(find.byType(TextField), '6958862134621');
    await tester.tap(find.text('查看'));
    await frames(tester);
    expect(find.text('校验没通过，再对一下末位'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await frames(tester);
    expect(find.text('手输条码'), findsOneWidget);

    await tester.tap(find.text('手输条码'));
    await frames(tester);
    await tester.enterText(find.byType(TextField), '6958862134620');
    await tester.tap(find.text('查看'));
    await frames(tester);
    expect(find.text('确认'), findsOneWidget);
    expect(find.text('记下'), findsOneWidget);
    expect(find.text('商品'), findsNothing);
    expect(find.text('正在查这个条码'), findsNothing);
    expect(find.text('麦富迪'), findsWidgets);
    expect(find.text('三文鱼双拼全价全期猫粮'), findsWidgets);

    await database.close();
  });
}
