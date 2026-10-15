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

  testWidgets('pantry links are at least 48dp', (tester) async {
    await boot(tester, controller, location: '/pantry');
    for (final label in ['拍贴纸', '自定义猫粮', '自制鲜食', '图鉴']) {
      final size = tester.getSize(find.widgetWithText(TextButton, label));
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
    }
  });

  testWidgets('cat pills and profile rows are at least 48dp', (tester) async {
    await boot(tester, controller, location: '/home');
    expect(find.text('橘座'), findsWidgets);
    final pill = find.ancestor(
      of: find.text('橘座'),
      matching: find.byType(GestureDetector),
    );
    expect(pill, findsWidgets);
    expect(tester.getSize(pill.first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('cat profile rows are at least 48dp', (tester) async {
    await boot(tester, controller, location: '/cats');
    final weight = find.ancestor(
      of: find.text('体重'),
      matching: find.byType(ConstrainedBox),
    );
    expect(weight, findsWidgets);
    expect(tester.getSize(weight.first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('calendar days stay at least 48dp on a phone', (tester) async {
    await boot(tester, controller, location: '/calendar');
    final day = find.ancestor(
      of: find.text('12'),
      matching: find.byType(InkWell),
    );
    expect(day, findsWidgets);
    final box = tester.getSize(day.first);
    expect(box.width, greaterThanOrEqualTo(48));
    expect(box.height, greaterThanOrEqualTo(48));
  });
}
