import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/dates.dart';
import 'package:maokangji/domain/food/expiry_policy.dart';
import 'package:maokangji/domain/food/pack_confirm.dart';
import 'package:maokangji/domain/food/recognition_draft.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/domain/parsing/ocr_lines.dart';
import 'package:maokangji/domain/parsing/pack_front_parser.dart';
import 'package:maokangji/domain/reminders/reminder_planner.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const parser = PackFrontParser();

  test('high scores are 识别 and a weak expiry stays empty', () {
    const lines = [
      OcrLine('品牌：伯纳天纯', confidence: 0.92),
      OcrLine('产品名称：全价成猫粮', confidence: 0.9),
      OcrLine('净含量：2kg', confidence: 0.88),
      OcrLine('配料：鸡肉、三文鱼、鱼油', confidence: 0.86),
      OcrLine('生产日期：2026年3月15日', confidence: 0.91),
      OcrLine('到期时间：2027年3月15日', confidence: 0.93),
    ];
    final read = parser.parse('', lines: lines);
    final sheet = sheetFromRead(read, lines: lines);
    expect(sheet.brand, '伯纳天纯');
    expect(sheet.brandMark, FieldMark.recognized);
    expect(sheet.name, '全价成猫粮');
    expect(sheet.nameMark, FieldMark.recognized);
    expect(sheet.spec, '2kg');
    expect(sheet.specMark, FieldMark.recognized);
    expect(sheet.ingredients, contains('鸡肉'));
    expect(sheet.ingredientsMark, FieldMark.review);
    expect(sheet.production, DateTime(2026, 3, 15));
    expect(sheet.productionMark, FieldMark.recognized);
    expect(sheet.expiry, DateTime(2027, 3, 15));
    expect(sheet.expiryMark, FieldMark.recognized);
    expect(sheet.failure, isNull);
    expect(fieldMarkLabel(FieldMark.recognized), '识别');
    expect(fieldMarkLabel(FieldMark.review), '请核对');
    expect(fieldMarkLabel(FieldMark.missing), '未识别');
  });

  test('a mid score asks for a check and a low score is left blank', () {
    const lines = [
      OcrLine('品牌：伯纳天纯', confidence: 0.62),
      OcrLine('产品名称：全价成猫粮', confidence: 0.4),
      OcrLine('净含量：1.5kg', confidence: 0.55),
      OcrLine('到期时间', confidence: 0.95),
      OcrLine('2027年6月1日', confidence: 0.62),
    ];
    final read = parser.parse('', lines: lines);
    expect(read.expiryDate, DateTime(2027, 6, 1));
    final sheet = sheetFromRead(read, lines: lines);
    expect(sheet.brand, '伯纳天纯');
    expect(sheet.brandMark, FieldMark.review);
    expect(sheet.name, isEmpty);
    expect(sheet.nameMark, FieldMark.missing);
    expect(sheet.spec, '1.5kg');
    expect(sheet.specMark, FieldMark.review);
    expect(sheet.expiry, isNull);
    expect(sheet.expiryMark, FieldMark.missing);
    expect(sheet.expiryUnread, isTrue);
    expect(sheet.failure, isNull);
  });

  test('an empty read and a dropped read are different failures', () {
    final empty = sheetFromRead(parser.parse(''));
    expect(empty.failure, PackFailure.empty);
    expect(failureTitle(empty.failure!), '文字不够清晰');
    expect(failureBody(empty.failure!), contains('手填'));

    const lines = [
      OcrLine('产品名称：全价成猫粮', confidence: 0.2),
      OcrLine('到期时间：2028年1月1日', confidence: 0.1),
    ];
    final low = sheetFromRead(parser.parse('', lines: lines), lines: lines);
    expect(low.name, isEmpty);
    expect(low.expiry, isNull);
    expect(low.failure, PackFailure.low);
    expect(failureTitle(PackFailure.camera), '需要相机才能扫描包装');
    expect(failureBody(PackFailure.camera), contains('手填'));
    expect(failureBody(PackFailure.low), contains('重拍'));
  });

  test('a printed shelf life can fill expiry but still asks for a check', () {
    final read = parser.parse('生产日期：2025.01.01 保质期：18个月');
    expect(read.expiryDate, DateTime(2026, 7, 1));
    expect(read.expiryInferred, isTrue);
    final sheet = sheetFromRead(read);
    expect(sheet.expiry, DateTime(2026, 7, 1));
    expect(sheet.expiryMark, FieldMark.review);
    expect(sheet.askBeforeSave, isTrue);
  });

  test('ingredient leads are the printed names and not a score', () {
    const raw = '鸡肉、三文鱼、鱼油、牛磺酸、维生素、盐';
    expect(leadingIngredients(raw), ['鸡肉', '三文鱼', '鱼油', '牛磺酸', '维生素']);
    expect(ingredientLeadCaption, isNot(contains('评分')));
    expect(ingredientLeadCaption, contains('原文'));
    for (final text in [
      emptyExpiryCopy,
      onDeviceOcrCopy,
      failureBody(PackFailure.camera),
      uncheckedSaveTitle,
    ]) {
      expect(text, isNot(contains('会员')));
      expect(text, isNot(contains('付费')));
      expect(text, isNot(contains('开通')));
      expect(text, isNot(contains('订阅')));
    }
  });

  test('an empty expiry is not a reminder and stays off the home card', () {
    const dated = PantryEntry(
      item: PantryItem(
        id: 1,
        productId: 1,
        dateSource: DateSource.ocr,
        expiryDate: null,
      ),
      product: FoodProduct(
        id: 1,
        brand: '伯纳天纯',
        name: '无日期',
        spec: '',
        foodForm: FoodForm.dry,
        storageMethod: '',
        afterOpenDays: 30,
        isSample: false,
      ),
    );
    const soon = PantryEntry(
      item: PantryItem(
        id: 2,
        productId: 2,
        dateSource: DateSource.manual,
        expiryDate: null,
      ),
      product: FoodProduct(
        id: 2,
        brand: '皇家',
        name: '有日期',
        spec: '',
        foodForm: FoodForm.dry,
        storageMethod: '',
        afterOpenDays: 30,
        isSample: false,
      ),
    );
    final withDate = PantryEntry(
      item: PantryItem(
        id: 2,
        productId: 2,
        dateSource: DateSource.manual,
        expiryDate: DateTime(2026, 10, 25),
      ),
      product: soon.product,
    );
    final far = PantryEntry(
      item: PantryItem(
        id: 3,
        productId: 3,
        dateSource: DateSource.gs1,
        expiryDate: DateTime(2027, 8, 1),
      ),
      product: const FoodProduct(
        id: 3,
        brand: '远',
        name: '明年',
        spec: '',
        foodForm: FoodForm.dry,
        storageMethod: '',
        afterOpenDays: 30,
        isSample: false,
      ),
    );
    expect(shouldRemindExpiry(null), isFalse);
    expect(expiryReminders([dated]), isEmpty);
    expect(expiryReminders([withDate]).single.productName, contains('有日期'));
    final today = DateTime(2026, 10, 19);
    final near = bagsNearExpiry([dated, withDate, far], today);
    expect(near.map((item) => item.name), ['有日期']);
    expect(nearExpiryLabel(near.single), '有日期 · 还有 6 天');
    expect(pantryHasUndatedExpiry([dated, withDate]), isTrue);
    final planned = const ReminderPlanner().plan(
      now: today,
      expiries: expiryReminders([dated]),
    );
    expect(planned, isEmpty);
  });

  test('a draft keeps badges and reopens the confirm form', () {
    final draft = RecognitionDraft(
      id: recognitionDraftId(barcode: '6900000000007'),
      kind: 'ocr',
      updatedAt: DateTime.utc(2026, 10, 19),
      barcode: '6900000000007',
      brand: '伯纳天纯',
      name: '全价成猫粮',
      marks: const {
        'brand': 'recognized',
        'name': 'review',
        'expiry': 'missing',
      },
      failure: 'low',
      addBag: true,
    );
    final again = RecognitionDraft.fromJson(draft.toJson());
    expect(again.marks['brand'], 'recognized');
    expect(again.marks['name'], 'review');
    expect(again.failure, 'low');
    expect(again.resumeRoute, contains('/pack?'));
    expect(again.resumeRoute, contains('draft='));
    final marks = marksForDraft(stored: again.marks, values: const {});
    expect(marks['brand'], FieldMark.recognized);
    expect(marks['name'], FieldMark.review);
    expect(marks['expiry'], FieldMark.missing);
    expect(askBeforeSave(marks), isTrue);
    expect(confirmProgress(2, marks), contains('请核对'));
    expect(markAfterEdit(''), FieldMark.missing);
    expect(markAfterEdit('手写'), FieldMark.edited);
  });

  group('confirm screen', () {
    late AppDatabase database;
    late AppController controller;

    setUp(() async {
      database = AppDatabase.memory();
      controller = AppController(
        repo: DriftCareRepository(database),
        notifications: NoopNotificationService(),
        recognizer: const MockCoatBreedRecognizer(),
        clock: () => DateTime(2026, 10, 19, 9),
      );
      await controller.init();
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('手填 saves an empty expiry and does not invent a year', (
      tester,
    ) async {
      const code = '6900000000007';
      await boot(tester, controller, location: '/pack?code=$code');
      expect(find.text('存进粮仓'), findsOneWidget);
      expect(find.text('重拍'), findsOneWidget);
      expect(find.text('手填'), findsOneWidget);
      expect(find.text(emptyExpiryCopy), findsOneWidget);
      expect(find.textContaining('2027年10月'), findsNothing);
      expect(find.text('未识别'), findsWidgets);
      final before = controller.pantry.length;
      await enterField(tester, '品牌', '伯纳天纯');
      await enterField(tester, '品名', '手写全价粮');
      await tapText(tester, '存进粮仓');
      expect(find.text(uncheckedSaveTitle), findsNothing);
      final added = controller.pantry.where(
        (entry) => entry.product.name == '手写全价粮',
      );
      expect(added, hasLength(1));
      expect(controller.pantry.length, before + 1);
      expect(added.single.item.expiryDate, isNull);
      expect(added.single.item.dateSource, DateSource.none);
      expect(added.single.product.barcode, code);
      expect(expiryReminders(added), isEmpty);
      expect(
        dateOnly(DateTime(2026, 10, 19)).add(const Duration(days: 365)),
        isNot(added.single.item.expiryDate),
      );
    });

    testWidgets('请核对 asks before 存进粮仓 and a camera miss still has 手填', (
      tester,
    ) async {
      const code = '6900000000007';
      await controller.saveRecognitionDraft(
        RecognitionDraft(
          id: recognitionDraftId(barcode: code),
          kind: 'ocr',
          updatedAt: DateTime.utc(2026, 10, 19),
          barcode: code,
          brand: '伯纳天纯',
          name: '全价成猫粮',
          addBag: true,
        ),
      );
      await boot(
        tester,
        controller,
        location:
            '/pack?code=$code&draft=${Uri.encodeComponent(recognitionDraftId(barcode: code))}',
      );
      expect(find.text('请核对'), findsWidgets);
      final before = controller.pantry.length;
      await tapText(tester, '存进粮仓');
      expect(find.text(uncheckedSaveTitle), findsOneWidget);
      await tapText(tester, '再看看');
      expect(
        controller.pantry.where((entry) => entry.product.name == '全价成猫粮'),
        isEmpty,
      );
      expect(controller.pantry.length, before);
      await tapText(tester, '存进粮仓');
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, '存进粮仓'),
        ),
      );
      await frames(tester);
      final added = controller.pantry.where(
        (entry) => entry.product.name == '全价成猫粮',
      );
      expect(added, hasLength(1));
      expect(added.single.item.expiryDate, isNull);
    });

    testWidgets(
      'a camera miss still offers settings, retake and manual entry',
      (tester) async {
        const code = '6900000000007';
        await controller.saveRecognitionDraft(
          RecognitionDraft(
            id: 'camera-miss',
            kind: 'ocr',
            updatedAt: DateTime.utc(2026, 10, 19),
            barcode: code,
            failure: 'camera',
            addBag: true,
          ),
        );
        await boot(
          tester,
          controller,
          location: '/pack?draft=camera-miss&code=$code',
        );
        expect(find.text('需要相机才能扫描包装'), findsOneWidget);
        expect(find.text('去设置'), findsOneWidget);
        expect(find.text('手填'), findsOneWidget);
        expect(find.text('重拍'), findsWidgets);
        await tapText(tester, '去设置');
        expect(find.textContaining('系统设置'), findsWidgets);
        await tapText(tester, '手填');
        expect(find.text('品名'), findsOneWidget);
      },
    );

    testWidgets('home shows a near-expiry card only for a real date', (
      tester,
    ) async {
      await boot(tester, controller, location: '/home');
      await revealText(tester, '临期');
      expect(find.text('临期'), findsOneWidget);
      expect(find.textContaining('还有 20 天'), findsWidgets);
      expect(find.text('没填到期日的袋子不会出现在这里，也不会提醒。'), findsNothing);
    });
  });
}
