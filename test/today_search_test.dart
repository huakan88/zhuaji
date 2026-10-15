import 'package:flutter/material.dart';
import 'package:maokangji/features/home/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
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

  testWidgets('today search matches pinyin and groups the hits', (
    tester,
  ) async {
    await boot(tester, controller);
    expect(find.byTooltip('扫码'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == '猫咪、粮、记录',
      ),
      findsOneWidget,
    );

    await enter(tester, find.byType(TextField), 'jz');
    expect(find.text('猫咪'), findsWidgets);
    expect(find.text('橘座'), findsOneWidget);
    await tapText(tester, '橘座');
    expect(find.text('保存'), findsWidgets);

    await back(tester);
    final homeList = find.descendant(
      of: find.byType(HomePage),
      matching: find.byType(Scrollable),
    );
    tester.state<ScrollableState>(homeList.first).position.jumpTo(0);
    await tester.pump();
    await enter(tester, find.byType(TextField), '');
    expect(find.text('jz'), findsOneWidget);

    await enter(tester, find.byType(TextField), '猫');
    expect(find.text('粮仓'), findsWidgets);
    expect(find.text('猫粮库'), findsOneWidget);
    await revealText(tester, '猫三联');
    expect(find.text('疫苗'), findsWidgets);
    expect(find.text('猫三联'), findsWidgets);
  });

  testWidgets('a built-in code shows the local card, not a cached name', (
    tester,
  ) async {
    await controller.saveBarcodeRecord(
      const BarcodeRecord(
        code: '3182550799669',
        found: true,
        brand: 'Royal Canin',
        name: 'Neutered Satiety Balance',
        quantity: '12 kg',
        ingredients: 'cached ingredients that must not win',
        nutrients: [BarcodeNutrient(label: '粗蛋白', text: '1 %')],
        source: 'openpetfoodfacts',
      ),
    );
    await boot(tester, controller, location: '/lookup?code=3182550799669');
    expect(find.text('皇家'), findsOneWidget);
    expect(find.text('Neutered Satiety Balance'), findsOneWidget);
    expect(find.text('12千克'), findsOneWidget);
    expect(find.textContaining('Protéines'), findsOneWidget);
    expect(find.text('粗蛋白'), findsOneWidget);
    expect(find.text('35 %'), findsOneWidget);
    expect(find.text('1 %'), findsNothing);
    expect(find.text('收进粮仓'), findsOneWidget);
    expect(find.textContaining('本机常见猫粮'), findsOneWidget);
  });

  testWidgets('a domestic library hit shows brand, name and spec', (
    tester,
  ) async {
    controller.barcodeFetch = (_) async {
      fail('a local hit must not ask the network');
    };
    await boot(tester, controller, location: '/lookup?code=6958862134620');
    expect(find.text('麦富迪'), findsOneWidget);
    expect(find.text('三文鱼双拼全价全期猫粮'), findsOneWidget);
    expect(find.text('2千克'), findsOneWidget);
    expect(find.text('6958862134620'), findsOneWidget);
    expect(find.text('配料'), findsNothing);
    expect(find.text('成分'), findsNothing);
    expect(find.textContaining('本机常见猫粮'), findsOneWidget);
    expect(find.text('收进粮仓'), findsOneWidget);
  });

  testWidgets('a hit hides ingredients and analysis when the source has none', (
    tester,
  ) async {
    await controller.saveBarcodeRecord(
      const BarcodeRecord(
        code: '6970000000000',
        found: true,
        brand: 'Royal Canin',
        name: 'Neutered Satiety Balance',
        quantity: '12 kg',
        ingredients: '',
        nutrients: [],
        source: 'productguru',
        sourceUrl: 'https://myproduct.guru/p/3182550799669',
      ),
    );
    await boot(tester, controller, location: '/lookup?code=6970000000000');
    expect(find.text('Royal Canin'), findsOneWidget);
    expect(find.text('配料'), findsNothing);
    expect(find.text('成分'), findsNothing);
    expect(find.textContaining('Data: ProductGuru'), findsOneWidget);
  });

  testWidgets('an unknown domestic code offers a photo or a brand', (
    tester,
  ) async {
    controller.barcodeFetch = (call) async {
      if (call.uri.host.contains('upcitemdb')) {
        return const BarcodeResponse(200, '{"code":"OK","total":0,"items":[]}');
      }
      return const BarcodeResponse(404, '{"status":0}');
    };
    await boot(tester, controller, location: '/lookup?code=6970000000000');
    expect(find.text('公开库里没有这款'), findsOneWidget);
    expect(find.textContaining('国产粮'), findsOneWidget);
    expect(find.text('拍包装识别'), findsOneWidget);
    expect(find.text('选品牌'), findsOneWidget);

    await tapText(tester, '选品牌');
    expect(find.text('先选品牌'), findsOneWidget);
    expect(find.text('室内成猫干粮'), findsNothing);
  });
}
