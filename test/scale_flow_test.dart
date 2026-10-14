import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/scale/scale_parser.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/services/scale_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';

class FakeScale implements ScaleSource {
  FakeScale({this.status = ScaleStatus.ready});

  ScaleStatus status;
  StreamController<ScaleReading>? _out;
  var stops = 0;

  @override
  Future<ScaleStatus> prepare() async => status;

  @override
  Stream<ScaleReading> readings() {
    final out = _out = StreamController<ScaleReading>();
    return out.stream;
  }

  @override
  Future<void> stop() async {
    stops++;
    await _out?.close();
  }

  void send(double kg, {bool stable = true}) {
    _out!.add(
      ScaleReading(kg: kg, stable: stable, protocol: ScaleProtocol.miScale2),
    );
  }

  void fail() => _out!.addError(StateError('gatt 133'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AppController controller;
  late FakeScale scale;

  setUp(() async {
    database = AppDatabase.memory();
    controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
    scale = FakeScale();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> open(WidgetTester tester) async {
    await boot(tester, controller, location: '/weight', scale: () => scale);
    await tapText(tester, '用蓝牙秤（抱猫称）');
    expect(find.text('蓝牙秤'), findsOneWidget);
  }

  Future<void> send(
    WidgetTester tester,
    double kg, {
    bool stable = true,
  }) async {
    scale.send(kg, stable: stable);
    await frames(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await frames(tester);
  }

  testWidgets('抱猫称 minus 自己, owner weight remembered, then saved', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('先自己站上去'), findsOneWidget);
    expect(find.textContaining('还没在真秤上试过'), findsOneWidget);

    await send(tester, 61.2, stable: false);
    expect(find.text('61.20 kg'), findsOneWidget);
    expect(find.text('先自己站上去'), findsOneWidget);

    await send(tester, 62.40);
    expect(find.text('抱着猫站上去'), findsOneWidget);
    expect(find.text('自己 62.40 kg'), findsOneWidget);
    expect(controller.ownerWeightKg, 62.40);

    await send(tester, 62.45);
    expect(find.textContaining('还是自己的重量'), findsOneWidget);

    await send(tester, 66.75);
    expect(find.text('4.35 kg'), findsOneWidget);
    expect(find.text('抱猫 66.75 - 自己 62.40'), findsOneWidget);

    await tapText(tester, '用这个');
    expect(find.text('轻一点'), findsOneWidget);
    expect(find.text('4.35 kg'), findsOneWidget);
    await tapText(tester, '保存');
    expect(controller.latestWeight!.weightKg, closeTo(4.35, 1e-9));
    expect(scale.stops, greaterThan(0));
    await close(tester);
  });

  testWidgets('next time the owner weight is one tap', (tester) async {
    await controller.saveOwnerWeight(58.10);
    await open(tester);
    await tapText(tester, '自己还是 58.10 kg');
    expect(find.text('抱着猫站上去'), findsOneWidget);
    await send(tester, 62.15);
    expect(find.text('4.05 kg'), findsOneWidget);
    await close(tester);
  });

  testWidgets('a jump that is not a cat asks to reweigh yourself', (
    tester,
  ) async {
    await controller.saveOwnerWeight(40);
    await open(tester);
    await tapText(tester, '自己还是 40.00 kg');
    await send(tester, 62.40);
    expect(find.textContaining('不像一只猫'), findsOneWidget);
    await tapText(tester, '重称自己');
    expect(find.text('先自己站上去'), findsOneWidget);
    await close(tester);
  });

  testWidgets('bluetooth off on iOS points at Control Center', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    scale.status = ScaleStatus.off;
    await open(tester);
    expect(find.text('请先在控制中心打开蓝牙，再回来重试'), findsOneWidget);
    await close(tester);
  });

  testWidgets('bluetooth off: say so, manual entry still works', (
    tester,
  ) async {
    scale.status = ScaleStatus.off;
    await open(tester);
    expect(find.text('没连上秤'), findsOneWidget);
    expect(find.text('蓝牙没打开'), findsOneWidget);
    await tapText(tester, '手动输入');
    expect(find.text('轻一点'), findsOneWidget);
    await tapText(tester, '重一点');
    await tapText(tester, '保存');
    expect(controller.latestWeight!.weightKg, closeTo(4.40, 1e-9));
    await close(tester);
  });

  testWidgets('a dropped connection offers retry, retry reconnects', (
    tester,
  ) async {
    await open(tester);
    scale.fail();
    await frames(tester);
    expect(find.textContaining('连不上秤'), findsOneWidget);
    await tapText(tester, '重试');
    expect(find.text('先自己站上去'), findsOneWidget);
    await send(tester, 62.40);
    expect(find.text('抱着猫站上去'), findsOneWidget);
    await close(tester);
  });

  testWidgets('no data for a while times out to the fallback', (tester) async {
    await open(tester);
    await tester.pump(ScalePageQuiet.duration);
    await frames(tester);
    expect(find.textContaining('没收到秤的数据'), findsOneWidget);
    expect(find.text('手动输入'), findsOneWidget);
    await close(tester);
  });

  testWidgets('privacy policy explains bluetooth', (tester) async {
    await open(tester);
    await tapText(tester, '隐私政策');
    expect(find.text('蓝牙'), findsOneWidget);
    expect(find.textContaining('不用蓝牙定位'), findsOneWidget);
    await close(tester);
  });
}

abstract final class ScalePageQuiet {
  static const duration = Duration(seconds: 91);
}
