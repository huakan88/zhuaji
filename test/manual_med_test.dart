import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/features/health/known_or_custom.dart';
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

  test('a blank manual name is rejected and a typed name is kept', () {
    final controller = TextEditingController();
    expect(
      chosenOrTyped(custom: false, controller: controller, selected: '大宠爱'),
      '大宠爱',
    );
    expect(
      chosenOrTyped(custom: true, controller: controller, selected: '大宠爱'),
      isNull,
    );
    controller.text = '  爱沃克  ';
    expect(
      chosenOrTyped(custom: true, controller: controller, selected: '大宠爱'),
      '爱沃克',
    );
    controller.dispose();
  });

  testWidgets('deworm keeps the known brands and saves a typed medicine', (
    tester,
  ) async {
    await boot(tester, controller, location: '/deworms');
    expect(find.text('大宠爱'), findsOneWidget);
    expect(find.text('博来恩'), findsOneWidget);
    expect(find.text('海乐妙'), findsOneWidget);
    expect(find.text(otherChoiceLabel), findsOneWidget);

    final before = controller.catDeworms.length;
    await tapText(tester, otherChoiceLabel);
    expect(find.byType(TextField), findsOneWidget);
    await enter(tester, find.byType(TextField), '   ');
    await tapText(tester, '记下');
    expect(find.text('先写上名字'), findsOneWidget);
    expect(controller.catDeworms, hasLength(before));

    await enter(tester, find.byType(TextField), '爱沃克');
    await tapText(tester, '记下');
    expect(controller.catDeworms.map((item) => item.product), contains('爱沃克'));

    await tapText(tester, '海乐妙');
    expect(find.byType(TextField), findsNothing);
    await tapText(tester, '记下');
    expect(controller.catDeworms.map((item) => item.product), contains('海乐妙'));
  });

  testWidgets('vaccine keeps 猫三联 and 狂犬 and saves a typed name', (
    tester,
  ) async {
    await boot(tester, controller, location: '/vaccines');
    expect(find.text('猫三联'), findsWidgets);
    expect(find.text('狂犬'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tapText(tester, otherChoiceLabel);
    await enter(tester, find.byType(TextField), '猫白血病');
    await tapText(tester, '记下');
    expect(controller.catVaccines.map((item) => item.name), contains('猫白血病'));
  });

  testWidgets('a sticker can be saved under a typed vaccine name', (
    tester,
  ) async {
    await boot(tester, controller, location: '/sticker');
    expect(find.text('猫三联'), findsOneWidget);
    expect(find.text('狂犬'), findsOneWidget);
    await tapText(tester, otherChoiceLabel);
    await enter(tester, find.byType(TextField), '四联');
    await tapText(tester, '记下');
    expect(controller.catVaccines.map((item) => item.name), contains('四联'));
  });
}
