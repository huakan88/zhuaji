import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/data/db/app_database.dart';
import 'package:maokangji/data/repositories/drift_care_repository.dart';
import 'package:maokangji/domain/food/fresh_recipes.dart';
import 'package:maokangji/services/coat_recognizer.dart';
import 'package:maokangji/services/notification_service.dart';
import 'package:maokangji/state/app_controller.dart';

import 'app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('energy and allowances follow the published factors', () {
    expect(
      restingEnergyKcal(4),
      closeTo(70 * math.pow(4, 0.75).toDouble(), 0.0001),
    );
    expect(merKcal(4), closeTo(restingEnergyKcal(4) * 1.2, 0.0001));
    expect(neuteredAdultFactor, 1.2);
    expect(intactAdultFactor, 1.4);
    expect(obesityProneFactor, 1.0);
    expect(
      allowancePerDay(per1000kcal: 0.50, dailyKcal: 200),
      closeTo(0.10, 0.0001),
    );
    expect(
      gramsForKcal(dailyKcal: 200, kcalPer100g: 100),
      closeTo(200, 0.0001),
    );
    expect(gramsForKcal(dailyKcal: 200, kcalPer100g: 0), isNull);
    expect(restingEnergyKcal(0), 0);
  });

  test('every card cites an allowed source and names the hazards', () {
    expect(freshSourceHosts, {
      'wsava.org',
      'pmc.ncbi.nlm.nih.gov',
      'aafco.org',
      'nap.nationalacademies.org',
      'tufts.edu',
      'vetmed.ucdavis.edu',
      'vet.cornell.edu',
      'aaha.org',
      'petnutritionalliance.org',
      'acvn.org',
    });
    expect(freshCards.length, greaterThanOrEqualTo(10));
    final joined = freshCards.map((card) => card.text).join('\n');
    for (final word in ['洋葱', '大蒜', '葡萄', '巧克力', '生鱼']) {
      expect(joined, contains(word));
    }
    final safety = freshById('safety')!;
    expect(safety.text, contains('营养师'));
    expect(safety.text, contains('主食'));
    final slow = freshById('slow-cook')!;
    expect(slow.text, contains('温度'));
    expect(slow.text, contains('100 克'));
    expect(slow.text, contains('45 克'));
    expect(slow.text, isNot(contains('80 度')));
    expect(slow.text, isNot(contains('小时就')));
    expect(freshById('fish-oil')!.text, contains('未确定'));
    expect(freshById('taurine')!.text, contains('0.25'));
    expect(freshById('taurine')!.text, contains('0.50'));
    expect(freshById('calcium')!.text, contains('1.5'));
    expect(freshById('calcium')!.text, contains('1.25'));
    expect(freshById('iodine')!.text, contains('0.15'));
    expect(freshById('vitamin-e')!.text, contains('10'));
    expect(freshById('b-complex')!.text, contains('1.40'));
    for (final card in freshCards) {
      expect(card.sources, isNotEmpty, reason: card.id);
      for (final source in card.sources) {
        expect(freshSourceAllowed(source.url), isTrue, reason: source.url);
      }
    }
    expect(freshSourceAllowed('http://wsava.org/x'), isFalse);
    expect(freshSourceAllowed('https://example.com/a'), isFalse);
  });

  test('adding a fresh card twice keeps one product and one bag', () async {
    final database = AppDatabase.memory();
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
    await controller.addFreshToPantry(
      cardId: 'slow-cook',
      holdDays: 2,
      dailyGrams: 50,
    );
    await controller.addFreshToPantry(
      cardId: 'slow-cook',
      holdDays: 3,
      dailyGrams: 40,
    );
    final bags = controller.pantry.where(
      (entry) => entry.product.barcode == freshBarcode('slow-cook'),
    );
    expect(bags, hasLength(1));
    expect(
      controller.products.where((item) => item.barcode == 'fresh:slow-cook'),
      hasLength(1),
    );
    final bag = bags.single;
    expect(bag.item.afterOpenDays, 3);
    expect(bag.item.dailyGrams, 40);
    expect(bag.item.openedAt, DateTime(2026, 10, 12));
    expect(bag.product.isCustom, isTrue);
    expect(bag.product.name, contains('不是全价'));
    await database.close();
  });

  testWidgets('the pantry card opens a recipe and stocks it', (tester) async {
    final database = AppDatabase.memory();
    final controller = AppController(
      repo: DriftCareRepository(database),
      notifications: NoopNotificationService(),
      recognizer: const MockCoatBreedRecognizer(),
      clock: () => DateTime(2026, 10, 12, 10),
    );
    await controller.init();
    await boot(tester, controller, location: '/pantry');
    await tapText(tester, '自制鲜食');
    expect(find.text('长期当主食前，先给兽医或营养师确认'), findsOneWidget);
    await tapText(tester, '慢煮一份熟肉');
    expect(find.text('加入粮仓并提醒'), findsOneWidget);
    await tapText(tester, '加入粮仓并提醒');
    expect(find.text('已加入粮仓'), findsOneWidget);
    expect(
      controller.pantry.where(
        (entry) => entry.product.barcode == 'fresh:slow-cook',
      ),
      hasLength(1),
    );
    await database.close();
  });
}
