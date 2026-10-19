import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/domain/food/recognition_draft.dart';
import 'package:maokangji/features/pantry/scan_page.dart';
import 'package:maokangji/services/barcode_share.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AppController controller;

  setUp(() async {
    database = AppDatabase.memory();
    controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 17, 9),
    );
    await controller.init();
  });

  tearDown(() async {
    await database.close();
  });

  test('a draft survives a restart and does not invent an expiry', () async {
    const code = '6900000000007';
    await controller.saveRecognitionDraft(
      RecognitionDraft(
        id: recognitionDraftId(barcode: code),
        kind: 'ocr',
        updatedAt: DateTime.utc(2026, 10, 17),
        barcode: code,
        brand: '伯纳天纯',
        name: '全价成猫粮',
        spec: '1.5kg',
        ingredients: '鸡肉',
        addBag: true,
      ),
    );
    final again = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 17, 9),
    );
    await again.init();
    final draft = again.draftFor(barcode: code);
    expect(draft, isNotNull);
    expect(draft!.brand, '伯纳天纯');
    expect(draft.name, '全价成猫粮');
    expect(draft.ingredients, '鸡肉');
    expect(draft.expiry, isNull);
    expect(draft.toSyncJson()['kind'], 'ocr');
    expect(again.openDrafts, hasLength(1));
  });

  test('a pending correction opens confirm and does not ask the network', () async {
    const code = '6900000000007';
    controller.barcodeFetch = (_) async {
      fail('a pending correction must not ask the network');
    };
    controller.shareQueue = [
      SharePending.waiting(
        const BarcodeRecord(
          code: code,
          found: true,
          brand: '伯纳天纯',
          name: '全价成猫粮',
          quantity: '2kg',
          ingredients: '鸡',
          nutrients: [],
          source: 'user',
        ),
        DateTime.utc(2026, 10, 17),
      ),
    ];
    final route = await scanDestination(controller, code);
    expect(route, contains('/confirm?'));
    expect(route, isNot(contains('/lookup')));
    expect(controller.findBarcode(code)?.brand, '伯纳天纯');
    expect(controller.findBarcode(code)?.name, '全价成猫粮');
  });

  testWidgets('a new bag does not prefill expiry a year ahead', (tester) async {
    await boot(
      tester,
      controller,
      location: '/food?bag=1&code=6900000000007',
    );
    expect(find.text('条码 6900000000007'), findsOneWidget);
    await revealText(tester, '没认出到期日，请手写。不会自动记成一年后。');
    expect(
      find.text('没认出到期日，请手写。不会自动记成一年后。'),
      findsOneWidget,
    );
    expect(find.textContaining('2027年10月'), findsNothing);
    expect(find.text('请手写'), findsWidgets);
  });

  testWidgets('最近识别 restores the fields that were read', (tester) async {
    const code = '6900000000007';
    await controller.saveRecognitionDraft(
      RecognitionDraft(
        id: recognitionDraftId(barcode: code),
        kind: 'ocr',
        updatedAt: DateTime.utc(2026, 10, 17),
        barcode: code,
        brand: '伯纳天纯',
        name: '全价成猫粮',
        spec: '1.5kg',
        ingredients: '鸡肉',
        expiry: DateTime(2027, 3, 15),
        expiryFromOcr: true,
        addBag: true,
      ),
    );
    await boot(tester, controller, location: '/pantry');
    expect(find.text('最近识别'), findsOneWidget);
    expect(find.text('伯纳天纯 全价成猫粮'), findsOneWidget);
    await tapText(tester, '伯纳天纯 全价成猫粮');
    expect(find.text('条码 $code'), findsOneWidget);
    final values = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((field) => field.controller?.text)
        .toList();
    expect(values, contains('伯纳天纯'));
    expect(values, contains('全价成猫粮'));
    expect(values, contains('鸡肉'));
    await revealText(tester, '2027年3月15日');
    expect(find.text('2027年3月15日'), findsOneWidget);
  });
}
