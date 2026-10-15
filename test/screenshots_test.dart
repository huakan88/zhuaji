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
import 'package:maokangji/domain/food/barcode_lookup.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/core/theme/app_tokens.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';
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
    await _capture(tester, 'light', ZhuajiThemeMode.light);
    await _capture(tester, 'dark', ZhuajiThemeMode.dark);
    await tester.runAsync(_compare);
  });
}

Future<void> _capture(
  WidgetTester tester,
  String folder,
  ZhuajiThemeMode mode,
) async {
  final controller = AppController(
    repo: DriftCareRepository(AppDatabase.memory()),
    notifications: NoopNotificationService(),
    recognizer: const MockCoatBreedRecognizer(),
    clock: () => DateTime(2026, 10, 12, 10),
  );
  await controller.init();
  await controller.setThemeMode(mode);
  const royalImage = '/tmp/opff-royal.jpg';
  await tester.runAsync(() => _primeFileImage(royalImage));
  await controller.saveBarcodeRecord(
    BarcodeRecord(
      code: '3182550799669',
      found: true,
      brand: 'Royal Canin',
      name: 'Neutered Satiety Balance',
      quantity: '12 kg',
      ingredients: 'Protéines de volailles déshydratées, maïs, fibres végétales, blé, gluten de maïs, gluten de blé, hydrolysat de protéines animales, graisses animales, sels minéraux, pulpe de chicorée, huile de poisson',
      nutrients: const [
        BarcodeNutrient(label: '粗蛋白', text: '35 %'),
        BarcodeNutrient(label: '粗脂肪', text: '10 %'),
        BarcodeNutrient(label: '粗纤维', text: '9.2 %'),
        BarcodeNutrient(label: '粗灰分', text: '9.3 %'),
      ],
      source: 'openpetfoodfacts',
      imageUrl: File(royalImage).existsSync() ? royalImage : null,
    ),
  );
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
  await _shot(tester, folder, 'today');
  await _shot(tester, folder, 'today-top');

  await enter(tester, find.byType(TextField), '猫');
  await _frames(tester);
  await _shot(tester, folder, 'search');
  await enter(tester, find.byType(TextField), '');
  await _frames(tester);

  unawaited(
    GoRouter.of(tester.element(find.byType(Scaffold).last))
        .push('/lookup?code=3182550799669'),
  );
  await _frames(tester);
  await _shot(tester, folder, 'lookup');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  unawaited(
    GoRouter.of(tester.element(find.byType(Scaffold).last))
        .push('/lookup?code=6958862134620'),
  );
  await _frames(tester);
  await _shot(tester, folder, 'lookup-cn');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  controller.barcodeFetch = (call) async {
    if (call.uri.host.contains('upcitemdb')) {
      return const BarcodeResponse(200, '{"code":"OK","total":0,"items":[]}');
    }
    return const BarcodeResponse(404, '{"status":0}');
  };
  unawaited(
    GoRouter.of(tester.element(find.byType(Scaffold).last))
        .push('/lookup?code=6970000000000'),
  );
  await _frames(tester);
  await _shot(tester, folder, 'lookup-miss');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '未来 30 天');
  await _frames(tester);
  await _shot(tester, folder, 'calendar');
  await _tapOnScreen(tester, '18');
  await _frames(tester);
  await _shot(tester, folder, 'calendar-day');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '猫三联');
  await _frames(tester);
  await _frames(tester);
  await _shot(tester, folder, 'today-undo');
  tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
  await _frames(tester);
  ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
      .clearSnackBars();
  await _frames(tester);

  await _tapOnScreen(tester, '健康');
  await _frames(tester);
  await _shot(tester, folder, 'health');

  await _tapOnScreen(tester, '疫苗');
  await _frames(tester);
  await _shot(tester, folder, 'vaccine');
  await _tapOnScreen(tester, '拍贴纸');
  await _frames(tester);
  await _shot(tester, folder, 'sticker');
  unawaited(
    GoRouter.of(tester.element(find.byType(Scaffold).last))
        .push('/sticker?demo=1'),
  );
  await _frames(tester);
  await _shot(tester, folder, 'sticker-confirm');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '驱虫');
  await _frames(tester);
  await _shot(tester, folder, 'deworm');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '就医');
  await _frames(tester);
  await _shot(tester, folder, 'visit');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '体重');
  await _frames(tester);
  await _shot(tester, folder, 'weight');

  await _tapOnScreen(tester, '用蓝牙秤（抱猫称）');
  await _frames(tester);
  scale.send(61.2, stable: false);
  await _frames(tester);
  await _shot(tester, folder, 'scale-owner');
  scale.send(62.40);
  await _frames(tester);
  scale.send(65.9, stable: false);
  await _frames(tester);
  await _shot(tester, folder, 'scale-together');
  scale.send(66.75);
  await _frames(tester);
  await _shot(tester, folder, 'scale-result');
  await _tapOnScreen(tester, '用这个');
  await _frames(tester);
  await _shot(tester, folder, 'weight-from-scale');

  ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
      .clearSnackBars();
  await _frames(tester);
  scale.status = ScaleStatus.off;
  await _tapOnScreen(tester, '用蓝牙秤（抱猫称）');
  await _frames(tester);
  await _shot(tester, folder, 'scale-failed');
  await _tapOnScreen(tester, '隐私政策');
  await _frames(tester);
  await _shot(tester, folder, 'privacy');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await _tapOnScreen(tester, '手动输入');
  await _frames(tester);
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
      .clearSnackBars();
  await _frames(tester);

  const code = '6909999000031';
  final router = GoRouter.of(tester.element(find.byType(Scaffold).last));
  unawaited(router.push('/confirm?code=$code'));
  await _frames(tester);
  await _shot(tester, folder, 'barcode-new');
  await _tapOnScreen(tester, '记下');
  await _frames(tester);
  unawaited(router.push('/confirm?code=$code'));
  await _frames(tester);
  await _shot(tester, folder, 'barcode-known');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '粮仓');
  await _frames(tester);
  await _shot(tester, folder, 'pantry');
  await tester.tap(find.byTooltip('扫码'));
  await _frames(tester);
  await _shot(tester, folder, 'scan');
  await _tapOnScreen(tester, '选品牌');
  await _frames(tester);
  await _shot(tester, folder, 'scan-result');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await _tapOnScreen(tester, '自制鲜食');
  await _frames(tester);
  await _shot(tester, folder, 'recipes');
  await _tapOnScreen(tester, '慢煮一份熟肉');
  await _frames(tester);
  await _shot(tester, folder, 'recipe');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await _tapOnScreen(tester, '冻干双拼');
  await _frames(tester);
  await _shot(tester, folder, 'bag-stock');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '图鉴');
  await _frames(tester);
  await _shot(tester, folder, 'catalog');
  await _tapOnScreen(tester, '山野 冻干双拼');
  await _frames(tester);
  await _shot(tester, folder, 'custom-food');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '健康');
  await _frames(tester);
  await _tapOnScreen(tester, '化验');
  await _frames(tester);
  await _shot(tester, folder, 'labs');
  await _tapOnScreen(tester, '2026年10月12日 · 血常规');
  await _frames(tester);
  await _shot(tester, folder, 'lab-sheet');
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);
  await tester.tap(find.byTooltip('返回'));
  await _frames(tester);

  await _tapOnScreen(tester, '猫咪');
  await _frames(tester);
  await _shot(tester, folder, 'cat');

  await revealText(tester, '最近');
  final story = find.text('最近').evaluate().where((e) => !_hidden(e));
  await tester.ensureVisible(find.byWidget(story.first.widget));
  await tester.drag(
    find.byWidget(story.first.widget),
    const Offset(0, -260),
    warnIfMissed: false,
  );
  await _frames(tester);
  await _shot(tester, folder, 'cat-story');

  await tester.pumpWidget(const SizedBox());
  await _frames(tester);
}

