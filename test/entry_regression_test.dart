import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
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

  testWidgets('two tabs, and leaving a form comes back', (tester) async {
    await boot(tester, controller);
    expect(find.text('今天'), findsWidgets);
    expect(find.text('猫'), findsWidgets);
    expect(find.text('我的'), findsNothing);

    await tapText(tester, '猫');
    expect(find.text('体检'), findsOneWidget);
    expect(find.text('看病'), findsOneWidget);
    await tapText(tester, '添加');
    expect(find.text('建档'), findsOneWidget);
    await back(tester);
    expect(find.text('体检'), findsOneWidget);

    await tapText(tester, '今天');
    await tapText(tester, '室内成猫全价粮');
    expect(find.text('室内成猫全价粮'), findsNothing);
    expect(
      controller.pantry.any((item) => item.product.name == '室内成猫全价粮'),
      isFalse,
    );
  });
}
