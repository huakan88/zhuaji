import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/copy.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/features/pantry/scan_page.dart';
import 'package:maokangji/services/barcode_share.dart';
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

  test('a search miss tells a barcode, a bad digit and a link apart', () {
    expect(scanRejectHint('6958862134621'), '校验没通过，再对一下末位');
    expect(scanRejectHint('6958862134620'), isNull);
    expect(scanRejectHint('https://example.com'), isNull);

    final barcode = searchMissFor('6900000000007', remembered: false);
    expect(barcode.title, '没有找到');
    expect(barcode.lookup, isTrue);
    expect(barcode.action, '查这个条码');

    final digit = searchMissFor('6958862134621', remembered: false);
    expect(digit.title, '末位对不上');
    expect(digit.lookup, isFalse);

    final link = searchMissFor(
      'https://example.com/not-a-product',
      remembered: false,
    );
    expect(link.title, '这不是猫粮条码');
    expect(link.action, '扫码');

    expect(shareQueueNotice(0), isEmpty);
    expect(shareQueueNotice(2), contains('2 条'));
    expect(shareQueueNotice(2), contains('联网后会自动提交'));
  });

  testWidgets('a word miss and a bad barcode say what to do next', (
    tester,
  ) async {
    await boot(tester, controller, location: '/home');
    await enter(tester, find.byType(TextField), '没有这只猫');
    await frames(tester);
    expect(find.text('没有找到'), findsOneWidget);
    expect(find.text('可以手写品牌、名称和规格并保存，或扫包装上的条码。'), findsOneWidget);
    expect(find.text('自己添加'), findsOneWidget);

    await enter(tester, find.byType(TextField), '6958862134621');
    await frames(tester);
    expect(find.text('末位对不上'), findsOneWidget);
    expect(find.text('扫码'), findsOneWidget);
    expect(find.text('查这个条码'), findsNothing);
  });

  testWidgets('an unrelated code does not pretend a food matched', (
    tester,
  ) async {
    expect(
      await scanDestination(controller, 'https://example.com/not-a-product'),
      '/confirm?plain=1',
    );
    await boot(tester, controller, location: '/confirm?plain=1');
    expect(find.textContaining('这不是猫粮条码'), findsOneWidget);
    expect(find.text('先选品牌'), findsOneWidget);
    expect(find.text('认得这个码'), findsNothing);
    expect(find.text('室内成猫干粮'), findsNothing);
  });

  testWidgets('recording the last vaccine twice the same day keeps one', (
    tester,
  ) async {
    await boot(tester, controller, location: '/health');
    final before = controller.catVaccines.length;
    await tapText(tester, '今天再记 猫三联');
    expect(controller.catVaccines, hasLength(before + 1));
    expect(find.text('今天已经记过猫三联'), findsOneWidget);
    await tapText(tester, '今天已经记过猫三联');
    expect(controller.catVaccines, hasLength(before + 1));
    expect(find.text('今天已经记过猫三联'), findsWidgets);
  });

  testWidgets('sex and a birthday sit on the cat page', (tester) async {
    await boot(tester, controller, location: '/cats');
    expect(controller.active?.sex, CatSex.male);
    await tapText(tester, '母');
    expect(controller.active?.sex, CatSex.female);
    await tapText(tester, '年龄');
    expect(find.text('确定'), findsOneWidget);
    await tapText(tester, '确定');
    expect(controller.active?.birthday, isNotNull);

    await tapText(tester, '品种');
    expect(find.text('档案'), findsOneWidget);
    expect(find.text('已绝育'), findsOneWidget);
    expect(find.text('填写生日'), findsNothing);
  });

  testWidgets('a waiting share is visible on today', (tester) async {
    controller.shareQueue = [
      SharePending.waiting(
        const BarcodeRecord(
          code: '6900000000007',
          found: true,
          brand: '山野',
          name: '冻干',
          quantity: '1.5kg',
          ingredients: '',
          nutrients: [],
          source: 'user',
        ),
        DateTime.utc(2026, 10, 12),
      ),
    ];
    await boot(tester, controller, location: '/home');
    expect(find.textContaining('1 条条码修正还没发出去'), findsOneWidget);
    expect(find.textContaining('联网后会自动提交'), findsOneWidget);
  });

  testWidgets('saving the same weight does not add another row', (
    tester,
  ) async {
    await boot(tester, controller, location: '/weight');
    final before = controller.catWeights.length;
    expect(find.textContaining('今天已经记过'), findsOneWidget);
    await tapText(tester, '保存');
    expect(controller.catWeights, hasLength(before));
    expect(controller.latestWeight!.weightKg, closeTo(4.35, 0.001));
  });

  testWidgets('changing today\'s weight replaces that row', (tester) async {
    await boot(tester, controller, location: '/weight');
    final before = controller.catWeights.length;
    await tapText(tester, '重一点');
    await tapText(tester, '保存');
    expect(controller.catWeights, hasLength(before));
    expect(controller.latestWeight!.weightKg, closeTo(4.40, 0.001));
  });
}