Future<void> _compare() async {
  const names = [
    'today',
    'search',
    'lookup',
    'lookup-cn',
    'lookup-miss',
    'today-top',
    'health',
    'scan',
    'pantry',
    'recipes',
    'recipe',
    'cat',
    'calendar',
    'labs',
  ];
  final images = <ui.Image>[];
  for (final name in names) {
    for (final folder in ['light', 'dark']) {
      final file = File(
        '/opt/cursor/artifacts/screenshots/v2140/$folder/$name.png',
      );
      if (!file.existsSync()) return;
      final data = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      images.add(frame.image);
    }
  }
  if (images.length != names.length * 2) return;
  final width = images.first.width;
  final height = images.first.height;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width * 2, height * names.length.toDouble()),
    Paint()..color = const Color(0xFF000000),
  );
  for (var i = 0; i < images.length; i++) {
    final column = i.isEven ? 0.0 : width.toDouble();
    final row = (i ~/ 2) * height.toDouble();
    canvas.drawImage(images[i], Offset(column, row), Paint());
  }
  final picture = recorder.endRecording();
  final composed = await picture.toImage(width * 2, height * names.length);
  final bytes = await composed.toByteData(format: ui.ImageByteFormat.png);
  final out = File(
    '/opt/cursor/artifacts/screenshots/v2140/compare-light-dark.png',
  );
  await out.parent.create(recursive: true);
  await out.writeAsBytes(bytes!.buffer.asUint8List());
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

Future<void> _primeFileImage(String path) async {
  final file = File(path);
  if (!file.existsSync()) return;
  final provider = FileImage(file);
  final key = await provider.obtainKey(
    const ImageConfiguration(devicePixelRatio: 1),
  );
  if (PaintingBinding.instance.imageCache.containsKey(key)) return;
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  PaintingBinding.instance.imageCache.putIfAbsent(
    key,
    () => OneFrameImageStreamCompleter(
      Future<ImageInfo>.value(ImageInfo(image: frame.image)),
    ),
  );
}

Future<void> _frames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 40)),
  );
  await tester.pump();
}

Future<void> _shot(WidgetTester tester, String folder, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('shot')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(
      '/opt/cursor/artifacts/screenshots/v2140/$folder/$name.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}
