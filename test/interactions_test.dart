import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/widgets/paw_icon.dart';
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
    await revealText(tester, '最近 4.35 kg');
    expect(find.text('最近 4.35 kg'), findsOneWidget);
    expect(controller.catFeedings.any((item) => item.foodName.contains('皇家')), isTrue);

    await tapText(tester, '橘座');
    await tapText(tester, '奶油');

    expect(controller.active?.name, '奶油');
    await revealText(tester, '最近 4.05 kg');
    expect(find.text('最近 4.05 kg'), findsOneWidget);
    expect(find.text('最近 4.35 kg'), findsNothing);
    expect(controller.catFeedings.where((item) => item.foodName.contains('皇家')), isEmpty);
    expect(controller.photos.every((item) => item.catId == controller.activeCatId), isTrue);
  });

  testWidgets('home cards, bell, diary and quick actions open real pages', (tester) async {
    await boot(tester, controller);

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await frames(tester);
    expect(find.text('开启通知权限'), findsOneWidget);
    await back(tester);

    await tapText(tester, '全部');
    expect(find.textContaining('的体态'), findsOneWidget);
    await tapText(tester, '再拍一张');
    expect(find.text('从相册选择'), findsOneWidget);
    await tapText(tester, '拍照');
    expect(find.textContaining('没有拿到照片'), findsOneWidget);
    await back(tester);

    await tapText(tester, '驱虫');
    expect(find.text('成长'), findsOneWidget);
    await tapText(tester, '首页');

    await tapText(tester, '临期猫粮');
    expect(find.text('在库'), findsOneWidget);
    await tapText(tester, '首页');

    await tapText(tester, '下次疫苗');
    expect(find.text('体重趋势'), findsOneWidget);
    await tapText(tester, '首页');

    await tapText(tester, '喂食');
    expect(find.text('记一餐'), findsOneWidget);
    await back(tester);

    await tapText(tester, '健康');
    expect(find.text('已经一起'), findsOneWidget);
    await tapText(tester, '首页');

    await tapText(tester, '扫码');
    expect(find.text('使用这段内容'), findsOneWidget);
    await back(tester);
  });

  testWidgets('weight sheet validates, persists, and can be deleted', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '体重');
    expect(find.text('记录体重'), findsOneWidget);
    await enter(tester, find.byType(TextField).last, '0');
    await tapText(tester, '保存');
    expect(find.text('请填写 0 到 20 kg 之间的体重'), findsOneWidget);

    await enter(tester, find.byType(TextField).last, '4.20');
    await tapText(tester, '保存');
    expect(find.text('记录体重'), findsNothing);
    expect(controller.latestWeight?.weightKg, 4.2);

    final again = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 11),
    );
    await again.init();
    expect(again.latestWeight?.weightKg, 4.2);

    await tapText(tester, '健康');
    await tapText(tester, '4.20 kg');
    expect(find.text('记录体重'), findsOneWidget);
    Navigator.of(tester.element(find.text('记录体重'))).pop();
    await frames(tester);

    final row = find.ancestor(of: find.text('4.20 kg'), matching: find.byType(ListTile));
    await tester.ensureVisible(row);
    await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.delete_outline)));
    await frames(tester);
    await tapText(tester, '删除');
    expect(controller.latestWeight?.weightKg, 4.35);
  });

  testWidgets('health records and notes can be added, opened, and deleted', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '健康', index: 1);
    await tapText(tester, '互动');
    await tapText(tester, '今日喂食');
    expect(find.text('记一餐'), findsOneWidget);
    await back(tester);
    await tapText(tester, '健康', index: 1);
    await tapText(tester, '互动');
    await tapText(tester, '一周体重');
    expect(find.text('记录体重'), findsOneWidget);
    Navigator.of(tester.element(find.text('记录体重'))).pop();
    await frames(tester);
    await tapText(tester, '疫苗日期');
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

    await tapText(tester, '互动');
    await tapText(tester, '写一条');
    await enter(tester, find.byType(TextField).last, '');
    await tapText(tester, '保存');
    expect(find.text('先写一点内容'), findsOneWidget);
    await enter(tester, find.byType(TextField).last, '精神很好');
    await tapText(tester, '保存');
    await tapText(tester, '精神很好');
    expect(find.text('这条笔记'), findsOneWidget);
    await tapText(tester, '关闭');
    await deleteRow(tester, '精神很好');
    expect(controller.catNotes.any((item) => item.content == '精神很好'), isFalse);

    await tapText(tester, '去记喂食');
    expect(find.text('热量估算'), findsOneWidget);
  });

  testWidgets('feeding meal, reminder, and transition persist', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '喂食');
    await tapText(tester, '记一餐');
    await enterField(tester, '食物名称', '午饭罐头');
    await tapText(tester, '保存');
    expect(find.textContaining('午饭罐头'), findsOneWidget);
    expect(controller.catFeedings.any((item) => item.foodName == '午饭罐头'), isTrue);
    final mealTitle = find.textContaining('午饭罐头').first;
    await tester.ensureVisible(mealTitle);
    await tester.tap(mealTitle);
    await frames(tester);
    expect(find.text('这餐记录'), findsOneWidget);
    await tapText(tester, '关闭');

    final meal = find.ancestor(of: find.textContaining('午饭罐头'), matching: find.byType(ListTile));
    await tester.tap(find.descendant(of: meal, matching: find.byIcon(Icons.delete_outline)));
    await frames(tester);
    await tapText(tester, '删除');
    expect(controller.catFeedings.any((item) => item.foodName == '午饭罐头'), isFalse);

    final before = controller.remindersFor(controller.activeCatId!).first.enabled;
    await tester.tap(find.byType(Switch).first);
    await frames(tester);
    expect(controller.remindersFor(controller.activeCatId!).first.enabled, isNot(before));

    await tapText(tester, '调整早餐时间');
    expect(find.text('取消'), findsWidgets);
    await tapText(tester, '取消');

    expect(find.text('结束这次换粮'), findsOneWidget);
    await tapText(tester, '结束这次换粮');
    await tapText(tester, '取消');
    expect(controller.activeTransition, isNotNull);
    await tapText(tester, '结束这次换粮');
    await tapText(tester, '删除');
    expect(controller.activeTransition, isNull);
    expect(find.text('开始 7 天换粮'), findsOneWidget);

    await tapText(tester, '开始 7 天换粮');
    await enterField(tester, '原来的粮', '');
    await tapText(tester, '开始');
    expect(find.text('两种粮的名字都要填'), findsOneWidget);

    await tapText(tester, '开始 7 天换粮');
    await enterField(tester, '原来的粮', '旧粮');
    await enterField(tester, '新的粮', '新粮');
    await tapText(tester, '开始');
    expect(find.textContaining('第 1 天'), findsOneWidget);
    expect(controller.activeTransition?.toFood, '新粮');
  });

  testWidgets('pantry dates, catalog search, and unknown barcode persist', (tester) async {
    await boot(tester, controller);
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
    await enter(tester, find.byType(TextField).last, '(11)251012(17)270412(10)DEMO');
    await tapText(tester, '使用这段内容');
    await tapText(tester, '采用');
    expect(find.textContaining('DEMO'), findsWidgets);

    await back(tester);
    await tapText(tester, '网易严选 浓汤大口肉罐');
    await tapText(tester, '标记已开封');
    expect(find.textContaining('已开封'), findsWidgets);
    expect(
      controller.pantry.any((item) => item.product.name.contains('浓汤') && item.item.openedAt != null),
      isTrue,
    );

    await back(tester);
    await tapText(tester, '图鉴');
    await enter(tester, find.byType(TextField).last, '不存在的牌子xyz');
    expect(find.text('没有这款'), findsOneWidget);
    await enter(tester, find.byType(TextField).last, '幼猫慕斯');
    await tapText(tester, '皇家 Royal Canin 幼猫慕斯罐');
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

  testWidgets('reminders, profile, cat form, and quick-add actions work', (tester) async {
    await boot(tester, controller);
    await tapText(tester, '我的');
    await tapText(tester, '去看看');
    expect(find.text('开启通知权限'), findsOneWidget);
    await tester.tap(find.text('开启通知权限'));
    await frames(tester);
    expect(find.text('开启通知权限'), findsOneWidget);
    expect(find.textContaining('已请求通知权限'), findsOneWidget);
    final daily = find.textContaining('每天');
    expect(daily, findsWidgets);
    final card = find.ancestor(of: daily.first, matching: find.byType(InkWell));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await frames(tester);
    final onFeeding = find.textContaining('的喂养').evaluate().isNotEmpty;
    expect(onFeeding || find.text('首页').evaluate().isNotEmpty, isTrue);
    if (onFeeding) await back(tester);
    if (find.byTooltip('返回').evaluate().isNotEmpty) await back(tester);
    await tapText(tester, '我的');
    await tapText(tester, '喂养');
    expect(find.text('七日换粮'), findsOneWidget);
    await back(tester);
    await tapText(tester, '体态对比');
    expect(find.textContaining('的体态'), findsOneWidget);
    await tapText(tester, '查看');
    expect(find.text('体态照片'), findsWidgets);
    await tapText(tester, '关闭');
    await back(tester);
    await tapText(tester, '当前档案');
    expect(find.text('记录天数'), findsOneWidget);
    await tapText(tester, '编辑资料');
    expect(find.text('编辑资料'), findsWidgets);
    await back(tester);
    await tapText(tester, '体重');
    expect(find.text('成长'), findsOneWidget);

    await tapText(tester, '我的');
    await tapText(tester, '编辑');
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
    expect(find.text('小黑'), findsWidgets);
    expect(controller.cats.any((item) => item.name == '小黑'), isTrue);
    await tapText(tester, '删除这只猫');
    await tapText(tester, '取消');
    expect(controller.cats.any((item) => item.name == '小黑'), isTrue);
    await tapText(tester, '删除这只猫');
    await tapText(tester, '删除');
    expect(controller.cats.any((item) => item.name == '小黑'), isFalse);

    await tapText(tester, '首页');
    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    for (final label in ['记喂食', '记体重', '扫条码', '记疫苗', '记驱虫', '记就医', '写笔记', '开始换粮', '记饮水']) {
      expect(find.text(label), findsOneWidget);
    }
    await tapText(tester, '记疫苗');
    expect(find.text('添加疫苗'), findsOneWidget);
    await enterField(tester, '名称', '');
    await tapText(tester, '保存');
    expect(find.text('先写疫苗名称'), findsOneWidget);
    Navigator.of(tester.element(find.text('添加疫苗'))).pop();
    await frames(tester);

    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '记驱虫');
    expect(find.text('添加驱虫'), findsOneWidget);
    Navigator.of(tester.element(find.text('添加驱虫'))).pop();
    await frames(tester);

    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '记就医');
    expect(find.text('就医记录'), findsOneWidget);
    Navigator.of(tester.element(find.text('就医记录'))).pop();
    await frames(tester);

    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '写笔记');
    expect(find.text('健康笔记'), findsOneWidget);
    Navigator.of(tester.element(find.text('健康笔记'))).pop();
    await frames(tester);

    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '记体重');
    expect(find.text('记录体重'), findsOneWidget);
    Navigator.of(tester.element(find.text('记录体重'))).pop();
    await frames(tester);

    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '扫条码');
    expect(find.text('扫描商品条码'), findsOneWidget);
    await back(tester);

    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '开始换粮');
    expect(find.text('七日换粮'), findsOneWidget);
  });
}
