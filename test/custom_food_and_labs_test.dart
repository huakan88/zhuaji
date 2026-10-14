import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/health/lab_catalog.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/features/pantry/scan_page.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
  });

  tearDown(() async {
    await database.close();
  });

  test('the camera is asked for EAN, UPC, GS1 and QR', () {
    expect(
      scanFormats,
      containsAll(const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.dataBar,
        BarcodeFormat.dataBarExpanded,
        BarcodeFormat.qrCode,
      ]),
    );
    expect(suggestedLabKind('cbc'), LabKind.cbc);
    expect(suggestedLabKind('sdma'), LabKind.chem);
    expect(suggestedLabKind('vaccine'), isNull);
  });

  testWidgets('scan page says both codes work and offers two ways out', (
    tester,
  ) async {
    await boot(tester, controller, location: '/scan');
    expect(find.text('条形码、二维码都能扫'), findsOneWidget);
    expect(find.text('拍包装识别'), findsOneWidget);
    expect(find.text('自己添加'), findsOneWidget);
    expect(find.text('选品牌'), findsOneWidget);
  });

  testWidgets('a custom food can be added, found and deleted', (tester) async {
    await boot(tester, controller, location: '/catalog');
    await tapText(tester, '自己添加');
    await enterField(tester, '品牌', '山野');
    await enterField(tester, '名称', '冻干双拼');
    await tapText(tester, '冻干');
    await tapText(tester, '鸡肉');
    await tapText(tester, '1.5kg');
    await tapText(tester, '保存');

    final saved = controller.products.where((item) => item.brand == '山野');
    expect(saved, hasLength(1));
    expect(saved.single.isCustom, isTrue);
    expect(saved.single.foodForm, FoodForm.freezeDried);
    expect(saved.single.flavor, '鸡肉');
    expect(saved.single.spec, '1.5kg');

    await enterField(tester, '搜索', '山野');
    expect(find.textContaining('山野'), findsWidgets);
    expect(find.textContaining('自定义'), findsOneWidget);
    await tapText(tester, '山野 冻干双拼');
    expect(find.text('改这款'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '删除'));
    await frames(tester);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await frames(tester);
    expect(controller.products.any((item) => item.brand == '山野'), isFalse);
  });

  testWidgets('the next scan of a custom barcode is recognized', (tester) async {
    await controller.saveFood(
      const FoodDraft(
        brand: '山野',
        name: '冻干双拼',
        spec: '1.5kg',
        foodForm: FoodForm.freezeDried,
        storageMethod: '阴凉干燥，封好袋口。',
        afterOpenDays: 30,
        flavor: '鸡肉',
        isCustom: true,
      ),
      barcode: '6901111222233',
    );
    await boot(tester, controller, location: '/confirm?code=6901111222233');
    expect(find.text('认得这个码'), findsOneWidget);
    expect(find.text('冻干双拼'), findsWidgets);
  });

  testWidgets('a lab sheet flags values and keeps a trend', (tester) async {
    final cat = controller.active!;
    await controller.saveLab(
      LabDraft(
        catId: cat.id,
        kind: LabKind.cbc,
        takenOn: DateTime(2026, 9, 1),
        photos: const [],
      ),
      values: const [LabValue(code: 'WBC', value: 10, unit: '10^9/L')],
    );
    final id = await controller.saveLab(
      LabDraft(
        catId: cat.id,
        kind: LabKind.cbc,
        takenOn: DateTime(2026, 10, 12),
        photos: const [],
      ),
      values: const [
        LabValue(code: 'WBC', value: 18.2, unit: '10^9/L'),
        LabValue(code: 'PLT', value: 88, unit: '10^9/L'),
      ],
    );
    await boot(tester, controller, location: '/labs');
    expect(find.textContaining('偏高'), findsWidgets);
    expect(find.textContaining('偏低'), findsWidgets);
    await tapText(tester, '2026年10月12日 · 血常规');
    await revealText(tester, '仅供参考，以兽医诊断为准');
    expect(find.text('仅供参考，以兽医诊断为准'), findsOneWidget);
    expect(find.textContaining('白细胞偏高'), findsOneWidget);
    expect(find.textContaining('血小板偏低'), findsOneWidget);
    expect(find.textContaining('的变化'), findsOneWidget);
    await revealText(tester, labRangeSource);
    expect(find.textContaining('IDEXX'), findsOneWidget);

    await tapText(tester, '红细胞');
    await tapText(tester, '用这个');
    await tapText(tester, '保存');
    final again = controller.labById(id);
    expect(again!.values.any((item) => item.code == 'RBC'), isTrue);
  });
}
