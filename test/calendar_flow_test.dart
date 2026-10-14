import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/models.dart';
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

  testWidgets('a day opens its items and postpone moves them a week', (
    tester,
  ) async {
    await boot(tester, controller, location: '/calendar');
    expect(find.text('未来 30 天'), findsWidgets);
    await tapText(tester, '18');
    expect(find.textContaining('体外'), findsWidgets);
    await tapText(tester, '顺延');
    expect(find.text('顺延了 7 天'), findsOneWidget);
    await tapText(tester, '25');
    expect(find.textContaining('体外'), findsWidgets);
  });

  testWidgets('sticker confirm saves the lot the camera read', (tester) async {
    await boot(tester, controller, location: '/sticker?demo=1');
    expect(find.text('批号 A12B-3391'), findsOneWidget);
    expect(find.text('认出来了，对一下再记下。不对就重拍。'), findsOneWidget);
    await tapText(tester, '记下');
    await frames(tester);
    final saved = controller.catVaccines.where(
      (item) => item.batch == 'A12B-3391',
    );
    expect(saved, isNotEmpty);
    expect(saved.first.name, '猫三联');
  });

  testWidgets('daily grams estimate how long the bag lasts', (tester) async {
    final productId = await controller.saveFood(
      const FoodDraft(
        brand: '山野',
        name: '冻干双拼',
        spec: '1.5kg',
        foodForm: FoodForm.dry,
        storageMethod: '阴凉干燥。',
        afterOpenDays: 30,
        isCustom: true,
      ),
    );
    final pantryId = await controller.savePantry(
      PantryDraft(
        productId: productId,
        dateSource: DateSource.manual,
        openedAt: DateTime(2026, 9, 30),
        expiryDate: DateTime(2026, 12, 1),
      ),
    );
    await boot(tester, controller, location: '/bag?id=$pantryId');
    expect(find.text('点一下每天喂多少'), findsOneWidget);
    await tapText(tester, '80 克');
    await frames(tester);
    expect(find.textContaining('该补货了'), findsWidgets);
  });
}
