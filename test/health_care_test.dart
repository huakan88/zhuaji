import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('checkups, disease care, and water logs persist per cat', (
    tester,
  ) async {
    await boot(tester, controller);
    expect(controller.active?.name, '橘座');
    expect(controller.catConditions.map((item) => item.diseaseId), ['ckd']);
    expect(controller.todayWaterMl, 180);

    await tester.tap(find.text('健康').last);
    await frames(tester);
    expect(find.text('体检'), findsOneWidget);
    expect(find.text('养护'), findsOneWidget);
    expect(find.textContaining('仅供参考，请遵医嘱'), findsWidgets);

    await tapText(tester, '体检');
    expect(find.textContaining('3 岁'), findsOneWidget);
    expect(find.textContaining('成年'), findsWidgets);
    expect(find.text('PKD 基因或肾脏超声'), findsNothing);
    await tapText(tester, '更多');
    expect(find.textContaining('AAHA/AAFP'), findsWidgets);
    await tapText(tester, '已完成');
    expect(find.textContaining('已记下，下次会再提醒'), findsWidgets);

    final again = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 11),
    );
    await again.init();
    expect(again.checkups.any((item) => item.result == '已完成'), isTrue);

    await tapText(tester, '加入提醒');
    expect(find.textContaining('已经有未到的提醒'), findsOneWidget);
    await back(tester);

    await tapText(tester, '养护');
    await tapText(tester, '慢性肾病');
    expect(find.text('需要立即就医'), findsOneWidget);
    expect(find.textContaining('IRIS'), findsWidgets);
    await revealText(tester, '180 ml');
    expect(find.textContaining('180 ml'), findsWidgets);
    await tapText(tester, '记饮水');
    await enterField(tester, '大约喝了多少毫升', '0');
    await tapText(tester, '保存');
    expect(find.text('饮水量请填 1 到 2000 毫升'), findsOneWidget);
    await enterField(tester, '大约喝了多少毫升', '90');
    await tapText(tester, '保存');
    expect(controller.todayWaterMl, 270);
    await tapText(tester, '记体重');
    expect(find.text('记录体重'), findsOneWidget);
    Navigator.of(tester.element(find.text('记录体重'))).pop();
    await frames(tester);
    await back(tester);

    await enterField(tester, '搜索', '不存在的病xyz');
    expect(find.text('没有这种病'), findsOneWidget);
    await enterField(tester, '搜索', '口炎');
    expect(find.text('口炎与牙病'), findsOneWidget);
    await tapText(tester, '口炎与牙病');
    expect(find.textContaining('对乙酰氨基酚'), findsOneWidget);
    await tapText(tester, '标记确诊');
    expect(find.textContaining('已记到橘座'), findsOneWidget);
    expect(
      controller.catConditions.map((item) => item.diseaseId),
      contains('stomatitis'),
    );
    await tapText(tester, '取消标记');
    await tapText(tester, '删除');
    expect(
      controller.catConditions.map((item) => item.diseaseId),
      isNot(contains('stomatitis')),
    );
    await back(tester);
    await back(tester);

    await tapText(tester, '今天');
    await tapText(tester, '橘座');
    await tapText(tester, '奶油');
    expect(controller.active?.name, '奶油');
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/health');
    await frames(tester);
    expect(find.text('体检'), findsOneWidget);
    expect(find.text('慢性肾病'), findsNothing);
    await tapText(tester, '体检');
    await revealText(tester, 'PKD 基因或肾脏超声');
    expect(find.text('PKD 基因或肾脏超声'), findsOneWidget);
    expect(find.text('心脏超声（HCM 筛查）'), findsNothing);
    expect(controller.catWaters, isEmpty);
  });
}
