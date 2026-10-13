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

  testWidgets('switching cats isolates weights and meals', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '健康');
    await revealText(tester, '最近 4.35 kg');
    expect(find.text('最近 4.35 kg'), findsOneWidget);

    await tapText(tester, '今天');
    await tapText(tester, '橘座');
    await tapText(tester, '奶油');

    expect(controller.active?.name, '奶油');
    await tapText(tester, '健康');
    await revealText(tester, '最近 4.05 kg');
    expect(find.text('最近 4.05 kg'), findsOneWidget);
    expect(find.text('最近 4.35 kg'), findsNothing);
  });

  testWidgets('home alerts and scan open the health and pantry flows', (
    tester,
  ) async {
    await boot(tester, controller);

    await tapText(tester, '驱虫');
    expect(find.text('记体重'), findsOneWidget);
    await tapText(tester, '今天');

    await tapText(tester, '临期猫粮');
    expect(find.text('在库'), findsOneWidget);
    await back(tester);

    await tapText(tester, '下次疫苗');
    expect(find.text('疫苗'), findsWidgets);
    await tapText(tester, '今天');

    await tapText(tester, '扫条码');
    expect(find.text('使用这段内容'), findsOneWidget);
    await back(tester);
  });

  testWidgets('weight sheet validates, persists, and can be deleted', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '健康');
    await tapText(tester, '记体重');
    expect(find.text('记录体重'), findsOneWidget);
    expect(find.text('4.35 kg'), findsWidgets);
    await tapText(tester, '轻一点');
    expect(find.text('4.30 kg'), findsWidgets);
    await tapText(tester, '保存');
    expect(find.text('记录体重'), findsNothing);
    expect(controller.latestWeight?.weightKg, closeTo(4.30, 0.001));

    final again = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 11),
    );
    await again.init();
    expect(again.latestWeight?.weightKg, closeTo(4.30, 0.001));

    await tapText(tester, '健康');
    await revealText(tester, '4.30 kg');
    await tapText(tester, '4.30 kg');
    expect(find.text('记录体重'), findsOneWidget);
    Navigator.of(tester.element(find.text('记录体重'))).pop();
    await frames(tester);

    final row = find.ancestor(
      of: find.text('4.30 kg'),
      matching: find.byType(ListTile),
    );
    await tester.ensureVisible(row);
    await tester.tap(
      find.descendant(of: row, matching: find.byIcon(Icons.delete_outline)),
    );
    await frames(tester);
    await tapText(tester, '删除');
    expect(controller.latestWeight?.weightKg, 4.35);
  });

  testWidgets('health records can be added, opened, and deleted', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '健康');
    expect(find.text('疫苗'), findsWidgets);

    await tapText(tester, '添加');
    await enterField(tester, '名称', '狂犬');
    await tapText(tester, '保存');
    expect(find.text('狂犬'), findsOneWidget);
    await tapText(tester, '狂犬');
    expect(find.text('编辑疫苗'), findsOneWidget);
    await tapText(tester, '保存');
    await deleteRow(tester, '狂犬');
    expect(find.text('狂犬'), findsNothing);

    await tapText(tester, '添加', index: 1);
    await enterField(tester, '药品名称', '测试驱虫');
    await tapText(tester, '保存');
    expect(find.textContaining('测试驱虫'), findsOneWidget);
    await deleteRow(tester, '测试驱虫');

    await tapText(tester, '添加', index: 2);
    await enterField(tester, '原因', '复诊观察');
    await tapText(tester, '保存');
    expect(find.text('复诊观察'), findsOneWidget);
    await tapText(tester, '复诊观察');
    expect(find.text('编辑就医'), findsOneWidget);
    Navigator.of(tester.element(find.text('编辑就医'))).pop();
    await frames(tester);
    await deleteRow(tester, '复诊观察');
  });

  testWidgets('pantry dates, catalog search, and unknown barcode persist', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '我的');
    await tapText(tester, '粮仓');
    await tapText(tester, '查看并修改日期');
    expect(find.text('这袋粮'), findsOneWidget);
    await tapText(tester, '填入示例 GS1 日期');
    await tapText(tester, '采用');
    await tapText(tester, '保存日期');
    expect(find.textContaining('2025年10月12日'), findsOneWidget);
    expect(find.textContaining('2027年4月12日'), findsOneWidget);

    await tapText(tester, '扫描 GS1 日期码');
    expect(find.text('使用这段内容'), findsOneWidget);
    await enter(tester, find.byType(TextField).last, '');
    await tapText(tester, '使用这段内容');
    expect(find.text('先扫到一条内容，或在下面输入'), findsOneWidget);
    await enter(
      tester,
      find.byType(TextField).last,
      '(11)251012(17)270412(10)DEMO',
    );
    await tapText(tester, '使用这段内容');
    await tapText(tester, '采用');
    expect(find.textContaining('DEMO'), findsWidgets);

    await back(tester);
    await tapText(tester, '网易严选 浓汤大口肉罐');
    await tapText(tester, '标记已开封');
    expect(find.textContaining('已开封'), findsWidgets);
    expect(
      controller.pantry.any(
        (item) =>
            item.product.name.contains('浓汤') && item.item.openedAt != null,
      ),
      isTrue,
    );

    await back(tester);
    await tapText(tester, '图鉴');
    await enter(tester, find.byType(TextField).last, '不存在的牌子xyz');
    expect(find.text('没有这款'), findsOneWidget);
    await enter(tester, find.byType(TextField).last, '幼猫慕斯');
    await tapText(tester, '皇家 Royal Canin 幼猫慕斯罐');
    await revealText(tester, '登记到粮仓');
    expect(find.text('登记到粮仓'), findsOneWidget);
    await back(tester);

    await tapText(tester, '扫条码');
    await enter(tester, find.byType(TextField).last, '6900000000000');
    await tapText(tester, '使用这段内容');
    expect(find.text('添加猫粮'), findsOneWidget);
    expect(find.textContaining('6900000000000'), findsOneWidget);
    await tapText(tester, '保存并登记');
    expect(find.text('品牌和名称都要填'), findsOneWidget);
    await enterField(tester, '品牌', '自有品牌');
    await enterField(tester, '名称', '测试粮');
    await tapText(tester, '保存并登记');
    expect(find.text('这袋粮'), findsOneWidget);
    expect(controller.findBarcode('6900000000000')?.name, '测试粮');
  });

  testWidgets('profile, cat form, and remaining actions work', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '我的');
    await tapText(tester, '橘座');
    expect(find.text('记录天数'), findsOneWidget);
    await tapText(tester, '编辑资料');
    expect(find.text('名字'), findsOneWidget);
    await back(tester);
    await tapText(tester, '体重');
    expect(find.text('记体重'), findsOneWidget);

    await tapText(tester, '我的');
    await tapText(tester, '编辑资料');
    expect(find.text('名字'), findsOneWidget);
    await back(tester);
    await tapText(tester, '添加');
    expect(find.text('新的猫咪'), findsOneWidget);
    await tapText(tester, '保存');
    expect(find.text('先写一个名字'), findsOneWidget);
    await tapText(tester, '拍照');
    expect(find.text('新的猫咪'), findsOneWidget);
    expect(find.textContaining('没有打开相机或相册'), findsWidgets);
    await enterField(tester, '名字', '小黑');
    await tapText(tester, '保存');
    expect(find.text('先拍一张，或点示例图'), findsOneWidget);
    await tapText(tester, '先用示例图');
    await tapText(tester, '保存');
    expect(find.text('小黑'), findsWidgets);
    expect(controller.cats.any((item) => item.name == '小黑'), isTrue);
    await tapText(tester, '删除这只猫');
    await tapText(tester, '取消');
    expect(controller.cats.any((item) => item.name == '小黑'), isTrue);
    await tapText(tester, '删除这只猫');
    await tapText(tester, '删除');
    expect(controller.cats.any((item) => item.name == '小黑'), isFalse);

    await tapText(tester, '今天');
    await tapText(tester, '健康');
    await tapText(tester, '添加');
    expect(find.text('添加疫苗'), findsOneWidget);
    await enterField(tester, '名称', '');
    await tapText(tester, '保存');
    expect(find.text('先写疫苗名称'), findsOneWidget);
    Navigator.of(tester.element(find.text('添加疫苗'))).pop();
    await frames(tester);

    await tapText(tester, '添加', index: 1);
    expect(find.text('添加驱虫'), findsOneWidget);
    Navigator.of(tester.element(find.text('添加驱虫'))).pop();
    await frames(tester);

    await tapText(tester, '添加', index: 2);
    expect(find.text('就医记录'), findsOneWidget);
    Navigator.of(tester.element(find.text('就医记录'))).pop();
    await frames(tester);

    await tapText(tester, '记体重');
    expect(find.text('记录体重'), findsOneWidget);
    Navigator.of(tester.element(find.text('记录体重'))).pop();
    await frames(tester);

    await tapText(tester, '今天');
    await tapText(tester, '扫条码');
    expect(find.text('扫描商品条码'), findsOneWidget);
    await back(tester);
    await tapText(tester, '健康');
    await tapText(tester, '慢性肾病');
    await revealText(tester, '记饮水');
    await tapText(tester, '记饮水');
    expect(find.text('记录饮水'), findsOneWidget);
  });
}
