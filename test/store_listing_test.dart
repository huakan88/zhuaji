import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/app.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';
import 'cjk_font.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots are 1080x1920', (tester) async {
    await tester.runAsync(loadZhuajiFonts);
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.4;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
    await tester.pumpWidget(ZhuajiApp(controller: controller));
    await frames(tester);
    await _shot(tester, '00-consent');

    await tester.tap(find.text('不同意，仅用基本功能'));
    await frames(tester);
    await _shot(tester, '01-today');
    await tapText(tester, '健康');
    await _shot(tester, '02-health');
    await tapText(tester, '粮仓');
    await _shot(tester, '03-pantry');
    await tapText(tester, '猫咪');
    await _shot(tester, '04-cats');
  });
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('shot')),
    );
    final image = await boundary.toImage(pixelRatio: 2.4);
    expect(image.width, 1080, reason: name);
    expect(image.height, 1920, reason: name);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/store-listing/screenshots/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}
