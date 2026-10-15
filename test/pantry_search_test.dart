import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:maokangji/app.dart';
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

  test(
    'a stocked barcode opens the bag and a new code opens confirm',
    () async {
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
      final bagId = await controller.savePantry(
        PantryDraft(
          productId: productId,
          dateSource: DateSource.manual,
          openedAt: DateTime(2026, 10, 1),
          expiryDate: DateTime(2027, 6, 1),
          afterOpenDays: 30,
        ),
      );
      expect(scanDestination(controller, '6901111222233'), '/bag?id=$bagId');
      expect(
        scanDestination(controller, '6900000000007'),
        '/lookup?code=6900000000007',
      );
      expect(scanDestination(controller, '  '), '/confirm');
    },
  );

  testWidgets('search finds a stocked bag and a catalog food', (tester) async {
    await boot(tester, controller, location: '/pantry');
    expect(find.text('扫粮'), findsNothing);
    expect(find.byTooltip('扫码'), findsOneWidget);

    await enter(tester, find.byType(TextField), '室内成猫全价粮');
    expect(find.text('室内成猫全价粮'), findsWidgets);
    expect(find.text('猫粮库'), findsNothing);

    await enter(tester, find.byType(TextField), '幼猫慕斯罐');
    expect(find.text('幼猫慕斯罐'), findsWidgets);
    expect(find.textContaining('未入库'), findsWidgets);
    await tapText(tester, '幼猫慕斯罐', index: 1);
    expect(find.text('确认'), findsWidgets);
    expect(find.text('幼猫慕斯罐'), findsWidgets);
    expect(find.text('品牌'), findsNothing);
  });

  testWidgets('a scan shortcut opens the camera over 今天', (tester) async {
    await boot(tester, controller);
    final router = GoRouter.of(tester.element(find.text('今天').first));
    openAppRoute(router, shortcutRoute('scan')!);
    await frames(tester);
    expect(find.text('条形码、二维码都能扫'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await frames(tester);
    expect(find.byTooltip('扫码'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == '猫咪、粮、记录',
      ),
      findsOneWidget,
    );
  });
}
