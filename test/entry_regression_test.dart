import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/widgets/common.dart';
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

  testWidgets('home menu, diary, nav, and quick-add water open', (
    tester,
  ) async {
    await boot(tester, controller);

    await tapText(tester, '橘座');
    await tapText(tester, '添加猫咪');
    expect(find.text('新的猫咪'), findsOneWidget);
    await tapText(tester, '生日');
    expect(find.text('取消'), findsWidgets);
    await tapText(tester, '取消');
    expect(find.text('新的猫咪'), findsOneWidget);
    final neuter = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, '已绝育'),
    );
    expect(neuter.onChanged, isNotNull);
    await back(tester);

    await revealText(tester, '全部');
    final pageScroll = tester.state<ScrollableState>(downScrollables().first);
    for (
      var step = 0;
      step < 6 &&
          find
              .ancestor(
                of: find.byType(CatImage),
                matching: find.byType(GestureDetector),
              )
              .evaluate()
              .isEmpty;
      step++
    ) {
      pageScroll.position.jumpTo(
        (pageScroll.position.pixels + 180).clamp(
          0,
          pageScroll.position.maxScrollExtent,
        ),
      );
      await tester.pump();
    }
    final diary = find.ancestor(
      of: find.byType(CatImage),
      matching: find.byType(GestureDetector),
    );
    expect(diary, findsWidgets);
    tester.widget<GestureDetector>(diary.first).onTap?.call();
    await frames(tester);
    expect(find.textContaining('的体态'), findsOneWidget);
    await back(tester);

    await tapText(tester, '首页');
    await tapText(tester, '粮仓');
    expect(find.text('在库'), findsOneWidget);
    await tapText(tester, '我的');
    expect(find.text('体检建议'), findsOneWidget);

    await tapText(tester, '首页');
    await tester.tap(find.byType(PawIcon).last);
    await frames(tester);
    await tapText(tester, '记饮水');
    expect(find.text('记录饮水'), findsOneWidget);
    await enterField(tester, '大约喝了多少毫升', '0');
    await tapText(tester, '保存');
    expect(find.text('饮水量请填 1 到 2000 毫升'), findsOneWidget);
    await enterField(tester, '大约喝了多少毫升', '40');
    await tapText(tester, '保存');
    expect(controller.todayWaterMl, 220);
  });

  testWidgets('me, profile, checkup delete, and recheck date work', (
    tester,
  ) async {
    await boot(tester, controller);
    await tapText(tester, '我的');
    await tapText(tester, '体检建议');
    expect(find.textContaining('的体检'), findsOneWidget);
    expect(find.text('仅供参考，请遵医嘱。'), findsWidgets);
    await revealText(tester, '删除最近一条');
    await tapText(tester, '删除最近一条');
    await tapText(tester, '删除');
    expect(
      controller.catCheckups.where((item) => item.itemId == 'cbc'),
      isEmpty,
    );
    await back(tester);

    await tapText(tester, '疾病养护');
    expect(find.text('搜索疾病'), findsOneWidget);
    await tapText(tester, '慢性肾病');
    expect(find.text('需要立即就医'), findsOneWidget);
    await tapText(tester, '改复查日');
    expect(find.text('确定'), findsOneWidget);
    await tapText(tester, '确定');
    expect(find.textContaining('复查日已改成'), findsOneWidget);
    await back(tester);
    await back(tester);

    await tapText(tester, '当前档案');
    expect(find.text('记录天数'), findsOneWidget);
    await tapText(tester, '慢性肾病');
    expect(find.text('饮食'), findsOneWidget);
    await back(tester);
    await tapText(tester, '体检建议');
    expect(find.textContaining('成年'), findsWidgets);
    await back(tester);
    await tapText(tester, '疾病养护');
    expect(find.text('糖尿病'), findsOneWidget);
    await back(tester);
    await tapText(tester, '体态对比');
    expect(find.text('再拍一张'), findsOneWidget);
  });

  testWidgets(
    'pantry manual date, photo date, removal, and reminder cards work',
    (tester) async {
      await boot(tester, controller);
      await tapText(tester, '粮仓');
      await tapText(tester, '查看并修改日期');
      final before = controller.pantry.length;

      await tapText(tester, '拍摄印刷日期');
      expect(find.text('从相册选择'), findsOneWidget);
      await tapText(tester, '拍照');
      expect(find.textContaining('没有打开相机或相册'), findsWidgets);

      await tapText(tester, '手动填写日期');
      expect(find.text('确定'), findsOneWidget);
      await tapText(tester, '确定');
      expect(find.text('确定'), findsOneWidget);
      await tapText(tester, '确定');
      expect(find.text('确认日期'), findsOneWidget);
      expect(find.textContaining('生产：'), findsOneWidget);
      expect(find.textContaining('保质期：'), findsOneWidget);
      await tapText(tester, '采用');
      expect(find.text('保存日期'), findsOneWidget);

      await tapText(tester, '移出粮仓');
      await tapText(tester, '取消');
      expect(controller.pantry, hasLength(before));
      await tapText(tester, '移出粮仓');
      await tapText(tester, '删除');
      expect(controller.pantry, hasLength(before - 1));
      expect(find.text('在库'), findsOneWidget);

      await tapText(tester, '我的');
      await tapText(tester, '喂养');
      await tapText(tester, '结束这次换粮');
      await tapText(tester, '删除');
      await tester.tap(find.byType(Switch).at(0));
      await frames(tester);
      await tester.tap(find.byType(Switch).at(1));
      await frames(tester);
      await back(tester);
      await tapText(tester, '提醒');
      await revealText(tester, '橘座的驱虫提醒');
      await tapText(tester, '橘座的驱虫提醒');
      expect(find.text('成长'), findsWidgets);
      await tapText(tester, '首页');
      await tapText(tester, '橘座');
      await tapText(tester, '奶油');
      await tapText(tester, '我的');
      await tapText(tester, '喂养');
      await tester.tap(find.byType(Switch).at(0));
      await frames(tester);
      await tester.tap(find.byType(Switch).at(1));
      await frames(tester);
      await back(tester);
      await tapText(tester, '提醒');
      await revealText(tester, '猫粮即将到期');
      await tapText(tester, '猫粮即将到期');
      expect(find.text('在库'), findsOneWidget);
    },
  );
}
