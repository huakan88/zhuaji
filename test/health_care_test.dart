import 'package:flutter/material.dart';
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

  testWidgets('checkup and disease stay on the cat page', (tester) async {
    await boot(tester, controller);
    expect(controller.catConditions.map((item) => item.diseaseId), ['ckd']);

    await tapText(tester, '健康');
    await tapText(tester, '体检');
    expect(find.textContaining('3 岁'), findsOneWidget);
    expect(find.textContaining('成年'), findsWidgets);
    expect(find.text('PKD 基因或肾脏超声'), findsNothing);
    expect(find.textContaining('仅供参考'), findsNothing);
    await tapText(tester, '完成');
    expect(find.text('记下了'), findsWidgets);

    final again = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 11),
    );
    await again.init();
    expect(again.checkups.any((item) => item.result == '已完成'), isTrue);
    await back(tester);

    await tapText(tester, '看病');
    await tapText(tester, '慢性肾病');
    expect(find.text('红灯'), findsOneWidget);
    expect(find.text('已记'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tapText(tester, '口炎与牙病');
    expect(find.text('红灯'), findsOneWidget);
    await tapText(tester, '记下');
    expect(
      controller.catConditions.map((item) => item.diseaseId),
      contains('stomatitis'),
    );
    await back(tester);

    await tapText(tester, '猫咪');
    await tapText(tester, '奶油');
    expect(controller.active?.name, '奶油');
    await tapText(tester, '健康');
    await tapText(tester, '体检');
    await revealText(tester, 'PKD 基因或肾脏超声');
    expect(find.text('PKD 基因或肾脏超声'), findsOneWidget);
    expect(find.text('心脏超声（HCM 筛查）'), findsNothing);
  });
}
