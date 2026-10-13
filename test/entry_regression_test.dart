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

  testWidgets('home menu, diary, nav, and quick-add water open', (
    tester,
  ) async {
    await boot(tester, controller);

    await tapText(tester, '橘座');
    await tapText(tester, '添加猫咪');
    expect(find.text('建档'), findsOneWidget);
    await tapText(tester, '更多');
    await tapText(tester, '生日');
    expect(find.text('取消'), findsWidgets);
    await tapText(tester, '取消');
    expect(find.text('建档'), findsOneWidget);
    expect(find.text('已绝育'), findsOneWidget);
    await tapText(tester, '已绝育');
    await back(tester);

    await tapText(tester, '我的');
    await tapText(tester, '粮仓');
    expect(find.text('在库'), findsOneWidget);
    await back(tester);

    await tapText(tester, '健康');
    await tapText(tester, '养护');
    await tapText(tester, '慢性肾病');
    await revealText(tester, '记饮水');
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
    await tapText(tester, '健康');
    await tapText(tester, '体检');
    expect(find.text('体检'), findsWidgets);
    await revealText(tester, '仅供参考，请遵医嘱。');
    expect(find.text('仅供参考，请遵医嘱。'), findsWidgets);
    await revealText(tester, '删除最近一条');
    await tapText(tester, '删除最近一条');
    await tapText(tester, '删除');
    expect(
      controller.catCheckups.where((item) => item.itemId == 'cbc'),
      isEmpty,
    );
    await back(tester);

    await tapText(tester, '养护');
    expect(find.text('搜索'), findsOneWidget);
    await tapText(tester, '慢性肾病');
    expect(find.text('需要立即就医'), findsOneWidget);
    await tapText(tester, '改复查日');
    expect(find.text('确定'), findsOneWidget);
    await tapText(tester, '确定');
    expect(find.textContaining('复查日已改成'), findsOneWidget);
    await back(tester);
    await back(tester);

    await tapText(tester, '我的');
    await tapText(tester, '橘座');
    expect(find.text('记录天数'), findsOneWidget);
    await back(tester);
    await tapText(tester, '健康');
    await tapText(tester, '养护');
    await tapText(tester, '看其他疾病');
    expect(find.text('糖尿病'), findsOneWidget);
  });

  testWidgets(
    'pantry manual date, photo date, removal, and reminder cards work',
    (tester) async {
      await boot(tester, controller);
      await tapText(tester, '我的');
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
      await back(tester);

      await tapText(tester, '今天');
      await tapText(tester, '驱虫');
      expect(find.text('记体重'), findsOneWidget);
      await tapText(tester, '今天');
      await tapText(tester, '橘座');
      await tapText(tester, '奶油');
      await tapText(tester, '临期猫粮');
      expect(find.text('在库'), findsOneWidget);
    },
  );
}
