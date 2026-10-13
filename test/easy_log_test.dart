import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/domain/care/easy_log.dart';
import 'package:maokangji/domain/models.dart';

void main() {
  test('vaccine dates follow age', () {
    final adult = nextVaccineDate(DateTime(2020, 1, 1), DateTime(2026, 10, 12));
    expect(adult, DateTime(2027, 10, 12));
    final kitten = nextVaccineDate(
      DateTime(2026, 6, 1),
      DateTime(2026, 10, 12),
    );
    expect(kitten, DateTime(2026, 11, 9));
  });

  test('a month of weight change over 5 percent is an alert', () {
    WeightRecord point(int daysAgo, double kg) => WeightRecord(
      id: daysAgo,
      catId: 1,
      loggedOn: DateTime(2026, 10, 12).subtract(Duration(days: daysAgo)),
      weightKg: kg,
    );

    final calm = weightChangeOverMonth([point(28, 4.50), point(0, 4.35)]);
    expect(calm, isNotNull);
    expect(calm!.notable, isFalse);

    final drop = weightChangeOverMonth([point(30, 5.0), point(0, 4.7)]);
    expect(drop!.notable, isTrue);
    expect(drop.percent, closeTo(-0.06, 0.001));

    final slow = weightChangeOverMonth([point(80, 5), point(0, 4)]);
    expect(slow!.notable, isTrue);
  });
}
