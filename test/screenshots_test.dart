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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController(
      repo: DriftCareRepository(AppDatabase.memory()),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
    await tester.pumpWidget(ZhuajiApp(controller: controller));
    await _frames(tester);
    await _shot(tester, 'home');

    await tester.tap(find.text('健康').last);
    await _frames(tester);
    await _shot(tester, 'health');

    await tester.tap(find.text('粮仓').last);
    await _frames(tester);
    await _shot(tester, 'pantry');

    await tester.tap(find.text('查看并修改日期').first);
    await _frames(tester);
    await _shot(tester, 'food');

    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    await tester.tap(find.text('我的'));
    await _frames(tester);
    await _shot(tester, 'cats');

    await tester.tap(find.text('橘座'));
    await _frames(tester);
    await _shot(tester, 'profile');
  });
}

Future<void> _frames(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('shot')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('/opt/cursor/artifacts/screenshots/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}
