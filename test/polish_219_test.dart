import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/features/pantry/scan_page.dart';
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
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('a search miss can scan, and a barcode can be looked up', (
    tester,
  ) async {
    await boot(tester, controller, location: '/home');
    await enter(tester, find.byType(TextField), '没有这只猫');
    await frames(tester);
    expect(find.text('没有找到'), findsOneWidget);
    expect(find.text('扫码'), findsOneWidget);

    await enter(tester, find.byType(TextField), '6900000000007');
    await frames(tester);
    expect(find.text('查这个条码'), findsOneWidget);
  });

  testWidgets('pantry miss of a barcode offers lookup and manual add', (
    tester,
  ) async {
    await boot(tester, controller, location: '/pantry');
    await enter(tester, find.byType(TextField), '6900000000007');
    await frames(tester);
    expect(find.text('没有这款'), findsOneWidget);
    expect(find.text('查这个条码'), findsOneWidget);
    expect(find.text('自己添加'), findsWidgets);
  });

  testWidgets('one tap records the last vaccine again', (tester) async {
    await boot(tester, controller, location: '/health');
    final before = controller.catVaccines.length;
    await tapText(tester, '今天再记 猫三联');
    expect(controller.catVaccines, hasLength(before + 1));
    final saved = controller.catVaccines.reduce(
      (a, b) => a.givenOn.isAfter(b.givenOn) ? a : b,
    );
    expect(saved.name, '猫三联');
    expect(saved.givenOn, DateTime(2026, 10, 12));
    expect(saved.nextDue, DateTime(2027, 10, 12));
  });

  testWidgets('a catalog hit shows brand, spec and ingredients together', (
    tester,
  ) async {
    controller.barcodeFetch = (_) async {
      fail('a built-in barcode must not ask the public chain');
    };
    final route = await scanDestination(controller, '3182550799669');
    expect(route, contains('/confirm?'));
    expect(route, contains('product='));
    await boot(tester, controller, location: route);
    expect(find.text('Neutered Satiety Balance'), findsOneWidget);
    expect(find.text('皇家'), findsWidgets);
    expect(find.text('12千克'), findsOneWidget);
    expect(find.text('配料'), findsOneWidget);
    expect(find.textContaining('Protéines de volailles'), findsOneWidget);
    expect(find.text('成分'), findsOneWidget);
    expect(find.text('粗蛋白'), findsOneWidget);
  });

  testWidgets('a stocked 69 bag shows its spec on the bag page', (
    tester,
  ) async {
    controller.barcodeFetch = (_) async {
      fail('a built-in barcode must not ask the public chain');
    };
    await scanDestination(controller, '6958862134620');
    final product = controller.findBarcode('6958862134620')!;
    expect(product.spec, '2千克');
    final bagId = await controller.savePantry(
      PantryDraft(
        productId: product.id,
        dateSource: DateSource.manual,
        openedAt: DateTime(2026, 10, 1),
        expiryDate: DateTime(2027, 6, 1),
        afterOpenDays: 30,
      ),
    );
    expect(
      await scanDestination(controller, '6958862134620'),
      '/bag?id=$bagId',
    );
    await boot(tester, controller, location: '/bag?id=$bagId');
    expect(find.text('三文鱼双拼全价全期猫粮'), findsOneWidget);
    expect(find.text('麦富迪'), findsOneWidget);
    expect(find.text('2千克'), findsOneWidget);
    expect(find.text('规格'), findsOneWidget);
  });

  testWidgets('typing a saved bag with a bad check digit opens that bag', (
    tester,
  ) async {
    final productId = await controller.saveFood(
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
    await controller.savePantry(
      PantryDraft(
        productId: productId,
        dateSource: DateSource.manual,
        openedAt: DateTime(2026, 10, 1),
        expiryDate: DateTime(2027, 6, 1),
        afterOpenDays: 30,
      ),
    );
    await boot(tester, controller, location: '/scan');
    await tapText(tester, '手输条码');
    await enter(tester, find.byType(TextField), '6901111222233');
    await tapText(tester, '查看');
    expect(find.text('冻干双拼'), findsOneWidget);
    expect(find.text('校验没通过，再对一下末位'), findsNothing);
  });
}
