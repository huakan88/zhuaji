import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/widgets/weight_trend.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/care/care_story.dart';
import 'package:maokangji/domain/models.dart';
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

  CatProfile named(String name) =>
      controller.cats.firstWhere((cat) => cat.name == name);

  test('recent care is newest first and skips future dates', () {
    final orange = named('橘座');
    final events = recentCare(
      catId: orange.id,
      vaccines: controller.vaccines,
      deworms: controller.deworms,
      visits: controller.visits,
      checkups: controller.checkups,
      weights: controller.weights,
      now: controller.now,
    );
    expect(events.first.title, '称重');
    expect(events.first.detail, '4.35 kg');
    expect(events.map((event) => event.title), contains('驱虫'));
    for (var i = 1; i < events.length; i++) {
      expect(events[i - 1].on.isBefore(events[i].on), isFalse);
    }
    expect(events.length, lessThanOrEqualTo(4));
  });

  test('vet card lists weight, shots, deworming and the last visit', () {
    final orange = named('橘座');
    final card = vetCard(
      cat: orange,
      vaccines: controller.vaccines,
      deworms: controller.deworms,
      visits: controller.visits,
      weights: controller.weights,
      conditions: controller.conditions,
      now: controller.now,
    );
    expect(card, startsWith('橘座 的健康卡'));
    expect(card, contains('中华田园猫'));
    expect(card, contains('体重 4.35 kg'));
    expect(card, contains('-0.27 kg'));
    expect(card, contains('疫苗 猫三联'));
    expect(card, contains('下次 2026-10-30'));
    expect(card, contains('驱虫 体外 示例体外驱虫'));
    expect(card, contains('上次就医'));
    expect(card, contains('年度体检'));
    expect(card, contains('请遵医嘱'));
    expect(card, isNot(contains('奶油')));
  });

  test('trend label reads weeks and signed change', () {
    final orange = named('橘座');
    final points = controller.weights
        .where((item) => item.catId == orange.id)
        .toList();
    expect(trendLabel(points), '近 7 周 -0.27 kg');
    final cream = named('奶油');
    final creamPoints = controller.weights
        .where((item) => item.catId == cream.id)
        .toList();
    expect(trendLabel(creamPoints), '近 6 周 +0.25 kg');
  });

  test('due count is per cat', () {
    expect(controller.dueCountFor(named('橘座')), 4);
    expect(controller.dueCountFor(named('奶油')), 1);
  });

  testWidgets('today switches cats from the pills', (tester) async {
    await boot(tester, controller);
    expect(find.text('5 件'), findsOneWidget);
    expect(find.text('1 件'), findsOneWidget);
    await tapText(tester, '奶油');
    expect(controller.active?.name, '奶油');
    expect(find.text('4.05 kg'), findsWidgets);
  });

  testWidgets('cat page shows the trend and copies a health card', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await boot(tester, controller);
    await tapText(tester, '猫咪');
    expect(find.text('近 7 周 -0.27 kg'), findsOneWidget);
    expect(find.text('最近'), findsOneWidget);
    expect(find.text('称重 · 4.35 kg'), findsOneWidget);
    await tapText(tester, '复制健康卡');
    expect(copied, isNotNull);
    expect(copied, startsWith('橘座 的健康卡'));
    expect(find.text('已复制，可以发给医生'), findsOneWidget);
  });
}
