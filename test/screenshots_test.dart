import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:maokangji/app.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/domain/scale/scale_parser.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/services/scale_service.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/state/app_controller.dart';

import 'cjk_font.dart';

class _ShotScale implements ScaleSource {
  var status = ScaleStatus.ready;
  StreamController<ScaleReading>? _out;

  @override
  Future<ScaleStatus> prepare() async => status;

  @override
  Stream<ScaleReading> readings() =>
      (_out = StreamController<ScaleReading>()).stream;

  @override
  Future<void> stop() async => _out?.close();

  void send(double kg, {bool stable = true}) => _out!.add(
    ScaleReading(kg: kg, stable: stable, protocol: ScaleProtocol.miScale2),
  );
}

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
    final cat = controller.active!;
    final customId = await controller.saveFood(
      const FoodDraft(
        brand: '山野',
        name: '冻干双拼',
        spec: '1.5kg',
        foodForm: FoodForm.freezeDried,
        storageMethod: '阴凉干燥，封好袋口。',
        afterOpenDays: 30,
        flavor: '鸡肉',
        isCustom: true,
      ),
      barcode: '6901111222233',
    );
    await controller.savePantry(
      PantryDraft(
        productId: customId,
        dateSource: DateSource.manual,
        openedAt: DateTime(2026, 9, 30),
        expiryDate: DateTime(2027, 6, 1),
        afterOpenDays: 0,
        dailyGrams: 80,
      ),
    );
    await controller.saveLab(
      LabDraft(
        catId: cat.id,
        kind: LabKind.cbc,
        takenOn: DateTime(2026, 9, 1),
        photos: const [],
      ),
      values: const [LabValue(code: 'WBC', value: 10, unit: '10^9/L')],
    );
    await controller.saveLab(
      LabDraft(
        catId: cat.id,
        kind: LabKind.cbc,
        takenOn: DateTime(2026, 10, 12),
        photos: const [],
      ),
      values: const [
        LabValue(code: 'WBC', value: 18.2, unit: '10^9/L'),
        LabValue(code: 'PLT', value: 88, unit: '10^9/L'),
      ],
    );
    final scale = _ShotScale();
    await tester.pumpWidget(
      ZhuajiApp(controller: controller, scaleSource: () => scale),
    );
    await _frames(tester);
    await _shot(tester, 'today');

    await _tapOnScreen(tester, '未来 30 天');
    await _frames(tester);
    await _shot(tester, 'calendar');
    await _tapOnScreen(tester, '18');
    await _frames(tester);
    await _shot(tester, 'calendar-day');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '猫三联');
    await _frames(tester);
    await _frames(tester);
    await _shot(tester, 'today-undo');
    tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
    await _frames(tester);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
        .clearSnackBars();
    await _frames(tester);

    await _tapOnScreen(tester, '健康');
    await _frames(tester);
    await _shot(tester, 'health');

    await _tapOnScreen(tester, '疫苗');
    await _frames(tester);
    await _shot(tester, 'vaccine');
    await _tapOnScreen(tester, '拍贴纸');
    await _frames(tester);
    await _shot(tester, 'sticker');
    unawaited(
      GoRouter.of(tester.element(find.byType(Scaffold).last)).push(
        '/sticker?demo=1',
      ),
    );
    await _frames(tester);
    await _shot(tester, 'sticker-confirm');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '驱虫');
    await _frames(tester);
    await _shot(tester, 'deworm');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '就医');
    await _frames(tester);
    await _shot(tester, 'visit');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '体重');
    await _frames(tester);
    await _shot(tester, 'weight');

    await _tapOnScreen(tester, '用蓝牙秤（抱猫称）');
    await _frames(tester);
    scale.send(61.2, stable: false);
    await _frames(tester);
    await _shot(tester, 'scale-owner');
    scale.send(62.40);
    await _frames(tester);
    scale.send(65.9, stable: false);
    await _frames(tester);
    await _shot(tester, 'scale-together');
    scale.send(66.75);
    await _frames(tester);
    await _shot(tester, 'scale-result');
    await _tapOnScreen(tester, '用这个');
    await _frames(tester);
    await _shot(tester, 'weight-from-scale');

    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
        .clearSnackBars();
    await _frames(tester);
    scale.status = ScaleStatus.off;
    await _tapOnScreen(tester, '用蓝牙秤（抱猫称）');
    await _frames(tester);
    await _shot(tester, 'scale-failed');
    await _tapOnScreen(tester, '隐私政策');
    await _frames(tester);
    await _shot(tester, 'privacy');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    await _tapOnScreen(tester, '手动输入');
    await _frames(tester);
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
        .clearSnackBars();
    await _frames(tester);

    await _tapOnScreen(tester, '扫粮');
    await _frames(tester);
    await _shot(tester, 'scan');
    await _tapOnScreen(tester, '选品牌');
    await _frames(tester);
    await _shot(tester, 'scan-result');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    const code = '6909999000031';
    final router = GoRouter.of(tester.element(find.byType(Scaffold).last));
    unawaited(router.push('/confirm?code=$code'));
    await _frames(tester);
    await _shot(tester, 'barcode-new');
    await _tapOnScreen(tester, '记下');
    await _frames(tester);
    unawaited(router.push('/confirm?code=$code'));
    await _frames(tester);
    await _shot(tester, 'barcode-known');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '粮仓');
    await _frames(tester);
    await _shot(tester, 'pantry');
    await _tapOnScreen(tester, '冻干双拼');
    await _frames(tester);
    await _shot(tester, 'bag-stock');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '图鉴');
    await _frames(tester);
    await _shot(tester, 'catalog');
    await _tapOnScreen(tester, '山野 冻干双拼');
    await _frames(tester);
    await _shot(tester, 'custom-food');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '健康');
    await _frames(tester);
    await _tapOnScreen(tester, '化验');
    await _frames(tester);
    await _shot(tester, 'labs');
    await _tapOnScreen(tester, '2026年10月12日 · 血常规');
    await _frames(tester);
    await _shot(tester, 'lab-sheet');
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);
    await tester.tap(find.byTooltip('返回'));
    await _frames(tester);

    await _tapOnScreen(tester, '猫咪');
    await _frames(tester);
    await _shot(tester, 'cat');

    final story = find.text('最近').evaluate().where((e) => !_hidden(e));
    await tester.ensureVisible(find.byWidget(story.first.widget));
    await tester.drag(
      find.byWidget(story.first.widget),
      const Offset(0, -260),
      warnIfMissed: false,
    );
    await _frames(tester);
    await _shot(tester, 'cat-story');

    await tester.pumpWidget(const SizedBox());
    await _frames(tester);
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
    final file = File('/opt/cursor/artifacts/screenshots/v280/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}
