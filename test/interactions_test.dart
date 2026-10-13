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

  testWidgets('today lists three todos and a tap finishes one', (tester) async {
    await boot(tester, controller);
    expect(find.text('扫粮'), findsOneWidget);
    expect(find.text('到期粮'), findsOneWidget);
    expect(find.text('疫苗'), findsOneWidget);
    expect(find.text('体重'), findsOneWidget);
    expect(find.text('健康'), findsNothing);
    expect(find.text('粮仓'), findsNothing);

    await tapText(tester, '猫三联');
    expect(find.text('猫三联'), findsNothing);
    expect(
      controller.catVaccines.single.nextDue!.isAfter(DateTime(2027, 1, 1)),
      isTrue,
    );

    await tapText(tester, '体重');
    expect(find.text('体重'), findsNothing);
    expect(controller.weightAlertVisible(controller.active!), isFalse);
  });

  testWidgets('cat page switches cats and logs weight in one tap', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '猫');
    expect(find.text('4.35 kg'), findsWidgets);
    await tapText(tester, '奶油');
    expect(controller.active?.name, '奶油');
    expect(find.text('4.05 kg'), findsWidgets);
    expect(find.text('4.35 kg'), findsNothing);

    await tapText(tester, '4.05 kg');
    expect(find.text('记录体重'), findsOneWidget);
    await tapText(tester, '轻一点');
    await tapText(tester, '保存');
    expect(controller.latestWeight!.weightKg, closeTo(4.0, 0.001));
    expect(find.text('4.00 kg'), findsWidgets);
  });

  testWidgets('scan fills the date and one confirm saves the bag', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '扫粮');
    expect(find.text('手输'), findsOneWidget);
    await tapText(tester, '手输');
    await tapText(tester, '确定');
    expect(find.text('还没扫到'), findsOneWidget);

    await enterField(tester, '条码', '(11)251012(17)270412(10)DEMO');
    await tapText(tester, '确定');
    expect(find.text('确认'), findsOneWidget);
    expect(find.textContaining('2027年4月12日'), findsOneWidget);
    await enterField(tester, '名字', '测试粮');
    await tapText(tester, '记下');
    expect(find.text('扫粮'), findsOneWidget);
    final bag = controller.pantry.singleWhere(
      (item) => item.product.name == '测试粮',
    );
    expect(bag.item.expiryDate!.year, 2027);
    expect(bag.item.expiryDate!.month, 4);
    expect(bag.item.expiryDate!.day, 12);
    expect(find.text('测试粮'), findsNothing);
  });

  testWidgets('a new cat is only a photo and a name', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '猫');
    await tapText(tester, '添加');
    expect(find.text('名字'), findsOneWidget);
    expect(find.text('已绝育'), findsNothing);
    await tapText(tester, '保存');
    expect(find.text('先写名字'), findsOneWidget);
    await enterField(tester, '名字', '小黑');
    await tapText(tester, '保存');
    expect(find.text('先拍一张'), findsOneWidget);
    await tapText(tester, '示例');
    await tapText(tester, '保存');
    expect(controller.cats.map((cat) => cat.name), contains('小黑'));
    expect(find.text('小黑'), findsWidgets);

    await tapText(tester, '删除');
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await frames(tester);
    expect(controller.cats.map((cat) => cat.name), isNot(contains('小黑')));
    expect(controller.cats.map((cat) => cat.name), contains('橘座'));
  });
}
