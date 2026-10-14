import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AppController controller;

  AppController build() => AppController(
    repo: DriftCareRepository(database),
    notifications: NoopNotificationService(),
    recognizer: const MockCoatBreedRecognizer(),
    clock: () => DateTime(2026, 10, 12, 10),
  );

  setUp(() async {
    database = AppDatabase.memory();
    controller = build();
    await controller.init();
  });

  tearDown(() async {
    await database.close();
  });

  test('a GS1 string and the EAN-13 under it share one key', () {
    expect(barcodeKey('6901234567892'), '6901234567892');
    expect(barcodeKey(' 6901234567892 '), '6901234567892');
    expect(barcodeKey('(01)06901234567892(17)270412'), '6901234567892');
    expect(barcodeKey('0106901234567892172704121012AB'), '6901234567892');
    expect(barcodeKey('0123456789012'), '123456789012');
    expect(barcodeKey(''), '');
  });

  test('an unknown code is remembered and survives a restart', () async {
    const code = '6909999000017';
    expect(controller.findBarcode(code), isNull);
    final product = controller.products.last;
    await controller.rememberBarcode(code, product.id);
    expect(controller.findBarcode(code)?.id, product.id);
    expect(
      controller.findBarcode('(01)0$code(17)271231')?.id,
      product.id,
      reason: 'the GS1 form of the same product',
    );

    final again = build();
    await again.init();
    expect(again.findBarcode(code)?.id, product.id);
  });

  test('a removed product does not leave a dangling match', () async {
    await controller.rememberBarcode('6909999000024', 999999);
    expect(controller.findBarcode('6909999000024'), isNull);
  });

  testWidgets('scan once, pick the brand, the next scan knows it', (
    tester,
  ) async {
    const code = '6909999000031';
    await boot(tester, controller, location: '/confirm?code=$code');
    expect(find.text('选好品牌记下后，下次扫这个码直接认出'), findsOneWidget);
    expect(find.text('认得这个码'), findsNothing);
    final brand = controller.products.firstWhere(
      (item) => item.name != '室内成猫干粮' && item.brand.isNotEmpty,
    );
    final chips = find.byType(ChoiceChip);
    expect(chips, findsWidgets);
    await tapText(tester, _short(brand.brand));
    await tapText(tester, '记下');
    final chosen = controller.findBarcode(code);
    expect(chosen, isNotNull);
    expect(chosen!.brand, brand.brand);

    await tester.pumpWidget(const SizedBox());
    await boot(tester, controller, location: '/confirm?code=$code');
    expect(find.text('认得这个码'), findsOneWidget);
    expect(find.text(chosen.name), findsWidgets);
    expect(find.byType(TextField), findsNothing);

    await tapText(tester, '不是这个');
    expect(find.text('认得这个码'), findsNothing);
    expect(find.byType(ChoiceChip), findsWidgets);
  });
}

String _short(String brand) {
  final parts = brand.split(RegExp(r'\s+'));
  for (final part in parts) {
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(part)) return part;
  }
  return parts.first;
}
