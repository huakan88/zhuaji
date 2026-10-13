import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/app.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'cjk_font.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (tester) async {
    await tester.runAsync(loadZhuajiFonts);
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
    await _shot(tester, 'today');

    await _tapOnScreen(tester, '猫');
    await _frames(tester);
    await _shot(tester, 'cat');

    await _tapOnScreen(tester, '体检');
    await _frames(tester);
    await _shot(tester, 'checkup');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '添加');
    await _frames(tester);
    await _shot(tester, 'onboard');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '今天');
    await _frames(tester);
    await _tapOnScreen(tester, '扫粮');
    await _frames(tester);
    await _shot(tester, 'scan');
  });
}

bool _hidden(Element element) {
  var hidden = false;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Offstage && widget.offstage) {
      hidden = true;
      return false;
    }
    if (widget.runtimeType.toString() == '_VisibilityScope') {
      final visible = (widget as dynamic).isVisible == true;
      if (!visible) {
        hidden = true;
        return false;
      }
    }
    return true;
  });
  return hidden;
}

Future<void> _tapOnScreen(WidgetTester tester, String text) async {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  Offset? target;
  for (final element in find.text(text).evaluate()) {
    if (_hidden(element)) continue;
    final box = element.renderObject;
    if (box is! RenderBox || !box.attached || !box.hasSize) continue;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    if (center.dx >= 0 &&
        center.dy >= 0 &&
        center.dx <= size.width &&
        center.dy <= size.height - 8) {
      target = center;
    }
  }
  if (target == null) fail('屏幕上没有可点的「$text」');
  await tester.tapAt(target);
}

Future<void> _frames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 40)),
  );
  await tester.pump();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('shot')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('/opt/cursor/artifacts/screenshots/v200/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}
