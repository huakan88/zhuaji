import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/health/lab_catalog.dart';
import 'package:maokangji/domain/models.dart';
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

  test('a custom lab unit is kept and not graded on the catalog range', () {
    const custom = LabValue(code: 'HGB', value: 1, unit: 'mmol/L');
    expect(readLabValue(custom), isNull);
    expect(baseValue(custom), 1);
    final known = readLabValue(
      const LabValue(code: 'HGB', value: 100, unit: 'g/L'),
    );
    expect(known, isNotNull);
    expect(known!.flag, LabFlag.normal);
  });

  testWidgets('food flavor, spec and form keep the typed words', (
    tester,
  ) async {
    await boot(tester, controller, location: '/catalog');
    await tapText(tester, '自己添加');
    await enterField(tester, '品牌', '山野');
    await enterField(tester, '名称', '生骨肉');
    await tapText(tester, otherChoiceLabel);
    await enter(tester, _hint('形态'), '生骨肉');
    await tapText(tester, otherChoiceLabel, index: 1);
    await enter(tester, _hint('口味'), '鹌鹑');
    await tapText(tester, otherChoiceLabel, index: 2);
    await enter(tester, _hint('规格'), '400g');
    await tapText(tester, '保存');

    final saved = controller.products.singleWhere((item) => item.brand == '山野');
    expect(saved.customForm, '生骨肉');
    expect(saved.formTitle, '生骨肉');
    expect(saved.flavor, '鹌鹑');
    expect(saved.spec, '400g');
    expect(saved.foodForm, FoodForm.dry);
  });

  testWidgets('a blank custom flavor does not save', (tester) async {
    await boot(tester, controller, location: '/catalog');
    await tapText(tester, '自己添加');
    await enterField(tester, '品牌', '山野');
    await enterField(tester, '名称', '生骨肉');
    await tapText(tester, otherChoiceLabel, index: 1);
    await tapText(tester, '保存');
    expect(find.text('先写上口味'), findsOneWidget);
    expect(controller.products.any((item) => item.brand == '山野'), isFalse);
  });

  testWidgets(
    'visit reason, clinic, breed, checkup and disease store typed names',
    (tester) async {
      await boot(tester, controller, location: '/visits');
      await tapText(tester, otherChoiceLabel);
      await enter(tester, _hint('原因'), '拉肚子');
      await tapText(tester, otherChoiceLabel, index: 1);
      await enter(tester, _hint('医院'), '小区医院');
      await tapText(tester, '记下');
      final visit = controller.catVisits.singleWhere(
        (item) => item.reason == '拉肚子',
      );
      expect(visit.clinic, '小区医院');

    final cat = controller.cats.firstWhere((item) => item.name == '橘座');
    await tester.pumpWidget(const SizedBox());
    await boot(tester, controller, location: '/cats');
    await tapText(tester, '中华田园猫');
    await tapText(tester, otherChoiceLabel);
    await enter(tester, _hint('品种'), '金渐层');
    await tapText(tester, '保存');
    expect(controller.catById(cat.id)?.breed, '金渐层');

      await tester.pumpWidget(const SizedBox());
      await boot(tester, controller, location: '/checkups');
      await tapText(tester, otherChoiceLabel);
      await enter(tester, _hint('项目'), '心脏听诊');
      await tapText(tester, '完成');
      expect(controller.checkups.any((item) => item.itemId == '心脏听诊'), isTrue);

      await tester.pumpWidget(const SizedBox());
      await boot(tester, controller, location: '/diseases');
      await tapText(tester, otherChoiceLabel);
      await enter(tester, _hint('病名'), '耳螨');
      await tapText(tester, '记下');
      expect(
        controller.catConditions.map((item) => item.diseaseId),
        contains('耳螨'),
      );
    },
  );

  testWidgets('bag grams and lab kind keep a typed value', (tester) async {
    final bag = controller.pantry.first;
    await boot(tester, controller, location: '/bag?id=${bag.item.id}');
    await tapText(tester, otherChoiceLabel);
    await enter(tester, _hint('克'), '45');
    await tapText(tester, '用这个');
    expect(controller.pantryById(bag.item.id)?.item.dailyGrams, 45);

    await tester.pumpWidget(const SizedBox());
    await boot(tester, controller, location: '/lab');
    await tapText(tester, '其他');
    await enter(tester, _hint('化验名称'), '血气');
    await revealText(tester, '血红蛋白');
    await tapText(tester, '血红蛋白');
    await tapText(tester, otherChoiceLabel);
    await enter(tester, _hint('单位'), 'mmol/L');
    await tapText(tester, '用这个');
    await tapText(tester, '保存');

    final report = controller.labs.last;
    expect(report.kindLabel, '血气');
    expect(report.kindTitle, '血气');
    final hgb = report.values.singleWhere((item) => item.code == 'HGB');
    expect(hgb.unit, 'mmol/L');
    expect(readLabValue(hgb), isNull);
  });
}

Finder _hint(String hint) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );
}
