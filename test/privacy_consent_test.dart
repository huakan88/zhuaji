import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/app.dart';
import 'package:maokangji/core/consent_launch.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/services/barcode_share.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';
import 'cjk_font.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('launch plan waits for a choice', () {
    expect(planLaunch(null).showConsent, isTrue);
    expect(planLaunch(null).initNotifications, isFalse);
    expect(planLaunch(null).syncCloud, isFalse);
    expect(planLaunch('0').initNotifications, isFalse);
    expect(planLaunch('0').showConsent, isFalse);
    expect(planLaunch('1').initNotifications, isTrue);
    expect(planLaunch('1').syncCloud, isTrue);
    expect(planLaunch('1').showConsent, isFalse);
  });

  test('basic mode keeps the local catalog and skips the network', () async {
    final database = AppDatabase.memory();
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12),
    );
    await controller.init();
    await controller.useBasicMode();
    controller.shareClient = _BoomShare();
    controller.barcodeFetch = (_) async {
      fail('basic mode must not query a public database');
    };
    final local = await controller.resolveBarcode('6958862134620');
    expect(local.source, 'local');
    expect(local.brand, '麦富迪');
    final missing = await controller.resolveBarcode('6900000000007');
    expect(missing.found, isFalse);
    await controller.rememberUserBarcode(
      code: '6900000000007',
      brand: '自记',
      name: '不上传',
      spec: '1千克',
      ask: () async {
        fail('basic mode must not ask to publish');
      },
    );
    expect(controller.shareQueue, isEmpty);
    await database.close();
  });

  testWidgets('first launch can read the policy and stay local', (
    tester,
  ) async {
    await tester.runAsync(loadZhuajiFonts);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12),
    );
    var started = 0;
    controller.onFullAccess = () async {
      started += 1;
    };
    await tester.pumpWidget(ZhuajiApp(controller: controller));
    await frames(tester);
    expect(find.text('同意并继续'), findsOneWidget);
    expect(find.text('不同意，仅用基本功能'), findsOneWidget);
    expect(find.text('退出应用'), findsOneWidget);
    expect(find.text('橘座'), findsNothing);
    expect(started, 0);

    await tester.tap(find.text('隐私政策'));
    await frames(tester);
    expect(find.text('同意之前'), findsOneWidget);
    await tester.tap(find.text('返回'));
    await frames(tester);
    expect(find.text('用户协议'), findsOneWidget);

    await tester.tap(find.text('不同意，仅用基本功能'));
    await frames(tester);
    expect(find.text('橘座'), findsWidgets);
    expect(started, 0);
    expect(controller.privacyChoice, PrivacyChoice.basic);
    expect(await database.setting('privacyConsent'), '0');
  });

  testWidgets('accept starts services once and opens today', (tester) async {
    await tester.runAsync(loadZhuajiFonts);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12),
    );
    var started = 0;
    controller.onFullAccess = () async {
      started += 1;
    };
    await tester.pumpWidget(ZhuajiApp(controller: controller));
    await frames(tester);
    await tester.tap(find.text('同意并继续'));
    await frames(tester);
    expect(find.text('橘座'), findsWidgets);
    expect(started, 1);
    expect(controller.privacyChoice, PrivacyChoice.accepted);
    expect(await database.setting('notifAsked'), '1');
  });

  testWidgets('settings can withdraw consent and erase local data', (
    tester,
  ) async {
    await tester.runAsync(loadZhuajiFonts);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12),
    );
    await controller.init();
    await controller.acceptPrivacy();
    await tester.pumpWidget(
      ZhuajiApp(controller: controller, gateConsent: true),
    );
    await frames(tester);
    await tapText(tester, '猫咪');
    await revealText(tester, '撤回同意');
    await tapText(tester, '撤回同意');
    await tester.tap(find.widgetWithText(FilledButton, '撤回'));
    await frames(tester);
    expect(controller.privacyChoice, PrivacyChoice.basic);
    expect(find.textContaining('当前是基本功能'), findsOneWidget);

    await revealText(tester, '删除本机数据');
    await tapText(tester, '删除本机数据');
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await frames(tester);
    expect(controller.cats, isNotEmpty);

    await tapText(tester, '删除本机数据');
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await frames(tester);
    expect(find.text('同意并继续'), findsOneWidget);
    expect(controller.cats, isEmpty);
    expect(controller.privacyChoice, PrivacyChoice.unset);
  });
}

extension on AppDatabase {
  Future<String?> setting(String key) {
    return DriftCareRepository(this).setting(key);
  }
}

class _BoomShare implements BarcodeShareClient {
  @override
  Future<ShareConfig> config() async => ShareConfig.speaking;

  @override
  Future<ShareAnswer> lookup(String code) async {
    fail('basic mode must not query the share server');
  }

  @override
  Future<ShareAnswer> submit(BarcodeRecord record) async {
    fail('basic mode must not submit');
  }
}
