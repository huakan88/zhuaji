import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/food/stock.dart';

void main() {
  final today = DateTime(2026, 10, 12);

  test('reads kilograms and grams, and ignores millilitres', () {
    expect(gramsFromSpec('2kg'), 2000);
    expect(gramsFromSpec('1.5 kg'), 1500);
    expect(gramsFromSpec('85g'), 85);
    expect(gramsFromSpec('500克'), 500);
    expect(gramsFromSpec('1千克'), 1000);
    expect(gramsFromSpec('85ml'), isNull);
    expect(gramsFromSpec(''), isNull);
  });

  test('unopened bag lasts the full pack', () {
    final estimate = estimateStock(
      spec: '2kg',
      dailyGrams: 50,
      openedAt: null,
      today: today,
    );
    expect(estimate.daysLeft, 40);
    expect(estimate.runOutOn, DateTime(2026, 11, 21));
    expect(estimate.low, isFalse);
    expect(stockHint(estimate), '大约还能吃 40 天');
  });

  test('opened bag subtracts each day and warns inside a week', () {
    final estimate = estimateStock(
      spec: '1.5kg',
      dailyGrams: 80,
      openedAt: DateTime(2026, 9, 30),
      today: today,
    );
    expect(estimate.remainingGrams, 540);
    expect(estimate.daysLeft, 6);
    expect(estimate.low, isTrue);
    expect(stockHint(estimate), contains('该补货了'));
  });

  test('bag status keeps the sooner of eating and expiry', () {
    final full = estimateStock(
      spec: '2kg',
      dailyGrams: 50,
      openedAt: null,
      today: today,
    );
    expect(
      bagStatus(
        estimate: full,
        expiry: DateTime(2027, 10, 12),
        useBy: null,
        today: today,
        opened: true,
      ),
      '还能吃 40 天',
    );
    final low = estimateStock(
      spec: '1.5kg',
      dailyGrams: 80,
      openedAt: DateTime(2026, 9, 30),
      today: today,
    );
    expect(
      bagStatus(
        estimate: low,
        expiry: DateTime(2027, 1, 1),
        useBy: null,
        today: today,
        opened: true,
      ),
      '快吃完，还能吃 6 天',
    );
    expect(
      bagStatus(
        estimate: full,
        expiry: DateTime(2026, 10, 15),
        useBy: null,
        today: today,
        opened: true,
      ),
      '快到期，还剩 3 天',
    );
    expect(
      bagStatus(
        estimate: estimateStock(
          spec: '2kg',
          dailyGrams: null,
          openedAt: null,
          today: today,
        ),
        expiry: DateTime(2026, 10, 1),
        useBy: null,
        today: today,
        opened: true,
      ),
      '已过期',
    );
    expect(
      bagStatus(
        estimate: estimateStock(
          spec: '',
          dailyGrams: null,
          openedAt: null,
          today: today,
        ),
        expiry: DateTime(2027, 4, 1),
        useBy: null,
        today: today,
        opened: false,
      ),
      '没开封',
    );
    expect(
      bagStatus(
        estimate: estimateStock(
          spec: '',
          dailyGrams: null,
          openedAt: null,
          today: today,
        ),
        expiry: null,
        useBy: null,
        today: today,
        opened: true,
      ),
      '日期还没填',
    );
  });

  test('asks for a daily amount before estimating', () {
    final estimate = estimateStock(
      spec: '2kg',
      dailyGrams: null,
      openedAt: today,
      today: today,
    );
    expect(estimate.daysLeft, isNull);
    expect(stockHint(estimate), '点一下每天喂多少');
    expect(
      stockHint(
        estimateStock(spec: '', dailyGrams: 40, openedAt: null, today: today),
      ),
      '包装上没有克数，没法估算',
    );
  });
}
