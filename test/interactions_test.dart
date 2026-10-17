import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/features/health/weight_page.dart';
import 'package:maokangji/features/home/home_page.dart';
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

  testWidgets('today completes a todo in one tap', (tester) async {
    await boot(tester, controller);
    expect(find.text('健康'), findsOneWidget);
    expect(find.text('粮仓'), findsOneWidget);
    expect(find.text('猫咪'), findsOneWidget);
    expect(_homeText('到期粮'), findsOneWidget);
    expect(_homeText('疫苗'), findsOneWidget);
    await revealText(tester, '示例体外驱虫');
    expect(_homeText('驱虫'), findsNWidgets(2));
    await revealText(tester, '体重');
    expect(_homeText('体重'), findsOneWidget);

    await tapText(tester, '猫三联');
    expect(find.textContaining('下次'), findsWidgets);
    expect(
      controller.catVaccines.single.nextDue!.isAfter(DateTime(2027, 1, 1)),
      isTrue,
    );
    expect(_homeText('猫三联'), findsNothing);

    await tapText(tester, '体重');
    expect(find.text('轻一点'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WeightPage),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );
    await tapText(tester, '保存');
    expect(_homeText('体重'), findsNothing);
    expect(controller.weightAlertVisible(controller.active!), isFalse);
  });

  testWidgets('cat page switches cats and weight is a stepper', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '猫咪');
    expect(find.text('4.35 kg'), findsWidgets);
    await tapText(tester, '奶油');
    expect(controller.active?.name, '奶油');
    expect(find.text('4.05 kg'), findsWidgets);
    expect(find.text('4.35 kg'), findsNothing);

    await tapText(tester, '健康');
    await tapText(tester, '体重');
    expect(find.text('轻一点'), findsOneWidget);
    await tapText(tester, '轻一点');
    await tapText(tester, '保存');
    expect(controller.latestWeight!.weightKg, closeTo(4.0, 0.001));
    await tapText(tester, '猫咪');
    expect(find.text('4.00 kg'), findsWidgets);
  });

  testWidgets('scan confirm is chips and a wheel, then today shows the bag', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '粮仓');
    await tester.tap(find.byTooltip('扫码'));
    await frames(tester);
    expect(find.text('手输'), findsNothing);
    expect(find.text('选品牌'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tapText(tester, '选品牌');
    expect(find.text('确认'), findsOneWidget);
    expect(find.text('生产'), findsOneWidget);
    expect(find.text('到期'), findsOneWidget);
    expect(find.text('开封'), findsOneWidget);
    expect(find.text('室内成猫干粮'), findsWidgets);
    expect(find.byType(TextField), findsNothing);
    await tapText(tester, '记下');
    expect(_homeText('室内成猫干粮'), findsOneWidget);
    final bag = controller.pantry.singleWhere(
      (item) => item.product.name == '室内成猫干粮',
    );
    expect(bag.item.openedAt, isNotNull);
    expect(bag.item.expiryDate, isNotNull);

    await tapText(tester, '室内成猫干粮');
    expect(find.textContaining('还在粮仓'), findsWidgets);
    expect(_homeText('室内成猫干粮'), findsNothing);
    expect(
      controller.pantry.any((item) => item.product.name == '室内成猫干粮'),
      isTrue,
    );
  });

  testWidgets('a code with dates opens the same confirm page', (tester) async {
    await boot(
      tester,
      controller,
      location:
          '/confirm?code=${Uri.encodeComponent('(11)251012(17)270412(10)DEMO')}',
    );
    expect(find.text('确认'), findsOneWidget);
    expect(find.textContaining('2027年4月12日'), findsOneWidget);
    expect(find.text('开封'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a new cat is only a photo and a name', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '猫咪');
    await tapText(tester, '添加');
    expect(find.text('名字'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
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

  testWidgets('health chips and pantry still finish the job', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '健康');
    expect(find.text('就医'), findsOneWidget);
    expect(find.text('体检'), findsOneWidget);
    expect(find.text('看病'), findsOneWidget);

    await tapText(tester, '疫苗');
    expect(find.text('猫三联'), findsWidgets);
    expect(find.byType(TextField), findsNothing);
    await tapText(tester, '狂犬');
    await tapText(tester, '记下');
    expect(controller.catVaccines.map((item) => item.name), contains('狂犬'));
    await back(tester);

    await tapText(tester, '驱虫');
    expect(find.text('示例体外驱虫'), findsWidgets);
    expect(find.text('示例体内驱虫'), findsWidgets);
    await tapText(tester, '完成');
    expect(
      controller.catDeworms
          .singleWhere((item) => item.product == '示例体外驱虫')
          .nextDue!
          .isAfter(DateTime(2027, 1, 1)),
      isTrue,
    );
    await tapText(tester, '大宠爱');
    await tapText(tester, '记下');
    expect(controller.catDeworms.map((item) => item.product), contains('大宠爱'));
    await back(tester);

    await tapText(tester, '就医');
    expect(find.text('年度体检'), findsWidgets);
    expect(find.textContaining('示例宠物医院'), findsWidgets);
    expect(find.byType(TextField), findsNothing);
    await tapText(tester, '呕吐');
    await tapText(tester, '记下');
    final vomit = controller.catVisits.singleWhere(
      (item) => item.reason == '呕吐',
    );
    expect(vomit.clinic, '示例宠物医院');
    await back(tester);

    await tapText(tester, '粮仓');
    expect(find.text('室内成猫全价粮'), findsWidgets);
    expect(find.textContaining('还剩 20 天'), findsOneWidget);
    expect(find.textContaining('没开封'), findsOneWidget);
    await tapText(tester, '浓汤大口肉罐');
    expect(find.text('已吃完'), findsOneWidget);
    expect(find.text('删除'), findsWidgets);
    await tapText(tester, '已吃完');
    await tapText(tester, '吃完了');
    expect(
      controller.pantry.any((item) => item.product.name == '浓汤大口肉罐'),
      isFalse,
    );
  });
}

Finder _homeText(String text) {
  return find.descendant(of: find.byType(HomePage), matching: find.text(text));
}
