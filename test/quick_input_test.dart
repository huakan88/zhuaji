import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/models.dart';
import 'package:maokangji/features/home/home_page.dart';
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

  Future<void> undo(WidgetTester tester) async {
    tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
    await frames(tester);
  }

  testWidgets('one tap on today records, and 撤销 puts it back', (
    tester,
  ) async {
    await boot(tester, controller);
    final before = controller.catVaccines.single;

    await tapText(tester, '猫三联');
    expect(find.text('撤销'), findsOneWidget);
    expect(controller.catVaccines.single.givenOn, DateTime(2026, 10, 12));
    expect(_homeText('猫三联'), findsNothing);

    await undo(tester);
    final after = controller.catVaccines.single;
    expect(after.id, before.id);
    expect(after.givenOn, before.givenOn);
    expect(after.nextDue, before.nextDue);
    expect(_homeText('猫三联'), findsOneWidget);
  });

  testWidgets('undo also works for deworming and food on today', (
    tester,
  ) async {
    await boot(tester, controller);
    final worm = controller.catDeworms.firstWhere(
      (item) => item.nextDue != null,
    );
    await tapText(tester, worm.product);
    expect(
      controller.catDeworms.singleWhere((item) => item.id == worm.id).nextDue,
      isNot(worm.nextDue),
    );
    await undo(tester);
    expect(
      controller.catDeworms.singleWhere((item) => item.id == worm.id).nextDue,
      worm.nextDue,
    );

    final bag = controller.pantry.firstWhere(
      (entry) => find
          .descendant(
            of: find.byType(HomePage),
            matching: find.text(entry.product.name),
          )
          .evaluate()
          .isNotEmpty,
    );
    await tapText(tester, bag.product.name);
    expect(controller.pantryAcked(bag), isTrue);
    await undo(tester);
    expect(controller.pantryAcked(bag), isFalse);
  });

  testWidgets('date chips pick 今天 / 昨天 / 前天 without the wheel', (
    tester,
  ) async {
    await boot(tester, controller, location: '/vaccines');
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('昨天'), findsOneWidget);
    expect(find.text('前天'), findsOneWidget);
    expect(find.text('更早'), findsOneWidget);
    await tapText(tester, '昨天');
    await tapText(tester, '狂犬');
    await tapText(tester, '记下');
    final rabies = controller.catVaccines.singleWhere(
      (item) => item.name == '狂犬',
    );
    expect(rabies.givenOn, DateTime(2026, 10, 11));
  });

  testWidgets('deworming starts on the last product, 照旧 is one tap', (
    tester,
  ) async {
    final last = controller.lastDeworm!;
    await boot(tester, controller, location: '/deworms');
    final chip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text(last.product).last,
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(chip.selected, isTrue);
    await tapText(tester, '前天');
    await tapText(tester, '记下');
    final saved = controller.catDeworms.reduce(
      (a, b) => a.id > b.id ? a : b,
    );
    expect(saved.product, last.product);
    expect(saved.kind, last.kind);
    expect(saved.givenOn, DateTime(2026, 10, 10));
    expect(saved.nextDue, DateTime(2027, 1, 8));
  });

  testWidgets('a visit defaults to the last clinic', (tester) async {
    await controller.saveVisit(
      VetDraft(
        catId: controller.activeCatId!,
        visitedOn: DateTime(2026, 9, 1),
        reason: '呕吐',
        clinic: '街口动物医院',
      ),
    );
    expect(controller.knownClinics.first, '街口动物医院');
    await boot(tester, controller, location: '/visits');
    await tapText(tester, '体检');
    await tapText(tester, '记下');
    final saved = controller.catVisits.reduce((a, b) => a.id > b.id ? a : b);
    expect(saved.clinic, '街口动物医院');
    expect(saved.visitedOn, DateTime(2026, 10, 12));
  });
}

Finder _homeText(String text) {
  return find.descendant(of: find.byType(HomePage), matching: find.text(text));
}
